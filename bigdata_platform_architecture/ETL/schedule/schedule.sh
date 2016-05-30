#!/bin/sh
set -x

if [ $# -lt 1 ]
then
    echo "usage: ./run.sh conf_file"
    exit 1
fi

#¶ÁÈ¡ÅäÖÃ
conf=$1
if [ -f $conf ]
then
    source $conf
else
    echo "[FATAL] conf file [${conf}] is not exist."
    exit -1
fi

# ¼ÓÔØconfºó¶¨Òå£¬·ñÔòhadoop_commandÕÒ²»µ½
# É¾³ýhdfsÉÏµÄÄ¿Â¼»òÎÄ¼þ£¬ÊäÈëÁ½¸ö²ÎÊý£ºÄ¿Â¼Â·¾¶
# ²ÎÊý´íÎó·µ»Ø1£¬É¾³ýÊ§°Ü·µ»Ø2£¬³É¹¦·µ»Ø0
function hdfs_del_dir()
{
    if [ $# -lt 1 ]
    then
        return 1
    fi

    del_dir=$1

    hadoop_command fs -test -e ${del_dir}
    if [ $? -eq 0 ]
    then
        echo "[WARNING] dir [${del_dir}] is exist, will be deleted."

        hadoop_command fs -rmr ${del_dir}
        if [ $? -ne 0 ]
        then
            echo "[FATAL] delete dir [${del_dir}] failed."
            return 2
        fi
        echo "[TRACE] delete dir [${del_dir}] success."
    fi

    return 0
}

#ÆðÊ¼Ê±¼ä£¬×÷ÎªÄ¿Â¼
next_day=$START_DAY
next_hour=$START_HOUR
next_minute=$START_MINUTE

#ÈÎÎñµ÷¶ÈÊ±¼ä¼ä¸ô
time_interval=$TIME_INTERVAL

#Êý¾ÝÊäÈëºÍÊä³öÄ¿Â¼
source_dir_prefix=$SOURCE_DIR_PREFIX
mapred_output_dir_prefix=$MAPRED_OUTPUT_DIR_PREFIX
pipe_name=$LOG_PIPE_NAME
source_del_interval=$SOURCE_DEL_INTERVAL
ready_file_num=$READY_FILE_NUM

# ÈÝÈÌ²¿·ÖÊý¾Ý¶ªÊ§£¬µ«×î¶à¶ªÊ§10¸öÎÄ¼þ£¬Ò»°ãÊÇÓÉÓÚÉÏÓÎ»úÆ÷¹ÊÕÏ£¬µ¼ÖÂÈÕÖ¾µ¼³öÊ§°Ü
# Ò²¿ÉÄÜÊÇhadoopÑÓÊ±µ¼ÖÂ²¿·ÖÎÄ¼þÔÝÎ´¾ÍÐ÷£¬ÕâÖÖÇé¿ö´ýhadoop»Ö¸´Ê±»á×Ô¼º»Ö¸´Õý³£
# ÈôÊÇ»úÆ÷¹ÊÕÏµ¼ÖÂ£¬ÔòÐèÒªÈË¹¤checkÉÏÓÎlogagentÊÇ·ñÆô¶¯
min_ready_file_num=$(($ready_file_num - 10))

#Êý¾Ý×îÖÕµ¼ÈëµÄhive±í
hive_db=$HIVE_DB
hive_table=$HIVE_TABLE
partition_del_interval=$PARTITION_DEL_INTERVAL
#M/RÈÎÎñÃûÇ°×º
job_name_prefix=$JOB_NAME_PREFIX
#M/R½Å±¾Ãû¡¢ÅäÖÃ¡¢Â·¾¶
map_script=$MAP_SCRIPT
reduce_script=$REDUCE_SCRIPT
archive_path=$MAP_ARCHIVE_PATH

#log
log_file=$LOG_FILE

#¿ìÕÕÎÄ¼þ£¬±£´æÒÑ¾­´¦ÀíµÄÄ¿Â¼£¬°´Ê±¼äµÝÔö
snapshot_file=$SNAPSHOT_FILENAME
if [ -s $snapshot_file ]
then
    source $snapshot_file
    next_day=$NEXT_DAY
    next_hour=$NEXT_HOUR
    next_minute=$NEXT_MINUTE
fi

#·ÖÖÓÊý¶ÔÆë
next_minute=$((((next_minute/time_interval))*time_interval))
if [ $next_minute -lt 10 ]
then
    next_minute=0$next_minute
fi

error_recode_file=$WORK_DIR/error_recode
expected_file_num=$ready_file_num

wait_count=0
wait_time=60
while true
do
    day=$next_day
    hour=$next_hour
    minute=$next_minute
# Ô´Êý¾ÝÊÇ·ñready, Ä¿Â¼½á¹¹£º/prefix/pipename/20160304/1030
    #source_dir=${source_dir_prefix}/${pipe_name}/${date_dir}
    date_dir=${day}/${hour}${minute}
    source_dir=${source_dir_prefix}"/access_log."${day}${hour}${minute}".*"
    echo "[TRACE] begin to handling dat dir[${source_dir}]..." >> $log_file
    test_result=`hadoop_command fs -count ${source_dir}`
    ret_stat=$?

    file_count=`echo ${test_result} | awk '{print $2}'`
    if [ $file_count -eq $ready_file_num ]
    then
        expected_file_num=$ready_file_num
    fi

    if [ $ret_stat -ne 0 ] || [ $file_count -lt $expected_file_num ]
    then
#µ±Ô´Êý¾ÝÑÓÊ±1Ð¡Ê±Î´µ¼³öÊ±£¬Ìø¹ý¸ÃÊ±¶Î¼ì²é
        if [ $wait_count -eq 60 ]
        then
            task_name="${pipe_name}_${day}${hour}${minute}"
            echo "some error occur at time[$date_dir], file_count[$file_count]..." >> $log_file
            echo $date_dir >> $error_recode_file
            ./exception_reporter.sh ${task_name} 60

            if [ $file_count -ge $min_ready_file_num ]
            then
                echo "[WARNING] jump check dir[${source_dir}]" >> $log_file
                expected_file_num=$(($min_ready_file_num))
            fi
        else
            echo "[TRACE] ${test_result}" >> $log_file
            echo "[TRACE] source dir[${source_dir}] is not ready, wait one minute" >> $log_file
            sleep $wait_time
            ((wait_count++))
            # ÖØÐÂ¼ÆËãµÈ´ýÊ±¼ä
            continue
        fi
    fi
    wait_count=0

# Êä³öÄ¿Â¼ÊÇ·ñ´æÔÚ, Èô´æÔÚÔòÏÈÉ¾³ý
    mapred_output_dir=${mapred_output_dir_prefix}/${date_dir}
    hdfs_del_dir ${mapred_output_dir} >> $log_file
    if [ $? -ne 0 ]
    then
        echo "[FATAL] delete dir [${mapred_output_dir}] failed." >> $log_file
        continue
    fi

# ÔËÐÐM/RÈÎÎñ, Extraction and Transformation
    map_red_jobname="${job_name_prefix}_MR_${day}${hour}${minute}"
    hadoop_streaming -libjars "${HADOOP_CLASSPATH}/hadoop-streaming-custom-output-1.0.jar" \
                     -D mapred.job.name=${map_red_jobname} \
                     -mapper "${map_script}" \
                     -reducer "${reduce_script}" \
                     -input ${source_dir} \
                     -output ${mapred_output_dir} \
                     -outputformat com.custom.CustomMultiOutputFormat \
                     -cacheArchive ${archive_path}  2>> $log_file
    if [ $? -ne 0 ]
    then
        echo "[FATAL] hadoop M/R failed,job_name[${map_red_jobname}]." >> $log_file
        continue
    else
        echo "[TRACE] hadoop M/R success,job_name[${map_red_jobname}]." >> $log_file
    fi

# M/RÊä³öÊÇ·ñ´æÔÚ
    hadoop_command fs -test -e ${mapred_output_dir}
    if [ $? -eq 0 ]
    then
# µ¼Èëhive ±í, Loading
        hour_minute=${hour}${minute}
        hive_jobname="${job_name_prefix}_hive_${day}${hour}${minute}"
        hive -e "set mapred.job.name=${hive_jobname}; \
                 USE ${hive_db};  \
                 LOAD DATA INPATH '${mapred_output_dir}/log_player' \
                 OVERWRITE INTO TABLE ${hive_table} \
                 PARTITION(date_time=${day}, hour_minute=${hour_minute});" 2>> $log_file
        if [ $? -ne 0 ]
        then
            echo "[FATAL] hive command error,job_name[${hive_jobname}]." >> $log_file
            continue
        else
            echo "[NOTICE] load data to hive_table[${hive_table}] success,jobname[${hive_jobname}]" >> $log_file
        fi

# ¼ÆËãÏÂÒ»¸öÊ±¼äÄ¿Â¼
        timestamp=`date +"%s" -d "${day} ${hour}:${minute}"`
        timestamp=$((timestamp + time_interval * 60))
        date_string=`date  -d "1970-1-1 0:0:0 GMT + ${timestamp} seconds"`
        next_day=`date +"%Y%m%d" -d "${date_string}"`
        next_hour=`date +"%H" -d "${date_string}"`
        next_minute=`date +"%M" -d "${date_string}"`

# Ð´Èë¿ìÕÕ£¬¿ìÕÕÖÐ±íÊ¾ÏÂÒ»´ÎÒªÅÜµÄÄ¿Â¼
        echo "NEXT_DAY=${next_day}" > $snapshot_file;
        echo "NEXT_HOUR=${next_hour}" >> $snapshot_file;
        echo "NEXT_MINUTE=${next_minute}" >> $snapshot_file;
    else
        echo "[FATAL] input dir[${mapred_output_dir}] of hive is not exist." >> $log_file
        continue
    fi

# É¾³ýÀúÊ·Êý¾Ý
# É¾³ý3ÌìÖ®Ç°µÄÔ­Ê¼Êý¾Ý, Ô­Ê¼Êý¾Ý±£´æ3Ìì
    curtime=`date +"%s" -d "${day} ${hour}:${minute}"`
    some_days_ago=$((curtime - source_del_interval * 24 * 60 * 60))
    del_time=`date  -d "1970-1-1 0:0:0 GMT + ${some_days_ago} seconds"`
    del_day=`date +"%Y%m%d" -d "${del_time}"`
    del_hour=`date +"%H" -d "${del_time}"`
    del_minute=`date +"%M" -d "${del_time}"`
    del_source_dir=${source_dir_prefix}/${pipe_name}/${del_day}/${del_hour}${del_minute}
    hdfs_del_dir ${del_source_dir} >> ${log_file}
    if [ $? -ne 0 ]
    then
        echo "[FATAL] delete dir [${del_source_dir}] failed." >> $log_file
        continue
    fi

# É¾³ýhive±íÖÐ7ÌìÇ°µÄÊý¾Ý£¬´¦Àíºó½á¹û±£Áô7Ìì
    some_days_ago=$((curtime - partition_del_interval * 24 * 60 * 60))
    del_time=`date  -d "1970-1-1 0:0:0 GMT + ${some_days_ago} seconds"`
    del_day=`date +"%Y%m%d" -d "${del_time}"`
    del_hour=`date +"%H" -d "${del_time}"`
    del_minute=`date +"%M" -d "${del_time}"`
    del_hour_minute=${del_hour}${del_minute}
    hive_jobname="${job_name_prefix}_hive_del_${del_day}${del_hour_minute}"
    hive -e "set mapred.job.name=${hive_jobname}; \
             USE ${hive_db};  \
             ALTER TABLE ${hive_table} \
             DROP PARTITION (date_time=${del_day}, hour_minute=${del_hour_minute});" 2>> $log_file
    if [ $? -ne 0 ]
    then
        echo "[FATAL] hive command error,job_name[${hive_jobname}]." >> $log_file
        continue
    else
        echo "[NOTICE] drop partition from hive_table[${hive_table}] success, partition[${del_day}/${del_hour_minute}]" >> $log_file
    fi

done

exit 0

