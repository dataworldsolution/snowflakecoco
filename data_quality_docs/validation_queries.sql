/*
================================================================================
  DATA VALIDATION SQL QUERIES - Country Master Files
================================================================================
  Purpose:   Post-load validation queries for tables converted from CSV files
             in __initial_load/country-master/
  Tables:    REGION_MASTER, CURRENCY_MASTER, COUNTRY_MASTER, TAX_MASTER
  Generated: September 29, 2026
  Usage:     Run these queries after loading CSV data into Snowflake tables.
             Each query returns rows that FAIL the check (empty = pass).
================================================================================
*/


-- ============================================================================
-- 1. COMPLETENESS CHECKS
-- ============================================================================

-- DQ-C01: region_master - No nulls in any column
SELECT 'DQ-C01' AS check_id, 'CRITICAL' AS severity, 'region_master null check' AS check_name, *
FROM region_master
WHERE region_code IS NULL
   OR region_name IS NULL
   OR is_active IS NULL
   OR effective_start_date IS NULL
   OR effective_end_date IS NULL
   OR created_at IS NULL
   OR source_system IS NULL;

-- DQ-C02: currency_master - No nulls in any column
SELECT 'DQ-C02' AS check_id, 'CRITICAL' AS severity, 'currency_master null check' AS check_name, *
FROM currency_master
WHERE currency_code IS NULL
   OR currency_name IS NULL
   OR currency_symbol IS NULL
   OR minor_unit IS NULL
   OR is_active IS NULL
   OR effective_start_date IS NULL
   OR effective_end_date IS NULL
   OR created_at IS NULL
   OR source_system IS NULL;

-- DQ-C03: country_master - No nulls in any column
SELECT 'DQ-C03' AS check_id, 'CRITICAL' AS severity, 'country_master null check' AS check_name, *
FROM country_master
WHERE country_code IS NULL
   OR country_name IS NULL
   OR iso_alpha3 IS NULL
   OR region_code IS NULL
   OR apple_fiscal_segment IS NULL
   OR currency_code IS NULL
   OR tax_code IS NULL
   OR primary_language IS NULL
   OR timezone IS NULL
   OR ecommerce_supported IS NULL
   OR retail_store_supported IS NULL
   OR market_tier IS NULL
   OR population_millions IS NULL
   OR gdp_usd_billions IS NULL
   OR gdpr_applicable IS NULL
   OR is_active IS NULL
   OR effective_start_date IS NULL
   OR effective_end_date IS NULL
   OR created_at IS NULL
   OR source_system IS NULL;

-- DQ-C04: tax_master - No nulls in any column
SELECT 'DQ-C04' AS check_id, 'CRITICAL' AS severity, 'tax_master null check' AS check_name, *
FROM tax_master
WHERE tax_code IS NULL
   OR tax_type IS NULL
   OR tax_rate IS NULL
   OR tax_inclusive_flag IS NULL
   OR effective_start_date IS NULL
   OR effective_end_date IS NULL
   OR is_active IS NULL
   OR created_at IS NULL
   OR source_system IS NULL;

-- DQ-C05: country_master - Row count threshold (baseline: 35)
SELECT 'DQ-C05' AS check_id, 'HIGH' AS severity, 'country_master row count' AS check_name,
       COUNT(*) AS actual_count, 35 AS expected_minimum,
       CASE WHEN COUNT(*) >= 35 THEN 'PASS' ELSE 'FAIL' END AS result
FROM country_master;

-- DQ-C06: region_master - Row count threshold (baseline: 5)
SELECT 'DQ-C06' AS check_id, 'HIGH' AS severity, 'region_master row count' AS check_name,
       COUNT(*) AS actual_count, 5 AS expected_minimum,
       CASE WHEN COUNT(*) >= 5 THEN 'PASS' ELSE 'FAIL' END AS result
FROM region_master;


