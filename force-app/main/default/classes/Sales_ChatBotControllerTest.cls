@isTest
public class Sales_ChatBotControllerTest {
    public static Id fAQArticleRecordTypeId = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByName().get('FAQ').getRecordTypeId();
    
    public static testmethod void testgetFAQ(){
    
    User usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    UserRole ur = [Select id from UserRole where name = 'Global - Teams'];
        
    List<User> userList = UserData_Test.createCustomerusers();
    PermissionSet publisherPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Power_Up_KB_Publishers'];
    PermissionSet adminPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Power_Up_KB_Administrators'];
        
    System.runAs(usr) {
      for(User u : userList){
       u.UserPermissionsKnowledgeUser = true;
       u.UserRoleId = ur.Id;
        }
       update userList;
       insert new PermissionSetAssignment(AssigneeId = userList[0].id, PermissionSetId = publisherPermission.Id);
       insert new PermissionSetAssignment(AssigneeId = userList[1].id, PermissionSetId = adminPermission.Id);             
    } 
        
    String articleTitle = 'OIPC';
    String articleBody = 'OIPC Body';
    String articleUrlName = 'OIPCtest';
    String language = 'en_US';
        
    Knowledge__kav article = new Knowledge__kav(
      Title = articleTitle,
      Summary = articleBody,
      UrlName = articleUrlName,
      Language = language,
      Description__c = 'TEst article for OIPC',
      Answer__c = 'OIPC Test',
      recordtypeId = fAQArticleRecordTypeId
    );
    insert article;
        
    List<Knowledge__DataCategorySelection> categoryList = new List<Knowledge__DataCategorySelection>();
    Knowledge__DataCategorySelection typ = new Knowledge__DataCategorySelection();
        typ.DataCategoryGroupName = 'Type';
        typ.DataCategoryName = 'OIPC';
        typ.ParentId = article.Id;
        categoryList.add(typ);    
     	insert  categoryList;  
        
    knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId,publishStatus FROM knowledge__kav WHERE id =: article.Id];
    
    List<Sales_ChatBotController.FAQSearchInput> lstInp =  new List<Sales_ChatBotController.FAQSearchInput>();
       Sales_ChatBotController.FAQSearchInput inp = new Sales_ChatBotController.FAQSearchInput();
       inp.sKeyword = 'OIPC';
       lstInp.add(inp);
        
       Id [] fixedSearchResults= new Id[1];
       fixedSearchResults[0] = obj1.Id;
       Test.setFixedSearchResults(fixedSearchResults);
        system.runAs(userList[0]){
            test.startTest();
            KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
            knowledge__kav obj2 = [SELECT Id,Title,KnowledgeArticleId,publishStatus FROM knowledge__kav WHERE id =: article.Id WITH DATA CATEGORY Type__c AT OIPC__c];
    		Sales_ChatBotController.getFAQ(lstInp);
            test.stopTest(); 
        }
    }

}