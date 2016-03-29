#!/bin/bash
# remove all svn files recursively
# refer : http://stackoverflow.com/questions/5282279/subversion-how-to-remove-all-svn-files-recursively
find . -name .svn -exec rm -rf {} \;
