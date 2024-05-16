-- Which nation has participated in all of the olympic games
SELECT region
FROM olympics a
JOIN noc b
	ON a.noc = b.noc
GROUP BY region
HAVING COUNT(DISTINCT games) = (SELECT COUNT(DISTINCT games) FROM olympics)
ORDER BY COUNT(DISTINCT games) DESC


-- Total number of nations who participated in each of the olympics game. 

SELECT games, COUNT(DISTINCT region) AS cnt
FROM olympics a
JOIN noc b
	ON a.noc = b.noc
GROUP BY games	
ORDER BY games 

-- How many unique athletes have won a gold medal in the Olympics

SELECT COUNT(DISTINCT name) AS Gold_medal_athletes
FROM olympics
WHERE medal = 'Gold'

-- Which Sports were just played only once in the olympics? and Order the output by Sports. output should include number of games.

SELECT sport, COUNT(games) AS no_of_games
FROM olympics
GROUP BY sport
HAVING COUNT(DISTINCT games)=1

--Fetch the total number of sports played in each olympic games. Order by no of sports by descending.

SELECT games, COUNT(DISTINCT sport) AS no_of_sports
FROM olympics
GROUP BY games
ORDER BY COUNT(sport) DESC

-- Fetch oldest athlete to win a gold medal

SELECT name
FROM olympics
WHERE medal = 'Gold'
ORDER BY age DESC
LIMIT 1

-- Top 5 athletes who have won the most gold medals. Order the results by gold medals in descending.

SELECT name, team, COUNT(medal) AS no_of_gold_medals
FROM olympics
WHERE medal = 'Gold'
GROUP BY name, team
ORDER BY COUNT(medal) DESC
LIMIT 5 

-- Top 5 athletes who have won the most medals. Order the results by gold medals in descending.

SELECT name, team, COUNT(medal) AS no_of_medals
FROM olympics
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY name, team
ORDER BY COUNT(medal) DESC
LIMIT 5 

-- Top 5 most successful countries in olympics. Success is defined by no of medals won.

SELECT region AS country, COUNT(1) AS no_of_medals
FROM olympics a
JOIN noc b
	ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')	
GROUP BY region
ORDER BY COUNT(medal) DESC
LIMIT 5 

-- In which Sport/event, India has won highest medals.

SELECT sport AS highest_medal_sport
FROM olympics a
JOIN noc b
	ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze') AND region = 'India'
GROUP BY sport
ORDER BY COUNT(medal) DESC
LIMIT 1

/* Break down all olympic games where india won medal for Hockey and 
how many medals in each olympic games and order the result by number of medals in descending.*/

SELECT games, COUNT(medal) AS no_of_medals
FROM olympics a
JOIN noc b
	ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze') AND region = 'India' AND sport = 'Hockey'
GROUP BY games
ORDER BY COUNT(medal) DESC

-- Which sports have the most events in the Olympics?
SELECT sport
FROM olympics
GROUP BY sport
ORDER BY COUNT(sport) DESC
LIMIT 1

-- How many times has each country participated in the Olympics?

SELECT region, COUNT(DISTINCT games) AS no_of_participations
FROM olympics a
JOIN noc b
	ON a.noc=b.noc
GROUP BY region
ORDER BY COUNT(DISTINCT games) DESC

-- How many athletes are there from each country?

SELECT region, COUNT(DISTINCT name) AS no_of_athletes
FROM olympics a
JOIN noc b
	ON a.noc=b.noc
GROUP BY region	
ORDER BY no_of_athletes DESC

-- What was the first year each country participated in the Olympics?

SELECT region, MIN(year) AS first_year
FROM olympics a
JOIN noc b
	ON a.noc=b.noc
GROUP BY region	
ORDER BY region	

-- How many medals have been won by male and female athletes in each sport

SELECT sport, SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS males, 
			SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) AS females
FROM olympics 
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY sport

-- How has the number of medals won by USA changed over the years

WITH cte AS 
(SELECT year, COUNT(medal) AS curr
FROM olympics a
JOIN noc b
	ON a.noc=b.noc 
WHERE region = 'USA'
		AND medal IN ('Gold','Silver','Bronze')
GROUP BY year)

SELECT *, (curr - LAG(curr) OVER())*100/LAG(curr) OVER() AS medals_pct_change
FROM cte 

-- Which athletes have competed in multiple sports

SELECT name, STRING_AGG(DISTINCT sport,',') AS sports
FROM olympics
GROUP BY name
HAVING COUNT(DISTINCT sport) > 1

-- How many gold, silver, and bronze medals has each country won

SELECT region,
		SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
		SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
		SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
FROM olympics a
JOIN noc b
	ON a.noc=b.noc
GROUP BY region
ORDER BY region, gold DESC, silver DESC, bronze DESC

-- Which countries have participated in the Olympics but have never won a medal?

SELECT region
FROM olympics a
LEFT JOIN noc b
	ON a.noc=b.noc
GROUP BY region
HAVING SUM(CASE WHEN medal IN ('Gold','Silver','Bronze') THEN 1 ELSE 0 END) = 0

-- What is the medal efficiency ratio (medals won per athlete) for each country

SELECT 
    b.region, 
    SUM(CASE WHEN a.medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS medals,
    COUNT(DISTINCT a.name) AS athletes,
    ROUND(COALESCE(SUM(CASE WHEN a.medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END)::numeric / COUNT(DISTINCT a.name), 0),2) AS medal_efficiency_ratio
FROM olympics a
JOIN noc b ON a.noc = b.noc
GROUP BY b.region
ORDER BY medal_efficiency_ratio DESC;

-- What is the average age of medal winners for each sport and country

SELECT sport, region, ROUND(AVG(age::numeric),0) AS avg_age
FROM olympics a
JOIN noc b 
	ON a.noc = b.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY sport, region

-- Which countries are the most dominant in each sport based on the number of medals won

WITH cte AS
(SELECT sport, region, COUNT(medal) AS cnt
FROM olympics a
JOIN noc b 
	ON a.noc = b.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')	
GROUP BY sport, region),	
cte2 AS 
(SELECT *, DENSE_RANK() OVER(PARTITION BY sport ORDER BY cnt DESC) AS rnk
FROM cte)
SELECT sport, region AS dominant_country
FROM cte2 
WHERE rnk=1



	
	
	
	