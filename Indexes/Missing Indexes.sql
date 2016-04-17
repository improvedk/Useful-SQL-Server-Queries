/*
	Created by:  Mark S. Rasmussen <mark@improve.dk>
	License:     CC BY 3.0
	
	Warning - these suggestions should be taken with a ton of salt!
*/

SELECT DISTINCT TOP 50
	d.index_handle,
	d.statement AS table_name,
	s.unique_compiles,
	s.user_seeks,
	s.last_user_seek,
	s.avg_total_user_cost,
	s.avg_user_impact,
	d.equality_columns,
	d.inequality_columns,
	d.included_columns,
	s.avg_total_user_cost + s.avg_user_impact + (s.user_seeks + s.user_scans) AS score
FROM
	sys.dm_db_missing_index_details d
CROSS APPLY
	sys.dm_db_missing_index_columns (d.index_handle)
INNER JOIN
	sys.dm_db_missing_index_groups g ON
		g.index_handle = d.index_handle
INNER JOIN
	sys.dm_db_missing_index_group_stats s ON
		s.group_handle = g.index_group_handle
WHERE
	DB_NAME(d.database_id) = DB_NAME()
ORDER BY
	s.avg_total_user_cost + s.avg_user_impact + (s.user_seeks + s.user_scans) DESC
