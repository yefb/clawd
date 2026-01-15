-- =============================================================================
-- 🤖 BOT ISSUES DIAGNOSTIC
-- Síntomas: Bot no joinea, no recording, missed calls
-- =============================================================================

-- PASO 1: Buscar usuario por email
-- Reemplazar: {{USER_EMAIL}}
SELECT 
    u.uuid as user_uuid,
    u.email,
    u.first_name || ' ' || u.last_name as name,
    tm.team_member_team as primary_team_uuid,
    t.name as team_name,
    u.settings->>'bot_joining' as user_bot_settings
FROM "user" u
LEFT JOIN team_members tm ON tm.team_member_user = u.uuid AND tm.primary = true
LEFT JOIN teams t ON t.uuid = tm.team_member_team
WHERE u.email ILIKE '%{{USER_EMAIL}}%';

-- =============================================================================

-- PASO 2: Calendar events recientes del usuario (últimos 7 días)
-- Reemplazar: {{USER_UUID}}
SELECT 
    ce.id as event_id,
    ce.summary as meeting_title,
    ce.start_time,
    ce.end_time,
    ce.joinable_final->>'should_join' as should_join,
    ce.joinable_final->>'reason' as reason,
    ce.joinable_final->>'source' as source,
    ce.joinable_override,
    ce.conversation_uuid,
    CASE 
        WHEN ce.zoom_meeting_join_url IS NOT NULL THEN 'Zoom'
        WHEN ce.microsoft_teams_meeting_join_url IS NOT NULL THEN 'Teams'
        WHEN ce.google_meet_join_url IS NOT NULL THEN 'Google Meet'
        ELSE 'Unknown'
    END as platform
FROM calendar_events ce
WHERE ce.user_uuid = '{{USER_UUID}}'
  AND ce.start_time >= NOW() - INTERVAL '7 days'
ORDER BY ce.start_time DESC;

-- =============================================================================

-- PASO 3: Detalle de un evento específico
-- Reemplazar: {{CALENDAR_EVENT_ID}}
SELECT 
    ce.id,
    ce.summary,
    ce.start_time,
    ce.end_time,
    ce.joinable_final,
    ce.joinable_override,
    ce.zoom_meeting_join_url,
    ce.microsoft_teams_meeting_join_url,
    ce.google_meet_join_url,
    ce.conversation_uuid,
    ce.transport_external_id as recall_bot_id
FROM calendar_events ce
WHERE ce.id = '{{CALENDAR_EVENT_ID}}';

-- =============================================================================

-- PASO 4: Si hay conversation_uuid, verificar estado del recording
-- Reemplazar: {{CONVERSATION_UUID}}
SELECT 
    c.uuid,
    c.title,
    c.started_at,
    c.finished_at,
    ROUND(EXTRACT(EPOCH FROM (c.finished_at - c.started_at))/60, 2) as duration_min,
    c.transport,
    c.transport_external_id as recall_bot_id,
    c.video_status,
    c.media_storage_status,
    c.transcript_status,
    c.is_empty,
    c.is_internal
FROM conversations c
WHERE c.uuid = '{{CONVERSATION_UUID}}';

-- =============================================================================

-- PASO 5: Team settings para bot joining
-- Reemplazar: {{TEAM_UUID}}
SELECT 
    t.uuid,
    t.name,
    t.settings->>'bot_joining' as bot_joining,
    t.organizer_join_internal_meetings,
    t.score_internal_calls,
    t.domain_names
FROM teams t
WHERE t.uuid = '{{TEAM_UUID}}';

-- =============================================================================
-- RAZONES COMUNES en joinable_final->>'reason':
-- 
-- user_not_organizer      → Usuario no es organizador del meeting
-- event_not_accepted      → Evento no fue aceptado en calendar
-- internal_meeting        → Meeting interno (depende de settings)
-- no_meeting_link         → No se detectó link de Zoom/Teams/Meet
-- overlap_conflict        → Conflicto con otro meeting
-- user_disabled           → Usuario deshabilitó el bot
-- team_disabled           → Team deshabilitó el bot
-- =============================================================================
