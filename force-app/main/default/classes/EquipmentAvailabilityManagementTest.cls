@isTest
public class EquipmentAvailabilityManagementTest {
    
    @isTest static void testGetEquipmentAvailability() {   
        Continuation conti =(Continuation)EquipmentAvailabilityManagement.getEquipmentAvailability('40','DRY','9 6','msl','test','test123456','10','');
        try{
        EquipmentAvailabilityManagement.processEquipmentAvailabilityReq('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processEquipmentAvailabilityReq');
    }
    
    @isTest static void testGetLocationNames() {   
        
         Geography__c geocode = new Geography__c();
         geocode.Name = 'Xingang';
         geocode.GEO_ID__c = '02GYFH4R8RVY6';
         geocode.GEO_Code__c = 'CNHSK';
         insert geocode;
         Geography__c geocode2 = new Geography__c();
         geocode2.Name = 'Le Havre';
         geocode2.GEO_ID__c = '274LBR94PNZWE';
         geocode2.GEO_Code__c = 'FRLEH';
         insert geocode2;
        EquipmentAvailabilityManagement.getLocationNames(new list<string>{'CNHSK','FRLEH'});          
    }
}