/*Paid Search*/
/*1*/
insert into mmm.mmm_adwordssearch_2017_raw (date_id,AdGroupId, AdGroupName, site_name,exchange_name, campaign_advertiser, campaign_budget, campaign_id, campaign_name, keywordid, keyword_name, device_id, device_browser, match_type,keyword_quality_score, position, impressions, CTR, clicks, currency)
select * 
from mmm.mmm_adwordssearch_2015_raw b
where not exists (select * from mmm.mmm_adwordssearch_2017_raw a
				where a.AdGroupId = b.AdGroupId);
select count(*) from mmm.mmm_adwordssearch_2017_raw;
create table search_extracted as 
(select * from mmm.mmm_adwordssearch_2017_raw);
select * from search_extracted;
/*Update*/
create table adwordsearch_extracted
as (
select * from mmm.mmm_adwordssearch_2015_raw);


/*2*/
create table search_transformed 
as(
select b.Week, sum(a.impressions) as SearchImpressions, sum(a.clicks) as SearchClicks 
from search_extracted a
left join mmm.mmm_date_metadata b
on a.date_id = b.Day
group by b.Week);
select * from search_transformed;

create table search_campaign_transformed as
(
select b.Week,
sum(if(campaign_name like '%Always-On%',clicks,0)) as SearchAlwaysOnClick,
sum(if(campaign_name in ('Landing Page','Retargeting'),clicks ,0)) as SearchWebsiteClick,
sum(if(campaign_name like'%Branding%',clicks,0)) as SearchBrandingClick
from search_extracted a
left join mmm.mmm_date_metadata b
on a.date_id = b.Day
group by b.Week
);
select * from search_campaign_transformed;

/*Facebook*/
/*1*/
create table facebook_extracted as
(select * from mmm.mmm_facebook_raw);

/*2*/
create table facebook_transformed as
(
select ap_total_imps as FacebookImpressions, ap_total_clicks as FacebookClicks, round(ap_total_clicks/ap_total_imps,2) as FacebookCTR
from facebook_extracted
where ap_total_imps !=0
);
/*update2*/
select 
Period,
sum(ap_total_imps) as FacebookImpressions, 
sum(ap_total_clicks) as FacebookClicks,
sum(ap_total_clicks)/sum(ap_total_imps)  as CTR
from mmm.mmm_facebook_raw
group by Period
;

/*update 2*/
CREATE TABLE facebook_transform
(
SELECT b.`week`, SUM(ap_total_imps) AS FacebookImpressions,
       SUM(ap_total_clicks) AS FacebookClicks,
       ROUND(SUM(ap_total_clicks)/SUM(IF(ap_total_imps = 0, 1, ap_total_imps)),3) AS FacebookCTR
FROM mmm_facebook_raw a
LEFT JOIN mmm_date_metadata b ON a.period = b.`Day`
GROUP BY 1
);


/*3*/
create table fb_campaign_transformed as
(
select b.Week,
sum(if(`Campaign Objective` like '%Branding%',ap_total_imps,0)) as FBBrandingImpression,
sum(if(`Campaign Objective` like '%Holiday%',ap_total_imps,0)) as FBHolidayImpression,
sum(if(`Campaign Objective` in('%Other%','July 4th','New Product Launch','Pride'),ap_total_imps,0)) as FBOtherImpression 
from facebook_extracted a
left join mmm.mmm_date_metadata b
on a.Period = b.Day
group by b.Week
);
select * from fb_campaign_transformed;

/*Wechat*/
/*1*/
create table wechat_extracted as 
(select * from mmm_wechat_raw);
select * from wechat_extracted;

/*2*/
create table wechat_transformed as (
select b.Week,Campaign,sum(`Article Total Read`+`Account Total Read`+`Moments Total Read`) as WechatTotalRead 
from wechat_extracted a
left join mmm.mmm_date_metadata b
on a.Period = b.Day
group by b.Week,Campaign
);
select * from wechat_transformed;

/*3*/
create table WechatNewLaunchRead as
(
select Campaign,WechatTotalRead
from wechat_transformed
where Campaign = 'New Product Launch'
);
select * from WechatNewLaunchRead;

/*Final Stack*/
create view MMM_Stack 
as(
select m.Week,
m.Month,
t1.`National TV GRP` as `National TV GRPs`,
t1.`Magazine GRP`as `Magazine GRPs`,
t2.`SearchImpressions`as `Paid Search`,
t3.display_impression as Display,
t4.FBBrandingImpression as `Facebook Impressions`,
t5.WechatTotalRead as Wechat,
t6.`Sales event` as `Sales Event`,
t7.`Comp Spend` as `Comp Media Spend`,
t8.Sales as Sales,
t3.display_always_on_impression as DisplayAlwaysOnImpression,
t3.display_branding_impression as DisplayBrandingImpression,
t3.display_website_impression as DisplayWebsiteImpression,
t3.display_holiday_impression as DisplayHolidayImpression,
t9.SearchBrandingClick as SearchBrandingclicks,
t9.SearchAlwaysOnClick as SearchAlwasyOnclicks,
t9.SearchWebsiteClick as SearchWebsiteclicks,
t4.FBBrandingImpression as FacebookBrandingImpressions,
t4.FBHolidayImpression as FacebookHolidayImpressions,
t4.FBOtherImpression as FacebookOtherImpressions
FROM (SELECT DISTINCT `Week`,`Month` FROM mmm.mmm_date_metadata) m
left join `mmm`.`mmm_offline_transformed` t1 on t1.Date = m.Week
left join `mmm`.`search_transformed` t2 on t2.Week = m.Week
left join `mmm`.`mmm_dcmdisplay_transformed` t3 on t3.Date = m.Week
left join `mmm`.`fb_campaign_transformed` t4 on t4.Week = m.Week
left join `mmm`.`wechat_transformed` t5 on t5.Week = m.Week
left join `mmm`.`mmm_event_transformed` t6 on t6.week = m.Week
left join `mmm`.`mmm_comp_media_transformed` t7 on t7.Week = m.Week
left join `mmm`.`mmm_sales_transformed` t8 on t8.Week = m.Week
left join `mmm`.`search_campaign_transformed` t9 on t9.Week = m.Week
);

select * from MMM_Stack;




