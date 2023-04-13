--Caffeine Form sells cups to coffee shops through their website. They would prefer to partner directly with the shops. 
--The company believes that stores with more reviews will help them to better market their product.
--The company wants to focus on the types of shop that get the most review and requested a report on how types of shop and number of reviews are related.


--Data cleaning:


--Region: Missing values should be replaced with "Unknown". Checked for missing values and replace with "Unknown". No NULLs were found.
SELECT DISTINCT Region
FROM coffeeshops;



--Checked for missing values and replace with "Unknown". Check for missing values and replace with "Unknown". No NULLS were found.
--Verify if all place_type categories are listed/there are any typos:
SELECT DISTINCT Place_type
FROM coffeeshops;

--Average rating of the store from reviews: On a 5 point scale. Missing values should be replaced with 0.
SELECT
COALESCE(Rating, 0) AS Rating
FROM coffeeshops;

--Reviews: Continuous. The number of reviews given to the store. Missing values should be replaced with the overall median number.

SELECT
PERCENTILE_DISC(0.5) 
        WITHIN GROUP (ORDER BY Reviews)
        OVER (PARTITION BY Reviews) AS median
FROM coffeeshops;


--Check for missing values and replace with median:
SELECT 
COALESCE(Reviews, 
		(SELECT TOP 1
PERCENTILE_DISC(0.5) 
        WITHIN GROUP (ORDER BY Reviews)
        OVER (PARTITION BY Reviews) AS median
FROM coffeeshops))
FROM coffeeshops;


--Dine in Option: Nominal. If dine in is available. Either True or False. Missing values should be replaced with False.
--Verify if all categories are listed/there are any typos.
--Check for missing values and replace with "False". Replace 1 for "True"
SELECT
CASE
    WHEN Dine_in_option IS NULL THEN 'False'
   	ELSE 'True'
    END
FROM coffeeshops;

--Takeaway Option: Nominal. If take away is available. Either True or False. Missing values should be replaced with False.
--Verify if all categories are listed/there are any typos.
--Check for missing values and replace with "False". Replace 1 for "True":
SELECT
CASE
    WHEN Takeout_option IS NULL THEN 'False'
   	ELSE 'True'
    END
FROM coffeeshops;



--Putting everything together using CTEs:

WITH Ratings AS(
SELECT
Place_name, Place_type, COALESCE(Rating, 0) AS Rating
FROM coffeeshops), 

Reviews AS (
SELECT
Place_name,
COALESCE(Reviews, 
		(SELECT TOP 1
PERCENTILE_DISC(0.5) 
        WITHIN GROUP (ORDER BY Reviews)
        OVER (PARTITION BY Reviews) AS median
FROM coffeeshops)) AS Reviews
FROM coffeeshops)

SELECT
COUNT(*) AS count,
ra.Place_type,
ROUND(AVG(CAST (Rating AS numeric)),2) AS avg_Rating,  
ROUND(AVG(CAST (Reviews AS numeric)),2) AS avg_Reviews
FROM Ratings ra
INNER JOIN Reviews re
ON ra.Place_name = re.Place_name
GROUP BY ra.Place_type
ORDER BY 1 DESC, 2;
