/********************************************************************************
 Title:         Settings Overview
 Created by:    Mark S. Rasmussen <mark@improve.dk>
 License:       CC BY 3.0
 Requirements:  2005+
 
 Usage:
 This query is meant to give you an overview of the server level settings as well
 as common recommendations.
 ********************************************************************************/

SELECT
	name,
	value,
	value_in_use,
	minimum,
	maximum,
	description,
	is_dynamic,
	is_advanced,
	CASE
		WHEN name = 'backup compression default' AND value = 0 THEN
			'It is generally recommended to enable backup compression unless you'' bound by CPU during backups.'
		WHEN name = 'clr enabled' AND value = 1 THEN
			'CLR should only be enabled if it''s needed, otherwise it''s better to leave it disabled.'
		WHEN name = 'max server memory (MB)' AND value = 2147483647 THEN
			'You should always specify a max value for the ''max server memory'' setting to avoid SQL Server starving the OS and/or other instances.'
		WHEN name = 'optimize for ad hoc workloads' AND value = 0 THEN
			'You should generally always enable the ''optimize for adhoc workloads'' setting.'
		ELSE
			NULL
	END AS Recommendation
FROM
	sys.configurations
ORDER BY
	name
