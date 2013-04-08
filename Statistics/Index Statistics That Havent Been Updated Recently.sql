/********************************************************************************
 Title:			Index Statistics That Haven't Been Updated Recently
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 Running this returns a list of all statistics on indexes, including the last
 update date. Use this to find statistics that need to be updated, either by
 filtering on the object/index name or by the updated date directly.
 ********************************************************************************/
 
SELECT
	SCHEMA_NAME(o.schema_id) + '.' + o.name AS [Object Name],
	i.name AS [Index Name],
	i.type_desc AS [Index Type],
	STATS_DATE(i.object_id, i.index_id) AS [Last Updated]
FROM
	sys.indexes i
INNER JOIN
	sys.objects o ON o.object_id = i.object_id
WHERE
	o.type = 'U'
ORDER BY
	[Last Updated]