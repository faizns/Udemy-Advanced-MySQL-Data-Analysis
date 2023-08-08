## 📂 **Analysis for Channel Management**
### 📌 **Business Concept: Channel Portofolio Optimization**
Analyzing a portfolio of marketing channels is about **bidding efficiently and using data to maximize the effectiveness of your marketing budget.**

### 📌 **Common Use Cases: Channel Portofolio Optimization**
- Understanding which marketing channels are driving the most sessions and orders through your website
- Understanding differences in user characteristics and conversion performance across marketing channels
- Optimizing bids and allocating marketing spend across a multi-channel portfolio to achieve maximum performance
<br>

### **Task**
### **1. Analyzing Channel Portofolios**
**Channel Portofolio Analysis** : to identify traffic coming from multiple marketing channels, we will use utm parameters stored in our sessions table

<p align="center">
  <kbd> <img width="320" alt="1 channel portofolio" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/720a17d8-6200-47f7-954d-ef40d14eedbb"></kbd> <br>
</p>
<br>

**Steps :**
- Pull weekly sessions from 22 Aug - 29 Nov for gsearch and bsearch, utm campaign nonbrand
- week_start_date | total_session | gsearch_session | bsearch_session

<br>

**Query :**
```sql
SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS total_session,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END)  AS gsearch_session,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END)  AS bsearch_session
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-29'
    AND utm_source IN ('gsearch', 'bsearch')
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);
```
<br>

**Result :**
<p align="center">
  <kbd>  <img width="400" alt="1" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/13c1960a-30e6-4ed5-870e-f073b759b6e5"> </kbd> <br>
  1 — bsearch tends to get roughly a third the traffic of gsearch
</p>
<br>

### **2. Comparing Channel Characteristics**

<p align="center">
  <kbd><img width="320" alt="2 comparing" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/a0838523-777c-4eb6-a469-a57ad09acf1b"></kbd> <br>
</p>
<br>

**Steps :**
- Pull mobile session from 22 Aug - 30 Nov for gsearch and bsearch, utm campaign nonbrand
- utm_source | total_session | mobile_session | percentage_mobile_session

<br>

**Query :**
```sql
SELECT
    utm_source,
    COUNT(DISTINCT website_session_id) AS total_session,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_session,
    ROUND(100*(COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)),2)
        AS percentage_mobile_session
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
    AND utm_source IN ('gsearch', 'bsearch')
    AND utm_campaign = 'nonbrand'
GROUP BY 1;
```
<br>

**Result :**
<p align="center">
  <kbd>  <img width="500" alt="2" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/4ff35644-5f15-4417-b6a3-8fdb96669439"></kbd> <br>
  2 — Most of the traffic coming from mobile with gsearch campaigns
</p>
<br>


### **3. Cross-Channel Bid Optimization**

<p align="center">
  <kbd>  <img width="320" alt="3 cross chanel" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/4722a5f5-9745-428b-89d6-15a7ad13194b"> </kbd> <br>
</p>
<br>


**Steps :**
- Based on device type, pull gsearch and bsearch nonbrand conversion rates (order/session) from 22 Aug - 18 Sep
- device_type | utm_source | total_session | tota_order | percentage_cvr


<br>

**Query :**
```sql
SELECT
    device_type,
    utm_source,
    COUNT(DISTINCT w.website_session_id) AS total_session,
    COUNT(DISTINCT order_id) AS total_order,
    ROUND(100*(COUNT(DISTINCT order_id)/COUNT(DISTINCT w.website_session_id)),2)
        AS percentage_cvr
FROM website_sessions w
	LEFT JOIN orders o
		ON w.website_session_id = o.website_session_id
WHERE w.created_at BETWEEN '2012-08-22' AND '2012-09-18'
    AND utm_source IN ('gsearch', 'bsearch')
    AND utm_campaign = 'nonbrand'
GROUP BY 1,2;
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="500" alt="3" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/1d9d7852-5b07-4da7-9ac4-3c257bfa0a7b"></kbd> <br>
  3 — gsearch campaign has a higher conversion rate in both desktop and mobile compared to bsearch campaign
</p>

<br>

### **4. Channel Portofolio Trends**

<p align="center">
  <kbd> <img width="320" alt="4  trend" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/7b1f56b8-e8b4-47c6-beab-c605d6fae8ba"> </kbd> <br>
</p>

<br>


**Steps :**
- Pull weekly sessions gsearch and bsearch nonbrand sessions by device type from 4 Nov - 22 Dec
- week_start_date | total_session | gd_session | bd_session | percentage_gd_bd | gm_session | bm_session | percentage_gm_bm

<br>

**Query :**
```sql
SELECT
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT website_session_id) AS total_session,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS gd_session,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS bd_session,
	ROUND(100*(COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)),2) AS percentage_gd_bd,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS gm_session,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS bm_session,
	ROUND(100*(COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)),2) AS percentage_gm_bm
