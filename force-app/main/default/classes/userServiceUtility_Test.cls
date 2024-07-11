/*
* Author   : Sunil.bs@Maersk Line.com
* Purpose  : Test class to cover ServiceNow Integration with Salesforce for Automation of Access Approval 
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-6348    17-11-2022   Sunil BS                Created.
*/

@istest
public class userServiceUtility_Test {

@istest
public static void testUpdateCaseClassification2(){
   Test.startTest();
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"Username": "hamilton","UserType": "Service","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "hi"}';        
        
        //  Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri ='https://Maersk Line--dev03.sandbox.lightning.force.com/services/apexrest/servicenowuserapproval';
        request.httpMethod = 'POST';
    	
           string reqbody = '{"Username": "hamilton","UserType": "Service","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "hi"}';
  
           request.requestBody = Blob.valueOf(reqbody);
     	   RestContext.request = request;
       	  // Call the method to test
      	   string s = userServiceUtility.dopost();
    
           string reqbody2 = '{"Username": "hamilton","UserType": "Service","Brand": "Maersk Line","Country": "G","CMVisibility": "Single Carrier","Role": "hi"}';
    	   request.requestBody = Blob.valueOf(reqbody2);
     	   RestContext.request = request;
    		string s2 = userServiceUtility.dopost();
    
           string reqbody3 = '{"Username": "hamilton","UserType": "Service","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "MC - APA"}';
    	   request.requestBody = Blob.valueOf(reqbody3);
     	   RestContext.request = request;
   			 string s3 = userServiceUtility.dopost();
    
           string reqbody4 = '{"Username": "hamilton","UserType": "Sales","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "MC - APA"}';
    	   request.requestBody = Blob.valueOf(reqbody4);
     	   RestContext.request = request;
     string s4 = userServiceUtility.dopost();
    
    string reqbody5 = '{"Username": "hamilton","UserType": "Sales","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "Multi-Carrier"}';
    	   request.requestBody = Blob.valueOf(reqbody5);
     	   RestContext.request = request;
     string s5 = userServiceUtility.dopost();
    
    //Code block for center role
    string reqbody6 = '{"Username": "hamilton","UserType": "Sales","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "Centre"}';
    	   request.requestBody = Blob.valueOf(reqbody6);
     	   RestContext.request = request;
     string s6 = userServiceUtility.dopost();
    
    
    //sales service type
      string reqbody7= '{"Username": "hamilton","UserType": "Sales","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "hi"}';
    	   request.requestBody = Blob.valueOf(reqbody7);
     	   RestContext.request = request;
     string s7 = userServiceUtility.dopost();
    
     //sales service type
      string reqbody9= '{"Username": "hamilton","UserType": "Sales","Brand": "Maersk Line","Country": "MZ","CMVisibility": "Single Carrier","Role": "hi"}';
    	   request.requestBody = Blob.valueOf(reqbody9);
     	   RestContext.request = request;
     string s9 = userServiceUtility.dopost();
    
    //Negative flow with wrong value for country code
      string reqbody8 = '{"Username": "hamilton","UserType": "Sales","Brand": "Maersk Line","Country": "G","CMVisibility": "Single Carrier","Role": "MC - APA"}';
      string s8 = userServiceUtility.dopost();
     // servicenowuserapprovalwrapper s13;
     //     s13.parse(reqbody8);
    
      User integrationUser = null;
     integrationUser =  new User(); 
     String dateTimeStr = string.valueOf(system.now());
            dateTimeStr = dateTimeStr.replaceAll(':', ' ');
            dateTimeStr = dateTimeStr.replaceAll(' ','');
    
    /*
    Geography__c recGeo;
      recGeo = new Geography__c(
                        Name = 'TESTCOUNTRY', //changed
                        Active__c =true,
                        GEO_Code__c = 'IN',
                        GEO_ID__c = '10Z2W9Zkjh3q4ab3',
                        Is_Port__c = false,
                        Type_Of_Location__c = 'Country');
                        
        Database.insert(recGeo);
    
    
       BDA__C recBDA = null;
       recBDA = new BDA__C ();
        recBDA.Name = 'Centre Function'; //'France Area';
        recBDA.Type__c = 'Cluster';
        recBDA.BDA_Code__c = 'dasdsaxceds';
        //#RQ-004639         Added new field GEO_id__c field 
        recBDA.GEO_ID__c= 'dasdsaxceds';
        recBDA.Active__c = true;
        recBDA.Default_Account_Owner__c = UserInfo.getUserId();//PR-0055-Added MSL Default owner field
        insert recBDA;
    
     list<user> userlist = new list<user>();
     Id integrationProfileId = Label.TestClean_ProfileIdsIntegrationUser;
            integrationUser.FirstName = 'Demo';                 
            integrationUser.LastName = 'Test User';                 
            integrationUser.Username = 'IntgUser'+dateTimeStr+'@ust-global.com';                 
            integrationUser.Email = 'Testuser@Maersk Line.com';                 
            integrationUser.Alias = 'tuser';                 
            integrationUser.CommunityNickname = 'dm1aasrsdfawr';                 
            integrationUser.TimeZoneSidKey = 'Europe/London';                 
            integrationUser.LocaleSidKey = 'en_GB';                 
            integrationUser.EmailEncodingKey = 'ISO-8859-1';                 
            integrationUser.ProfileId = integrationProfileId; 
            integrationUser.Country = recGeo.Name;                
            integrationUser.Cluster__c = recBDA.Name;
            //integrationUser.Quoting_Tool__c = 'Quote Builder';           //#RQ-004643      
            integrationUser.LanguageLocaleKey = 'en_US';  
            integrationUser.Liner_Brand__c = brandutilities.SEALANDEUROPE;//PR-0055-Added SealandEurope and SealandAsia Liner Brand
            //integrationUser.MLL__c = true;//#PR-0055 
            integrationUser.Maersk Line_User_id__c  = 'INT001';           //#RQ-001260 Adding Maersk Line user Id 
            integrationUser.Country_Cluster_Sales_Manager__c = true;            
            userList.add( integrationUser );
   			
 		    insert userList;*/

    //Code block for existing user
    list<user> u = [select username from user where isactive = true limit 1];
    string testusername = u[0].username;
    system.debug(+testusername);
       string reqbody10 = '{"Username": "'+testusername+'","UserType": "Sales","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "MC - APA"}';
    	   request.requestBody = Blob.valueOf(reqbody10);
     	   RestContext.request = request;
     string s10 = userServiceUtility.dopost();
    
     //Code block for existing user but is inactive
    list<user> u2 = [select username from user where isactive = false limit 1];
    string testusername2 = u2[0].username;
    system.debug(+testusername2);
       string reqbody11 = '{"Username": "'+testusername+'","UserType": "Sales","Brand": "Maersk Line","Country": "GB","CMVisibility": "Single Carrier","Role": "MC - APA"}';
    	   request.requestBody = Blob.valueOf(reqbody11);
     	   RestContext.request = request;
     string s11 = userServiceUtility.dopost();
    	Test.stopTest();
	}
}