#!/bin/bash
HADOOP_STREAMING_ARCHIVE_DIR='/usr/dash/archive/'
cd extractor
rm extractor-1.0.0.tar.gz 
tar -czvf extractor-1.0.0.tar.gz ./*
hadoop fs -rm ${HADOOP_STREAMING_ARCHIVE_DIR}extractor-1.0.0.tar.gz 
hadoop fs -put extractor-1.0.0.tar.gz ${HADOOP_STREAMING_ARCHIVE_DIR}
