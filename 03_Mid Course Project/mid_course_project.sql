-- -------------------
-- MID COURSE PROJECT
-- -------------------
use mavenfuzzyfactory


/*
1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?
*/

SELECT 
    YEAR(w.created_at),
    MONTH(w.created_at) AS months,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(100*(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id)),2) AS percent_cvr
FROM website_sessions w
    LEFT JOIN orders o
		ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-11-27'
	AND w.utm_source = 'gsearch'
GROUP BY 1, 2



/* 
2. Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately.
 */
 
SELECT 
    YEAR(w.created_at) AS years,
    MONTH(w.created_at) AS months,
    -- nonbrand
    COUNT(DISTINCT CASE WHEN w.utm_campaign = 'nonbrand' THEN w.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN w.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS nonbrand_orders,
    ROUND(100*(COUNT(DISTINCT CASE WHEN w.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)/
        COUNT(DISTINCT CASE WHEN w.utm_campaign = 'nonbrand' THEN w.website_session_id ELSE NULL END)),2) AS percent_nonbrand_cvr,
    -- brand
    COUNT(DISTINCT CASE WHEN w.utm_campaign = 'brand' THEN w.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN w.utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders,
    ROUND(100*(COUNT(DISTINCT CASE WHEN w.utm_campaign = 'brand' THEN o.order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN w.utm_campaign = 'brand' THEN w.website_session_id ELSE NULL END)),2) AS percent_brand_cvr
FROM website_sessions w
	LEFT JOIN orders o
		ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-11-27'
	AND w.utm_source = 'gsearch'
    AND w.utm_campaign IN ('nonbrand', 'brand')
GROUP BY 1, 2



/*
3. While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type?
*/

-- find device type
SELECT 
    DISTINCT device_type
FROM website_sessions
-- there are mobile and desktop

-- calculate session and order by device
SELECT
    YEAR(w.created_at) AS years,
    MONTH(w.created_at) AS months,
    -- mobile
    COUNT(DISTINCT CASE WHEN w.device_type = 'mobile' THEN w.website_session_id ELSE NULL END) AS mobile_sessions_nonb,
    COUNT(DISTINCT CASE WHEN w.device_type = 'mobile' THEN o.order_id ELSE NULL END) AS mobile_orders_nonb,
    ROUND(100*(COUNT(DISTINCT CASE WHEN w.device_type = 'mobile' THEN o.order_id ELSE NULL END)/
        COUNT(DISTINCT CASE WHEN w.device_type = 'mobile' THEN w.website_session_id ELSE NULL END)),2) AS percent_mobile_nonb_cvr,
     -- desktop
    COUNT(DISTINCT CASE WHEN w.device_type = 'desktop' THEN w.website_session_id ELSE NULL END) AS desktop_sessions_nonb,
    COUNT(DISTINCT CASE WHEN w.device_type = 'desktop' THEN o.order_id ELSE NULL END) AS desktop_orders_nonb,
    ROUND(100*(COUNT(DISTINCT CASE WHEN w.device_type = 'desktop' THEN o.order_id ELSE NULL END)/
        COUNT(DISTINCT CASE WHEN w.device_type = 'desktop' THEN w.website_session_id ELSE NULL END)),2) AS percent_desktop_nonb_cvr
FROM website_sessions w
	LEFT JOIN orders o
		ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-11-27'
	AND w.utm_source = 'gsearch'
    AND w.utm_campaign = 'nonbrand'
GROUP BY 1, 2



/*
4. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/

-- see traffic we're getting
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at < '2012-10-27'
-- there are gsearch and b search

/*
From the output we can see:
- If source, campaign and http referral is NULL, then it is direct traffic - users type in the website link in the browser's search bar.
- If source and campaign is NULL, but there is http referral, then it is organic search - coming from search engine and not tagged with paid parameters.
*/

SELECT
	YEAR(created_at) AS years,
    MONTH(created_at) AS montsh,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY 1,2


/*
5. Could you pull session to order conversion rates, by month?
*/

SELECT 
	YEAR(w.created_at),
    MONTH(w.created_at) AS months,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(100*(COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id)),2) AS percent_cvr
FROM website_sessions w
    LEFT JOIN orders o
		ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-11-27'
GROUP BY 1, 2



/*
6. For the gsearch lander test, please estimate the revenue that test earned us 
(Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value) 
- Revenue from Jun 19 – Jul 28 vs same period
*/

-- Find lander-1 test was created
SELECT 
    MIN(created_at),
    MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1'
-- its created at 2012-06-19 00:35:54 and pageview_id start at 23504

-- Find the first website_pageview_id, retricting to home and lander-1
CREATE TEMPORARY TABLE landing_page_test
SELECT
    p.website_session_id,
    MIN(p.website_pageview_id) AS min_pageview_id,
    p.pageview_url AS landing_page
FROM website_pageviews p
    JOIN website_sessions s
		ON s.website_session_id = p.website_session_id
        AND s.created_at < '2012-07-28'
        AND s.utm_source = 'gsearch'
        AND s.utm_campaign ='nonbrand'
        AND p.website_pageview_id >= 23504 -- = at 2012-06-19
WHERE p.pageview_url IN ('/home', '/lander-1')
GROUP BY 1, 3

-- Join the result with order_id and aggregat for session, order, and cvr
WITH session_order_landing AS
(
    SELECT 
        t.website_session_id,
        t.landing_page,
        o.order_id
    FROM landing_page_test t
        LEFT JOIN orders o
            ON t.website_session_id = o.website_session_id
)
SELECT 
    landing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(100*(COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id)),2) AS percent_cvr
