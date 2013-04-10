/********************************************************************************
 Title:			Worst Performing Queries
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 Returns a list of the most time consuming queries, server wide. Depending on what
 kind of queries you're looking for, you can uncomment the relevant predicates.
 ********************************************************************************/

WITH TMP AS
(
	SELECT TOP 100
		CAST(SUM(s.total_elapsed_time) / 1000000.0 AS DECIMAL(10, 2)) AS [Total Elapsed Time in S],
		SUM(s.execution_count) AS [Total Execution Count],
		CAST(SUM(s.total_worker_time) / 1000000.0 AS DECIMAL(10, 2)) AS [Total CPU Time in S],
		CAST(SUM(s.total_worker_time) / SUM(s.execution_count) / 1000.0 AS DECIMAL(10, 2)) AS [Avg CPU Time in MS],
		SUM(s.total_logical_reads) AS [Total Logical Reads],
		CAST(CAST(SUM(s.total_logical_reads) AS FLOAT) / CAST(SUM(s.execution_count) AS FLOAT) AS DECIMAL(10, 2)) AS [Avg Logical Reads],
		SUM(s.total_logical_writes) AS [Total Logical Writes],
		CAST(CAST(SUM(s.total_logical_writes) AS FLOAT) / CAST(SUM(s.execution_count) AS FLOAT) AS DECIMAL(10, 2)) AS [Avg Logical Writes],
		SUM(s.total_clr_time) AS [Total CLR Time],
		CAST(SUM(s.total_clr_time) / SUM(s.execution_count) / 1000.0 AS DECIMAL(10, 2)) AS [Avg CLR Time in MS],
		CAST(SUM(s.min_worker_time) / 1000.0 AS DECIMAL(10, 2)) AS [Min CPU Time in MS],
		CAST(SUM(s.max_worker_time) / 1000.0 AS DECIMAL(10, 2)) AS [Max CPU Time in MS],
		SUM(s.min_logical_reads) AS [Min Logical Reads],
		SUM(s.max_logical_reads) AS [Max Logical Reads],
		SUM(s.min_logical_writes) AS [Min Logical Writes],
		SUM(s.max_logical_writes) AS [Max Logical Writes],
		CAST(SUM(s.min_clr_time) / 1000.0 AS DECIMAL(10, 2)) AS [Min CLR Time in MS],
		CAST(SUM(s.max_clr_time) / 1000.0 AS DECIMAL(10, 2)) AS [Max CLR Time in MS],
		COUNT(1) AS [Number of Statements],
		MAX(s.last_execution_time) AS [Last Execution Time],
		s.plan_handle AS [Plan Handle]
	FROM
		sys.dm_exec_query_stats s
		
	-- Most CPU consuming
	--GROUP BY s.plan_handle ORDER BY SUM(s.total_worker_time) DESC
		
	-- Most read+write IO consuming
	--GROUP BY s.plan_handle ORDER BY SUM(s.total_logical_reads + s.total_logical_writes) DESC
		
	-- Most write IO consuming
	--GROUP BY s.plan_handle ORDER BY SUM(s.total_logical_writes) DESC
		
	-- Most CLR consuming
	--WHERE s.total_clr_time > 0 GROUP BY s.plan_handle ORDER BY SUM(s.total_clr_time) DESC
)
SELECT
	TMP.*,
	st.text AS [Query],
	qp.query_plan AS [Plan]
FROM
	TMP
OUTER APPLY
	sys.dm_exec_query_plan(TMP.[Plan Handle]) AS qp
OUTER APPLY
	sys.dm_exec_sql_text(TMP.[Plan Handle]) AS st