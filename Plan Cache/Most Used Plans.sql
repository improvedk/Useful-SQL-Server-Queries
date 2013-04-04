/********************************************************************************
 Title:			Most Used Plans
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 This script can be used to get a list of the most used plans in the plan cache.
 These plans are generally the most important ones to make sure are optimized.
 If you sort by CP.usecounts ASC rather than DESC, then you'll get a list of the
 least used plans which may indicate lack of plan reuse.
 ********************************************************************************/
 
SELECT TOP 100
	CP.refcounts AS [Reference Count],
	CP.usecounts AS [Use Count],
	CP.size_in_bytes / 1024 AS [Size in KB],
	CP.cacheobjtype AS [Cache Object Type],
	CP.objtype AS [Object Type],
	sql_text.text AS [Query],
	query_plan.query_plan AS [Plan]
FROM
	sys.dm_exec_cached_plans CP
OUTER APPLY
	sys.dm_exec_sql_text(plan_handle) AS sql_text
OUTER APPLY
	sys.dm_exec_query_plan(plan_handle) AS query_plan
ORDER BY
	CP.usecounts DESC