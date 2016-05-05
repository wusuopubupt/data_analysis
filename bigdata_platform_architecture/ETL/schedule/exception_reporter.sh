#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: ./exception_reporter.sh task_name minutes"
    exit 1
fi

task_name=$1
minutes=$2

cur_dir=`pwd`

. ${cur_dir}/lib/message_sender/func.conf.sh;

receiver_mobile='888888888'

# send message
content="[ETL����]:hdfs�����ļ�����������Ԥ�ڳ���${minutes}����,������:${task_name}.";

SendMessage "${content}" "${receiver_mobile}";

# send mail
mail_subject="[ETL�����쳣]";
mail_list='dash@mathandcs.com'
echo ${content} | mail ${mail_list} -s ${mail_subject} -c' '
