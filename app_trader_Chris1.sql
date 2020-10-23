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