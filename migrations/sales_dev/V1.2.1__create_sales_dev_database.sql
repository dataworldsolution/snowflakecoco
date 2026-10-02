-- ============================================================================
-- Migration  : V1.2.1
-- Object     : SALES_DEV (Database)
-- Purpose    : Development database for Apple Inc Sales Analytics platform.
--              Follows medallion architecture (Bronze > Silver > Gold).
-- Note       : TRANSIENT database - no fail-safe cost in dev environment.
--              For QA/Prod, replace SALES_DEV with SALES_QA / SALES_PROD.
--              QA should also be TRANSIENT; Prod should be permanent (remove
--              the TRANSIENT keyword).
-- Depends On : None
-- ============================================================================

CREATE TRANSIENT DATABASE IF NOT EXISTS SALES_DEV
    COMMENT = 'Apple Inc Sales Analytics - Development environment';
