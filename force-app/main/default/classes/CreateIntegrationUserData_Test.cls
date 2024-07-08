/**
 * Version     Owner                                Date                Description
 * 2.0         Ranjini.Janardhanan@ust-global.com   12.02.2015          #RQ-000875Removed profile Name hardcoding.
 * 3.0         deepak.r.mahapatra@in.ibm.com        21-02-2017          #RQ-004643 : Delete Quoting Tool Field in the User object 
 * 4.0         manjunath@maersk                     12-12-2019          #RQ-012411 : Added a valid value for BDA name(as per User.Cluster__c picklist)
 * 5.0         Amritesh@UST	                        14/04/2020          #RQ-013373 : Fixed bad cluster value
 * 6.0         Ronnie@SF                            27/06/2022          #SPI100: Removed brand hardcoding
 ************************************************************************************/
@isTest
public class CreateIntegrationUserData_Test
{ 
    public static Profile integrationProfile=null;
    public static BDA__C testBDA=null;
    public static User integrationUser=null;
    public static User MSLIntegrationUser=null;
    public static User SCLIntegrationUser=null;
    public static User systemAdminUser=null;
    public static User MSLSystemAdminUser=null;
    public static User SCLSystemAdminUser=null;
    public static User SEAIntegrationUser=null;
    public static Profile systemAdminProfile=null;

