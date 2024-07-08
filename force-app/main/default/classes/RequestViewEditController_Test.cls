/*
Description  : Test class for RequestViewEditController

* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          27/02/2018        john.christopher@ust-global.com           #RQ-007724 - Rate Sheet3
* v2.0			16/Jul/2018		  manjunath.c.holekade@maersk.com			#RQ-008482 - Mod-01 - Included new param
*/ 

@isTest
public class RequestViewEditController_Test {
    
    @testSetup static void setup() {
        
        RateSheetData_Test.createRequestData();
        RateSheetData_Test.createRequestContractOuptput(null);        
    }
    
    @isTest
    static void TestRequestEdit(){
        
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        Request__c request = [SELECT Id, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name,Requested_By__c
                              FROM Request__c Where OD_Pairs__c= 'Customised' AND recordTypeId = :rateSheetRecTypeId Limit 1];
        
        Test.startTest();  
        RequestViewEditController.getRequestDetails('','Edit');
        RequestViewEditController.getRequestDetails(request.id,'Edit');
        request.Additional_Notes__c = 'test';
        RequestViewEditController.saveRequestDetails( request, 'Edit');
        Request__c req = [select Id, Additional_Notes__c FROM Request__c WHERE Id=:request.Id];
        System.AssertEquals('test',req.Additional_Notes__c);
        
        //Test Save Exception
        request.Special_Deals__c = 'Yes';
        request.Type_of_Special_Deal__c = '';       
        System.debug('$$$ TestRequestEdit: '  );
        RequestViewEditController.saveRequestDetails( request, 'Edit');
        Test.stopTest(); 
    }
    
    @isTest
    static void TestRequestClone(){
        
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        Request__c request = [SELECT Id, Mail_Send_To__c, Existing_Contract_ID__c, Requested_By__c
                              FROM Request__c Where OD_Pairs__c= 'Customised' AND recordTypeId = :rateSheetRecTypeId Limit 1];
        
        List<User> lstUser = [ SELECT Id FROM USER WHERE isActive = true LIMIT 1];
        
        Test.startTest();  
        request.Existing_Contract_ID__c='1234';
        request.Mail_Send_To__c='Both';
        request.Requested_By__c = lstUser[0].id;
        RequestViewEditController.saveRequestDetails(request,'Clone');
        System.AssertEquals('1234',request.Existing_Contract_ID__c);
        System.AssertEquals('Both',request.Mail_Send_To__c);
        Test.stopTest(); 
    }
    
    @isTest
    static void TestRequestNew(){
        
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        //Request__c request = [SELECT Id, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name
        //                      FROM Request__c Where OD_Pairs__c= 'Customised' AND recordTypeId = :rateSheetRecTypeId Limit 1];
        
        List<User> lstUser = [ SELECT Id FROM USER WHERE isActive = true LIMIT 1];
        Request__c request = new Request__c();
        Test.startTest();
        RequestViewEditController.getRequestDetails('','New');
        
        request.RecordTypeId = rateSheetRecTypeId;
        request.Existing_Contract_ID__c='1234';
        request.Requested_By__c = lstUser[0].id;
        request.Mail_Send_To__c='Both';
        RequestViewEditController.saveRequestDetails(request,'New');
        System.AssertEquals('1234',request.Existing_Contract_ID__c);
        System.AssertEquals('Both',request.Mail_Send_To__c);
        
        Test.stopTest(); 
    }
    
    /*@isTest
    static void TestRequestDelete(){
        
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        Request__c request = [SELECT Id, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name
                              FROM Request__c Where OD_Pairs__c= 'Customised' AND recordTypeId = :rateSheetRecTypeId Limit 1];
        Test.startTest();  
        
        //Test the delete request
        RequestViewEditController.deleteRequest(request);
        
        //Test the delete exception
        Request__c testRec = new Request__c();
        RequestViewEditController.deleteRequest(testRec);
        
        Test.stopTest(); 
    }
    */
    @isTest
    static void TestFetchCommodities(){
        
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        Request__c request = [SELECT Id, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name,BCO_FWD__c
                              FROM Request__c Where OD_Pairs__c= 'Customised' AND recordTypeId = :rateSheetRecTypeId Limit 1];
        
        String route = request.Pricing_Management__r.Product__r.Name;
        //String bcoFwd= request.BCO_FWD__c;
        Test.startTest();  
        RequestViewEditController.getCommodities(route, 'FWD');
        RequestViewEditController.getCommodities(route, 'BCO');
        Test.stopTest(); 
    }
    
    @isTest
    static void TestFetchEquipmentTypes(){
        Request__c request = [SELECT Id, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name
                              FROM Request__c Where OD_Pairs__c= 'Customised' Limit 1];
        String route = request.Pricing_Management__r.Product__r.Name;
        Test.startTest();  
        RequestViewEditController.getEquipmentTypes('FAK','BCO',route,'New',''); //#RQ-008482 - Mod-01 - Start - Included new param
        RequestViewEditController.getEquipmentTypes('FAK','FWD',route,'New','');
        RequestViewEditController.getEquipmentTypes('Test','FWD',route,'New','');
        RequestViewEditController.getEquipmentTypes('Test','BCO',route,'New',''); //#RQ-008482 - Mod-01 - End
        Test.stopTest(); 
    }
    
    
    @isTest
    static void TestreDirectNew(){
        Test.startTest();
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();
        
        Request__c request = [SELECT Id, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name
                              FROM Request__c Where OD_Pairs__c= 'Customised' Limit 1];
        
        ApexPages.StandardController stdCntller = new Apexpages.Standardcontroller( request ); 
        RequestViewEditController cntrl = new RequestViewEditController(stdCntller);
        cntrl.redirectNew();
        
        PageReference pageRef = Page.RequestNewOverride; 
        pageRef.getParameters().put('RecordType', rateSheetRecTypeId ); 
        pageRef.getParameters().put('retURL', '/a2Q' );
        Test.setCurrentPage( pageRef );
        cntrl.redirectNew();
        Test.stopTest(); 
    }
    
    @isTest
    static void TestreDirectEdit(){
        Test.startTest();
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();
        
        Request__c request = [SELECT Id, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name
                              FROM Request__c Where OD_Pairs__c= 'Customised' Limit 1];
        
        ApexPages.StandardController stdCntller = new Apexpages.Standardcontroller( request ); 
        RequestViewEditController cntrl = new RequestViewEditController(stdCntller);
        PageReference pageRef = Page.RequestEditOverride; 
        pageRef.getParameters().put('id', request.id );
        Test.setCurrentPage( pageRef );
        cntrl.redirectEdit();
        String contractRecTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RequestContractRecordType).getRecordTypeId();
        Request__c reqRec = [SELECT id FROM Request__c WHERE recordtypeid = :contractRecTypeId LIMIT 1];
        pageRef = Page.RequestEditOverride; 
        pageRef.getParameters().put('id', reqRec.id );
        Test.setCurrentPage( pageRef );
        cntrl.redirectEdit();
        Test.stopTest(); 
    }   
}