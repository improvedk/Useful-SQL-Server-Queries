/********************************************************************************
 Title:			Clearing Plan Cache
 Created by:	Mark S. Rasmussen <mark@improve.dk>
 License:		CC BY 3.0
 
 Usage:
 These commands can be used to either wipe the whole cache or to just clear
 a specific plan from the cache.
 ********************************************************************************/
 
 /*
	This will clear all plans in the cache. Beware that this will cause recompiles
	of all queries on the server. This will increase CPU usage so beware before
	running this on a production system.
*/
DBCC FREEPROCCACHE



/*
	This clears just a single plan by referencing it's plan handle
*/
DBCC FREEPROCCACHE (0x06009800B81B733A40C1D0C1030000000000000000000000)