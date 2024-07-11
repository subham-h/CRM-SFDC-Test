/**
* Author   : Avinash@Maersk
* Purpose  : Test class for ExternalCaseCreationFormController class
* 
* Revision Ref Number  Date          Owner                  Description
* -------- ----------  -----------   -------------------    -----------
* 1.0      SC-7492     11-Apr-2023   Avinash@Maersk      Simplify External Manual Case Creation - POC
*/
@isTest
public class ExternalCaseCreationFormControllerTest {
    
    @isTest
    static void testExtCaseCreationForm(){
        Test.startTest();
        ExternalCaseCreationFormController.ExtWrapper extWrapList = new ExternalCaseCreationFormController.ExtWrapper();
        List<ExternalCaseCreationFormController.RecordTypeDetailsWrapper> lastRecTypeDetailsWrapper = new List<ExternalCaseCreationFormController.RecordTypeDetailsWrapper>();
        
        extWrapList = ExternalCaseCreationFormController.getFields('External Case Wizard', '');
        Assert.isTrue(!extWrapList.formFieldSectionWrapperList.isEmpty(), 'Fields present');
        
        lastRecTypeDetailsWrapper = ExternalCaseCreationFormController.getRecordTypeDetails();
        Assert.isTrue(!lastRecTypeDetailsWrapper.isEmpty(), 'Record Type present');
        Test.stopTest();
    }
    @isTest
    static void testProductBrandCaseCreationForm(){
        String userRole = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()].UserRole.Name;
        Test.startTest();
        ExternalCaseCreationFormController.getBrandAndProductValues();
        Test.stopTest();
    }
}