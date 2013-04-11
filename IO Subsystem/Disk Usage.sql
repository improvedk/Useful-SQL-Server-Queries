/********************************************************************************
 Title:			Disk Usage
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 List of all disks on which there are files, including overall usage statistics.
 ********************************************************************************/

WITH TMP AS
(
	SELECT
		f.type_desc AS [Type],
		SUBSTRING(f.physical_name, 1, 1) AS [Drive Letter],
		s.size_on_disk_bytes / 1024 / 1024 AS [Size in MB],
		CAST(CAST(s.io_stall_read_ms AS FLOAT) / CAST(s.num_of_reads AS FLOAT) AS DECIMAL(10, 2)) AS [Read Latency in MS],
		CAST(CAST(s.io_stall_write_ms AS FLOAT) / CAST(s.num_of_writes AS FLOAT) AS DECIMAL(10, 2)) AS [Write Latency in MS],
		s.num_of_reads AS [Num Reads],
		s.num_of_bytes_read / s.num_of_reads AS [Avg Bytes Per Read],
		s.num_of_bytes_read / 1024 / 1024 AS [Total Reads in MB],
		s.num_of_writes AS [Num Writes],
		s.num_of_bytes_written / s.num_of_writes AS [Avg Bytes Per Write],
		s.num_of_bytes_written / 1024 / 1024 AS [Total Writes in MB]
	FROM
		sys.dm_io_virtual_file_stats(NULL, NULL) s
	INNER JOIN
		sys.master_files f ON f.database_id = s.database_id AND f.file_id = s.file_id
)
SELECT
	[Drive Letter],
	[Type],
	SUM([Size in MB]) / 1024 AS [Total Size in GB],
	AVG([Read Latency in MS]) AS [Avg Read Latency in MS],
	AVG([Write Latency in MS]) AS [Avg Write Latency in MS],
	SUM([Num Reads]) AS [Num Reads],
	SUM([Num Writes]) AS [Num Writes],
	SUM([Total Reads in MB]) / 1024 AS [Total Reads in GB],
	SUM([Total Writes in MB]) / 1024 AS [Total Writes in GB]
FROM
	TMP
GROUP BY
	[Type],
	[Drive Letter]