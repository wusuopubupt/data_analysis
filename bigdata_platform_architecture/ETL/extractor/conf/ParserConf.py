#!/usr/bin/evn python
#-*- coding: UTF-8 -*-

import sys
from common.Parser import Parser 
from common.Parser import LogplayerParser

from common.Schema import SchemaParser

#获取Extractor脚本路径
path = sys.path[0]
hql_dir = path + '/HQL/'

# parser conf
parser_conf = {}

# 1. logplayer
logplayer_schema = SchemaParser(hql_dir + 'log_player/logplayer.hql')
logplayer_parser = Parser(BaiduplayerParser, logplayer_schema)
logplayer_conf = {'type': 'logplayer', \
                  'parser': logplayer_parser, \
                  'schema': logplayer_schema}
parser_conf['logplayer'] = logplayer_conf

# 2. log_view
log_view_schema = SchemaParser(hql_dir + 'log_pc/log_view.hql')
log_view_parser = Parser(PcWebViewParser, log_view_schema)
log_view_conf = {'type': 'log_view',\
                 'parser': log_view_parser, \
                 'schema': log_view_schema}
parser_conf['log_view'] = log_view_conf

