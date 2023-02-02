-- -------------------------------
-- Analyzing Website Performance
-- -------------------------------

use mavenfuzzyfactory;

-- 1. Identifying Top Website Pages
SELECT 
	pageview_url,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC



-- 2. Identifying Top Entry Pages
WITH first_entry AS (
	SELECT
		website_session_id,
		MIN(website_pageview_id) AS first_pageview
	FROM website_pageviews
	WHERE created_at < '2012-06-12'
	GROUP BY 1 
    )
SELECT 
	w.pageview_url AS landing_page,
	COUNT(f.website_session_id) AS session_hitting_this_landing_page
FROM first_entry f
	LEFT JOIN website_pageviews w
		ON f.first_pageview = w.website_pageview_id
GROUP BY 1
ORDER BY 1



-- 3. Calculating Bounce Rates
-- a. Find the first website_pageview_id for relavant seasson with filter
CREATE TEMPORARY TABLE landing_page_home
SELECT
	p.website_session_id,
	MIN(p.website_pageview_id) AS first_landing_page,
	p.pageview_url AS landing_page
FROM website_pageviews p
	JOIN website_sessions s
		ON s.website_session_id = p.website_session_id
		AND s.created_at < '2012-06-14'		-- filter by date
WHERE pageview_url = '/home'				-- filter pageview_url home
GROUP BY 1

-- b. Count page views for each session to identify bounces (website_pageview_id = 1)
CREATE TEMPORARY TABLE bounced_home
SELECT
	l.website_session_id,
	l.landing_page,
	COUNT(p.website_pageview_id) AS count_of_pageview
FROM landing_page_home l
	LEFT JOIN website_pageviews p
		ON l.website_session_id = p.website_session_id
GROUP BY 1,2 
HAVING COUNT(p.website_pageview_id) = 1

-- c. Summarizing by counting total session and bounced session
SELECT
	COUNT(DISTINCT l.website_session_id) AS total_session,
	COUNT(DISTINCT b.website_session_id) AS bounced_session,
	COUNT(DISTINCT b.website_session_id)/COUNT(DISTINCT l.website_session_id) AS bounce_rate
FROM landing_page_home l
	LEFT JOIN bounced_home b
		ON l.website_session_id = b.website_session_id
GROUP BY l.landing_page



-- 4. Analyzing Landing Page Tests
-- a. Find when `/lander-1` was created on the website
SELECT 
	MIN(created_at),
	MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- b. Find the first website_pageview_id for relavant season with filter
CREATE TEMPORARY TABLE landing_page_test
SELECT
	p.website_session_id,
	MIN(p.website_pageview_id) AS first_landing_page,
	p.pageview_url AS landing_page
FROM website_pageviews p
	JOIN website_sessions s
		ON s.website_session_id = p.website_session_id
		AND s.created_at BETWEEN '2012-06-19' AND '2012-07-28'  -- lander-1 displayed to user at 2012-06-19
		AND utm_source = 'gsearch'
		AND utm_campaign ='nonbrand'
		AND p.pageview_url IN ('/home', '/lander-1')
GROUP BY 1, 3

-- c. Count page views for each session to identify bounces (website_pageview_id = 1) each landing page
CREATE TEMPORARY TABLE bounced_test
SELECT
	l.website_session_id,
	l.landing_page,
	COUNT(p.website_pageview_id) AS count_of_page_viewed
FROM landing_page_test l
	LEFT JOIN website_pageviews p
		ON l.website_session_id = p.website_session_id
GROUP BY 1, 2
HAVING COUNT(p.website_pageview_id) = 1

-- d. Summarizing by counting total session and bounced session each landing page
SELECT
	l.landing_page,
	COUNT(DISTINCT l.website_session_id) AS total_session,
	COUNT(DISTINCT b.website_session_id) AS bounced_session,
	COUNT(DISTINCT b.website_session_id)/COUNT(DISTINCT l.website_session_id) AS bounce_rate
FROM landing_page_test l
	LEFT JOIN bounced_test b
		ON l.website_session_id = b.website_session_id
GROUP BY l.landing_page



-- 5. Landing Page Trend Analysis
-- a. Find the first website_pageview_id for relavant season with select created_at and filter
CREATE TEMPORARY TABLE landing_page_trend
SELECT
	p.created_at,
	p.website_session_id,
	p.pageview_url AS landing_page,
	MIN(p.website_pageview_id) AS first_landing_page
FROM website_pageviews p
	JOIN website_sessions s
		ON s.website_session_id = p.website_session_id
		AND s.created_at BETWEEN '2012-06-01' AND '2012-08-31' 
		AND utm_source = 'gsearch'
		AND utm_campaign ='nonbrand'
		AND p.pageview_url IN ('/home', '/lander-1')
