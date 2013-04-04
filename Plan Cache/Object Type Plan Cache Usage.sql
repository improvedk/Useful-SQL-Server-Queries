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
	COUNT(*) AS [Number of Plans],
	SUM(CAST(size_in_bytes AS bigint)) / 1024 / 1024 AS [Size in MB],
	cacheobjtype [Cache Object Type],
	objtype AS [Object Type]
FROM
	sys.dm_exec_cached_plans
GROUP BY
	cacheobjtype,
	objtype
ORDER BY
	SUM(CAST(size_in_bytes AS bigint)) DESC