FROM session_order_landing
GROUP BY 1

/*
-- cvr 3.18 for /home
-- cvr 4.06 for /landr-1
-- - incremental difference 1.08%
*/

-- find most recent pageview for gsearch nonbrand where traffic was sent to /home
SELECT
    MAX(s.website_session_id)
FROM website_sessions s
	LEFT JOIN website_pageviews p
		ON s.website_session_id = p.website_session_id
WHERE s.created_at < '2012-11-27'
	AND s.utm_source = 'gsearch'
	AND s.utm_campaign = 'nonbrand'
    AND p.pageview_url = '/home'
    -- result: the recent website_session_id = 17145

SELECT
    COUNT(website_session_id) AS session_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND website_session_id > 17145 
    -- result: there are 22972 session since the test

/*
 TOTAL SESSION SINCE TEST = 22972
 Incremental of order = 1.08%
	22972 X 1.08% = 248
    - estimated at least 248 incremental orders since 29 Jul using \lander-1 page
    - Jul to Nov --> 4 months
    - 248 / 4 = 64 additional order/month
*/



/*
7. For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each 
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28)
*/

-- find all pageview_url from two pages (Jun 19 – Jul 28)
SELECT DISTINCT
    p.pageview_url
FROM website_pageviews p
    LEFT JOIN website_sessions s
		ON p.website_session_id = s.website_session_id
WHERE p.created_at < '2012-11-27'
	AND s.utm_source = 'gsearch'
	AND s.utm_campaign = 'nonbrand'
    AND p.website_pageview_id >= 23504 
    
-- Select all pageviews for relevant session
CREATE TEMPORARY TABLE pageview_levels
WITH pageviews_cte AS
(
	SELECT
        s.website_session_id,
        p.created_at,
        p.pageview_url,
        CASE WHEN p.pageview_url = '/home' THEN 1 ELSE 0 END AS home_p,
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
	WHERE s.created_at BETWEEN '2012-06-19' AND '2012-07-28'
        AND p.website_pageview_id >= 23504 
	    AND s.utm_source = 'gsearch'
	    AND s.utm_campaign ='nonbrand'
	    AND p.pageview_url IN ('/home', '/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
    ORDER BY 1, 2
)
SELECT
    website_session_id, 
    MAX(home_p) AS home_p,
    MAX(lander1_p) AS lander1_p,
    MAX(product_p) AS product_p,
    MAX(mrfuzzy_p) AS mrfuzzy_p,
    MAX(chart_p) AS chart_p,
    MAX(shipping_p) AS shipping_p,
    MAX(billing_p) AS billing_p,
    MAX(thankyou_p) AS thankyou_p
FROM pageviews_cte
GROUP BY 1

-- Aggregate data to assess funnel performance
CREATE TEMPORARY TABLE session_page
SELECT 
    CASE 
        WHEN home_p = 1 THEN 'saw_home_page'
        WHEN lander1_p = 1 THEN 'saw_lander_page'
        ELSE 'not_identify'
    END AS segment,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_p = 1 THEN website_session_id ELSE NULL END) AS to_product,
    COUNT(DISTINCT CASE WHEN mrfuzzy_p = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN chart_p = 1 THEN website_session_id ELSE NULL END) AS to_chart,
    COUNT(DISTINCT CASE WHEN shipping_p = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_p = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_p = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM pageview_levels
GROUP BY 1

-- Agregate for conversion/click rate
SELECT
    segment,
    sessions,
    ROUND(100*(to_product / sessions),2) AS segment_clickrate,
    ROUND(100*(to_mrfuzzy / to_product),2) AS product_clikrate,
    ROUND(100*(to_chart / to_mrfuzzy),2) AS mrfuzzy_clikrate,
    ROUND(100*(to_shipping / to_chart),2) AS chart_clickrate,
    ROUND(100*(to_billing / to_shipping),2) AS shipping_clickrate,
    ROUND(100*(to_thankyou / to_billing),2) AS billing_clikrate
FROM session_page



/*
8. I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test 
(Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact.
*/

-- Find billing-2 test was created
SELECT 
    MIN(created_at),
    MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/billing-2'
-- make sense

WITH billing_cte AS
(
    SELECT
		p.website_session_id,
		p.pageview_url,
		o.price_usd
	FROM website_pageviews p
		LEFT JOIN orders o
			ON p.website_session_id = o.website_session_id
	WHERE p.created_at BETWEEN '2012-09-10' AND '2012-11-10'
		AND p.pageview_url IN ('/billing', '/billing-2')
)
SELECT 
    pageview_url AS billing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page
FROM billing_cte
GROUP BY 1

/*
 rev billing   = 22.83
 rev billing-2 = 31.34
 lift		   = 8.51 / pageview
*/

-- calculate session past month
SELECT 
    COUNT(website_session_id) AS sessions
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-27' AND '2012-11-27'
    AND pageview_url IN ('/billing', '/billing-2')

/*
 total session a month  = 1193
 value billing test 	= 1193 X 8.51 
						= 10152,43
*/
