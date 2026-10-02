-- ============================================================================
-- Migration  : V1.1.1
-- Object     : GOVERNANCE (Database)
-- Purpose    : Centralized governance database for tags, policies, masking
--              policies, and other security/governance objects.
-- Note       : This is a permanent database (NOT transient) since governance
--              objects must persist with full fail-safe protection.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS GOVERNANCE
    COMMENT = 'Centralized governance - Tags, policies, masking policies, security objects';
