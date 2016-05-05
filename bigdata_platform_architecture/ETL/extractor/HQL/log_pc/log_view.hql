USE db_name;

CREATE TABLE IF NOT EXISTS log_view(
    source_host STRING    COMMENT 'the source host of log',
    event_date  STRING    COMMENT 'yearMonthDay',
    event_time  STRING    COMMENT 'hour:minute:second',
    ip          STRING    COMMENT 'client ip',
    url         STRING    COMMENT 'url',
    cookie      STRING    COMMENT 'cookie',
    referer     STRING    COMMENT 'http referer',
    user_agent  STRING    COMMENT 'ua',
    httpstatus  BIGINT    COMMENT 'http status',
    fr          STRING    COMMENT 'channel flag',
    url_fields MAP<STRING,STRING> COMMENT 'url fields')
COMMENT 'table for log_view'
PARTITIONED BY(date_time STRING, hour_minute STRING);
