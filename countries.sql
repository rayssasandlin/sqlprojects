--Calculating  the percentage increase in population from 2010 to 2015 for each country code:

SELECT p1.country_code,
       p1.size AS size2010, 
       p2.size AS size2015,
      (p2.size - p1.size)/p1.size * 100.0 AS growth_perc
FROM populations AS p1
  INNER JOIN populations AS p2
    ON p1.country_code = p2.country_code
              AND p1.year = p2.year - 5;


--Exploring the relationship between the size of a country in terms of surface area and in terms of population using grouping fields created with CASE:

SELECT country_name, continent, code, surface_area,
       CASE WHEN surface_area > 2000000 THEN 'large'
        WHEN surface_area > 350000 THEN 'medium'
        ELSE 'small' END
        AS geosize_group
FROM countries;

SELECT country_code, size,
  CASE WHEN size > 50000000
            THEN 'large'
       WHEN size > 1000000
            THEN 'medium'
       ELSE 'small' END
       AS popsize_group
FROM dbo.populations
WHERE year = 2015;

SELECT
name, continent, geosize_group, popsize_group
FROM countries_plus AS c
  INNER JOIN pop_plus AS p
    ON c.code = p.country_code
ORDER BY geosize_group;



--Determining the names of the lowest five countries and their regions in terms of life expectancy for 2010:

SELECT TOP 5
c.country_name AS country,
region,
life_expectancy AS life_exp
FROM countries c
  LEFT JOIN populations p
    ON c.code = p.country_code
WHERE year = 2010
AND life_expectancy IS NOT NULL
ORDER BY life_exp;




--Which countries also have a city with the same name as their country name?
SELECT country_name
  FROM countries
	INTERSECT
SELECT name
  FROM cities;


--Listing the names of cities in cities which are not noted as capital cities in countries as a single field result:
SELECT name
  FROM cities
	EXCEPT
SELECT capital
  FROM countries
ORDER BY name;




--Listing the names of capital cities that are not listed in the cities table:
SELECT capital
  FROM countries
	EXCEPT
SELECT name
  FROM cities
ORDER BY capital;



--Identifying languages spoken in the Middle East:
SELECT DISTINCT name
  FROM languages
WHERE code IN
  (SELECT code
   FROM countries
   WHERE region = 'Middle East')
ORDER BY name;



--Identifying the Oceanian countries that are not included in the currencies table:
SELECT country_name
  FROM Countries
  WHERE continent = 'Oceania'
  	AND code NOT IN
  	(SELECT code
  	 FROM currencies);



--Retrieving the urban area population for only capital cities.
SELECT
name, country_code, urbanarea_pop
  FROM cities
WHERE name IN
  (SELECT capital
   FROM countries)
ORDER BY urbanarea_pop DESC;

--Determining the number of languages spoken for each country, identified by the country's local name:

SELECT local_name, lang_num
  FROM countries,
  	(SELECT code, COUNT(*) AS lang_num
  	 FROM languages
  	 GROUP BY code) AS subquery
  WHERE countries.code = subquery.code
ORDER BY lang_num DESC;



--Listing the country with max inflation rate per continent:
SELECT country_name, continent, inflation_rate
  FROM countries c
	INNER JOIN economies e
	ON c.code = e.code
  WHERE year = 2015
    AND inflation_rate IN (
        SELECT MAX(inflation_rate) AS max_inf
        FROM (
             SELECT country_name, continent, inflation_rate
             FROM countries c
             INNER JOIN economies e
             ON c.code = e.code
             WHERE year = 2015) AS subquery
        GROUP BY continent);


--Calculating the average fertility rate for each region in 2015.
SELECT
region, continent, AVG(fertility_rate) AS avg_fert_rate
  FROM countries AS c
    INNER JOIN populations AS p
      ON c.code = p.country_code
  WHERE year = 2015
GROUP BY region, continent
ORDER BY avg_fert_rate;



--Determining the top 10 capital cities in Europe and the Americas in terms of a calculated percentage using city_proper_pop and metroarea_pop in cities.


SELECT TOP 10 
name, country_code,  city_proper_pop, metroarea_pop,
      city_proper_pop/metroarea_pop * 100 AS city_perc
  FROM cities 
  WHERE name IN
    -- Subquery
    (SELECT capital
     FROM countries
     WHERE (continent = 'Europe'
        OR continent LIKE '%America%'))
       AND metroarea_pop IS NOT NULL
ORDER BY city_perc DESC;