    public static void initializeIntegrationUser()
    {
        //integrationProfile=[Select Id,Name from Profile where Name = :Label.Integration_User];                 
        //systemAdminProfile=[Select Id,Name from Profile where Name = :Label.System_Administrator];    

        User test_user = [ Select id from User where id = :Userinfo.getUserId()];
       
        Geography__c geo = new Geography__c();
        geo.Name = 'TestGeography';
        geo.Type_Of_Location__c = 'Country';
        geo.GEO_ID__c = '0QK7LWQMLOXVI';
        insert geo;
        
        testBDA=new BDA__C ();
        testBDA.Name='Centre Function'; //'France Area';
        testBDA.Type__c='Cluster';
        testBDA.BDA_Code__c='dfrtrewq';
        testBDA.Active__c = true;
        testBDA.GEO_ID__c = geo.GEO_ID__c;
        insert testBDA;
        
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Test COuntry', 'Country');
        DataGeneratorHelper1_Test.createGeography (GeoCountryList);
        String dateTimeStr = string.valueOf(system.now());
        dateTimeStr = dateTimeStr.replaceAll(':', ' ');
        dateTimeStr = dateTimeStr.replaceAll(' ','');
        system.runas(test_user)
        {        
            integrationUser= new User();                 
            integrationUser.FirstName='Demo';
            integrationUser.isActive = true;    
            integrationUser.LastName='Test User';                 
            integrationUser.Username='TestUser'+dateTimeStr+'@ust-global.com';                 
            integrationUser.Email='TestUseasdr@ust-global.com';                 
            integrationUser.Alias='tdf784';  
            integrationUser.phone = '+44 1234123456';
            integrationUser.Mobilephone = '+44 1234123456';
            integrationUser.fax='89652358';
            integrationUser.Street ='Test Street';
            integrationUser.City = 'Test City';
            integrationUser.State = 'Tx';
            integrationUser.PostalCode ='1234';
            //integrationUser.Region__C = 'Centre Function';
            integrationUser.Country ='Test COuntry';
            //integrationUser.Quoting_Tool__c='Quote Builder';  //#RQ-004643             
            //integrationUser.Quoting_Tool__c='AFLS';           //#RQ-004643
            integrationUser.CommunityNickname='dmfs53';                 
            integrationUser.TimeZoneSidKey='Europe/London';                 
            integrationUser.LocaleSidKey='en_GB';                 
            integrationUser.EmailEncodingKey='ISO-8859-1';                 
            integrationUser.ProfileId=Label.Integration_User_Profile_Id;                 
            integrationUser.Cluster__c=testBDA.Name;                 
            integrationUser.LanguageLocaleKey='en_US';  
            integrationUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;// Dual Brand ; Integration User  
            integrationUser.Maersk_User_Id__c = 'MSL123';               
            insert integrationUser;
            
            MSLIntegrationUser= new User();                 
            MSLIntegrationUser.FirstName='Demo';
            MSLIntegrationUser.isActive = true;
            MSLIntegrationUser.LastName='Test User';                 
            MSLIntegrationUser.Username='TestMSL'+dateTimeStr+'@ust-global.com';                 
            MSLIntegrationUser.Email='TestUsesdv43r@ust-global.com';                 
            MSLIntegrationUser.Alias='tu772v'; 
            MSLIntegrationUser.phone = '+44 1234123456';
            MSLIntegrationUser.Mobilephone = '+44 1234123456';
            MSLIntegrationUser.fax='+44 1234123456';
            MSLIntegrationUser.Street ='Test Street';
            MSLIntegrationUser.City = 'Test City';
            MSLIntegrationUser.State = 'Tx';
            MSLIntegrationUser.PostalCode ='1234';
            //MSLIntegrationUser.Region__C = 'Centre Function';
            MSLIntegrationUser.MLL__c = TRUE;
            MSLIntegrationUser.Country ='Test COuntry';
            //MSLIntegrationUser.Quoting_Tool__c='Quote Builder';     //#RQ-004643          
            //MSLIntegrationUser.Quoting_Tool__c='AFLS';              //#RQ-004643
            MSLIntegrationUser.CommunityNickname='dfw21v';                 
            MSLIntegrationUser.TimeZoneSidKey='Europe/London';                 
            MSLIntegrationUser.LocaleSidKey='en_GB';                 
            MSLIntegrationUser.EmailEncodingKey='ISO-8859-1';                 
            MSLIntegrationUser.ProfileId=Label.Integration_User_Profile_Id;                 
            MSLIntegrationUser.Cluster__c=testBDA.Name;                 
            MSLIntegrationUser.LanguageLocaleKey='en_US';  
            MSLIntegrationUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;     // Maersk Line; Integration User      
            MSLIntegrationUser.Maersk_User_Id__c = 'MSL345';         
            insert MSLIntegrationUser;
            
            SCLIntegrationUser= new User();                 
            SCLIntegrationUser.FirstName='Demo';
            SCLIntegrationUser.isActive = true; 
            SCLIntegrationUser.LastName='Test User';                 
            SCLIntegrationUser.Username='TestSCL'+dateTimeStr+'@ust-global.com';                 
            SCLIntegrationUser.Email='TestUseoiohr@ust-global.com';                 
            SCLIntegrationUser.Alias='tu562d';  
            SCLIntegrationUser.phone = '+44 1234123456';
            SCLIntegrationUser.Mobilephone = '+44 1234123456';
            SCLIntegrationUser.fax='+44 1234123456';
            SCLIntegrationUser.Street ='Test Street';
            SCLIntegrationUser.City = 'Test City';
            SCLIntegrationUser.State = 'Tx';
            SCLIntegrationUser.PostalCode ='1234';
            //SCLIntegrationUser.Region__C = 'Centre Function';
            SCLIntegrationUser.Country ='Test COuntry';
            //SCLIntegrationUser.Quoting_Tool__c='Quote Builder';      //#RQ-004643         
            //SCLIntegrationUser.Quoting_Tool__c='AFLS';               //#RQ-004643
            SCLIntegrationUser.CommunityNickname='sdf23';                 
            SCLIntegrationUser.TimeZoneSidKey='Europe/London';                 
            SCLIntegrationUser.LocaleSidKey='en_GB';                 
            SCLIntegrationUser.EmailEncodingKey='ISO-8859-1';                 
            SCLIntegrationUser.ProfileId=Label.Integration_User_Profile_Id;                 
            SCLIntegrationUser.Cluster__c=testBDA.Name;                 
            SCLIntegrationUser.LanguageLocaleKey='en_US';  
            SCLIntegrationUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;     // Safmarine; Integration User                  
            SCLIntegrationUser.Maersk_User_Id__c='MSL567';     
            insert SCLIntegrationUser;
            
            SEAIntegrationUser= new User();                 
            SEAIntegrationUser.FirstName='Demo';
            SEAIntegrationUser.isActive = true; 
            SEAIntegrationUser.LastName='Test User';                 
            SEAIntegrationUser.Username='TestUsaf326krfer@ust-global.com';                 
            SEAIntegrationUser.Email='TestSEA'+dateTimeStr+'@ust-global.com';                 
            SEAIntegrationUser.Alias='tus23';  
            SEAIntegrationUser.phone = '+44 1234123456';
            SEAIntegrationUser.Mobilephone = '+44 1234123456';
            SEAIntegrationUser.fax='+44 1234123456';
            SEAIntegrationUser.Street ='Test Street';
            SEAIntegrationUser.City = 'Test City';
            SEAIntegrationUser.State = 'Tx';
            SEAIntegrationUser.PostalCode ='1234';
            //SEAIntegrationUser.Region__C = 'Centre Function';
            SEAIntegrationUser.Country ='Test COuntry';
            //SEAIntegrationUser.Quoting_Tool__c='Quote Builder';    //#RQ-004643           
            //SEAIntegrationUser.Quoting_Tool__c='AFLS';             //#RQ-004643
            SEAIntegrationUser.CommunityNickname='sai24';                 
            SEAIntegrationUser.TimeZoneSidKey='Europe/London';                 
            SEAIntegrationUser.LocaleSidKey='en_GB';                 
            SEAIntegrationUser.EmailEncodingKey='ISO-8859-1';                 
            SEAIntegrationUser.ProfileId=Label.Integration_User_Profile_Id;                 
            SEAIntegrationUser.Cluster__c=testBDA.Name;                 
            SEAIntegrationUser.LanguageLocaleKey='en_US';  
            SEAIntegrationUser.Liner_Brand__c = BrandUtilities.SEALAND;     // Sealand; Integration User                  
            insert SEAIntegrationUser;
            
            
            
            systemAdminUser= new User();                 
            systemAdminUser.FirstName='Demo'; 
            systemAdminUser.isActive = true;   
            systemAdminUser.LastName='System User';                 
            systemAdminUser.Username='Systemaf235nhgUser@ust-global.com';                 
            systemAdminUser.Email='SystemUswdf563er@ust-global.com';                 
            systemAdminUser.Alias='sus123'; 
            systemAdminUser.phone = '+44 1234123456';
            systemAdminUser.Mobilephone = '+44 1234123456';
            systemAdminUser.fax='+44 1234123456';
            systemAdminUser.Street ='Test Street';
            systemAdminUser.City = 'Test City';
            systemAdminUser.State = 'Tx';
            systemAdminUser.PostalCode ='1234';
            //systemAdminUser.Region__C = 'Centre Function';
            systemAdminUser.Country ='Test COuntry';            
            //systemAdminUser.Quoting_Tool__c='Quote Builder';  //#RQ-004643             
            //systemAdminUser.Quoting_Tool__c='AFLS'; //#RQ-004643
            systemAdminUser.CommunityNickname='sai60';                 
            systemAdminUser.TimeZoneSidKey='Europe/London';                 
            systemAdminUser.LocaleSidKey='en_GB';                 
            systemAdminUser.EmailEncodingKey='ISO-8859-1';                 
            systemAdminUser.ProfileId=Label.TestClean_ProfileIdsSystemAdmin;                 
            systemAdminUser.Cluster__c=testBDA.Name;                 
            systemAdminUser.LanguageLocaleKey='en_US';      
            systemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;  // Dual Brand ; System Admin              
            insert systemAdminUser;    
            
            MSLSystemAdminUser= new User();                 
            MSLSystemAdminUser.FirstName='Demo';
            MSLSystemAdminUser.isActive = true; 
            MSLSystemAdminUser.LastName='System User';                 
            MSLSystemAdminUser.Username='Sys235sd64@ust-global.com';                 
            MSLSystemAdminUser.Email='Syst32523@ust-global.com';                 
            MSLSystemAdminUser.Alias='sus3';  
            MSLSystemAdminUser.phone = '+44 1234123456';
            MSLSystemAdminUser.Mobilephone = '+44 1234123456';
            MSLSystemAdminUser.fax='+44 1234123456';
            MSLSystemAdminUser.Street ='Test Street';
            MSLSystemAdminUser.City = 'Test City';
            MSLSystemAdminUser.State = 'Tx';
            MSLSystemAdminUser.PostalCode ='1234';
            //MSLSystemAdminUser.Region__C = 'Centre Function';
            MSLSystemAdminUser.Country ='Test COuntry';
            //MSLSystemAdminUser.Quoting_Tool__c='Quote Builder'; //#RQ-004643              
            //MSLSystemAdminUser.Quoting_Tool__c='AFLS'; //#RQ-004643
            MSLSystemAdminUser.CommunityNickname='sai0435';                 
            MSLSystemAdminUser.TimeZoneSidKey='Europe/London';                 
            MSLSystemAdminUser.LocaleSidKey='en_GB';                 
            MSLSystemAdminUser.EmailEncodingKey='ISO-8859-1';                 
            MSLSystemAdminUser.ProfileId=Label.TestClean_ProfileIdsSystemAdmin;                 
            MSLSystemAdminUser.Cluster__c=testBDA.Name;                 
            MSLSystemAdminUser.LanguageLocaleKey='en_US';      
            MSLSystemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // Maersk Line ; System Admin          
            insert MSLSystemAdminUser;
            
            
            SCLSystemAdminUser= new User();                 
            SCLSystemAdminUser.FirstName='Demo';
            SCLSystemAdminUser.isActive = true;     
            SCLSystemAdminUser.LastName='System User';                 
            SCLSystemAdminUser.Username='SystemUser123456@ust-global.com';                 
            SCLSystemAdminUser.Email='SystemSCLAdm@ust-global.com';                 
            SCLSystemAdminUser.Alias='susfrt4';
            SCLSystemAdminUser.phone = '+44 1234123456';
            SCLSystemAdminUser.Mobilephone = '+44 1234123456';
            SCLSystemAdminUser.fax='+44 1234123456';
            SCLSystemAdminUser.Street ='Test Street';
            SCLSystemAdminUser.City = 'Test City';
            SCLSystemAdminUser.State = 'Tx';
            SCLSystemAdminUser.PostalCode ='1234';
            //SCLSystemAdminUser.Region__C = 'Centre Function';
            SCLSystemAdminUser.Country ='Test COuntry';
            //SCLSystemAdminUser.Quoting_Tool__c='Quote Builder';    //#RQ-004643           
            //SCLSystemAdminUser.Quoting_Tool__c='AFLS';             //#RQ-004643
            SCLSystemAdminUser.CommunityNickname='scl75';                 
            SCLSystemAdminUser.TimeZoneSidKey='Europe/London';                 
            SCLSystemAdminUser.LocaleSidKey='en_GB';                 
            SCLSystemAdminUser.EmailEncodingKey='ISO-8859-1';                 
            SCLSystemAdminUser.ProfileId=Label.TestClean_ProfileIdsSystemAdmin;                 
            SCLSystemAdminUser.Cluster__c=testBDA.Name;                 
            SCLSystemAdminUser.LanguageLocaleKey='en_US';      
            SCLSystemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // Safmarine ; System Admin            
            insert SCLSystemAdminUser;  
        }
    } 
}