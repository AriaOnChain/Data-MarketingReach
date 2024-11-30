
drop table if exists dws_report_sms_date;
create table dws_report_sms_date
(
    data_date date
    ,timestamp_v timestamp  default current_timestamp
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (data_date)
;

drop table if exists dws_report_mail_date;
create table dws_report_mail_date
(
    data_date date
    ,timestamp_v timestamp  default current_timestamp
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (data_date)
;

drop table if exists dws_report_wechat_date;
create table dws_report_wechat_date
(
    data_date date
    ,timestamp_v timestamp  default current_timestamp
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (data_date)
;

drop table if exists ads_report_sms;
--创建自增序列
drop sequence if exists ads_report_sms_id_seq;
create sequence ads_report_sms_id_seq increment by 1 minvalue 1 no maxvalue start with 1;
--营销触达报告-短信



create table ads_report_sms (
     cdp_group_id int8
    ,cdp_group_name varchar(256)
    ,cdp_group_uv int8
    ,smscampaignname varchar(256)
    ,smscontentid int8
    ,smscontentname text
    ,smslink text
    ,smschannel varchar(256)
    ,bpid varchar(256)
    ,phone int8
    ,tag varchar(256)
    ,smssentnumber int8
    ,smstime timestamp
    ,smsdeliverstatus_delivrd varchar(256)
    ,smsdeliveredtime timestamp
    ,smsuniqueclick int8
    ,smsclickdate timestamp
    ,sentdate timestamp
    ,timestamp_v timestamp  default current_timestamp
    ,id int8
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (cdp_group_id,bpid,sentdate)
;
alter table ads_report_sms alter column id set default nextval('ads_report_sms_id_seq ');


drop table if exists ads_report_mail;
--创建自增序列
drop sequence if exists ads_report_mail_id_seq;
create sequence ads_report_mail_id_seq increment by 1 minvalue 1 no maxvalue start with 1;


--营销触达报告-邮件

create table ads_report_mail (
     cdp_group_id int8
    ,cdp_group_name varchar(256)
    ,cdp_group_uv int8
    ,dmdcampaignname varchar(256)
    ,dmdmailingname varchar(256)
    ,dmdcontentid int8
    ,dmdcontentname varchar(256)
    ,dmdclickurl text
    ,dmdchannel varchar(256)
    ,bpid varchar(256)
    ,email varchar(256)
    ,tag varchar(256)
    ,dmdsentnumber int8
    ,dmdlogdate timestamp
    ,dmdtype_sent int8
    ,dmdlogdate_sent timestamp
    ,dmdtype_open int8
    ,dmdlogdate_open timestamp
    ,dmdtype_click int8
    ,dmdlogdate_click timestamp
    ,dmdlogdate_unsubscribe timestamp
    ,sentdate timestamp
    ,timestamp_v timestamp
    ,id int8
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (cdp_group_id,bpid,sentdate)
;
alter table ads_report_mail alter column id set default nextval('ads_report_mail_id_seq ');



drop table if exists ads_report_wechat;
--创建自增序列
drop sequence if exists ads_report_wechat_id_seq;
create sequence ads_report_wechat_id_seq increment by 1 minvalue 1 no maxvalue start with 1;

--营销触达报告-微信

create table ads_report_wechat (
     cdp_group_id int8
    ,cdp_group_name varchar(256)
    ,cdp_group_uv int8
    ,dmtcampaignname varchar(256)
    ,dmtcontenttitle varchar(512)
    ,dmtcontentid varchar(256)
    ,dmtcontentname varchar(256)
    ,dmtclickurl text
    ,dmtarticleidx varchar(256)
    ,dmtchannel varchar(256)
    ,bpid varchar(256)
    ,unionid varchar(256)
    ,openid varchar(256)
    ,tag varchar(256)
    ,dmtsentnumber int8
    ,dmtsentdate timestamp
    ,dmtdeliverynumber int8
    ,dmtdeliverytime timestamp
    ,dmtreadtimetotal varchar(256)
    ,dmtreadtime int8
    ,dmtclick int8
    ,dmtclickdate timestamp
    ,sentdate timestamp
    ,appid varchar(256)
    ,timestamp_v timestamp
    ,id int8
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (cdp_group_id,unionid,sentdate)
;
alter table ads_report_wechat alter column id set default nextval('ads_report_wechat_id_seq ');



drop table if exists dws_report_apppush_date;
create table dws_report_apppush_date
(
    data_date date
    ,timestamp_v timestamp  default current_timestamp
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (data_date)
;

drop table if exists ads_report_apppush;
--创建自增序列
drop sequence if exists ads_report_apppush_id_seq;
create sequence ads_report_apppush_id_seq increment by 1 minvalue 1 no maxvalue start with 1;

--营销触达报告-个推

create table ads_report_apppush (
     cdp_group_id int8
    ,cdp_group_name varchar(256)
    ,cdp_group_uv int8
    ,apushcampaignname varchar(256)
    ,apushcontentid text
    ,apushcontenttitle varchar(512)
    ,apushcontentmessage text
    ,apushclicklink text
    ,apushchannel varchar(256)
    ,bpid varchar(256)
    ,cid varchar(256)
    ,tag varchar(256)
    ,apushsentnumber int8
    ,apushtime timestamp
    ,apushdeliverednumber int8
    ,apushdeliveredtime timestamp
    ,apushuniqueclick text
    ,apushclickdate timestamp
    ,sentdate timestamp
    ,timestamp_v timestamp
    ,id int8
)with (appendonly=true,orientation=column,compresstype=zlib,compresslevel=5)
    distributed by (cdp_group_id,bpid,sentdate)
;
alter table ads_report_apppush alter column id set default nextval('ads_report_apppush_id_seq ');




comment on column ads_report_sms.cdp_group_id is 'CDP人群包ID';
comment on column ads_report_sms.cdp_group_name is 'CDP人群包名称';
comment on column ads_report_sms.cdp_group_uv is 'CDP人群包总人数';
comment on column ads_report_sms.smscampaignname is '营销活动名称';
comment on column ads_report_sms.smscontentid is '素材ID';
comment on column ads_report_sms.smscontentname is '素材名称';
comment on column ads_report_sms.smslink is '点击链接';
comment on column ads_report_sms.smschannel is '触达渠道';
comment on column ads_report_sms.bpid is '会员BPid';
comment on column ads_report_sms.phone is '会员手机号';
comment on column ads_report_sms.tag is '标签';
comment on column ads_report_sms.smssentnumber is '推送UV';
comment on column ads_report_sms.smstime is '推送时间';
comment on column ads_report_sms.smsdeliverstatus_delivrd is '送达状态';
comment on column ads_report_sms.smsdeliveredtime is '送达时间';
comment on column ads_report_sms.smsuniqueclick is '点击链接UV';
comment on column ads_report_sms.smsclickdate is '点击链接时间';
comment on column ads_report_sms.sentdate is '活动执行时间';
comment on column ads_report_sms.timestamp_v is '数据处理时间';
comment on column ads_report_sms.id is '自增id';




comment on column ads_report_mail.cdp_group_id is 'CDP人群包ID';
comment on column ads_report_mail.cdp_group_name is 'CDP人群包名称';
comment on column ads_report_mail.cdp_group_uv is 'CDP人群包总人数';
comment on column ads_report_mail.dmdcampaignname is '营销活动名称';
comment on column ads_report_mail.dmdmailingname is '内容标题';
comment on column ads_report_mail.dmdcontentid is '素材ID';
comment on column ads_report_mail.dmdcontentname is '素材名称';
comment on column ads_report_mail.dmdclickurl is '点击链接';
comment on column ads_report_mail.dmdchannel is '触达渠道';
comment on column ads_report_mail.bpid is '会员BPid';
comment on column ads_report_mail.email is '邮箱';
comment on column ads_report_mail.tag is '标签';
comment on column ads_report_mail.dmdsentnumber is '推送UV';
comment on column ads_report_mail.dmdlogdate is '推送时间';
comment on column ads_report_mail.dmdtype_sent is '送达UV';
comment on column ads_report_mail.dmdlogdate_sent is '送达时间';
comment on column ads_report_mail.dmdtype_open is '打开UV';
comment on column ads_report_mail.dmdlogdate_open is '打开时间';
comment on column ads_report_mail.dmdtype_click is '点击链接UV';
comment on column ads_report_mail.dmdlogdate_click is '点击链接时间';
comment on column ads_report_mail.dmdlogdate_unsubscribe is '取消订阅时间';
comment on column ads_report_mail.sentdate is '活动执行时间';
comment on column ads_report_mail.timestamp_v is '数据处理时间';
comment on column ads_report_mail.id is '自增id';




comment on column ads_report_wechat.cdp_group_id is 'CDP人群包ID';
comment on column ads_report_wechat.cdp_group_name is 'CDP人群包名称';
comment on column ads_report_wechat.cdp_group_uv is 'CDP人群包总人数';
comment on column ads_report_wechat.dmtcampaignname is '营销活动名称';
comment on column ads_report_wechat.dmtcontenttitle is '内容标题';
comment on column ads_report_wechat.dmtcontentid is '素材ID';
comment on column ads_report_wechat.dmtcontentname is '素材名称';
comment on column ads_report_wechat.dmtclickurl is '点击链接';
comment on column ads_report_wechat.dmtarticleidx is '内容位置';
comment on column ads_report_wechat.dmtchannel is '触达渠道';
comment on column ads_report_wechat.bpid is '会员BPid';
comment on column ads_report_wechat.unionid is 'unionid';
comment on column ads_report_wechat.openid is 'openid';
comment on column ads_report_wechat.tag is '标签';
comment on column ads_report_wechat.dmtsentnumber is '推送UV';
comment on column ads_report_wechat.dmtsentdate is '推送时间';
comment on column ads_report_wechat.dmtdeliverynumber is '送达UV';
comment on column ads_report_wechat.dmtdeliverytime is '送达时间';
comment on column ads_report_wechat.dmtreadtimetotal is '公众号消息阅读次数 (粉丝+非粉丝)';
comment on column ads_report_wechat.dmtreadtime is '公众号消息阅读次数 (仅粉丝)[A1]';
comment on column ads_report_wechat.dmtclick is '点击链接UV';
comment on column ads_report_wechat.dmtclickdate is '点击链接时间';
comment on column ads_report_wechat.sentdate is '活动执行时间';
comment on column ads_report_wechat.timestamp_v is '数据处理时间';
comment on column ads_report_wechat.id is '自增id';




comment on column ads_report_apppush.cdp_group_id is 'CDP人群包ID';
comment on column ads_report_apppush.cdp_group_name is 'CDP人群包名称';
comment on column ads_report_apppush.cdp_group_uv is 'CDP人群包总人数';
comment on column ads_report_apppush.apushcampaignname is '营销活动名称';
comment on column ads_report_apppush.apushcontentid is '素材ID';
comment on column ads_report_apppush.apushcontenttitle is '推送标题';
comment on column ads_report_apppush.apushcontentmessage is '推送内容';
comment on column ads_report_apppush.apushclicklink is '推送链接';
comment on column ads_report_apppush.apushchannel is '触达渠道';
comment on column ads_report_apppush.bpid is '会员BPid';
comment on column ads_report_apppush.cid is '个推ID';
comment on column ads_report_apppush.tag is '标签';
comment on column ads_report_apppush.apushsentnumber is '推送UV';
comment on column ads_report_apppush.apushtime is '推送时间';
comment on column ads_report_apppush.apushdeliverednumber is '到达UV';
comment on column ads_report_apppush.apushdeliveredtime is '到达时间';
comment on column ads_report_apppush.apushuniqueclick is '点击UV';
comment on column ads_report_apppush.apushclickdate is '点击时间';
comment on column ads_report_apppush.sentdate is '活动执行时间';
comment on column ads_report_apppush.timestamp_v is '数据处理时间';
comment on column ads_report_apppush.id is '自增id';