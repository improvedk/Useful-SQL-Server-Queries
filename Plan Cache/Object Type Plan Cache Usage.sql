/********************************************************************************
 Title:			Object Type Plan Cache Usage
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 This script gives an overview of what kind of plans are stored in the plan cache.
 A large amount of 'Adhoc' object types indicates a lack of parameterization of
 the queries, causing a bloated plan cache.
 ********************************************************************************/
 
SELECT
	p.objtype AS [Object Type],
	COUNT(*) AS [Number of Plans],
	CAST(SUM(CAST(p.size_in_bytes AS FLOAT)) / 1024 / 1024 AS DECIMAL(10, 2)) AS [Size in MB],
	SUM(CASE p.usecounts WHEN 1 THEN 1 ELSE 0 END) AS [Number of Plans (Usecount = 1)],
	CAST(CAST(SUM(CASE p.usecounts WHEN 1 THEN p.size_in_bytes ELSE 0 END) AS FLOAT) / 1024 / 1024 AS DECIMAL(10, 2)) AS [Size in MB (Usecount = 1)]
FROM
	sys.dm_exec_cached_plans p
GROUP BY
	p.objtype
ORDER BY
	SUM(CAST(p.size_in_bytes AS bigint)) DESC