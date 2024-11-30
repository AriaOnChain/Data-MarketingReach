truncate table ads_reach_report_monitoring;
insert into ads_reach_report_monitoring
select 
 'ads_report_wechat'
,'3'
,sum(case when cdp_group_name is null then 1 else 0 end)  
,sum(case when dmtcampaignname is null then 1 else 0 end)
,sum(case when dmtcontentid is null then 1 else 0 end) 
,sum(case when dmtcontenttitle is null then 1 else 0 end) 
,sum(case when dmtchannel is null then 1 else 0 end) 
,sum(case when dmtcontentname is null then 1 else 0 end) 
,0 
,sum(case when dmtsentnumber is null then 1 else 0 end) 
,sum(case when dmtsentdate is null then 1 else 0 end) 
,sum(case when dmtdeliverynumber is null then 1 else 0 end)
,sum(case when dmtdeliverytime is null then 1 else 0 end) 
,sum(case when dmtreadtimetotal is null then 1 else 0 end) 
,sum(case when unionid is null then 1 else 0 end) 
,sum(case when openid is null then 1 else 0 end) 
,0
 from ads_report_wechat ;

insert into ads_reach_report_monitoring
select 
'ads_report_sms'
,'1'
,sum(case when cdp_group_name is null then 1 else 0 end) 
,sum(case when smscampaignname is null then 1 else 0 end)
,sum(case when smscontentid is null then 1 else 0 end) 
,0
,sum(case when smschannel is null then 1 else 0 end) 
,sum(case when smscontentname is null then 1 else 0 end)
,sum(case when bpid is null then 1 else 0 end) 
,sum(case when smssentnumber is null then 1 else 0 end) 
,sum(case when smstime is null then 1 else 0 end) 
,sum(case when smssentnumber is null then 1 else 0 end) 
,0
,0
,0
,0
,0
 from ads_report_sms ;

insert into ads_reach_report_monitoring

select 
'ads_report_mail'
,'2'
,sum(case when cdp_group_name is null then 1 else 0 end) 
,sum(case when dmdcampaignname is null then 1 else 0 end) campaignNameNum
,sum(case when dmdcontentid is null then 1 else 0 end) contentIDNum
,sum(case when dmdmailingname is null then 1 else 0 end) contentTitleNum
,sum(case when dmdchannel is null then 1 else 0 end) channelNum
,sum(case when dmdcontentname is null then 1 else 0 end) contentNameNum
,sum(case when bpid is null then 1 else 0 end) bpidNum
,sum(case when dmdsentnumber is null then 1 else 0 end) sentNumber
,sum(case when dmdlogdate is null then 1 else 0 end) sentTime
,sum(case when dmdtype_sent is null then 1 else 0 end) deliveryNumber
,sum(case when dmdlogdate_sent is null then 1 else 0 end) deliveryTime
,0
,0
,0
,0
from ads_report_mail ;

insert into ads_reach_report_monitoring

select 
'ads_report_apppush'
,'4' 
,sum(case when cdp_group_name is null then 1 else 0 end) CDP_group_name_num
,sum(case when apushcampaignname is null then 1 else 0 end) campaignNameNum
,sum(case when apushcontentid is null then 1 else 0 end) contentIDNum
,sum(case when apushcontenttitle is null then 1 else 0 end) contentTitleNum
,sum(case when apushchannel is null then 1 else 0 end) channelNum
,sum(case when apushcontenttitle is null then 1 else 0 end) contentNameNum
,0
,sum(case when apushsentnumber is null then 1 else 0 end) sentNumber
,sum(case when apushtime is null then 1 else 0 end) sentTime
,0
,0
,0 
,0 
,0 
,sum(case when cid is null then 1 else 0 end)
from ads_report_apppush ;