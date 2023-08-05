## 📂 **Analysis for Channel Management**
### 📌 **Business Concept: Channel Portofolio Optimization**
Analyzing a portfolio of marketing channels is about **bidding efficiently and using data to maximize the effectiveness of your marketing budget.**

### 📌 **Common Use Cases: Channel Portofolio Optimization**
- Understanding which marketing channels are driving the most sessions and orders through your website
- Understanding differences in user characteristics and conversion performance across marketing channels
- Optimizing bids and allocating marketing spend across a multi-channel portfolio to achieve maximum performance

### **Task**
### **1. Analyzing Channel Portofolios**
**Channel Portofolio Analysis** : to identify traffic coming from multiple marketing channels, we will use utm parameters stored in our sessions table

<p align="center">
  <kbd> </kbd> <br>
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
  <kbd>  </kbd> <br>
 
  1 — 
</p>

<br>

<p align="center">
  <kbd> </kbd><br>
</p>
<br>

### **2. Comparing Channel Characteristics**

<p align="center">
  <kbd> </kbd> <br>
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
  <kbd>  </kbd> <br>
 
  2 — 
</p>

<br>

<p align="center">
  <kbd> </kbd><br>
</p>
<br>

### **3. Cross Channel Bid Optimization**

<p align="center">
  <kbd> </kbd> <br>
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
  <kbd>  </kbd> <br>
 
  3 — 
</p>

<br>

<p align="center">
  <kbd> </kbd><br>
</p>
<br>

### **4. Channel Portofolio Trends**

<p align="center">
  <kbd> </kbd> <br>
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
  <kbd>  </kbd> <br>
 
  4 — 
</p>

<br>

<p align="center">
  <kbd> </kbd><br>
</p>
<br>


### 📌 **Business Concept: Analyzing Direct Traffic**
Analyzing your branded or direct traffic is about **keeping a pulse on how well your brand is doing with consumers, and how well your brand drives business.**

### 📌 **Common Use Cases: Analyzing Direct Traffic**
- Identifying how much revenue you are  generating from direct traffic – this is high  margin revenue without a direct cost of customer acquisition
- Understanding whether or not your paid traffic is generating a “halo” effect, and promoting additional direct traffic
- Assessing the impact of various initiatives on  how many customers seek out your business

### **5. Analyzing Free Channels**
**Free Traffic Analysis** : to identify traffic coming to your site that you are not paying for with marketing campaigns, we will again turn to our utm params.
<br>

<p align="center">
  <kbd> </kbd> <br>
</p>
<br>


**Steps :**


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
  <kbd>  </kbd> <br>
 
  5 — 
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

---

## 📂 **Business Patterns & Seasonality**
### 📌 **Business Concept: Analyzing Seasonality & Business Patterns**
Analyzing business patterns is about **generating insights to help you maximize efficiency and anticipate future trends.**


### 📌 **Common Use Cases: Analyzing Seasonality & Business Patterns**
- Day-parting analysis to understand how much support staff you should have at different times of day or days of the week
- Analyzing seasonality to better prepare for upcoming spikes or slowdowns in demand

### **Task**
### **1. Analyzing Seasonality**

### **2. Analyzing Business Patterns**