-- ============================================================================
-- 2. UNIQUENESS CHECKS
-- ============================================================================

-- DQ-U01: region_master - PK uniqueness
SELECT 'DQ-U01' AS check_id, 'CRITICAL' AS severity, 'region_code uniqueness' AS check_name,
       region_code, COUNT(*) AS duplicate_count
FROM region_master
GROUP BY region_code
HAVING COUNT(*) > 1;

-- DQ-U02: currency_master - PK uniqueness
SELECT 'DQ-U02' AS check_id, 'CRITICAL' AS severity, 'currency_code uniqueness' AS check_name,
       currency_code, COUNT(*) AS duplicate_count
FROM currency_master
GROUP BY currency_code
HAVING COUNT(*) > 1;

-- DQ-U03: country_master - PK uniqueness
SELECT 'DQ-U03' AS check_id, 'CRITICAL' AS severity, 'country_code uniqueness' AS check_name,
       country_code, COUNT(*) AS duplicate_count
FROM country_master
GROUP BY country_code
HAVING COUNT(*) > 1;

-- DQ-U04: country_master - Alternate key uniqueness
SELECT 'DQ-U04' AS check_id, 'HIGH' AS severity, 'iso_alpha3 uniqueness' AS check_name,
       iso_alpha3, COUNT(*) AS duplicate_count
FROM country_master
GROUP BY iso_alpha3
HAVING COUNT(*) > 1;

-- DQ-U05: tax_master - PK uniqueness
SELECT 'DQ-U05' AS check_id, 'CRITICAL' AS severity, 'tax_code uniqueness' AS check_name,
       tax_code, COUNT(*) AS duplicate_count
FROM tax_master
GROUP BY tax_code
HAVING COUNT(*) > 1;

-- DQ-U06: country_master - Full row uniqueness
SELECT 'DQ-U06' AS check_id, 'CRITICAL' AS severity, 'country_master full row duplicates' AS check_name,
       country_code, COUNT(*) AS duplicate_count
FROM country_master
GROUP BY country_code, country_name, iso_alpha3, region_code, apple_fiscal_segment,
         currency_code, tax_code, primary_language, timezone, ecommerce_supported,
         retail_store_supported, market_tier, population_millions, gdp_usd_billions,
         gdpr_applicable, is_active, effective_start_date, effective_end_date,
         created_at, source_system
HAVING COUNT(*) > 1;


-- ============================================================================
-- 3. REFERENTIAL INTEGRITY CHECKS
-- ============================================================================

-- DQ-RI01: country_master.region_code -> region_master.region_code (orphan check)
SELECT 'DQ-RI01' AS check_id, 'CRITICAL' AS severity, 'region_code FK integrity' AS check_name,
       c.country_code, c.region_code AS orphan_region_code
FROM country_master c
LEFT JOIN region_master r ON c.region_code = r.region_code
WHERE r.region_code IS NULL;

-- DQ-RI02: country_master.currency_code -> currency_master.currency_code (orphan check)
SELECT 'DQ-RI02' AS check_id, 'CRITICAL' AS severity, 'currency_code FK integrity' AS check_name,
       c.country_code, c.currency_code AS orphan_currency_code
FROM country_master c
LEFT JOIN currency_master cur ON c.currency_code = cur.currency_code
WHERE cur.currency_code IS NULL;

-- DQ-RI03: country_master.tax_code -> tax_master.tax_code (orphan check)
SELECT 'DQ-RI03' AS check_id, 'CRITICAL' AS severity, 'tax_code FK integrity' AS check_name,
       c.country_code, c.tax_code AS orphan_tax_code
FROM country_master c
LEFT JOIN tax_master t ON c.tax_code = t.tax_code
WHERE t.tax_code IS NULL;

-- DQ-RI04: Unreferenced currencies (currencies not used by any country)
SELECT 'DQ-RI04' AS check_id, 'LOW' AS severity, 'unreferenced currencies' AS check_name,
       cur.currency_code, cur.currency_name
