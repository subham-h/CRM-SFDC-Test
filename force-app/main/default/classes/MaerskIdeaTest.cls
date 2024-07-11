/**
*
 * test class Claims for Maersk Ideas Module.
 * 
 *
 * 
 *  Date           Owner                                  Description
*********************************************************************************************************************************  
 * 
 *  04/03/2022    divya.kumari@maersk.com                 testMaerskIdeaSubmission:Testing creation of Maersk Idea 
 *  04/03/2022    divya.kumari@maersk.com                 testFPOReview:Testing FPO Review 
 *  04/03/2022    divya.kumari@maersk.com                 testValidateAnchorReview:Testing Change Anchor Review
 *  04/03/2022    divya.kumari@maersk.com                 testChangeAnchorShouldNotAcceptorRejectIdea:Testing Change Anchor Should not Accept or RejectIdea 
 *  27/06/2022    Ronnie@SF                               SPI-100: Removed brand hardcoding
*/

@isTest public class MaerskIdeaTest {

    @isTest 
    
    //Testing creation of Maersk Idea
    public static void testMaerskIdeaSubmission()
    {    
        Maersk_Idea__c maerskidea = TestDataFactoryHelper.maerskIdeaCreation();
        
        
        List<Maersk_Idea__c> createdmaerskidea  = [SELECT id,Maersk_Idea_Topic__c,Idea_Stage__c,Functional_Product_Owner__c,Idea_Age__c,Application__c,CreatedById,Owner_Area__c,Owner_Brand__c,Owner_Country__c,Owner_Profile__c,Owner_Region__c,Owner_Role__c  FROM Maersk_Idea__c WHERE id=:maerskidea.id ];
 
        System.assertEquals(createdmaerskidea.size(),1,'New Maersk idea Created');
        System.assertEquals('New',createdmaerskidea[0].Idea_Stage__c,'Idea stage check');
        System.assertEquals(BrandUtilities.MAERSKLINE + ';', createdmaerskidea[0].Owner_Brand__c,'Brand check');

    }
    
 
    //Testing FPO Review 
    @isTest
    public static void testFPOReview()
    {

        User testUser=TestDataFactoryHelper.createUser();
        Maersk_Idea__c maerskidea = TestDataFactoryHelper.maerskIdeaCreation();
        
        System.runAs(testUser)
        {
            Test.startTest();
            List<Maersk_Idea__c> createdmaerskidea  = [SELECT id,Maersk_Idea_Topic__c,Idea_Stage__c,Functional_Product_Owner__c,Idea_Age__c,Application__c  FROM Maersk_Idea__c WHERE id=:maerskidea.id ];
            maerskidea.Idea_Stage__c='Closed-Merged'; 
            //maerskidea.Reason_for_Rejection__c='Cost-Benefit Not Justified';
            update maerskidea;              
            Test.stopTest();   
         }     
        System.assertEquals('Closed-Merged',maerskidea.Idea_Stage__c,'Idea stage check');
        
    }
    
    //Testing Change Anchor Review
    @isTest
    public static void testChangeAnchorReview()
    {
        User createdUser = TestDataFactoryHelper.createUser();
        User createdUserAdmin = TestDataFactoryHelper.createUser();
          
        system.runAs(createdUserAdmin){
            PermissionSet ps = [SELECT Id,Label FROM PermissionSet WHERE Name = 'Maersk_Idea_Area_Change_Anchor_Access'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = CreatedUser.Id,
            PermissionSetId = ps.Id);
            insert psa;

        }
        
               
        Maersk_Idea__c maerskidea = TestDataFactoryHelper.maerskIdeaCreation();
        System.runAs(CreatedUser)
        {
            
            Test.startTest();
            List<Maersk_Idea__c> createdmaerskidea  = [SELECT id,Maersk_Idea_Topic__c,Idea_Stage__c,Functional_Product_Owner__c,Idea_Age__c,Application__c  FROM Maersk_Idea__c WHERE id=:maerskidea.id ];
            maerskidea.Idea_Stage__c='Change Anchor Approved';
            
            update maerskidea;              
            Test.stopTest();   
        }     
        System.assertEquals('Change Anchor Approved',maerskidea.Idea_Stage__c, 'Idea stage Check');        

    }
    
    //Testing Change Anchor Should not Accept or RejectIdea
    @isTest
    public static void testChangeAnchorShouldNotAcceptorRejectIdea()
    {
        try{
        User createdUser = TestDataFactoryHelper.createUser();
        User createdUserAdmin = TestDataFactoryHelper.createUser();
          
        system.runAs(createdUserAdmin){
            PermissionSet ps = [SELECT Id,Label FROM PermissionSet WHERE Name = 'Maersk_Idea_Area_Change_Anchor_Access'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = CreatedUser.Id,
            PermissionSetId = ps.Id);
            insert psa;

        }
        
               
        Maersk_Idea__c maerskidea = TestDataFactoryHelper.maerskIdeaCreation();
        System.runAs(CreatedUser)
        {
            
            Test.startTest();
            List<Maersk_Idea__c> createdmaerskidea  = [SELECT id,Maersk_Idea_Topic__c,Idea_Stage__c,Functional_Product_Owner__c,Idea_Age__c,Application__c  FROM Maersk_Idea__c WHERE id=:maerskidea.id ];
            maerskidea.Idea_Stage__c='Rejected'; 
            update maerskidea;              
            Test.stopTest();   
        }  
        }
        Catch(Exception ex)
        {
            
            System.Assert(ex.getMessage().contains('Only Functional Product Owners can perform this action.: []'),'Exception message');
        }
        
    }
    

    }