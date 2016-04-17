/*
	Created by:  Mark S. Rasmussen <mark@improve.dk>
	License:     CC BY 3.0
*/

WITH TMP AS
(
	SELECT
		DB_NAME(database_id) AS database_name,
		OBJECT_NAME(object_id) AS table_name,
		(SELECT Name FROM sys.indexes WHERE index_id = ps.index_id AND object_id = ps.object_id) AS index_name,
		index_type_desc,
		alloc_unit_type_desc,
		avg_fragmentation_in_percent,
		fragment_count,
		avg_fragment_size_in_pages,
		page_count,
		page_count * 8 / 1024 AS 'disk size MB',
		avg_page_space_used_in_percent,
		record_count,
		min_record_size_in_bytes,
		avg_record_size_in_bytes,
		CASE
			WHEN avg_fragmentation_in_percent BETWEEN 0 AND 30 THEN
				'REORGANIZE'
			ELSE
				'REBUILD'
		END AS recommendation
	FROM
		sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'SAMPLED') ps
	WHERE
		avg_fragmentation_in_percent > 5 AND
		page_count >= 2560 -- We don't care about objects less than 20MB
),
TMP2 AS
(
	SELECT
		*,
		'ALTER INDEX [' + index_name + '] ON dbo.[' + table_name + '] REORGANIZE' AS sql_reorganize,
		'ALTER INDEX [' + index_name + '] ON dbo.[' + table_name + '] REBUILD' AS sql_rebuild
	FROM
		TMP
)
SELECT
	*,
	CASE recommendation
		WHEN 'REBUILD' THEN
			sql_rebuild
		ELSE
			sql_reorganize
	END AS sql_recommended
FROM
	TMP2
ORDER BY
	avg_fragmentation_in_percent DESC
