# retail-analytics-eda   
Retail sales EDA | SQL (data cleaning &amp; prep)  / Power BI (visualization)  |  Covers pricing trends, inventory health, seasonality, and data quality audit.
## ❓ Business Questions 
1. Are prices really growing?  (YoY - Year over Year)
2. Is revenue growth driven by volume or price?
3. Do we have an inventory problem?
4. Does seasonality affect the margin?
5. Do promotions have a negative impact on profit?
6. Which countries are overstocked?  
7. Do we have suspicious data (quality issues)? 
   Should we change the way we collect data? 
   What improvements can we make?  

## 🛠️ Tools Used
- SQL Server (SSMS) — data cleaning & analysis
- Power BI — visualization.

## 📁 Data
Raw data located in `/data/raw/`.
Files provided by mentor for educational purposes only.

## 📂 Data Sources
Raw data files provided by mentor for educational purposes only.

| File | Description |
|------|-------------|
| `inventory_mmmgkubv.csv` | Inventory data |
| `products_mmmgmeum.csv` | Products data |
| `sales_orders.csv` | Sales orders data |

## 📊 Project Steps
1. Data quality check
2. Data cleaning (SQL)
3. Data preparation
4. Sales analysis
5. Visualization & conclusions


## 🗂️ SQL Scripts
- `sql/00_data_import.sql` — initial data import and table setup
- `sql/01_data_quality.sql` — data quality check for all three tables
- `sql/02_data_cleaning.sql` — data cleaning and standardization
- `sql/03_data_preparation.sql` — views and final data preparation for analysis

## 📊 Dashboard
Power BI dashboard covering revenue, seasonality, pricing and discount analysis.

- `dashboard/dashboard.pbix` — full Power BI file (requires Power BI Desktop to open)
- `dashboard/1_dashboard_overview.pdf` — screenshot, Overview page
- `dashboard/2_dashboard_details.pdf` — screenshot, Details page
- `dashboard/dashboard_demo.gif` — short demo of the year filter in action

## 📊 Reports
- `reports/data_cleaning_summary.pdf` — summary of data quality findings and cleaning decisions across all three tables
- `reports/Data_preparation_report.pdf` — data type conversions, cleaning steps and views built during preparation
- `reports/Analysis_report.pdf` — findings for all business questions (Q1–Q6), with SQL, charts and key metrics
- `reports/Brainstorm_report.pdf` — deeper investigation into two unexpected results (price growth vs. inflation, 2018/2022 revenue dips), verified against the data and external benchmarks

## 🔑 Key Findings
- Prices rose ~37% (2015–2024) while sales volume stayed flat — revenue growth is price-driven, not volume-driven
- Strong Q4 seasonality across all years
- No meaningful correlation between discounts and revenue (Pearson ≈ −0.01)
- Inventory data is unreliable for analysis: 82.7% of rows show a date mismatch of over a year between order and stock update
