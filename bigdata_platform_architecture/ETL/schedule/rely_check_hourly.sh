#!/bin/bash
# hive表小时级分区检查(rely check)
set -x
db="xiaoyaotest"
table=$1
day=$(date +%Y%m%d -d '-1 hour')
hour=$(date +%H -d '-1 hour')
if [ $# -eq 3 ];then
    day=$2
    hour=$3
fi
data_dir='./data'
if [ ! -d "${data_dir}/${table}" ];then
    mkdir -p "${data_dir}/${table}"
fi
partition="${data_dir}/${table}/partition_${day}_${hour}"
expected_num=6
while true;do
    hive -e "use $db; show partitions ${table};" > ${partition}
    # date_time=20160407/hour_minute=0810
    num_partition=$(cat ${partition} | grep "date_time=${day}" | grep "hour_minute=${hour}[012345]0" | wc -l)
    if [ ${num_partition} -ne ${expected_num} ];then
        sleep 5
        continue
    fi
    exit 0
done
