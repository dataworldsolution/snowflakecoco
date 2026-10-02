-- ============================================================================
-- Migration  : V1.2.3
-- Object     : SALES_DEV.COMMON.CSV_FORMAT (File Format)
-- Purpose    : Standard CSV file format used by COPY INTO commands to load
--              source data (from __initial_load/) into bronze layer tables.
-- Settings   : - Header row skipped (SKIP_HEADER = 1)
--              - Fields optionally enclosed by double quotes
--              - NULL handling for 'NULL', 'null', and empty strings
--              - Trim whitespace from fields
--              - Flexible column count (ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
-- Depends On : V1.2.2 (SALES_DEV.COMMON schema)
-- ============================================================================

CREATE FILE FORMAT IF NOT EXISTS SALES_DEV.COMMON.CSV_FORMAT
    TYPE                            = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY    = '"'
    SKIP_HEADER                     = 1
    NULL_IF                         = ('NULL', 'null', '')
    TRIM_SPACE                      = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH  = FALSE
    COMMENT = 'Standard CSV file format for initial data load';
