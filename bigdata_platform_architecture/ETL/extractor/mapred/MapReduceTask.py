#!/usr/bin/env python
#-*- coding: UTF-8 -*-
"""
MR Task
"""
import sys
import os
import re
from datetime import datetime
from urlparse import urlparse
from urlparse import parse_qs

class MapReduceTask(object):
    """
       MR task for log parser
    """
    def __init__(self, parsers):
        self.parsers = parsers
        self.singlemap = SingleMap()

    def run(self):
        """
        run func
        """
        source_host = self.singlemap.get_src_hostname()

        for line in sys.stdin:
            line = line.strip()
            if len(line) == 0:
                continue
            result_dict = self.singlemap.get_common_fields(line)
            # 判断日志类型,调用不同日志的parser 
            log_type= self.singlemap.get_log_type(result_dict)
            if not log_type:
                continue
            result = self.parsers[log_type].parse(result_dict, line)
            if result:
                # MR multi output
                # hive表以001作为分隔符, mapreduce任务以\t作分隔符
                print '%s\t%s\001%s\001' % (log_type, source_host, result)


class SingleMap(object):
    """
       映射类
    """

    def __init__(self):
        pass

    def get_common_fields(self, line):
        """
        提取公有字段
        """
        fields_list = line.strip().split('\001')
        result_dict = {}
        # 公有字段
        ip = fields_list[0]
        date_time = datetime.strptime(fields_list[1], '%d/%b/%Y:%H:%M:%S')\
                            .strftime('%Y%m%d %H:%M:%S')
        date_time_dict = date_time.split(' ') 
        event_date = date_time_dict[0]
        event_time = date_time_dict[1]
        url = fields_list[5]
        # 解析url
        parse_res_dict = urlparse(url)
        path = parse_res_dict.path
        query = parse_res_dict.query
        # 所有打点参数K-V字典, fr=['a', 'b']形式的参数，取fr=b
        #qs = dict((k, v if len(v) > 1 else v[0]) for k, v in parse_qs(query).iteritems())
        qs = dict((k, v[-1]) for k, v in parse_qs(query).iteritems())
        # 注意：这些自动属于公有字段，get参数不允许再使用！
        result_dict['referer'] = fields_list[6]
        result_dict['cookie'] = fields_list[7]
        result_dict['user_agent'] = fields_list[8]
        result_dict['httpstatus'] = fields_list[3]
        result_dict['ip'] = ip
        result_dict['event_date'] = event_date
        result_dict['event_time'] = event_time
        result_dict['url'] = url
        result_dict['path'] = path
        result_dict['query'] = query
        result_dict['qs_dict'] = qs
        kv_dict = []
        for k, v in qs.iteritems():
            if type(v) is list:
                v = v[-1]
            kv_dict.append(k + "\003" + v)
        url_fields = '\002'.join(kv_dict)
        result_dict['url_fields'] = url_fields

        return result_dict

    def get_src_hostname(self):
        """
        从环境变量中获取MR任务的输入文件名, 区分各个不同源
        """
        env = os.environ
        hostname=''

        if 'map_input_file' in env:
            map_file_path = env['map_input_file']
            return map_file_path
            filename = map_file_path.split('/')[-1]
            hostname = filename.split('_')[1]

        return hostname

    def get_log_type(self, result_dict):
        """
        判断当前日志的类型, like udw
        """
        qs_dict = result_dict['qs_dict']
        url_pre = result_dict['path']
    
        
        # a
        if 'app' in qs_dict and qs_dict['app'] == 'log_a':
            return 'log_a'
        # b
        if url_pre == '/v':
            return 'log_b'
        # c
        pattern_play = re.compile(r'^\/(search)\/')
        if pattern_play.match(url_pre):
            return 'log_c'
