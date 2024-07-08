/*  
* Version	Ref Number		Date			Owner					Description
* --------	----------		------------	-----------				-----------
* 1.0		SFSE-11111		04-Jul-2023		Vazid					Code created : Test class for EmployeeHRData Trigger & its handlers
*/
@isTest
public class EmployeeHRDataTriggerTest {
    
    @testSetup
    static void testData() {
        List<BDA_Geography__c> bdaGeography = BDAGeographyData_Test.lstBDAGeographies;
    }
    
    @IsTest
    static void testEmployeeHrTriggerHandler() {
        
        if(UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        }
        if(UserDataGeneratorHelper_Test.salesUser == null){            
            UserDataGeneratorHelper_Test.initializeSalesUser();            
        } 
        List<Employee_HR_Data__c> lstEmpData = new List<Employee_HR_Data__c>();
        lstEmpData.add(SIPDataGeneratorHelper.SIP_Create_Employee_HR_Data(UserDataGeneratorHelper_Test.salesUser.Id, UserDataGeneratorHelper_Test.salesUser.Maersk_User_id__c , 
                                                                          UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id, 'Caribbean Sea Area', 'Latin America Region', 
                                                                          BrandUtilities.MAERSK,  date.newInstance(2022,1,1),  date.newInstance(2022,12, 31), 'One Team Sales'));
        
        lstEmpData.add(SIPDataGeneratorHelper.SIP_Create_Employee_HR_Data(UserDataGeneratorHelper_Test.mslsalesUser.Id, UserDataGeneratorHelper_Test.mslsalesUser.Maersk_User_id__c, 
                                                                          UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id, 'Caribbean Sea Area', 'Latin America Region', 
                                                                          BrandUtilities.MAERSK,  date.newInstance(2022,1,1),  date.newInstance(2022,12, 31), 'One Team Sales'));
        
        lstEmpData[0].Country_Code__c  = 'CN';
        
        insert lstEmpData;
        
        try {
            lstEmpData[0].Country_Code__c  = 'US';
            lstEmpData[1].Country_Code__c  = 'IN'; 
            update lstEmpData;
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('Country code (geo code) not found, please enter correct country code.'));
        }
        
    }
}