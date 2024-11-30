drop table if exists ads_reach_report_monitoring;
create table ads_reach_report_monitoring
(
     reportname      varchar(256)
    ,reporttype      int8
    ,cdp_group_name_num      int8
    ,campaign_name_num       int8
    ,content_id_num      int8
    ,content_title_num       int8
    ,channel_num     int8
    ,content_name_num        int8
    ,bpid_num        int8
    ,sent_number     int8
    ,sent_time       int8
    ,delivery_number     int8
    ,delivery_time       int8
    ,dmtread_time_total      int8
    ,unionid     int8
    ,openid      int8
    ,cid     int8
    ,creat_time   timestamp  default current_timestamp  
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (reportname)
;
