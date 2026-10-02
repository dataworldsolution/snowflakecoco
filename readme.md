# Sales Analytics Platform - Snowflake

Apple Inc Sales Analytics platform built on Snowflake using a **medallion architecture** (Bronze > Silver > Gold) with environment separation (Dev / QA / Prod).

## Project Structure

```
snowflakecoco/
├── __architectural_notes/       # Architecture diagrams and design references
├── __initial_load/              # Source CSV files for initial data load
│   ├── country-master/          #   4 files: country, currency, region, tax
│   ├── product-master/          #   5 files: category, family, model, sku, availability
│   ├── store-master/            #   1 file:  store master
│   ├── customer-master/         #   Partitioned by year/country_code
│   │   ├── 2019/                #     35 country folders (AE..ZA)
│   │   ├── 2020/ ... 2025/
│   └── sales-transaction/       #   Partitioned by year (header + item per year)
│       ├── 2019/
│       ├── 2020/ ... 2025/
├── data_quality_docs/           # Data profiling and quality check reports
│   ├── data_profiling_observations.html
│   ├── data_quality_checks.html
│   └── validation_queries.sql
└── migrations/                  # Database Change Management (DCM) scripts
    ├── governance/              #   Governance database, tags, and policies
    │   ├── V1.1.1__create_governance_database.sql
    │   ├── V1.1.2__create_governance_tags_schema.sql
    │   └── V1.1.3__create_environment_and_cost_center_tags.sql
    └── sales_dev/               #   Sales Dev database objects
        ├── V1.2.1__create_sales_dev_database.sql
        ├── V1.2.2__create_sales_dev_schemas.sql
        ├── V1.2.3__create_sales_dev_common_objects.sql
        ├── V1.2.4__apply_sales_dev_tags.sql
        └── V1.2.5__create_stage_and_initial_load.sql
```

## Database Layout

| Database | Schema | Purpose |
|----------|--------|---------|
| GOVERNANCE | TAGS | Environment and cost center tags |
| SALES_DEV | BRONZE | Raw data landing zone (stages, raw tables) |
| SALES_DEV | SILVER | Cleaned and curated data (dynamic tables) |
| SALES_DEV | GOLD | Modeled facts, dimensions, semantic views |
| SALES_DEV | COMMON | Shared utilities: file formats, sequences, UDFs |

## Migration Naming Convention

Migrations follow versioned naming: `V{major}.{minor}.{patch}__{description}.sql`

- **V1.1.x** - Governance database and tags
- **V1.2.x** - Sales Dev database, schemas, objects, and data loading

## Initial Data Load

Source CSVs are uploaded to the internal stage `@SALES_DEV.BRONZE.SALES_CSV_STG` using the `snow stage copy` CLI command (not SQL COPY INTO). The stage has:

- **Directory table** enabled for file metadata queries
- **SNOWFLAKE_SSE** encryption
- **Auto-compress** enabled (files stored as `.csv.gz`)

The file format `SALES_DEV.COMMON.CSV_FORMAT` uses `COMPRESSION = AUTO`, so GZIP files are decompressed transparently during COPY INTO operations.

### Stage Layout

```
@SALES_CSV_STG/
└── initial-load/
    ├── country-master/          # 4 files (flat)
    ├── product-master/          # 5 files (flat)
    ├── store-master/            # 1 file  (flat)
    ├── customer-master/
    │   └── 2019/{country_code}/ # 35 files (year/country partitioned)
    └── sales-transaction/
        └── 2019/                # 2 files: header + item (year partitioned)
```

See `V1.2.5__create_stage_and_initial_load.sql` for the full set of snow CLI commands used.
