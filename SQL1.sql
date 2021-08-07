/*Q1 The number of competitor spend*/
create table mmm.mmm_comp_transformed
(
select date_format(b.Week,'%m/%d/%Y'),
round(sum(`Competitive Media Spend`),2) as Total_Competitor_Spend_by_week
from mmm.mmm_comp_media_spend a
left join mmm.mmm_date_metadata b
on a.Week = b.Week
group by a.Week);

select * from mmm_comp_transformed;


/*Q2 Data-Events*/
with sales as (
select date_format(b.Week,'%m/%d/%y')as Week, a.`Sales Event` as Weekly_Sales,
count(a.`Sales Event`) Number_of_Event
from  mmm.mmm_event a
right join mmm.mmm_date_metadata b
on a.Day = b.Day
group by b.Week,a.`Sales Event`)
select Week, 
case when Weekly_Sales is null then '0' 
else '1' 
end as Event_status
from sales;

with sales as (
select date_format(b.Week,'%m/%d/%y')as Week, a.`Sales Event` as Weekly_Sales,
count(a.`Sales Event`) Number_of_Event
from  mmm.mmm_event a
right join mmm.mmm_date_metadata b
on a.Day = b.Day
group by b.Week,a.`Sales Event`)
select Week, ifnull(Weekly_Sales,0) as Event_Status
from sales;

/*update Q2*/
create table mmm.mmm_event_transformed
(
select date_format(b.Week,'%m/%d/%y')as Week, ifnull(avg(a.`Sales Event`),0) as `Sales Event`
from  mmm.mmm_event a
right join mmm.mmm_date_metadata b
on a.Day = b.Day
group by b.Week,a.`Sales Event`);

/*Q3 Mircoreconomics*/
create table mmm_econ_transformed
(select date_format(a.Time,'%u/%m/%d/%y') as Week_Of_Whole_Year, a.Value,count(a.Value)
from mmm.dp_live_cci a
left join mmm.mmm_date_metadata b
on a.Time = b.Month
group by b.Week,a.Time,a.Value);

select * from mmm_econ_transformed;

/*update Q3*/
create table mmm_econ_transformed
(select date_format(b.Week,'%u/%m/%d/%y') as Week, round(avg(a.Value),2) as `Unemployment Rate`
from mmm.mmm_econ a
left join mmm.mmm_date_metadata b
on a.Month = b.Month
group by b.Week,a.Month,a.Value);

select * from mmm_econ_transformed;


/*Q4 SQL-Calculated weekly sales*/
select date_format(b.Week,'%m/%d/%y'),round(sum(Sales),2)as Sales
from mmm.mmm_sales_raw_nofrench a
left join mmm.mmm_date_metadata b
on a.`Order Date` = b.Day
group by b.Week;

create table mmm_sales_tranformed
(select date_format(b.Week,'%m/%d/%y')Week,round(sum(Sales),2)as Sales
from mmm.mmm_sales_raw_nofrench a
left join mmm.mmm_date_metadata b
on a.`Order Date` = b.Day
group by b.Week);

CREATE TABLE mmm.mmm_sales_transformed
(SELECT
b.`week`
,sum(a.sales) AS Sales
FROM mmm.mmm_sales_raw_nofrench a
LEFT JOIN mmm.mmm_date_metadata b
ON a.`Order Date` = b.`Day`
GROUP BY b.`Week`
);



select * from mmm_sales_tranformed;

/*Find out all weeks that total sales are greater than 250,000*/
with weeklysales as
(
select date_format(b.Week,'%m/%d/%y')as Week,round(sum(a.Sales),2)as Sales
from mmm.mmm_sales_raw_nofrench a
left join mmm.mmm_date_metadata b
on a.`Order Date` = b.Day
group by b.Week)
select * 
from weeklysales
where Sales > 250000;

/*Find out all the week number that sales have increased from the week before*/
with weeklysale1 as
(
select date_format(b.Week,'%m/%d/%y') as Week,
round(sum(Sales),2)as This_Week_Sales,
lag(round(sum(Sales),2),1) OVER (order by Week) as Previous_Week_Sales,
round(round(sum(Sales),2) - lag(round(sum(Sales),2),1) OVER (order by Week),2) as Diff
from mmm.mmm_sales_raw_nofrench a
left join mmm.mmm_date_metadata b
on a.`Order Date` = b.Day
group by b.Week)
select * 
from weeklysale1
where Diff > 0;

/*Review*/
select * 
from mmm.mmm_sales_tranform a
left join mmm.mmm_sales_tranform b
on a.Week = Date_add(b.Week,interval 7 day)
where a.Sales > b.Sales;

/*Find out the quarter of each year that has the highest sales*/
with salesrank 
as
(
select year(`Order Date`)as Year, 
quarter(`Order Date`) as Quarter, 
max(Sales) as Total_Sales,
rank () over (partition by quarter(`Order Date`) order by max(Sales) desc) as salrank
from mmm.mmm_sales_raw_nofrench
group by quarter(`Order Date`), year(`Order Date`))
select Year, Quarter, Total_Sales
from salesrank
where salrank<2
order by Total_Sales desc;



