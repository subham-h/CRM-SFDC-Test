/*
 * Author   : Jiji
 * Purpose  : Utility test class for creating Vessel Policy related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Jiji@UST                Created.
 * 
 */

@isTest
public class VesselPolicyData_Test {
    
    public static boolean bCreate = true;
    public static integer iNumberOfVesselPolicies = 5;
    public static list<Vessel_Policy__c> lstVesselPolicies;
    public static list<Vessel__c> lstVessels = new list<Vessel__c> ();
        
    public static testMethod void createVesselPolicies() {
        if(lstVessels.isEmpty()) {
            VesselData_Test.iNumberOfVessels = iNumberOfVesselPolicies;
            VesselData_Test.createVessels();
            lstVessels = VesselData_Test.lstVessels;
        }
        
        Vessel_Policy__c vpIterator;
        lstVesselPolicies = new list<Vessel_Policy__c>();
        for(integer i=0; i<iNumberOfVesselPolicies; i++) {
            vpIterator = new Vessel_Policy__c();
            vpIterator.Name = 'Test Vessel Policy' + i;
            vpIterator.Vessel__c = lstVessels[i].Id;
            vpIterator.Vessel_Policy_Start_Date__c = System.now().addDays(-10);
            vpIterator.Vessel_Policy_End_Date__c = System.now().addDays(10);
            lstVesselPolicies.add(vpIterator);
        }
        
        if(bCreate) {
            insert lstVesselPolicies;
        }
    }

}