/* SQL - Sequential Query Language */
/* ETL - Extract, Transform, Load */

SELECT * FROM mmm.test;

SELECT Bootcamp FROM mmm.test;

DROP TABLE mmm.test;

/*Create Table*/
CREATE TABLE mmm.test
(
MarTechApe INT,
MMM INT,
Bootcamp TEXT,
`Data Processing` TEXT
);

INSERT INTO mmm.test
VALUES
(666,666,666,666)
,(777,777,777,777)
,(888,888,888,888)
;

/*where*/
SELECT MarTechApe,`Data Processing`
FROM mmm.test
WHERE MarTechApe = 888;

SELECT * FROM mmm.test;

/*Update*/
Update mmm.test
SET MarTechApe = 888
WHERE MarTechApe = 777;

/*DELETE*/
DELETE FROM mmm.test
WHERE MarTechApe = 888 AND mmm = 777;

/* CREATE A NEW TABLE FROM mmm.test*/
CREATE TABLE mmm.test2
SELECT * FROM mmm.test
WHERE MarTechApe =888;

SELECT * FROM mmm.test;
SELECT * FROM mmm.test2;

/*UNION vs. UNION ALL*/
SELECT * FROM mmm.test
UNION ALL
SELECT * FROM mmm.test2;

SELECT * FROM mmm.test
UNION
SELECT * FROM mmm.test2;

/*Add Column*/
Alter TABLE mmm.test2
ADD COLUMN `NAME` TEXT;

SELECT 1+2;

SELECT 1+ NULL;

Update mmm.test2
SET `Name` = 'BOSS';

Alter TABLE mmm.test2
ADD COLUMN `NAME2` TEXT,
ADD COLUMN `NAME3` TEXT;

ALTER TABLE mmm.test2
DROP COLUMN `NAME2`,
DROP COLUMN `NAME3`;

/*Join*/
SELECT a.*
,b.`Name`
FROM mmm.test AS a
INNER JOIN mmm.test2 AS b
ON a.MarTechApe = b.MarTechApe;

SELECT a.*
,b.`Name`
FROM mmm.test AS a
Left JOIN mmm.test2 AS b
ON a.MarTechApe = b.MarTechApe;

SELECT a.*
,b.`Name`
FROM mmm.test AS a
RIGHT JOIN mmm.test2 AS b
ON a.MarTechApe = b.MarTechApe;

/* UNION  on same # of columns, beware of column order */
SELECT * FROM mmm.test
UNION
SELECT * FROM mmm.test2;


SELECT Bootcamp from MMM.TEST
union
select `NAME` from MMM.TEST2;

/*Aggregation*/
SELECT * FROM mmm.testgroupby;

/*Total sales for each region*/
SELECT Region, sum(sales)
FROM mmm.testgroupby
group by Region;

/*Average sale by month*/
SELECT `MONTH`, AVG(SALES)
FROM mmm.testgroupby
Group by `month`;

/*Pivot vs. Unpivot*/
/*Pivot*/
CREATE TABLE mmm.pivot
SELECT
`Month`
,SUM(IF(Region = 'EAST',SALES,NULL)) AS EASTSALES
,SUM(IF(Region = 'SOUTH', SALES, NULL)) AS SouthSALES
,SUM(IF(Region = 'WEST', SALES, NULL)) AS WESTSALES
,SUM(IF(Region = 'NORTH', SALES, NULL)) AS NORTHSALES
From MMM.TESTGROUPBY
GROUP BY `Month`;

SELECT * FROM mmm.pivot;

/*Unpivot*/
CREATE TABLE mmm.unpivot
SELECT `Month`, 'EAST' AS `Region`, `EASTSALES` as Sales FROM mmm.pivot
UNION ALL
SELECT `Month`, 'South' AS `Region`, `SouthSALES` as Sales FROM mmm.pivot
UNION ALL
SELECT `Month`, 'West' AS `Region`, `WESTSALES` as Sales FROM mmm.pivot
UNION ALL
SELECT `Month`, 'North' AS `Region`, `NORTHSALES` as Sales FROM mmm.pivot
;

select * FROM mmm.unpivot;

select * FROM mmm.unpivot
ORDER BY Month;

select * FROM mmm.unpivot
ORDER BY Month DESC;

