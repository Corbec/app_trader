-- The query below pulls the count of apps that are on both stores - 328 apps
SELECT COUNT(DISTINCT(psa.name))
FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON regexp_replace(psa.name, '[:|-].*', '', 'g') = regexp_replace(asa.name, '[:|-].*', '', 'g');


/*The query below pulls average rating and review count for apps on both stores. 

App Store apps have an average rating of 4.09 and average review count of 151,597.
Play Store apps have and average rating of 4.34 and average review count of 4,091,043.
*/

SELECT
	ROUND(AVG(asa.rating), 2) AS avg_asa_rating,
	ROUND(AVG(CAST(asa.review_count AS numeric))) AS avg_asa_review_count,
	ROUND(AVG(psa.rating), 2) AS avg_psa_rating,
	ROUND(AVG(psa.review_count)) AS avg_psa_review_count
FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name;
/*WHERE psa.rating > 4
AND asa.rating > 4
AND psa.review_count > 10000
AND CAST(asa.review_count AS numeric) > 10000
ORDER BY asa.rating DESC;*/


-- The query below shows the average rating and review count by genre for app store apps that are on both stores.
SELECT DISTINCT(asa.primary_genre),
	ROUND(AVG(asa.rating), 2) AS avg_asa_rating,
	ROUND(AVG(CAST(asa.review_count AS numeric))) AS avg_asa_review_count
FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name
	GROUP BY asa.primary_genre
	ORDER BY avg_asa_rating DESC;
	
-- The query below shows the average rating and review count by genre for play store apps that are on both stores.
SELECT psa.category,
	ROUND(AVG(psa.rating), 2) AS avg_psa_rating,
	ROUND(AVG(psa.review_count)) AS avg_psa_review_count
FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name
GROUP BY psa.category
ORDER BY avg_psa_rating DESC;
	
/* All app names on app store in the Games primary genre that have a rating above the average rating
for app store apps that are also in play store. Also gives rating and price. */

-- **Last thing I was working on 8 Oct 2020**

SELECT asa.name, asa.rating, asa.price
FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name
WHERE asa.primary_genre = 'Games'
AND asa.rating > (SELECT AVG(asa.rating) FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name)
GROUP BY asa.name, asa.rating, asa.price
ORDER BY asa.rating DESC;


-- Average rating and review count by category in the play store.
SELECT genres,
	ROUND(AVG(rating), 2) AS avg_rating,
	ROUND(AVG(review_count), 2) AS avg_review_count
FROM play_store_apps
GROUP BY genres
ORDER BY avg_rating DESC;

-- Average rating and review count by category in app store.
SELECT primary_genre,
	ROUND(AVG(rating), 2) AS avg_rating,
	ROUND(AVG(review_count::numeric), 2) AS avg_review_count
FROM app_store_apps
GROUP BY primary_genre
ORDER BY avg_rating DESC;

/* First attempt to CTE something to pull all of the apps in one category from both tables at once.*/

WITH genre_games AS (
		SELECT asa.name,
			asa.price::money,
			asa.rating AS app_store_rating,
			ROUND(AVG(asa.review_count::numeric)) AS app_store_avg_review,
			ROUND((asa.rating * 2) + 1) AS asa_life_exp,
			psa.price::money,
			psa.rating AS play_store_rating,
			ROUND(AVG(psa.review_count)) AS play_store_avg_review,
			ROUND((psa.rating * 2) + 1) AS psa_life_exp
		FROM play_store_apps AS psa
			INNER JOIN
			app_store_apps AS asa
			ON regexp_replace(psa.name, '[:-].*', '') = regexp_replace(asa.name, '[:-].*', '')
		WHERE LOWER(asa.primary_genre) LIKE 'game%'
		AND LOWER(psa.category) LIKE 'game%'
		AND asa.rating > (SELECT AVG(asa.rating) FROM play_store_apps AS psa
			INNER JOIN
			app_store_apps AS asa
			ON regexp_replace(psa.name, '[:-].*', '') = regexp_replace(asa.name, '[:-].*', ''))
		AND psa.rating > (SELECT AVG(psa.rating) FROM play_store_apps AS psa
			INNER JOIN
			app_store_apps AS asa
			ON regexp_replace(psa.name, '[:-].*', '') = regexp_replace(asa.name, '[:-].*', ''))
		GROUP BY asa.name, asa.price, app_store_rating, psa.price, play_store_rating
		ORDER BY asa.rating DESC;
		)
SELECT


-- Trying to look at all apps that are on both tables and present like the previous query

