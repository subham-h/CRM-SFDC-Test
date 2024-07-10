/*
* Utility test class for MaerskIdeaOperations Class.
* 
*Version    Date           Owner                                      RQ#           Description
*********************************************************************************************************************************  
1.0       8-02-2022    somya.mahapatra@maersk.com			        #SC-4143   	   Code created.
*/

@isTest
public class MaerskIdeaOperations_Test {
	
    public static testMethod void testRetriveIdeas(){
        Maersk_Idea__c newIdea = new Maersk_Idea__c();
        List<Maersk_Idea__c> fetchedIdeas = new List<Maersk_Idea__c>();
        List<Maersk_Idea__c> fetchedEmptyIdeas = new List<Maersk_Idea__c>();
        Boolean exceptionOccurred = false;
        
        newIdea.Application__c = 'Salesforce Service View';
        newIdea.Maersk_Idea_Topic__c = 'Random Topic';
        newIdea.Outcome_Type__c = 'User Experience Enhancement';
        newIdea.What_does_it_mean_for_the_Customer__c = 'Null';
        newIdea.Maersk_Opportunity_Problem_Statement__c = 'Test Idea';
        newIdea.Maersk_Idea_Description__c = 'Test Class';
        insert newIdea;

        Maersk_Idea__c getNewIdea = [SELECT Name, Application__c, Owner.Name FROM Maersk_Idea__c WHERE Id = :newIdea.Id];
        
        fetchedIdeas  = MaerskIdeaOperations.retriveIdeas(getNewIdea.Name, 'Name');
        fetchedEmptyIdeas = MaerskIdeaOperations.retriveIdeas(getNewIdea.Name + 'Test', 'Name');
        fetchedIdeas  = MaerskIdeaOperations.retriveIdeas(getNewIdea.Application__c, 'Application');
        fetchedEmptyIdeas = MaerskIdeaOperations.retriveIdeas(getNewIdea.Application__c + 'Test', 'Application');

        
        
        Test.startTest();
        System.assert(!fetchedIdeas.isEmpty(),'Maersk Idea Fetched List should not be empty');
        System.assert(fetchedEmptyIdeas.isEmpty(),'The records retrived were empty');
        Test.stopTest();
    }
    
    public static testMethod void testMergeSelectedIdeas(){
         
        List<Maersk_Idea__c> ideaList = new List<Maersk_Idea__c>();
        for(Integer i = 1; i<=3; i++){
            Maersk_Idea__c newIdea = new Maersk_Idea__c();
            newIdea.Application__c = 'Salesforce Service View';
            newIdea.Maersk_Idea_Topic__c = 'Topic'+i;
            newIdea.Outcome_Type__c = 'User Experience Enhancement';
            newIdea.What_does_it_mean_for_the_Customer__c = 'Null';
            newIdea.Maersk_Opportunity_Problem_Statement__c = 'Test Idea';
            newIdea.Maersk_Idea_Description__c = 'Test Class';
            
            ideaList.add(newIdea);
        }
        insert ideaList;
        
        String parentId=ideaList[0].Id;
        List<String> childID = new List<String>{ideaList[1].Id, ideaList[2].Id};
        List<Additional_Owners__c> childOwnerList = new List<Additional_Owners__c>();
        for(String child : childId){
            Additional_Owners__c addOwner= new Additional_Owners__c(Maersk_Idea__c = child, 
                                                          Additional_Owner_Name__c = UserInfo.getUserId());
            childOwnerList.add(addOwner);
        }
        insert childOwnerList;
        
        List<ContentDocumentLink> childDocList = new List<ContentDocumentLink>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        for(String child : childId){  
        	ContentVersion cv = new ContentVersion(Title = child, PathOnClient = 'test', VersionData = beforeblob );  
            cvList.add(cv);
        }
        insert cvList;
        
        for(String child : childId){         
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Title = :child];
            ContentDocumentLink addDocument= new ContentDocumentLink(ContentDocumentId = testContent.ContentDocumentId, 
                                                                     ShareType = 'I',  
                                                                     LinkedEntityId = child);
            childDocList.add(addDocument);
        }
        insert childDocList;
        
         
       	 UserDataGeneratorHelper_Test.initializeSystemAdminUser();
         User testUser = UserDataGeneratorHelper_Test.systemAdminUser;
		 System.runAs(testUser){
             Test.startTest();
             MaerskIdeaOperations.mergeSelectedIdeas(parentId, childId);
             Test.stopTest();
        }
       
    }
}