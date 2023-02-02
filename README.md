# **Udemy - Advanced SQL : MySQL Data Analysis and Business Intelligence**

## 📂 **Introduction**
### **The Situation**
You’ve just been hired as an **eCommerce Database Analyst** for **Maven Fuzzy Factory**, an online retailer which has just launched their first product.

### **The Brief**
As a member of the startup team, you will work with the *CEO*, the *Head of Marketing*, and the *Website Manager* to help steer the business.

You will analyze and optimize marketing channels, measure and test website conversion performance, and use data to understand the impact of new product launches. 

### **The Objectives**
**Use SQL to:**
- Access and explore the Maven Fuzzy Factory database
- Become the data expert for the company, and the go-to person for mission critical analyses
- Analyze and optimize the business’ marketing channels, website, and product portfolio <br>
<br>

---

## 📂 **Overview Database**
We will be working with six related tables, which contain eCommerce data about:
- Website Activity
- Products
- Orders and Refunds

We'll use MySQL to understand how customers access and interact with the site, analyze landing page performance and conversion, and explore product-level sales.

### **Entity Relationship Database**

<details>
  <summary>Click to view ERD</summary>

<p align="center">
  <kbd><img width="800" alt="erd" src="https://user-images.githubusercontent.com/115857221/216096971-49eb3432-6cdf-49c4-afcc-78e386d6cb50.png"> </kbd> <br>
</p>

</details>

<br>

---

## 📂 **Analyzing Traffic Sources**
### 📌 **Business Concept: Traffic Source Analysis**
Traffic source analysis is about understanding **where your customers are 
coming from** and **which channels are driving the highest quality traffic.**

### 📌 **Common Use Cases: Traffic Source Analysis**
- Analyzing search data and shifting budget towards the engines, campaigns or keywords driving the strongest conversion rates
- Comparing user behavior patterns across traffic sources to inform creative and messaging strategy
- Identifying opportunities to eliminate wasted spend or scale high-converting traffic

### **Task**
### **1. Finding Top Traffic Sources**

<p align="center">
  <kbd><img width="330" alt="email1_1" src="https://user-images.githubusercontent.com/115857221/216097426-509b18d3-7fc6-4bc2-ba07-fff86f586ee3.png"> </kbd> <br>
</p>
<br>

**Steps :**
- Breakdown of sessions by UTM source, campaign and referring domain
- Filter results up to sessions before **'2012-04-12'** and group results by **utm_source**, **utm_campaign** and **http_referer**
<br>