/*MMM Data - Sales */
select * from MMM.MMM_SALES_RAW;

Select * from MMM.MMM_DATE_METADATA;

CREATE TABLE mmm.mmm_sales_transformed
(SELECT
b.`week`
,sum(a.sales) AS Sales
FROM mmm.mmm_sales_raw a
LEFT JOIN mmm.mmm_date_metadata b
ON a.`Order Date` = b.`Day`
GROUP BY b.`Week`
);

Select * from mmm.mmm_sales_transformed;

/*QA*/
SELECT SUM(SALES) FROM mmm.mmm_sales_raw;
SELECT SUM(SALES) FROM mmm.mmm_sales_transformed;

/*HW MMM Comp Spend*/
SELECT * FROM mmm.mmm_comp_media_raw;

/*Check if all week is in Date Metadata*/
SELECT *
FROM mmm.mmm_comp_media_raw a
LEFT JOIN mmm.mmm_date_metadata b
ON a.`Week` =b.`Week`
WHERE b.`Week` IS NULL
;

/*Create mmm._comp_media_transformed*/
CREATE TABLE mmm.mmm_comp_media_transformed
(
SELECT 
`Week`
,ROUND(SUM(`Competitive Media Spend`),2) AS `Comp Spend`
FROM mmm.mmm_comp_media_raw
Group By `Week`
);

SELECT * FROM mmm.mmm_comp_media_transformed;

/*HW mmm Events*/
SELECT * FROM mmm.mmm_event_raw;

Create table mmm.mmm_event_transformed
(
SELECT 
b.`week`
,IFNULL(AVG(a.`Sales Event`),0) as `Sales event`
FROM mmm.mmm_event_raw a
RIGHT JOIN mmm.mmm_date_metadata b
on a.`day` =b.`day`
group by b.`week`)
;

select * from mmm.mmm_event_transformed;

/*HW MMM econ*/
SELECT * FROM mmm.mmm_econ_raw;

Create table mmm.mmm_econ_transformed
(
select 
B.`WEEK`
,round(AVG(A.`VALUE`),1) AS `Unemployment rate`
FROM mmm.mmm_econ_raw a
LEFT JOIN mmm.mmm_date_metadata b
ON a.`month` = b.`month`
Group by b.`week`
)
;

select * from  mmm.mmm_econ_transformed;

/*HW MMM SALES SQL*/
/*ALL weeks that total sales are greater than 250000*/
SELECT *
FROM mmm.mmm_sales_transformed
where sales >= 250000;

/*all the week number that sales have increased from the week before */
select *
from mmm.mmm_sales_transformed a
left join mmm.mmm_sales_transformed b
on a.`week` = Date_add(b.`week`, interval 7 day)
where a.sales > b.sales
;

/*quarter of each year that has highest sales*/

CREATE TABLE mmm.quarterly_sales
(
SELECT
YEAR(a.`order date`) as `year`
, Quarter(a.`order date`) as `quarter`
, round(sum(a.`sales`),2) as `quarterlysales`
from mmm.mmm_sales_raw a
group by 
YEAR(a.`order date`)
, Quarter(a.`order date`)
)
;

select * from mmm.quarterly_sales;

select
`year`
,MAX(quarterlysales) as maxquarter
from mmm.quarterly_sales
group by `year`;

SELECT
a.`year`
,a.`quarter`
,a.quarterlysales
from mmm.quarterly_sales a
inner join
(
select
`year`
,MAX(quarterlysales) as maxquarter
from mmm.quarterly_sales
group by `year`
) b
on a.`year` = b.`year` and a.`quarterlysales` =b.`maxquarter`
;

/* MMM OFFLINE*/
SELECT * FROM mmm.mmm_offline_raw;
select * from mmm.mmm_dma_hh;

CREATE TABLE mmm.mmm_offline_transformed
(
SELECT
`Date`
,ROUND(SUM(a.`TV GRP`/100*B.`TOTAL HH`)/SUM(b.`TOTAL HH`)*100,1) AS `National TV GRP`
,ROUND(SUM(a.`Magazine GRP`/100*B.`TOTAL HH`)/SUM(b.`TOTAL HH`)*100,1) AS `Magazine GRP`
FROM mmm.mmm_offline_raw a
LEFT JOIN mmm.mmm_dma_hh b
ON a.`DMA` =b.`DMA NAME`
GROUP BY `Date`
)
;

