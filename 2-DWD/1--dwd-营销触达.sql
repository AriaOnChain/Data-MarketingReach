

create or replace function bi_dwd_report()
RETURNS pg_catalog.int4
AS
$BODY$
DECLARE

    var_app_name varchar := 'bi_dwd_report';
    var_app_tab_name varchar := 'dwd_report';
	  var_func_desc varchar := 'dwd营销触达';
    var_app_start_time timestamp  ;
    var_app_end_time timestamp  ;
    SQLSTATE varchar := 0;
    SQLERRM varchar := '';
    var_call_msg text := '成功';
    var_done_res int := 1;
    var_fail_res int := -1;
    VAR_PERIOD_TYPE varchar := '';
    VAR_PERIOD_VAL varchar := '';
    row record;
BEGIN

SELECT clock_timestamp() into var_app_start_time;

raise notice '-------- !!!开始 : % -- 函数: % --------',var_app_start_time,var_app_name;
------------------------------------------------------------------------------

--公用表
drop table if exists dwd_common;
create table dwd_common as
  select
   t1.id
  ,t1.id as task_id
  ,t2.task_id as pd
  ,t1.node_id
  ,bi_time_add_8hour(t2.create_time) as create_time
  ,bi_time_add_8hour(t1.create_time) as create_time1
  ,t1.node_name
  ,t1.campaign_name
  ,t1.action_type
  ,t2.send_count
  ,t2.click_count
  ,t2.reach_count
  ,t1.process_id
  ,t1.campaign_id
  ,to_char(bi_time_add_8hour(t1.actual_actiontime), 'YYYY-MM-DD HH24:MI:SS') as actual_actiontime
  ,t1.brand_id
from pre_actiontask t1
left join pre_tasklog t2
on t1.id = t2.task_id 
--排除测试执行数据
where test_run != 'true'
;



--根据occ_id、originId 取bpid unionid 的逻辑赋值
drop table if exists dwd_common_id;
create table dwd_common_id as
  select 
    occ_id 
    
    ,case when bind_origin_id is null then
               case when channel_type ='MEMBER' then origin_id end
          when bind_origin_id is not null then 
          	   case when bind_channel_type = 'MEMBER' then bind_origin_id
          	   		when channel_type1 = 'MEMBER' then origin_id1 end
     end as bpid
    ,case when bind_origin_id is null then
              case when channel_type ='WECHAT' then origin_id end
          when bind_origin_id is not null then 
          	   case when bind_channel_type = 'WECHAT' then bind_origin_id
          	   		when channel_type1 = 'WECHAT' then origin_id1 end
    end as unionid
    from (select
     t1.occ_id 
    ,t1.origin_id as origin_id
    ,t1.channel_type as channel_type
    ,t2.bind_channel_type
    ,t2.bind_origin_id
    ,t2.channel_type as channel_type1
    ,t2.origin_id as origin_id1
  from pre_omnichannelcustomer t1
  left join pre_omnichannelcustomerrel t2
  on t1.origin_id = t2.bind_origin_id ) a;

--测试数据 有重复需去重
drop table if exists dws_common_id;
create table dws_common_id as
  select occ_id,bpid,min(unionid) as unionid
  from dwd_common_id
  group by occ_id,bpid ;

--查出邮箱、手机过滤同一occ_id的没有绑定信息的bpid
-- drop table if exists dwd_common_binding_id;
-- create table dwd_common_binding_id as
-- select t1.occ_id,t1.bpid,t1.unionid, t2.email ,t2.mobile 
--       from dws_common_id t1
--       left join pre_prctvmkt_member t2 on t2.bp_id = t1.bpid;

--补缺失bpid数据
-- drop table if exists dwd_bpid_patch;
-- create table dwd_bpid_patch as
-- select t1.occ_id,sms.bp_id as sms_bp_id,mail.bp_id as mail_bp_id
-- from pre_prctvmkt_customer t1
-- left join pre_prctvmkt_member sms
-- on t1.mobile =sms.mobile 
-- left join pre_prctvmkt_member mail
-- on t1.email =mail.email;

