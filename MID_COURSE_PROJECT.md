# **MID COURSE PROJECT**

## 📂 **Introduction**
### 📌 **The Situation**
Maven Fuzzy Factory has been live for ~8 months, and your CEO is due to present company performance metrics to the board next week. You’ll be the one tasked with preparing relevant metrics to show the company’s promising growth.

### 📌 **The Objective**
**Use SQL to :** <br>
Extract and analyze website traffic and performance data from the Maven Fuzzy Factory database to quantify the company’s growth, and to tell the story of how you have been able to generate that growth.

<p align="center">
  <kbd> <img width="340" alt="msg" src="https://user-images.githubusercontent.com/115857221/216864559-d2204574-62c9-4b96-b819-20ac205987d9.png"> </kbd> <br>
</p>
<br>

- Tell the story of your company’s growth, using trended performance data
- Use the database to explain some of the details around your growth story, and quantify the revenue impact of some of your wins
- Analyze current performance, and use that data available to assess upcoming opportunities
<br>

---

## 📂 **QUESTION**
#### 💡*1 - Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?*

**Steps :**
- Extract month from date, calculate relavant sessions and orders based source is gsearch
- Aggregate to find conversion rate for every month sessions
<br>

**Query :**
```sql
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
```
<br>

**Result :**
<p align="center">
  <kbd><img width="450" alt="Q1" src="https://user-images.githubusercontent.com/115857221/216864745-5cbd3d25-5bcc-482f-b0e9-f3a4ca7fbfb8.png"></kbd> <br>
  
  1 — Session to orders growth remained stable and saw a steadily increase from March, 3.23% to November, 4.20%.
</p>
<br>

---

#### 💡*2 - Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.*

**Steps :**
- Extract month from date, calculate relavant sessions and orders based on source is gsearch
- Aggregate to find conversion rate for every month based on campaign
<br>

**Query :**
```sql
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
```
<br>

**Result :**
<p align="center">
  <kbd><img width="850" alt="Q2" src="https://user-images.githubusercontent.com/115857221/216865217-9d6da421-9d2a-49f9-ae3e-46d6139738a1.png"></kbd> <br>
  
  2 — We can see that the percentage of conversion rate of nonbrand campaign steadily grows from 3% to 4%. But, the brand campaign has fluctuating conversion rates/trends every month.
</p>
<br>

---

#### 💡*3 - While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.*

**Steps :**
- Extract month from date, calculate relavant sessions and orders based on source is gsearch
- Aggregate to find nonbrand conversion rate for every month based on device type
<br>

**Query :**
```sql
-- find device type
SELECT DISTINCT device_type
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
```
<br>

**Result :**
<p align="center">
  <kbd><img width="1000" alt="Q3" src="https://user-images.githubusercontent.com/115857221/216865814-2bbd3e05-2104-4ad1-867c-ca76ba161d7a.png"></kbd> <br>
  
  3 — The majority of the conversion rate contribution came from desktop users with a good growth from 4.43% in March, it dropped in April to 3.51%, but continued to increase in the following months to reach 5% in November. The contribution with mobile devices is quite low and there is a need to investigate this, it could be that the web accessed through mobile is not user friendly.
</p>
<br>

---

#### 💡*4 - I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?*

**Step :**
- Find the various utm sources and refers to see the traffic we're getting
- Extract months and aggregate to find each session based on the last output condition
<br>

**Query :**
```sql
-- see traffic we're getting
SELECT DISTINCT
    utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at < '2012-10-27'
```
<br>

<p align="center">
  <kbd><img width="400" alt="Q4-1" src="https://user-images.githubusercontent.com/115857221/216866191-03157525-c34b-45ab-8521-0fa3299ceeb5.png"></kbd> <br>
</p>
<br>

From the output we can see:
- Source of traffic from gsearch and bsearch
- Based on the output :
    - If source, campaign, and http referral is NULL, then it is direct traffic: users type in the website link in the browser's search bar
    - If source and campaign is NULL, but there is http referral, then it is organic search: coming from search engine and not tagged with paid parameters
<br>

```sql
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
```
<br>

**Result :**
<p align="center">
  <kbd><img width="800" alt="Q4-2" src="https://user-images.githubusercontent.com/115857221/216866427-379e23d6-ef69-4d1b-8810-ec46aba72180.png"></kbd> <br>
  
  4 — Gsearh is the dominant traffic among other channels. Not only gsearch, each channel also experiences session growth every month.
</p>
<br>

---

#### 💡*5 - I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?*

**Step :**
- Extract month from date, calculate relavant sessions and orders
- Aggregate to find conversion rate for every month sessions
<br>

**Query :**
```sql
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
```
<br>

**Result :**
<p align="center">
  <kbd><img width="450" alt="Q5" src="https://user-images.githubusercontent.com/115857221/216867519-5feaf0b4-9c02-4215-bcf4-db407019c987.png"></kbd> <br>
  
  5 — The conversion rate in March was 3.19% and decreased in the next month. The conversion rate started to increase steadily in the following month until it reached 4.40% in November.
</p>
<br>

---

#### 💡*6 - For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)*

**Step :**
- Find lander-1 test was created and the first website_pageview_id, retricting to home and lander-1
- Create summary, join the result with order_id and aggregat for session, order, and cvr
- Find most recent pageview for gsearch nonbrand where traffic was sent to /home and estimate revenue that test earned from lander-1
<br>

