# 🌍 Tours & Travel Data Warehouse (PostgreSQL + PostGIS)

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![PostGIS](https://img.shields.io/badge/PostGIS-3.4-green?style=for-the-badge&logo=postgis&logoColor=white)](https://postgis.net/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![pgAdmin](https://img.shields.io/badge/pgAdmin-4-326690?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.pgadmin.org/)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion-orange?style=for-the-badge)](#-data-architecture)

An end-to-end, enterprise-grade Data Warehousing and Analytics solution for an international tours and travel agency (**`tours_dw`**), built on **PostgreSQL 16** with **PostGIS spatial extensions** and containerized with **Docker Compose**.

The project implements a **Medallion Data Architecture** (Operational $\rightarrow$ Bronze $\rightarrow$ Silver $\rightarrow$ Gold) with automated full-refresh and incremental ingestion pipelines, spatial GIS analytics, deduplication, data cleansing, and pre-configured **pgAdmin** monitoring.

---

## 🏗️ Data Architecture

The data pipeline transitions through the **Medallion Architecture**:

```
 ┌──────────────────────────┐
 │    Operational (OLTP)    │  PostgreSQL + PostGIS (public schema)
 │  Users, Fleet, Bookings  │  150+ Places, 40 Vehicles, 2,200 Bookings, Payments & Audit
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
 │   Dimensional Modeling   │  Fact & Dimension tables optimized for analytical reporting
 └──────────────────────────┘
```

1. **Operational Source (`public`)**:
   - Manages tour reservations, fleet management, customer profiles, payment installments, destination GIS points, reviews, customer inquiries, and status lifecycle audit histories.
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
       - `gold.dim_customers`: Customer profiles with RFM segmentation (`VIP Traveler`, `Regular`, `Standard`, `Prospect`), spend stats, and lifetime booking counts.
       - `gold.dim_vehicles`: Fleet inventory with vehicle specs, pricing, passenger/luggage capacities, and insurance status.
       - `gold.dim_destinations`: 150+ tourist spots with PostGIS coordinates, activity counts, and package route inclusions.
       - `gold.dim_packages`: Pre-packaged itineraries, durations, and stop counts.
       - `gold.dim_activities`: Tourist experiences (Safaris, Whale Watching, Surfing, Hiking, Tea Tasting) grouped by activity categories.
     - **Facts & Data Marts**:
       - `gold.fact_bookings`: Core booking transactions with financial realization statuses, passenger breakdowns, and reviews.
       - `gold.fact_payments`: Installment payment transactions and verification states.
       - `gold.fact_booking_lifecycle`: Turnaround and funnel analytics tracking **12,094 status changes**, hours elapsed per state, and cancellation reasons.
       - `gold.fact_customer_inquiries`: Lead generation tracking, support response latency (in hours), and 24-hour SLA breach flags.
       - `gold.fact_reviews`: Feedback sentiment categorization (`EXCELLENT`, `GOOD`, `AVERAGE`, `POOR`), photo attach rates, and driver ratings.
       - `gold.mart_daily_performance`: Daily booking volumes, confirmed revenue, conversion rates, and passenger totals.

---

## 🚀 Quick Start (One-Click Docker Setup)

The entire environment—including database initialization, operational data seeding, Medallion layer DDLs, automated pipeline execution, pgAdmin 4, and Metabase Business Intelligence—spins up with a single Docker Compose command.

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (running on Windows, macOS, or Linux)

### 2. Start the Stack
Run the following command in the project root:

```bash
docker compose up -d
```

### 3. Automated Container Initialization
Upon startup, the PostgreSQL container automatically executes the following scripts in order:
1. `01_init_database.sql` $\rightarrow$ Creates core tables, ENUM types, PostGIS extensions, views, and spatial triggers.
2. `02_init_database_data.sql` $\rightarrow$ Seeds 1,500+ users, 40 vehicles, 150 tourist destinations, 2,200 bookings, payments, and 12,000+ status audit logs.
3. `03_ddl_bronze.sql` $\rightarrow$ Builds the Bronze landing schema and tables.
4. `04_proc_load_bronze.sql` $\rightarrow$ Compiles the `bronze.load_bronze()` stored procedure.
5. `05_ddl_silver.sql` $\rightarrow$ Builds the Silver cleansed schema and spatial indexes.
6. `06_proc_load_silver.sql` $\rightarrow$ Compiles the `silver.load_silver()` stored procedure.
7. `07_ddl_gold.sql` $\rightarrow$ Builds the analytical Gold Star Schema views and data marts.
8. `08_run_pipeline.sql` $\rightarrow$ **Automatically runs the Bronze and Silver ETL pipelines**.

---

## 📊 Analytics & BI Access

### Business Intelligence (Metabase - Zero-Touch Auto-Configured)
- **URL**: [http://localhost:3000](http://localhost:3000)
- **Credentials** (Pre-configured automatically on startup):
  - **Email**: `admin@admin.com`
  - **Password**: `AdminPassword123!`
- **Database Status**: The **`Tours Data Warehouse`** (`tours_dw`) connection and all **`gold`** and **`silver`** models are **automatically connected and synced** upon startup by the `metabase_init` companion service. Zero manual wizard clicks required!
- **Recommended Dashboards & Visualizations**:
  - **Revenue & Bookings Trend**: Plot `gold.mart_daily_performance` over `booking_date` (Line / Bar charts).
  - **Traveler Geo Distribution**: Use `gold.dim_destinations` with latitude/longitude for interactive pin maps.
  - **Customer Tier Breakdown**: Pie / Donut chart of `gold.dim_customers` grouped by `customer_tier`.
  - **Financial Realization**: Breakdown of `gold.fact_bookings` by `financial_status` (Fully Paid, Partially Paid, Unpaid).

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
├── docker-compose.yml              # Multi-container orchestration (PostgreSQL + PostGIS, pgAdmin 4, Metabase)
├── pgadmin/
│   └── servers.json                # Pre-configured pgAdmin server registration
├── scripts/
│   ├── init_database.sql           # Operational schema, PostGIS extensions, triggers & views
│   ├── init_database_data.sql      # Seed data (Users, Fleet, Places, Bookings, Payments, Audit)
│   ├── run_pipeline.sql            # Automated pipeline trigger script
│   ├── bronze/
│   │   ├── ddl_bronze.sql          # Bronze layer schema definition (raw landing)
│   │   └── proc_load_bronze.sql    # ELT stored procedure: public -> bronze
│   ├── silver/
│   │   ├── ddl_silver.sql          # Silver layer schema definition (cleansed & indexed)
│   │   └── proc_load_silver.sql    # Transformation procedure: bronze -> silver
│   └── gold/
│       ├── ddl_gold.sql            # Gold layer dimensional views & business marts
│       └── business_queries.sql    # 20 human-readable executive & operational analytical queries
├── datasets/                       # Reference datasets and CSV source files
├── docs/                           # Architecture diagrams, data flow charts & data catalog
├── tests/                          # Data quality and validation test scripts
└── README.md                       # Project documentation
```

---

## 📈 20 Human-Readable Business Analytics Queries

The warehouse includes 20 production-ready analytical queries in [`scripts/gold/business_queries.sql`](file:///c:/Users/Lenovo/Desktop/Projects/personal/data_engineering/sql-data-warehouse-project/scripts/gold/business_queries.sql) designed for executive and operational decision-making:

1. **Tourism Seasonality & Revenue Fluctuation Analysis** — Peak vs. Monsoon performance drop-off.
2. **Month-over-Month (MoM) Revenue Growth** — Trajectory tracking via `LAG()`.
3. **Cumulative Annual Revenue Run-Rate** — Year-to-date pacing toward budget targets.
4. **Accounts Receivable & Balance Aging** — Unpaid receivables exposure across customer tiers.
5. **Customer Tier Distribution (VIP Segmentation)** — High-roller spend vs. standard travelers.
6. **Geographic Market Penetration** — Inbound tourist volume and revenue by origin country.
7. **Repeat Traveler Retention Rate** — Loyalty analysis (one-and-done vs. repeat bookers).
8. **High-Value Customer Churn Risk** — Lapsed VIP customers with no trips in 6+ months.
9. **Vehicle Profitability & Daily Revenue Yield** — Return on investment by vehicle class.
10. **Idle Fleet Identification** — Vehicles sitting parked $>30$ days causing depreciation loss.
11. **Seating Capacity Utilization** — Dispatches with $<40\%$ seat occupancy (preventing over-allocation).
12. **Vehicle Preference by Tour Duration** — Vehicle choices for day trips vs. cross-country tours.
13. **Destination GMV Popularity Ranking** — Top 10 destinations driving tour package revenue.
14. **Activity Category Revenue Contribution** — Safari/Wildlife vs. Surfing vs. Cultural revenue split.
15. **Tour Package Cancellation Rates** — Packages with $>25\%$ drop-offs needing itinerary revision.
16. **Spatial Travel Corridor Density** — Top origin-destination pairs for driver staging.
17. **Booking Funnel Conversion & Bottlenecks** — Drop-off rates across `PENDING` $\rightarrow$ `CONFIRMED` $\rightarrow$ `COMPLETED`.
18. **Staff Confirmation Turnaround SLA** — Average operational hours to confirm booking requests.
19. **Customer Inquiry Response Latency** — General lead support response times and 24h SLA breaches.
20. **Driver Service Quality & Review Sentiment** — Driver leaderboards by 5-star ratings and complaint themes.

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