Select
	asa.name AS name,
	asa.price::money AS price,
	asa.rating AS rating,
	ROUND(AVG(asa.review_count::numeric)) AS avg_review,
	ROUND((asa.rating * 2) + 1) AS life_exp
FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name
/*WHERE asa.rating > (SELECT AVG(asa.rating) FROM play_store_apps AS psa
		INNER JOIN
		app_store_apps AS asa
		ON psa.name = asa.name)*/
GROUP BY asa.name, asa.price, asa.rating
UNION ALL
SELECT
	psa.name AS name,
	psa.price::money AS price,
	psa.rating AS rating,
	ROUND(AVG(psa.review_count)) AS review,
	ROUND((psa.rating * 2) + 1) AS life_exp	
FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name
/*WHERE psa.rating > (SELECT AVG(psa.rating) FROM play_store_apps AS psa
	INNER JOIN
	app_store_apps AS asa
	ON psa.name = asa.name)*/
GROUP BY psa.name, psa.price, psa.rating
ORDER BY ;

-- Final query for top ten with cost/revenue calculated
SELECT asa.name,
			--asa
			asa.primary_genre,
			asa.rating AS app_store_rating,
			ROUND(AVG(asa.review_count::numeric)) AS app_store_avg_review,
			ROUND((asa.rating * 2) + 1) AS asa_life_exp,
			CASE WHEN asa.price >= 1 THEN asa.price * 10000
            ELSE 10000 END AS asa_purchase_price,
			-- asa_life_cost = asa_purchase_price * asa_life_exp
			CASE WHEN asa.price >= 1 THEN (asa.price * 10000) + ((asa.rating * 2) + 1) * 12000
			ELSE 10000 + ((asa.rating * 2) + 1) * 12000 END AS asa_life_cost,
			-- asa_life_rev = asa_life_exp * 30000
			((asa.rating * 2) + 1) * 30000 AS asa_life_rev,
			--psa
			psa.category,
			psa.rating AS play_store_rating,
			ROUND(AVG(psa.review_count)) AS play_store_avg_review,
			ROUND((psa.rating * 2) + 1) AS psa_life_exp,
			CASE WHEN REPLACE(psa.price,'$','')::decimal > 0.99
			THEN (REPLACE(psa.price,'$','')::decimal) * 10000
            ELSE 10000 END AS psa_purchase_price,
			-- psa_life_cost = psa_purchase_price * psa_life_exp
			CASE WHEN REPLACE(psa.price,'$','')::decimal > 0.99
			THEN ((REPLACE(psa.price,'$','')::decimal) * 10000) + ((psa.rating * 2) + 1) * 12000
            ELSE 10000 + ((psa.rating * 2) + 1) * 12000 END AS psa_life_cost,
			-- psa_life_rev = psa_life_exp * 30000
			((psa.rating * 2) + 1) * 30000 AS psa_life_rev,
			-- life_profit = (asa_life_rev + psa_life_rev - asa_life_cost - psa_life_cost) - (((psa.rating * 2) + 1) * 12000)
			(((asa.rating * 2) + 1) * 30000) +
			(((psa.rating * 2) + 1) * 30000) -
			(CASE WHEN asa.price >= 1 THEN (((asa.price * 10000) + ((asa.rating * 2) + 1) * 12000) - (((psa.rating * 2) + 1) * 12000))
			ELSE (10000 + ((asa.rating * 2) + 1) * 12000) - (((psa.rating * 2) + 1) * 12000) END) -
			(CASE WHEN REPLACE(psa.price,'$','')::decimal > 0.99
			THEN ((REPLACE(psa.price,'$','')::decimal) * 10000) + ((psa.rating * 2) + 1) * 12000
            ELSE 10000 + ((psa.rating * 2) + 1) * 12000 END) AS life_profit
		FROM play_store_apps AS psa
			INNER JOIN
			app_store_apps AS asa
			ON psa.name = asa.name
		WHERE LOWER(asa.primary_genre) LIKE 'game%'
		AND LOWER(psa.category) LIKE 'game%'/*
		AND asa.rating > (SELECT AVG(asa.rating) FROM play_store_apps AS psa
			INNER JOIN
			app_store_apps AS asa
			ON psa.name = asa.name)
		AND psa.rating > (SELECT AVG(psa.rating) FROM play_store_apps AS psa
			INNER JOIN
			app_store_apps AS asa
			ON psa.name = asa.name)*/
		GROUP BY asa.name, app_store_rating, play_store_rating,
		asa.price, psa.price, asa.primary_genre, psa.category
		ORDER BY life_profit DESC;