**Query :**
```sql
SELECT 
	utm_source,
	utm_campaign,
	http_referer,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1, 2, 3
ORDER BY 4 DESC
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="500" alt="tabel_top_traffic" src="https://user-images.githubusercontent.com/115857221/216097751-9cf81722-0923-48ce-87cb-67c4c43e1a15.png"> </kbd> <br>
 
  1 — Most sessions came from gsearch nonbrand campaign traffic. Drill deeper to explore potential optimization opportunities.
</p>

<br>

<p align="center">
  <kbd><img width="330" alt="email1_2" src="https://user-images.githubusercontent.com/115857221/216097918-e6348a69-05b2-4e59-8ad6-b754076673e9.png"> <br>
</p>
<br>

### **2. Traffic Conversion Rate**

<p align="center">
  <kbd><img width="330" alt="email1_3" src="https://user-images.githubusercontent.com/115857221/216098062-374ab27d-37be-4de3-b002-d1a1767b17d6.png"> </kbd> <br>
</p>
<br>

**Steps :**
- Calculate CVR from **session(COUNT)** to **order(COUNT)**. If CVR < 4% need to reduce bids, otherwise if CVR >= 4% can increase bids to drive more volume
- Filter sessions **< '2012-04-12'**, **utm_source = 'gsearch'** and **utm_campaign = 'nonbrand'**
<br>

**Query :**
```sql
SELECT
	COUNT(DISTINCT w.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_CVR
FROM website_sessions w
	LEFT JOIN orders o
		ON o.website_session_id = w.website_session_id
WHERE w.created_at < '2012-04-14'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
```
<br>

**Result :**
<p align="center">
  <kbd><img width="380" alt="tabel_traffic_cvr" src="https://user-images.githubusercontent.com/115857221/216098251-06f32653-8c9c-478a-83f5-0d286efbdb70.png"> </kbd> <br>
  
  2 — The conversion rate is less than 4%, which is 2.88%, hence we have to reduce bids. We should to monitor impact of bid reduction and analyze performance trending by device type in order to refine bidding strategy.
</p>

<br>

<p align="center">
  <kbd><img width="330" alt="email1_4" src="https://user-images.githubusercontent.com/115857221/216098576-b5d77b1b-b1b6-4036-9196-b5828c308a9d.png"> </kbd> <br>
</p>
<br>

### 📌 **Business Concept: Bid Optimization**
Analyzing for bid optimization is about **understanding the value of various 
segments of paid traffic, so that you can optimize your marketing budget**.

### 📌 **Common Use Cases: Bid Optimization**
-  Using conversion rate and revenue per click analyses to figure out how much you should spend per click to acquire customers
- Understanding how your website and products perform for various subsegments of traffic (i.e. mobile vs desktop) to optimize within channels 
- Analyzing the impact that bid changes have on your ranking in the auctions, and the volume of customers driven to your site<br>
<br>

### **3. Traffic Source Trending**

<p align="center">
  <kbd> <img width="330" alt="email1_5" src="https://user-images.githubusercontent.com/115857221/216099554-e346086f-ed31-424a-9228-a312830672ba.png"> </kbd> <br>
</p>
<br>

**Steps :**
- Calculate trend and impact on sessions for gsearch nonbrand campaign after bidding down on Apr 15, 2021
- Filter to **< '2012-05-10'**, **utm_source = 'gsearch'**, **utm_campaign = 'nonbrand'**
<br>

**Query :**
```sql
SELECT
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions 
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at)
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="230" alt="tabel_traffic_trending" src="https://user-images.githubusercontent.com/115857221/216099721-18749403-05ba-4a2c-b562-ed10076282e1.png"></kbd> <br>
  
  3 — The sessions after 2021-04-15 have dropped. Continue to monitor session volume. We could make the campaigns more efficient to increase volume again, by maximising volume at the lowest possible bid.
</p>

<br>

<p align="center">
  <kbd><img width="330" alt="email1_6" src="https://user-images.githubusercontent.com/115857221/216099857-425a6456-57e6-4ab3-9b4a-62db953f5c98.png"> </kbd> <br>
</p>
<br>

### **4. Traffic Source Bid Optimization**

<p align="center">
  <kbd> <img width="330" alt="email1_7" src="https://user-images.githubusercontent.com/115857221/216099972-b8f55eb5-a1c6-4c5b-9d33-369544050738.png"> </kbd> <br>
</p>
<br>

**Steps :**
- Calculate the conversion rate from session to order by device type
<br>

**Query :**
```sql
SELECT
	w.device_type,
	COUNT(DISTINCT w.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_CVR
FROM website_sessions w
	LEFT JOIN orders o
		ON o.website_session_id = w.website_session_id
WHERE w.created_at < '2012-05-11'
	AND w.utm_source = 'gsearch'
	AND w.utm_campaign = 'nonbrand'
GROUP BY 1
ORDER BY 4 DESC
```
<br>

**Result :**
<p align="center">
  <kbd><img width="480" alt="tabel_bid_opz" src="https://user-images.githubusercontent.com/115857221/216100125-db73b60e-23b2-4491-9233-a72886b31827.png"> </kbd> <br>
  
  4 — Desktop bids were driving nearly 4% of the conversion rate, so we should transfer the paid traffic spent to the desktop channel instead.
</p>

<br>

<p align="center">
  <kbd> <img width="330" alt="email1_8" src="https://user-images.githubusercontent.com/115857221/216100248-c15d75af-7f7b-4dd5-8be9-9262689b9eb8.png"> </kbd> <br>
</p>
<br>

### **5. Traffic Source Segment Trending**

<p align="center">
  <kbd> <img width="330" alt="email1_9" src="https://user-images.githubusercontent.com/115857221/216100406-763878cb-f233-45a4-985c-7b95e8d3679f.png"> </kbd> <br>
</p>
<br>

**Steps :**
- Calculate (with pivot)  weekly session trends for both desktop and mobile after bidding up on the desktop channel on 2012-05-19
- Filter to **between '2012-04-15' to '2012-06-19'**, **utm_source = 'gsearch'**, **utm_campaign = 'nonbrand'**
<br>

