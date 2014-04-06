/********************************************************************************
 Title:                 File IO Usage
 Created by:            Mark S. Rasmussen <mark@improve.dk>
 License:               CC BY 3.0
 Requirements:          2005+
 
 Usage:
 List of all files in use and their IO usage.
 ********************************************************************************/

SELECT
	DB_NAME(s.database_id) AS [Database],
	s.file_id AS [File ID],
	f.type_desc AS [Type],
	f.physical_name AS [Path],
	f.is_percent_growth,
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
ORDER BY
	-- Overall most IOPS expensive
	s.num_of_reads + s.num_of_writes DESC
