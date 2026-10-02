-- ============================================================================
-- Migration  : V1.2.4
-- Object     : Tag assignments for SALES_DEV database and schemas
-- Purpose    : Apply GOVERNANCE.TAGS.ENVIRONMENT = 'DEV' to the database and
--              all four schemas for environment identification and chargeback.
-- Note       : For QA/Prod, change the tag value to 'QA' or 'PROD' and update
--              the object names accordingly.
-- Depends On : V1.1.3 (tags exist), V1.2.2 (schemas exist)
-- ============================================================================

-- Tag the database
ALTER DATABASE SALES_DEV SET TAG GOVERNANCE.TAGS.ENVIRONMENT = 'DEV';

-- Tag each schema individually
ALTER SCHEMA SALES_DEV.BRONZE SET TAG GOVERNANCE.TAGS.ENVIRONMENT = 'DEV';
ALTER SCHEMA SALES_DEV.SILVER SET TAG GOVERNANCE.TAGS.ENVIRONMENT = 'DEV';
ALTER SCHEMA SALES_DEV.GOLD   SET TAG GOVERNANCE.TAGS.ENVIRONMENT = 'DEV';
ALTER SCHEMA SALES_DEV.COMMON SET TAG GOVERNANCE.TAGS.ENVIRONMENT = 'DEV';