**Query :**
```sql
SELECT
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_session,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_session
FROM website_sessions
WHERE created_at < '2012-06-09'
	AND created_at > '2012-04-15'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at)
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="405" alt="tabel_segm_tren" src="https://user-images.githubusercontent.com/115857221/216100559-cb7142a5-8022-4ad5-b183-ab005bc5212d.png"> </kbd> <br>
  
  5 — Desktop volume increased after bidding on 2012-05-19, but mobile volume dropped dramatically. Focusing on desktops was able to optimize spending efficiently. Continue to monitor device-level volume and be aware of the impact bid levels has. Continue to monitor conversion performance at the device-level to optimize spend.
</p>

<br>

<p align="center">
  <kbd> <img width="330" alt="email1_10" src="https://user-images.githubusercontent.com/115857221/216100702-a9f3a551-0558-48fe-a10e-76a07ab8445c.png"> </kbd> <br>
</p>
<br>

---

## 📂 **Analyzing Website Performance**
### 📌 **Business Concept: Analyzing Top Website Content**
Website content analysis is about **understanding which pages are seen the most by your users, to identify where to focus on improving your business.**

### 📌 **Common Use Cases: Analyzing Top Website Content**
- Finding the most-viewed pages that customers view on your site
- Identifying the most common entry pages to your website – the first thing a user sees
- For most-viewed pages and most common entry pages, understanding how those pages perform for your business objectives

### **Task**
### **1. Identifying Top Website Pages**

<p align="center">
  <kbd> <img width="320" alt="1_1" src="https://user-images.githubusercontent.com/115857221/216283478-342e8610-dbab-4cc7-8676-4c804b6ce553.png"> </kbd> <br>
</p>
<br>

**Steps :**
- Find page view count by page view url, filter date **< 2012-06-09** and **sort session count descencing**

<br>

**Query :**
```sql
SELECT 
	pageview_url,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="340" alt="2_1" src="https://user-images.githubusercontent.com/115857221/216283629-dc9bbe0d-7452-4fcf-bff7-b180ae9b72b9.png"> </kbd> <br>
  
  1 — homepage, products, and original Mr Fuzzy are the most-viewed website pages with the highest traffic.
<br>

<p align="center">
  <kbd> <img width="320" alt="1_2" src="https://user-images.githubusercontent.com/115857221/216283964-ed9ab99d-5cf5-46a0-b850-928cf605d599.png"> </kbd> <br>
</p>
<br>

### **2. Identifying Top Entry Pages**

<p align="center">
  <kbd> <img width="320" alt="2_1" src="https://user-images.githubusercontent.com/115857221/216284683-d2007343-81c8-4617-a97b-6e059298fa7a.png"> </kbd> <br>
</p>
<br>

Analyze the performance of each of our top pages to look for improvement opportunities.

**Steps :**
- Create cte to find the first page landed/entry for each session, filter date to **< 2012-06-12**
- Count session based on landing page
<br>

**Query :**
```sql
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
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="400" alt="2_2" src="https://user-images.githubusercontent.com/115857221/216285092-9a6e31ee-c775-4eae-ab27-5266447596bb.png"> </kbd> <br>
 
  2 — Homepage is the top landing page. Analyze landing page performance, for the homepage specifically.
</p>
<br>

<p align="center">
  <kbd> <img width="320" alt="2_2" src="https://user-images.githubusercontent.com/115857221/216285417-b81f7f3d-ea65-428a-87a2-552628001f82.png"> </kbd> <br>
</p>
<br>

### 📌 **Business Concept: Landing Page Performance and Testing**
Landing page analysis and testing is about **understanding the performance of your key landing pages and then testing to improve your results**

### 📌 **Common Use Cases: Landing Page Performance and Testing**
- Identifying your top opportunities for landing pages – high volume pages with higher than expected bounce rates or low conversion rates
- Setting up A/B experiments on your live traffic to see if you can improve your bounce rates and conversion rates 
- Analyzing test results and making recommendations on which version of landing pages you should use going forward

<br>

### **3. Calculation Bounce Rate**

<p align="center">
  <kbd><img width="320" alt="3_1" src="https://user-images.githubusercontent.com/115857221/216287301-22de4f59-d3ea-48a2-b270-c5d50d2b5523.png"> </kbd> <br>
</p>
<br>

Analyze landing page performance, for the homepage specifically.<br>
**Bounce Rate** = Total one-pages visits / Total entrance visits

**Steps :**
- Find the first `website_pageview_id` for relavant seasson with filter to date **< '2012-06-14'** and `pageview_url` is **'/home'**
- Count page views for each session to identify bounces (`website_pageview_id` = 1)
- Summarize by counting total session and bounced session
<br>

**Query :**
```sql
-- Find the first website_pageview_id for relavant seasson with filter
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

