/*
	Title:       Object Type Plan Cache Usage
	Created by:  Mark S. Rasmussen <mark@improve.dk>
	License:     CC BY 3.0
 
	Usage:
	This script gives an overview of what kind of plans are stored in the plan cache.
	A large amount of 'Adhoc' object types indicates a lack of parameterization of
	the queries, causing a bloated plan cache.
*/

SELECT
	CASE p.objtype
		WHEN 'Prepared' THEN 'Prepared statement'
		WHEN 'Adhoc' THEN 'Ad hoc query'
		WHEN 'Proc' THEN 'Stored procedure'
		WHEN 'UsrTab' THEN 'User table'
		WHEN 'SysTab' THEN 'System table'
		WHEN 'Check' THEN 'Check constraint'
		ELSE p.objtype
	END AS [Object Type],
	COUNT(*) AS [Number of Plans],
	SUM(CASE p.usecounts WHEN 1 THEN 1 ELSE 0 END) AS [Number of Plans (Usecount = 1)],
	CAST(SUM(CAST(p.size_in_bytes AS FLOAT)) / 1024 / 1024 AS DECIMAL(10, 2)) AS [Size in MB],
	CAST(CAST(SUM(CASE p.usecounts WHEN 1 THEN p.size_in_bytes ELSE 0 END) AS FLOAT) / 1024 / 1024 AS DECIMAL(10, 2)) AS [Size in MB (Usecount = 1)]
FROM
	sys.dm_exec_cached_plans p
GROUP BY
	p.objtype
ORDER BY
	SUM(CAST(p.size_in_bytes AS bigint)) DESC
