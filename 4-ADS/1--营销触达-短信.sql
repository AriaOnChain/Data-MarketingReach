

create or replace function bi_ads_report_sms(in_data_date date)
RETURNS pg_catalog.int4
AS
$BODY$
DECLARE

    var_app_name varchar := 'bi_ads_report_sms';
    var_app_tab_name varchar := 'ads_report_sms';
	  var_func_desc varchar := '营销触达报告_短信';
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

  truncate dws_report_sms_date;
  insert into dws_report_sms_date select coalesce(in_data_date,CURRENT_DATE);
  insert into bi_app_call_out  select setval('ads_report_sms_id_seq ', 1, false);

  truncate table ads_report_sms;
  insert into ads_report_sms
    select 
      null::int as cdp_group_id                               --CDP人群包ID
      ,t1.node_name as cdp_group_name                    --CDP人群包名称
      ,null::int as cdp_group_uv                              --CDP人群包总人数
      ,t1.campaign_name as smscampaignname               --营销活动名称
      ,t1.node_id::int8 as smscontentid                  --素材ID
      ,t2.content as smscontentname 
      -- ,left(t2.content,POSITION('http' in t2.content)-1)||coalesce(t2.external_url,'')   as smscontentname        --素材名称
      -- ,case when t2.click_time is not null then t2.external_url 
      --  end as smslink                                    --点击链接
      ,t2.external_url as smslink  
      ,'sms' as smschannel                               --触达渠道
      ,case when t3.bpid is not null then t3.bpid 
      else t4.bpid end as bpid                                   --会员BPid
      ,null as phone                                     --会员手机号
      ,null as tag                                       --标签
      ,t1.send_count as smssentnumber                    --推送UV
      ,t2.submit_time as smstime                         --推送时间
      ,t2.delivery_status as smsdeliverstatus_delivrd    --送达状态
      ,case when t2.delivery_status = 'SUCCESS' then t2.reach_time 
       end as smsdeliveredtime                           --送达时间
     -- ,case when t2.click_count > 0 then 1 
      --           else 0 
      -- end as smsuniqueclick                             --点击链接UV 需求变动
      ,t2.click_count as smsuniqueclick                  --点击链接UV
      ,t2.click_time  as smsclickdate                    --点击链接时间
      ,t2.create_time as sentdate                        --活动执行时间
      ,now() as timestamp_v 
    from dwd_common t1
    left join dwd_sub_task_sms t2
    on t1.task_id=t2.task_id
    --left join pre_prctvmkt_member t4
    --on  t2.mobile=t4.mobile
    --and t2.occ_id=t4.occ_id
    -- left join dwd_common_binding_id t3
    -- on t2.occ_id=t3.occ_id
    -- and t2.mobile=t3.mobile
    left join dws_common_id t3
    on t2.occ_id=t3.occ_id
    left join dwd_bpid_patch2 t4
    on t2.occ_id = t4.occ_id
    where action_type = 'SMS' 
    --过滤异常任务
    --and t2.task_id is not null
    --排除测试数据
    and t2.status ='SUCCESS'
    and t1.create_time1 >= (select max(data_date) from dws_report_sms_date) - INTERVAL '10 day'
    and t1.create_time1 < (select max(data_date) from dws_report_sms_date)
    ;




delete from ads_report_sms_his where timestamp_v::date = (select max(data_date) from dws_report_sms_date);
insert into ads_report_sms_his
select
*
from ads_report_sms
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


