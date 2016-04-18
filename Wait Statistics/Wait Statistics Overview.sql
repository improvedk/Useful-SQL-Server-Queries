/********************************************************************************
 Title:			Wait Statistics Overview
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 Attribution:	Inspired by Paul Randals script here (which is based on scripts by Glenn Berry)
				http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/
 
 Usage:
 Run this script to get an overview of the most important waits going on on the
 server. Waits types that take up less than 1% are not included in the output.
 ********************************************************************************/
 
;WITH TMP AS
(
	SELECT
		wait_type AS [Wait Type],
		waiting_tasks_count AS [Count],
		CAST(wait_time_ms / 1000.0 AS DECIMAL(14, 2)) AS [Wait Time in S],
		CAST(signal_wait_time_ms / 1000.0 AS DECIMAL(14, 2)) AS [Signal Wait Time in S],
		wait_time_ms / waiting_tasks_count AS [Wait Per Task in MS],
		max_wait_time_ms AS [Max Wait Time in S],
		CAST((wait_time_ms - signal_wait_time_ms) / 1000.0 AS DECIMAL(14, 2)) AS [Resource Wait Time in S]
	FROM
		sys.dm_os_wait_stats
	WHERE
		wait_time_ms - signal_wait_time_ms > 0 AND
		wait_type NOT IN (
			'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
			'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
			'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
			'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
			'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
			'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
			'BROKER_RECEIVE_WAITFOR', 'ONDEMAND_TASK_QUEUE', 'DBMIRROR_EVENTS_QUEUE',
			'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES',
			'SLEEP_BPOOL_FLUSH', 'SQLTRACE_LOCK', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION', 'DIRTY_PAGE_POLL',
			'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', 'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP'
		)
), TMP2 AS (
	SELECT
		[Wait Type],
		CAST([Wait Time in S] / SUM([Wait Time in S]) OVER() * 100 AS DECIMAL(14, 2)) AS [Percentage],
		[Wait Time in S],
		[Wait Time in S] - [Signal Wait Time in S] AS [Resource Wait Time in S],
		[Signal Wait Time in S],
		CAST([Wait Time in S] / [Count] * 1000 AS DECIMAL(14, 2)) AS [Avg Wait in MS],
		CAST([Resource Wait Time in S] / [Count] * 1000 AS DECIMAL(14, 2)) AS [Avg Resource Waint in MS],
		CAST([Signal Wait Time in S] / [Count] * 1000 AS DECIMAL(14, 2)) AS [Avg Signal Wait in MS],
		[Count]
	FROM
		TMP
)
SELECT
	*
FROM
	TMP2
WHERE
	Percentage >= 1 -- Percentage threshold
ORDER BY
	Percentage DESC