```
<br>

<p align="center">
  <kbd><img width="420" alt="2_3" src="https://user-images.githubusercontent.com/115857221/216287908-588cb15d-3c95-48ca-b6ab-3f67f139b2eb.png"> </kbd> <br>
</p>
<br>

```sql
-- Count page views for each session to identify bounces (website_pageview_id = 1)
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
```
<br>

<p align="center">
  <kbd> <img width="420" alt="2_4" src="https://user-images.githubusercontent.com/115857221/216288218-056dab36-7793-403b-8c06-deaf45b8e2a4.png"> </kbd> <br>
</p>
<br>

```sql
-- Summarize by counting total session and bounced session
SELECT
	COUNT(DISTINCT l.website_session_id) AS total_session,
	COUNT(DISTINCT b.website_session_id) AS bounced_session,
	COUNT(DISTINCT b.website_session_id)/COUNT(DISTINCT l.website_session_id) AS bounce_rate
FROM landing_page_home l
	LEFT JOIN bounced_home b
		ON l.website_session_id = b.website_session_id
GROUP BY l.landing_page
```
<br>
    
**Result :**

<p align="center">
  <kbd><img width="400" alt="2_5" src="https://user-images.githubusercontent.com/115857221/216288295-75296b78-66d4-4854-be22-25ed5c059b44.png"> </kbd> <br>
  
  3 — A 60% bounce rate is pretty high especially for paid search.
</p>
<br>
    
<p align="center">
  <kbd> <img width="320" alt="3_2" src="https://user-images.githubusercontent.com/115857221/216287438-9fd9bdb3-f851-4cf0-9947-6c47b21c5a46.png"> </kbd> <br>
</p>
<br>

### **4. Analyzing Landing Page Tests**

<p align="center">
  <kbd> <img width="340" alt="4_1" src="https://user-images.githubusercontent.com/115857221/216292400-0d7da5e8-0df1-4959-93fa-b5cc6423159c.png"> </kbd> <br>
</p>
<br>
    
Help Morgan measure and analyze a new page that she thinks will improve performance, and analyze the results of an A/B split test against the homepage. A/B test on **/lander-1** and **/home** for **gsearch nonbrand** campaign.

**Steps :**
- Find when **/lander-1** was created on the website by use either date or pageview id to limit the results
- Find the first `website_pageview_id` for relavant season with filter by date periode, between **'2012-06-01' and '2012-08-31'**
- Count page views for each session to identify bounces (`website_pageview_id` = 1) each landing page
- Summarize by counting total session and bounced session each landing page
<br>

**Query :**
    
```sql
-- Find when `/lander-1` was created on the website
SELECT 
	MIN(created_at),
	MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';
```
<br>
    
<p align="center">
  <kbd> <img width="300" alt="4_landing1" src="https://user-images.githubusercontent.com/115857221/216292895-3a362f38-c40b-4ede-a85e-20bd456e7663.png"> </kbd> <br>
</p>
<br>

```sql
-- Find the first website_pageview_id for relavant season with filter
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
```
<br>
    
<p align="center">
  <kbd> <img width="400" alt="4_step2" src="https://user-images.githubusercontent.com/115857221/216293673-eb7c327b-fe5f-49f1-854a-2ca6e2b5aa02.png"> </kbd> <br>
</p>
<br>

```sql
-- Count page views for each session to identify bounces (website_pageview_id = 1) each landing page
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
```
<br>
    
<p align="center">
  <kbd> <img width="410" alt="4_step3" src="https://user-images.githubusercontent.com/115857221/216294022-8eea6345-41e2-4821-88cb-4499ae7c5224.png"> </kbd> <br>
</p>
<br>

```sql
-- Summarize by counting total session and bounced session each landing page
SELECT
	l.landing_page,
	COUNT(DISTINCT l.website_session_id) AS total_session,
	COUNT(DISTINCT b.website_session_id) AS bounced_session,
	COUNT(DISTINCT b.website_session_id)/COUNT(DISTINCT l.website_session_id) AS bounce_rate
FROM landing_page_test l
LEFT JOIN bounced_test b
	ON l.website_session_id = b.website_session_id