GROUP BY 1, 2, 3

-- b. Count page views for each session to identify bounces (website_pageview_id = 1)
CREATE TEMPORARY TABLE bounced_trend
SELECT
	l.website_session_id,
	l.landing_page,
	COUNT(p.website_pageview_id) AS count_of_page_viewed
FROM landing_page_trend l
	LEFT JOIN website_pageviews p
		ON l.website_session_id = p.website_session_id
GROUP BY 1, 2
HAVING COUNT(p.website_pageview_id) = 1

-- c. summarizing with pivot
SELECT
	MIN(DATE(l.created_at)) AS week_start,
	COUNT(DISTINCT b.website_session_id)/COUNT(DISTINCT l.website_session_id) AS bounce_rate,
	COUNT(DISTINCT CASE WHEN l.landing_page = '/home' THEN l.website_session_id ELSE NULL END) AS home_sessions,
	COUNT(DISTINCT CASE WHEN l.landing_page = '/lander-1' THEN l.website_session_id ELSE NULL END) AS lander_sessions
FROM landing_page_trend l
	LEFT JOIN bounced_trend b
		ON l.website_session_id = b.website_session_id
GROUP BY WEEK(l.created_at)



-- 6. Building Conversion Funnels
-- a. Select all pageviews fr relevant session, create pageview level in temporary table
CREATE TEMPORARY TABLE pageview_levels
WITH pageviews_cte AS
(
	SELECT
		s.website_session_id,
		p.created_at,
		p.pageview_url,
		CASE WHEN p.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_p,
		CASE WHEN p.pageview_url = '/products' THEN 1 ELSE 0 END AS product_p,
		CASE WHEN p.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_p,
		CASE WHEN p.pageview_url = '/cart' THEN 1 ELSE 0 END AS chart_p,	
		CASE WHEN p.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_p,
		CASE WHEN p.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_p,
		CASE WHEN p.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_p
	FROM website_sessions s
		LEFT JOIN website_pageviews p
			ON s.website_session_id = p.website_session_id
	WHERE 
		p.created_at BETWEEN '2012-08-05' AND '2012-09-05'
		AND s.utm_source = 'gsearch'
		AND s.utm_campaign ='nonbrand'
		AND p.pageview_url IN ('/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
	ORDER BY 1, 2
)

SELECT
	website_session_id, 
	MAX(lander1_p) AS lander1_p,
	MAX(product_p) AS product_p,
	MAX(mrfuzzy_p) AS mrfuzzy_p,
	MAX(chart_p) AS chart_p,
	MAX(shipping_p) AS shipping_p,
	MAX(billing_p) AS billing_p,
	MAX(thankyou_p) AS thankyou_p
FROM pageviews_cte
GROUP BY 1

SELECT * FROM pageview_levels

-- b. Aggregate data to assess funnel performance
CREATE TEMPORARY TABLE session_page
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_p = 1 THEN website_session_id ELSE NULL END) AS to_product,
	COUNT(DISTINCT CASE WHEN mrfuzzy_p = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN chart_p = 1 THEN website_session_id ELSE NULL END) AS to_chart,
	COUNT(DISTINCT CASE WHEN shipping_p = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_p = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_p = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM pageview_levels

-- c. Agregate for click rate
SELECT
	to_product / sessions AS lander_click_rate,
	to_mrfuzzy / to_product AS product_click_rate,
	to_chart / to_mrfuzzy AS mrfuzzy_click_rate,
	to_shipping / to_chart AS chart_click_rate,
	to_billing / to_shipping AS shipping_click_rate,
	to_thankyou / to_billing AS billing_click_rate
FROM session_page



-- 7. Analyzing Conversion Funnel Test
-- a. Find first time '/billing-2 was seen
SELECT 
	MIN(created_at) AS first_created,
	MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'
-- 53550 first_pv_id

-- b. Select all pageviews for relevant session
WITH billing_test AS
(
	SELECT
		s.website_session_id,
		p.pageview_url
	FROM website_sessions s
		LEFT JOIN website_pageviews p
			ON s.website_session_id = p.website_session_id
	WHERE p.website_pageview_id >= 53550 -- first pageview when '/billing-2' was created
		AND s.created_at < '2012-11-10'
		AND p.pageview_url IN ('/billing', '/billing-2')
)
-- c. Aggregate and summarise the conversion rate
SELECT 
	b.pageview_url AS billing_version,
	COUNT(DISTINCT b.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT b.website_session_id) AS session_to_order_rate
FROM billing_test b
	LEFT JOIN orders o
		ON b.website_session_id = o.website_session_id
GROUP BY 1