FROM currency_master cur
LEFT JOIN country_master c ON cur.currency_code = c.currency_code
WHERE c.currency_code IS NULL;

-- DQ-RI05: Unreferenced tax codes (tax codes not used by any country)
SELECT 'DQ-RI05' AS check_id, 'MEDIUM' AS severity, 'unreferenced tax codes' AS check_name,
       t.tax_code, t.tax_type, t.tax_rate
FROM tax_master t
LEFT JOIN country_master c ON t.tax_code = c.tax_code
WHERE c.tax_code IS NULL;


-- ============================================================================
-- 4. VALIDITY & FORMAT CHECKS
-- ============================================================================

-- DQ-V01: country_code must be exactly 2 uppercase letters
SELECT 'DQ-V01' AS check_id, 'HIGH' AS severity, 'country_code format' AS check_name,
       country_code
FROM country_master
WHERE NOT REGEXP_LIKE(country_code, '^[A-Z]{2}$');

-- DQ-V02: iso_alpha3 must be exactly 3 uppercase letters
SELECT 'DQ-V02' AS check_id, 'HIGH' AS severity, 'iso_alpha3 format' AS check_name,
       country_code, iso_alpha3
FROM country_master
WHERE NOT REGEXP_LIKE(iso_alpha3, '^[A-Z]{3}$');

-- DQ-V03: tax_rate must be between 0.0 and 1.0
SELECT 'DQ-V03' AS check_id, 'CRITICAL' AS severity, 'tax_rate range' AS check_name,
       tax_code, tax_rate
FROM tax_master
WHERE tax_rate < 0.0 OR tax_rate > 1.0;

-- DQ-V04: is_active must be 'Y' or 'N' across all tables
SELECT 'DQ-V04' AS check_id, 'HIGH' AS severity, 'is_active domain - region_master' AS check_name,
       region_code, is_active
FROM region_master WHERE is_active NOT IN ('Y', 'N')
UNION ALL
SELECT 'DQ-V04', 'HIGH', 'is_active domain - currency_master',
       currency_code, is_active
FROM currency_master WHERE is_active NOT IN ('Y', 'N')
UNION ALL
SELECT 'DQ-V04', 'HIGH', 'is_active domain - country_master',
       country_code, is_active
FROM country_master WHERE is_active NOT IN ('Y', 'N')
UNION ALL
SELECT 'DQ-V04', 'HIGH', 'is_active domain - tax_master',
       tax_code, is_active
FROM tax_master WHERE is_active NOT IN ('Y', 'N');

-- DQ-V05: effective_end_date must be >= effective_start_date across all tables
SELECT 'DQ-V05' AS check_id, 'CRITICAL' AS severity, 'date range - region_master' AS check_name,
       region_code AS record_key, effective_start_date, effective_end_date
FROM region_master WHERE effective_end_date < effective_start_date
UNION ALL
SELECT 'DQ-V05', 'CRITICAL', 'date range - currency_master',
       currency_code, effective_start_date, effective_end_date
FROM currency_master WHERE effective_end_date < effective_start_date
UNION ALL
SELECT 'DQ-V05', 'CRITICAL', 'date range - country_master',
       country_code, effective_start_date, effective_end_date
FROM country_master WHERE effective_end_date < effective_start_date
UNION ALL
SELECT 'DQ-V05', 'CRITICAL', 'date range - tax_master',
       tax_code, effective_start_date, effective_end_date
FROM tax_master WHERE effective_end_date < effective_start_date;

-- DQ-V06: minor_unit must be 0, 2, or 3
SELECT 'DQ-V06' AS check_id, 'MEDIUM' AS severity, 'minor_unit domain' AS check_name,
       currency_code, minor_unit
FROM currency_master
WHERE minor_unit NOT IN (0, 2, 3);

