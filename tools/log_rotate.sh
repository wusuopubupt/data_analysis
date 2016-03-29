#!/bin/bash
# rotate nginx access log every 10 minutes
set -x
app_path='/home/work/nginx'
nginx_path=${app_path}'/log/webserver/'
access_log=${nginx_path}'access_log'
log_time=`date +%Y%m%d%H%M -d "10 minutes ago"`
flume_path='/home/flume/spool/'
if [ -f ${access_log} ] ;then
    mv ${access_log} ${access_log}'.'${log_time}
    ln -s ${access_log}'.'${log_time} ${flume_path}'access_log.'${log_time}
fi
# reload nginx configure
kill -USR1 `cat $app_path/var/nginx.pid` || kill -USR1 `cat $app_path/log/nginx.pid`
