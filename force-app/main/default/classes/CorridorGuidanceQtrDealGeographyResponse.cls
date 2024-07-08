public class CorridorGuidanceQtrDealGeographyResponse {
 
    @AuraEnabled public List<String> originList{ get; set; }
    @AuraEnabled public List<String> destList{ get; set; }
    @AuraEnabled public List<String> OriginDestPairList{ get; set; }
 
 	
    public CorridorGuidanceQtrDealGeographyResponse (){
       
        originList = new List<String>();
        destList = new List<String>();
        OriginDestPairList = new List<String>();        
        
    }
}