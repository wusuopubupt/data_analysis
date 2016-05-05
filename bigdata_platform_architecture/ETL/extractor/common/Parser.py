#!/bin/env python
#coding: utf8
import re
import sys
from Log import Log
from Utils import Utils


class Parser:
    """
    basic log parser class
    """

    def __init__(self, log_parser, schema_parser):
        self.log_parser = log_parser()
        self.schema_parser = schema_parser
        self.logger = Log()

    def parse(self, result_dict, line):
        """
        通用解析入口
        """
        qs = result_dict['qs_dict']
        # 各日志的私有字段
        result_dict = self.log_parser.extract_fields(qs, result_dict)

        if result_dict:
            ret = self.join_hive_columns(result_dict)
            if not ret:
                self.logger.fatal('parse line [%s] failed.' %(line))
                sys.exit()
            return ret
        else:
            self.logger.fatal('get common fields failed, line[%s].' % (line))
            return None

    def join_hive_columns(self, result_dict):
        """
        合并hive字段
        """
        schema = self.schema_parser.schema()
        columns = []
        for column in schema:
            try:
                key = column['name']
                # source_host 是从mapred中获取的，不是来自于日志
                if key == 'source_host':
                    continue

                if key in result_dict:
                    column_value = result_dict[key]
                    columns.append(column_value)
                # 只要HIVE表有个一个字段没在result_dict里就丢掉
                else:
                    self.logger.fatal('regex_dict has no key[%s]' %(key))
                    return None
            except KeyError,e:
                self.logger.fatal('Exception in log parser:%s' %(e))
                return None
        # hive默认列连接符\001 
        try:
            output_str = '\001'.join(columns)
            # 回车换行符转换成urlencode形式
            return output_str.replace('\n', '%0A').replace('\r', '%0D')
        except:
            return None


class LoglayerParser(object):
    """ 
    log_player log parser class
    """ 
    # 需要从query string中提取的字段
    _fields = ['pid', 'app', 'module', 'pccode', 'version', 'channel']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        从query string中提取各个不同业务自己的字段
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # 其他自定义字段处理逻辑
        # TODO
        return result_dict


class PcWebViewParser(object):
    """
    pc_web_view log parser class
    """
    # 需要从query string中提取的字段
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        从query string中提取各个不同业务自己的字段
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # 其他自定义字段处理逻辑
        # TODO
        return result_dict


class PcWebSearchParser(object):
    """
    pc_web_search log parser class
    """
    # 需要从query string中提取的字段
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        从query string中提取各个不同业务自己的字段
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # 其他自定义字段处理逻辑
        # TODO
        return result_dict


class PcWebPlayParser(object):
    """
    pc_web_play log parser class
    """
    # 需要从query string中提取的字段
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        从query string中提取各个不同业务自己的字段
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # 其他自定义字段处理逻辑
        # TODO
        return result_dict


class PcWebOthersParser(object):
    """
    pc_web_others log parser class
    """
    # 需要从query string中提取的字段
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        从query string中提取各个不同业务自己的字段
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # 其他自定义字段处理逻辑
        # TODO
        return result_dict

