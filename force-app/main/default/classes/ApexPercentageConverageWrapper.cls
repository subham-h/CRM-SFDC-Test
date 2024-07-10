/*
* @Name: ApexPercentageConverageWrapper
* @description : Response wrapper class to sort map by value used in Schedule_MyNameSpaceApexTestResult class. 
*
* Version  Date         Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      28/08/2019   sidhartha.mohapatra@maersk.com           	       	   Created Class
*/
public class ApexPercentageConverageWrapper {
    /**
     * @description size
     * @return size
    */
	public Integer size {get;set;} 
    
    /**
     * @description totalSize
     * @return totalSize
    */
    public Integer totalSize {get;set;} 
    
    /**
     * @description Checkbox done
     * @return boolean
    */
    public Boolean done {get;set;} 
    
    /**
     * @description queryLocator
     * @return object
    */
    public Object queryLocator {get;set;} 
    
    /**
     * @description entitytypeName
     * @return name
    */
    public String entityTypeName {get;set;} 
    
    /**
     * @description list of records
     * @return List<records>
    */
    public List<Records> records {get;set;} 
    
    /*
     * @description Attributes wrapper 
     */
    public class Attributes {
        
     /**
     * @description type
     * @return string
     */
        public String type {get;set;}
        
     /**
     * @description url
     * @return string
      */
        public String url {get;set;} 
    }
    /*
     * @description ApexClassOrTrigger wrapper 
     */
    public class ApexClassOrTrigger {
        
     /**
     * @description attributes
     * @return attributes wrapper
     */
       public Attributes attributes {get;set;} 
        
     /**
     * @description name
     * @return string
      */
       public String name {get;set;} 
    }
     /*
     * @description records wrapper 
    */
    public class Records {
  
        public Attributes attributes {get;set;} 
        public String Id {get;set;} 
        public ApexClassOrTrigger apexClassOrTrigger {get;set;} 
        public Integer numLinesCovered {get;set;} 
        public Integer numLinesUncovered {get;set;}
    }
}