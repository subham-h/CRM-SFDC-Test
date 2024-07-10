/*
 * Author   : Jiji
 * Purpose  : Utility test class for creating Vessel related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Jiji@UST                Created.
 * 
 */

@isTest
public class VesselData_Test {
    
    public static boolean bCreate = true;
    public static integer iNumberOfVessels = 5;
    public static list<Vessel__c> lstVessels;
    
    public static testMethod void createVessels() {
        lstVessels = new list<Vessel__c>();
        for(integer i=0; i<iNumberOfVessels; i++) {
            Vessel__c VesselIterator = new Vessel__c();
            VesselIterator.Name = 'Test Vessel ' + i;
            VesselIterator.Vessel_Name__c = 'Test Vessel ' + i;
            lstVessels.add(VesselIterator);
        }
        
        if(bCreate) {
            insert lstVessels;
        }
    }

}