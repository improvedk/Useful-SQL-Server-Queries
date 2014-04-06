/*
	Title:         Overall CPU Usage per Database
	Created by:    Mark S. Rasmussen <mark@improve.dk>
	License:       CC BY 3.0
	Attribution:   Inspired by Glenn Berry's DMV scripts
	               (http://sqlserverperformance.wordpress.com/tag/dmv-queries/)
	Requirements:  2005+

	Usage:
	Outputs an overview of how much CPU time each database has spent since the last
	DBCC FREEPROCCACHE / restart.
*/

WITH DatabaseUsage AS
(
	SELECT
		DB_Name(PA.DatabaseID) AS [Database Name],
		SUM(total_worker_time) AS [CPU Time (ms)]
	 FROM
		sys.dm_exec_query_stats AS qs
	 CROSS APPLY
		(SELECT CAST(value AS int) AS DatabaseID FROM sys.dm_exec_plan_attributes(qs.plan_handle) WHERE attribute = 'dbid') AS PA
	GROUP BY
		DatabaseID
)
SELECT
	*,
	CAST([CPU Time (ms)] * 1.0 / SUM([CPU Time (ms)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Time (%)]
FROM
	DatabaseUsage
ORDER BY
	[CPU Time (ms)] DESC
OPTION
	(RECOMPILE)
