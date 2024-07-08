public class CorridorGuidanceQuartDealResponse extends AuraResponse{
    
    @AuraEnabled public Corridor_Guidance__c cgRec { get; set; }
    @AuraEnabled public List<Corridor_Guidance_Detail__c> cgQuartDealDetailList{ get; set; }
    @AuraEnabled public Boolean isSuccess { get; set; }
    @AuraEnabled public List<String> listMessage { get; set; }
	
 public CorridorGuidanceQuartDealResponse (){
    cgQuartDealDetailList = new List<Corridor_Guidance_Detail__c>();
     isSuccess = true;
     listMessage = new List<String>();
    
     
 }
}