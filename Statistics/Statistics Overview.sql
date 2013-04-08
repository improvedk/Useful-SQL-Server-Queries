/********************************************************************************
 Title:			Statistics Overview
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 This query is meant to give you an overview of the statistics created in the
 database. Each table is listed with each of its statistics, as well as the
 statistic properties.
 ********************************************************************************/
 
SELECT
	SCHEMA_NAME(o.schema_id) + '.' + o.name AS [Object Name],
	STATS_DATE(s.object_id, s.stats_id) AS [Last Updated],
	s.name AS [Stats Name],
	s.stats_id AS [Stats ID],
	s.auto_created AS [Stats Auto Created],
	s.user_created AS [Stats User Created],
	s.no_recompute AS [Stats Auto Update],
	s.has_filter AS [Stats Filtered],
	s.filter_definition AS [Stats Filter Definition]
FROM
	sys.stats s
INNER JOIN
	sys.objects o ON o.object_id = s.object_id
WHERE
	o.type = 'U'
ORDER BY
	[Object Name],
	[Stats Name]