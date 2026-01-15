-- =============================================================================
-- 🏷️ LABELS DIAGNOSTIC
-- Síntomas: Labels no aparecen, labels incorrectos, missing tags
-- =============================================================================

-- PASO 1: Ver labels de una conversation específica
-- Reemplazar: {{CONVERSATION_UUID}}
SELECT 
    c.uuid,
    c.title,
    c.started_at,
    c.labels,
    c.is_empty,
    c.is_internal,
    c.transcript_status,
    t.name as team_name
FROM conversations c
JOIN teams t ON t.uuid = c.conversation_team
WHERE c.uuid = '{{CONVERSATION_UUID}}';

-- =============================================================================

-- PASO 2: Label categories asignadas a un team
-- Reemplazar: {{TEAM_UUID}}
SELECT 
    lc.uuid as category_uuid,
    lc.name as category_name,
    lc.enabled,
    lc.labels,
    lct.team_uuid,
    t.name as team_name
FROM label_categories lc
LEFT JOIN label_category_teams lct ON lct.label_category_uuid = lc.uuid
LEFT JOIN teams t ON t.uuid = lct.team_uuid
WHERE lct.team_uuid = '{{TEAM_UUID}}'
   OR lc.all_teams = true
ORDER BY lc.name;

-- =============================================================================

-- PASO 3: Todas las label categories de una org
-- Reemplazar: {{ORG_UUID}}
SELECT 
    lc.uuid,
    lc.name,
    lc.enabled,
    lc.all_teams,
    lc.labels,
    lc.created_at
FROM label_categories lc
WHERE lc.organization_uuid = '{{ORG_UUID}}'
ORDER BY lc.name;

-- =============================================================================

-- PASO 4: Conversations recientes de un user y sus labels
-- Reemplazar: {{USER_UUID}}
SELECT 
    c.uuid,
    c.title,
    c.started_at,
    c.labels,
    c.is_empty,
    c.is_internal,
    t.name as team
FROM conversations c
JOIN teams t ON t.uuid = c.conversation_team
WHERE c.user_conversations = '{{USER_UUID}}'
  AND c.started_at >= NOW() - INTERVAL '14 days'
  AND c.is_empty = false
ORDER BY c.started_at DESC
LIMIT 20;

-- =============================================================================

-- PASO 5: Verificar qué teams tienen acceso a una label category
-- Reemplazar: {{CATEGORY_NAME}}
SELECT 
    lc.uuid as category_uuid,
    lc.name as category_name,
    lc.all_teams,
    t.uuid as team_uuid,
    t.name as team_name
FROM label_categories lc
LEFT JOIN label_category_teams lct ON lct.label_category_uuid = lc.uuid
LEFT JOIN teams t ON t.uuid = lct.team_uuid
WHERE lc.name ILIKE '%{{CATEGORY_NAME}}%';

-- =============================================================================
-- CHECKLIST DE DIAGNÓSTICO:
-- 
-- ✅ Conversation tiene is_empty = false?
-- ✅ Conversation tiene transcript procesado (transcript_status)?
-- ✅ Label category está enabled?
-- ✅ Label category está asignada al team del call?
-- ✅ Si is_internal = true, team tiene score_internal_calls?
-- =============================================================================
