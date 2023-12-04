/* Import dataset to DSADATA library */
proc import
	out=DSADATA.housing
	datafile='/home/u63571953/Data/Project_Housing.csv'
	dbms=CSV
	replace;
run;

/* 1. Generate (Last 20 rows) processed renting post records. (2M) */
proc sql;
	create table rentingPost as
	select * 
	from DSADATA.housing
	order by monotonic() desc;
quit;

data last20rows;
	set rentingPost (obs=20);
run;

proc print data=last20rows;
	title 'Q1';
run;

/* 2. What kind of property is having the most number of the reception on average? (5M) */
proc sql;
	create table AvgReception as
	select FlatType, avg(TotalReceptions) as AvgR
	from DSADATA.housing
	group by FlatType
	order by AvgR desc;
quit;

proc print data=AvgReception;
	title 'Q2';
run;

proc sgplot data=AvgReception;
    vbar FlatType / response=AvgR datalabel;
    xaxis display=(nolabel);
    yaxis grid;
run;

/* 3. What is the contribution of house type in the record? What is the most common type of property in the UK? (5M) */
proc sql;
	create table type_counts as
	select FlatType, count(*) as count
	from DSADATA.housing
	group by FlatType;
quit;

proc sgpie data=type_counts;
title 'Q3';
	pie FlatType / response=count;
run;

proc sql;
	select FlatType, count(*) as count
	from DSADATA.housing
	group by FlatType
	order by count desc
	;
quit;

proc sgplot data=type_counts;
	vbar FlatType / response=count datalabel;
run;

/* 4. What is the value distribution of the number of bathroom between the flat house and terraced house? (5M) */
proc sql;
   create table bathroom_counts as
   select FlatType, TotalBaths, count(*) as count
   from DSADATA.housing
   where FlatType in ('flat', 'terraced house')
   group by FlatType, TotalBaths;
quit;

proc print data=bathroom_counts;
	title 'Q4';
run;

proc sgplot data=bathroom_counts;
   vbar TotalBaths / group=FlatType response=count;
run;

proc sgplot data=DSADATA.housing;
	where FlatType in ('flat', 'terraced house');
	vbox TotalBaths / category=FlatType;
run;

/* 5. What kind of property is contain the second most turnover? (7M) */
proc sql;
	create table sales_summary as
	select FlatType, sum(price) as total_sales
	from DSADATA.housing
	group by FlatType;
quit;

proc sort data=sales_summary;
	by descending total_sales;
run;

proc print data=sales_summary;
	title 'Q5';
run;

proc sgplot data=sales_summary;
	vbar flattype / response=total_sales datalabel;
	xaxis discreteorder=data;
	yaxis label="Total Sales";
run;

/* 6. Is there any relationship between the number of bedrooms, the number of bathrooms and the average price of a different property? (5M) */
proc corr data=DSADATA.housing;
	var TotalBeds TotalBaths;
	with price;
	title 'Q6 corr';
run;

proc sgplot data=DSADATA.housing;
   reg x=TotalBeds y=Price;
   xaxis label="TotalBeds";
   yaxis label="Price";
   title 'Q6 corr bed';
run;

proc sgplot data=DSADATA.housing;
   reg x=TotalBaths y=Price;
   xaxis label="TotalBaths";
   yaxis label="Price";
   title 'Q6 corr bath';
run;

proc reg data=DSADATA.housing;
   model Price = TotalBeds TotalBaths;
   title 'Q6 reg';
run;







