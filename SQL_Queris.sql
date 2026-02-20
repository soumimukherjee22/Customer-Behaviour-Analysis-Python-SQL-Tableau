-- creating and cleaning
create database customer_behaviour;
use customer_behaviour;
select * from shopping;
ALTER TABLE shopping
RENAME COLUMN `Customer ID` TO customer_id,
RENAME COLUMN `Age` TO age,
RENAME COLUMN `Gender` TO gender,
RENAME COLUMN `Item Purchased` TO item_purchased,
RENAME COLUMN `Category` TO category,
RENAME COLUMN `Purchase Amount (USD)` TO purchase_amount_usd,
RENAME COLUMN `Location` TO location,
RENAME COLUMN `Size` TO size,
RENAME COLUMN `Color` TO color,
RENAME COLUMN `Season` TO season,
RENAME COLUMN `Review Rating` TO review_rating,
RENAME COLUMN `Subscription Status` TO subscription_status,
RENAME COLUMN `Payment Method` TO payment_method,
RENAME COLUMN `Shipping Type` TO shipping_type,
RENAME COLUMN `Discount Applied` TO discount_applied,
RENAME COLUMN `Promo Code Used` TO promo_code_used,
RENAME COLUMN `Previous Purchases` TO previous_purchases,
RENAME COLUMN `Preferred Payment Method` TO Preferred_payment_method,
RENAME COLUMN `Frequency of Purchases` TO frequency_of_purchases;
alter table shopping add column age_group varchar(50);
set sql_safe_updates=0;
update shopping set age_group = case 
when age < 18 then "Minor"
when age between 18 and 34 then "Young_Adult"
when age between 35 and 54 then "Adult"
when age >=55 then "Senior"
else "N/A"
end;
set sql_safe_updates=1;

-- BASIC SQL QUESTIONS
-- Customer Overview
-- 1. Total number of customers
select count(customer_id) as Total_Number_of_customers from shopping;
-- 2. Total purchase amount (revenue)
select sum(purchase_amount_usd) as Total_Revenue from shopping;
-- 3. Average purchase amount
select round(avg(purchase_amount_usd),2) as Avg_Revenue from shopping;
-- 4. Total purchases by gender
select gender, sum(purchase_amount_usd) as Total_Purchases from shopping group by gender;
-- 5. Customer count by age group
select  gender, count(customer_id) as Customer_Count from shopping group by gender;
-- 6. Customer distribution by location
select location, count(customer_id) as Total_Customers from shopping group by location;

-- Product Analysis
-- 7. Total sales by category
select category, sum(purchase_amount_usd) as Total_Sales from shopping group by category;
-- 8. Total sales by item purchased
select item_purchased, sum(purchase_amount_usd) as Total_Sales from shopping group by item_purchased;
-- 9. Most purchased product category
select category, sum(purchase_amount_usd) as Total_Sales from shopping group by category order by Total_Sales desc;
-- 10. Sales distribution by size
select size, sum(purchase_amount_usd) as Total_Sales from shopping group by size;
-- 11. Sales distribution by color
select color, sum(purchase_amount_usd) as Total_Sales from shopping group by color;
-- 12. Sales by season
select season, sum(purchase_amount_usd) as Total_Sales from shopping group by season;

-- Payment & Subscription
-- 13. Purchases by payment method
select payment_method, sum(purchase_amount_usd) as Total_Sales from shopping group by payment_method;
-- 14. Preferred payment method count
select payment_method, count(payment_method) as Total_Payment from shopping group by payment_method;
-- 15. Subscription vs non-subscription customer count
select subscription_status, count(subscription_status) as Total_Subscription from shopping group by subscription_status;
-- 16. Revenue from subscribed vs non-subscribed users
select subscription_status, sum(purchase_amount_usd) as Total_Sales from shopping group by subscription_status;

-- Marketing Impact
-- 17. Purchases with discount vs without discount
select discount_applied, count(discount_applied) as Total_Discount_Applied from shopping group by discount_applied;
-- 18. Purchases using promo code vs not using promo code
select promo_code_used, count(promo_code_used) as Total_Promo_Code_Used from shopping group by promo_code_used;
-- 19. Average purchase amount with discount applied
select round(avg(purchase_amount_usd),2) as Avg_Sales_by_discount from shopping where discount_applied = "Yes";
-- 20. Average purchase amount without discount
select round(avg(purchase_amount_usd),2) as Avg_Sales_without_discount from shopping where discount_applied = "No";

