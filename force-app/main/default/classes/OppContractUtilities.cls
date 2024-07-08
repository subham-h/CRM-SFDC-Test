/*  
* Revision   Date           Owner                   Description
* --------   -----------    -------------------     -----------
* 1.0        23-Aug-2022 	sidhartha@maersk     Utility class Opportunity Contract 
*/
public with sharing class OppContractUtilities {

     public static void createContractShare( List<Opportunity_Contract__c> newContractList, Map<Id, Set<Id>> mapOpIdToUserSet) {
        List<Contract__Share> contractshareToInsert = new List<Contract__Share>();
        for(Opportunity_Contract__c contract: newContractList) {
            Set <Id> setOpUserID = mapOpIdToUserSet.get(contract.Opportunity__c);
            //system.debug('##SM## setOpUserID : ' + setOpUserID);
            
            for(Id userId: setOpUserID) {
            Contract__Share contractshare = new Contract__Share();
            contractshare.ParentId = contract.Contract__c; 
            contractshare.UserOrGroupId = userId;
            contractshare.AccessLevel = 'Read';
            contractshare.RowCause = 'Manual';
            contractshareToInsert.add(contractshare);
            }
        }
         
        //system.debug('##SM## contractshareToInsert: ' + contractshareToInsert);
        
        Database.SaveResult[] srList = Database.insert(contractshareToInsert, false);  
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {                   
                    ErrorLogger.writeError('SFDC', 'Contract', 'OppContractUtilities.createContractShare', JSON.serialize(err),err.getMessage(),JSON.serialize(contractshareToInsert));                                             
                }
            }    
        }
    }

}