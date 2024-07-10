/*
* Controller for searching ISR templates
* 
*Version    Date        Owner                  RQ#           Description
*********************************************************************************************************************************  
1.0       29-04-2024    Shahanawaz@Maersk      SC-10027      Auto Fill Details to ISR template
*/
public class ISRTemplateController {
    
    @AuraEnabled(cacheable=true)
    public static List<ISR_Template__c> getISRTemplates(String searchTerm){
        List<ISR_Template__c> isrTemplateList = new List<ISR_Template__c>();
        String query = 'Select Id, Name, SF_4PL_Account__c, Brand__c, Case_Visibility__c, Contact__c, Direction__c, Resolver_Dept__c, Collaboration_Reason__c From ISR_Template__c';
        if(!String.isBlank(searchTerm)){
            query += ' Where Name LIKE  \'%' + searchTerm + '%\'';
        }
        query += ' LIMIT 10';
        isrTemplateList = Database.query(query);
        return isrTemplateList;
    }

}