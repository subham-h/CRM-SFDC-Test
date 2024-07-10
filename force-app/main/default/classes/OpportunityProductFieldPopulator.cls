/*      
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0      SFSE-10984  16-May-2023     mahanthi.devi@maersk.com        To replicate standard OLI Trigger Logic on cutom object Opportunity Product .
* 2.0      SFSE-10599  15-09-2023      Aleena@Maersk.com               To remove reference of Nominated Quantity 
* 3.0      SFSE-14324  21/03/2024     ramadevi@maersk                 Update the Recommendation is the Opportunity Product is deleted  
* 4.0      SFSE-14825  28-May-2024     Avinash@Maersk              		"Cargo type" on Opportunity level
*/
public class OpportunityProductFieldPopulator {
    
    //SFSE-14825
    public static void updateOptyCargoType(Set<string> setOptyToUpdtCargoType){
            try{
                Map<Id,Set<String>> mapOptyIdtoSetCargoTypeValues = new Map<Id,Set<String>>();
                for(Opportunity_Product__c optyProd : [Select Cargo_Type__c,OpportunityId__c from Opportunity_Product__c where OpportunityId__c =: setOptyToUpdtCargoType]){
                    if(mapOptyIdtoSetCargoTypeValues.containsKey(optyProd?.OpportunityId__c)){
                        mapOptyIdtoSetCargoTypeValues.get(optyProd?.OpportunityId__c).add(optyProd?.Cargo_Type__c);
                    }else{
                        mapOptyIdtoSetCargoTypeValues.put(optyProd?.OpportunityId__c,new Set<String>{optyProd?.Cargo_Type__c});
                    }
                }
                List<Opportunity> lstOptyToUpdtCargoType = new List<Opportunity>();
                for(Opportunity optyRec : [Select Id,Cargo_type__c from Opportunity where Id =: setOptyToUpdtCargoType]){
                    if(mapOptyIdtoSetCargoTypeValues.containsKey(optyRec?.Id)){
                        optyRec.Cargo_type__c = String.join((Iterable<String>)mapOptyIdtoSetCargoTypeValues.get(optyRec.Id),';');
                        lstOptyToUpdtCargoType.add(optyRec);
                    }
                    else{
                        optyRec.Cargo_type__c = '';
                        lstOptyToUpdtCargoType.add(optyRec);
                    }
                }
                if(!lstOptyToUpdtCargoType.isEmpty() && lstOptyToUpdtCargoType.size() > 0){
                    update lstOptyToUpdtCargoType;
                }
            }
            catch(Exception e){
                ErrorLogger.writeErrors( 'SFDC', 'OpportunityProduct', 'OpportunityProductFieldPopulator.updateOptyCargoType', new list<Exception>{e});
            }
        }
    
    public static void updateOpptyProdFields(list<Opportunity_Product__c> lstOpptyProducts, map<Id, Opportunity_Product__c> oldOpptyProductsMap, Boolean VRBypassIsActive, Map<id,Boolean> OpportunityClosedmap) {
        
        String OtherProductName = Label.OtherProductRouteCode;
        Boolean optOutchk;
        for( Opportunity_Product__c op : lstOpptyProducts ){         
            
            //#RQ-000139 - Start - Added condition to exclude the below validation error for Unassigned product 
            //#RQ-000601 - Allow user to edit the Revenue Schedule on a closed Opportunity. 
            
            if( OpportunityClosedmap.get(op.OpportunityId__c)!=null && OpportunityClosedmap.get(op.OpportunityId__c) == True  && !Trigger.isUpdate && VRBypassIsActive != true ){
                
                op.addError(' '+Label.ExpectedErrorLabel);
                
            }
        }
    }
    
    // v5.0 - method to update Amend Quantity based on Product Owner Target or Nominated Qunatity
    // Soft deprecating Nominated Quantity 
    public static void updateAmendQty (list<Opportunity_Product__c> lstOppProd_ProductOwnerTarget/* list<Opportunity_Product__c> lstOppProd_NominatedQty*/){
        
        for (Opportunity_Product__c recOppProd : lstOppProd_ProductOwnerTarget){
            recOppProd.Amend_Expected_FFE__c = recOppProd.Tender_Target__c;
        }
        
       /* for (Opportunity_Product__c recOppProd : lstOppProd_NominatedQty){
            recOppProd.Amend_Expected_FFE__c = recOppProd.Nominated_Quantity__c;
        }*/
        system.debug('@@@ lstOli_ProductOwnerTarget '+ lstOppProd_ProductOwnerTarget);
    }
    
