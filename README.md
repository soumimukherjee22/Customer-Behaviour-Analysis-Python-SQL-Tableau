# 🛍️ Customer Behaviour Analysis

> **End-to-End Data Analytics Portfolio Project** — Python · SQL · Tableau

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-2024-E97627?style=for-the-badge&logo=tableau&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.0-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-27AE60?style=for-the-badge)

---

## 📌 Business Problem

A retail business operating across the United States had accumulated rich transactional data from **3,900 customers** — but had never systematically analysed it. The result: marketing budgets spent without ROI, high-value customers not identified, and churning customers not detected until it was too late.

**This project builds a complete, data-driven intelligence system** to answer five critical business questions:

| Pain Point | The Problem |
|---|---|
| 🔴 No Segmentation | All 3,900 customers receive identical marketing regardless of loyalty or spend |
| 🔴 Discount Inefficiency | 32% of customers use promo codes — but does it actually lift revenue? |
| 🔴 Silent Churn | Low-frequency, disengaged customers leave silently, never flagged in advance |
| 🔴 Missed Seasons | Seasonal demand patterns exist, but inventory and promotions are never aligned |
| 🔴 Operational Blindspots | No benchmark for which shipping method or payment channel drives satisfaction |

---

## 📁 Repository Structure

```
customer-behaviour-analysis/
│
├── 📓 Customer_Behaviour_Analysis.ipynb   # Python EDA + statistical analysis + churn model
├── 🗄️  SQL_Queries.sql                    # 30+ SQL queries (Basic → Advanced) + BI View
├── 📊 Customer_Behaviour_Analysis.twbx   # Tableau workbook (2 dashboards)
├── 📄 README.md                           # You are here
│
└── 📁 assets/
    ├── dashboard_segmentation.png         # Customer Segmentation Dashboard screenshot
    └── dashboard_product.png              # Product & Category Performance screenshot
```

---

## 🗂️ Dataset

**Source:** Shopping Trends Dataset  
**Records:** 3,900 customers · 19 features · US market (50 states)

| Feature Group | Columns |
|---|---|
| **Demographics** | `customer_id`, `age`, `age_group` *(derived)*, `gender`, `location` |
| **Product** | `item_purchased`, `category`, `size`, `color`, `season` |
| **Transaction** | `purchase_amount_usd`, `review_rating`, `previous_purchases` |
| **Behaviour** | `frequency_of_purchases`, `subscription_status`, `payment_method`, `shipping_type` |
| **Marketing** | `discount_applied`, `promo_code_used`, `preferred_payment_method` |

**Key Stats:**

```
Total Revenue     →  $233,081
Total Customers   →  3,900
Avg Purchase      →  $59.76
Avg Rating        →  3.75 / 5.0
```

---

## 🐍 Python Analysis

**File:** `Customer_Behaviour_Analysis.ipynb`  
**Libraries:** `pandas` · `numpy` · `seaborn` · `matplotlib` · `plotly` · `scipy`

### What's Inside

**1. Data Cleaning & EDA**
- Null value check, data type inspection, shape analysis
- Purchase amount distribution (histogram + KDE)
- Spending by category (boxplot), category popularity (countplot)
- Average spend by season, gender distribution, location-based patterns

**2. Outlier Detection**
```python
# IQR Method — identify anomalous high-spend customers
Q1 = df["Purchase Amount (USD)"].quantile(0.25)
Q3 = df["Purchase Amount (USD)"].quantile(0.75)
IQR = Q3 - Q1
outliers = df[df["Purchase Amount (USD)"] > Q3 + 1.5 * IQR]
```

**3. Hypothesis Testing**
```python
# Welch's t-test: Does gender significantly affect spending?
_, p_value = stats.ttest_ind(male_spend, female_spend, equal_var=False)
# Result: p > 0.05 → Gender does NOT significantly affect purchase amount
```

**4. Correlation Analysis**
```python
# Age vs Purchase Amount — Pearson correlation
df[['Age', 'Purchase Amount (USD)']].corr()
```

**5. Confidence Interval Estimation**
```python
# 95% CI for true population mean of purchase amount
z = stats.norm.ppf(0.975)
lower = mean - z * (std / np.sqrt(n))
upper = mean + z * (std / np.sqrt(n))
```

**6. Churn Risk Scoring Model**
```python
def churn_score(freq, subscription):
    score = 0
    if freq in ['annually', 'every 3 months']:  score += 2
    elif freq == 'quarterly':                    score += 1
    if subscription == 'No':                     score += 2
    return score

df['churn_risk'] = df['churn_score'].apply(lambda x: 1 if x >= 3 else 0)
```
> Customers scoring **≥ 3** are flagged as **high churn risk** for proactive re-engagement.

---

## 🗄️ SQL Analysis

**File:** `SQL_Queries.sql`  
**Database:** MySQL · `customer_behaviour` schema · `shopping` table

### Query Tiers

