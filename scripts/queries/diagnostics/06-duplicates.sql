-- =============================================================================
-- 🔄 DUPLICATES DIAGNOSTIC
-- Síntomas: Calls duplicados, múltiples entries para mismo meeting
-- =============================================================================

-- PASO 1: Buscar duplicados por calendar event
-- Reemplazar: {{USER_UUID}}, {{DATE_FROM}}
SELECT 
    ce.id as calendar_event_id,
    ce.summary,
    ce.start_time,
    COUNT(DISTINCT c.uuid) as conversation_count,
    ARRAY_AGG(DISTINCT c.uuid) as conversation_uuids
FROM calendar_events ce
LEFT JOIN conversations c ON c.calendar_event_id = ce.id
WHERE ce.user_uuid = '{{USER_UUID}}'
  AND ce.start_time >= '{{DATE_FROM}}'
GROUP BY ce.id, ce.summary, ce.start_time
HAVING COUNT(DISTINCT c.uuid) > 1
ORDER BY ce.start_time DESC;

-- =============================================================================

-- PASO 2: Buscar duplicados por transport_external_id (mismo bot)
-- Reemplazar: {{USER_UUID}}, {{DATE_FROM}}
SELECT 
    c.transport_external_id,
    COUNT(*) as count,
    ARRAY_AGG(c.uuid) as conversation_uuids,
    MIN(c.started_at) as first_started,
    MAX(c.started_at) as last_started
FROM conversations c
WHERE c.user_conversations = '{{USER_UUID}}'
  AND c.started_at >= '{{DATE_FROM}}'
  AND c.transport_external_id IS NOT NULL
GROUP BY c.transport_external_id
HAVING COUNT(*) > 1
ORDER BY count DESC;

-- =============================================================================

-- PASO 3: Buscar duplicados por título y fecha similar
-- Reemplazar: {{USER_UUID}}, {{DATE_FROM}}
SELECT 
    c.title,
    DATE(c.started_at) as call_date,
    COUNT(*) as count,
    ARRAY_AGG(c.uuid) as conversation_uuids,
    ARRAY_AGG(c.started_at) as start_times
FROM conversations c
WHERE c.user_conversations = '{{USER_UUID}}'
  AND c.started_at >= '{{DATE_FROM}}'
GROUP BY c.title, DATE(c.started_at)
HAVING COUNT(*) > 1
ORDER BY call_date DESC;

-- =============================================================================

-- PASO 4: Detalle de conversations potencialmente duplicadas
-- Reemplazar: {{CONV_UUID_1}}, {{CONV_UUID_2}}
SELECT 
    c.uuid,
    c.title,
    c.started_at,
    c.finished_at,
    c.media_duration,
    c.transport,
    c.transport_external_id,
    c.calendar_event_id,
    c.is_empty,
    c.created_at
FROM conversations c
WHERE c.uuid IN ('{{CONV_UUID_1}}', '{{CONV_UUID_2}}')
ORDER BY c.started_at;

-- =============================================================================

-- PASO 5: Calendar events sin conversation (posible missing recording)
-- Reemplazar: {{USER_UUID}}, {{DATE_FROM}}
SELECT 
    ce.id,
    ce.summary,
    ce.start_time,
    ce.end_time,
    ce.joinable_final->>'should_join' as should_join,
    ce.joinable_final->>'reason' as reason,
    ce.conversation_uuid
FROM calendar_events ce
WHERE ce.user_uuid = '{{USER_UUID}}'
  AND ce.start_time >= '{{DATE_FROM}}'
  AND ce.conversation_uuid IS NULL
  AND ce.joinable_final->>'should_join' = 'true'
ORDER BY ce.start_time DESC;

-- =============================================================================

-- PASO 6: Imports duplicados (si aplica)
-- Reemplazar: {{ORG_UUID}}, {{DATE_FROM}}
SELECT 
    ci.uuid,
    ci.source,
    ci.status,
    ci.created_at,
    ci.total_conversations,
    ci.processed_conversations,
    ci.error_message
FROM conversation_imports ci
WHERE ci.organization_uuid = '{{ORG_UUID}}'
  AND ci.created_at >= '{{DATE_FROM}}'
ORDER BY ci.created_at DESC;

-- =============================================================================
-- CAUSAS COMUNES DE DUPLICADOS:
-- 
-- 1. Bot joinea múltiples veces al mismo meeting
-- 2. Import manual + recording automático
-- 3. Calendar event sincronizado múltiples veces
-- 4. User tiene múltiples calendar accounts
-- =============================================================================
