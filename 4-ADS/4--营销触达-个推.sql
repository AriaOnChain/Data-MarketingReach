

create or replace function bi_ads_report_apppush(in_data_date date)
RETURNS pg_catalog.int4
AS
$BODY$
DECLARE

    var_app_name varchar := 'bi_ads_report_apppush';
    var_app_tab_name varchar := 'ads_report_apppush';
	  var_func_desc varchar := '营销触达报告_apppush';
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

  truncate dws_report_apppush_date;
  insert into dws_report_apppush_date select coalesce(in_data_date,CURRENT_DATE);

  insert into bi_app_call_out  select setval('ads_report_apppush_id_seq ', 1, false);

  truncate table ads_report_apppush;
  insert into ads_report_apppush
    select 
     null::int       as cdp_group_id                --CDP人群包ID
    ,cdp_group_name       as cdp_group_name              --CDP人群包名称
    ,null::int       as cdp_group_uv                --CDP人群包总人数
    ,a_pushcampaign_name       as apushcampaignname           --营销活动名称
    ,a_pushcontent_i_d       as apushcontentid              --素材ID
    ,a_pushcontent_title       as apushcontenttitle           --推送标题
    ,a_pushcontent_message       as apushcontentmessage         --推送内容
    ,a_pushclick_link       as apushclicklink              --推送链接
    ,'APPPUSH'       as apushchannel                --触达渠道
    ,bp_id       as bpid                        --会员BPid
    ,cid       as cid                         --个推ID
    ,null::int       as tag                         --标签
    ,a_pushsent_number       as apushsentnumber             --推送UV
    ,execute_time       as apushtime                   --推送时间
    ,a_pushdelivered_number       as apushdeliverednumber        --到达UV
    ,a_pushdelivered_time       as apushdeliveredtime          --到达时间
    ,click       as apushuniqueclick            --点击UV
    ,a_pushclick_date       as apushclickdate              --点击时间
    ,execute_time       as sentdate                    --活动执行时间
    ,now()       as timestamp_v                 --数据处理时间
    from  dwd_apppush
    where create_time >= (select max(data_date) from dws_report_apppush_date) - INTERVAL '10 day'
    and create_time <  (select max(data_date) from dws_report_apppush_date)
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


