/*
* version       Date                Owner                                       Description
*******************************************************************************************************
 * 1.0      RQ-003402   20-Jul-2016     kishore.dupam@ust-global.com   Code created
 **         
------------------------------------------------------------------------------------------------------
*/
public class CorridorGuidanceUtilities{
    
    public static void populateTradeGuidanceId( List<Corridor_Guidance__c> newTriggerList ){
        
        // get list of oppty id & product Ids
        List<Id> OpptyIds = new List<ID>();
        List<Id> RouteIds = new List<ID>();
        Map<String, Id> OpptyProdToTradeGuidanceMap = new Map<String, Id>();
        
        for( Corridor_Guidance__c recTG: newTriggerList ){
        
            if ( recTG.Opportunity__c != null && recTG.Product__c != null ){
                OpptyIds.add ( recTG.Opportunity__c );
                RouteIds.add ( recTG.Product__c );
                OpptyProdToTradeGuidanceMap.put( recTG.Opportunity__c + '_' + recTG.Product__c, recTG.Id );
        
            }
        }
        
        List<OpportunityLineItem> oliList= [ SELECT Id, Trade_Guidance_Id__c, OpportunityId, Product2Id 
                                            FROM OpportunityLineItem
                                            Where OpportunityId in :OpptyIds and Product2Id in :RouteIds ];
                                            
        List<OpportunityLineItem> updateOLIList = new List<OpportunityLineItem>();
        
        for( OpportunityLineItem oli: oliList ){
            
            if( OpptyProdToTradeGuidanceMap.containsKey( oli.OpportunityId + '_' + oli.Product2Id ) ) {
                
                oli.Trade_Guidance_Id__c = OpptyProdToTradeGuidanceMap.get( oli.OpportunityId + '_' + oli.Product2Id ) ;
                updateOLIList.add(oli);
                
            }       
        }
        
        if( updateOLIList.size() > 0 ){
            
            Database.update ( updateOLIList, false) ;
        
        }
    }
    
    public Static void deleteTradeGuidanceId ( Map<Id, Corridor_Guidance__c> oldMap){
        
  
        Set<Id> setCorrGuidanceIds = oldMap.keyset();
        system.debug ('$$$ setCorrGuidanceIds :' +setCorrGuidanceIds );
        
        list<OpportunityLineItem> oliList = [ SELECT Id, Trade_Guidance_Id__c FROM OpportunityLineItem
                                                Where Trade_Guidance_Id__c IN :setCorrGuidanceIds ];
     
        for( OpportunityLineItem oli: oliList ){
            
            oli.Trade_Guidance_Id__c = '';
                
        }
                 
        if( oliList.size() > 0 ){
            
            Database.update ( oliList , false) ;
        
        }
        
    }
}