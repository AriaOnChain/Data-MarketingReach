

create or replace function bi_ads_report_wechat(in_data_date date)
RETURNS pg_catalog.int4
AS
$BODY$
DECLARE

    var_app_name varchar := 'bi_ads_report_wechat';
    var_app_tab_name varchar := 'ads_report_wechat';
	  var_func_desc varchar := '营销触达报告_微信';
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

  truncate dws_report_wechat_date;
  insert into dws_report_wechat_date select coalesce(in_data_date,CURRENT_DATE);

  insert into bi_app_call_out  select setval('ads_report_wechat_id_seq ', 1, false);

  truncate table ads_report_wechat;
  insert into ads_report_wechat
    select 
    null::int               as cdp_group_id
    ,t1.node_name       as cdp_group_name
    ,null::int              as cdp_group_uv
    ,t1.campaign_name   as dmtcampaignname
    ,t1.content_title          as dmtcontenttitle
    ,t1.node_id::int8         as dmtcontentid        --素材ID
    ,case when t1.title is null then t1.title_alternative else t1.title end         as dmtcontentname      --素材名称 
    ,t1.content_url                as dmtclickurl         --点击链接
    ,t1.dmtarticleidx          as dmtarticleidx       --内容位置
    ,'wechat'::varchar          as dmtchannel          --触达渠道
    ,t3.bpid          as bpid                --会员BPid
    ,t3.unionid          as unionid             --unionid
    ,t1.openid         as openid              --openid
    ,null              as tag
    ,t1.send_count      as dmtsentnumber
    ,t1.submit_time     as dmtsentdate         --推送时间
    ,t1.reach_count               as dmtdeliverynumber
    ,t1.reach_time     as dmtdeliverytime     --送达时间
    ,t1.int_page_read_count                as dmtreadtimetotal    --公众号消息阅读次数 (粉丝+非粉丝)
    ,null::int             as dmtreadtime
    ,null::int              as dmtclick
    ,null::timestamp              as dmtclickdate
    ,t1.create_time     as sentdate            --活动执行时间
    ,t1.appid
    ,now()             as timestamp_v
    from dwd_sub_task_wechat t1
    left join dws_common_id t3
    on t1.occ_id=t3.occ_id
    where action_type = 'WECHAT_MEDIA'
    and t1.status='SUCCESS'
    and t1.create_time1 >= (select max(data_date) from dws_report_wechat_date) - INTERVAL '3 day'
    and t1.create_time1 < (select max(data_date) from dws_report_wechat_date) - INTERVAL '2 day'
    ;

delete from ads_report_wechat_his where timestamp_v::date = (select max(data_date) from dws_report_mail_date);
    insert into ads_report_wechat_his
      select
      *
      from ads_report_wechat
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


