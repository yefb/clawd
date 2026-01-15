-- =============================================================================
-- 🔗 CRM AUTO-SELECT DIAGNOSTIC
-- Síntomas: Calls no se linkean a oportunidades, CRM no sincroniza
-- =============================================================================

-- PASO 1: Verificar org settings (auto-select habilitado?)
-- Reemplazar: {{ORG_NAME}}
SELECT 
    o.uuid as org_uuid,
    o.name,
    o.settings->>'internal_auto_select_opportunities' as org_auto_select,
    o.settings->>'auto_push_enabled' as org_auto_push
FROM organizations o
WHERE o.name ILIKE '%{{ORG_NAME}}%';

-- =============================================================================

-- PASO 2: Verificar user settings
-- Reemplazar: {{USER_EMAIL}}
SELECT 
    u.uuid as user_uuid,
    u.email,
    u.first_name || ' ' || u.last_name as name,
    u.settings->>'auto_select_opportunities' as user_auto_select,
    u.settings->>'auto_push_enabled' as user_auto_push,
    u.settings->>'auto_calculate_scorecards' as user_auto_scorecards,
    u.settings->>'auto_calculate_crm_fields' as user_auto_crm_fields
FROM "user" u
WHERE u.email ILIKE '%{{USER_EMAIL}}%';

-- =============================================================================

-- PASO 3: Verificar CRM accounts (integraciones de la org)
-- Reemplazar: {{ORG_UUID}}
SELECT 
    ca.uuid as crm_account_uuid,
    ca.user_uuid,
    u.email as user_email,
    cp.name as crm_platform,
    ca.settings,
    ca.active,
    ca.created_at
FROM crm_accounts ca
JOIN crm_platforms cp ON cp.uuid = ca.crm_platform_uuid
LEFT JOIN "user" u ON u.uuid = ca.user_uuid
WHERE ca.organization_uuid = '{{ORG_UUID}}'
ORDER BY ca.created_at DESC;

-- =============================================================================

-- PASO 4: Conversations recientes y su linkeo a CRM
-- Reemplazar: {{USER_UUID}}
SELECT 
    c.uuid as conversation_uuid,
    c.title,
    c.started_at,
    c.external_intelligence_opportunity_id as opportunity_id,
    c.linked_crm_records_ids,
    d.org_crm_record_uuid,
    ocr.external_id as crm_record_external_id
FROM conversations c
LEFT JOIN deals d ON d.uuid = c.deal_uuid
LEFT JOIN org_crm_records ocr ON ocr.uuid = d.org_crm_record_uuid
WHERE c.user_conversations = '{{USER_UUID}}'
  AND c.started_at >= NOW() - INTERVAL '30 days'
  AND c.is_empty = false
ORDER BY c.started_at DESC
LIMIT 20;

-- =============================================================================

-- PASO 5: Team opportunity emails (matches guardados)
-- Reemplazar: {{TEAM_UUID}}
SELECT 
    toe.uuid,
    toe.email,
    toe.opportunity_id,
    toe.linked_crm_records,
    toe.created_at
FROM team_opportunity_emails toe
WHERE toe.team_uuid = '{{TEAM_UUID}}'
ORDER BY toe.created_at DESC
LIMIT 50;

-- =============================================================================

-- PASO 6: Verificar calendar event y sus participants para auto-select
-- Reemplazar: {{CALENDAR_EVENT_ID}}
SELECT 
    ce.id,
    ce.summary,
    ce.start_time,
    ce.calculated_opportunity_id,
    ce.is_opportunity_calculated,
    ce.linked_crm_records,
    ce.meta->>'attendees' as attendees
FROM calendar_events ce
WHERE ce.id = '{{CALENDAR_EVENT_ID}}';

-- =============================================================================

-- PASO 7: CRM platform entities (qué objetos están habilitados)
-- Reemplazar: {{ORG_UUID}}
SELECT 
    cpe.uuid,
    cp.name as platform,
    cpe.entity_type,
    cpe.enabled,
    cpe.settings
FROM crm_platform_entities cpe
JOIN crm_platforms cp ON cp.uuid = cpe.crm_platform_uuid
WHERE cpe.organization_uuid = '{{ORG_UUID}}'
ORDER BY cp.name, cpe.entity_type;

-- =============================================================================
-- CHECKLIST DE DIAGNÓSTICO:
-- 
-- ✅ Org tiene internal_auto_select_opportunities = true?
-- ✅ User tiene auto_select_opportunities = true?
-- ✅ Hay al menos un crm_account activo para la org?
-- ✅ Los crm_platform_entities tienen entities habilitados?
-- ✅ Hay matches en team_opportunity_emails para los attendees?
-- ✅ Calendar event tiene linked_crm_records populated?
-- =============================================================================