select * from mmm.mmm_offline_transformed;

/*MMM DCM/GCM*/
SELECT * FROM mmm.mmm_dcmdisplay_2015_raw;

Select count(`date`) from mmm.mmm_dcmdisplay_2015_raw;

select distinct `campaign name` from mmm.mmm_dcmdisplay_2015_raw;

create table mmm.mmm_dcmdisplay_transformed
(
SELECT
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER)) as  displayimpressions
,SUM(IF(`campaign name` like '%always-on%', CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as `displayalwaysonimpressions`
,SUM(IF(`campaign name` like '%website%', CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as `displaywebsiteimpressions`
,SUM(IF(`campaign name` IN('branding campaign','new product launch'), CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as displaybrandingimpressions
,SUM(IF(`campaign name` IN('holiday','july 4th'), CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as displayholidayimpressions
FROM mmm.mmm_dcmdisplay_2015_raw
group by `date`
)
;

SELECT *
FROM mmm.mmm_dcmdisplay_transformed
WHERE DisplayImpressions <> DisplayAlwaysOnimpressions +DisplayWebsiteImpressions + DisplayBrandingImpressions + DisplayHolidayImpressions;

/*DCM delete and update */
SELECT * from mmm.mmm_dcmdisplay_2017_raw;

CREATE Temporary table mmm.display_temp
(
SELECT
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER)) as  displayimpressions
,SUM(IF(`campaign name` like '%always-on%', CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as `displayalwaysonimpressions`
,SUM(IF(`campaign name` like '%website%', CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as `displaywebsiteimpressions`
,SUM(IF(`campaign name` IN('branding campaign','new product launch'), CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as displaybrandingimpressions
,SUM(IF(`campaign name` IN('holiday','july 4th'), CONVERT(REPLACE(`Served Impressions`,',',''),SIGNED INTEGER),0)) as displayholidayimpressions
FROM mmm.mmm_dcmdisplay_2017_raw
group by `date`
);


SELECT
A.`Date`
from MMM.MMM_dcmdisplay_transformed a
inner join mmm.display_temp b
on a.`date` = b.`date`
;

USE mmm;
DELETE a
from MMM.MMM_dcmdisplay_transformed a
inner join mmm.display_temp b
on a.`date` = b.`date`
;

INSERT INTO mmm.mmm_dcmdisplay_transformed
select * from mmm.display_temp;

SELECT * from mmm.mmm_dcmdisplay_transformed;

/*AF - Analytic files */

CREATE VIEW mmm.af
AS
SELECT 
m.`Week`,
m.`Month`,
t1.Sales,
t2. `Sales Event` AS `Sales Event`,
t3.`Unemployment Rate` AS`Unemployment Rate`,
t5.`National TV GRP`,
t5.`Magazine GRP`,
t6.`DisplayImpressions` AS `Display`
FROM (SELECT DISTINCT `Week`,`Month` FROM mmm.mmm_date_metadata) m
LEFT JOIN `mmm`.`mmm_sales_transformed` t1 ON m.`Week` = t1.`Week`
LEFT JOIN `mmm`.`mmm_event_transformed` t2 ON m.`Week` = t2.`Week`
LEFT JOIN `mmm`.`mmm_econ_transformed` t3 ON m.`Week` = t3.`Week`
LEFT JOIN `mmm`.`mmm_offline_transformed` t5 ON m.`Week` = t5.`Date`
LEFT JOIN `mmm`.`mmm_dcmdisplay_transformed` t6 ON m.`Week` = t6.`Date`
;

select * from mmm.af;



/*HW MMM SEARCH */

SELECT * FROM mmm.mmm_adwordssearch_2015_raw;

create table MMM.MMM_ADWORDSSEARCH_EXTRACTED
(
SELECT * FROM mmm.mmm_adwordssearch_2015_raw
);

select distinct a.date_id
from  mmm.mmm_adwordssearch_EXTRACTED A
INNER JOIN  mmm.mmm_adwordssearch_2017_raw b
ON a.date_id = b.date_id;

USE MMM;
DELETE a
from  mmm.mmm_adwordssearch_EXTRACTED A
INNER JOIN  mmm.mmm_adwordssearch_2017_raw b
ON a.date_id = b.date_id;

INSERT INTO mmm.mmm_adwordssearch_EXTRACTED
SELECT * FROM mmm.mmm_adwordssearch_2017_raw;

CREATE TABLE mmm.mmm_adwordssearch_transformed
(
SELECT 
date_id
,sum(impressions) as searchimpressions
,sum(clicks) as searchclicks
,sum(IF(Campaign_name IN ('Always-on','Mobile Always-on'), clicks, 0)) as searchalwaysonclicks
,SUM(IF(campaign_name IN ('Landing Page','Retargeting'),clicks,0)) AS SearchWebsiteClick
,SUM(IF(campaign_name IN ('Branding Campaign','New Product Launch'),clicks,0)) AS SearchBrandingClick
FROM mmm.mmm_adwordssearch_extracted
Group by date_id
);

select * from mmm.mmm_adwordssearch_transformed;

/*HW MMM Facebook*/
Select * from mmm.mmm_facebook_raw;

Create table mmm.mmm_facebook_transformed
(
select 
period
,sum(ap_total_imps) as FacebookImpressions
,sum(ap_total_clicks) as FacebookClicks
,sum(ap_total_clicks)/sum(ap_total_imps) as CTR
,sum(if(`Campaign Objective` IN ('July 4th','Holiday'),ap_total_imps,0)) as Facebookholidayimpression
FROM mmm.mmm_facebook_raw
group by period
);

/*Option2: check if impressions =0*/
CREATE TABLE facebook_transform
(SELECT b.`week`, SUM(ap_total_imps) AS FacebookImpressions,
       SUM(ap_total_clicks) AS FacebookClicks,
       ROUND(SUM(ap_total_clicks)/SUM(IF(ap_total_imps = 0, 1, ap_total_imps)),3) AS FacebookCTR
FROM facebook a
LEFT JOIN mmm_date_metadata b ON a.period = b.`Day`
GROUP BY 1);

/*MMM Data -Wechat */
SELECT * FROM mmm.mmm_wechat_raw;

create table mmm.mmm_wechat_transformed
(
SELECT 
period
,SUM(`article total read`+`Account total read`+`moments total read`) as wechattotalread
,Sum(if(Campaign = 'New Product Launch', `Article Total Read` +`Account Total Read` + `Moments Total Read`,0)) As WechatNewLaunchRead
from mmm.mmm_wechat_raw
group by period
);


/*HW: MMM Final Stack*/
use MMM;
CREATE VIEW mmm.mmm_stack
AS
SELECT 
m.`Week` AS `Period`,
m.`Month`,
t1.Sales,
t2. `Sales Event` AS `Sales Event`,
t3.`Unemployment Rate` AS`Unemployment Rate`,
t5.`National TV GRP`,
t5.`Magazine GRP`,
t6.`DisplayImpressions` AS `Display`,
t7.`SearchClicks` AS `SearchClick`,
t8.`FacebookImpressions` AS `FacebookImpressions`,
t9.`WechatTotalRead` AS `Wechat`
FROM (SELECT DISTINCT `Week`,`Month` FROM mmm.mmm_date_metadata) m
LEFT JOIN `mmm`.`mmm_sales_transformed` t1 ON m.`Week` = t1.`Week`
LEFT JOIN `mmm`.`mmm_event_transformed` t2 ON m.`Week` = t2.`Week`
LEFT JOIN `mmm`.`mmm_econ_transformed` t3 ON m.`Week` = t3.`Week`
LEFT JOIN `mmm`.`mmm_offline_transformed` t5 ON m.`Week` = t5.`Date`
LEFT JOIN `mmm`.`mmm_dcmdisplay_transformed` t6 ON m.`Week` = t6.`Date`
LEFT JOIN `mmm`.`mmm_adwordssearch_transformed` t7 ON m.`Week` = t7.`date_id`
LEFT JOIN `mmm`.`mmm_facebook_transformed` t8 ON m.`Week` = t8.`period`
LEFT JOIN `mmm`.`mmm_wechat_transformed` t9 ON m.`Week` = t9.`Period`
;

select * from mmm.mmm_stack;