drop table if exists dwd_bpid_patch2;
create table dwd_bpid_patch2 as
  select occ_id,min(bpid) as bpid from (
select 
    t1.occ_id,
case when t2.bind_channel_type = 'MEMBER' then t2.bind_origin_id
     when t2.channel_type = 'MEMBER' then t2.origin_id end
     as bpid
 from pre_omnichannelcustomer t1
  left join pre_omnichannelcustomerrel_0717 t2
  on t1.origin_id = t2.bind_origin_id ) a 
  group by occ_id ;






--营销动作-短信动作明细 
drop table if exists dwd_sub_task_node_cust_all;
create table dwd_sub_task_node_cust_all as
  select
       t1.id
      ,t1.id as task_id
      ,t2.subtask_id
      ,t1.node_id
      ,bi_time_add_8hour(t2.create_time) as create_time
      ,t2.occ_id
      ,t2.content
      ,t2.mobile
      ,bi_time_add_8hour(t2.submit_time) as submit_time
      ,t2.delivery_status
      ,bi_time_add_8hour(t2.reach_time)  as reach_time
      ,t2.status
    from pre_actiontask t1
    left join pre_mc_action_smstasklog t2
    on t1.id=t2.task_id
    where t2.status='SUCCESS'
    --过滤异常任务
    --where t2.task_id is not null 
    ;


--短信长链 明细
-- drop table if exists dwd_sub_task_cust_url_all;
-- create table dwd_sub_task_cust_url_all as
--   select
--       t2.task_id
--       ,t2.subtask_id
--       ,t2.member_id as occ_id
--       ,t4.external_url  --长链
--       ,t5.id
--       ,t5.created as created
--     from pre_mc_action_personalizedshortlinkrecord t2
--     left join pre_prctvmkt_urlrelation t3   	
--     on right(t2.personalized_short_link,8) = t3.short_link
--     left join pre_prctvmkt_externallink t4
--     on t3.h5_short_link = t4.short_link

--     left join pre_prctvmkt_effectevaluationmember t5
--     on t4.id =t5.external_link_id::text
--     and t2.member_id = t5.member_id::text
--     and t3.campaign_detail_id=t5.campaign_detail_id::text
-- ;因短链回收导致一条短链对应多条长链
--短信长链 明细
drop table if exists dwd_sub_task_cust_url_all;
create table dwd_sub_task_cust_url_all as
select
      t2.task_id
      ,t2.subtask_id
      ,t2.member_id as occ_id
      ,t4.external_url  --长链
      ,t5.id
      ,t5.created as created
from pre_prctvmkt_campaigndetail t6  --增加表 过虑因短链重复利用导致的数据错误
inner join pre_actiontask t1 --主表
on t1.node_id=t6.nodeid
and t1.process_id=t6.jobid
left join pre_mc_action_smstasklog tt
on t1.id=tt.task_id
left join pre_mc_action_personalizedshortlinkrecord t2
on tt.subtask_id=t2.subtask_id and tt.occ_id=t2.member_id
left join pre_prctvmkt_urlrelation t3
on t6.id =t3.campaign_detail_id
and right(t2.personalized_short_link,8) = t3.short_link
left join pre_prctvmkt_externallink t4
on t3.h5_short_link = t4.short_link
left join pre_prctvmkt_effectevaluationmember t5
on t4.id =t5.external_link_id::text
and t2.member_id = t5.member_id::text
and t3.campaign_detail_id=t5.campaign_detail_id::text
;

--营销动作-短信动作去重
drop table if exists dwd_sub_task_sms;
create table dwd_sub_task_sms as
    select 
         t1.node_id
        ,t1.occ_id
        ,t1.create_time
        ,t1.task_id
        ,min(t1.mobile) as mobile
        ,min(status) as status
        ,min(t1.content) as content
        ,min(t1.submit_time) as submit_time
        ,min(t1.delivery_status) as delivery_status
        ,min(t1.reach_time) as reach_time
        ,min(t2.external_url) as external_url
        ,count(t2.id) as click_count
        ,min(t2.created) as click_time
    from dwd_sub_task_node_cust_all t1
    left join dwd_sub_task_cust_url_all t2
    on t1.subtask_id=t2.subtask_id and t1.occ_id=t2.occ_id
    group by t1.node_id,t1.occ_id,t1.create_time,t1.task_id ;



