public abstract class AuraResponse {

    @AuraEnabled public Boolean isSuccess { get; set; }
    @AuraEnabled public String level { get; set; }
    @AuraEnabled public List<String> lstMessage { get; set; }

    public AuraResponse ( Boolean isSuccess, String level, List<String> lstMessage ){

        this.isSuccess = isSuccess;
        this.level = level;
        this.lstMessage = lstMessage;

    }
    
    public AuraResponse (){
    
        lstMessage = new List<String>();
    }
    
}