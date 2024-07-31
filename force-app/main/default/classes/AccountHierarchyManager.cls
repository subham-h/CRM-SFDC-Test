/*
* Author   : Nisha
* Purpose  : Update 'Represents Concern' on client account 
*        
* Revision Ref Number   Date            Owner                           Description
* -------- ----------   -----------     -------------------     		-----------
* 1.0      RQ-005390    05-Jun-2017     Nisha@UST                       Created. 
* 1.0      RQ-010288    29-May-2019     Junaid.Khader@ust-global.com    Defect fix. Commented the line which blanks out the parentId of the client account.
* 2.0      SFSE-7624    05-Jan-2022     Kiran@Maersk				    Live issue fix. Attractiveness field null checks added in updateAccountPlanKCAccount method
* 3.0      SFSE-14282   23-Feb-2023     Samar@Maersk                    Moving Account Process Builder to Trigger.
*/

public class AccountHierarchyManager {
    
    /*@future
    public static void updateAccountPlanKCAccount(Set<Id> accIds){
        List<Business_Plan__c> lstBSPtoUpdate = new List<Business_Plan__c>();
         map<Id, Account> mapAccounts = new map<Id, Account>([SELECT Id, Attractiveness__c FROM Account 
                                                              WHERE Id IN :accIds]);
        List<Business_Plan__c> lstGetAccountPlan = [SELECT Id, Lead_Account__c, Key_Client_Account__c FROM Business_Plan__c
                                                   WHERE Lead_Account__c IN: accIds];
        for(Business_Plan__c bsp: lstGetAccountPlan) {
            Account accIterator = mapAccounts.get(bsp.Lead_Account__c);
            if(String.isNotEmpty(accIterator.Attractiveness__c) && (accIterator.Attractiveness__c.contains('Key Client') || accIterator.Attractiveness__c.contains('Runway') || accIterator.Attractiveness__c.contains('Efficiency'))) {
              bsp.Key_Client_Account__c = 'Yes';  
            } else{
               bsp.Key_Client_Account__c = 'No'; 
            }
            lstBSPtoUpdate.add(bsp);
        }
            asklas
            asmdsa
            asdlkas;
        
        try{
            update lstBSPtoUpdate;
        }catch(Exception e) {
            
        }
    }*/
    
    public static void updateRepresentsConcern(set<Id> setConcernIds, set<Id> setExcludedClientIds) {
        try {
                //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
            list<Account> lstUpdateClientAccounts = [SELECT Id, Represents_Concern__c FROM Account WHERE ParentId IN :setConcernIds AND Id NOT IN :setExcludedClientIds AND Represents_Concern__c = true];
            if(lstUpdateClientAccounts != null && !lstUpdateClientAccounts.isEmpty()) {
                for(Account accIterator : lstUpdateClientAccounts) {
                    accIterator.Represents_Concern__c = false;
                    //accIterator.ParentId = null;
                }
                
                TriggerExecutionController.skipAccountTrigger(true);
                update lstUpdateClientAccounts;
                TriggerExecutionController.skipAccountTrigger(false);
            }
        }
        catch(Exception ex){
            ErrorLogger.writeError('SFDC', 'Account', 'AccountHierarchyManager.updateRepresentsConcern', ex.getTypeName(), ex.getMessage(), ''); // #RQ-005636 
        }
    }

    public static void updateKeyAttribute(List<Account> setofAccount){
            //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
        Set<Id> setofConcernId = new Set<Id>();
        List<Account> lstConcernUpdate = new List<Account>();

        try{
            if(setofAccount.size() > 0){
                for(Account acc : setofAccount){
                    if(acc.ParentId != null && acc.Represents_Concern__c == true){
                        setofConcernId.add(acc.ParentId);
                    }
                }
            }
            
            if(!setofConcernId.isEmpty()){
                    //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
                Map<Id,Account> mapofConcern = new Map<Id,Account>([SELECT Id,Attractiveness__c,Vertical__c,Industry__c,Value_Proposition__c,Sub_Segment__c,Sales_Channel__c,Customer_Size__c FROM Account WHERE Id IN : setofConcernId]);
                Account concern;
                for(Account acc : setofAccount){
                    if(acc.ParentId != null && acc.Represents_Concern__c == true){
                        concern = mapofConcern.containsKey(acc.ParentId) ? mapofConcern.get(acc.ParentId): null;
                        if( concern != null && (acc.Attractiveness__c != concern.Attractiveness__c || acc.Vertical__c != concern.Vertical__c || acc.Industry__c != concern.Industry__c
                            || acc.Value_Proposition__c != concern.Value_Proposition__c || acc.Sub_Segment__c != concern.Sub_Segment__c || acc.Sales_Channel__c != concern.Sales_Channel__c)){
                            
                            concern.Attractiveness__c = acc.Attractiveness__c ;
                            concern.Vertical__c = acc.Vertical__c ;
                            concern.Industry__c = acc.Industry__c ;
                            concern.Value_Proposition__c = acc.Value_Proposition__c ;
                            concern.Sub_Segment__c = acc.Sub_Segment__c ;
                            concern.Sales_Channel__c = acc.Sales_Channel__c ;
                            //concern.Customer_Size__c = acc.Customer_Size__c;
                            lstConcernUpdate.add(concern);
                        }
                    }
                }
            }

            if(!lstConcernUpdate.isEmpty()){
                Database.SaveResult[] result = database.update(lstConcernUpdate,false);
                ErrorLogger.writeErrors('CMD', 'Account', 'AccountHierarchyManager.updateKeyAttribute', result, lstConcernUpdate);
            }
        }catch(Exception ex){
            ErrorLogger.writeError('SFDC', 'Account', 'AccountHierarchyManager.updateKeyAttribute', ex.getTypeName(), ex.getMessage(), '');
        }
        
    }

    // Send To CMD Flag on contact when account recordtype changes from draft to Client Account -  SFSE-14282 
    public static void updateContact(Set<Id> setofAccount){
            //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
        try{
            if(!setofAccount.isEmpty()){
                List<Contact> conlist = [SELECT Id, AccountId FROM Contact WHERE AccountId IN : setofAccount];
                if(!setofAccount.isEmpty()){
                    Database.SaveResult[] result = database.update(conlist,false);
                    ErrorLogger.writeErrors('CMD', 'Account', 'AccountHierarchyManager.updateContact', result, conlist);
                }
            }    
        }catch(Exception ex){
            ErrorLogger.writeError('SFDC', 'Account', 'AccountHierarchyManager.updateContact', ex.getTypeName(), ex.getMessage(), '');
        }
        
    }
        //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
    
}