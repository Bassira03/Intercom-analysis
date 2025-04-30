#Analyse-des-conversations-Intercom-Equipe-Support**

🛏️ **Contexte** 
Chez Skello, l'équipe Support utilise Intercom pour gérer les conversations clients. Afin d'améliorer le pilotage opérationnel, un besoin a été exprimé par Lorette (manager Support) pour disposer d'un reporting visuel et actionnable, mis à jour chaque semaine.


📌 **Objectif**
Construire un modèle de données SQL et un reporting clair pour suivre la performance de l'équipe support (CSAT, réactivité, charge, etc.), à partir des exports Intercom. 

Nettoyer et modéliser les données issues d'Intercom Suivre les indicateurs clés :
- Nombre de conversations traitées 
- Temps moyen de première réponse CSAT (Customer Satisfaction Score) % de réponses en moins de 5 minutes
- Charge horaire de l'équipe 
- Performance individuelle des agents support 
- Créer un tableau de bord Power BI résumant ces KPIs

📊 **Modèle de données** 
Tables sources : 
- conversations.csv
- conversation_parts.csv
Tables additionnelles :
- support_agents : dictionnaire des agents internes 
Vues SQL construites : 
- first_admin_response : détection de la 1re réponse humaine
- csat_per_conversation : extraction du score CSAT 
- support_agent_metrics : agrégat de performance par agent 
- volume_by_weekday_hour : heatmap d'activité horaire 
- réponse_under_5min_stats : SLA 5 minutes

🗂 **Structure du projet**
	- data/: fichiers CSV nettoyés et prêts à l'importation
	- scripts/: scripts Python de Nettoyage des données
	- sql/: script de création des tables, requêtes analytiques
	- dashboard/: modèle ou capture du tableau de bord proposé

📊 **Métriques suivies**
	- CSAT moyen et taux de réponse
	- Temps de réponse moyen
	- % de réduction en < 5 minutes
- Volume de conversations par créneau horaire
- Détail par agent (réactivité, charge, CSAT)

💡 **Questions pour Lorette**
- Les bots doivent-ils être exclus des analyses ?
- Faut-il une granularité par canal (chat, mail, etc.) ou seulement globale ?
- 	Priorisation automatique via tag ou temps d'attente ?

