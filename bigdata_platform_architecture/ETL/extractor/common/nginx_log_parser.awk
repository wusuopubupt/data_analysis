#!/bin/awk -f
# nginx log parser

BEGIN {
    FS="\""
}
{
    split($1, a, " ")
    ip=a[1]
    datetime=substr(a[4],2)
    request=$2 
    referer=$4
    cookie=$6
    useragent=$8
    split($3, c, " ")
    code=c[1]
    size=c[2]
    n=split(request, detail, " ")
    method=detail[1]
    url=""
    for(i=2; i<n; i++) {
        url=(url" "detail[i]) 
    }
    url=substr(url, 2)
    protocol=detail[n]
    split($10, others, " ")
    ssl_header=others[3]
    
    printf "%s\001%s\001%s\001%s\001%s\001%s\001%s\001%s\001%s\n", ip, datetime, method, code, protocol, url, referer, cookie, useragent
} 
