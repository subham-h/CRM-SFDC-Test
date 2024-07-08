/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-8141        22/08/2022     Meghana Gupta            Code Created
* 
* ***/

@isTest
public class Batch_Sip_LoadEmpHRData_Test {
    
    @testSetup static void setup() {
        if ( UserDataGeneratorHelper_Test.salesUser == null){
            
            UserDataGeneratorHelper_Test.initializeSalesUser();
        }
        
        Map<String, string> GeoMap = new Map<String, String>();
        GeoMap.put( 'TESTCOUNTRY', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( GeoMap );
        
        BDA__c bdaRegion = DataGeneratorHelper1_Test.createBDA ('Trade Region',null, UserDataGeneratorHelper_Test.integrationUser.Id);
        BDA__c bdaArea = DataGeneratorHelper1_Test.createBDA ('Cluster',bdaRegion.Id, UserDataGeneratorHelper_Test.integrationUser.Id);
        Map<Id, Id> mapBdaGeo = new Map<Id,Id>();
        mapBdaGeo.put(bdaArea.Id, geoList[0].Id);
        DataGeneratorHelper1_Test.createBDAGeography(mapBdaGeo);
        
        //SFSE-9443
        if(UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        }
        
        List<Employee_HR_Data__c> lstEmpData = new List<Employee_HR_Data__c>();
        lstEmpData.add(SIPDataGeneratorHelper.SIP_Create_Employee_HR_Data(UserDataGeneratorHelper_Test.salesUser.Id, UserDataGeneratorHelper_Test.salesUser.Maersk_User_id__c , 
                                                                          UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id, 'Caribbean Sea Area', 'Latin America Region', 
                                                                          BrandUtilities.MAERSK,  date.newInstance(2022,1,1),  date.newInstance(2022,12, 31), 'One Team Sales'));
        
        lstEmpData.add(SIPDataGeneratorHelper.SIP_Create_Employee_HR_Data(UserDataGeneratorHelper_Test.mslsalesUser.Id, UserDataGeneratorHelper_Test.mslsalesUser.Maersk_User_id__c, 
                                                                          UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id, 'Caribbean Sea Area', 'Latin America Region', 
                                                                          BrandUtilities.MAERSK,  date.newInstance(2022,1,1),  date.newInstance(2022,12, 31), 'One Team Sales'));
        
        lstEmpData[0].Employee_HR_Id__c = 'Employee3';
        lstEmpData[0].SIP_Status__c = 'New';
        lstEmpData[1].Employee_HR_Id__c = 'Employee4';
        lstEmpData[0].SIP_Status__c = 'Update Received on SIP Ineligibility';
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
            insert lstEmpData;
        }
        
    }
    
    @isTest
    public static void testBatchScheduler(){
        Test.setMock(HttpCalloutMock.class, new sipMock());

        Test.startTest();
        Batch_Sip_LoadEmpHRData_Scheduler sh1 = new Batch_Sip_LoadEmpHRData_Scheduler();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test Scheduler SIP', sch, sh1); 
        Test.stopTest();   
    }
    
    public class sipMock implements HttpCalloutMock { 
        
        public HTTPResponse respond(HTTPRequest req) {

            HTTPResponse res = new HTTPResponse(); 
            res.setStatusCode(200); 
            String json = '{ "Report_Entry": [ { "PositionTitle": "Sales Representative", "Months_For_Annualization": "12", "Manager_Unique_ID": "DRE039", "Brand_Name": "Maersk", "Employee_Unique_ID": "MGU127", "SIP_Eligiblity": "SIP", "Country_Alpha_2_Code": "IN1", "SIP_Noneligible": "2022-11-07", "IsManager": "0", "Paymix": "80", "SIP_Eligible_date": "2022-01-02" }, { "PositionTitle": "Sales Representative", "Months_For_Annualization": "12", "Manager_Unique_ID": "DRE039", "Brand_Name": "Maersk", "Employee_Unique_ID": "MGU127", "SIP_Eligiblity": "SIP", "Country_Alpha_2_Code": "", "IsManager": "1", "SIP_Eligible_date": "2022-01-02","termination_date": "2016-10-03" } ] }';
            res.setBody(json);
            
            return res; 
        } 
    }   
}