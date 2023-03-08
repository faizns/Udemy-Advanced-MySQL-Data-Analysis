-- -------------------------------
-- Business Pattern & Seasonlity
-- -------------------------------

-- 1. Analyzing Seasonality
-- monthly seasons
SELECT
    MONTH(w.created_at) AS months,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(100*(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id)),2) AS cvr
FROM website_sessions w
    LEFT JOIN orders o
        ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2013-01-01'
GROUP BY MONTH(w.created_at);

-- weekly seasons
SELECT
    MIN(DATE(w.created_at)) AS week_start_date,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
    ROUND(100*(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id)),2) AS cvr
FROM website_sessions w
    LEFT JOIN orders o
        ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2013-01-01'
GROUP BY MONTH(w.created_at);


-- 2. Analyzing Business Pattern
WITH time_session_cte AS(
SELECT
    DATE(created_at) AS dt,
    WEEKDAY(created_at) AS wk,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3)

SELECT
    hr,
    ROUND(AVG(CASE WHEN wk = 0 THEN sessions ELSE NULL END),0) AS monday,
    ROUND(AVG(CASE WHEN wk = 1 THEN sessions ELSE NULL END),0) AS tuesday,
    ROUND(AVG(CASE WHEN wk = 2 THEN sessions ELSE NULL END),0) AS wednesday,
    ROUND(AVG(CASE WHEN wk = 3 THEN sessions ELSE NULL END),0) AS thursday,
    ROUND(AVG(CASE WHEN wk = 4 THEN sessions ELSE NULL END),0) AS friday,
    ROUND(AVG(CASE WHEN wk = 5 THEN sessions ELSE NULL END),0) AS saturday,
    ROUND(AVG(CASE WHEN wk = 6 THEN sessions ELSE NULL END),0) AS sunday
FROM time_session_cte
GROUP BY 1
ORDER BY 1;
