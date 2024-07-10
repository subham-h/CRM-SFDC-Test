/**
 * Description  : Test Class for publishKnowledgeArticleController class.
 * 
 * Version       Date                Owner                                 Description
 *******************************************************************************************************************
 * v1.0          01/01/2020          sreya.v@maersk.com                    Test Class for publishKnowledgeArticleController class.
 * v2.0          27/06/2022          Ronnie@SF                             SPI-100: Removed brand hardcoding
 *-------------------------------------------------------------------------------------------------------------------
 */

@isTest
public class publishKnowledgeArticleControllerTest {
    
    public static Id advisoryArticleRecordTypeId = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByName().get('Advisory').getRecordTypeId();    
    public static Id fAQArticleRecordTypeId = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByName().get('FAQ').getRecordTypeId();  
    public static Id SOPArticleRecordTypeId = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByName().get('SOP').getRecordTypeId(); 
    
    @testSetup
    public static void testDataSetup(){
        List<knowledge__kav> articleList = new List<knowledge__kav>();
        List<Knowledge__DataCategorySelection> categoryList = new List<Knowledge__DataCategorySelection>();
        
        knowledge__kav know = new knowledge__kav();
        know.Title = 'test Advisory';
        know.UrlName = 'sample-Advisory';
        know.Description__c = 'test article';
        know.RecordTypeId = advisoryArticleRecordTypeId;
        articleList.add(know);
        
        knowledge__kav know1 = new knowledge__kav();
        know1.Title = 'test FAQ';
        know1.UrlName = 'sample-FAQ';
        know1.Description__c = 'test article';
        know1.Answer__c = 'Test Answer';
        know1.RecordTypeId = fAQArticleRecordTypeId;
        articleList.add(know1);
        
        knowledge__kav know2 = new knowledge__kav();
        know2.Title = 'test SOP';
        know2.UrlName = 'sample-SOP';
        know2.Description__c = 'test article';
        know2.RecordTypeId = SOPArticleRecordTypeId;
        articleList.add(know2);
  
        insert articleList;
        
        Knowledge__DataCategorySelection geo = new Knowledge__DataCategorySelection();
        geo.DataCategoryGroupName = 'Geography';
        geo.DataCategoryName = 'Europe';
        geo.ParentId = articleList[0].Id;
        categoryList.add(geo);

        Knowledge__DataCategorySelection geo1 = new Knowledge__DataCategorySelection();
        geo1.DataCategoryGroupName = 'Geography';
        geo1.DataCategoryName = 'Global';
        geo1.ParentId = articleList[1].Id;
        categoryList.add(geo1);
  
        Knowledge__DataCategorySelection geo2 = new Knowledge__DataCategorySelection();
        geo2.DataCategoryGroupName = 'Geography';
        geo2.DataCategoryName = 'Global';
        geo2.ParentId = articleList[2].Id;
        categoryList.add(geo2);
  
        for (knowledge__kav kn : articleList){
             Knowledge__DataCategorySelection type = new Knowledge__DataCategorySelection();
            type.DataCategoryGroupName = 'Type';
            type.DataCategoryName = 'Booking';
            type.ParentId = kn.Id;
            categoryList.add(type);
            
            Knowledge__DataCategorySelection brand = new Knowledge__DataCategorySelection();
            brand.DataCategoryGroupName = 'Liner_Brand';
            brand.DataCategoryName = BrandUtilities.MAERSKLINE.replace(' ', '_');
            brand.ParentId = kn.Id;
            categoryList.add(brand);
        }
            
        insert categoryList;       
        
    }
    public static testMethod void testPublishKnowledgeArticle(){
         List<Knowledge__DataCategorySelection> categoryList = new List<Knowledge__DataCategorySelection>();
        
        User usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        UserRole ur = [Select id from UserRole where name = 'Global - Teams'];
        
        List<User> userList = UserData_Test.createCustomerusers();
        
        system.debug('userList'+userList);
        system.debug('userpermission'+userList[0].UserPermissionsKnowledgeUser);
        
        PermissionSet publisherPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Power_Up_KB_Publishers'];
        PermissionSet adminPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Power_Up_KB_Administrators'];
        
        //To avoid mixed dml  
        System.runAs(usr) {
            for(User u : userList){
                u.UserPermissionsKnowledgeUser = true;
                u.UserRoleId = ur.Id;
            }
            update userList;
            insert new PermissionSetAssignment(AssigneeId = userList[0].id, PermissionSetId = publisherPermission.Id);
            insert new PermissionSetAssignment(AssigneeId = userList[1].id, PermissionSetId = adminPermission.Id);             
            
        } 
        
        knowledge__kav advisoryArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE RecordTypeId =: advisoryArticleRecordTypeId limit 1];
        knowledge__kav faqArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE RecordTypeId =: fAQArticleRecordTypeId limit 1];
        knowledge__kav sopArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE RecordTypeId =: SOPArticleRecordTypeId limit 1];        
         
        //List<PermissionSetAssignment> assignee = [SELECT AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Power_Up_KB_Administrators' and Assignee.IsActive= true limit 1];
    
        Datetime dueDate = system.now() + 1;        
        String translatedFAQ = KbManagement.PublishingService.submitForTranslation(faqArticle.KnowledgeArticleId, 'fr', userList[1].id, dueDate);
        String translatedSOP = KbManagement.PublishingService.submitForTranslation(sopArticle.KnowledgeArticleId, 'fr', userList[1].id, dueDate);
        
      
        System.runAs(userList[0]) {
            publishKnowledgeArticleController.publishArticle(faqArticle.Id); 
        }
        
        System.runAs(userList[1]) {
            
            publishKnowledgeArticleController.publishArticle(advisoryArticle.Id);
            publishKnowledgeArticleController.publishArticle(faqArticle.Id); 
            
            knowledge__kav publishedArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE RecordTypeId =: advisoryArticleRecordTypeId limit 1];
            publishKnowledgeArticleController.publishArticle(publishedArticle.Id);
            
            publishKnowledgeArticleController.publishArticle(translatedFAQ);             
            
            publishKnowledgeArticleController.publishArticle(translatedSOP);
            publishKnowledgeArticleController.publishArticle(translatedSOP);
            publishKnowledgeArticleController.publishArticle(sopArticle.Id);
            
        }
        
    }   
}