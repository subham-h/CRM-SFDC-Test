/*
 * Created By   : Ramadevi@UST
 * Purpose      : Centralize the record selection process for AFLS Quote object.
 *              
 * Revision Ref Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      #RQ-005525  21-Jul-2017     Ramadevi.palanisamy@ust-global.com   Formatted the trigger and introduced CBO architecture.
 *
 */

public class AFLSQuoteRecordSelector implements RecordSelector{

    private TriggerHandler aflsTriggerHandler; 
    
    public List<Qt_Quote__c> quoteToBeProcessed = new List<Qt_Quote__c>();
    public set<String>  oppToBeQueried = new set<String> ();
    public set<String> accToBeQueried = new set<String> ();
    public set<String> userToBeQueried = new set<String> ();
    public Map<String, Opportunity> oppDetails = new Map<String, Opportunity>();
    public Map<String, Account> accDetails = new Map<String, Account>();
    public Map<String, User> userDetails = new Map<String, User>();
    
    public aflsQuoteRecordSelector(list<Qt_Quote__c> lstQuotes, map<Id, Qt_Quote__c> mapOldQuotes, aflsQuoteTriggerHandler aflsTriggerHandler){
        this.aflsTriggerHandler = aflsTriggerHandler;
        selectRecords(lstQuotes, mapOldQuotes);
        this.getRelatedRecords(lstQuotes);
    }
    
    public void selectRecords(list<Qt_Quote__c> lstQuotes, map<Id,SObject> mapOldQuotes) {
        if (lstQuotes!=Null){        
            for(Qt_Quote__c aflsQt : lstQuotes){
                Qt_Quote__c oldQuote;
                if(mapOldQuotes!= null){
                    oldQuote= (Qt_Quote__c)mapOldQuotes.get(aflsQt.Id);
                }
                
                // on before insert/update, capture the afls quotes, its corresponding opportunity Id, Account Id and thier owner User Ids along with afls quote creater user id
                if(aflsTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                     if((aflsTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) && ( aflsQt.Qt_External_Id__c != null || aflsQt.Qt_Customer_Code__c != null ) ||
                        ((aflsTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) && (( aflsQt.Qt_External_Id__c != oldQuote.Qt_External_Id__c ) || ( aflsQt.Qt_Customer_Code__c != oldQuote.Qt_Customer_Code__c ) || ( aflsQt.Qt_Created_By__C != oldQuote.Qt_Created_By__C )))
                     ){
                         quoteToBeProcessed.add(aflsQt);
                         
                         if( aflsQt.Qt_External_Id__c != null ){
                             oppToBeQueried.add(aflsQt.Qt_External_Id__c);
                         }
                         
                         if(aflsQt.Qt_Created_by__c != Null) {
                             userToBeQueried.add(aflsQt.Qt_Created_by__c);
                         }
                         
                         if(aflsQt.Qt_Customer_Code__c != Null){
                             accToBeQueried.add(aflsQt.Qt_Customer_Code__c);
                         }
                    }
                }
                // on after Insert, capture all the quotes
                if(aflsTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER  && aflsTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                    quoteToBeProcessed.add(aflsQt);
                }
            }
        }
    }
    
    // Method to query all the Accounts related to AFLS Quotes being processed
    public void getAccDetails(Set<String> accToBeQueried){
        for (Account acc:[SELECT Id, Name, OwnerId, MSL_Account_Owner__c, MSL_Account_Owner__r.IsActive, 
                          SCL_Account_Owner__r.IsActive,Owner.Name, SEA_Account_Owner__c, SEA_Account_Owner__r.IsActive, MCC_Account_Owner__c, MCC_Account_Owner__r.IsActive, CreatedBy.Name, Owner.IsActive, SCV_Code__c, 
                          Seago_Account_Owner__c, Seago_Account_Owner__r.IsActive FROM Account WHERE SCV_Code__c in :accToBeQueried]) {

            accDetails.put(acc.SCV_Code__c,acc);   
        
        }
    }
    
    // Method to query all the Opportunity related to AFLS Quotes being processed
    public void getOppDetails(Set<String> oppToBeQueried){
        for(Opportunity opp :[SELECT Id, Name, OwnerId, Owner.IsActive, Owner.Name, Opportunity_Ref__c 
                                  FROM Opportunity WHERE Opportunity_Ref__c IN:oppToBeQueried]){  
                                  
            oppDetails.put(opp.Opportunity_Ref__c, opp);
            
        }       
    }
    
    // Method to query all the User related to AFLS Quotes being processed
    public void getUserDetails(Set<String> userToQueried){
        for(User usr:[SELECT id, Name, isActive, Maersk_User_Id__c from User where Maersk_User_Id__c IN:userToBeQueried 
                        and UserType = 'Standard']){  
                                  
            userDetails.put(usr.Maersk_User_Id__c , usr);
            
        }
    }
    
    // Method to get all the related records for AFLS Quotes being processed
    public void getRelatedRecords(list<sObject> records){
        if(accToBeQueried != null) {
            getAccDetails(accToBeQueried);
        }
        if(oppToBeQueried != null) {
            getOppDetails(oppToBeQueried);
        }
        if(userToBeQueried != null) {
            getUserDetails(userToBeQueried);
        }
    }
}