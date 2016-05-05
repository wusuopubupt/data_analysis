#!#/bin/env python
#-*- coding: UTF-8 -*-
import sys

class Log:
    '''
    output log info
    '''

    def fatal(self, log_str):
        print >> sys.stderr, '[FATAL] %s' %(log_str)

    def warning(self, log_str):
        print >> sys.stderr, '[WARNING] %s' %(log_str)

    def notice(self, log_str):
        print >> sys.stderr, '[NOTICE] %s' %(log_str)

    def trace(self, log_str):
        print >> sys.stderr, '[TRACE] %s' %(log_str)

    def debug(self, log_str):
        print >> sys.stderr, '[DEBUG] %s' %(log_str)

