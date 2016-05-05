#!/usr/bin/env python
#-*- coding: UTF-8 -*-
import re
from Log import Log


class Utils(object):
    """ 
    utils class
    """ 

    def __init__(self):
        self.logger = Log()

    # �ֶ������url_fields�д����򷵻أ����򷵻ؿ�
    def get_value(self, query_dict, k):
        """ 
        get value from query dict by key
        """ 
        if k in query_dict:
            return query_dict[k]
        return ''
