#!/bin/awk -f
# lighttpd log parser
# accesslog.format = "%{clientip}i %l %u %t \"%r\" %>s %b mod_gzip: %{gzip_ratio}npct. \"%{Referer}i\" %{Cookie}i \"%{User-Agent}i\""}}}}}

BEGIN {
    FS="\""
}
{
    #for(i=1;i<NF;i++) {
    #   print $i 
    #}
    split($1, a, " ")
    ip=a[1]
    datetime=substr(a[4],2)
    request=$2 
    referer=$4
    cookie=$5
    useragent=$6
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
    
    printf "%s\001%s\001%s\001%s\001%s\001%s\001%s\001%s\001%s\n", ip, datetime, method, code, protocol, url, referer, cookie, useragent
} 
