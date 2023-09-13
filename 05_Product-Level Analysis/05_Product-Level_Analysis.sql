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
-- Step 1: 
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT
	CASE 
		WHEN created_at < '2013-09-25' THEN 'Pre_cross_sell'
        WHEN created_at >= '2012-01-06' THEN 'Post_cross_sell'
        ELSE 'check query!'
	END AS period,
    website_session_id AS cart_session_id,
    website_pageview_id AS cart_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart';

-- Step 2: 
CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
SELECT 
	ssc.period,
    ssc.cart_session_id,
    MIN(wp.website_pageview_id) AS pv_id_after_chart
FROM sessions_seeing_cart ssc
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id = ssc.cart_session_id
        AND wp.website_pageview_id > ssc.cart_pageview_id
GROUP BY 1, 2
HAVING
	MIN(wp.website_pageview_id) IS NOT NULL;
    

-- Step 3:
CREATE TEMPORARY TABLE pre_post_sessions_orders
SELECT
	period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
FROM sessions_seeing_cart ssc
	JOIN orders od
		ON ssc.cart_session_id = od.website_session_id;

-- Step 4:
WITH sum_cte AS(
	SELECT
		ssc.period,
		ssc.cart_session_id,
		CASE WHEN cssap.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_pg,
		CASE WHEN ppso.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
		ppso.items_purchased,
		ppso.price_usd
	FROM sessions_seeing_cart ssc
		LEFT JOIN cart_sessions_seeing_another_page cssap
			ON ssc.cart_session_id = cssap.cart_session_id
		LEFT JOIN pre_post_sessions_orders ppso
			ON ssc.cart_session_id = ppso.cart_session_id
	ORDER BY cart_session_id)
SELECT 
	period,
    COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_pg) AS click_throughs,
    SUM(placed_order) AS orders_placed,
    SUM(items_purchased) AS product_purchased,
    SUM(items_purchased)/SUM(placed_order) AS product_per_order,
    SUM(price_usd) AS revenue,
    SUM(price_usd)/SUM(placed_order) AS aov,
    SUM(price_usd)/COUNT(DISTINCT cart_session_id) AS rev_per_cart_sessions
FROM sum_cte
GROUP BY 1;


------------------------------------------------------------------------
-- 6. Product Portofolio Expansion
SELECT
	CASE 
		WHEN ws.created_at < '2013-12-12' THEN 'Pre_Birthday_Bear'
        WHEN ws.created_at >= '2013-12-12' THEN 'Post_Birthday_Bear'
        ELSE 'Check query'
	END AS period,
	100*(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id)) AS conv_rate,
	SUM(o.price_usd)/COUNT(DISTINCT o.order_id) AS avg_order,
	SUM(o.items_purchased)/COUNT(DISTINCT o.order_id) AS prod_per_order,
	SUM(o.price_usd)/COUNT(DISTINCT ws.website_session_id) AS rev_per_session
FROM website_sessionS ws
	LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1;


------------------------------------------------------------------------
-- 7. Product Refund Rates
SELECT
	YEAR (oi.created_at) AS yr,
    MONTH(oi.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN oi.order_item_id ELSE NULL END) AS p1_orders,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN oir.order_item_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN product_id = 1 THEN oi.order_item_id ELSE NULL END) AS p1_refund_rt,
	
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN oi.order_item_id ELSE NULL END) AS p2_orders,
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN oir.order_item_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN product_id = 2 THEN oi.order_item_id ELSE NULL END) AS p2_refund_rt,
	
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN oi.order_item_id ELSE NULL END) AS p3_orders,
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN oir.order_item_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN product_id = 3 THEN oi.order_item_id ELSE NULL END) AS p3_refund_rt,
	
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN oi.order_item_id ELSE NULL END) AS p4_orders,
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN oir.order_item_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN product_id = 4 THEN oi.order_item_id ELSE NULL END) AS p4_refund_rt
FROM order_items oi
	LEFT JOIN order_item_refunds oir
		ON oi.order_item_id = oir.order_item_id
WHERE oi.created_at < '2014-10-15'
GROUP BY 1,2;
