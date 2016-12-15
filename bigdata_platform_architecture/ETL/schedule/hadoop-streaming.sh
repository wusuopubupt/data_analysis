#!/bin/bash
hdfs dfs -rm -r hdfs://ip:port/user/dashwang/tmp/output

#           symbol link
# my_script  ----->   mr.tar.gz
#	./mapper.sh
#	./reducer.sh

# cat 1.txt 2.txt | wc -l
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-2.7.1.jar  \
		-archives "hdfs://ip:port/user/dashwang/tmp/archives/mr.tar.gz#my_script" \
		-D mapreduce.map.memory.mb=2048 \
		-D mapreduce.job.reduces=1 \
		-D mapred.job.name=prophet_hadoop_streaming_atom_test  \
		-input /user/dashwang/tmp/input/1.txt  \
		-input /user/dashwang/tmp/input/2.txt  \
		-output /user/dashwang/tmp/output/ \
		-mapper "bash ./my_script/mapper.sh" \
		-reducer "bash ./my_script/reducer.sh"



