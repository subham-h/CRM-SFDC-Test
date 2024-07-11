/** 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-8631     24-Apr-2024   Kiran@maersk       	Auto Case Assignment - Ocean - based on Cargo types - Reefer, OOG, Break Bulk
 * 
 */

global class BreakBulkWrapper {
    
    public String isBreakBulk {get;set;}
    
    public static BreakBulkWrapper parseBreakBulk(String json){
		return (BreakBulkWrapper) System.JSON.deserialize(json, BreakBulkWrapper.class);
	}
    
}