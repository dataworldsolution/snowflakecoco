-- ============================================================================
-- Migration  : V1.1.2
-- Object     : GOVERNANCE.TAGS (Schema)
-- Purpose    : Schema to hold all tag definitions used across environments
--              for environment identification, cost allocation, and
--              data classification.
-- Depends On : V1.1.1 (GOVERNANCE database)
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS GOVERNANCE.TAGS
    COMMENT = 'All tags for environment tracking, cost allocation, and data classification';
