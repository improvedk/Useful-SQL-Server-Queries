/*
	Title:       How are indexes being used
	Created by:  Mark S. Rasmussen <mark@improve.dk>
	License:     CC BY 3.0
*/

WITH TMP AS (
	SELECT
		d.name,
		OBJECT_NAME(s.object_id) AS object_name,
		ISNULL(i.name, '(Heap)') AS index_name,
		user_seeks,
		user_scans,
		user_lookups,
		user_seeks + user_scans + user_lookups as total_reads,
		user_updates,
		CASE
			WHEN (user_seeks + user_scans + user_lookups = 0) THEN
				'UNUSED'
			WHEN (user_seeks + user_scans < user_updates) THEN
				'UPDATES > READS'
			WHEN (user_seeks < user_scans) THEN
				'SCANS > SEEKS'
			ELSE
				' '
		END AS Warning
	FROM
		sys.dm_db_index_usage_stats s
	INNER JOIN
		sys.indexes i ON
			i.object_id = s.object_id AND
			i.index_id = s.index_id
	INNER JOIN
		sys.databases d ON
			d.database_id = s.database_id
	WHERE
		d.name = DB_NAME() AND
		OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
)
SELECT * FROM TMP

-- Top scanned indexes
ORDER BY 
	user_scans DESC

-- Bookmark lookups
ORDER BY
	user_lookups DESC

-- Write-only indexes
WHERE
	total_reads = 0
