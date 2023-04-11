--dropping unnecessary columns


alter table [dbo].['2018$']
drop column 
       lead_time
      ,[arrival_date_week_number]
      ,[arrival_date_day_of_month]
      ,[adults]
      ,[children]
      ,[babies]
      ,[is_repeated_guest]
      ,[previous_cancellations]
      ,[previous_bookings_not_canceled]
      ,[reserved_room_type]
      ,[assigned_room_type]
      ,[booking_changes]
      ,[deposit_type]
      ,[agent]
      ,[company]
      ,[days_in_waiting_list]
      ,[customer_type]
      ,[total_of_special_requests]
      ,[reservation_status]
      ,[reservation_status_date]


alter table [dbo].['2019$']
drop column 
       lead_time
	  ,[is_canceled]
      ,[arrival_date_week_number]
      ,[arrival_date_day_of_month]
      ,[adults]
      ,[children]
      ,[babies]
      ,[is_repeated_guest]
      ,[previous_cancellations]
      ,[previous_bookings_not_canceled]
      ,[reserved_room_type]
      ,[assigned_room_type]
      ,[booking_changes]
      ,[deposit_type]
      ,[agent]
      ,[company]
      ,[days_in_waiting_list]
      ,[customer_type]
      ,[total_of_special_requests]
      ,[reservation_status]
      ,[reservation_status_date]


alter table [dbo].['2020$']
drop column 
       lead_time
	  ,[is_canceled]
      ,[arrival_date_week_number]
      ,[arrival_date_day_of_month]
      ,[adults]
      ,[children]
      ,[babies]
      ,[is_repeated_guest]
      ,[previous_cancellations]
      ,[previous_bookings_not_canceled]
      ,[reserved_room_type]
      ,[assigned_room_type]
      ,[booking_changes]
      ,[deposit_type]
      ,[agent]
      ,[company]
      ,[days_in_waiting_list]
      ,[customer_type]
      ,[total_of_special_requests]
      ,[reservation_status]
      ,[reservation_status_date]


--cleaning market_segment table

go
create or alter view segment_discount as(
	select top 8 *
	from market_segment$)
go


--joinint 2018 & 2019 data


go
create or alter view combined_table as(
	select * from [dbo].['2018$']
	union all
	select * from [dbo].['2019$'])
go



--joining combined_table with segment_discount


go
create or alter view joined_data as(
	select combined_table.hotel, combined_table.arrival_date_month, combined_table.arrival_date_year, combined_table.stays_in_week_nights, 
	combined_table.stays_in_weekend_nights, combined_table.meal, combined_table.country, combined_table.market_segment, combined_table.distribution_channel,
	combined_table.adr, combined_table.required_car_parking_spaces, segment_discount.Discount
	from combined_table
	join segment_discount
	on combined_table.market_segment=segment_discount.market_segment)
go


--adding the revenue colum to form final table

go
create or alter view final_data as(
	select *, (stays_in_week_nights+stays_in_weekend_nights)*adr*(1-Discount) as revenue
	from joined_data)
go


--1) Calculate the important KPIs

select arrival_date_year, count(*) as total_customer
from final_data
group by arrival_date_year

select arrival_date_year, round(sum(revenue), 0) as revenue
from final_data
group by arrival_date_year

select round(AVG(adr), 0) as average_adr from final_data

select round(AVG(stays_in_week_nights+stays_in_weekend_nights), 0) as average_stay from final_data


--2) What is revenue breakdown according to hotel type?

select arrival_date_year, hotel, round(sum(revenue), 0) as revenue
from final_data
group by arrival_date_year, hotel
order by arrival_date_year


--3) atleast by how much % parking size should be increased?

select arrival_date_year, sum(required_car_parking_spaces) as required_parking_space,
round(((sum(required_car_parking_spaces) - lag(sum(required_car_parking_spaces)) over (order by arrival_date_year))
/lag(sum(required_car_parking_spaces)) over (order by arrival_date_year))*100, 2) as perc_increase
from final_data
group by arrival_date_year
-- parking size should be increased by atleast 200%


--4) Which countries contribute the most to the revenue

select top 10 country, round(sum(revenue), 0) as revenue
from final_data
group by country
order by revenue desc


--5) Find out top emerging countries

select top 10 country, round(sum(revenue), 0) as revenue,
round(((sum(revenue) - lag(sum(revenue)) over(partition by country order by arrival_date_year))/
lag(sum(revenue)) over(partition by country order by arrival_date_year))*100, 2) as annual_perc_increase
from final_data
group by country, arrival_date_year
--order by country, arrival_date_year
order by annual_perc_increase desc


--6) From which distribution channels we are getting most customers

select distribution_channel, count(*) as total_reservations
from final_data
group by distribution_channel
order by total_reservations desc


--7) Which meal plans are popular among customers

select meal, count(*) as total_customers
from final_data
group by meal
order by total_customers desc


--8) Find out the peak seasons for our business

select arrival_date_month, count(*) as total_Reservations
from final_data
group by arrival_date_month
order by total_Reservations desc

