-- DQ-V07: tax_inclusive_flag must be 'Y' or 'N'
SELECT 'DQ-V07' AS check_id, 'HIGH' AS severity, 'tax_inclusive_flag domain' AS check_name,
       tax_code, tax_inclusive_flag
FROM tax_master
WHERE tax_inclusive_flag NOT IN ('Y', 'N');


-- ============================================================================
-- 5. CONSISTENCY CHECKS
-- ============================================================================

-- DQ-CS01: If tax_type = 'NONE' then tax_rate must be 0
SELECT 'DQ-CS01' AS check_id, 'HIGH' AS severity, 'NONE tax type with non-zero rate' AS check_name,
       tax_code, tax_type, tax_rate
FROM tax_master
WHERE tax_type = 'NONE' AND tax_rate != 0.0;

-- DQ-CS02: Tax-exclusive flag consistency
-- If tax_inclusive_flag = 'N' then tax_type should be SALES_TAX or NONE
SELECT 'DQ-CS02' AS check_id, 'MEDIUM' AS severity, 'tax-exclusive type mismatch' AS check_name,
       tax_code, tax_type, tax_inclusive_flag
FROM tax_master
WHERE tax_inclusive_flag = 'N' AND tax_type NOT IN ('SALES_TAX', 'NONE');

-- DQ-CS03: Active records must have future end date
SELECT 'DQ-CS03' AS check_id, 'HIGH' AS severity, 'active record with past end date' AS check_name,
       country_code, is_active, effective_end_date
FROM country_master
WHERE is_active = 'Y' AND effective_end_date < CURRENT_DATE();

-- DQ-CS04: GDPR applicable consistency with region
-- EMEA countries (excluding known exceptions TR, ZA) should have gdpr_applicable = 'Y'
SELECT 'DQ-CS04' AS check_id, 'MEDIUM' AS severity, 'EMEA GDPR inconsistency' AS check_name,
       c.country_code, c.country_name, c.region_code, c.gdpr_applicable
FROM country_master c
WHERE c.region_code = 'EMEA'
  AND c.country_code NOT IN ('TR', 'ZA')
  AND c.gdpr_applicable != 'Y';


-- ============================================================================
-- 6. BUSINESS RULE CHECKS
-- ============================================================================

-- DQ-BR01: market_tier must be 'Tier1' or 'Tier2'
SELECT 'DQ-BR01' AS check_id, 'HIGH' AS severity, 'invalid market_tier' AS check_name,
       country_code, market_tier
FROM country_master
WHERE market_tier NOT IN ('Tier1', 'Tier2');

-- DQ-BR02: tax_type must be in allowed domain
SELECT 'DQ-BR02' AS check_id, 'HIGH' AS severity, 'invalid tax_type' AS check_name,
       tax_code, tax_type
FROM tax_master
WHERE tax_type NOT IN ('VAT', 'GST', 'SALES_TAX', 'IVA', 'ICMS', 'SST', 'NONE');

-- DQ-BR03: Population must be within sane range (> 0, < 2000 million)
SELECT 'DQ-BR03' AS check_id, 'MEDIUM' AS severity, 'population out of range' AS check_name,
       country_code, country_name, population_millions
FROM country_master
WHERE population_millions <= 0 OR population_millions >= 2000;

-- DQ-BR04: GDP must be within sane range (> 0, < 50000 billion)
SELECT 'DQ-BR04' AS check_id, 'MEDIUM' AS severity, 'GDP out of range' AS check_name,
       country_code, country_name, gdp_usd_billions
FROM country_master
WHERE gdp_usd_billions <= 0 OR gdp_usd_billions >= 50000;


-- ============================================================================
-- 7. SUMMARY DASHBOARD QUERY
-- ============================================================================
-- Run this after all checks to get a consolidated pass/fail summary.