-- INTERMEDIATE SQL QUESTIONS
-- Customer Behavior Analysis
-- 1. Average spend per customer
select customer_id, avg(purchase_amount_usd) as Avg_Spend from shopping group by customer_id;
-- 2. Top 10 high-value customers by total spending
select customer_id, sum(purchase_amount_usd) as Total_Sales from shopping group by customer_id order by Total_Sales desc limit 10;
-- 3. Customers with highest number of previous purchases
select customer_id, previous_purchases from shopping where previous_purchases = (select max(previous_purchases)from shopping);
-- 4. Repeat buyers vs one-time buyers distribution
with CustomerPurchaseCounts as (
select customer_id, count(customer_id) as Purchase_Count
from shopping 
group by customer_id
)
select 
case 
when Purchase_Count = "1" then "One_Time_Buyers"
else "Repeat_Buyers"
end as CustomerType,
count(customer_id) as Customer_Count
from CustomerPurchaseCounts
group by CustomerType;
-- 5. Customer segmentation based on purchase frequency
-- Weekly, Fortnightly, Monthly, Annually
select count(customer_id) as Total_Customers, frequency_of_purchases from shopping group by frequency_of_purchases;

-- Revenue Intelligence
-- 6. Revenue by location and category
select location, category, sum(purchase_amount_usd) as Total_Revenue from shopping group by location, category;
-- 7. Revenue by season and category
select season, category, sum(purchase_amount_usd) as Total_Revenue from shopping group by season, category;
-- 8. Revenue by gender and category
select gender, category, sum(purchase_amount_usd) as Total_Revenue from shopping group by gender, category;
-- 9. Revenue by age group and category
select age_group, category, sum(purchase_amount_usd) as Total_Revenue from shopping group by age_group, category;
-- 10. High-revenue product categories per season
select season, category, sum(purchase_amount_usd) as Total_Revenue from shopping group by season, category order by Total_Revenue desc;

-- Marketing Effectiveness
-- 11. Revenue impact of discounts
select 
case 
when discount_applied = "Yes" then "With_Discount"
else "Without_Discount"
end as Discount_Status,
sum(purchase_amount_usd) as Total_Revenue,
avg(purchase_amount_usd) as Avg_Purchase_Amount,
count(*) as Number_of_Orders
from shopping 
group by Discount_Status;
-- 12. Revenue impact of promo codes
select 
case 
when promo_code_used = "Yes" then "With_Discount"
else "Without_Discount"
end as Code_Using_Status,
sum(purchase_amount_usd) as Total_Revenue,
avg(purchase_amount_usd) as Avg_Purchase_Amount,
count(*) as Number_of_Orders
from shopping 
group by Code_Using_Status;
-- 13. Subscription users vs non-subscription users revenue contribution
select 
case 
when subscription_status = "Yes" then "Subscribed"
else "Non-Subscribed"
end as Subscription_Status,
sum(purchase_amount_usd) as Total_Revenue,
avg(purchase_amount_usd) as Avg_Purchase_Amount,
count(*) as Number_of_Orders
from shopping 
group by Subscription_Status;
-- 14. Average rating vs purchase amount relationship
select review_rating, avg(purchase_amount_usd) as Avg_Purchase_Amount from shopping group by review_rating order by review_rating;
-- 15. Discount usage by frequency of purchase
select discount_applied, frequency_of_purchases, count(*) as usage_count from shopping group by discount_applied, frequency_of_purchases;

-- Operational Analytics
-- 16. Shipping type vs average purchase amount
select shipping_type, avg(purchase_amount_usd) as average_purchase_amount from shopping group by shipping_type;
-- 17. Shipping type vs customer satisfaction (review rating)
select shipping_type, round(avg(review_rating),2) as customer_satisfaction from shopping group by shipping_type;
-- 18. Payment method vs average transaction value
select payment_method, round(avg(purchase_amount_usd),2) as average_transaction_value from shopping group by payment_method order by average_transaction_value desc;
-- 19. Location-wise payment preference patterns
select location, payment_method, count(*) as preference_count from shopping group by location, payment_method order by location, preference_count desc;
-- 20. Subscription status vs frequency of purchase
select subscription_status, frequency_of_purchases, count(customer_id) as Total_Customers, avg(purchase_amount_usd) as avg_spend from shopping group by subscription_status, frequency_of_purchases;

