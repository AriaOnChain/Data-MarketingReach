

create or replace function bi_ads_report_mail(in_data_date date)
RETURNS pg_catalog.int4
AS
$BODY$
DECLARE

    var_app_name varchar := 'bi_ads_report_mail';
    var_app_tab_name varchar := 'ads_report_mail';
	  var_func_desc varchar := '营销触达报告_邮件';
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

  truncate dws_report_mail_date;
  insert into dws_report_mail_date select coalesce(in_data_date,CURRENT_DATE);

  insert into bi_app_call_out  select setval('ads_report_mail_id_seq ', 1, false);

  truncate table ads_report_mail;
  insert into ads_report_mail
    
    select 
    null::int                  as cdp_group_id                 --CDP人群包ID
    ,t1.node_name          as cdp_group_name              --CDP人群包名称
    ,null::int                 as cdp_group_uv                 --CDP人群包总人数
    ,t1.campaign_name      as dmdcampaignname             --营销活动名称
    ,t2.mail_name                     as dmdmailingname   --内容标题
    ,t1.node_id::int8            as dmdcontentid          --素材ID
    ,t2.mail_name                     as dmdcontentname   --素材名称
    -- ,replace(replace(replace(replace(replace(replace(replace(t2.comment,'{nodeId}',t1.node_id),
    -- '{processId}',t1.process_id),'{campaignId}',t1.campaign_id),
    -- '{actualActionTime}',t1.actual_actiontime::varchar),'{campaignName}',
    -- t1.campaign_name),'{nodeName}',t1.node_name),'{brandId}',t1.brand_id) as dmdclickurl                  --点击链接

    ,replace(replace(replace(replace(replace(replace(replace(
      replace(replace(replace(replace(replace(replace(replace(
      t2.comment,'{nodeId}',t1.node_id),'{processId}',t1.process_id),'{campaignId}',t1.campaign_id),
    '{actualActionTime}',t1.actual_actiontime::varchar),'{campaignName}',
    t1.campaign_name),'{nodeName}',t1.node_name),'{brandId}',t1.brand_id),
    '{{{anodeId}}}',t1.node_id),'{{{aprocessId}}}',t1.process_id),'{{{acampaignId}}}',t1.campaign_id),
    '{{{aactualActionTime}}}',t1.actual_actiontime::varchar),'{{{acampaignName}}}',
    t1.campaign_name),'{{{anodeName}}}',t1.node_name),'{{{abrandId}}}',t1.brand_id) as dmdclickurl    

    ,'email'              as dmdchannel                   --触达渠道
    ,case when t3.bpid is not null then t3.bpid 
      else t4.bpid end as bpid                           --会员BPid
    ,null             as email                            --邮箱
    ,null                 as tag                          --标签
    ,t1.send_count         as dmdsentnumber               --推送UV
    ,t2.submit_time        as dmdlogdate                  --推送时间
    ,t1.reach_count        as dmdtype_sent                --送达UV
    -- ,t2.reach_time         as dmdlogdate_sent             --送达时间
    ,case when t2.send_time is null then 
     case when t2.dmdlogdate_open is not null then t2.reach_time else null end
     else t2.send_time end as dmdlogdate_sent
   -- ,case when dmdtype_open >0 then 1 else 0 end      as dmdtype_open                 --打开UV  需求变动
    ,t2.dmdtype_open                                         --打开UV
    ,t2.dmdlogdate_open   as dmdlogdate_open              --打开时间
   -- ,case when dmdtype_click >0 then 1 else 0 end    as dmdtype_click                 --点击链接UV  需求变动
    ,t2.dmdtype_click                                         --点击链接UV 
    ,t2.dmdlogdate_click as dmdlogdate_click              --点击链接时间
    ,t2.dmdlogdate_unsubscribe as dmdlogdate_unsubscribe  --取消订阅时间
    ,t2.create_time        as sentdate                    --活动执行时间
    ,now() as timestamp_v
    from dwd_common t1
    left join dwd_sub_task_mail t2
    on  t1.task_id=t2.task_id

    -- left join pre_prctvmkt_member t4
    -- on  t2.email=t4.email
   -- and t2.occ_id=t4.occ_id

    -- left join dwd_common_binding_id t3
    -- on t2.occ_id=t3.occ_id
    -- and t2.email = t3.email
    left join dws_common_id t3
    on t2.occ_id=t3.occ_id
    left join dwd_bpid_patch2 t4
    on t2.occ_id = t4.occ_id
    where action_type = 'EDM'
    --and t2.task_id is not null
    and t2.status ='SUCCESS'
    and create_time1 >= (select max(data_date) from dws_report_mail_date) - INTERVAL '10 day'
    and create_time1 <  (select max(data_date) from dws_report_mail_date)
    ;




    delete from ads_report_mail_his where timestamp_v::date = (select max(data_date) from dws_report_mail_date);
    insert into ads_report_mail_his
      select
      *
      from ads_report_mail
      ;
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


