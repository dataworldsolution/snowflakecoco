# Apple Inc Sales Analytics - Project Rules

## Project Overview
This is a Snowflake-based sales analytics platform for Apple Inc, following a medallion architecture (Bronze > Silver > Gold) with three deployment environments (Dev, QA, Prod) hosted on a single Snowflake account.

## Git Branching
- **Dev_Branch** — active development; all changes go here first
- **QA_Branch** — promoted from Dev via GitHub PR for business validation
- **main** — production-ready code only
- Never push directly to main or QA_Branch unless explicitly asked

## Databases

| Database | Purpose | Type |
|----------|---------|------|
| GOVERNANCE | Tags, policies, masking policies, security objects | Permanent |
| SALES_DEV | Development environment | Transient |
| SALES_QA | QA / business validation environment | Transient |
| SALES_PROD | Production environment | Permanent |

## Schemas (per environment database)

| Schema | Label | Purpose |
|--------|-------|---------|
| BRONZE | A | Raw data landing zone (COPY + INFER_SCHEMA) |
| SILVER | B | Cleaned & curated data (dynamic tables, incremental) |
| GOLD | C | Modeled fact & dimension tables, aggregated facts, semantic views |
| COMMON | D | File formats, sequences, UDFs, stored procedures |

## Object Creation Rules
1. SALES_DEV and SALES_QA: all schemas and tables must be **transient**
2. Common objects (CSV file formats, sequences) go in the **COMMON** schema
3. Tags, policies, masking policies go in the **GOVERNANCE** database
4. Always use **CREATE IF NOT EXISTS** — never drop existing objects accidentally
5. All objects must have **meaningful, short comments**
6. Data-storing objects (tables, stages) must have a **tag** for chargeback tracking

## Tags (in GOVERNANCE.TAGS)
- **ENVIRONMENT** — allowed values: DEV, QA, PROD
- **COST_CENTER** — free-form, for chargeback tracking

## Data Flow & Transformation Rules
- Source data is CSV in the `__initial_load/` folder
- Bronze tables: populated via COPY command + INFER_SCHEMA; include 3 metadata columns: `__file_name`, `__row_number`, `__load_timestamp`
- Bronze to Silver, Silver to Gold: use **dynamic tables** with incremental load, lag set to downstream
- Fact and dimension tables: created as dynamic tables based on silver layer
- Fact tables reference **gold-layer dimension tables** (not silver)
- Aggregated fact tables in Gold schema using dynamic tables
- Semantic views created within the Gold layer
- Delta/incremental load: task wrapping COPY for new files into internal stage; dynamic tables propagate automatically

## Source Data Entities (13 total)
**Reference data:** region_master, country_master, currency_master, tax_master, product_category_master, product_family_master, product_model_master, product_sku_master, product_country_availability, store_master, customer_master
**Transactional data:** sales_header, sales_item

## Migration Scripts
- Stored in `migrations/` folder using schemachange naming: `V{major}.{minor}.{patch}__{description}.sql`
- **V1.1.x** — Governance objects (shared, run once)
- **V1.2.x** — SALES_DEV environment
- **V1.3.x** — SALES_QA environment (future)
- **V1.4.x** — SALES_PROD environment (future)
- Governance scripts run first, then environment-specific scripts in version order

## File Format
- `SALES_DEV.COMMON.CSV_FORMAT` — standard CSV format with header skip, quote-enclosed fields, NULL handling, trim whitespace
