-- ============================================================================
-- Migration  : V1.2.5
-- Object     : SALES_DEV.BRONZE.SALES_CSV_STG (Internal Stage)
-- Purpose    : Creates the internal named stage for CSV file uploads and
--              documents the snow CLI commands used to perform the initial
--              data load into the stage.
-- Settings   : - Directory table enabled for file-level metadata queries
--              - Server-side encryption (SNOWFLAKE_SSE)
-- Note       : The snow CLI commands below are NOT executable in Snowflake.
--              They are documented here as commented code for DCM traceability
--              and to record the exact commands used during initial load.
-- Depends On : V1.2.2 (SALES_DEV.BRONZE schema)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Step 1: Create the internal named stage
-- ---------------------------------------------------------------------------
CREATE OR REPLACE STAGE SALES_DEV.BRONZE.SALES_CSV_STG
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Internal stage for CSV file uploads - initial and incremental loads';

-- ---------------------------------------------------------------------------
-- Step 2: Initial Load - Upload CSV files via snow CLI
--         (Executed outside Snowflake using: snow stage copy)
--         Connection: TR06889 (account: me04657.ap-southeast-1)
-- ---------------------------------------------------------------------------

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2a. Country Master (4 files)
--     Source : __initial_load/country-master/
--     Target : @SALES_CSV_STG/initial-load/country-master/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- snow stage copy \
--   "__initial_load/country-master/*.csv" \
--   "@SALES_DEV.BRONZE.SALES_CSV_STG/initial-load/country-master/" \
--   --parallel 10 \
--   --auto-compress \
--   --overwrite \
--   -c TR06889
--
-- Files uploaded:
--   country_master.csv   -> country_master.csv.gz   (5,563 -> 1,838 bytes)
--   currency_master.csv  -> currency_master.csv.gz  (2,484 -> 681 bytes)
--   region_master.csv    -> region_master.csv.gz     (502 -> 262 bytes)
--   tax_master.csv       -> tax_master.csv.gz       (3,064 -> 499 bytes)

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2b. Product Master (5 files)
--     Source : __initial_load/product-master/
--     Target : @SALES_CSV_STG/initial-load/product-master/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- snow stage copy \
--   "__initial_load/product-master/*.csv" \
--   "@SALES_DEV.BRONZE.SALES_CSV_STG/initial-load/product-master/" \
--   --parallel 10 \
--   --auto-compress \
--   --overwrite \
--   -c TR06889
--
-- Files uploaded:
--   product_category_master.csv      -> product_category_master.csv.gz      (1,075 -> 397 bytes)
--   product_country_availability.csv -> product_country_availability.csv.gz (1,814,269 -> 236,275 bytes)
--   product_family_master.csv        -> product_family_master.csv.gz        (3,339 -> 787 bytes)
--   product_model_master.csv         -> product_model_master.csv.gz         (10,758 -> 1,962 bytes)
--   product_sku_master.csv           -> product_sku_master.csv.gz           (60,181 -> 8,407 bytes)

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2c. Store Master (1 file)
--     Source : __initial_load/store-master/
--     Target : @SALES_CSV_STG/initial-load/store-master/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- snow stage copy \
--   "__initial_load/store-master/*.csv" \
--   "@SALES_DEV.BRONZE.SALES_CSV_STG/initial-load/store-master/" \
--   --parallel 10 \
--   --auto-compress \
--   --overwrite \
--   -c TR06889
--
-- Files uploaded:
--   store_master.csv -> store_master.csv.gz (25,419 -> 9,015 bytes)

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2d. Customer Master - 2019 (35 files, partitioned by country code)
--     Source : __initial_load/customer-master/2019/{country_code}/
--     Target : @SALES_CSV_STG/initial-load/customer-master/2019/{country_code}/
--     Countries: AE, AT, AU, BE, BR, CA, CH, CN, DE, DK, ES, FI, FR, HK,
--                IE, IL, IN, IT, JP, KR, MX, MY, NL, NO, NZ, PL, SA, SE,
--                SG, TH, TR, TW, UK, US, ZA
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- for cc in AE AT AU BE BR CA CH CN DE DK ES FI FR HK IE IL IN IT JP KR \
--           MX MY NL NO NZ PL SA SE SG TH TR TW UK US ZA; do
--   snow stage copy \
--     "__initial_load/customer-master/2019/$cc/*.csv" \
--     "@SALES_DEV.BRONZE.SALES_CSV_STG/initial-load/customer-master/2019/$cc/" \
--     --parallel 10 \
--     --auto-compress \
--     --overwrite \
--     -c TR06889
-- done

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2e. Sales Transactions - 2019 (2 files: header + item)
--     Source : __initial_load/sales-transaction/2019/
--     Target : @SALES_CSV_STG/initial-load/sales-transaction/2019/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- snow stage copy \
--   "__initial_load/sales-transaction/2019/*.csv" \
--   "@SALES_DEV.BRONZE.SALES_CSV_STG/initial-load/sales-transaction/2019/" \
--   --parallel 10 \
--   --auto-compress \
--   --overwrite \
--   -c TR06889
--
-- Files uploaded:
--   sales_header_2019.csv -> sales_header_2019.csv.gz (14,909,885 -> 5,361,742 bytes)
--   sales_item_2019.csv   -> sales_item_2019.csv.gz   (9,380,821 -> 4,226,473 bytes)

-- ---------------------------------------------------------------------------
-- Step 3: Refresh the directory table to register all uploaded files
-- ---------------------------------------------------------------------------
ALTER STAGE SALES_DEV.BRONZE.SALES_CSV_STG REFRESH;
