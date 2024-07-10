public class OpportunityWizardCtrl {
    
    
    @AuraEnabled
    public static List<RecordType> getListOfRecordType(){
        
        List<RecordType> recordTypes = new List<RecordType>();
        for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable() && !String.valueOf(info.getRecordTypeId()).endsWith('AAA')) {
                recordTypes.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
            }
        }        
        
        return recordTypes; 
    }
    
    @AuraEnabled
    public static List<RecordType> getAvailableRecordTypeOpp()
    {
        Map<String,String> recordTypeMap = new Map<String,String>();
        List<RecordType> lstRecTyp = new List<RecordType>();
        Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        for(RecordType rec : [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE SobjectType = 'Opportunity']) {
            if(rec.DeveloperName != 'Opportunity_Record_Type_Read_Only' && rec.DeveloperName != 'Opportunity_Record_Type'){
                recordTypeMap.put(rec.Name, rec.Description);
                lstRecTyp.add(rec);
                system.debug('recordtype' + recordtypemap);    
            }
            
        }
        return lstRecTyp;
    }   
    
    @AuraEnabled(cacheable=true)
    public static Boolean isPermitted() {
        Boolean hasCustomPermission = false;
        Id userId = UserInfo.getUserId();
        hasCustomPermission = FeatureManagement.checkPermission('Opportunity_Creation_Wizard_Access');
        return hasCustomPermission;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> isAccRecTypeConcern(List<Id> accId) {
        system.debug('accId'+accId);
        //Boolean isConcernRecTyp = false;
        List<Account> acc = [Select Id, recordType.DeveloperName, Name from Account where Id in :accId];
        //if(acc.recordType.DeveloperName == 'Concern_Account'){
        //    isConcernRecTyp = true;
        //}
        //   system.debug('called'+isConcernRecTyp);
        return acc;
    }
    
    @AuraEnabled(cacheable=true)
    public static List < Contract__c > fetchContracts(Id accId) {
        
        List < Contract__c > contracts = [SELECT Id, Name, Customer__r.Name , Agreement_Type_Name__c , Effective_Date__c , Expiration_Date__c , Status__c, 
                                          Brand_Name__c FROM Contract__c WHERE Customer__c =:accId order by Expiration_Date__c DESC];
        
        return contracts;
    }
    @AuraEnabled(cacheable=true)
    public static List < Opportunity > fetchOpps(Id accId) {
        List < Opportunity > opportunities = [SELECT Id, Account.Name, Name, Opportunity_Ref__c , StageName , First_Shipment_Date__c , Last_Shipment_Date__c  FROM Opportunity WHERE AccountId =:accId order by Last_Shipment_Date__c DESC];       
        return opportunities;
    }
    
    @AuraEnabled(cacheable=true)
    public static List < Contact > fetchContactDetails(Id contId) {
        List < Contact > contacts = [SELECT Id, Name, AccountId, FirstName , LastName, Contact_Status__c  
                                     FROM Contact WHERE Id =:contId];       
        return contacts;
    }
    //SFSE-11327 : Auto-populate customer type (BCO/ FWD) from Account
    @AuraEnabled(cacheable=true)
    public static List < Account > fetchAccountDetails(Id accId) {
        List < Account > Accounts = [SELECT Id, Name, Customer_Role__c  
                                     FROM Account WHERE Id =:accId];      
        return Accounts;
    }
    @AuraEnabled
    public static list<Opportunity> insertOpps (List<sObject> opps, String recordTyp, List<sObject> oppContracts){
        system.debug('recordTyp'+recordTyp);
        String sOppRecordTypeID = '';
        Opportunity opObj = (Opportunity) opps[0];
        if(recordTyp.equalsIgnorecase('Shipping & Cargo Services')){
            sOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ShippingCargoServices').getRecordTypeId();
        }else if(recordTyp.equalsIgnorecase('Quarterly NAC & BCO Deals')){
            sOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Quarterly_Deal').getRecordTypeId();
        }else if(recordTyp.equalsIgnorecase('Supply Chain Services')){
            sOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Supply_Chain_Services').getRecordTypeId();
        }/*else if(recordTyp.equalsIgnorecase('Standard Opportunity')){
            sOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Record_Type').getRecordTypeId();
        }*/else{
            sOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ShippingCargoServices').getRecordTypeId();
        }
        
        try{
            opObj.recordTypeId = sOppRecordTypeID; 
            System.debug('opObj>>'+JSON.serializePretty(opObj));           
            insert opObj;
            if(oppContracts.size() > 0) {
                //createOppContracts(oppContracts, opObj.Id);
            }
            return opps;
        }
        catch(DMLException ex){
            AuraHandledException e = new AuraHandledException(ex.getMessage());
            throw e;
        }       
    }
    
    public static List<Opportunity_Contract__c> createOppContracts(List<Opportunity_Contract__c> oppContracts, Id oppId) {
        List<Opportunity_Contract__c> oppContractsToInsert = new List<Opportunity_Contract__c>();
        for(Opportunity_Contract__c oc: oppContracts) {
            oc.opportunity__c = oppId;
            oppContractsToInsert.add(oc);
        }
        insert oppContractsToInsert;
        return oppContractsToInsert;
    }
}