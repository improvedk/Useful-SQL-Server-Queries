/*
	Title:         Overall Database Resource Usage
	Created by:    Mark S. Rasmussen <mark@improve.dk>
	License:       CC BY 3.0
	Attribution:   Inspired by Glenn Berry's DMV scripts
	               (http://sqlserverperformance.wordpress.com/tag/dmv-queries/)
	Requirements:  2005+

	Usage:
	Outputs an overview of how much/IO resources database has spent since the last
	DBCC FREEPROCCACHE / restart.
*/

WITH DatabaseUsage AS
(
	SELECT
		DB_Name(PA.DatabaseID) AS [Database Name],
		SUM(total_worker_time) AS [CPU Time (ms)],
		(SUM(IO.num_of_bytes_read) + SUM(IO.num_of_bytes_written)) / 1024 / 1024 AS [IO (mb)]
	FROM
		sys.dm_exec_query_stats AS QS
	CROSS APPLY
		(SELECT CAST(value AS int) AS DatabaseID FROM sys.dm_exec_plan_attributes(qs.plan_handle) WHERE attribute = 'dbid') AS PA
	LEFT JOIN
		sys.dm_io_virtual_file_stats(NULL, NULL) AS IO ON IO.database_id = PA.DatabaseID
	GROUP BY
		DatabaseID
)
SELECT
	*,
	CAST([CPU Time (ms)] * 1.0 / SUM([CPU Time (ms)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Time (%)],
	CAST([IO (mb)] * 1.0 / SUM([IO (mb)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [IO (%)]
FROM
	DatabaseUsage
ORDER BY
	[CPU Time (ms)] DESC
OPTION
	(RECOMPILE)