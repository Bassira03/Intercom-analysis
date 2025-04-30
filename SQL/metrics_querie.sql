use conversation_globale;

-- 1. Première réponse d'un admin humain
CREATE OR REPLACE VIEW first_admin_response AS
SELECT
    cp.CONVERSATION_ID,
    MIN(cp.CREATED_AT) AS first_admin_response_at
FROM conversation_parts cp
JOIN conversations c ON cp.CONVERSATION_ID = c.ID
WHERE cp.AUTHOR LIKE '%admin%'
  AND cp.TYPE = 'conversation_part'
GROUP BY cp.CONVERSATION_ID;

-- 2. Extraction CSAT score + commentaire
CREATE OR REPLACE VIEW csat_per_conversation AS
SELECT
    ID AS conversation_id,
    CAST(JSON_EXTRACT(CONVERSATION_RATING, '$.rating') AS SIGNED) AS csat_score,
    JSON_UNQUOTE(JSON_EXTRACT(CONVERSATION_RATING, '$.remark')) AS csat_comment
FROM conversations
WHERE CONVERSATION_RATING IS NOT NULL;

-- 3. Pourcentage de réponses < 5 minutes
CREATE OR REPLACE VIEW response_under_5min_stats AS
SELECT
    COUNT(*) AS total_conversations_with_response,
    SUM(CASE WHEN TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at) <= 300 THEN 1 ELSE 0 END) AS responses_under_5min,
    ROUND(
        100.0 * SUM(CASE WHEN TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at) <= 300 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS percentage_under_5min
FROM conversations c
JOIN first_admin_response fr ON c.ID = fr.CONVERSATION_ID;

-- 4. Volume par jour de la semaine et heure
CREATE OR REPLACE VIEW volume_by_weekday_hour AS
SELECT
    DAYNAME(CREATED_AT) AS weekday,
    HOUR(CREATED_AT) AS hour,
    COUNT(*) AS conversation_count
FROM conversations
GROUP BY DAYNAME(CREATED_AT), HOUR(CREATED_AT)
ORDER BY FIELD(weekday, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'), hour;

-- 5. Métriques détaillées par agent
CREATE OR REPLACE VIEW support_agent_metrics AS
SELECT
    sa.name AS agent_name,
    COUNT(DISTINCT c.ID) AS total_conversations,
    AVG(TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at)) AS avg_first_response_sec,
    SUM(CASE WHEN TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at) <= 300 THEN 1 ELSE 0 END) AS under_5min_count,
    ROUND(
        100.0 * SUM(CASE WHEN TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at) <= 300 THEN 1 ELSE 0 END)
        / COUNT(DISTINCT c.ID), 2
    ) AS under_5min_percent,
    COUNT(DISTINCT cs.conversation_id) AS rated_conversations,
    AVG(cs.csat_score) AS avg_csat
FROM conversations c
JOIN support_agents sa ON c.ASSIGNEE = sa.id
LEFT JOIN first_admin_response fr ON c.ID = fr.CONVERSATION_ID
LEFT JOIN csat_per_conversation cs ON c.ID = cs.conversation_id
GROUP BY sa.name;
