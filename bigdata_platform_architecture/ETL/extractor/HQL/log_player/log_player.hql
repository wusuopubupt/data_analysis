USE your_db_name;

CREATE TABLE IF NOT EXISTS log_player (
    source_host STRING    COMMENT 'the source host of log',
    event_date  STRING    COMMENT 'yearMonthDay',
    event_time  STRING    COMMENT 'hour:minute:second',
    module      STRING    COMMENT 'module name',
    pid         STRING    COMMENT 'pid',
    app         STRING    COMMENT 'app name',
    pccode      STRING    COMMENT 'pccode',
    version     STRING    COMMENT 'client version',
    channel     STRING    COMMENT 'channel',
    ip          STRING    COMMENT 'client IP',
    url_fields  MAP<STRING,STRING>  COMMENT 'url fields')
COMMENT 'table for log_player'
PARTITIONED BY(date_time STRING, hour_minute STRING);
