public class CaseHistoryWrapper {
    
    public String id {get;set;} 
    public String caseid {get;set;} 
    public String createdbyid {get;set;} 
    public String createddate {get;set;} 
    public String field {get;set;} 
    public String newvalue {get;set;} 
    public String oldvalue {get;set;} 
    public String datatype {get;set;} 
    
    public CaseHistoryWrapper(String caseid, String createddate, String fieldName, String newValue, String oldValue, String createdbyid){
        this.id = StaticFactory.generateRandomNumber(20);
        this.caseid = caseid;
        this.createdbyid = createdbyid;
        this.createddate = createddate;
        this.field = fieldName;
        this.newvalue = newValue;
        this.oldvalue = oldValue;
        this.datatype = 'Text';
    }    
    
}