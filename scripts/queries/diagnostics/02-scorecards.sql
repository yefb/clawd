-- =============================================================================
-- 📊 SCORECARDS DIAGNOSTIC
-- Síntomas: Scorecard no calcula, scorecard missing, wrong scorecard
-- =============================================================================

-- PASO 1: Buscar usuario y verificar settings
-- Reemplazar: {{USER_EMAIL}}
SELECT 
    u.uuid as user_uuid,
    u.email,
    u.first_name || ' ' || u.last_name as name,
    u.settings->>'auto_calculate_scorecards' as auto_calc_scorecards,
    u.settings->>'auto_calculate_crm_fields' as auto_calc_crm_fields,
    tm.team_member_team as team_uuid,
    tm.primary as is_primary_team,
    t.name as team_name
FROM "user" u
LEFT JOIN team_members tm ON tm.team_member_user = u.uuid
LEFT JOIN teams t ON t.uuid = tm.team_member_team
WHERE u.email ILIKE '%{{USER_EMAIL}}%';

-- =============================================================================

-- PASO 2: Scorecards asignados al team del usuario
-- Reemplazar: {{TEAM_UUID}}
SELECT 
    s.uuid as scorecard_uuid,
    s.title as scorecard_name,
    s.enabled,
    s.all_teams,
    s.criteria,
    s.interaction_type,
    CASE 
        WHEN s.team_uuid = '{{TEAM_UUID}}' THEN 'Direct assignment'
        WHEN st.team_uuid = '{{TEAM_UUID}}' THEN 'Via scorecard_teams'
        WHEN s.all_teams = true THEN 'All teams'
        ELSE 'Unknown'
    END as assignment_type
FROM scorecards s
LEFT JOIN scorecard_teams st ON st.scorecard_uuid = s.uuid AND st.team_uuid = '{{TEAM_UUID}}'
WHERE s.enabled = true
  AND (
      s.team_uuid = '{{TEAM_UUID}}'
      OR st.team_uuid = '{{TEAM_UUID}}'
      OR s.all_teams = true
  );

-- =============================================================================

-- PASO 3: Conversations recientes del usuario y sus scorecard results
-- Reemplazar: {{USER_UUID}}
SELECT 
    c.uuid as conversation_uuid,
    c.title,
    c.started_at,
    c.is_empty,
    c.is_internal,
    c.labels,
    sr.uuid as scorecard_result_uuid,
    s.title as scorecard_name
FROM conversations c
LEFT JOIN scorecard_results sr ON sr.conversation_uuid = c.uuid
LEFT JOIN scorecards s ON s.uuid = sr.scorecard_uuid
WHERE c.user_conversations = '{{USER_UUID}}'
  AND c.started_at >= NOW() - INTERVAL '30 days'
  AND c.is_empty = false
ORDER BY c.started_at DESC
LIMIT 20;

-- =============================================================================

-- PASO 4: Detalle de scorecard result para una conversación específica
-- Reemplazar: {{CONVERSATION_UUID}}
SELECT 
    sr.uuid as result_uuid,
    s.title as scorecard_name,
    sr.summary,
    sr.created_at,
    si.title as item_title,
    si.type as item_type,
    si.weight,
    sir.numeric_result,
    sir.status,
    sir.description
FROM scorecard_results sr
JOIN scorecards s ON s.uuid = sr.scorecard_uuid
LEFT JOIN scorecard_item_results sir ON sir.scorecard_result_uuid = sr.uuid
LEFT JOIN scorecard_items si ON si.uuid = sir.scorecard_item_uuid
WHERE sr.conversation_uuid = '{{CONVERSATION_UUID}}'
ORDER BY si.position;

-- =============================================================================

-- PASO 5: Verificar por qué un scorecard no se calculó
-- Reemplazar: {{CONVERSATION_UUID}}, {{SCORECARD_UUID}}
SELECT
    c.uuid as conversation_uuid,
    c.title,
    c.is_empty,
    c.is_internal,
    c.labels as conversation_labels,
    s.uuid as scorecard_uuid,
    s.title as scorecard_name,
    s.criteria as scorecard_criteria,
    s.enabled as scorecard_enabled,
    u.settings->>'auto_calculate_scorecards' as user_auto_calc
FROM conversations c
JOIN "user" u ON u.uuid = c.user_conversations
CROSS JOIN scorecards s
WHERE c.uuid = '{{CONVERSATION_UUID}}'
  AND s.uuid = '{{SCORECARD_UUID}}';

-- =============================================================================

-- PASO 6: Listar todos los scorecards de una org
-- Reemplazar: {{ORG_NAME}}
SELECT 
    s.uuid,
    s.title,
    s.enabled,
    s.all_teams,
    s.criteria,
    s.interaction_type,
    t.name as direct_team,
    o.name as org_name
FROM scorecards s
JOIN organizations o ON o.uuid = s.organization_uuid
LEFT JOIN teams t ON t.uuid = s.team_uuid
WHERE o.name ILIKE '%{{ORG_NAME}}%'
ORDER BY s.enabled DESC, s.title;

-- =============================================================================
-- CHECKLIST DE DIAGNÓSTICO:
-- 
-- ✅ Usuario tiene auto_calculate_scorecards = true?
-- ✅ Scorecard está enabled?
-- ✅ Scorecard está asignado al team del usuario?
-- ✅ Conversation tiene labels que matchean criteria?
-- ✅ Conversation NO es is_empty = true?
-- ✅ Conversation NO es is_internal = true? (o team tiene score_internal_calls)
-- =============================================================================
