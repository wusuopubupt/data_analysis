#!/bin/bash
# 本地文件etl测试
set -x

head -10 ../extractor/data/mock_access_log* | ../extractor/common/lighttpd_log_parser.awk | python ../extractor/Extractor.py 

