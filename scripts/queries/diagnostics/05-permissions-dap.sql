-- =============================================================================
-- 🔐 PERMISSIONS & DAP DIAGNOSTIC
-- Síntomas: Usuario no ve calls, access denied, calls privados
-- =============================================================================

-- PASO 1: Buscar usuario y sus membresías de team
-- Reemplazar: {{USER_EMAIL}}
SELECT 
    u.uuid as user_uuid,
    u.email,
    u.first_name || ' ' || u.last_name as name,
    u.seat_type,
    tm.team_member_team as team_uuid,
    tm.primary as is_primary_team,
    tm.role as team_role,
    t.name as team_name,
    t.organization_uuid
FROM "user" u
LEFT JOIN team_members tm ON tm.team_member_user = u.uuid
LEFT JOIN teams t ON t.uuid = tm.team_member_team
WHERE u.email ILIKE '%{{USER_EMAIL}}%'
ORDER BY tm.primary DESC, t.name;

-- =============================================================================

-- PASO 2: Team settings y DAP (Data Access Policy)
-- Reemplazar: {{TEAM_UUID}}
SELECT 
    t.uuid,
    t.name,
    t.settings->>'dap_enabled' as dap_enabled,
    t.settings->>'conversation_visibility' as conversation_visibility,
    t.settings->>'cross_team_visibility' as cross_team_visibility,
    t.privacy_default,
    t.parent_team_uuid,
    pt.name as parent_team_name
FROM teams t
LEFT JOIN teams pt ON pt.uuid = t.parent_team_uuid
WHERE t.uuid = '{{TEAM_UUID}}';

-- =============================================================================

-- PASO 3: Verificar acceso de un usuario a una conversation específica
-- Reemplazar: {{USER_UUID}}, {{CONVERSATION_UUID}}
SELECT 
    c.uuid as conversation_uuid,
    c.title,
    c.conversation_team as call_team_uuid,
    ct.name as call_team_name,
    c.user_conversations as call_owner_uuid,
    owner.email as call_owner_email,
    c.is_private,
    tm.team_member_team as user_team_uuid,
    ut.name as user_team_name,
    CASE 
        WHEN c.user_conversations = '{{USER_UUID}}' THEN '✅ Is owner'
        WHEN tm.team_member_team = c.conversation_team THEN '✅ Same team'
        WHEN c.is_private = true THEN '❌ Private call'
        ELSE '❓ Check DAP settings'
    END as access_status
FROM conversations c
JOIN teams ct ON ct.uuid = c.conversation_team
JOIN "user" owner ON owner.uuid = c.user_conversations
LEFT JOIN team_members tm ON tm.team_member_user = '{{USER_UUID}}'
LEFT JOIN teams ut ON ut.uuid = tm.team_member_team
WHERE c.uuid = '{{CONVERSATION_UUID}}';

-- =============================================================================

-- PASO 4: Listar calls de un team que un usuario debería ver
-- Reemplazar: {{USER_UUID}}, {{TEAM_UUID}}
SELECT 
    c.uuid,
    c.title,
    c.started_at,
    c.is_private,
    u.email as owner_email,
    CASE 
        WHEN c.user_conversations = '{{USER_UUID}}' THEN 'Own call'
        WHEN c.is_private = false THEN 'Team call (visible)'
        ELSE 'Private (check permissions)'
    END as visibility
FROM conversations c
JOIN "user" u ON u.uuid = c.user_conversations
WHERE c.conversation_team = '{{TEAM_UUID}}'
  AND c.started_at >= NOW() - INTERVAL '7 days'
  AND c.is_empty = false
ORDER BY c.started_at DESC
LIMIT 20;

-- =============================================================================

-- PASO 5: Todos los teams de una org con sus DAP settings
-- Reemplazar: {{ORG_UUID}}
SELECT 
    t.uuid,
    t.name,
    t.settings->>'dap_enabled' as dap_enabled,
    t.privacy_default,
    t.parent_team_uuid,
    pt.name as parent_team,
    (SELECT COUNT(*) FROM team_members tm WHERE tm.team_member_team = t.uuid) as member_count
FROM teams t
LEFT JOIN teams pt ON pt.uuid = t.parent_team_uuid
WHERE t.organization_uuid = '{{ORG_UUID}}'
ORDER BY t.name;

-- =============================================================================

-- PASO 6: Verificar jerarquía de teams
-- Reemplazar: {{ORG_UUID}}
WITH RECURSIVE team_hierarchy AS (
    SELECT uuid, name, parent_team_uuid, 0 as level, name::text as path
    FROM teams 
    WHERE organization_uuid = '{{ORG_UUID}}' AND parent_team_uuid IS NULL
    
    UNION ALL
    
    SELECT t.uuid, t.name, t.parent_team_uuid, th.level + 1, th.path || ' > ' || t.name
    FROM teams t
    JOIN team_hierarchy th ON t.parent_team_uuid = th.uuid
)
SELECT uuid, name, level, path
FROM team_hierarchy
ORDER BY path;

-- =============================================================================
-- DAP (Data Access Policy) NOTES:
-- 
-- privacy_default = 'private' → Calls son privados por default
-- privacy_default = 'team' → Calls visibles al team
-- dap_enabled = true → Restricciones adicionales activas
-- 
-- Un usuario puede ver un call si:
-- 1. Es el owner (user_conversations = user.uuid)
-- 2. Es del mismo team Y call no es privado
-- 3. Tiene rol de admin/manager con permisos cross-team
-- =============================================================================
