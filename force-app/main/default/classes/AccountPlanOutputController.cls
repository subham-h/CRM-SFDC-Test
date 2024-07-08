/*
* Version  Date           Owner                    RQ#           Description
****************************************************************************************************************************************
* 1.0      02-Sept-2020   Neha@TCS     SFSE-4360     Apex class for accountPlanOutput LWC
*/
public with sharing class AccountPlanOutputController {
      // This method will get the Initiatives associated with Account Plan
    @AuraEnabled(cacheable=true)
    public static List<Initiative__c> getInitiativeList(id recordId) {
        List<String> statusValue = String.ValueOf(Label.Initiative_Status).split(',');
        List<Initiative__c> InitiativeList = new List<Initiative__c> ();
        InitiativeList =[select id, RecordType.Name,Name, Status__c, Owner.Name, Due_Date__c from Initiative__c where Share_with_Customer__c = true and Status__c in :statusValue and Business_Plan__c =:recordId];
        if(InitiativeList.size()>0){            
            return InitiativeList;
        }else{
            return null;
        }
    }
    // This method will get the Opportunity and associated Product for Account Plan
    @AuraEnabled(cacheable=true)
    public static List<OpportunityAndProductListWrapper> getOpportunityProductList(id recordId) {        

        List<OpportunityAndProductListWrapper> oppWrapperList = new List<OpportunityAndProductListWrapper> ();
        List<Opportunity> OpportunityList = [select id,Name,Owner.Name,StageName,Proposal_Presentation_Date__c,CloseDate,(Select Product2.Name, Quantity, Quantity_Unit_Of_Measure__c from OpportunityLineItems) from Opportunity where Account_Plan__c =:recordId and IsClosed = false];
                 
        if(OpportunityList.size()>0){
            for(Opportunity opp : OpportunityList){
                OpportunityAndProductListWrapper opWppperObj = new OpportunityAndProductListWrapper();
                opWppperObj.Name= opp.Name;
                opWppperObj.OwnerName= opp.Owner.Name;
                opWppperObj.Stage= opp.StageName;
                opWppperObj.ProposalDate= String.ValueOf(opp.Proposal_Presentation_Date__c);
                opWppperObj.CloseDate= String.ValueOf(opp.CloseDate);
                opWppperObj.OpportunityLineItemList = opp.OpportunityLineItems;
                oppWrapperList.add(opWppperObj);
            }
            System.debug('oppWrapperList::::'+oppWrapperList);
            return oppWrapperList;
        }else{
            return null;
        }
    }
    // Method to query the field set stored in custom metadata to display the records
    @AuraEnabled(cacheable=true)
    public static List<AccountPlanWrapper> getBusinessPlanData(id recordId, String objectApiName) {
       List<AccountPlanWrapper> apWrapperList = new List<AccountPlanWrapper> ();

       String brandName = getLinerBrandName(recordId); // get the Brand name

        List<Account_Plan_Report__mdt> accountplanOutfieldset =[SELECT MasterLabel,Active__c,Field_Set__c,Order__c ,Number_of_Columns__c from Account_Plan_Report__mdt where Active__c = true Order by Order__c ASC];
       
        if(accountplanOutfieldset != null && accountplanOutfieldset.size()>0){
            for(Account_Plan_Report__mdt aprObject : accountplanOutfieldset){
                AccountPlanWrapper apwapperObj = new AccountPlanWrapper(); 
                apwapperObj.BandName = brandName;
                apwapperObj.SerialNumber = Integer.valueOf(aprObject.Order__c);
                apwapperObj.NumberOfColumn = Integer.valueOf(aprObject.Number_of_Columns__c);
                apwapperObj.FieldSetName = aprObject.MasterLabel;
                List<FieldDefinition> fdDataList =  getData(recordId, objectAPIname, aprObject.Field_Set__c, aprObject.Order__c, aprObject.Number_of_Columns__c);
                if(fdDataList!=null && fdDataList.size()>0){
                    apwapperObj.FieldDescriptionsList = fdDataList;
                }
                apWrapperList.add(apwapperObj);
            }
        }
        
        System.debug('apWrapperList111::'+JSON.serializePretty(apWrapperList));
        return apWrapperList;
    }
    // Method to get the Liner brand required to get the logo which is needed to be displayed
    public static String getLinerBrandName(String recordId){
        String brandName ='';
        String query = 'SELECT Id,Liner_Brand__c FROM Business_Plan__c  where  Id =:recordId';
        System.debug('query>>>>'+query);
        List<Business_Plan__c> bpList =   Database.query(query);
        if(bpList != null && bpList.size()>0){
            brandName = bpList[0].Liner_Brand__c;
        }
        return brandName;
    }
    
    // Method to get all the field values of the field set 
    public static List<FieldDefinition> getData(String recordId, String objectAPIname, String fieldSetName,  Decimal Order, Decimal NumberofColumns){
        
        FieldDefinition fieldDef;
        List<FieldDefinition> FieldDescriptionsList = new List<FieldDefinition>();

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectAPIname);        
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj;  
        
        //To read the values for field set and put it in the wrapper class
        if(DescribeSObjectResultObj.FieldSets.getMap()!= null){
            fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        }      

        if(fieldSetObj!=null){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : fieldSetObj.getFields()) {
                System.debug('f!!!::'+JSON.serializePretty(f));
                if(String.valueOf(f.type).equalsIgnoreCase('reference')){
                    String tempStr = f.getFieldPath().replace('__c','__r.Name');
                    System.debug('tempStr>>'+tempStr);
                    query += tempStr + ', ';

                }else{
                    query += f.getFieldPath() + ', ';
                }
            }
            query += 'Id FROM Business_Plan__c  where  Id =:recordId';            
            List<Business_Plan__c> bpList =   Database.query(query);
            System.debug('bpList>>>>'+bpList);
            if(bpList != null && bpList.size()>0){               
                for(Schema.FieldSetMember f : fieldSetObj.getFields()) {
                   String tempValue = String.valueOf(bpList[0].get(f.getFieldPath()));
                   if(String.valueOf(f.type).equalsIgnoreCase('reference')){
                        String tempObjName = f.getFieldPath().replace('__c','__r');
                        //String tempFieldPath = f.getFieldPath().replace('__c','__r.Name');
                        tempValue = String.valueOf(bpList[0].getSobject(tempObjName).get('Name'));
                    }else{
                        tempValue = String.valueOf(bpList[0].get(f.getFieldPath()));
                    }
                    System.debug('tempValue>>>>'+tempValue);
                   fieldDef = new FieldDefinition();
                   fieldDef.APIfieldName=f.getFieldPath();
                   fieldDef.fieldLabel= f.label;                   
                   fieldDef.fieldValue  = tempValue;
                   FieldDescriptionsList.add(fieldDef);

                }
            }
            System.debug('FieldDescriptionsList>>>>'+FieldDescriptionsList);
        }
        return FieldDescriptionsList;
    }
    public Class OpportunityAndProductListWrapper{
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String OwnerName {get;set;}
        @AuraEnabled public String Stage {get;set;}
        @AuraEnabled public String ProposalDate {get;set;}
        @AuraEnabled public String CloseDate {get;set;}       
        @AuraEnabled public List<OpportunityLineItem> OpportunityLineItemList {get;set;}
    }
    public Class AccountPlanWrapper{
        @AuraEnabled public Integer SerialNumber {get;set;}
        @AuraEnabled public Integer NumberOfColumn {get;set;}
        @AuraEnabled public String BandName {get;set;}
        @AuraEnabled public String FieldSetName {get;set;}
        @AuraEnabled public List<FieldDefinition> FieldDescriptionsList {get;set;}

    }
    public Class FieldDefinition{
        
        @AuraEnabled public String APIfieldName {get;set;}
        @AuraEnabled public String fieldLabel {get;set;}
        @AuraEnabled public String FieldValue {get;set;}
    }

    
   
}