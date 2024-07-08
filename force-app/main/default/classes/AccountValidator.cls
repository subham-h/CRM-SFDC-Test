/* 
 * Author   : Ranjini
 * Purpose  : All validation related logic related to Account should be kept in this class. 
 * 
 * Revision     Ref Number      Date            Owner                   	Description
 * --------     ----------      -----------     -------------------         -----------
 * 1.0      	RQ-004103       05-Jul-2017   	Ranjini@UST                 Created as part of CBO refactoring.
 * 2.0			SFSE-9288		14-Sept-2022	Vazid						Removed future call from shareContract method
																			Modified logic in the same method
 */

public class AccountValidator {
    
    // Client and Concern Accounts can not be deleted. 
    public static void preventAccountDelete(list<Account> lstAcctsToPreventDelete) {
        for(Account acc : lstAcctsToPreventDelete) {
            acc.addError(Label.Client_Concern_AccDel_Validation); 
        }
    }
    
    
    
    public static void shareContract(Set<Id> accIds, Set<Id> olduIds, Map<String, Id> mapOfBrandUserId) {   
        List<Contract__Share> cOShareListToCreate = new List<Contract__Share>();
        List<Contract__c> lstContract =  [SELECT Id, Customer__c, Brand_Name__c FROM Contract__c WHERE Customer__c IN:accIds];
        List<Contract__share> contractShare = [SELECT Id, UserOrGroupId FROM Contract__share WHERE UserOrGroupId IN: olduIds AND RowCause = 'Manual'];
        If(contractShare.size() > 0) {
            delete contractShare;
        }
         
        for(Contract__c coN: lstContract) { 
            if(mapOfBrandUserId.containskey(coN.Brand_Name__c)){
                Contract__Share coNtoShare = new Contract__Share();
                coNtoShare.ParentId = coN.Id;
                coNtoShare.UserOrGroupId = mapOfBrandUserId.get(coN.Brand_Name__c);
                coNtoShare.RowCause = 'Manual';
                coNtoShare.AccessLevel = 'Read';  
                cOShareListToCreate.add(coNtoShare);
            } 
        } 
        try{
            Database.insert(cOShareListToCreate); 
        } Catch(Exception e) {
            ErrorLogger.writeErrors( 'SFDC', 'Contract', 'OpportunityUtilities.shareContract', new list<Exception>{e});
        }
    }
    
}