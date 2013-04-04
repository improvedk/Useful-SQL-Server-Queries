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
	cp.refcounts AS [Reference Count],
	cp.usecounts AS [Use Count],
	cp.size_in_bytes / 1024 AS [Size in KB],
	cp.cacheobjtype AS [Cache Object Type],
	cp.objtype AS [Object Type],
	st.text AS [Query],
	qp.query_plan AS [Plan],
	cp.plan_handle AS [Plan Handle]
FROM
	sys.dm_exec_cached_plans cp
OUTER APPLY
	sys.dm_exec_sql_text(plan_handle) AS st
OUTER APPLY
	sys.dm_exec_query_plan(plan_handle) AS qp
ORDER BY
	CP.usecounts DESC