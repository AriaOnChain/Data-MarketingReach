

create or replace function bi_dwd_report_apppush()
returns pg_catalog.int4
as
$body$
declare

    var_app_name varchar := 'bi_dwd_report_apppush';
    var_app_tab_name varchar := 'dwd_report_apppush';
	  var_func_desc varchar := 'dwd营销触达-个推';
    var_app_start_time timestamp  ;
    var_app_end_time timestamp  ;
    sqlstate varchar := 0;
    sqlerrm varchar := '';
    var_call_msg text := '成功';
    var_done_res int := 1;
    var_fail_res int := -1;
    var_period_type varchar := '';
    var_period_val varchar := '';
    row record;
begin

select clock_timestamp() into var_app_start_time;

raise notice '-------- !!!开始 : % -- 函数: % --------',var_app_start_time,var_app_name;
------------------------------------------------------------------------------

drop table if exists dwd_apppush;
create table dwd_apppush as
  select 
      t1.cdp_group_name
     ,t1.a_pushcampaign_name
     ,t1.a_pushcontent_i_d
     ,t1.a_pushcontent_title
     ,t1.a_pushcontent_message
     ,t1.a_pushclick_link
     ,t4.bp_id
     ,t2.cid
     ,t3.a_pushsent_number
     ,bi_time_add_8hour(t1.execute_time) execute_time
     ,count(t2.delivery)over(partition by t2.apptaskid) a_pushdelivered_number
     ,t2.a_pushdelivered_time
     ,t2.click
     ,t2.a_pushclick_date
     ,bi_time_add_8hour(t1.create_time) create_time
  from pre_apppush_incidencerel t1
  left join pre_apppush_returnmsg t2
  on t1.app_push_task_id=t2.apptaskid
  left join (select task_id,count(task_id) a_pushsent_number 
  from pre_campaign_action_output
  group by task_id) t3
  on t1.task_id=t3.task_id
  left join pre_prctvmkt_member t4
  on t2.cid=t4.cid
;




------------------------------------------------------------------------------
select clock_timestamp() into var_app_end_time;
raise notice '-------- !!!结束 : % -- 函数: % --------执行成功 --------',var_app_end_time,var_app_name;

--返回
insert into bi_app_call_log values (var_app_name,var_app_tab_name,var_done_res,var_call_msg,var_app_start_time,var_app_end_time,var_func_desc,var_period_type,var_period_val);
return var_done_res;
--错误处理

end;    --结束
$body$
language plpgsql volatile
;