**Query :**
```sql
-- Find lander-1 test was created
SELECT 
    MIN(created_at),
    MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1'
-- it was created at 2012-06-19 00:35:54 and pageview_id start at 23504

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
```
<br>

<p align="center">
  <kbd><img width="400" alt="Q6 1" src="https://user-images.githubusercontent.com/115857221/216869912-746b0d5a-014e-4197-ba61-1581f932be96.png"></kbd> <br>
</p>
<br>


```sql
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
```
<br>

**Result :**

<p align="center">
  <kbd><img width="400" alt="Q6 2" src="https://user-images.githubusercontent.com/115857221/216870310-e6951b46-801c-4e88-923e-eb097c348474.png"> </kbd> <br>
  
  6 — The home page conversion rate is 3.18% and lander-1 is 4.06%. The incremental difference in website performance is 1.08% using lander-1.
</p>
<br>

```sql
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
```
<br>

<p align="center">
  <kbd><img width="200" alt="Q6 3" src="https://user-images.githubusercontent.com/115857221/216870579-20ae4d55-cc71-40bb-bc69-7303e0d52567.png"> </kbd> <br>
</p>
<br>

- We can estimate the increase in revenue from the increase in orders :
    - 22972 session x 1.08% (incremental % of order) = 248
    - So, estimated at least 248 incremental orders since 29 Jul using the lander-1 page
- Calculate monthly increase (July - November) : 
    - 248 / 4 = 64 additional order/month
<br>

---

#### 💡*7 - I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?*

**Step :**
- Check pageview_url from two pages was created and create summary all pageviews for relevant session
- Categorise website sessions under `segment` by 'saw_home_page' or 'saw_lander_page' and aggregate data to assess funnel performance
- Convert aggregated result to percentage of click rate
<br>

**Query :**
```sql
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
```
<br>

<p align="center">
  <kbd><img width="200" alt="Q7 1" src="https://user-images.githubusercontent.com/115857221/216871503-56b23bc7-6c46-4d52-ab3c-c000649c4e81.png"> </kbd> <br>
</p>
<br>

```sql
-- Create summary all pageviews for relevant session
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

```
<br>

<p align="center">
  <kbd><img width="800" alt="Q7 2" src="https://user-images.githubusercontent.com/115857221/216871805-e7f06ea1-44d7-409c-b3d5-fd59d452640b.png"></kbd> <br>
</p>
<br>

```sql
-- Categorise website sessions under `segment` by 'saw_home_page' or 'saw_lander_page'
-- Aggregate data to assess funnel performance
CREATE TEMPORARY TABLE session_page
    SELECT 
        CASE 
            WHEN home_p = 1 THEN 'saw_home_page'
            WHEN lander1_p = 1 THEN 'saw_lander_page'
            ELSE 'can_not_identify'
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
```
<br>

<p align="center">
  <kbd><img width="800" alt="Q7 3" src="https://user-images.githubusercontent.com/115857221/216872031-d1c1ea3d-a586-4b7d-af60-3067a9b846c1.png"></kbd> <br>
</p>
<br>

```sql
-- Convert aggregated website sessions to percentage of click rate by dividing by total sessions
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
```
<br>

**Result :**
<p align="center">
  <kbd><img width="10000" alt="Q7 4" src="https://user-images.githubusercontent.com/115857221/216872174-806c2ef9-2be4-4637-9a0a-e3c7b74fc81c.png"></kbd> <br>
  
  7 — Lander-1 page has a better click trough rate than the home page.
</p>
<br>

---

#### 💡*8 - I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact.*

**Step :**
- Check billing-2 test was created
- Calculate or aggregate the sessions and `price_usd` for /billing and /billing-2
- Calculate billing page sessions for the past month (Sep 27 – Nov 27) and estimate revenue
<br>

**Query :**

```sql
-- Find billing-2 test was created
SELECT 
    MIN(created_at),
    MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/billing-2'

-- it was cheates at 2012-09-10 00:13:05 billing 2 page view start from 53550
-- that's make sense (Sep 10 – Nov 10)

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

```
<br>

**Result :**

<p align="center">
  <kbd><img width="400" alt="Q8 1" src="https://user-images.githubusercontent.com/115857221/216872732-449b6f78-abd7-4cd2-9053-36b7320fa6f3.png"></kbd> <br>
  
  8 — billing-2 has a larger revenue per billing page contribution with a lift of 8.51 dollars/pageview
</p>
<br>


```sql
-- calculate billing page sessions for the past month
SELECT 
    COUNT(website_session_id) AS sessions
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-27' AND '2012-11-27'
    AND pageview_url IN ('/billing', '/billing-2')
```
<br>

<p align="center">
  <kbd><img width="200" alt="Q8 2" src="https://user-images.githubusercontent.com/115857221/216872912-55eb860b-85f6-4bb0-b9f4-6d6e32d42b9f.png"></kbd> <br>
</p>
<br>

- We can calculate from the past month :
    - Total session a month  = 1193
    - Value billing test = 1193 X 8.51 (lift) = 10152.43
- So there are 1193 sessions and with the increase of 8.51 dolar average revenue per session with a positive impact 10152.43 dolar increase in revenue.<br>
<br>

---