GROUP BY l.landing_page
```
<br>

**Result :**

<p align="center">
  <kbd><img width="450" alt="4_step4" src="https://user-images.githubusercontent.com/115857221/216294535-4e2eeeae-ae4f-4085-871f-f5345b277d92.png"> </kbd> <br>
  
  4 — The Lander page has a lower bounce rate than home page. Fewer customers have bounced on the lander page.
</p>
<br>

<p align="center">
  <kbd><img width="320" alt="4_21" src="https://user-images.githubusercontent.com/115857221/216322693-d543db2e-8167-457f-b9fa-1a818abb4786.png"></kbd> <br>
</p>
<br>

### **5. Landing Page Trend Analysis**

<p align="center">
  <kbd><img width="320" alt="5_trean" src="https://user-images.githubusercontent.com/115857221/216322809-680a70e7-c69f-41a1-b35a-3d9850f2ad12.png"></kbd> <br>
</p>
<br>

**Steps :**
- Pull paid **gsearch nonbrand** campaign traffic on **/home** and **/lander-1** pages, trended weekly since 2012-06-01 and the bounce rates.
- Find the first `website_pageview_id` for relavant season with select created_at and filter
- Count page views for each session to identify bounces (`website_pageview_id` = 1)
- Summarize sessions, bounced sessions and bounce rate by week
<br>

**Query :**

```sql
-- Find the first website_pageview_id for relavant season with select created_at and filter
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
```
<br>

<p align="center">
  <kbd><img width="520" alt="2_9" src="https://user-images.githubusercontent.com/115857221/216323058-5aa92d2c-7b24-4b0d-8c9b-53d7f81415cc.png"></kbd> <br>
</p>
<br>

```sql
-- Count page views for each session to identify bounces (website_pageview_id = 1)
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
```
<br>

<p align="center">
  <kbd> <img width="430" alt="2_10" src="https://user-images.githubusercontent.com/115857221/216323269-955e646e-a055-4df2-bd85-24046280040c.png"></kbd> <br>
</p>
<br>

```sql
SELECT
	MIN(DATE(l.created_at)) AS week_start,
	COUNT(DISTINCT b.website_session_id)/COUNT(DISTINCT l.website_session_id) AS bounce_rate,
	COUNT(DISTINCT CASE WHEN l.landing_page = '/home' THEN l.website_session_id ELSE NULL END) AS home_sessions,
	COUNT(DISTINCT CASE WHEN l.landing_page = '/lander-1' THEN l.website_session_id ELSE NULL END) AS lander_sessions
FROM landing_page_trend l
	LEFT JOIN bounced_trend b
		ON l.website_session_id = b.website_session_id
GROUP BY WEEK(l.created_at)
```
<br>

**Result :**

<p align="center">
  <kbd><img width="460" alt="2_11" src="https://user-images.githubusercontent.com/115857221/216323498-7e8e942c-d6d0-42a9-9ba0-fe0a7a9a8433.png"></kbd> <br>
 
 5 — All traffict was directed to home until 2012-06-17, and starting on 2012-08-05, all traffic was directed to lander-1. There has been improvement as the bounce rate decreased from more than 60% to about 50%. The /lander-1 page changes are operating as well.
</p>
<br>

<p align="center">
  <kbd><img width="320" alt="4_2" src="https://user-images.githubusercontent.com/115857221/216292267-76b43c20-a6fb-4775-8074-e0e638b9885e.png"> </kbd> <br>
</p>
<br>

### 📌 **Business Concept: Analyzing and Testing Conversion Funnels**
Conversion funnel analysis is about **understanding and optimizing each step of your user’s experience on their journey toward purchasing your products**

### 📌 **Common Use Cases: Analyzing and Testing Conversion Funnels**
- Identifying the most common paths customers take before purchasing your products
- Identifying how many of your users continue on to each next step in your conversion flow, and how many users abandon at each step
- Optimizing critical pain points where users are abandoning, so that you can convert more users and sell more products

When we perform conversion funnel analysis, we will look at each step in our conversion flow to see how many customers drop off and how many continue on at each step.<br> 
<br>

### **6. Building Conversion Funnels**

<p align="center">
  <kbd><img width="320" alt="6_build_1" src="https://user-images.githubusercontent.com/115857221/216328646-610a8a3a-005a-4187-b2a6-ff806976391e.png"></kbd> <br>
</p>
<br>

Build Conversion Funnels for **gsearch nonbrand** traffic from **/lander-1 to /thank you page**.

**Steps :**
- Select all pageviews for relevant session, create pageview level in temporary table, filter to date between **'2012-08-05' and '2012-09-05'**
- Aggregate data to assess funnel performance
- Agregate data to be click rate
<br>

**Query :**

```sql
-- Select all pageviews for relevant session, create pageview level in temporary table
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
```
<br>

<p align="center">
  <kbd><img width="650" alt="2_13" src="https://user-images.githubusercontent.com/115857221/216328860-723e918a-557f-477c-bae3-149187bb2335.png"></kbd> <br>
</p>
<br>

```sql
-- Aggregate data to assess funnel performance
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

