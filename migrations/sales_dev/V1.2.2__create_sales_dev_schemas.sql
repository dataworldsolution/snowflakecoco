-- ============================================================================
-- Migration  : V1.2.2
-- Object     : SALES_DEV.BRONZE, .SILVER, .GOLD, .COMMON (Schemas)
-- Purpose    : Medallion architecture schemas for the Sales Analytics platform.
--              A) BRONZE  - Raw data landing zone (COPY + INFER_SCHEMA).
--              B) SILVER  - Cleaned & curated data (dynamic tables, incremental).
--              C) GOLD    - Modeled fact & dimension tables, aggregated facts,
--                           semantic views.
--              D) COMMON  - Shared utilities: file formats, sequences, UDFs,
--                           stored procedures.
-- Note       : All schemas are TRANSIENT in dev/QA. For Prod, remove the
--              TRANSIENT keyword.
-- Depends On : V1.2.1 (SALES_DEV database)
-- ============================================================================

-- Schema A: Bronze - raw data lands here via PUT + COPY INTO
CREATE TRANSIENT SCHEMA IF NOT EXISTS SALES_DEV.BRONZE
    COMMENT = 'Bronze zone - Raw data landing from source systems';

-- Schema B: Silver - cleaned/curated via dynamic tables with incremental refresh
CREATE TRANSIENT SCHEMA IF NOT EXISTS SALES_DEV.SILVER
    COMMENT = 'Silver zone - Cleaned and curated data';

-- Schema C: Gold - star schema with fact/dimension tables, semantic views
CREATE TRANSIENT SCHEMA IF NOT EXISTS SALES_DEV.GOLD
    COMMENT = 'Gold zone - Modeled data with fact and dimension tables';

-- Schema D: Common - shared file formats, sequences, UDFs, stored procedures
CREATE TRANSIENT SCHEMA IF NOT EXISTS SALES_DEV.COMMON
    COMMENT = 'Common utilities - File formats, sequences, UDFs, stored procedures';
