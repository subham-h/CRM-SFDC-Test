public class CorridorGuidanceResponse extends AuraResponse {

    @AuraEnabled public Corridor_Guidance__c cgRec { get; set; }
    @AuraEnabled public List<Corridor_Guidance_Detail__c> cgDetailList{ get; set; }
    @AuraEnabled public OpportunityLineItem oliRec { get; set; }
    @AuraEnabled public integer TenderDuration { get; set; }
    @AuraEnabled public decimal TotalTarget { get; set; }
    @AuraEnabled public decimal SumRemainder { get; set; }
    @AuraEnabled public decimal Gap { get; set; }
    @AuraEnabled public decimal SumOfTopCorridors{ get; set; }
    @AuraEnabled public integer SOW{ get; set; }
    @AuraEnabled public decimal routeDirActual{ get; set; }
    @AuraEnabled public decimal routeDirCY{ get; set; }
    @AuraEnabled public Boolean isSuccess { get; set; }
    @AuraEnabled public List<String> listMessage { get; set; }
    @AuraEnabled public String TenderDurationError { get; set; }
    @AuraEnabled public decimal TradeAverage { get; set; }
    @AuraEnabled public decimal Previous_CY_FFE { get; set; }
    @AuraEnabled public decimal Target_CY_FFE { get; set; }
    @AuraEnabled public decimal Delta_CY_FFE { get; set; }
    
    
    public CorridorGuidanceResponse (){
        
        isSuccess = true;
        listMessage = new List<String>();
        cgDetailList = new List<Corridor_Guidance_Detail__c>();
        routeDirCY = 0;
        routeDirActual = 0;
        SOW = 0;
        SumOfTopCorridors = 0;
        TotalTarget = 0;
        SumRemainder = 0;
        TenderDuration = 0;
		Gap = 0;        
        TenderDurationError = '';
        TradeAverage = 0;
        Previous_CY_FFE  = 0;
    	Target_CY_FFE  = 0;
    	Delta_CY_FFE  = 0;
    
    }
}