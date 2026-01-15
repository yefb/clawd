-- ATT-12516: Scorecard rerun for Cristian Smith (Dec 1 - now)
-- Step 1: Find Cristian Smith user

SELECT 
    u.uuid, 
    u.email, 
    u.first_name, 
    u.last_name,
    tm.team_member_team as team_uuid,
    t.name as team_name,
    tm.primary as is_primary_team
FROM "user" u
LEFT JOIN team_members tm ON tm.team_member_user = u.uuid
LEFT JOIN teams t ON t.uuid = tm.team_member_team
WHERE (u.first_name ILIKE '%cristian%' OR u.first_name ILIKE '%christian%')
  AND u.last_name ILIKE '%smith%';

-- Step 2: Count calls needing scorecard rerun
-- (Replace <USER_UUID> with Cristian's UUID)

/*
SELECT 
    COUNT(*) as total_calls,
    COUNT(CASE WHEN c.is_empty = false THEN 1 END) as non_empty_calls,
    COUNT(sr.uuid) as existing_scorecard_results
FROM conversations c
LEFT JOIN scorecard_results sr ON sr.conversation_uuid = c.uuid
WHERE c.user_conversations = '<USER_UUID>'
  AND c.started_at >= '2025-12-01'
  AND c.started_at <= NOW();
*/

-- Step 3: List calls that need scorecard rerun (non-empty, Dec 1+)
/*
SELECT 
    c.uuid as conversation_uuid,
    c.title,
    c.started_at,
    c.media_duration,
    c.is_empty,
    c.is_internal,
    t.name as team_name,
    CASE WHEN sr.uuid IS NOT NULL THEN 'Has scorecard' ELSE 'No scorecard' END as scorecard_status
FROM conversations c
JOIN teams t ON t.uuid = c.conversation_team
LEFT JOIN scorecard_results sr ON sr.conversation_uuid = c.uuid
WHERE c.user_conversations = '<USER_UUID>'
  AND c.started_at >= '2025-12-01'
  AND c.is_empty = false
ORDER BY c.started_at DESC;
*/