    public static void updateOpptyProdName(List<Opportunity_Product__c> lstOpptyProducts, map<Id, Opportunity_Product__c> oldOpptyProductsMap, Boolean VRBypassIsActive, map<Id, Opportunity> opptyMap,map<Id,Product2> prodMap){
        String opptyProdName;        
        for( Opportunity_Product__c op : lstOpptyProducts ){
            
            //Update Opportunity product name field
            if(op.OpportunityId__c != null && op.Product2ID__c != null && Trigger.isBefore && 
               (Trigger.isInsert || (Trigger.isUpdate && (op.OpportunityId__c != oldOpptyProductsMap.get(op.Id).OpportunityId__c || op.Product2ID__c != oldOpptyProductsMap.get(op.Id).Product2ID__c) ))){
                   opptyProdName = opptyMap.get(op.OpportunityId__c).Name +' - ' + prodMap.get(op.Product2ID__c).Name;
                   op.Name = opptyProdName.length() <= 80 ? opptyProdName : opptyProdName.substring(0,79);
            }
            
        }
        
    }

    //SFSE-14324
    /*public static void updateRecommendationAsInvalid(List<String> OpptyList, set<Id> oppRecomUpdateType){
        List<String> OceanCodes = new List<String>();
        OceanCodes.addAll(Label.Ocean_Products_for_Intermodal_Recommendation.split('\\,'));
        Set<Id> OceanoppProdList = new Set<Id>();
        for(Opportunity_Product__c opProd : [SELECT id,OpportunityId__c from Opportunity_Product__c where OpportunityId__c in :OpptyList and OIPC_Product_Code__c in :OceanCodes]) {
            OceanoppProdList.add(opProd.OpportunityId__c);          
            
        }
        
        List<Recommendation__c> recomList = [select id,Is_valid__c,Is_User_Action_Mandatory__c,Recommendation_Id__c,Recommendation_Item_Reference__c,Recommendation_Object__c,Recommended_To__c,RecordTypeId,Rejection_Reason__c,Status__c,Recommendion_Related_Id__c from Recommendation__c where Recommended_To__c in :OpptyList and Is_valid__c=true];
        for(Recommendation__c recom : recomList){
            if(oppRecomUpdateType.contains(recom.Recommendion_Related_Id__c) && recom.Status__c == 'Accepted'){
               recom.Rejection_Reason__c ='Product removed by user manually.';
               recom.Is_valid__c = false;
               break;
            }
            if(!OceanoppProdList.contains(recom.Recommended_To__c)) {
                recom.Is_valid__c = false;
            }
        }
        update recomList;
    }*/
    //SFSE-14324
    public static void updateRecommendationAsInvalid(Map<String,String> OpptyMap, set<Id> oppRecomUpdateType){
        system.debug('in field populator');
        List<String> OceanCodes = new List<String>();
        OceanCodes.addAll(Label.Ocean_Products_for_Intermodal_Recommendation.split('\\,'));
        Set<Id> OceanoppProdList = new Set<Id>();
        for(Opportunity_Product__c opProd : [SELECT id,OpportunityId__c from Opportunity_Product__c where OpportunityId__c in :OpptyMap.keyset() and OIPC_Product_Code__c in :OceanCodes]) {
            OceanoppProdList.add(opProd.OpportunityId__c);
        }
        
        List<Recommendation__c> recomList = [select id,Is_valid__c,Is_User_Action_Mandatory__c,Recommendation_Id__c,Recommendation_Item_Reference__c,Recommendation_Object__c,Recommended_To__c,RecordTypeId,Rejection_Reason__c,Status__c,Recommendion_Related_Id__c from Recommendation__c where Recommended_To__c in :OpptyMap.Keyset() and Is_valid__c=true];
        for(Recommendation__c recom : recomList){
            if(OpptyMap.get(recom.Recommended_To__c) == recom.Recommendation_Id__c){
                if(oppRecomUpdateType.contains(recom.Recommendion_Related_Id__c) && recom.Status__c == 'Accepted'){
                    recom.Rejection_Reason__c ='Product removed by user manually.';
                    recom.Is_valid__c = false;
                    system.debug('recom##'+recom);
                    break;                    
                }
                if(!OceanoppProdList.contains(recom.Recommended_To__c)) {
                    recom.Is_valid__c = false;
                }
            }            
        }
        system.debug('recomList==>'+recomList);
        update recomList;
    }
}