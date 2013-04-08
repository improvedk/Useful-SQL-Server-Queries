/********************************************************************************
 Title:			Updating Statistics
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 Here's a number of different ways to update statistics, depending on what you
 need to accomplish.
 ********************************************************************************/
 
-- Updates all stats on the table/indexes by using a full table scan
UPDATE STATISTICS [Table] WITH FULLSCAN

-- Updates all stats on the table/indexes by sampling 10 percent of the data
UPDATE STATISTICS [Table] WITH SAMPLE 10 PERCENT

-- Updates all stats on the table/indexes by sampling the first 1000 rows
UPDATE STATISTICS [Table] WITH SAMPLE 1000 ROWS

-- Updates all statistics for the specified index/table combo
UPDATE STATISTICS [Table] [Index]

-- Updates the specified statistics on the specified table
UPDATE STATISTICS [Table]([Statistics Name])