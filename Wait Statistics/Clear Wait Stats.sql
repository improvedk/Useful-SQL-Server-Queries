/********************************************************************************
 Title:			Clear Wait Stats
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 Running this clears all wait statistics for the server as a whole. This does not
 impact performance in any way.
 ********************************************************************************/
 
 DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)