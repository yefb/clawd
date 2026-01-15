-- =============================================================================
-- 🔀 MULTI-RECORD (CRM Objects) DIAGNOSTIC
-- Síntomas: No aparecen Accounts/Contacts/Deals, multi-object sync
-- AREA: Yeiner es el SME primario para esto
-- =============================================================================

-- PASO 1: Verificar org settings para multi-record
-- Reemplazar: {{ORG_NAME}}
SELECT 
    o.uuid as org_uuid,
    o.name,
    o.settings->>'multi_record_enabled' as multi_record_enabled,
    o.settings->>'internal_auto_select_opportunities' as auto_select_opps,
    o.settings
FROM organizations o
WHERE o.name ILIKE '%{{ORG_NAME}}%';

-- =============================================================================

-- PASO 2: CRM Platform Entities (qué objetos están habilitados)
-- Reemplazar: {{ORG_UUID}}
SELECT 
    cpe.uuid,
    cp.name as platform,
    cpe.entity_type,
    cpe.enabled,
    cpe.settings,
    cpe.created_at
FROM crm_platform_entities cpe
JOIN crm_platforms cp ON cp.uuid = cpe.crm_platform_uuid
WHERE cpe.organization_uuid = '{{ORG_UUID}}'
ORDER BY cp.name, cpe.entity_type;

-- =============================================================================

-- PASO 3: CRM Accounts de la org (integraciones activas)
-- Reemplazar: {{ORG_UUID}}
SELECT 
    ca.uuid as crm_account_uuid,
    cp.name as platform,
    u.email as connected_by,
    ca.active,
    ca.settings,
    ca.created_at
FROM crm_accounts ca
JOIN crm_platforms cp ON cp.uuid = ca.crm_platform_uuid
LEFT JOIN "user" u ON u.uuid = ca.user_uuid
WHERE ca.organization_uuid = '{{ORG_UUID}}'
  AND ca.active = true
ORDER BY ca.created_at DESC;

-- =============================================================================

-- PASO 4: Org CRM Records (registros sincronizados)
-- Reemplazar: {{ORG_UUID}}
SELECT 
    ocr.uuid,
    cp.name as platform,
    ocr.external_id,
    ocr.record_type,
    ocr.record_data->>'Name' as record_name,
    ocr.created_at,
    ocr.updated_at
FROM org_crm_records ocr
JOIN crm_platforms cp ON cp.uuid = ocr.crm_platform_uuid
WHERE ocr.organization_uuid = '{{ORG_UUID}}'
ORDER BY ocr.updated_at DESC
LIMIT 50;

-- =============================================================================

-- PASO 5: Verificar linked_crm_records de conversations recientes
-- Reemplazar: {{ORG_UUID}}
SELECT 
    c.uuid as conversation_uuid,
    c.title,
    c.started_at,
    c.linked_crm_records_ids,
    c.external_intelligence_opportunity_id,
    u.email as owner
FROM conversations c
JOIN "user" u ON u.uuid = c.user_conversations
JOIN team_members tm ON tm.team_member_user = u.uuid AND tm.primary = true
JOIN teams t ON t.uuid = tm.team_member_team
WHERE t.organization_uuid = '{{ORG_UUID}}'
  AND c.started_at >= NOW() - INTERVAL '14 days'
  AND c.is_empty = false
ORDER BY c.started_at DESC
LIMIT 20;

-- =============================================================================

-- PASO 6: Deals y su linkeo a org_crm_records
-- Reemplazar: {{ORG_UUID}}
SELECT 
    d.uuid as deal_uuid,
    d.title as deal_title,
    ocr.external_id as crm_external_id,
    ocr.record_type,
    ocr.record_data->>'Name' as crm_record_name,
    d.created_at
FROM deals d
LEFT JOIN org_crm_records ocr ON ocr.uuid = d.org_crm_record_uuid
WHERE d.organization_uuid = '{{ORG_UUID}}'
ORDER BY d.created_at DESC
LIMIT 20;

-- =============================================================================

-- PASO 7: Verificar si un user tiene multi-record entities habilitados
-- Reemplazar: {{USER_EMAIL}}
SELECT 
    u.uuid,
    u.email,
    u.settings->>'enabled_crm_entities' as enabled_entities,
    u.settings->>'auto_select_opportunities' as auto_select
FROM "user" u
WHERE u.email ILIKE '%{{USER_EMAIL}}%';

-- =============================================================================
-- ENTITY TYPES COMUNES:
-- 
-- SFDC: Account, Contact, Opportunity, Lead
-- HubSpot: company, contact, deal
-- 
-- Para habilitar multi-record:
-- 1. Org setting: multi_record_enabled = true (o similar)
-- 2. CRM platform entities con enabled = true para cada tipo
-- 3. User settings con los entities habilitados
-- =============================================================================