WITH check_results AS (
    -- Completeness: null counts per table
    SELECT 'DQ-C01' AS check_id, 'CRITICAL' AS severity, 'region_master nulls' AS check_name,
           COUNT(*) AS fail_count FROM region_master
    WHERE region_code IS NULL OR region_name IS NULL OR is_active IS NULL
       OR effective_start_date IS NULL OR effective_end_date IS NULL
       OR created_at IS NULL OR source_system IS NULL
    UNION ALL
    SELECT 'DQ-C02', 'CRITICAL', 'currency_master nulls',
           COUNT(*) FROM currency_master
    WHERE currency_code IS NULL OR currency_name IS NULL OR currency_symbol IS NULL
       OR minor_unit IS NULL OR is_active IS NULL OR effective_start_date IS NULL
       OR effective_end_date IS NULL OR created_at IS NULL OR source_system IS NULL
    UNION ALL
    SELECT 'DQ-C03', 'CRITICAL', 'country_master nulls',
           COUNT(*) FROM country_master
    WHERE country_code IS NULL OR country_name IS NULL OR iso_alpha3 IS NULL
       OR region_code IS NULL OR currency_code IS NULL OR tax_code IS NULL
       OR is_active IS NULL OR effective_start_date IS NULL OR effective_end_date IS NULL
    UNION ALL
    SELECT 'DQ-C04', 'CRITICAL', 'tax_master nulls',
           COUNT(*) FROM tax_master
    WHERE tax_code IS NULL OR tax_type IS NULL OR tax_rate IS NULL
       OR tax_inclusive_flag IS NULL OR is_active IS NULL
    UNION ALL
    -- Uniqueness: duplicate PKs
    SELECT 'DQ-U01', 'CRITICAL', 'region_code duplicates',
           COUNT(*) FROM (SELECT region_code FROM region_master GROUP BY region_code HAVING COUNT(*) > 1)
    UNION ALL
    SELECT 'DQ-U02', 'CRITICAL', 'currency_code duplicates',
           COUNT(*) FROM (SELECT currency_code FROM currency_master GROUP BY currency_code HAVING COUNT(*) > 1)
    UNION ALL
    SELECT 'DQ-U03', 'CRITICAL', 'country_code duplicates',
           COUNT(*) FROM (SELECT country_code FROM country_master GROUP BY country_code HAVING COUNT(*) > 1)
    UNION ALL
    SELECT 'DQ-U05', 'CRITICAL', 'tax_code duplicates',
           COUNT(*) FROM (SELECT tax_code FROM tax_master GROUP BY tax_code HAVING COUNT(*) > 1)
    UNION ALL
    -- Referential Integrity: orphan FKs
    SELECT 'DQ-RI01', 'CRITICAL', 'region_code orphans',
           COUNT(*) FROM country_master c LEFT JOIN region_master r ON c.region_code = r.region_code WHERE r.region_code IS NULL
    UNION ALL
    SELECT 'DQ-RI02', 'CRITICAL', 'currency_code orphans',
           COUNT(*) FROM country_master c LEFT JOIN currency_master cur ON c.currency_code = cur.currency_code WHERE cur.currency_code IS NULL
    UNION ALL
    SELECT 'DQ-RI03', 'CRITICAL', 'tax_code orphans',
           COUNT(*) FROM country_master c LEFT JOIN tax_master t ON c.tax_code = t.tax_code WHERE t.tax_code IS NULL
    UNION ALL
    -- Validity
    SELECT 'DQ-V03', 'CRITICAL', 'tax_rate out of range',
           COUNT(*) FROM tax_master WHERE tax_rate < 0.0 OR tax_rate > 1.0
    UNION ALL
    SELECT 'DQ-V05', 'CRITICAL', 'end_date < start_date',
           COUNT(*) FROM country_master WHERE effective_end_date < effective_start_date
)
SELECT
    check_id,
    severity,
    check_name,
    fail_count,
    CASE WHEN fail_count = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM check_results
ORDER BY
    CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 ELSE 4 END,
    check_id;
