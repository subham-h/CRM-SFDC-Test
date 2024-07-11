/*
 * Author   : Jiji
 * Purpose  :  Generic test data factory Framework. Test class for IncidentTriggerHandler
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002716   12-Feb-2016 Jiji@UST                Test class for IncidentTriggerHandler
 *  
 */

@isTest
public class IncidentTriggerHandler_Test {
    
    public static List<Vessel__c> lstVessels = new List<Vessel__c>();
    public static List<Vessel_Policy__c> lstVesselPolicies = new List<Vessel_Policy__c>();
    
    // Test method for multiple incidents creation
    public static testmethod void test_createMultipleIncidentRecords() {
        if(lstVessels == null || lstVessels.isEmpty()) {
            VesselData_Test.iNumberOfVessels = 5;
            VesselData_Test.createVessels();
            lstVessels = VesselData_Test.lstVessels;
        }
        
        if(lstVesselPolicies.isEmpty()) {
            VesselPolicyData_Test.iNumberOfVesselPolicies = 5;
            VesselPolicyData_Test.lstVessels = lstVessels;
            VesselPolicyData_Test.createVesselPolicies();
            lstVesselPolicies = VesselPolicyData_Test.lstVesselPolicies;
        }

        IncidentData_Test.bCreate = false;
        IncidentData_Test.iNumberOfIncidents = 5;
        Integer i=0;
        
        list<Incident__c> lstIncident = new list<Incident__c>();
        IncidentData_Test.createClaimEventIncidents();
        lstIncident.addAll(IncidentData_Test.lstIncidents);
        for(Incident__c inRecord : lstIncident){
            inRecord.Insured_Vessel__c = lstVessels[i].Id;
            i++;
        }
        
        Test.startTest();
        insert lstIncident;
        Test.stopTest();
        
        System.assertEquals(lstIncident.Size(), 5); 
        Set<Id> incidentIdSet= new Set<Id>{ lstIncident[1].Id, lstIncident[2].Id, lstIncident[3].Id};  
        list<Incident__c> newIncidentList = [SELECT Id, P_I_Policy__c FROM Incident__c WHERE Id IN : incidentIdSet  ];
        
        System.assertNotEquals(newIncidentList[1].P_I_Policy__c, Null);
        System.assertNotEquals(newIncidentList[2].P_I_Policy__c, Null);
    }
    
    // Test method for single incidents creation
    public static testmethod void test_createSingleIncidentRecords() {
        if(lstVessels == null || lstVessels.isEmpty()) {
            VesselData_Test.iNumberOfVessels = 1;
            VesselData_Test.createVessels();
            lstVessels = VesselData_Test.lstVessels;
        }
        
        if(lstVesselPolicies.isEmpty()) {
            VesselPolicyData_Test.iNumberOfVesselPolicies = 1;
            VesselPolicyData_Test.lstVessels = lstVessels;
            VesselPolicyData_Test.createVesselPolicies();
            lstVesselPolicies = VesselPolicyData_Test.lstVesselPolicies;
        }
        
        IncidentData_Test.bCreate = false;
        IncidentData_Test.iNumberOfIncidents = 1;
        list<Incident__c> lstIncident = new list<Incident__c>();
        IncidentData_Test.createClaimEventIncidents();
        lstIncident.addAll(IncidentData_Test.lstIncidents);
        lstIncident[0].Insured_Vessel__c = lstVessels[0].Id;
        
        Test.startTest();
        insert lstIncident;
        Test.stopTest();
        
        list<Incident__c> newIncidentList = [SELECT Id, P_I_Policy__c FROM Incident__c WHERE Id = :lstIncident[0].Id  ];
        System.assertNotEquals(newIncidentList[0].P_I_Policy__c, Null);
    }
    
    // Test method for multiple incidents update
    public static testmethod void test_updateMultipleIncidentRecords() {
        if(lstVessels == null || lstVessels.isEmpty()) {
            VesselData_Test.iNumberOfVessels = 5;
            VesselData_Test.createVessels();
            lstVessels = VesselData_Test.lstVessels;
        }
        
        if(lstVesselPolicies.isEmpty()) {
            VesselPolicyData_Test.iNumberOfVesselPolicies = 5;
            VesselPolicyData_Test.lstVessels = lstVessels;
            VesselPolicyData_Test.createVesselPolicies();
            lstVesselPolicies = VesselPolicyData_Test.lstVesselPolicies;
        }
        
        IncidentData_Test.bCreate = false;
        IncidentData_Test.iNumberOfIncidents = 5;
        Integer i=0;
        IncidentData_Test.createClaimEventIncidents();
        list<Incident__c> lstIncident = IncidentData_Test.lstIncidents;
        for(Incident__c inRecord : lstIncident) {
            inRecord.Insured_Vessel__c = lstVessels[i].Id;
            i++;
        }
        insert lstIncident;
        

        Test.startTest();
        list<Incident__c> incidentToUpdateList = new list<Incident__c>();
        set<Id> incidentIdSet = new set<Id>{lstIncident[0].Id, lstIncident[1].Id, lstIncident[2].Id, lstIncident[3].Id};  
        list<Incident__c> newIncidentList = [SELECT Id, Date_of_Incident__c, P_I_Policy__c FROM Incident__c WHERE Id IN :incidentIdSet];
        for(Incident__c inc : newIncidentList) {
            inc.Date_of_Incident__c = inc.Date_of_Incident__c.addDays(1);
            incidentToUpdateList.add(inc);
        }
        update incidentToUpdateList; 
        Test.stopTest();
        
        newIncidentList = [SELECT Id, Date_of_Incident__c, P_I_Policy__c FROM Incident__c WHERE Id IN :incidentIdSet];
        System.assertNotEquals(newIncidentList[0].P_I_Policy__c, Null);
        System.assertNotEquals(newIncidentList[1].P_I_Policy__c, Null);
        System.assertNotEquals(newIncidentList[2].P_I_Policy__c, Null);
        System.assertNotEquals(newIncidentList[3].P_I_Policy__c, Null);        
    }
   
    // Test method for single incidents update, where vessel is not associated to any vessel policy
    public static testmethod void test_updateSingleIncidentwithNoPolicy() {
        if(lstVessels == null || lstVessels.isEmpty()) {
            VesselData_Test.iNumberOfVessels = 1;
            VesselData_Test.createVessels();
            lstVessels = VesselData_Test.lstVessels;
        }
        
        IncidentData_Test.bCreate = false;
        IncidentData_Test.iNumberOfIncidents = 1;
        list<Incident__c> lstIncident = new list<Incident__c>();
        IncidentData_Test.createClaimEventIncidents();
        lstIncident.addAll(IncidentData_Test.lstIncidents);
        lstIncident[0].Insured_Vessel__c = lstVessels[0].Id;
        
        Test.startTest();
        insert lstIncident;
        Test.stopTest();
        
        list<Incident__c> newIncidentList = [SELECT Id, P_I_Policy__c FROM Incident__c WHERE Id = :lstIncident[0].Id  ];
        System.assertEquals(newIncidentList[0].P_I_Policy__c, Null);
    }
    
}