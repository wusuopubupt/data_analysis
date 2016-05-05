#!/bin/env python
#-*- coding: UTF-8 -*-
import re
from Log import Log

class SchemaParser:
    '''
    hive schema parser
    '''

    def __init__(self, schema_file):
        self.regex = '.*CREATE TABLE IF NOT EXISTS (?P<table_name>\w+)\s*\(\s+(?P<columns>.*)\s*\)\s*COMMENT.*'
        self.schema_file = schema_file
        self.logger = Log()

    def parse(self):
        fp = open(self.schema_file, 'r')
        if fp:
            schema_data = fp.read()
            return self.do_parse(schema_data)
        else:
            self.logger.fatal("open schema file[%s] failed." % self.schema_file)
            return None

    def do_parse(self, hive_schema):
        content = hive_schema.replace('\n', ' ')
        pattern = re.compile(self.regex)
        # 从hive表结构定义的hql中解析出表名,各个字段名和字段类型
        result = pattern.search(content)
        if result:
            schema_dict = result.groupdict()

            self.table_name = schema_dict['table_name']
            columns = schema_dict['columns']

            self.schemas = []
            # 注意空格！ map<string,string> 
            column_list = columns.split(', ')
            for column in column_list:
                column_pairs = column.split()
                if len(column_pairs) >= 2 :
                    column_name = column_pairs[0]
                    column_type = column_pairs[1]
                    self.schemas.append({'name':column_name,'type':column_type})
                else :
                    self.logger.fatal('wrong format line:%s' %(column_pairs))
                    return None
        else:
            self.logger.fatal("schema regex search is not match, please check the schema")
            return None

        return self.schemas

    def print_schema(self):
        print 'table_name:',self.table_name
        i = 0
        for column in self.schemas:
            print 'column[%d]: %s, %s' %(i, column['name'], column['type'])
            i += 1

    def schema(self):
        return self.schemas

    def table_name(self):
        return self.table_name




