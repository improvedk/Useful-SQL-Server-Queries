/********************************************************************************
 Title:			Worst Performing Queries
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 Returns a list of the most time consuming queries. Most interesting queries fall
 into these patterns:
	- High CPU time per execution
		* If these are run rarely, they may not be worth looking it. But if they're
		* run often, you'll definitely want to optimize them.
	- Extreme execution count
		* As these are run so often, you'll want to optimize them.
 ********************************************************************************/

WITH TMP AS
(
	SELECT TOP 100
		SUM(s.total_worker_time) AS [Total CPU Time in MS],
		SUM(s.execution_count) AS [Total Execution Count],
		SUM(s.total_worker_time) / SUM(s.execution_count) AS [CPU Time Per Execution in MS],
		COUNT(1) AS [Number of Statements],
		s.plan_handle
	FROM
		sys.dm_exec_query_stats s
	GROUP BY
		s.plan_handle
)
SELECT
	[Total CPU Time in MS],
	[Total Execution Count],
	[CPU Time Per Execution in MS],
	[Number of Statements],
	sql_text.text AS [Query],
	q.query_plan AS [Plan]
FROM
	TMP
OUTER APPLY
	sys.dm_exec_query_plan(TMP.plan_handle) AS q
OUTER APPLY
	sys.dm_exec_sql_text(plan_handle) AS sql_text
ORDER BY
	TMP.[Total CPU Time in MS] DESC