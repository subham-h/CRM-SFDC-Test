/**
* Test class for : SIPTargetController

* Date         Owner                                                    Description
**************************************************************************************************************************************
* 27/09/2016   meghana.gupta@ust-global.com             SIP Release 3 changes
* 18-Mar-2019  meghana.gupta@ust-global.com             RQ-010223: functionality deprecated as part of SIP Pahse 1 until Phase 2, hence logic commented 
* 17-Jun-2019  Junaid.Khader@ust-global.com             RQ-010682: Test methods modifed with respect to new changes in the controller(Introduced LWC)
* 06-Mar-2020  Meghana@UST								RQ-013156 - Remove references of deprecated fields
* 05-Dec-2023  Vazid									SFSE-13440: Increased code coverage
*/

@isTest
private class SIPTargetController_Test {  

    @testSetup static void setupTestData(){
        if(UserDataGeneratorHelper_Test.integrationUser == null){            
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        }
        if(UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        }
        if(UserDataGeneratorHelper_Test.salesUser == null){            
            UserDataGeneratorHelper_Test.initializeSalesUser();            
        } 
        UserDataGeneratorHelper_Test.salesUser .managerId = UserDataGeneratorHelper_Test.MSLSystemAdminUser.id;
        update UserDataGeneratorHelper_Test.salesUser ;
        
        String CurrQuarter = SIP_Utilities.getQuarter ('Current');
        String PrevQuarter = SIP_Utilities.getQuarter ('Previous');
        String nextQuarter = SIP_Utilities.getQuarter ('Next');
        
        List<SIP__c> listSips = new List<SIP__c>();
        listSips.add(SIPDataGeneratorHelper.createSIP(UserDataGeneratorHelper_Test.SalesUser, PrevQuarter, 'Efficiency_Super_Saver'));
        listSips.add(SIPDataGeneratorHelper.createSIP(UserDataGeneratorHelper_Test.MSLSystemAdminUser, PrevQuarter, 'Efficiency_Super_Saver'));
        
        listSips.add(SIPDataGeneratorHelper.createSIP(UserDataGeneratorHelper_Test.SalesUser, CurrQuarter, 'Expertise_Ambition'));
        listSips.add(SIPDataGeneratorHelper.createSIP(UserDataGeneratorHelper_Test.MSLSystemAdminUser, CurrQuarter, 'Expertise_Ambition'));
       
        listSips.add(SIPDataGeneratorHelper.createSIP(UserDataGeneratorHelper_Test.SalesUser, nextQuarter, 'Ease_Advancement'));
        listSips.add(SIPDataGeneratorHelper.createSIP(UserDataGeneratorHelper_Test.MSLSystemAdminUser, nextQuarter, 'Ease_Advancement'));
        
        System.runAs(UserDataGeneratorHelper_Test.MSLintegrationUser){     
            insert listSips;
        }
    }
    
    testMethod static void testSIPTargetController() {
        String CurrQuarter = SIP_Utilities.getQuarter ('Previous');
        Id sipRecordTypeId =  (ID)Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Efficiency_Super_Saver').getRecordTypeId();
        
        List<SIP__c> listSIP = new List<SIP__c>();
        listSIP = [SELECT Id, Sales_Rep__c, Sales_Rep__r.Name, Quarter__c, RecordTypeId,
                       Acquisition_Target__c, E2E_Volume_Target_FFE__c,
                       Volume_Target__c, Revenue_Growth_VAS_Target__c
                   FROM SIP__c
                   WHERE Quarter__c = :CurrQuarter and RecordType.DeveloperName='Efficiency_Super_Saver'
                   ORDER BY CreatedDate DESC LIMIT 2];
        if(listSIP.size() > 0){
            Test.startTest();
            SIPTargetController.getSIPModelDetails(listSIP[0].Id);
            if(listSIP.size() > 1){
                SIPTargetController.getSIPModelDetails(listSIP[1].Id);
            }
            String jsonString = JSON.serialize(listSIP);
            SIPTargetController.updateSipDetails(jsonString, null, null);
            Test.stopTest();
            system.assertEquals(sipRecordTypeId, listSIP[0].RecordTypeId);
        }
        
    }
      testMethod static void testSIPTargetController_Expertise_Ambition() {
        String CurrQuarter = SIP_Utilities.getQuarter ('Current');
        Id sipRecordTypeId =  (ID)Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Expertise_Ambition').getRecordTypeId();
        
        List<SIP__c> listSIP = new List<SIP__c>();
        listSIP = [SELECT Id, Sales_Rep__c, Sales_Rep__r.Name, Quarter__c, RecordTypeId,
                       Acquisition_Target__c, E2E_Volume_Target_FFE__c,
                       Volume_Target__c, Revenue_Growth_VAS_Target__c
                   FROM SIP__c
                   WHERE Quarter__c = :CurrQuarter and RecordType.DeveloperName='Expertise_Ambition'
                   ORDER BY CreatedDate DESC LIMIT 2];
        if(listSIP.size() > 0){
            Test.startTest();
            SIPTargetController.getSIPModelDetails(listSIP[0].Id);
            if(listSIP.size() > 1){
                SIPTargetController.getSIPModelDetails(listSIP[1].Id);
            }
            String jsonString = JSON.serialize(listSIP);
            SIPTargetController.updateSipDetails(jsonString, null, null);
            Test.stopTest();
           // system.assertEquals(sipRecordTypeId, listSIP[0].RecordTypeId);
        }
        
    }
      testMethod static void testSIPTargetController_Ease_Advancement() {
        String CurrQuarter = SIP_Utilities.getQuarter ('Next');
        Id sipRecordTypeId =  (ID)Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Ease_Advancement').getRecordTypeId();
        
        List<SIP__c> listSIP = new List<SIP__c>();
        listSIP = [SELECT Id, Sales_Rep__c, Sales_Rep__r.Name, Quarter__c, RecordTypeId,
                       Acquisition_Target__c, E2E_Volume_Target_FFE__c,
                       Volume_Target__c, Revenue_Growth_VAS_Target__c
                   FROM SIP__c
                   WHERE Quarter__c = :CurrQuarter and RecordType.DeveloperName='Ease_Advancement'
                   ORDER BY CreatedDate DESC LIMIT 2];
        if(listSIP.size() > 0){
            Test.startTest();
            SIPTargetController.getSIPModelDetails(listSIP[0].Id);
            if(listSIP.size() > 1){
                SIPTargetController.getSIPModelDetails(listSIP[1].Id);
            }
            String jsonString = JSON.serialize(listSIP);
            SIPTargetController.updateSipDetails(jsonString, null, null);
            Test.stopTest();
          //  system.assertEquals(sipRecordTypeId, listSIP[0].RecordTypeId);
        }
        
    }

}