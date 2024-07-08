/*  
* Version	Date			#Reference				Owner					Description
1.0         17-04-2024      SFSE-11169              Sunil.bs                Gets opportunity score from GDA and updates on the SF field
*/
public class OpportunityScoringEventHandler {
    //Wrapper class to hold incoming response
    public class oppWrapper {
        public string opportunityIdentifier; //opportunityIdentifier
        public string winProbablity;	//Field to identify unique opportunity
    }
    
    public static oppWrapper parse(String json){
        return (oppWrapper) System.JSON.deserialize(json, oppWrapper.class);
    }
    
    /**
* @description | Read and update opportunity score flowing from GDA via events
* @param newList incoming platfrom events
* SFSE-11169
*/
    public static void updateOpportunityScoring(List<Opportunity_Scoring_Event__e> newList) {
        try{
            list<oppWrapper> oppWrapList= new list<oppWrapper>();
            List<opportunity> oppList = new List<opportunity>();
            for(Opportunity_Scoring_Event__e oppScoreEvObj:newList){             
                string jsonSTR = '';
                if(string.isnotblank(oppScoreEvObj.JSON_1__c)){
                    jsonSTR = oppScoreEvObj.JSON_1__c;
                    oppWrapper res = parse(jsonSTR);
                    oppWrapList.add(res);  
                }
            }          
            
            map<id,opportunity> oppMap = new map<id,opportunity>();
            for(oppWrapper objIntance:oppWrapList){
                Opportunity opp = new Opportunity();
                if(objIntance!=null && string.isnotblank(objIntance.opportunityIdentifier) && string.isnotblank(objIntance.opportunityIdentifier)){
                    //contains opportunity id
                    opp.id = (id)objIntance.opportunityIdentifier;
                    //contains opportunity score
                    opp.Opportunity_Score__c = decimal.valueOf(objIntance.winProbablity);
                    oppMap.put(opp.id,opp);
                }
            }
            
            if(!oppMap.isempty()){
                for(opportunity opp:[select id, opportunity_score__c from opportunity where id in:oppMap.keyset()]){
                    //We try to check if we are getting a new value for opportunity score only then we will attempt to update value for it
                    if(opp.Opportunity_Score__c == Null){
                        if(oppMap.containskey(opp.id)){
                        	opp.Opportunity_Score__c = oppMap.get(opp.id).opportunity_score__c;
                        }
                        oppList.add(opp);
                    }
                    else if(opp.Opportunity_Score__c!=oppMap.get(opp.id).opportunity_score__c){
                         if(oppMap.containskey(opp.id)){
                        	opp.Opportunity_Score__c = oppMap.get(opp.id).opportunity_score__c;
                        }
                        oppList.add(opp);
                    }
                }
            }
            
            if(!oppList.isempty()){
            TriggerExecutionController.skipAllTriggers(true);
            Database.saveResult[] oppUpdateResList= database.update(oppList,false);
            TriggerExecutionController.skipAllTriggers(false);
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'OpportunityScoringEventHandler.updateOpportunityScoring', oppUpdateResList, oppList);
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'OpportunityScoringEventHandler.updateOpportunityScoring', new list <Exception> {ex});  
        }
    }
}