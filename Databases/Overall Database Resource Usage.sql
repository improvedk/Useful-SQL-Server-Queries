/*
	Title:         Overall Database Resource Usage
	Created by:    Mark S. Rasmussen <mark@improve.dk>
	License:       CC BY 3.0
	Attribution:   Inspired by Glenn Berry's DMV scripts
	               (http://sqlserverperformance.wordpress.com/tag/dmv-queries/)
	Requirements:  2005+

	Usage:
	Outputs an overview of how many resources each database has spent since the last
	DBCC FREEPROCCACHE / DROPCLEANBUFFERS / restart.
*/

WITH DatabaseUsage AS
(
	-- Fetches IO & CPU stats
	SELECT
		PA.DatabaseID,
		SUM(total_worker_time) AS [CPU Time (ms)],
		(SUM(IO.num_of_bytes_read + IO.num_of_bytes_written)) / 1024 / 1024 AS [IO (mb)]
	FROM
		sys.dm_exec_query_stats AS QS
	CROSS APPLY
		(SELECT CAST(value AS int) AS DatabaseID FROM sys.dm_exec_plan_attributes(qs.plan_handle) WHERE attribute = 'dbid') AS PA
	LEFT JOIN
		sys.dm_io_virtual_file_stats(NULL, NULL) AS IO ON IO.database_id = PA.DatabaseID
	GROUP BY
		DatabaseID
),
BPUsage AS
(
	SELECT
		database_id AS DatabaseID,
		CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [Buffer Pool (mb)]
	FROM
		sys.dm_os_buffer_descriptors WITH (NOLOCK)
	WHERE
		database_id > 4 AND -- system databases
		database_id <> 32767 -- ResourceDB
	GROUP BY
		database_id
)
SELECT
	D.name,
	CAST([CPU Time (ms)] * 1.0 / SUM([CPU Time (ms)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU (%)],
	CAST([IO (mb)] * 1.0 / SUM([IO (mb)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [IO (%)],
	CAST([Buffer Pool (mb)] * 1.0 / SUM([Buffer Pool (mb)]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Buffer Pool (%)],
	[CPU Time (ms)],
	[IO (mb)],
	[Buffer Pool (mb)]
FROM
	sys.databases D
LEFT JOIN
	DatabaseUsage U ON U.DatabaseID = D.database_id
LEFT JOIN
	BPUsage BP ON BP.DatabaseID = D.database_id
ORDER BY
	[CPU Time (ms)] DESC
OPTION
	(RECOMPILE)