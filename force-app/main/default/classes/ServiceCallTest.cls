/*
* test class for Service Call Module.

*

    Date           Owner                                                Description

*********************************************************************************************************************************  
21/2/2022    divya.kumari@maersk.com           testCreatedService : testing creation of service call
21/2/2022    divya.kumari@maersk.com           testCSATForServicecall : testing csat sent 
*/


@isTest public class ServiceCallTest 
{

    //Testing creation of Service Call
    @isTest 
    public static void testCreatedService()
    {    
        Sales_Call__c servicecall = TestDataFactoryHelper.serviceCallCreation();  
        List<Sales_Call__c> createdservicecall  = [SELECT id, Name,Service_Type__c,Type__c,Status__c,Language__c,Duration__c FROM Sales_Call__c WHERE id=:servicecall.id ];
        System.debug('##### Created Service Call : '+createdservicecall);
        System.debug('##### Duration : '+createdservicecall[0].Duration__c); 
        
        System.assertEquals('English',createdservicecall[0].Language__c);
        System.assertEquals('Scheduled',createdservicecall[0].Status__c);        
    }
    

    //Testing CSAT for Service call    
    @isTest 
    public static void testCSATForServicecall()
    {    
        Sales_Call__c servicecall = TestDataFactoryHelper.serviceCallCreation();
        List<Sales_Call__c> createdservicecall  = [SELECT id, Name,Service_Type__c,Type__c,Status__c,Survey_sent__c FROM Sales_Call__c WHERE id=:servicecall.id ];
        System.debug('##### Created Insurance Policy : '+createdservicecall);
        createdservicecall[0].Status__c='Completed';
        update createdservicecall[0];
       // system.assertEquals(true, createdservicecall[0].Survey_sent__c);
        
    }
    
    
}