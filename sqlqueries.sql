--------------------------------------------------------- Sample Assessment ---------------------------------------------------------------------

-- Table Creation 
DROP TABLE IF EXISTS ott_viewership;
CREATE TABLE ott_viewership (
    view_id SERIAL PRIMARY KEY,
    user_name VARCHAR(50),
    region VARCHAR(30),
    show_name VARCHAR(50),
    genre VARCHAR(30),
    watch_hours INT,
    subscription_amount INT,
    watch_month VARCHAR(15)
);

--Insert Data
INSERT INTO ott_viewership (user_name, region, show_name, genre, watch_hours, subscription_amount, watch_month)
VALUES
('Rahul', 'North', 'Stranger Things', 'Drama', 15, 499, 'Jan'),
('Neha', 'South', 'Money Heist', 'Crime', 20, 499, 'Jan'),
('Vivek', 'East', 'Stranger Things', 'Drama', 18, 699, 'Feb'),
('Priya', 'West', 'Wednesday', 'Drama', 25, 699, 'Feb'),
('Amit', 'South', 'Money Heist', 'Crime', 12, 499, 'Mar'),
('Riya', 'East', 'The Witcher', 'Fantasy', 30, 999, 'Mar'),
('Karan', 'North', 'Wednesday', 'Drama', 22, 699, 'Apr'),
('Sohan', 'South', 'Stranger Things', 'Drama', 28, 999, 'Apr'),
('Pooja', 'West', 'The Witcher', 'Fantasy', 16, 499, 'May'),
('Arjun', 'North', 'Money Heist', 'Crime', 24, 699, 'May'),
('Meera', 'East', 'Wednesday', 'Drama', 19, 699, 'Jun'),
('Rohit', 'West', 'Stranger Things', 'Drama', 26, 999, 'Jun');


-- The management team wants insights about:
-- Most popular shows
-- User engagement
-- Regional performance
-- Subscription revenue
-- Content rankings
-- Monthly platform growth


-- Task 1: Identify users who watched more than the platform’s average watch hours.

WITH cte AS (
	SELECT  user_name,ROUND(AVG(watch_hours) over(),2) AS avg_watch_hours,watch_hours
	FROM ott_viewership
)
SELECT * FROM cte
WHERE watch_hours>avg_watch_hours;



-- Task 2: Determine whether any user from the West region watched “The Witcher”
WITH south_region AS(
	SELECT *
	FROM ott_viewership
	WHERE region = 'West'
)
SELECT * FROM south_region
WHERE show_name= 'The Witcher';


-- Task 3: Identify regions where at least one user watched more than 25 hours.
WITH watchhour AS (
	SELECT * 
	FROM ott_viewership
	WHERE watch_hours>25
)
SELECT user_name,REGION,watch_hours
FROM watchhour;



-- Task 4:
-- Create a reusable query output/result table showing:
-- Region
-- Total Watch Hours
-- Total Subscription Revenue
-- Store this query output/result table for future use.

CREATE OR REPLACE VIEW region_summary AS (
	SELECT region, 
		   SUM(watch_hours) AS total_watch_hours, 
		   SUM(subscription_amount) AS total_subs_revenue
	FROM ott_viewership
	GROUP BY region
);
SELECT * FROM region_summary;

-- Task 5: Rank all shows based on total watch hours

SELECT show_name,
	   SUM(watch_hours) AS total_watch_hours,
	   DENSE_RANK() OVER( ORDER BY SUM(watch_hours) DESC )
FROM ott_viewership
GROUP BY show_name;



-- Task 6: Assign a unique position to each user based on watch hours
WITH top_viewers AS (
	SELECT user_name, SUM(watch_hours) AS total_watch_hours
	FROM ott_viewership
	GROUP BY user_name
	ORDER BY total_watch_hours DESC
)
SELECT *,
		RANK() OVER (ORDER BY total_watch_hours DESC)
FROM top_viewers;



-- Task 7: Rank all regions based on subscription revenue.
-- If two regions have the same revenue, they should share the same rank.

SELECT *,
		DENSE_RANK() OVER(ORDER BY total_subs_revenue DESC ) AS rnk
FROM region_summary;   --Utilizing region_summary view we created before


-- Task 8: For every month, display the previous month’s subscription revenue.
CREATE OR REPLACE VIEW months_summary AS (
SELECT CASE WHEN watch_month = 'Jan' THEN 1
			WHEN watch_month = 'Feb' THEN 2
			WHEN watch_month = 'Mar' THEN 3
			WHEN watch_month = 'Apr' THEN 4
			WHEN watch_month = 'May' THEN 5 
			WHEN watch_month = 'Jun' THEN 6
			END AS month_no,
			watch_month,
			SUM(watch_hours) AS "Total Watch Hours",
			SUM(subscription_amount) AS "Subscription Revenue"
			
FROM ott_viewership
GROUP BY watch_month
ORDER BY month_no
);
SELECT *, LAG("Subscription Revenue") OVER() AS previous_month_revenue
FROM months_summary;


-- Task 9: For every month, display the next month’s subscription revenue.
SELECT *,
		LEAD("Subscription Revenue") OVER() AS next_month_revenue
FROM months_summary; -- utilizing months_summary VIEW 


-- Task 10:
-- Create a query output/result table that shows:
-- Show Name
-- Total Watch Hours
-- Show Rank
-- Then display only the Top 3 shows on the platform
CREATE OR REPLACE VIEW show_summary AS (
	SELECT show_name, 
		   SUM(watch_hours) AS total_watch_hours, 
		   DENSE_RANK() OVER (ORDER BY SUM(watch_hours)  DESC)
	FROM ott_viewership
	GROUP BY show_name
);

SELECT * FROM show_summary
LIMIT 3;


-- Task 11:
-- Create a query output/result table that shows:
-- Region
-- Total Revenue
-- Revenue Rank
-- Display only the Top 2 performing regions.

SELECT region, total_subs_revenue AS total_revenue ,
		DENSE_RANK() OVER(ORDER BY total_subs_revenue DESC ) AS Revenue_Rank
FROM region_summary    --Utilizing region_summary view we created before
LIMIT 2;   


-- Task 12: Identify the most watched show in each region

WITH show_region AS (
	SELECT region, show_name, SUM(watch_hours),
	DENSE_RANK() OVER(PARTITION BY REGION ORDER BY SUM(watch_hours) DESC ) AS rnk 
	FROM ott_viewership
	GROUP BY region, show_name)
	

SELECT *
FROM show_region
WHERE rnk <2;

-- Task 13: Write any three business insights from the dataset
SELECT * FROM MONTHS_SUMMARY
order by "Subscription Revenue" desc ;

SELECT * FROM show_summary;




