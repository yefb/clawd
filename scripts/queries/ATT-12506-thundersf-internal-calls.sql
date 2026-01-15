-- ATT-12506: Enable Internal Call Analysis for ThunderSF
-- Step 1: Find ThunderSF org and teams

SELECT 
    o.uuid as org_uuid, 
    o.name as org_name, 
    t.uuid as team_uuid, 
    t.name as team_name,
    t.score_internal_calls,
    t.settings->>'score_internal_calls' as settings_score_internal
FROM organizations o
JOIN teams t ON t.organization_uuid = o.uuid
WHERE o.name ILIKE '%thunder%' 
   OR t.name ILIKE '%thunder%';

-- What needs to happen:
-- Set teams.score_internal_calls = true for the relevant team(s)
-- This enables scorecard/label calculation on internal calls

-- Verification query (after update):
/*
SELECT 
    t.uuid,
    t.name,
    t.score_internal_calls,
    COUNT(c.uuid) as total_conversations,
    COUNT(CASE WHEN c.is_internal THEN 1 END) as internal_conversations
FROM teams t
LEFT JOIN conversations c ON c.conversation_team = t.uuid 
    AND c.started_at >= NOW() - INTERVAL '30 days'
WHERE t.name ILIKE '%thunder%'
GROUP BY t.uuid, t.name, t.score_internal_calls;
*/
