-- Nombre de réponses données en moins de 5 minutes (300 sec)
SELECT COUNT(*) AS responses_under_5min
FROM conversations c
JOIN first_admin_response fr ON c.ID = fr.CONVERSATION_ID
WHERE TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at) <= 300;
-- Pourcentage de réponses < 5 minutes
SELECT
  ROUND(
    100.0 *
    COUNT(*) /
    (SELECT COUNT(*) 
     FROM conversations c2 
     JOIN first_admin_response fr2 ON c2.ID = fr2.CONVERSATION_ID),
    2
  ) AS percentage_under_5min
FROM conversations c
JOIN first_admin_response fr ON c.ID = fr.CONVERSATION_ID
WHERE TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at) <= 300;
-- Temps moyen de 1ère réponse (en minutes)
SELECT
  ROUND(AVG(TIMESTAMPDIFF(SECOND, c.CREATED_AT, fr.first_admin_response_at)) / 60, 2) AS avg_first_response_minutes
FROM conversations c
JOIN first_admin_response fr ON c.ID = fr.CONVERSATION_ID;
--  CSAT moyen (sur les conversations notées)
SELECT
  ROUND(AVG(csat_score), 2) AS avg_csat
FROM csat_per_conversation;

SELECT
  cs.conversation_id,
  cs.csat_score,
  cs.csat_comment,
  c.CREATED_AT,
  sa.name AS agent_name
FROM csat_per_conversation cs
JOIN conversations c ON c.ID = cs.conversation_id
LEFT JOIN support_agents sa ON sa.id = c.ASSIGNEE
ORDER BY c.CREATED_AT DESC
LIMIT 20;