--邮件 明细
drop table if exists dwd_sub_task_mail_all;
create table dwd_sub_task_mail_all as
  select
       t1.occ_id
      ,t1.task_id
      ,bi_time_add_8hour(t2.create_time) as create_time2
      ,t1.email
      ,t3.comment
      ,t2.behavior
      ,t1.mail_name
      ,t1.status
      ,bi_time_add_8hour(t1.submit_time) as submit_time
      ,bi_time_add_8hour(t1.reach_time) as reach_time
      ,bi_time_add_8hour(t1.create_time) as create_time
    from  pre_mc_action_edmtasklog t1
    left join pre_mc_action_edmreachbehaviorloganalysis t2
    on t1.task_id = t2.action_taskid
    and t1.occ_id = t2.occ_id

    --展示所有连接,'，'拼接
    left join (
          select string_agg(comment , '，' ) as comment,occ_id,action_taskid  from (
          select comment,occ_id,action_taskid from pre_mc_action_edmreachbehaviorloganalysis
          where behavior ='CLICK'
          group by comment,occ_id,action_taskid ) a group by occ_id,action_taskid ) t3
    on t2.action_taskid=t3.action_taskid and t2.occ_id=t3.occ_id

    --过滤异常任务
    --where t2.action_taskid is not null 
    where t1.status='SUCCESS'
    ;

--邮件 去重
drop table if exists dwd_sub_task_mail;
create table dwd_sub_task_mail as
  select 
    task_id,
    create_time, 
    occ_id,
    min(email) as email,
    min(status) as status,
    min(comment) as comment,
    min(submit_time) as submit_time,
    min(reach_time) as reach_time,
    min(mail_name) as mail_name,
    count(case when behavior='OPEN' then occ_id end) as dmdtype_open,
    min(case when behavior = 'OPEN' then create_time2 end) as dmdlogdate_open,
    count(case when behavior='CLICK' then occ_id end) as dmdtype_click,  
    min(case when behavior = 'CLICK' then create_time2 end) as dmdlogdate_click,
    min(case when behavior = 'UNSUBSCRIBE' then create_time2 end) as dmdlogdate_unsubscribe,
    min(case when behavior = 'SENT' then create_time2 end) as send_time
  from dwd_sub_task_mail_all
  group by occ_id,task_id,create_time;

--邮件打开UV 点击链接UV汇总，同一素材ID的应相同  需求更新 此逻辑作废
-- drop table if exists dws_report_mail;
-- create table dws_report_mail as
-- select
--     null                  as cdp_group_id                 --CDP人群包ID
--     ,t1.node_name          as cdp_group_name              --CDP人群包名称
--     ,null                 as cdp_group_uv                 --CDP人群包总人数
--     ,t1.campaign_name      as dmdcampaignname             --营销活动名称
--     ,t2.mail_name                     as dmdmailingname   --内容标题
--     ,t1.node_id::int8            as dmdcontentid          --素材ID
--     ,t2.mail_name                     as dmdcontentname   --素材名称
--     ,t2.comment           as dmdclickurl                  --点击链接
--     ,'email'              as dmdchannel                   --触达渠道
--     ,t3.bpid             as bpid                          --会员BPid
--     ,null             as email                            --邮箱
--     ,null                 as tag                          --标签
--     ,t1.send_count         as dmdsentnumber               --推送UV
--     ,t2.submit_time        as dmdlogdate                  --推送时间
--     ,t1.reach_count        as dmdtype_sent                --送达UV
--     ,t2.reach_time         as dmdlogdate_sent             --送达时间
--     ,sum(t2.dmdtype_open) over(partition by t1.node_id)     as dmdtype_open                 --打开UV
--     ,t2.dmdlogdate_open   as dmdlogdate_open              --打开时间
--     ,sum(t2.dmdtype_click) over(partition by t1.node_id)    as dmdtype_click                 --点击链接UV
--     ,t2.dmdlogdate_click as dmdlogdate_click              --点击链接时间
--     ,t2.dmdlogdate_unsubscribe as dmdlogdate_unsubscribe  --取消订阅时间
--     ,t2.create_time        as sentdate                    --活动执行时间
--     ,t1.create_time1
--     from dwd_common t1
--     left join dwd_sub_task_mail t2
--     on  t1.task_id=t2.task_id
--     left join dws_common_id t3
--     on t2.occ_id=t3.occ_id
--     where action_type = 'EDM'
--     and t2.task_id is not null
--     ;


