/*  
* Version   Date            Owner                   Description
* --------  -----------     -------------------     -----------
* 1.0       06-Apr-2023     Vazid@UST               Mass transfer TAAs from List views.
* 2.0       18-Sep-2023     Shubham@UST             Optimize the code and correct error message
* 3.0       25-Jan-2023     Arpitha                 As part of tech debt story #13441 removed debug logs.
*/

public without sharing class TAAMassTransferCntrl {
    
    public static Map<String, Territory_Account_Association__c> mapIdToKey = new Map<String, Territory_Account_Association__c>();
    
    @AuraEnabled(cacheable = false)
    public static projectResponseWrapper massTransferAction(Date strDate, List<string> lstOfTAAs, string selectedTerritoryRec) {
        
        List<Territory_Account_Association__c> transferRecsToInsert = new List<Territory_Account_Association__c>();
        List<Territory_Account_Association__c> filterTransferListToInsert = new List<Territory_Account_Association__c>();
        List<Territory_Account_Association__c> selectedRecsToUpdate = new List<Territory_Account_Association__c>();
        projectResponseWrapper resWrapper = new projectResponseWrapper();
        List<responseFailedResultWrapper> failedWrapper = new List<responseFailedResultWrapper>();
        Map<String, Date> mapIdToKeyDate = new Map<String, Date>();
        
        //Using Dynamic query to clone all the selected records from list view
        string tAAquery = SOQLUtility.getSelectQueryAvoidFormulaSystemFields(new Territory_Account_Association__c());
        tAAquery = 'Select ' + tAAquery + ' ,Territory__r.Name, Name, Account__r.Name from Territory_Account_Association__c';
        tAAquery = tAAquery + ' WHERE id In:lstOfTAAs';
        Map<Id, Territory_Account_Association__c> mapOfTAA = new Map<Id, Territory_Account_Association__c>((List<Territory_Account_Association__c>)Database.query(tAAquery));
        
        //Clone all selected TAAs
        if(!mapOfTAA.isEmpty()){
            for(Territory_Account_Association__c rec: mapOfTAA.values()){
                Territory_Account_Association__c cloneRec = new Territory_Account_Association__c();
                cloneRec = rec.clone(false,false,false,false);
                cloneRec.Start_Date__c = strDate;
                cloneRec.Territory__c = selectedTerritoryRec;
                cloneRec.End_Date__c  = null;
                transferRecsToInsert.add(cloneRec);
                string strkey = rec.Account__c + '_' + rec.Brand__c+'_'+rec.Portfolio_Owner_Responsibility__c+'_'+rec.Product_Responsibility__c+'_'+rec.Territory__r.Name+'_'+rec.Business_Defined_Area__c+'_'+rec.Country__c;
                mapIdToKeyDate.put(strkey, rec.End_Date__c);
                //Assigning selected TAAs with End Date of selected Start Date - 1
                rec.End_Date__c = strDate.addDays(-1);
                mapIdToKey.put(strkey, rec);
                selectedRecsToUpdate.add(rec);
            }
        }
        
        //Update selected TAAs with End Date of selected Start Date - 1
        if(!selectedRecsToUpdate.isEmpty()) {
            List<Database.SaveResult> updateResults = Database.update(selectedRecsToUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult result = updateResults[i];
                if (!result.isSuccess()) {
                    String errorMsg = '';
                    for(Database.Error err : result.getErrors()) {
                        errorMsg = errorMsg + err.getMessage();
                    }
                    String strKey = transferRecsToInsert[i].Account__c + '_' + transferRecsToInsert[i].Brand__c+'_'+transferRecsToInsert[i].Portfolio_Owner_Responsibility__c+'_'+transferRecsToInsert[i].Product_Responsibility__c+'_'+transferRecsToInsert[i].Territory__r.Name+'_'+transferRecsToInsert[i].Business_Defined_Area__c+'_'+transferRecsToInsert[i].Country__c;
                    if(mapIdToKey.containskey(strKey)){
                        responseFailedResultWrapper wrap = getWrapper(strKey, errorMsg, transferRecsToInsert[i]);
                        mapOfTAA.put(mapIdToKey.get(strKey).Id,new Territory_Account_Association__c(Id = mapIdToKey.get(strKey).Id, End_Date__c = mapIdToKeyDate.get(strKey)));
                        failedWrapper.add(wrap);
                    }
                } else {
                    filterTransferListToInsert.add(transferRecsToInsert[i]);
                }
            }
        }
        
        //clone selected TAAs
        List<Database.SaveResult> insertResults = Database.insert(filterTransferListToInsert, false);
        
        List<Id> successIds = new List<Id>();
        mapOfTAA = new Map<Id, Territory_Account_Association__c>(); 
        
        for (Integer i = 0; i < insertResults.size(); i++)  {
            Database.SaveResult result = insertResults[i];
            
            if (!result.isSuccess()) {
                String errorMsg = '';
                String strKey = filterTransferListToInsert[i].Account__c + '_' + filterTransferListToInsert[i].Brand__c+'_'+filterTransferListToInsert[i].Portfolio_Owner_Responsibility__c+'_'+filterTransferListToInsert[i].Product_Responsibility__c+'_'+filterTransferListToInsert[i].Territory__r.Name+'_'+filterTransferListToInsert[i].Business_Defined_Area__c+'_'+filterTransferListToInsert[i].Country__c;
                for(Database.Error err : result.getErrors()) {
                    errorMsg = errorMsg + err.getMessage();
                }
                if (mapIdToKey.containskey(strKey)) {
                    responseFailedResultWrapper wrap = getWrapper(strKey, errorMsg, filterTransferListToInsert[i]);
                    mapOfTAA.put(mapIdToKey.get(strKey).Id,new Territory_Account_Association__c(Id = mapIdToKey.get(strKey).Id, End_Date__c = mapIdToKeyDate.get(strKey)));
                    failedWrapper.add(wrap);
                }                
            } else {
                successIds.add(result.getId());
            }
        }
        
        //Reverting End date of selected TAAs if transfer opertion is failed.
        if(!mapOfTAA.isEmpty()){
            Database.update(mapOfTAA.values(), false);
        }
        resWrapper.successRecordSize =  successIds.size();
        resWrapper.failedList = failedWrapper;
        return resWrapper;
    }
    
    public static responseFailedResultWrapper getWrapper(String strKey, String errorMsg, Territory_Account_Association__c taaRecord) {
        responseFailedResultWrapper wrap = new responseFailedResultWrapper();
        wrap.Name = mapIdToKey.get(strKey).Name;
        wrap.taaId = mapIdToKey.get(strKey).Id;
        wrap.territory = taaRecord.Territory__r.Name;
        wrap.territoryId = mapIdToKey.get(strKey).Territory__c;
        wrap.accountName = taaRecord.Account__r.Name;
        wrap.accountId = taaRecord.Account__c;
        wrap.portfolioOwnerResponsability = taaRecord.Portfolio_Owner_Responsibility__c;
        wrap.productResponsability = taaRecord.Product_Responsibility__c;
        wrap.errorMsg = errorMsg;
        return wrap;
    }
    
    public class projectResponseWrapper{
        @AuraEnabled public  Integer successRecordSize                      {get;set;}
        @AuraEnabled public  List<responseFailedResultWrapper>  failedList  {get;set;}
    }
    
    public class responseFailedResultWrapper{
        @AuraEnabled public  string Name                                {get;set;}  
        @AuraEnabled public  string taaId                               {get;set;}  
        @AuraEnabled public  string territory                           {get;set;}      
        @AuraEnabled public  string territoryId                         {get;set;}
        @AuraEnabled public  string accountName                         {get;set;}
        @AuraEnabled public  string accountId                           {get;set;}
        @AuraEnabled public  string portfolioOwnerResponsability        {get;set;}  
        @AuraEnabled public  string productResponsability               {get;set;}  
        @AuraEnabled public  string errorMsg                            {get;set;}  
    } 
}