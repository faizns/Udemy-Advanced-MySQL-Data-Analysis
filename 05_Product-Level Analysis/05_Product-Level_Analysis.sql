-- -------------------------------------------------------------------
-- Product Analysis
-- -------------------------------------------------------------------

-- 1. Product Level Sales Analysis
SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS months,
    COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM orders
WHERE created_at <= '2013-01-04'
GROUP BY 1,2;

------------------------------------------------------------------------
-- 2. Product Launch Sales Analysis
SELECT
	YEAR(wp.created_at) AS yr,
    MONTH(wp.created_at) AS months,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(100*(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT wp.website_session_id)),2) AS cvr,
    ROUND(SUM(o.price_usd)/COUNT(DISTINCT wp.website_session_id),2) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) AS product_one_order,
    COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) AS product_two_order
FROM website_sessions wp
	LEFT JOIN orders o
		ON wp.website_session_id = o.website_session_id
WHERE wp.created_at BETWEEN '2012-04-01' AND '2013-04-01'
GROUP BY 1,2;


------------------------------------------------------------------------
-- 3. Product Pathing Aanlysis
-- Step 1: find relavant /product pageview with website_session_id
CREATE TEMPORARY TABLE products_pageview
SELECT 
	website_session_id,
    website_pageview_id,
    created_at,
    CASE 
		WHEN created_at < '2013-01-06' THEN 'Pre_Product_2'
		WHEN created_at >= '2013-01-06' THEN 'Post_Product_2'
        ELSE 'check logic'
	END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
	and pageview_url = '/products';

-- Step 2: find the next pageviev id that occurs after the product page view
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT
	pp.time_period,
    pp.website_session_id,
    MIN(wp.website_pageview_id) AS min_next_pageview_id
FROM products_pageview pp
	LEFT JOIN website_pageviewS wp
    ON wp.website_session_id = pp.website_session_id
    AND wp.website_pageview_id > pp.website_pageview_id
GROUP BY 1, 2;

-- Step 3: find the pageview_urlnassociated with any applicable next pageview id
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT
	sid.time_period,
    sid.website_session_id,
    wp.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id sid
	LEFT JOIN website_pageviews wp
		ON wp.website_pageview_id = sid.min_next_pageview_id;

-- Step 4: summarize
SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_page,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS perct_w_next_page,
	COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    ROUND(100*COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id), 2) AS perct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_foreverlovebear,
    ROUND(100*COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-forever-love-bear'  THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id), 2) AS perct_to_foreverlovebear
FROM sessions_w_next_pageview_url
GROUP BY 1;


------------------------------------------------------------------------
-- 4. Product Conversion Funnel
-- Step 1:
CREATE TEMPORARY TABLE session_product
SELECT
	website_session_id,
    website_pageview_id,
    pageview_url AS product_seen
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
	AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');

-- Step 2: finding pageview url funnels
SELECT DISTINCT 
	wp.pageview_url
FROM session_product sp
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id = sp.website_session_id
        AND wp.website_pageview_id > sp.website_pageview_id;

/*Result :
/cart
/shipping
/billing-2
/thank-you-for-your-order
*/

-- Step 3: Build Funnels
CREATE TEMPORARY TABLE session_product_level
WITH pgview_level_cte AS(
	SELECT
		sp.website_session_id,
		sp.product_seen,
		CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS chart_pg,
		CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_pg,
		CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_pg,
		CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thxyou_pg
	FROM session_product sp
		LEFT JOIN website_pageviews wp
			ON wp.website_session_id = sp.website_session_id
			AND wp.website_pageview_id > sp.website_pageview_id
	ORDER BY 1, wp.created_at
    )
SELECT
	website_session_id,
    product_seen,
	MAX(chart_pg) AS to_chart,
    MAX(shipping_pg) AS to_shipping,
    MAX(billing_pg) AS to_billing,
    MAX(thxyou_pg) AS to_thxyou
FROM pgview_level_cte
GROUP BY 1, 2;

-- Step 4:
SELECT
	product_seen,
    COUNT(DISTINCT CASE WHEN to_chart = 1 THEN website_session_id ELSE NULL END) AS to_chart,
    COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN to_thxyou = 1 THEN website_session_id ELSE NULL END) AS to_thxyou
FROM session_product_level
GROUP BY 1;

-- Step 4:
SELECT 
	product_seen,
    100*COUNT(DISTINCT CASE WHEN to_chart = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS chart_click_rate,
    100*COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN to_chart = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
    100*COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate,
    100*COUNT(DISTINCT CASE WHEN to_thxyou = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END) AS thxyou_click_rate
FROM session_product_level
GROUP BY 1


------------------------------------------------------------------------
-- 5. Cross Selling