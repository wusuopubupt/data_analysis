#!/bin/bash
# dispatch flume to machines

set -x
passwd="your_passwd_here"

put_flume (){
    sshpass -p "$passwd" ssh -n -o StrictHostKeyChecking=no root@$1 'mkdir -p /home/hadoop' 
	sshpass -p "$passwd" scp -r /home/hadoop/apache-flume-1.5.0-bin root@$1:/home/hadoop/

    #ssh hadoop@$1 "mkdir -p /home/hadoop/xiaoyao03;scp -r cp01-guming-1.epc.baidu.com:/home/hadoop/apache-flume-1.5.0-bin /home/hadoop/xiaoyao03"
}

put_client_conf (){
    sshpass -p "$passwd" ssh -n -o StrictHostKeyChecking=no root@$1 'mkdir -p /home/hadoop/apache-flume-1.5.0-bin/spool;mkdir -p /home/hadoop/apache-flume-1.5.0-bin/checkpoint;mkdir -p /home/hadoop/apache-flume-1.5.0-bin/datadir' 
	sshpass -p "$passwd" scp  /home/hadoop/flume_client.conf root@$1:/home/hadoop/apache-flume-1.5.0-bin
}

put_collect_conf (){
	sshpass -p "$passwd" scp  /home/hadoop/flume_collect/$1/flume_collect.conf root@$1:/home/hadoop/apache-flume-1.5.0-bin
}

start_collector(){
    sshpass -p "$passwd" ssh -n -o StrictHostKeyChecking=no root@$1 '/home/hadoop/apache-flume-1.5.0-bin/bin/flume-ng agent --conf conf/ -f /home/hadoop/apache-flume-1.5.0-bin/flume_collect.conf -n collectorMainAgent' &
    #ssh hadoop@$1 "cd /home/hadoop/apache-flume-1.5.0-bin; \
    #bin/flume-ng agent --conf conf/ -f flume_collect.conf -n collectorMainAgent"
}

start_client(){
    sshpass -p "$passwd" ssh -n -o StrictHostKeyChecking=no root@$1 '/home/hadoop/apache-flume-1.5.0-bin/bin/flume-ng agent --conf conf/ -f /home/hadoop/apache-flume-1.5.0-bin/flume_client.conf -n clientMainAgent' &
    #ssh hadoop@$1 "cd /home/hadoop/apache-flume-1.5.0-bin; \
    #bin/flume-ng agent --conf conf/ -f flume_collect.conf -n collectorMainAgent"
}

#put File to every machine
if [ $1x = "put"x ];then
	while read hostname; do 
		put_flume $hostname 
	done < meachine_list
fi

#put Flume conf to every machine
if [ $1x = "conf_client"x ];then
	while read hostname; do 
		put_client_conf $hostname 
	done < meachine_client
fi

if [ $1x = "conf_collect"x ];then
	while read hostname; do 
		put_collect_conf $hostname 
	done < meachine_collect
fi

#start colletor
if [ $1x = "start_collect"x ];then
	while read hostname; do 
		start_collector $hostname 
	done < meachine_collect
fi

if [ $1x = "start_client"x ];then
	while read hostname; do 
		start_client $hostname 
	done < meachine_client
fi

