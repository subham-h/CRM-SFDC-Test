/*      
* Revision		Ref Number		Date			Owner						Description
* --------		----------		-----------		-------------------			-------------------------
* 1.0			SFSE-10739		24-May-2023		Neha@Maersk					Test class for OpportunityApprovalSLAController, which is used for displaying and updating SLA for Opportunity Approvals
* 1.1							26-Jul-2023		Kiran@Maersk				New test data framework
*/
@isTest
public class OpportunityApprovalSLAControllerTest {

    @testSetup static void setup() {
        
        Approval_Process__c processProductsSolution = TestBusinessHelper.createApprovalPorcess('Pursuit Gate Products', Label.Solution_Gate, 'Product', 7, 4, true, true);
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        
        User superUser = TestBusinessHelper.createUser('Super User', BrandUtilities.MAERSKLINE, false);
        superUser.Id = null;
        superUser.IsActive=true;
        superUser.country = 'India';
        superUser.Cluster__c = 'GSC';
        superUser.Industry_Focus__c='Retail';
        superUser.Segment_Focus__c='Advancement';
        superUser.Sales_Job_Function__c='Other';
        superUser.CM_Visibility__c = 'Single Carrier';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert superUser;
        }
        
    }
    
    // Method to get the SLA from Approval process based on Gate and Sub gate search
    @isTest static void getSLAfromApprovalProcessTest() {
        Approval_Process__c solutionProducts = [SELECT Id, Name, Gate__c, Sub_Gate__c, CreatedById FROM Approval_Process__c WHERE Gate__c =: Label.Solution_Gate AND Sub_Gate__c = 'Product' and Active__c= true LIMIT 1];
        User superUser = [Select id, Name, Profile.Name, Email, UserName from User where ProfileId =:Label.Super_User_Profile_Id AND IsActive = true LIMIT 1];
        System.debug('superUser '+superUser);
        System.runAs(superUser){
            Test.startTest();
            List<Approval_Process__c> processes = OpportunityApprovalSLAController.getSLAfromApprovalProcess(solutionProducts.Gate__c, solutionProducts.Sub_Gate__c); 
            system.assertEquals(processes.size(), 1);
            Test.stopTest();
        }
    }
    
    @isTest static void updateSLATest() {
        Approval_Process__c solutionProducts = [SELECT Id, Name, Gate__c, Sub_Gate__c, CreatedById FROM Approval_Process__c WHERE Gate__c =: Label.Solution_Gate AND Sub_Gate__c = 'Product' and Active__c= true LIMIT 1];
        User superUser = [Select id, Name, Profile.Name, Email, UserName from User where ProfileId =:Label.Super_User_Profile_Id AND IsActive = true LIMIT 1];
        System.debug('superUser '+superUser);
        System.runAs(superUser){
            Test.startTest();
            OpportunityApprovalSLAController.updateSLA(solutionProducts.id, '2', solutionProducts.Gate__c, solutionProducts.Sub_Gate__c); 
            solutionProducts = [SELECT Id, Name, Gate__c, Sub_Gate__c, SLA__c FROM Approval_Process__c WHERE Gate__c =: Label.Solution_Gate AND Sub_Gate__c = 'Product' and Active__c= true LIMIT 1];
            OpportunityApprovalSLAController.getUpdatedSLA(solutionProducts.id);
            system.assertEquals(solutionProducts.SLA__c, 2); //To make sure SLA is updated as 2            
            Test.stopTest();
        }
    }
    
}