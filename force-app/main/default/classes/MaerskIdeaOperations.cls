/*
* Utility class to manage operations from maerskIdeaMegeIdeas lwc component.
* 
*Version    Date           Owner                                      RQ#           Description
*********************************************************************************************************************************  
1.0       8-02-2022    somya.mahapatra@maersk.com                   #SC-4143       Code created.
*/
public class MaerskIdeaOperations {
    
    @AuraEnabled(Cacheable = true)
    public static list<Maersk_Idea__c> retriveIdeas(String strIdeaField,String strIdeaVal) {
        list<Maersk_Idea__c> IdeasList;
        String fieldValue = '%'+strIdeaField+'%';
        if(strIdeaVal == Label.Name)
        {
            IdeasList = [SELECT  Name, Application__c, Owner.Name,Maersk_Idea_Topic__c, Outcome_Type__c,Idea_Stage__c From Maersk_Idea__c WHERE Name LIKE :fieldValue AND Idea_Stage__c != :Label.Closed_Merged];
        }else if(strIdeaVal == Label.Application)
        {
            IdeasList = [SELECT  Name, Application__c, Owner.Name,Maersk_Idea_Topic__c, Outcome_Type__c,Idea_Stage__c From Maersk_Idea__c WHERE Application__c LIKE :fieldValue AND Idea_Stage__c != :Label.Closed_Merged];
        }
        else if(strIdeaVal == Label.Idea_Owner)
        { 
            IdeasList = [SELECT  Name, Application__c, Owner.Name,Maersk_Idea_Topic__c, Outcome_Type__c,Idea_Stage__c From Maersk_Idea__c WHERE Owner.Name LIKE :fieldValue AND Idea_Stage__c != :Label.Closed_Merged];
        }
        

        return IdeasList; 
    }
    
    @AuraEnabled()
    public static void mergeSelectedIdeas(String parentId, list<String> childId) {      
        
        List<Maersk_Idea__c> maerskIdeaToUpdate = [SELECT Id, Idea_Stage__c, Parent_Idea__c FROM Maersk_Idea__c WHERE Id in :childId];
        
        if(!maerskIdeaToUpdate.isEmpty()) {
            for(Maersk_Idea__c maerskIdeaObject: maerskIdeaToUpdate){
                maerskIdeaObject.Idea_Stage__c = Label.Closed_Merged;
                maerskIdeaObject.Parent_Idea__c = parentId;
            }
            update maerskIdeaToUpdate;
        }
                
        List<Additional_Owners__c> additionalOwnersToInsert = [SELECT Additional_Owner_Name__c FROM Additional_Owners__c 
                                                               WHERE Maersk_Idea__c in :childId];
        List<Additional_Owners__c> parentAdditionalOwners=new List<Additional_Owners__c>();
        if(!additionalOwnersToInsert.isEmpty()) {
            for(Additional_Owners__c childAdditionalOwner: additionalOwnersToInsert){
                Additional_Owners__c additional = new Additional_Owners__c(Maersk_Idea__c = parentId, 
                                                                           Additional_Owner_Name__c = childAdditionalOwner.Additional_Owner_Name__c);
                parentAdditionalOwners.add(additional);
            }
            
            delete additionalOwnersToInsert;
            
            if(!parentAdditionalOwners.isEmpty()) {
                insert parentAdditionalOwners;
            }
        }
        
        List<ContentDocumentLink> attachmentList = [SELECT  LinkedEntityId, ContentDocumentId, ShareType, 
                                                    Visibility FROM ContentDocumentLink where LinkedEntityId in :childId];
        List<ContentDocumentLink> changeParents = new List<ContentDocumentLink>();
        if(!attachmentList.isEmpty()) {
            for(ContentDocumentLink attachment: attachmentList){
                ContentDocumentLink con = new ContentDocumentLink(ContentDocumentId = attachment.ContentDocumentId, 
                                                                  ShareType = attachment.ShareType, Visibility=attachment.Visibility, 
                                                                  LinkedEntityId = parentId);
                changeParents.add(con);
            }
            
            if(!changeParents.isEmpty()) {
                insert changeParents;
            }
            
        }
        
    }
}