```
<br>

<p align="center">
  <kbd><img width="650" alt="2_14" src="https://user-images.githubusercontent.com/115857221/216329062-c3f1aa07-b916-4d3e-b469-4953884bb06c.png"></kbd> <br>
</p>
<br>

```sql
-- Agregate for click rate
SELECT
	to_product / sessions AS lander_click_rate,
	to_mrfuzzy / to_product AS product_click_rate,
	to_chart / to_mrfuzzy AS mrfuzzy_click_rate,
	to_shipping / to_chart AS chart_click_rate,
	to_billing / to_shipping AS shipping_click_rate,
	to_thankyou / to_billing AS billing_click_rate
FROM session_page
```
<br>

**Result :**

<p align="center">
  <kbd><img width="800" alt="landerclick" src="https://user-images.githubusercontent.com/115857221/216329497-a8d9638a-edac-4d50-adc0-36e8ad003bdc.png"></kbd> <br>
  
   6 — Lander-1, mrfuzzy, and billing pages has lowest clickthrough rate. More information on billing page will make customers more comfortable to insert their credit card information.
</p>
<br>

<p align="center">
  <kbd> <img width="320" alt="6_build_2" src="https://user-images.githubusercontent.com/115857221/216329608-df32ff00-3079-44df-beb9-30b8a7c87176.png"></kbd> <br>
</p>
<br>

### **7. Analyzing Conversion Funnel Test**

<p align="center">
  <kbd> <img width="320" alt="last1" src="https://user-images.githubusercontent.com/115857221/216333885-8beb2f85-dc83-4ed0-bd81-2b20be31c517.png"> </kbd> <br>
</p>
<br>

Help Morgan analyze the billing page test she plans to run.<br>
Analyze Conversion Funnel Tests for /billing and new /billing-2 pages.<br>

**Steps :**
- Find first time '/billing-2 was seen
- Select all pageviews for relevant session
- Aggregate and summarize the conversion rate
<br>

**Query :**

```sql
-- Find first time '/billing-2 was seen
SELECT 
	MIN(created_at) AS first_created,
	MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'
```
<br>

<p align="center">
  <kbd><img width="300" alt="7_1" src="https://user-images.githubusercontent.com/115857221/216334085-d029c06e-9500-416c-ab62-dfa1b82ecbe4.png"></kbd> <br>
</p>
<br>

```sql
-- Select all pageviews for relevant session
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
-- Aggregate and summarize the conversion rate
SELECT 
	b.pageview_url AS billing_version,
	COUNT(DISTINCT b.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT b.website_session_id) AS session_to_order_rate
FROM billing_test b
	LEFT JOIN orders o
		ON b.website_session_id = o.website_session_id
GROUP BY 1
```
<br>

<p align="center">
  <kbd> <img width="400" alt="7_2" src="https://user-images.githubusercontent.com/115857221/216334236-59f2ffc6-6cc9-48e0-ae68-6e70e286d271.png"></kbd> <br>
</p>
<br>

**Result :**

<p align="center">
  <kbd> <img width="480" alt="7_3" src="https://user-images.githubusercontent.com/115857221/216334300-ed94ec91-d7aa-4d0a-aab4-907ad9ad22ac.png"> </kbd> <br>
  
  7 — /billing-2 page has session to order converstion rate at 62%, much better than billing page at 46%.
</p>
<br>

<p align="center">
  <kbd> <img width="320" alt="last2" src="https://user-images.githubusercontent.com/115857221/216333957-6095576c-55e7-4c04-9d3e-fdc150b0b7f0.png"> </kbd> <br>
</p>
<br>

## 📂 **MID COURSE PROJECT**
