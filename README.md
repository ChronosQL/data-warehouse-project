# 🌍 Tours & Travel Data Warehouse (PostgreSQL + PostGIS)

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![PostGIS](https://img.shields.io/badge/PostGIS-3.4-green?style=for-the-badge&logo=postgis&logoColor=white)](https://postgis.net/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Metabase](https://img.shields.io/badge/Metabase-BI-509EE3?style=for-the-badge&logo=metabase&logoColor=white)](https://www.metabase.com/)
[![pgAdmin](https://img.shields.io/badge/pgAdmin-4-326690?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.pgadmin.org/)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion-orange?style=for-the-badge)](#-data-architecture)

An end-to-end, enterprise-grade Data Warehousing and Analytics solution for an international tours and travel agency (**`tours_dw`**), built on **PostgreSQL 16** with **PostGIS spatial extensions**, automated **Metabase Business Intelligence**, and containerized with **Docker Compose**.

The project implements a **Medallion Data Architecture** (Operational $\rightarrow$ Bronze $\rightarrow$ Silver $\rightarrow$ Gold) with automated full-refresh and incremental ingestion pipelines, spatial GIS analytics, deduplication, data cleansing, realistic Sri Lankan Rupee (LKR) financial modeling, and 5 zero-touch executive dashboards.

---

## 🏗️ Data Architecture

The data pipeline transitions through the **Medallion Architecture**:

```
 ┌──────────────────────────┐
 │    Operational (OLTP)    │  PostgreSQL 16 + PostGIS (public schema)
 │  Users, Fleet, Bookings  │  114 Places, 40 Vehicles, 2,500 Bookings, Payments & Audit
 └─────────────┬────────────┘
               │  CALL bronze.load_bronze()
               ▼
 ┌──────────────────────────┐
 │       Bronze Layer       │  Raw Landed History (bronze schema)
 │   Operational Mirror     │  Unconstrained schema, audit metadata (_ingested_at)
 └─────────────┬────────────┘
               │  CALL silver.load_silver()
               ▼
 ┌──────────────────────────┐
 │       Silver Layer       │  Cleansed & Enriched (silver schema)
 │   Cleaned & Normalized   │  Deduplicated, Casing standardized, PostGIS GIST indexes,
 └─────────────┬────────────┘  Business flags (is_approved, total_price, is_confirmed)
               │
               ▼
 ┌──────────────────────────┐
 │        Gold Layer        │  Business Star Schema (gold schema)
 │   Dimensional Modeling   │  Fact & Dimension tables optimized for analytical reporting (LKR)
 └──────────────────────────┘
```

1. **Operational Source (`public`)**:
   - Manages tour reservations, fleet management, customer profiles, payment installments, destination GIS points, reviews, customer inquiries, and status lifecycle audit histories.
   - Standardized in **Sri Lankan Rupees (LKR / Rs.)** with authentic local chauffeur tariffs (Economy Sedans from Rs. 7,500/day, Vans from Rs. 15,000/day, Luxury Coaches from Rs. 38,000/day).
   - Includes spatial point synchronization triggers and geospatial distance calculations using PostGIS.

2. **Bronze Layer (`bronze`)**:
   - Stores raw landing data extracted from operational source tables.
   - Relaxes foreign key constraints to ensure raw ingestion resilience against out-of-order writes.
   - Automatically tracks arrival timestamps via `_ingested_at TIMESTAMPTZ`.

3. **Silver Layer (`silver`)**:
   - Enforces relational schemas, primary keys, and data integrity constraints.
   - Cleanses string columns (whitespace trimming, case normalization via `INITCAP`, `LOWER`, `UPPER`).
   - Deduplicates records using window functions (`ROW_NUMBER() OVER (...)`).
   - Standardizes spatial coordinates and generates PostGIS geometry points with GIST spatial indexes.
   - Enriches records with calculated fields and business indicators (`total_price`, `total_passengers`, `is_approved`, `is_confirmed`).
   - Records transformation timestamps via `_loaded_at TIMESTAMPTZ`.

4. **Gold Layer (`gold`)**:
   - Houses analytical views, dimensional models, and aggregated marts structured in an **Enterprise Star Schema**:
     - **Dimensions**:
       - `gold.dim_date`: Conformed calendar dimension with Sri Lanka **tourism seasons** (`PEAK_WINTER`, `SUMMER_PEAK`, `OFF_PEAK_MONSOON`), weekend flags, quarters, and days of week.
       - `gold.dim_customers`: Customer profiles with Pareto RFM segmentation (`VIP Traveler` $\ge$ Rs. 1.25M spend / $\ge 5$ tours, `Regular Traveler` $\ge$ Rs. 400K / $\ge 2$ tours, `Standard Traveler`, `Prospect`).
       - `gold.dim_vehicles`: Fleet inventory with vehicle specs, passenger/luggage capacities, daily rates (LKR), and insurance status.
       - `gold.dim_destinations`: 114 curated Sri Lankan destinations with PostGIS coordinates, activity counts, and package route inclusions.
       - `gold.dim_packages`: 20 pre-packaged itineraries (Adventure, Cultural, Beach, Hill Country, Safari), durations, and stop counts.
       - `gold.dim_activities`: 114 tourist experiences (Safaris, Whale Watching, Surfing, Hiking, Tea Tasting) grouped by activity categories.
     - **Facts & Data Marts**:
       - `gold.fact_bookings`: Core booking transactions (2,500 records) with financial realization statuses, passenger breakdowns, and reviews.
       - `gold.fact_payments`: 4,200+ installment payment transactions and verification states.
       - `gold.fact_booking_lifecycle`: Turnaround and funnel analytics tracking **14,700+ status changes**, hours elapsed per state, and SLA performance.
       - `gold.fact_customer_inquiries`: 850 web inquiries with registered customer flags, response latency hours, and 24-hour SLA breach indicators.
       - `gold.fact_reviews`: 1,600+ reviews categorized across 12 distinct chauffeurs with sentiment labels (`EXCELLENT`, `GOOD`, `AVERAGE`, `POOR`).
       - `gold.mart_daily_performance`: Daily booking volumes, confirmed revenue in LKR, conversion rates, and passenger totals.

---

## 🚀 Quick Start (One-Click Docker Setup)

The entire environment—including database initialization, operational data seeding, Medallion layer DDLs, automated pipeline execution, pgAdmin 4, and automated Metabase BI dashboards—spins up with a single Docker Compose command.

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (running on Windows, macOS, or Linux)

### 2. Start the Stack
Run the following command in the project root:

```bash
docker compose up -d
```

### 3. Automated Container Initialization Pipeline
Upon startup, the PostgreSQL container automatically executes the initialization sequence:
1. `00_create_metabase_db.sql` $\rightarrow$ Pre-provisions the application database for Metabase.
2. `01_init_database.sql` $\rightarrow$ Creates core tables, ENUM types, PostGIS extensions, views, and spatial triggers.
3. `02_init_database_data.sql` $\rightarrow$ Seeds 1,200+ international travelers, 40 fleet vehicles, 114 tourist destinations, 2,500 seasonal bookings (LKR), payments, and 14,000+ status audit logs.
4. `03_ddl_bronze.sql` $\rightarrow$ Builds the Bronze landing schema and tables.
5. `04_proc_load_bronze.sql` $\rightarrow$ Compiles the `bronze.load_bronze()` stored procedure.
6. `05_ddl_silver.sql` $\rightarrow$ Builds the Silver cleansed schema and spatial indexes.
7. `06_proc_load_silver.sql` $\rightarrow$ Compiles the `silver.load_silver()` stored procedure.
8. `07_ddl_gold.sql` $\rightarrow$ Builds the analytical Gold Star Schema views and data marts.
9. `08_run_pipeline.sql` $\rightarrow$ **Automatically runs the Bronze and Silver ETL pipelines**.
10. `metabase_init` companion $\rightarrow$ Automatically configures admin credentials, connects `tours_dw`, builds **5 Executive Dashboards + 1 Master Catalog Landing Hub**, mounts **all 20 Business Questions** into 2x2 grids, and sets the Gold Catalog as the permanent homepage.

---

## 📊 Analytics & BI Access

### Business Intelligence (Metabase - Zero-Touch Auto-Configured)
- **URL**: [http://localhost:3000](http://localhost:3000)
- **Credentials** (Pre-configured automatically on startup):
  - **Email**: `admin@admin.com`
  - **Password**: `AdminPassword123!`
- **Default Homepage**: Automatically set to **`0. Enterprise Gold Data Warehouse - Schema Catalog & Architecture Hub`**, displaying live metrics (`Total Confirmed Bookings`, `Total Confirmed Revenue (LKR)`), 6 Gold Dimensions, and 6 Fact Tables/Marts.
- **Pre-Configured Executive Dashboards**:
  1. **Executive Revenue & Financial Intelligence**: Seasonality, MoM Growth, YTD Run-Rate, Accounts Receivable.
  2. **Customer Segmentation & Lifetime Value (LTV)**: Customer Tiers, Inbound Source Countries, Loyalty Brackets, Churn Risk.
  3. **Fleet & Transportation Operations**: Vehicle Daily Yields, Idle Fleet (>30 Days), Capacity Utilization, Vehicle Preferences.
  4. **Destinations & Tour Experience Analytics**: Top Destination Hotspots, Activity Revenue Contribution, Package Cancellation Rates, Route Corridors.
  5. **Operations Funnel, Service SLAs & Quality**: Booking Funnel Bottlenecks, Confirmation SLA Turnaround, 24h Web Inquiry SLA, Driver Review Sentiment.

### Database Administration (pgAdmin 4)
- **URL**: [http://localhost:5050](http://localhost:5050)
- **Email**: `admin@admin.com`
- **Password**: `admin`
- **Pre-configured Server**: **`Tours Data Warehouse`** is pre-registered automatically via `servers.json`. Click to connect and enter the database password: **`admin123`**.

### Direct Database Connection (psql, DBeaver, Power BI, Python)
| Parameter | Value |
| :--- | :--- |
| **Host** | `localhost` |
| **Port** | `5432` |
| **Database** | `tours_dw` |
| **Username** | `admin` |
| **Password** | `admin123` |

---

## 📂 Repository Structure

```
sql-data-warehouse-project/
├── docker-compose.yml              # Multi-container orchestration (PostgreSQL + PostGIS, pgAdmin 4, Metabase, curl-jq)
├── pgadmin/
│   └── servers.json                # Pre-configured pgAdmin server registration
├── scripts/
│   ├── init_database.sql           # Operational schema, PostGIS extensions, triggers & views
│   ├── init_database_data.sql      # Realistic seed data (LKR pricing, seasonal bookings, payments, audit)
│   ├── run_pipeline.sql            # Automated pipeline trigger script (Bronze -> Silver)
│   ├── metabase_init.sh            # Zero-touch Metabase API bootstrapper
│   ├── create_dashboards.sh        # Automated builder for 5 dashboards + Gold Hub with 20 live cards
│   ├── create_metabase_db.sql      # Metabase internal database setup
│   ├── bronze/
│   │   ├── ddl_bronze.sql          # Bronze layer schema definition (raw landing)
│   │   └── proc_load_bronze.sql    # ELT stored procedure: public -> bronze
│   ├── silver/
│   │   ├── ddl_silver.sql          # Silver layer schema definition (cleansed & indexed)
│   │   └── proc_load_silver.sql    # Transformation procedure: bronze -> silver
│   └── gold/
│       ├── ddl_gold.sql            # Gold layer dimensional views & business marts
│       └── business_queries.sql    # 20 human-readable executive & operational analytical queries (LKR)
├── datasets/                       # Reference datasets and CSV source files
├── docs/                           # Architecture diagrams, data flow charts & data catalog
├── tests/                          # Data quality and validation test scripts
└── README.md                       # Project documentation
```

---

## 📈 20 Human-Readable Business Analytics Queries (LKR)

The warehouse includes 20 production-ready analytical queries in [`scripts/gold/business_queries.sql`](file:///c:/Users/Lenovo/Desktop/Projects/personal/data_engineering/sql-data-warehouse-project/scripts/gold/business_queries.sql) formatted in **Sri Lankan Rupees (`FM"LKR "999,999,999,990.00`)**:

1. **Tourism Seasonality & Revenue Fluctuation Analysis** — Peak Winter (LKR 315M) vs. Summer Peak (LKR 125M) vs. Monsoon slump (LKR 105M).
2. **Month-over-Month (MoM) Revenue Growth** — Trajectory tracking via `LAG()` with percentage shifts.
3. **Cumulative Annual Revenue Run-Rate** — Day-by-day pacing toward annual financial targets.
4. **Accounts Receivable & Balance Aging** — Aging outstanding balances across Regular (LKR 49.5M), VIP (LKR 7.0M), and Standard travelers.
5. **Customer Tier Distribution (VIP Segmentation)** — High-roller spend vs. standard travelers with average booking counts.
6. **Geographic Market Penetration** — Inbound tourist volume and revenue by origin country (UK, Germany, Australia, France, USA, India).
7. **Repeat Traveler Retention Rate** — Loyalty analysis: One-and-Done (27.3%), Repeat (68.5%), and Loyal Advocates (4.2%).
8. **High-Value Customer Churn Risk** — Lapsed VIP customers with lifetime spend > LKR 2.5M and no trips in $>180$ days.
9. **Vehicle Profitability & Daily Revenue Yield** — Return on investment and daily yields by vehicle class.
10. **Idle Fleet Identification** — Vehicles sitting parked $>30$ days causing depreciation loss (cleanly detects 8 inactive fleet assets).
11. **Seating Capacity Utilization** — Dispatches with $<40\%$ seat occupancy (preventing over-allocation and matching passenger counts).
12. **Vehicle Preference by Tour Duration** — Vehicle choices for day trips vs. 7, 14, 21, and 28-day grand circuits.
13. **Destination GMV Popularity Ranking** — Top 10 revenue-generating destinations (Mirissa, Bentota, Ravana Falls, Galle Fort, Kandy).
14. **Activity Category Revenue Contribution** — Safari/Wildlife vs. Adventure vs. Cultural revenue split.
15. **Tour Package Cancellation Rates** — Packages with high cancellation rates (Adventure/Monsoon hikes at 16%–21% vs. Beach stays at 5%–10%).
16. **Spatial Travel Corridor Density** — Top origin-destination pairs for chauffeur staging.
17. **Booking Funnel Conversion & Bottlenecks** — Conversion rates across `PENDING` $\rightarrow$ `QUOTED` $\rightarrow$ `CONFIRMED` $\rightarrow$ `COMPLETED`.
18. **Staff Confirmation Turnaround SLA** — Fast Response ($\le 4$h: 70.3%), Moderate (4–24h: 20.3%), and Breached ($>24$h: 9.4%).
19. **Customer Inquiry Response Latency** — General lead support response times and 24h SLA breaches (12.2% breach rate).
20. **Driver Service Quality & Review Sentiment** — Driver leaderboards across 12 chauffeurs by 5-star ratings and customer sentiment.

---

## ⚡ Manual Pipeline Execution

To trigger a full warehouse refresh on demand from any SQL client or pgAdmin:

```sql
-- 1. Refresh Bronze Layer from Operational Source
CALL bronze.load_bronze();

-- 2. Transform, Cleanse, and Load Silver Layer
CALL silver.load_silver();
```

Both procedures output real-time execution timing diagnostics and loaded row counts for every table.

---

## 🎓 Project Information

This project is developed as part of the **ICT3183 – Group Project / Advanced Database Management Systems (ADBMS)** module at the Faculty of Technology, University of Ruhuna.

- **Degree:** Bachelor of Information and Communication Technology (BICT) (Hons)
- **Year / Semester:** 3rd Year – 1st Semester
- **Project Type:** Real-World ICT Industry Group Project
- **Client Organization:** Ceylon Best Tours
- **Client Representative:** Mr. Dilshan
- **Repository:** [ChronosQL/adbms-project](https://github.com/ChronosQL/adbms-project.git)

---

## 👥 Group 09

| Name | Registration Number |
|:---|:---|
| R.P.J.M. Ruvanpathirana | TG/2022/1351 |
| G.R.K.M.T. Rathnayaka | TG/2022/1380 |
| W.K.G. Rajapaksha | TG/2022/1382 |
| R. W. M. A. S Bandara | TG/2022/1386 |
| W.M.A.K. Keshali | TG/2022/1419 |

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE).