#### 🟢 Basic — Customer & Product Overview (Q1–Q20)
- Total customers, revenue, average purchase amount
- Sales breakdown by gender, age group, category, item, size, color, season
- Payment method preferences, subscription vs non-subscription revenue
- Discount and promo code usage counts

#### 🟡 Intermediate — Revenue Intelligence & Marketing Effectiveness (Q1–Q20)
- Average spend per customer, top 10 high-value customers
- Revenue cross-tabbed by: location × category, season × category, gender × category, age group × category
- Discount impact: total revenue, avg purchase, order count — with vs. without discount
- Subscription status vs frequency of purchase cross-analysis
- Shipping type vs average review rating (customer satisfaction benchmark)

#### 🔴 Advanced — Segmentation & BI (Q1–Q5 + VIEW)

**RFM-Style Customer Segmentation:**
```sql
SELECT
    customer_id,
    CASE
        WHEN SUM(purchase_amount_usd) >= 300  THEN 'High_Value'
        WHEN SUM(purchase_amount_usd) >= 150  THEN 'Medium_Value'
        ELSE 'Low_Value'
    END AS monetary_segment,
    CASE
        WHEN MAX(previous_purchases) >= 15    THEN 'Highly_Engaged'
        WHEN MAX(previous_purchases) >= 5     THEN 'Moderately_Engaged'
        ELSE 'Low_Engagement'
    END AS engagement_segment,
    CASE
        WHEN frequency_of_purchases IN ('Weekly','Fortnightly') THEN 'High_Frequency'
        WHEN frequency_of_purchases = 'Monthly'                 THEN 'Medium_Frequency'
        ELSE 'Low_Frequency'
    END AS frequency_segment
FROM shopping
GROUP BY customer_id, frequency_of_purchases;
```

**High-Value Loyal Customer Identification:**
```sql
-- Spend ≥ $300 AND previous purchases ≥ 10 AND Weekly/Fortnightly frequency
SELECT customer_id, SUM(purchase_amount_usd) AS total_spent, ...
FROM shopping
GROUP BY customer_id, frequency_of_purchases
HAVING SUM(purchase_amount_usd) >= 300
   AND MAX(previous_purchases) >= 10
   AND frequency_of_purchases IN ('Weekly', 'Fortnightly');
```

**Churn-Risk Customer Isolation:**
```sql
-- Spend < $100 AND previous purchases < 3 AND Annual/Quarterly frequency
HAVING SUM(purchase_amount_usd) < 100
   AND MAX(previous_purchases) < 3
   AND frequency_of_purchases IN ('Annually','Quarterly');
```

**Business Intelligence View (Tableau Data Source):**
```sql
CREATE VIEW customer_behavior_intelligence AS
SELECT customer_id, gender, age, location, category, season,
       subscription_status, frequency_of_purchases,
       discount_applied, promo_code_used,
       SUM(purchase_amount_usd)  AS total_spent,
       AVG(purchase_amount_usd)  AS avg_spent,
       MAX(previous_purchases)   AS previous_purchases
FROM shopping
GROUP BY customer_id, gender, age, location, category, season,
         subscription_status, frequency_of_purchases,
         discount_applied, promo_code_used;
```

---

## 📊 Tableau Dashboards

**File:** `Customer_Behaviour_Analysis.twbx`

### Dashboard 1 — Customer Segmentation

