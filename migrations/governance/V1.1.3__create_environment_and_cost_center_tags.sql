-- ============================================================================
-- Migration  : V1.1.3
-- Object     : GOVERNANCE.TAGS.ENVIRONMENT, GOVERNANCE.TAGS.COST_CENTER
-- Purpose    : Core tags used across all environments.
--              ENVIRONMENT - Identifies DEV/QA/PROD for access control and billing.
--              COST_CENTER - Free-form tag for chargeback on data-storing objects.
-- Depends On : V1.1.2 (GOVERNANCE.TAGS schema)
-- ============================================================================

-- Tag: ENVIRONMENT
-- Restricted to three allowed values matching our deployment environments.
-- Applied at database and schema level; will also be applied to tables/stages.
CREATE TAG IF NOT EXISTS GOVERNANCE.TAGS.ENVIRONMENT
    ALLOWED_VALUES 'DEV', 'QA', 'PROD'
    COMMENT = 'Identifies the deployment environment for chargeback and access control';

-- Tag: COST_CENTER
-- Free-form string so teams can assign their own cost center codes.
-- Must be applied to all data-storing objects (tables, stages) per architecture rules.
CREATE TAG IF NOT EXISTS GOVERNANCE.TAGS.COST_CENTER
    COMMENT = 'Cost center tag for chargeback tracking on data-storing objects';