--微信 明细

drop table if exists dwd_sub_task_wechat_all;
create table dwd_sub_task_wechat_all as
  select
     t1.node_name
    ,t1.campaign_name
    ,t1.node_id
    ,t1.send_count
    ,t1.task_id
    ,t1.create_time1
    ,t1.action_type
    ,t2.openid
    ,t2.occ_id
    ,t2.status
    ,bi_time_add_8hour(t2.submit_time) as submit_time
    ,bi_time_add_8hour(t2.reach_time) as reach_time
    ,bi_time_add_8hour(t2.create_time) as create_time
    ,t3.title
    ,t4.content_title
    ,t4.content_url
    ,t4.article_idx
    ,t4.title as title_alternative
    ,t5.int_page_read_count
    ,t1.reach_count
    ,t2.appid
  from dwd_common t1
  left join pre_mc_action_wechatmediatasklog  t2
  on t1.id=t2.task_id 
  left join pre_mc_action_wechatmediasummary t3
  on t2.task_id  = t3.task_id
  and t2.msgdata_id = t3.msg_data_id
  --只取头条名称
  and right(t3.msg_id,1)='1'
  left join pre_prctvmkt_materiallist t4
  on t2.media_id =t4.media_id
  --拼接阅读次数行转列
  left join (select task_id ,string_agg(int_page_read_count::varchar , '，' order by msg_id) int_page_read_count
             from ( select task_id,min(msg_id) msg_id,sum(int_page_read_count) int_page_read_count
                    from pre_mc_action_wechatmediasummary 
                    group by right(msg_id,1),task_id) a
             group by task_id ) t5
  on t3.task_id =t5.task_id
  where t1.create_time1::date =current_date - INTERVAL '3 day'
  and t2.status='SUCCESS';


--微信 去重
drop table if exists dwd_sub_task_wechat;
create table dwd_sub_task_wechat as
  select
    task_id,
    create_time,
    occ_id,
    min(status) as status,
    min(reach_time) as reach_time,
    min(content_title) as content_title,
    min(title) as title,
    min(title_alternative) as title_alternative,
    min(content_url) as content_url,
    min(article_idx) as dmtarticleidx,
    min(openid) as openid, 
    min(submit_time) as submit_time, 
    min(int_page_read_count) as int_page_read_count,
    min(node_name) as node_name,
    min(campaign_name) as campaign_name,
    min(node_id) as node_id,
    min(send_count) as send_count,
    min(create_time1) as create_time1,
    min(action_type) as action_type,
    min(reach_count) as reach_count,
    min(appid) as appid
  from dwd_sub_task_wechat_all
  group by task_id,create_time,occ_id;


------------------------------------------------------------------------------
SELECT clock_timestamp() into var_app_end_time;
raise notice '-------- !!!结束 : % -- 函数: % --------执行成功 --------',var_app_end_time,var_app_name;

--返回
insert into bi_app_call_log values (var_app_name,var_app_tab_name,var_done_res,var_call_msg,var_app_start_time,var_app_end_time,var_func_desc,VAR_PERIOD_TYPE,VAR_PERIOD_VAL);
return var_done_res;
--错误处理

END;    --结束
$BODY$
LANGUAGE plpgsql VOLATILE
;


