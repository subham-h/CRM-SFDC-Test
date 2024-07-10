/*
* Field Populator Class for moduleTrigger.
* 
*Vesrion Date         Owner                                      Description
**************************************************************************************************
* 1.0    27/10/2014   ranjini.janardhanan@ust-global.com         Code created as part of #PR-0028.
* 2.0    02/01/2014   ranjini.janardhanan@ust-global.com         Deleted the code which was updating the program Module Duration.   
                                                                 #SP-0013.Added code for populating the ContentVesrionId.
* 3.0    21/12/2016   abby.abraham@ust-global.com                #RQ-004392 Introduced CBO architecture.
* 4.0    27/01/2017   abby.abraham@ust-global.com                #RQ-004731  Optimised Code. 
*/

public class ModuleFieldPopulator {
    
/*
* This method will populate the contentVersionId from the ContentDocumentId.
* ContentversionId is been used in the Badge image formula field
*/ 
    public static void updateBadgeContentVersionId(list<Module__c> newList) {
        
        list<Id> badgeContentIdList = new list<Id>();
        for (Module__c module : newList) {
            if (module.Badge_URL__c != null && (module.Badge_URL__c.length() == 15 || module.Badge_URL__c.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', module.Badge_URL__c)) {               
                badgeContentIdList.add(module.Badge_URL__c); // to get the module's Badge content Id list
            }               
        }
        
        // To get the map of Badge ContentId and ContentVersionId.
        map<Id,Id> contentIdVersionIdMap = new map<Id,Id>();
        if (badgeContentIdList.size() > 0) {
            // Takes the Id of the latest version.
            for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :badgeContentIdList AND islatest = :true]) { 
                contentIdVersionIdMap.put(cv.ContentDocumentId, cv.Id);
            }
        }
        
        if (contentIdVersionIdMap.size() > 0) {
            // Populating the Badge Content Version Id field.
            for (Integer i = 0;i < newList.size();i++) {
                if (newList[i].Badge_URL__c != null && (newList[i].Badge_URL__c.length() == 15 || newList[i].Badge_URL__c.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', newList[i].Badge_URL__c)) {
                    newList[i].Badge_Content_Version_Id__c = contentIdVersionIdMap.get(newList[i].Badge_URL__c);
                }else { 
                    newList[i].Badge_Content_Version_Id__c = '';
                }
            }
        }
    }

}