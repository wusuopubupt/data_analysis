#!/usr/bin/env python
#-*- coding: UTF-8 -*-
import sys
from conf.ParserConf import parser_conf
from mapred.MapReduceTask import MapReduceTask
from common.Log import Log

if __name__ == '__main__':
    logger = Log()
    # 加载各个日志parser的配置
    parsers = {}
    for log_type, log_conf in parser_conf.iteritems():
        if 'schema' in log_conf:
            schema = log_conf['schema']
            ret = schema.parse()
            if not ret:
                logger.fatal('schema parse failed.')

        if 'parser' in log_conf:
            parser = log_conf['parser']
            parsers[log_type] = parser
        else:
            logger.fatal('log [%s] parser obj is not configured.' % log_type)
    # 运行MR任务
    mr_task = MapReduceTask(parsers)
    mr_task.run()