![Customer Segmentation Dashboard](https://github.com/soumimukherjee22/Customer-Behaviour-Analysis-Python-SQL-Tableau/blob/main/CUSTOMER%20SEGMENTATION.png)

| Visual | Insight |
|---|---|
| Customer Segmentation Treemap | Purchase frequency distribution across 6 tiers |
| Age-wise Purchase Rate Treemap | Adults 37.97% · Young Adults 31.82% · Seniors 30.21% |
| Loyal Customers Table | All repeat buyers (previous purchases = 50) |
| Top 10 High-Value Customers | Ranked by composite score |
| High-Value Customer Bar Chart | Previous purchases vs purchase amount (26 customers) |

**Filters:** Location · Frequency of Purchases

---

### Dashboard 2 — Product & Category Performance

![Product & Category Dashboard](https://github.com/soumimukherjee22/Customer-Behaviour-Analysis-Python-SQL-Tableau/blob/main/PRODUCT%20%26%20CATEGORY%20PERFORMANCE.png)

| Visual | Insight |
|---|---|
| Operations Heatmap | Payment method × Shipping type transaction counts |
| Category-Season Matrix | Revenue cross-tab: Clothing leads at $104,264 |
| Size Trend Bar Chart | M (44,410) > L (27,071) > S (16,429) > XL (10,961) |
| Colour Preference Chart | Top colours: Cyan (4,519), Silver (4,550), Gray (4,499) |
| Seasonal Product Demand Table | Item-level demand split across Fall/Spring/Summer/Winter |
| Item-wise Performance Chart | Previous purchases by individual product |
| Marketing Effectiveness | Promo code impact: 32.14% Yes vs 67.86% No |
| High-level Category Bar | Accessories $74,200 · Footwear $36,093 · Outerwear $18,524 |

**Filters:** Location · Category · Item Purchased · Season

---

## 📈 Key Findings

### Customer Segmentation
- Purchase frequency is **evenly distributed** across all 6 tiers (539–584 customers each) — no dominant buying pattern, signalling an opportunity to shift customers to higher-frequency tiers
- **Adults (35–54) drive 37.97%** of purchases, the largest segment, followed closely by Young Adults (31.82%) and Seniors (30.21%)

### Revenue & Products
- **Clothing dominates** at $104,264 — 40% above Accessories ($74,200) and nearly 3× Outerwear ($18,524)
- Clothing revenue is **stable across all four seasons**, making it a reliable year-round inventory anchor
- **Medium (M) is the dominant size** at 44,410 units — assortment should reflect this distribution

### Marketing Effectiveness
- Discount and promo code usage **does not significantly increase average purchase value** — tools attract existing buyers rather than driving incremental spend
- **Subscribed customers** purchase more frequently, making subscription conversion the priority retention strategy

### Statistical Results
| Test | Finding |
|---|---|
| Welch's t-test (Gender vs Spend) | p > 0.05 — gender has **no statistically significant** impact on purchase amount |
| 95% Confidence Interval | True population mean of purchase amount falls within a narrow, stable range |
| IQR Outlier Detection | No extreme outliers found — purchase distribution is clean |

---

## 💡 Recommendations

| # | Recommendation | Rationale |
|---|---|---|
| 01 | **Tiered Loyalty Programme** | Use RFM segments to create Gold/Silver/Bronze tiers; prioritise High Value + Highly Engaged customers |
| 02 | **Convert Discount Users to Subscribers** | Redirect 32% promo-code budget toward subscription conversion — subscribed customers spend more consistently |
| 03 | **Proactive Churn Intervention** | Run churn score model monthly; flag score ≥ 3 customers for personalised re-engagement within 30 days |
| 04 | **Seasonal Stock Alignment** | Prioritise Clothing year-round, Outerwear in Fall/Winter; align promotional spend to Spring Accessories peaks |
| 05 | **Senior Customer Strategy** | Seniors are 30% of purchases but under-targeted — design dedicated product bundles and communication |
| 06 | **Operational Shipping Review** | Benchmark shipping type vs satisfaction ratings; route customers to highest-rated shipping options |

---

## 🚀 How to Run

### Python Notebook
```bash
# 1. Clone the repository
git clone https://github.com/soumimukherjee22/customer-behaviour-analysis.git
cd customer-behaviour-analysis

# 2. Install dependencies
pip install pandas numpy seaborn matplotlib plotly scipy jupyter

# 3. Launch the notebook
jupyter notebook Customer_Behaviour_Analysis.ipynb
```

### SQL Setup
```sql
-- 1. Create the database
CREATE DATABASE customer_behaviour;
USE customer_behaviour;

-- 2. Import the dataset as the 'shopping' table
-- (Use MySQL Workbench import wizard or LOAD DATA INFILE)

-- 3. Run SQL_Queries.sql top-to-bottom
-- It will: clean columns → add age_group → run all 30+ queries → create the BI view
SOURCE SQL_Queries.sql;
```

### Tableau
```
1. Open Tableau Desktop (2023+ recommended)
2. Open Customer_Behaviour_Analysis.twbx
3. The workbook connects to embedded data — no additional setup needed
4. Use the tab bar to navigate between dashboards
5. Interact with Location, Category, and Season filters to explore the data
```

---

## 🛠️ Tech Stack

| Tool | Version | Purpose |
|---|---|---|
| Python | 3.10+ | EDA, statistical analysis, churn modelling |
| pandas | 2.0+ | Data manipulation and aggregation |
| NumPy | 1.24+ | Numerical computation |
| seaborn / matplotlib | Latest | Static visualisations |
| Plotly | 5.0+ | Interactive charts |
| SciPy | 1.10+ | Hypothesis testing, statistical tests |
| MySQL | 8.0 | Database, querying, BI view creation |
| Tableau Desktop | 2023+ | Interactive dashboards |

---

## 📂 Deliverables Summary

| File | Description |
|---|---|
| `Customer_Behaviour_Analysis.ipynb` | Full EDA, hypothesis testing, confidence interval, churn scoring |
| `SQL_Queries.sql` | 30+ queries across 3 tiers + RFM segmentation + BI VIEW |
| `Customer_Behaviour_Analysis.twbx` | 2 interactive Tableau dashboards |
| `README.md` | This file |

---

## 👤 Author

**Soumi Mukherjee**  
Data Analyst · Python · SQL · Tableau  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](www.linkedin.com/in/soumimukherjeeofficial)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/soumimukherjee22)
[![email](https://img.shields.io/badge/Email-D14836?logo=gmail&logoColor=white)](mailto:soumi.mukherjee2003@gmail.com) 

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with ❤️ as a portfolio project · Dataset: Shopping Trends (Synthetic Retail Data)</sub>
</div>
