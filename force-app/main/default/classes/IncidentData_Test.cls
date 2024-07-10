/*
 * Author   : Jiji
 * Purpose  : Utility test class for creating Incident related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Jiji@UST                Created.
 * 
 */

@isTest
public class IncidentData_Test {
    public static boolean bCreate = true;
    public static integer iNumberOfIncidents = 5;
    public static list<Incident__c> lstIncidents;
    public static Vessel__c vesselInstance = null;
    
    public static testMethod void createClaimEventIncidents() {
        populateCommonFields();
        
        Id claimEventRTId = StaticFactory.getRecordTypeIdByName('Incident__c', 'Claim Event');
        for(Incident__c incident : lstIncidents) {
            incident.RecordTypeId = claimEventRTId;
        }
        
        if(bCreate) {
            insert lstIncidents;
        }
    }
    
    private static testMethod void populateCommonFields() {
        if(vesselInstance == null) {
            VesselData_Test.iNumberOfVessels = 1;
            VesselData_Test.createVessels();
            vesselInstance = VesselData_Test.lstVessels[0];
        }
        
        Incident__c incident;
        lstIncidents = new list<Incident__c>();
        for(integer i=0; i<iNumberOfIncidents; i++) {
            incident = new Incident__c();
            incident.Name = 'Test Incident ' + i;
            incident.Date_of_Incident__c = System.now();
            incident.Insured_Voyage__c = 'Test Voyage';
            incident.Insured_Vessel__c = vesselInstance.Id ;
            incident.Insurance_Category__c = 'Maersk Ocean';
            
            lstIncidents.add(incident);
        }
    }
    
    public static testMethod void createClaimEventIncidentsForLNS() {
        Id claimEventRTId = StaticFactory.getRecordTypeIdByName('Incident__c', 'Claim Event');
        Insurance_Policy__c ip= new Insurance_Policy__c();
        ip.name = 'test ip';
        ip.Deductible__c = 1000;
        //ip.Geographic_Scope__c = 'testGeo';
        ip.Insurance_category__c = 'Cargo Liabilities';
        ip.Insurer__c = 'test123';
        insert ip;
        system.debug('ip&&'+ip);
        lstIncidents = new list<Incident__c>();
        
        for(integer i=0; i<1; i++) {
            Incident__c incident = new Incident__c();
            incident.Name = 'Test Incident ' + i;
            incident.Date_of_Incident__c = System.now();
            incident.RecordTypeId = claimEventRTId;
            incident.Location__c = BDAGeographyData_Test.countryUK.Id;
            incident.Insurance_Category__c = 'Cargo Liabilities';
            incident.Insurance_Policy__c = ip.Id;
            
            lstIncidents.add(incident);
        }
        
        system.debug('lstIncidents##'+lstIncidents);
        
        if(bCreate) {
            insert lstIncidents;
        }
    }
    
}