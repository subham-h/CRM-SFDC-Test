/*
* @Name: OrgPercentageCoverageWrapper
* @Description: Response wrapper class to sort map by value used in Schedule_MyNameSpaceApexTestResult class. 
*
* Version  Date         Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      28/08/2019   sidhartha.mohapatra@maersk.com           	       	   Created Class
*/
public class OrgPercentageCoverageWrapper {
    
    /*
     * @description size
     * @return size 
     */
	public Integer size {get;set;} 
    
    /*
     * @description totalSize
     * @return totalSize 
     */
    public Integer totalSize {get;set;} 
    
    /*
     * @description done checkbox
     * @return boolean 
     */
    public Boolean done {get;set;} 
    
    /*
     * @description querylocator
     * @return object 
     */
    public Object queryLocator {get;set;} 
    
    /*
     * @description entityTypeName
     * @return Name 
     */
    public String entityTypeName {get;set;} 
    
    /*
     * @description list of records
     * @return List<records> 
     */
    public List<Records> records;
    
    /*
     * @description Records class
     */
    public class Records{
        public Attributes attributes {get;set;} 
        public Integer percentCovered;
    }
    /*
     * @description Attributes class
     */
    public class Attributes {
		public String type {get;set;}
		public String url {get;set;} 
    }
}