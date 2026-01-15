-- =============================================================================
-- 🔎 TEAM & USER LOOKUP (Quick Reference)
-- Queries de búsqueda rápida para empezar cualquier diagnóstico
-- =============================================================================

-- BUSCAR ORG POR NOMBRE
-- Reemplazar: {{ORG_NAME}}
SELECT 
    o.uuid as org_uuid,
    o.name as org_name,
    o.created_at,
    (SELECT COUNT(*) FROM teams t WHERE t.organization_uuid = o.uuid) as team_count,
    (SELECT COUNT(DISTINCT tm.team_member_user) 
     FROM team_members tm 
     JOIN teams t ON t.uuid = tm.team_member_team 
     WHERE t.organization_uuid = o.uuid) as user_count
FROM organizations o
WHERE o.name ILIKE '%{{ORG_NAME}}%';

-- =============================================================================

-- BUSCAR USER POR EMAIL
-- Reemplazar: {{USER_EMAIL}}
SELECT 
    u.uuid as user_uuid,
    u.email,
    u.first_name,
    u.last_name,
    u.seat_type,
    u.created_at,
    o.name as org_name,
    t.name as primary_team
FROM "user" u
LEFT JOIN team_members tm ON tm.team_member_user = u.uuid AND tm.primary = true
LEFT JOIN teams t ON t.uuid = tm.team_member_team
LEFT JOIN organizations o ON o.uuid = t.organization_uuid
WHERE u.email ILIKE '%{{USER_EMAIL}}%';

-- =============================================================================

-- LISTAR TODOS LOS TEAMS DE UNA ORG
-- Reemplazar: {{ORG_UUID}}
SELECT 
    t.uuid as team_uuid,
    t.name as team_name,
    t.parent_team_uuid,
    pt.name as parent_team,
    (SELECT COUNT(*) FROM team_members tm WHERE tm.team_member_team = t.uuid) as member_count,
    t.created_at
FROM teams t
LEFT JOIN teams pt ON pt.uuid = t.parent_team_uuid
WHERE t.organization_uuid = '{{ORG_UUID}}'
ORDER BY t.name;

-- =============================================================================

-- LISTAR TODOS LOS USERS DE UN TEAM
-- Reemplazar: {{TEAM_UUID}}
SELECT 
    u.uuid as user_uuid,
    u.email,
    u.first_name || ' ' || u.last_name as name,
    u.seat_type,
    tm.primary as is_primary_team,
    tm.role as team_role
FROM team_members tm
JOIN "user" u ON u.uuid = tm.team_member_user
WHERE tm.team_member_team = '{{TEAM_UUID}}'
ORDER BY tm.primary DESC, u.email;

-- =============================================================================

-- BUSCAR TEAM POR NOMBRE
-- Reemplazar: {{TEAM_NAME}}
SELECT 
    t.uuid as team_uuid,
    t.name as team_name,
    o.uuid as org_uuid,
    o.name as org_name,
    (SELECT COUNT(*) FROM team_members tm WHERE tm.team_member_team = t.uuid) as member_count
FROM teams t
JOIN organizations o ON o.uuid = t.organization_uuid
WHERE t.name ILIKE '%{{TEAM_NAME}}%';

-- =============================================================================

-- CONVERSATIONS RECIENTES DE UN USER
-- Reemplazar: {{USER_UUID}}
SELECT 
    c.uuid,
    c.title,
    c.started_at,
    c.finished_at,
    ROUND(c.media_duration / 60.0, 2) as duration_min,
    c.is_empty,
    c.is_internal,
    t.name as team
FROM conversations c
JOIN teams t ON t.uuid = c.conversation_team
WHERE c.user_conversations = '{{USER_UUID}}'
  AND c.started_at >= NOW() - INTERVAL '30 days'
ORDER BY c.started_at DESC
LIMIT 20;

-- =============================================================================

-- CONVERSATIONS RECIENTES DE UN TEAM
-- Reemplazar: {{TEAM_UUID}}
SELECT 
    c.uuid,
    c.title,
    c.started_at,
    u.email as owner,
    ROUND(c.media_duration / 60.0, 2) as duration_min,
    c.is_empty,
    c.is_internal
FROM conversations c
JOIN "user" u ON u.uuid = c.user_conversations
WHERE c.conversation_team = '{{TEAM_UUID}}'
  AND c.started_at >= NOW() - INTERVAL '7 days'
ORDER BY c.started_at DESC
LIMIT 30;

-- =============================================================================

-- STATS DE UNA ORG
-- Reemplazar: {{ORG_UUID}}
SELECT 
    o.name as org_name,
    (SELECT COUNT(*) FROM teams t WHERE t.organization_uuid = o.uuid) as total_teams,
    (SELECT COUNT(DISTINCT tm.team_member_user) 
     FROM team_members tm 
     JOIN teams t ON t.uuid = tm.team_member_team 
     WHERE t.organization_uuid = o.uuid) as total_users,
    (SELECT COUNT(*) 
     FROM conversations c 
     JOIN teams t ON t.uuid = c.conversation_team 
     WHERE t.organization_uuid = o.uuid 
       AND c.started_at >= NOW() - INTERVAL '30 days') as calls_last_30d
FROM organizations o
WHERE o.uuid = '{{ORG_UUID}}';
