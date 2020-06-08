SET GLOBAL sql_mode = 'ONLY_FULL_GROUP_BY';
select @@GLOBAL.sql_mode;

create database superstoresDB;

use superstoresdb;

describe cust_dimen;
describe market_fact;
describe orders_dimen;
describe prod_dimen;
describe shipping_dimen;

/* TASK 1

A) : Understanding the data in hand 

Table Name - cust_dimen

This table gives information about the customers of the superstore
The columns include Customer_Name, Province, Region, Customer_Segment, Cust_id 
with the data type being "text".

Table name - market_fact;

The table has the details of products, customers and orders 
The columns include Ord_id, Prod_id, Ship_id, Cust_id, Sales, Discount, Order_Quantity, Profit, Shipping_Cost, Product_Base_Margin
with data type being "text" for Ord_id,Prod_id,Ship_id,Cust_id; "integer" for  Order_Quantity; and double for remaining columns.

Table Name - orders_dimen;

The table gives details of orders
The columns include Order_ID, Order_Date, Order_Priority, Ord_id
with data type being "interger" for Order_ID and "text" for remaining columns.


Table Name - prod_dimen

The table gives details about all the products of superstore
The columns include Product_Category, Product_Sub_Category, Prod_id 
with data type being "text".

Table name - shipping_dimen;

The table gives details of shipping. 
The columns include Order_ID, Ship_Mode, Ship_Date, Ship_id
with data type being "interger" for Order_ID and "text" for remaining columns.

...................................................................................................
B): Identify and list the Primary Keys and Foreign Keys for this dataset

1) Table: cust_dimen
	Primary key is Cust_id and there is no foriegn key.
    
2) Table: market_fact
	There is no Primary key and thaere are multiple foriegn key's.
    They are Ord_id, Prod_id, Ship_id, Cust_id
    
3) Table: orders_dimen 
   Primary Key is Ord_id and there is no foriegn key.
   
4) Table: prod_dimen
   Primary Key is Prod_id and there is no foriegn key.
   
5) Table: shipping_dimen
   Primary Key  is Ship_id and there is no foriegn key
   
*/

/*-----------------------------------------------------------------------
/*Task 2: Basic Analysis*/

/* A).To find the Total and the Average sales.*/

select (sum(market_fact.Sales)) as total_sales,
	   (avg(market_fact.Sales)) as avg_sales 
from market_fact;

/*B). To display the number of customers in each region in decreasing order of no_of_customers. */

select Region, count(Customer_Name) as no_of_customer
from cust_dimen
group by Region
order by no_of_customers DESC;

/*C). To find region having maximum customers */


select count(Customer_Name) as 'max(no_of_customers)', Region
from cust_dimen
group by Region 
having max(no_of_customer) = (select max(no_of_customer)
								from (select Region,
									  count(Customer_Name) as 'no_of_customers' 
									  from cust_dimen 
                                      group by Region)
							as a);
   

/*D). To find the number and id of products sold in decreasing order of products sold*/

select Prod_id as 'product ID', 
sum(Order_Quantity) as 'no_of_products sold' 
from market_fact 
group by Prod_id 
order by sum(Order_Quantity) DESC;

/*E). To find all the customers from Atlantic region who have ever purchased ‘TABLES’ and the number of tables purchased */

select cust_dimen.Customer_Name as 'customer name',
sum(market_fact.Order_Quantity) as 'no_of_tables purchased'
from cust_dimen,market_fact,prod_dimen
where cust_dimen.cust_id=market_fact.cust_id 
and prod_dimen.prod_id=market_fact.prod_id
and prod_dimen.Product_Sub_Category="TABLES"
and cust_dimen.Region="ATLANTIC" 
group by cust_dimen.Customer_Name;

/*-------------------------------------------------------------------------------------------
/*Task 3 : Advanced Analysis*/


/*A). Display the product categories in descending order of profits */

select P1.Product_Category as 'product_category',
sum(P2.profits) as'Profits'
from prod_dimen P1
left join (select Prod_id,
		  (sum(Profit)) as 'Profits' 
          from market_fact
          group by Prod_id) P2 on P1.Prod_id = P2.Prod_id 
group by P1.Product_Category
order by profits DESC;


/*B). To display the product category, product sub-category and the profit within each subcategory in three columns.*/
   
select P1.Product_Category as 'Product_Category',
P1.Product_Sub_Category as 'Product_Sub_Category',
sum(P2.profits) as'Profit'
from prod_dimen P1
left join (select Prod_id,
		  (sum(Profit)) as 'Profit'
          from market_fact
          group by Prod_id) P2 on P1.Prod_id = P2.Prod_id 
group by P1.Product_Category,P1.Product_Sub_Category;

   
/*C) 	To find least profitable product subcategory shipped the most */
   
select prod_dimen.Product_Category,
prod_dimen.Product_Sub_Category,
sum(market_fact.Profit)
from prod_dimen, market_fact
where prod_dimen.prod_id=market_fact.prod_id 
group by prod_dimen.Product_Sub_Category,prod_dimen.Product_Category
order by sum(market_fact.Profit) 
limit 1;

/* To diplay region,no of shipments and profit in each region*/

select cust_dimen.region,
count(shipping_dimen.ship_id) as no_of_shipments,
sum(market_fact.profit) as profit_in_each_region
from cust_dimen, shipping_dimen, market_fact, prod_dimen
where cust_dimen.cust_id=market_fact.cust_id 
and shipping_dimen.ship_id=market_fact.ship_id
and prod_dimen.prod_id=market_fact.prod_id 
and prod_dimen.Product_Sub_Category="TABLES"
group by cust_dimen.region
order by profit_in_each_region desc;

/* Region in which least profitable sub category is sold*/

select region 
from (select cust_dimen.region,
	 count(shipping_dimen.ship_id) as no_of_shipments,
     sum(market_fact.profit) as profit_in_each_region
	 from cust_dimen, shipping_dimen, market_fact, prod_dimen
	 where cust_dimen.cust_id=market_fact.cust_id 
     and shipping_dimen.ship_id=market_fact.ship_id
	 and prod_dimen.prod_id=market_fact.prod_id 
     and prod_dimen.Product_Sub_Category="TABLES"
group by cust_dimen.region
order by no_of_shipments desc) a limit 1;