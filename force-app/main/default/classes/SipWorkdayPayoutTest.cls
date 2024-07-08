@istest
public class SipWorkdayPayoutTest {
    @testSetup
    static void setupTestData(){
        
        if(UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        }
        if(UserDataGeneratorHelper_Test.salesUser == null){            
            UserDataGeneratorHelper_Test.initializeSalesUser();            
        } 
        
        List<Employee_HR_Data__c> lstEmpData = new List<Employee_HR_Data__c>();
        lstEmpData.add(SIPDataGeneratorHelper.SIP_Create_Employee_HR_Data(UserDataGeneratorHelper_Test.salesUser.Id, UserDataGeneratorHelper_Test.salesUser.Maersk_User_id__c , 
                                                                          UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id, 'Central America, Andina, Caribbean', 'Latin America Region', 
                                                                          BrandUtilities.MAERSK,  date.newInstance(2023,1,1),  date.newInstance(2023,12, 31), 'One Team Sales'));
        
        lstEmpData.add(SIPDataGeneratorHelper.SIP_Create_Employee_HR_Data(UserDataGeneratorHelper_Test.mslsalesUser.Id, UserDataGeneratorHelper_Test.mslsalesUser.Maersk_User_id__c, 
                                                                          null, 'Central America, Andina, Caribbean', 'Latin America Region', 
                                                                          BrandUtilities.MAERSK,  date.newInstance(2023,1,1),  date.newInstance(2023,12, 31), 'One Team Sales'));
        /*SFSE-9542 : START HERE*/
        lstEmpData[0].Employee_HR_Id__c = 'Employee1';
        lstEmpData[0].SIP_Status__c = 'New';
        lstEmpData[1].Employee_HR_Id__c = 'Employee2';
        lstEmpData[0].SIP_Status__c = 'Update Received on SIP Ineligibility';
        
        // inseert BDA to insert  payout curve bda
        BDA__c bdarec  = new BDA__c();
        bdarec.Name = 'Latin America Region';
        bdarec.BDA_Code__c = '123';
        bdarec.Type__c = 'Trade Region';
        bdarec.Active__c = true;
        bdarec.GEO_ID__c= 'test';
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
            insert bdarec;
        }
        
        BDA__c bdareccluster  = new BDA__c();
        bdareccluster.Name = 'Central America, Andina, Caribbean';
        bdareccluster.BDA_Code__c = '1234';
        bdareccluster.Type__c = 'Cluster';
        bdareccluster.Active__c = true;
        bdareccluster.GEO_ID__c= 'test12';
        bdareccluster.Parent_BDA__c = bdarec.id;
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
            insert bdareccluster;
        }
        
        List<SIP_Participant__c> sipUser = new List<SIP_Participant__c>();
        
        SIP_Participant__c newSIP = new SIP_Participant__c();
        newSIP.SIP_Participant__c = UserDataGeneratorHelper_Test.salesUser.Id;
        newSIP.Year__c = string.valueof(system.today().year());
        newSIP.Employee_HR_Id__c = 'Employee1';
        newSIP.Paymix__c = 80.0;        
        newSIP.Brand__c = BrandUtilities.MAERSK;
        newSIP.Region__c = bdarec.id;
        newSIP.Area__c = bdareccluster.id;
        newSIP.SIP_Participant_Id__c = 'SAL001';
        sipUser.add(newSIP);
        
        Validation_Rules_Bypass__c insertBypassvalidation = new Validation_Rules_Bypass__c(
            SetupOwnerId=UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id,
            Active__c= true
        );
        insert insertBypassvalidation;
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
            insert lstEmpData;
            insert sipUser;
        }        
    }
	
     @isTest static void Test1(){
        sipSearchAndBulkCreateCntrl.getInitLists();
        sipSearchAndBulkCreateCntrl.getEligibleUserList('2023', 'One Team Sales', 'Central America, Andina, Caribbean', '', 0, 200, 'Area__c', 'ASC', true,'No Longer Eligible' );
        sipSearchAndBulkCreateCntrl.getEligibleUserList('2023', '', '', 'Latin America Region', 0, 200, 'Area__c', 'ASC',false, 'New' );
        
        Map<Id, Employee_HR_Data__c> mapEmpData = new Map<Id, Employee_HR_Data__c>([Select id from Employee_HR_Data__c Limit 10]);
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/api/getsipdata?yr=2023&q=1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<SIP_Participant__c> sips = SipWorkdayPayout.getdata();
    }
    
    @IsTest
    static void abc() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        SipWorkdayPayout.herokuAuthentication();
        Test.stopTest();
    }
    
    @IsTest
    static void chkjobststatustest() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        SipWorkdayPayout.chkjobststatus();
        Test.stopTest();
    }
    
    @IsTest
    static void checkifFilePresentInFTPtest() {
     Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        SipWorkdayPayout.checkifFilePresentInFTP();
        Test.stopTest();   
    }
    
    @IsTest
    static void firejobtest(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        SipWorkdayPayout.firejob('{"user":"sidhartha.mohapatra@maersk.com","firejob":true,"quarter":"Q3","year":2024}');
        Test.stopTest();     
    }
    
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().endsWith('login')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('logged in successfully');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().endsWith('chkjobststatus')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('logged in successfully');
                res.setStatusCode(200);
                return res; 
            } else if (req.getEndpoint().endsWith('/')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('logged in successfully');
                res.setStatusCode(200);
                return res; 
            } else if (req.getEndpoint().endsWith('firejob')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('logged in successfully');
                res.setStatusCode(200);
                return res; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}