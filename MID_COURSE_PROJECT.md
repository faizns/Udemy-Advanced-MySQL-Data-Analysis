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
    - If source, campaign, and http referral is NULL, then it is direct traffic: users type in the website link in the browser's search bar.
    - If source and campaign is NULL, but there is http referral, then it is organic search: coming from search engine and not tagged w
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

