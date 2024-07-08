/**
* Helper class for generating Test data for Lead records

* Date         Owner                                            Description
******************************************************************************************************
* 05/02/2019   meghana.gupta@ust-global.com               RQ-004490 method to create leads
* 10/09/2020   meghana.gupta								SFSE-262: Add Source Brand while creating leads
*/

public class LeadDataGeneration {
    
      public static Lead createLead (String firstName, String lastName, String companyName, Id countryId, String brand, String strEmail, Id ownerId, Id campId, String LeadSource){
                
          Lead leadRec = new Lead();
          leadRec.FirstName = firstName;
          leadRec.LastName = lastName;
          leadRec.Country_lk__c = countryId;
          leadRec.Company = companyName;
          leadRec.Source_Brand__c = brand;
          leadRec.Email = strEmail;
          leadRec.LeadSource = LeadSource;
          
          if (ownerId != null)
          	leadRec.OwnerId = ownerId;
          
          leadRec.Primary_Campaign__c = campId;
          
          return leadRec;
    } 

}