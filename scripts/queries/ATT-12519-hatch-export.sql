-- ATT-12519: CSV export for Hatch (AE team conversations)
-- Step 1: Find Hatch org and teams

SELECT 
    o.uuid as org_uuid, 
    o.name as org_name, 
    t.uuid as team_uuid, 
    t.name as team_name
FROM organizations o
JOIN teams t ON t.organization_uuid = o.uuid
WHERE o.name ILIKE '%hatch%'
ORDER BY t.name;

-- Step 2: Once you have the AE team_uuid, run this:
-- (Replace <AE_TEAM_UUID> with actual value)

/*
SELECT 
    c.uuid as conversation_id,
    c.title,
    c.started_at,
    c.finished_at,
    ROUND(c.media_duration / 60.0, 2) as duration_minutes,
    u.email as owner_email,
    u.first_name || ' ' || u.last_name as owner_name,
    c.is_internal,
    c.labels
FROM conversations c
JOIN "user" u ON u.uuid = c.user_conversations
WHERE c.conversation_team = '<AE_TEAM_UUID>'
  AND c.is_empty = false
  AND c.started_at >= NOW() - INTERVAL '90 days'  -- Adjust range as needed
ORDER BY c.started_at DESC;
*/
