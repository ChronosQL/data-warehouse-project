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
   - Houses analytical views, dimensional models, and aggregated metrics for business intelligence and reporting.

---

## 🚀 Quick Start (One-Click Docker Setup)

The entire environment—including database initialization, operational data seeding, Medallion layer DDLs, and automated pipeline execution—spins up with a single Docker Compose command.

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
7. `07_run_pipeline.sql` $\rightarrow$ **Automatically runs the Bronze and Silver ETL pipelines**.

---

## 🖥️ Database & pgAdmin Access

### Web Interface (pgAdmin 4)
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
├── docker-compose.yml              # Multi-container orchestration (PostgreSQL + PostGIS & pgAdmin 4)
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
│   └── gold/                       # Analytical data models & dimensional views
├── datasets/                       # Reference datasets and CSV source files
├── docs/                           # Architecture diagrams, data flow charts & data catalog
├── tests/                          # Data quality and validation test scripts
└── README.md                       # Project documentation
```

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

## 🛡️ License

This project is licensed under the [MIT License](LICENSE).
