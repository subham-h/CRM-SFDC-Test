/*      
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0      SFSE-14324  20-03-2024     ramadevi.p@maersk.com        Controller for lwcRecommendation lwc component
* 2.0      SFSE-15072  01-07-2024     ramadevi.p@maersk.com        For Customer Insight related Recommendations, Check for the Insight score everytime the recommendation is given 
*/
public class AIRecommendationController {
    @AuraEnabled
    public static String saveRecommendations(String jsonStr){
        Recommendation__c recomUpdate = new Recommendation__c();
        system.debug('jsonStr==>'+jsonStr);
        if(jsonStr <> NULL){
            recomUpdate= (Recommendation__c)JSON.deserialize(jsonStr,Recommendation__c.class);
        }
        try{
            if(recomUpdate.Recommendation_Object__c == 'Opportunity' && recomUpdate.Status__c == 'Accepted'){
                opportunity_product__c oppProd = [select id,OIPC_Product_Code__c from opportunity_product__c where OpportunityId__c =:recomUpdate.Recommended_To__c and  OIPC_Product_Code__c =: recomUpdate.Recommendation_Item_Reference__c order by createddate desc limit 1];
                recomUpdate.Recommendion_Related_Id__c = oppProd.Id;
            }
            system.debug('before update==>'+recomUpdate);
            update recomUpdate;
        } catch(exception e){
            return 'Error';
        }
        return 'success';
    }
    
