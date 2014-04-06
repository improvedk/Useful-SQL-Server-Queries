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
	is_advanced
FROM
	sys.configurations
ORDER BY
	name