-- ADVANCED INTERMEDIATE (SQL + Power BI Storytelling)
-- 1. RFM-style segmentation using:
-- Frequency (Frequency of Purchases)
-- Monetary (Purchase Amount)
-- Engagement (Previous Purchases)
SELECT 
    customer_id,
    SUM(purchase_amount_usd) AS total_spent,
    AVG(purchase_amount_usd) AS avg_spent,
    MAX(previous_purchases) AS previous_purchases,
    frequency_of_purchases AS purchase_frequency,
    
    CASE 
        WHEN SUM(purchase_amount_usd) >= 300 THEN 'High_Value'
        WHEN SUM(purchase_amount_usd) BETWEEN 150 AND 299 THEN 'Medium_Value'
        ELSE 'Low_Value'
    END AS monetary_segment,
    
    CASE 
        WHEN MAX(previous_purchases) >= 15 THEN 'Highly_Engaged'
        WHEN MAX(previous_purchases) BETWEEN 5 AND 14 THEN 'Moderately_Engaged'
        ELSE 'Low_Engagement'
    END AS engagement_segment,
    
    CASE 
        WHEN frequency_of_purchases IN ('Weekly','Fortnightly') THEN 'High_Frequency'
        WHEN frequency_of_purchases = 'Monthly' THEN 'Medium_Frequency'
        ELSE 'Low_Frequency'
    END AS frequency_segment

FROM shopping
GROUP BY customer_id, frequency_of_purchases;
-- 2 High-value loyal customers identification
SELECT 
    customer_id,
    SUM(purchase_amount_usd) AS total_spent,
    MAX(previous_purchases) AS previous_purchases,
    frequency_of_purchases
FROM shopping
GROUP BY customer_id, frequency_of_purchases
HAVING 
    SUM(purchase_amount_usd) >= 300
    AND MAX(previous_purchases) >= 10
    AND frequency_of_purchases IN ('Weekly','Fortnightly')
ORDER BY total_spent DESC;
-- 3. Churn-risk customers (low frequency + low previous purchases)
SELECT 
    customer_id,
    SUM(purchase_amount_usd) AS total_spent,
    MAX(previous_purchases) AS previous_purchases,
    frequency_of_purchases
FROM shopping
GROUP BY customer_id, frequency_of_purchases
HAVING 
    SUM(purchase_amount_usd) < 100
    AND MAX(previous_purchases) < 3
    AND frequency_of_purchases IN ('Annually','Quarterly')
ORDER BY total_spent ASC;
-- 4. Seasonal buying pattern analysis
SELECT 
    season,
    category,
    COUNT(*) AS total_orders,
    SUM(purchase_amount_usd) AS total_revenue,
    AVG(purchase_amount_usd) AS avg_order_value
FROM shopping
GROUP BY season, category
ORDER BY season, total_revenue DESC;
-- 5. Cross-analysis:
-- Discount + Promo + Subscription impact on revenue
SELECT 
    discount_applied,
    promo_code_used,
    subscription_status,
    COUNT(*) AS total_transactions,
    SUM(purchase_amount_usd) AS total_revenue,
    AVG(purchase_amount_usd) AS avg_purchase_value
FROM shopping
GROUP BY 
    discount_applied,
    promo_code_used,
    subscription_status
ORDER BY total_revenue DESC;


-- Business Intelligence View
CREATE VIEW customer_behavior_intelligence AS
SELECT 
    customer_id,
    gender,
    age,
    location,
    category,
    season,
    subscription_status,
    frequency_of_purchases,
    discount_applied,
    promo_code_used,
    SUM(purchase_amount_usd) AS total_spent,
    AVG(purchase_amount_usd) AS avg_spent,
    MAX(previous_purchases) AS previous_purchases
FROM shopping
GROUP BY 
    customer_id,
    gender,
    age,
    location,
    category,
    season,
    subscription_status,
    frequency_of_purchases,
    discount_applied,
    promo_code_used;
select * from customer_behavior_intelligence;