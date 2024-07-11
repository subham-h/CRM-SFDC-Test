/**
 * Revision Ref Number  Date            Owner                            Description
 * -------- ----------  -----------     -------------------              -----------
 * 1.0      #RQ-004490  04-Feb-2019     abhinav.ankit@maersk.com         Code created For RQ-009925 for Lead Trigger Class covered is :- 1. LeadTriggerHandler
 *                                                                       2. LeadUtilities
 *                                                                       3. LeadRecordSelector
 *                                                                       4. LeadTrigger
 * 2.0     SFSE-262     10/09/2020      meghana.gupta                    SFSE-262: Changes for new Source Brand field on leads  
 * 2.1     SFSE-5063    11-Jan-2021     Nitin@Maersk                     removed unit test testLeadWithUserCluster     
 * 2.2     SFSE-5346    25-Jan-2021     Neha@TCS                         created method testCountryasNull() and updated remaining method                                      
 * 2.3     SFSE-5063    25-Jan-2021     Nitin@Maersk                     corrected testLeadWithStandardCountry method assert
 * 2.4     SPI-100      27-Jun-2022     Ronnie@SF                        Removed brand hardcoding
 * 2.5	   SFMC-7352	19-Jun-2023		amrutha@maersk					 Incorporated recordtype for all lead record creation in below methods
 */


@isTest
public class LeadTrigger_Test {
    
    @testSetup static void dataSetup() {
        Test.startTest();
        Map<String, String> mapGeo = new Map<String, String> {'China'=>'Country', 'India' =>'Country'};
        List<Geography__c> lstGeo = DataGeneratorHelper1_Test.createGeography(mapGeo);
        
        UserDataGeneratorHelper_Test.initializeSystemAdminUser();
        List<BDA__c> lstBDA = DataGeneratorHelper1_Test.createBDA('Cluster', null, UserDataGeneratorHelper_Test.systemAdminUser.Id, 2);
        
        Map<Id, Id> mapBDAToGeo = new Map<Id, Id>{lstBDA[0].Id => lstGeo[0].Id, lstBDA[1].Id => lstGeo[1].Id};
        List<BDA_Geography__c> lstBDAGeo = DataGeneratorHelper1_Test.createBDAGeography(mapBDAToGeo);
        System.debug('$$$ lstBDAGeo'+ lstBDAGeo);

        DataGeneratorHelper1_Test.createUserCluster(Userinfo.getUserId(), lstBDA[1].Id);
        Lead recLeadUserOwner = LeadDataGeneration.createLead('Test', 'User123', 'TestCompany2',lstGeo[0].id, BrandUtilities.MAERSK, 'testclassrun123@test.com.play', null, null, 'LinkedIn');
        recLeadUserOwner.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Process').getRecordTypeId();
        insert recLeadUserOwner;

        Group recQueueGroup = new Group(name = 'test lead queue', type = 'Queue');
        insert recQueueGroup;

        System.runAs(new User(Id=UserInfo.GetUserId())){
            QueuesObject recQueuesObj = new QueueSObject(QueueId = recQueueGroup.Id, SObjectType = 'Lead');
            insert recQueuesObj;
        }
        Test.stopTest();
        Lead recLeadQueueOwner = LeadDataGeneration.createLead('Test', 'User123', 'TestCompany2_Queue',lstGeo[0].id, BrandUtilities.MAERSK, 'testclassrun123@test.com.play', recQueueGroup.Id, null, 'LinkedIn');
        recLeadQueueOwner.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Process').getRecordTypeId();
        insert recLeadQueueOwner;       
    }
    
    @isTest
    static void testLeadWithStandardCountry(){
        
        List<Geography__c> lstGeo = [SELECT Id, Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' AND Name = 'China' limit 1];    
        Lead leadRec = [SELECT Id, Country_lk__c,Country FROM Lead WHERE Company = 'TestCompany2' Limit 1];
                
        Test.startTest();       
        leadRec.Country = '中国'; // setting the country in ascii so that it reads the metadata and populates the record
        leadRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Process').getRecordTypeId();
        update leadRec; 
        Test.stopTest(); 
        System.debug('leadRec:::'+leadRec);
        Lead leadRec1 = [SELECT Id, Country_lk__c FROM Lead WHERE Company = 'TestCompany2' Limit 1];
        System.assertEquals(leadRec1.Country_lk__c, lstGeo[0].Id, 'Standard Country value is not populated.');
    }
    
    @isTest
    static void testLeadWithCustomCountryLookup(){
        
        list<BDA_Geography__c> lstBdaGeo = [SELECT Geography__c,Geography__r.Name,BDA__c FROM BDA_Geography__c];          
        Lead leadRec = [SELECT Id, Country_lk__c,Country_lk__r.Name,Country FROM Lead WHERE Company = 'TestCompany2_Queue' Limit 1];
              
        Test.startTest();
        leadRec.Country_lk__c = lstBdaGeo[1].Geography__c;      
        leadRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Process').getRecordTypeId();
        update leadRec; 
        Test.stopTest();         
        Lead leadRec1 = [SELECT Id, Country_Ownership_cluster__c,Country_lk__c,Country_lk__r.Name FROM Lead WHERE Company = 'TestCompany2_Queue' Limit 1];       
        System.assertEquals(leadRec1.Country_Ownership_cluster__c, lstBdaGeo[1].BDA__c);
    }
    
    @isTest
    static void testCountryasNull(){
        
        list<BDA_Geography__c> lstBdaGeo = [SELECT Geography__c,Geography__r.Name,BDA__c FROM BDA_Geography__c];          
        Lead leadRec = [SELECT Id, Country_lk__c,Country_lk__r.Name,Country FROM Lead WHERE Company = 'TestCompany2' Limit 1];       
        
        Test.startTest();
        leadRec.Country_lk__c = null; 
        leadRec.Country = null;     
        leadRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Process').getRecordTypeId();
        update leadRec; 
        Test.stopTest();         
        Lead leadRec1 = [SELECT Id, Country FROM Lead WHERE Company = 'TestCompany2' Limit 1];     
        System.assertEquals(leadRec1.Country, null, 'Country is not set to null.');
    }
    
    @isTest
    static void testLeadConversion(){
        
        Lead leadRec = [SELECT Id, OwnerId FROM Lead WHERE Company = 'TestCompany2' Limit 1];
        
        Test.startTest();
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadRec.id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
                 
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.StopTest();
        System.assert(lcr.isSuccess(), 'Lead is not converted successfully.');
    }
    
    }