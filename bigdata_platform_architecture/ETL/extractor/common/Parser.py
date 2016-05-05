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
        ͨ�ý������
        """
        qs = result_dict['qs_dict']
        # ����־��˽���ֶ�
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
        �ϲ�hive�ֶ�
        """
        schema = self.schema_parser.schema()
        columns = []
        for column in schema:
            try:
                key = column['name']
                # source_host �Ǵ�mapred�л�ȡ�ģ�������������־
                if key == 'source_host':
                    continue

                if key in result_dict:
                    column_value = result_dict[key]
                    columns.append(column_value)
                # ֻҪHIVE���и�һ���ֶ�û��result_dict��Ͷ���
                else:
                    self.logger.fatal('regex_dict has no key[%s]' %(key))
                    return None
            except KeyError,e:
                self.logger.fatal('Exception in log parser:%s' %(e))
                return None
        # hiveĬ�������ӷ�\001 
        try:
            output_str = '\001'.join(columns)
            # �س����з�ת����urlencode��ʽ
            return output_str.replace('\n', '%0A').replace('\r', '%0D')
        except:
            return None


class LoglayerParser(object):
    """ 
    log_player log parser class
    """ 
    # ��Ҫ��query string����ȡ���ֶ�
    _fields = ['pid', 'app', 'module', 'pccode', 'version', 'channel']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        ��query string����ȡ������ͬҵ���Լ����ֶ�
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # �����Զ����ֶδ����߼�
        # TODO
        return result_dict


class PcWebViewParser(object):
    """
    pc_web_view log parser class
    """
    # ��Ҫ��query string����ȡ���ֶ�
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        ��query string����ȡ������ͬҵ���Լ����ֶ�
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # �����Զ����ֶδ����߼�
        # TODO
        return result_dict


class PcWebSearchParser(object):
    """
    pc_web_search log parser class
    """
    # ��Ҫ��query string����ȡ���ֶ�
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        ��query string����ȡ������ͬҵ���Լ����ֶ�
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # �����Զ����ֶδ����߼�
        # TODO
        return result_dict


class PcWebPlayParser(object):
    """
    pc_web_play log parser class
    """
    # ��Ҫ��query string����ȡ���ֶ�
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        ��query string����ȡ������ͬҵ���Լ����ֶ�
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # �����Զ����ֶδ����߼�
        # TODO
        return result_dict


class PcWebOthersParser(object):
    """
    pc_web_others log parser class
    """
    # ��Ҫ��query string����ȡ���ֶ�
    _fields = ['fr']

    def __init__(self):
        self.logger = Log()
        self.utils = Utils()

    def extract_fields(self, qs, result_dict):
        """
        ��query string����ȡ������ͬҵ���Լ����ֶ�
        """
        for k in self._fields:
            result_dict[k] = self.utils.get_value(qs, k)
        # �����Զ����ֶδ����߼�
        # TODO
        return result_dict

