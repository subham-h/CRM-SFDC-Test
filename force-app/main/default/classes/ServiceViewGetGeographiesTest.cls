@isTest
public class ServiceViewGetGeographiesTest {
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
        ServiceViewGetGeographies.getGeographies('FRLEH');          
    }
    
      @isTest static void testGetGeoCodes() {   
        
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
          ServiceViewGetGeographies.getGeoCodes(new list<string>{'274LBR94PNZWE'});          
    }

}