FROM website_sessions
WHERE created_at BETWEEN '2012-11-04' AND '2012-12-22'
	AND utm_source IN ('gsearch', 'bsearch')
	AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="800" alt="4" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/536a2f66-642f-402d-bec2-1ee76855ccf6"></kbd> <br>
  4 — The desktop bsearch sessions stayed at 4% of gsearch sessions but dropped after bids were lowered in weeks 2-3 of December. This drop could also be influenced by events like Black Friday, Cyber Monday, and other seasonal factors. For mobile sessions, there was a significant decline after bid reduction, but it varied during December, making it difficult to determine if the decline was solely due to reduced bids or other factors too.
</p>

<br>


### 📌 **Business Concept: Analyzing Direct Traffic**
Analyzing your branded or direct traffic is about **keeping a pulse on how well your brand is doing with consumers, and how well your brand drives business.**

### 📌 **Common Use Cases: Analyzing Direct Traffic**
- Identifying how much revenue you are  generating from direct traffic – this is high  margin revenue without a direct cost of customer acquisition
- Understanding whether or not your paid traffic is generating a “halo” effect, and promoting additional direct traffic
- Assessing the impact of various initiatives on  how many customers seek out your business
<br>

### **5. Analyzing Free Channels**
**Free Traffic Analysis** : to identify traffic coming to your site that you are not paying for with marketing campaigns, we will again turn to our utm params.
<br>

<p align="center">
  <kbd><img width="320" alt="5  free channel" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/afbf096d-75d9-4020-ba95-8b9abc4d693a"> </kbd> <br>
</p>

<br>


**Steps :**
- Analyze organic search, direct type in, and paid brand or nonbrand sessions
- Pull monthly organic search, direct type in, and paid brand sessions, present in % of paid nonbrand.

<br>

**Query :**
```sql
SELECT DISTINCT
	CASE 
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
		WHEN utm_campaign = 'brand' THEN 'paid_brand'
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	END AS channel_group,
	utm_source,
	utm_campaign,
	http_referer
FROM website_sessions
WHERE created_at < '2012-12-23';
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="500" alt="5 1" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/f9459670-74f5-49e1-bcad-b63b182ed57a"> </kbd> <br>
</p>

<br>

**Query :**
```sql
WITH channel_cte AS(
SELECT 
	created_at,
	website_session_id,
	CASE 
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
		WHEN utm_campaign = 'brand' THEN 'paid_brand'
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	END AS channel_group
FROM website_sessions
WHERE created_at < '2012-12-23')

SELECT 
	MONTH(created_at) AS months,
	COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) AS paid_brand,
	COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS paid_nonbrand,
	ROUND(100*(COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END)),2) AS percent_ratio_brand_nonbrand,

	COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) AS organic_search,
	ROUND(100*(COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END)),2) AS percent_ratio_organic_nonbrand,

	COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) AS direct,
	ROUND(100*(COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END)),2) AS percent_ratio_direct_nonbrand
FROM channel_cte
GROUP BY MONTH(created_at)
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="950" alt="5 2" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/82513176-ce03-4d2a-a45a-8fd56ba85d9b"></kbd> <br>
  5 — They are growing as a percentage of paid traffic volume
</p>
<br>

---

## 📂 **Business Patterns & Seasonality**
### 📌 **Business Concept: Analyzing Seasonality & Business Patterns**
Analyzing business patterns is about **generating insights to help you maximize efficiency and anticipate future trends.**


### 📌 **Common Use Cases: Analyzing Seasonality & Business Patterns**
- Day-parting analysis to understand how much support staff you should have at different times of day or days of the week
- Analyzing seasonality to better prepare for upcoming spikes or slowdowns in demand
<br>

### **Task**
### **1. Analyzing Seasonality**

<p align="center">
  <kbd> <img width="320" alt="6" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/6de5ce42-c72c-4cb6-9384-9a6364193edf"> </kbd> <br>
</p>
<br>

**Steps :**
- Pull monthly and weekly orders and sessions in 2012
- months/week_start_date | sessions | orders | cvr

<br>

**Query :**
```sql
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
```
<br>

**Result :**
<p align="center">
  <kbd><img width="250" alt="6 week" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/de535168-5622-4e23-a94e-7f87318590fe"></kbd> <br>
  1.1 — Conversion rates trended upward each month during 2012
</p>
<br>

**Query :**
```sql
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
GROUP BY WEEK(w.created_at);
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="250" alt="6 WEEKS" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/5da36707-7b2d-4302-9ab6-c02df6f675b1"></kbd><br>
  1.2 — The 3rd week of November saw a significant increase in traffic and orders.
</p>
<br>

### **2. Analyzing Business Patterns**

<p align="center">
  <kbd> <img width="320" alt="7" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/eba5ee77-82f2-41fa-818d-a4dde1d71ec9"></kbd> <br>
</p>
<br>

**Steps :**
- Pull sessions beside hour and day of the week in 15 Sep - 15 Nov 2012
- hr | monday | tuesday | ... |

<br>

**Query :**
```sql
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
```
<br>

**Result :**
<p align="center">
  <kbd> <img width="450" alt="hourly" src="https://github.com/faizns/Udemy-Advanced-MySQL-Data-Analysis/assets/115857221/17ffd1d3-88a0-49c7-9bc5-903520785a2c"></kbd> <br>
  2 — Plan on one support staff around the clock and then we should double up to two staff members from 8 am to 8 pm Monday through Friday
</p>
<br>