    @AuraEnabled
    public static List<RecommendationWrapper> getRecommendations(String recId,String ObjName){
        List<Recommendation__c> recommendationList = new List<Recommendation__c>();
        List<Recommendation__c> recommList = new List<Recommendation__c>();
        List<String> ProductCodeIdList = new List<String>();
        List<RecommendationWrapper> recomWrapperList = new List<RecommendationWrapper>();
        Map<String,RecommendationWrapper> recomwarapperMap = new Map<String,RecommendationWrapper>();
        Map<String,Product2> ProductCodeMap = new Map<String,Product2>();
        List < Recommendation_Action__c > recomActions = new List < Recommendation_Action__c >();
        Boolean alreadyActionedExist = false;
        List<Id> recomIdList = new list<Id>();
        List<Recommendation__c> UpdateRecomAsInvalid = new List<Recommendation__c>();
                
        //1. Check there are any recommendation records created for the Opportunity
        recommList = [select id,Recommendion_Related_Id__c,Is_valid__c,Is_User_Action_Mandatory__c,Recommendation_Id__c,Recommendation_Item_Reference__c,Recommendation_Object__c,Recommended_To__c,RecordTypeId,Rejection_Reason__c,Status__c from Recommendation__c where Recommended_To__c=:recId];
        
        if(recommList.size() > 0) { 
            List<Id> recomDefIdlist = new List<Id>();
            for(Recommendation__c rec : recommList) {               
                if(rec.Is_valid__c == true && rec.status__c == NULL && rec.Rejection_reason__c == NULL){                    
                    recomDefIdlist.add(Id.Valueof(rec.Recommendation_Id__c));
                }
            }

            //For Customer Insight Related Recommendations check the Customer Insight Score before showing the recommendation if exists
            Opportunity oppRecord = [SELECT id,Account.Customer_Insights_Score__c from Opportunity where id=:recId];
            List<Recommendation_Condition__c> conditionList = [SELECT id,Recommendation_Definition__c,Field_Name__c, Condition__c, Expected_Value__c from Recommendation_Condition__C where Recommendation_Definition__c in:recomDefIdlist and Field_Name__c = 'Account.Customer_Insights_Score__c'];
                        
            for(Recommendation__c rec : recommList) {
                system.debug('====>'+rec.Recommendation_Id__c == Label.Intermodal_Customer_Insight_Rule_Id);
                    if(rec.Recommendation_Id__c == Label.Intermodal_Customer_Insight_Rule_Id){
                        if(conditionList <> NULL){
                            for(Recommendation_Condition__c recCon : conditionList){
                                if(rec.recommendation_id__c == recCon.Recommendation_Definition__c && !((recCon.Condition__c == '>' && oppRecord.Account.Customer_Insights_Score__c > Integer.Valueof(recCon.Expected_Value__c))||(recCon.Condition__c == '>=' && oppRecord.Account.Customer_Insights_Score__c >= Integer.Valueof(recCon.Expected_Value__c))||(recCon.Condition__c == '<' && oppRecord.Account.Customer_Insights_Score__c < Integer.Valueof(recCon.Expected_Value__c))||(recCon.Condition__c == '>=' && oppRecord.Account.Customer_Insights_Score__c <= Integer.Valueof(recCon.Expected_Value__c)) || (recCon.Condition__c == '=' && oppRecord.Account.Customer_Insights_Score__c == Integer.Valueof(recCon.Expected_Value__c)))){
                                {                                
                                    rec.Is_valid__c = false;
                                    Recommendation__c updRecom = rec;
                                    system.debug('Before Update'+updRecom);
                                    UpdateRecomAsInvalid.add(updRecom);
                                }
                            }
                        }
                    }
                }

                if((rec.Is_valid__c && rec.status__c <> NULL) || (rec.Is_valid__c == false && rec.status__c <> NULL && rec.Rejection_reason__c <> NULL)){
                    alreadyActionedExist = true;                    
                }
                if(rec.Is_valid__c == true && rec.status__c == NULL && rec.Rejection_reason__c == NULL){
                    recommendationList.add(rec);
                    recomIdList.add(Id.Valueof(rec.Recommendation_Id__c));
                }
            }
            update UpdateRecomAsInvalid;
        }

        if(recommendationList.size() == 0 && alreadyActionedExist == false) { // considering there are no recommendations created for the record yet
            //Call the AIRecommendation12 to get the list of recommendations applicable for the record
            List<Recommendation_Definition__c> avlRecommDef = new List<Recommendation_Definition__c>();
            avlRecommDef = AIRecommendationUtilityClass.getRecommendation(recId,ObjName);
            
            if(avlRecommDef<> null && avlRecommDef.size()>0){                
                List<Recommendation__c> updateRecomList = new List<Recommendation__c>();
                //check for if the valid exist and actioned earlier
                List<Opportunity_Product__c> childCloseLostIMCHList = new List<Opportunity_Product__c>();
                if(ObjName == 'Opportunity') {
                    childCloseLostIMCHList=[SELECT id from Opportunity_Product__c where OpportunityId__r.Lost_Product_Parent_Opportunity__c =:recId and OIPC_Product_Code__c  = 'P-P0-20jb'];
                }
                // Create new recommendation and show to the user
                for(Recommendation_Definition__c recomDef:avlRecommDef){
                    if(ObjName == 'Opportunity'){
                        if(childCloseLostIMCHList <> NULL && childCloseLostIMCHList.size()==0){ 
                            system.debug('creating the recommendation');
                            //if ClosedLost Opp with Intermodal Exist already recommendation should not be given
                            recomIdList.add(recomDef.Id);
                            Recommendation__c newRecom = new Recommendation__c();
                            newRecom.recordtypeId = StaticFactory.getRecordTypeIdByName('Recommendation__c','Sales');                    
                    newRecom.Is_User_Action_Mandatory__c = recomDef.Is_User_Action_Mandatory__c;
                    newRecom.Recommendation_Id__c = recomDef.Id;
                    newRecom.Recommendation_Item_Reference__c = recomDef.Recommended_Item_Reference__c;
                    newRecom.Recommendation_Object__c = ObjName;
                    newRecom.Recommended_To__c = recId;
                    newRecom.Is_valid__c = true;
                    newRecom.Status__c = null;
                    newRecom.Recommendion_Related_Id__c = null;                    
                    updateRecomList.add(newRecom);
                }
                    }
                }
                insert updateRecomList;
                recommendationList.addAll(updateRecomList);
            }
        }
        system.debug('recommendationList==>'+recommendationList);
        if(recommendationList.size() > 0) {
			Map<id,List<Recommendation_Action__c>> AcceptActionMap = new Map<id,List<Recommendation_Action__c>>();
            Map<id,List<Recommendation_Action__c>> RejectActionMap = new Map<id,List<Recommendation_Action__c>>();
            Map<id,String> descriptionMap = new Map<id,String>();
			recomActions = [SELECT id, Action__c, Action_Component__c, Action_Type__c, Recommendation_Definition__c,Recommendation_Definition__r.Insight__c, Rejection_Reason__c,Order__c from Recommendation_Action__c where Recommendation_Definition__c in :recomIdList];
			for(Recommendation_Action__c action:recomActions){
                descriptionMap.put(action.Recommendation_Definition__c,action.Recommendation_Definition__r.Insight__c);
                if(action.Action__c == 'Accept'){
                    if(AcceptActionMap.containsKey(action.Recommendation_Definition__c)){
                        AcceptActionMap.get(action.Recommendation_Definition__c).add(action);
                    } else {
                        AcceptActionMap.put(action.Recommendation_Definition__c, new List<Recommendation_Action__c>{action});
                    }
                } else {
                    if(RejectActionMap.containsKey(action.Recommendation_Definition__c)){
                        RejectActionMap.get(action.Recommendation_Definition__c).add(action);
                    } else {
                        RejectActionMap.put(action.Recommendation_Definition__c, new List<Recommendation_Action__c>{action});
                    }
                }
				
				
			}
			
            for(Recommendation__c rec : recommendationList) {                
                if(rec.status__c == NULL && rec.Is_valid__c == true){
                    //considering the recommendation already exist
                    for(Recommendation__c recom : recommendationList){
                            RecommendationWrapper recomwrapper = new RecommendationWrapper(); 
							
                            recomwrapper.recomId = recom.Id;							
							recomwrapper.recommendationRecord = recom;
							
                            recomwrapper.ProdDescription = descriptionMap.get(recom.Recommendation_Id__c);
                            ProductCodeIdList.add(recom.Recommendation_Item_Reference__c);
                            recomwarapperMap.put(recom.Recommendation_Item_Reference__c,recomwrapper);
                            if(AcceptActionMap.containskey(recom.Recommendation_Id__c) && AcceptActionMap.get(recom.Recommendation_Id__c).size() > 0) {
							recomwrapper.acceptActionList.addAll(AcceptActionMap.get(recom.Recommendation_Id__c));
                            }
                            if(RejectActionMap.containskey(recom.Recommendation_Id__c) && RejectActionMap.get(recom.Recommendation_Id__c).size()>0) {
                            recomwrapper.rejectActionList.addAll(RejectActionMap.get(recom.Recommendation_Id__c));
                            }
                    }
                    for(Product2 prod : [SELECT id,OIPC_Code__c,Name, Description__c  from Product2  where OIPC_Code__c in :ProductCodeIdList]){
                            ProductCodeMap.put(prod.OIPC_Code__c,prod);
                    }
                    for(String str:recomwarapperMap.Keyset()){
                        if(ProductCodeMap.containsKey(str)){
                            RecommendationWrapper temprecWrapper = recomwarapperMap.get(str);
                            //temprecWrapper.ProdDescription = ProductCodeMap.get(str).Description__c;
                            temprecWrapper.ProductId = ProductCodeMap.get(str).Id;
                            temprecWrapper.ProductName = ProductCodeMap.get(str).Name;
                            recomwarapperMap.put(str,temprecWrapper);
                        }
                    }
        
                }
            }
        }
            
        List<RecommendationWrapper> returnList = new List<RecommendationWrapper>();
        returnList.addAll(recomwarapperMap.values());
        return returnList;
        
    }

    public class RecommendationWrapper{
        @AuraEnabled
        public Id recomId;
		@AuraEnabled
        public Recommendation__c recommendationRecord;
		
        @AuraEnabled
        public String ProdDescription; // Description of the Product
        @AuraEnabled
        public String ProductId; // Id of the Product
        @AuraEnabled
        public String ProductName; //Name of the Product
		
		@AuraEnabled
        public List<Recommendation_Action__c> acceptActionList= new List<Recommendation_Action__c>(); 
        @AuraEnabled
        public List<Recommendation_Action__c> rejectActionList = new List<Recommendation_Action__c>();

    }
}