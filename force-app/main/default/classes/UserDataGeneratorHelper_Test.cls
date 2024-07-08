/**
 * Test user creation helper class
* Creates different users which can be used in test classes.
 * version history
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Rev   Name                                      Date               RQ#                Comments
 * 
 * 1.    revathy.sudhindran@ust-global.co                             #RQ-000803         As part of editing test classes related this RQ added Sealand user creation
 * 2.    revathy.sudhindran@ust-global.com         16/04/2015         #PR-0047           MCC Brand Integration
 * 3.    revathy.sudhindran@ust-global.com         01/06/2015         #RQ-001260         Improve handling of Customer Owners who are not SFDC Users
 * 4.    Madhava.kotte@ust-global.com              17/06/2015         #PR-0054           Created MLL users 
 * 5.    Sunu.Paul@ust-global.com                  09/11/2015         #PR-0055           Created Seago users 
 * 6.    Sandhya.Sambasivan@ust-global.com         16/12/2015         #RQ-002247         Case Test class refactoring
 * 7.    Meghana.gupta@ust-global.com              20/12/2015         #RQ-002192         Added method to add user to a group
 * 8.    Sunu.Paul@ust-global.com                  10/02/2016         #RQ-002978         Added method to craete Super User
 * 9.    Madhava.kotte@ust-global.com              31/03/2016         #RQ-002301         OpportunityTrigger Refactoring
 * 10.   deepak.r.mahapatra@in.ibm.com             21/02/2017         #RQ-004643         Delete Quoting Tool Field in the User object 
 * 11.   ramadevi.palaniswamy@ust-global.com       03/10/2017         #RQ-004639         Added new field GEO_id__c field while creating BDA records
 * 12.   abby.abrahamust-global.com                06/04/2017         #RQ-004759         Modified test class to accomodate User Country Mandatory Validation Rule
 * 13.   ramadevi.palaniswamy@ust-global.com       03/10/2017         #RQ-004639         Included a user for Centre TNM Profile
 * 14.   Meenakshi.Rajasekaran@ust-global.com      16/09/2018          #RQ-008547         Included Receive case ownership change checkbox for MSLCustomerserve user
 * 15.   Junaid.Khader@ust-global.com              14/08/2018         #RQ-011435         Removed method initializeCentreTNMUser which was used for CluAp
 * 16.   manjunath@maersk                          12/12/2019        #RQ-012411         Added a valid value for BDA name(as per User.Cluster__c picklist)
 * 17.   manjunath@maersk                          30/01/2020        #RQ-012371         Removed references of deprecated field, User.User_Level__c
 * 18.   Amritesh@UST                              31/03/2020         #RQ-013342         Fixed bad cluster value   
 * 19.   meghana@UST                               15/10/2020         SFSE-4767          Users can not have Brand=Safmarine
 * 20.   Nitin@Maersk                              05/07/2021         SFSE-6249          Amended to use Math.round(Math.random()*1000) for email field on user creation
 * 21.   Ronnie@SF                                 27/06/2022         SPI-100            Removed brand hardcoding
 * 22.   Ronnie@SF                                 07/09/2022         CRM0000030         Removed redundant SOQL queries
*/
@isTest
public class UserDataGeneratorHelper_Test {
    
    public static BDA__C recBDA = null;
    public static User integrationUser = null;
    public static User MSLIntegrationUser = null;
    public static User SCLIntegrationUser = null;
    public static User SEAIntegrationUser = null;
    public static User MCCIntegrationUser = null;
    public static User MLLIntegrationUser = null;  //#RQ-002301
    public static User SeagoIntegrationUser = null;//#PR-0055
    
    public static User systemAdminUser = null;
    public static User MSLSystemAdminUser = null;
    public static User SCLSystemAdminUser = null;
    public static User SEASystemAdminUser = null;
    public static User MCCSystemAdminUser = null;
    public static User MLLSystemAdminUser = null; //#RQ-002301
    public static User SeagoSystemAdminUser=null;//#PR-0055
    public static User MSLTenderSystemAdminUser = null;
    
    //public static Profile systemAdminProfile = null;
    //public static Profile salesProfile = null;
    public static User salesUser = null;
    public static User MSLSalesUser = null;
    public static User SCLSalesUser = null;
    public static User SEASalesUser = null;
    public static User MCCSalesUser = null;
    public static User MLLSalesUser = null;
    public static User SeagosalesUser=null;//#PR-0055
    
    public static Profile customerServiceProfile = null; //#RQ-002247
    public static User MSLCustomerServiceUser = null;//#RQ-002247
    public static User MLLCustomerServiceUser = null;//#RQ-002247
    public static User SCLCustomerServiceUser = null;//#RQ-002247
    public static User SEACustomerServiceUser = null;//#RQ-002247
    public static User MCCCustomerServiceUser = null;//#RQ-002247
    
    public static Profile CentreTNMProfile= null;
    public static User CentreTNMUser=Null;
    public static User ETLIntegrationUser = Null;
    public static User SuperUser = null;//#RQ-002978
    
    // create test BDA record of type Cluster
    public static BDA__C createtestBDA(){
        
        BDA__C testBDA = new BDA__C ();
        testBDA.Name = 'Centre Function'; //'France Area';
        testBDA.Type__c = 'Cluster';
        testBDA.BDA_Code__c = 'dsrergtrr';
        //#RQ-004639         Added new field GEO_id__c field 
        testBDA.GEO_ID__c= 'dsrergtrr';
        testBDA.Active__c = true;
        insert testBDA;
        
        return testBDA;
    }
    
    // initialize integration users for all brands
    public static void initializeIntegrationUser(){
        
        List<User> userList = new List<User> ();
        Id integrationProfileId = Label.TestClean_ProfileIdsIntegrationUser;
        Id eTLProfileId = Label.ETLInterfaceProfileId;
        Geography__c recGeo;

        recBDA = new BDA__C ();
        recBDA.Name = 'Centre Function'; //'France Area';
        recBDA.Type__c = 'Cluster';
        recBDA.BDA_Code__c = 'dasdsaxcedss';
        //#RQ-004639         Added new field GEO_id__c field 
        recBDA.GEO_ID__c= 'dasdsaxceds';
        recBDA.Active__c = true;
        recBDA.Default_Account_Owner__c = UserInfo.getUserId();//PR-0055-Added MSL Default owner field
        insert recBDA;
        
         //#RQ-004759
        recGeo = new Geography__c(
                        Name = 'TESTCOUNTRY', //changed
                        Active__c =true,
                        GEO_Code__c = 'IN',
                        GEO_ID__c = '10Z2W9Zkjh3q4ab3',
                        Is_Port__c = false,
                        Type_Of_Location__c = 'Country');
                        
        Database.insert(recGeo);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {       
            String dateTimeStr = string.valueOf(system.now());
            dateTimeStr = dateTimeStr.replaceAll(':', ' ');
            dateTimeStr = dateTimeStr.replaceAll(' ','');
            
            integrationUser =  new User();                 
            integrationUser.FirstName = 'Demo';                 
            integrationUser.LastName = 'Test User';                 
            integrationUser.Username = 'IntgUser'+dateTimeStr+'@ust-global.com';                 
            integrationUser.Email = 'Tesrev096784sd' + Math.round(Math.random()*1000) + '@ust-global.com';                 
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
            integrationUser.Liner_Brand__c = BrandUtilities.SEAGO;//PR-0055-Added Seago and MCC Liner Brand
            //integrationUser.MLL__c = true;//#PR-0055 
            integrationUser.Maersk_User_id__c  = 'INT001';           //#RQ-001260 Adding Maersk user Id 
            integrationUser.Country_Cluster_Sales_Manager__c = true;            
            userList.add( integrationUser );
                        
            SCLIntegrationUser =  new User();                 
            SCLIntegrationUser.FirstName = 'Demo';                 
            SCLIntegrationUser.LastName = 'efesfwetr';                 
            SCLIntegrationUser.Username = 'SCL'+dateTimeStr+'@ust-global.com';                 
            SCLIntegrationUser.Email = 'Teajjh68293f' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SCLIntegrationUser.Alias = 'tuser';                 
            SCLIntegrationUser.CommunityNickname = 'dmasfasrf3';                 
            SCLIntegrationUser.TimeZoneSidKey = 'Europe/London';                 
            SCLIntegrationUser.LocaleSidKey = 'en_GB';                 
            SCLIntegrationUser.EmailEncodingKey = 'ISO-8859-1';                 
            SCLIntegrationUser.ProfileId = integrationProfileId;
            SCLIntegrationUser.Country = recGeo.Name;                 
            SCLIntegrationUser.Cluster__c = recBDA.Name;
            //SCLIntegrationUser.Quoting_Tool__c = 'Quote Builder';     //#RQ-004643            
            SCLIntegrationUser.LanguageLocaleKey = 'en_US';  
            SCLIntegrationUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;     // Safmarine; Integration User   
            SCLIntegrationUser.Maersk_User_id__c  = 'INT003';      //#RQ-001260 Adding Maersk user Id   
            userList.add( SCLIntegrationUser );
        
            ETLIntegrationUser = new User();
            ETLIntegrationUser.FirstName = 'DemoMl';                 
            ETLIntegrationUser.LastName = 'sdf43';                 
            ETLIntegrationUser.Username = 'MLL@ust-global.com';                 
            ETLIntegrationUser.Email = 'mllTestd3df12' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            ETLIntegrationUser.Alias = 't4323sf';                 
            ETLIntegrationUser.CommunityNickname = 'mls3ws3212';                 
            ETLIntegrationUser.TimeZoneSidKey = 'Europe/London';                 
            ETLIntegrationUser.LocaleSidKey = 'en_GB';                 
            ETLIntegrationUser.EmailEncodingKey = 'ISO-8859-1';                 
            ETLIntegrationUser.ProfileId = eTLProfileId; 
            ETLIntegrationUser.Country = recGeo.Name;                 
            ETLIntegrationUser.Cluster__c = recBDA.Name;
            ETLIntegrationUser.LanguageLocaleKey = 'en_US';  
            ETLIntegrationUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;       
            ETLIntegrationUser.MLL__c = true;
            userList.add(ETLIntegrationUser);
                     
            SEAIntegrationUser =  new User();                 
            SEAIntegrationUser.FirstName = 'Desmo';                 
            SEAIntegrationUser.LastName = 'efesfwafetr';                 
            SEAIntegrationUser.Username = BrandUtilities.SEALAND + dateTimeStr + '@ust-global.com';
            SEAIntegrationUser.Email = 'Tebkar646gjhqw11' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SEAIntegrationUser.Alias = 'tusxer';                 
            SEAIntegrationUser.CommunityNickname = 'dma24da1';                 
            SEAIntegrationUser.TimeZoneSidKey = 'Europe/London';                 
            SEAIntegrationUser.LocaleSidKey = 'en_GB';                 
            SEAIntegrationUser.EmailEncodingKey = 'ISO-8859-1';                 
            SEAIntegrationUser.ProfileId = integrationProfileId;
            SEAIntegrationUser.Country = recGeo.Name;               
            SEAIntegrationUser.Cluster__c = recBDA.Name;
            //SEAIntegrationUser.Quoting_Tool__c = 'Quote Builder';   //#RQ-004643              
            SEAIntegrationUser.LanguageLocaleKey = 'en_US';  
            SEAIntegrationUser.Liner_Brand__c = BrandUtilities.SEALAND;     // Sealand; Integration User 
            SEAIntegrationUser.Maersk_User_id__c  = 'INT004';      //#RQ-001260 Adding Maersk user Id   
            userList.add( SEAIntegrationUser );         
            
            MSLIntegrationUser =  new User();                 
            MSLIntegrationUser.FirstName = 'Demo';                 
            MSLIntegrationUser.LastName = 'Test User';                 
            MSLIntegrationUser.Username = 'Tes0997@ust-global.com';                 
            MSLIntegrationUser.Email = 'Tewe766582' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MSLIntegrationUser.Alias = 'tuser';                 
            MSLIntegrationUser.CommunityNickname = 'dm2asfwer';                 
            MSLIntegrationUser.TimeZoneSidKey = 'Europe/London';                 
            MSLIntegrationUser.LocaleSidKey = 'en_GB';                 
            MSLIntegrationUser.EmailEncodingKey = 'ISO-8859-1';                 
            MSLIntegrationUser.ProfileId = integrationProfileId; 
            MSLIntegrationUser.Country = recGeo.Name;                
            MSLIntegrationUser.Cluster__c = recBDA.Name;
            //MSLIntegrationUser.Quoting_Tool__c = 'Quote Builder';         //#RQ-004643       
            MSLIntegrationUser.LanguageLocaleKey = 'en_US';  
            MSLIntegrationUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;     // Maersk Line; Integration User        
            MSLIntegrationUser.Maersk_User_id__c  = 'INT002';      //#RQ-001260 Adding Maersk user Id 
            userList.add( MSLIntegrationUser );
        
            MCCIntegrationUser =  new User();                 
            MCCIntegrationUser.FirstName = 'Desmo';                 
            MCCIntegrationUser.LastName = 'efesfwafetr';                 
            MCCIntegrationUser.Username = BrandUtilities.MCC + dateTimeStr + '@ust-global.com';                 
            MCCIntegrationUser.Email = 'Tebkar646gjh241' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MCCIntegrationUser.Alias = 'tusxer';                 
            MCCIntegrationUser.CommunityNickname = 'dma24da21';                 
            MCCIntegrationUser.TimeZoneSidKey = 'Europe/London';                 
            MCCIntegrationUser.LocaleSidKey = 'en_GB';                 
            MCCIntegrationUser.EmailEncodingKey = 'ISO-8859-1';                 
            MCCIntegrationUser.ProfileId = integrationProfileId;
            MCCIntegrationUser.Country = recGeo.Name;                 
            MCCIntegrationUser.Cluster__c = recBDA.Name;
            //MCCIntegrationUser.Quoting_Tool__c = 'Quote Builder';        //#RQ-004643         
            MCCIntegrationUser.LanguageLocaleKey = 'en_US';  
            MCCIntegrationUser.Liner_Brand__c = BrandUtilities.MCC;     
            MCCIntegrationUser.Maersk_User_id__c  = 'INT005';                 
            userList.add( MCCIntegrationUser ); 
            
            //#PR-0054:MLL Integrator user
            MLLIntegrationUser =  new User();                 
            MLLIntegrationUser.FirstName = 'DemoMl';                 
            MLLIntegrationUser.LastName = 'sdf43';                 
            MLLIntegrationUser.Username = BrandUtilities.MLL + dateTimeStr + '@ust-global.com';                 
            MLLIntegrationUser.Email = 'mllTestd3df' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MLLIntegrationUser.Alias = 't4323sf';                 
            MLLIntegrationUser.CommunityNickname = 'mls3ws32';                 
            MLLIntegrationUser.TimeZoneSidKey = 'Europe/London';                 
            MLLIntegrationUser.LocaleSidKey = 'en_GB';                 
            MLLIntegrationUser.EmailEncodingKey = 'ISO-8859-1';                 
            MLLIntegrationUser.ProfileId = integrationProfileId; 
            MLLIntegrationUser.Country = recGeo.Name;              
            MLLIntegrationUser.Cluster__c = recBDA.Name;
            //MLLIntegrationUser.Quoting_Tool__c = 'Quote Builder';           //#RQ-004643      
            MLLIntegrationUser.LanguageLocaleKey = 'en_US';  
            MLLIntegrationUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;       
            MLLIntegrationUser.MLL__c = true;        
            userList.add( MLLIntegrationUser );
           
            //#PR-0055-Added Seago Integration User
            SeagoIntegrationUser= new User();                 
            SeagoIntegrationUser.FirstName='Desmo';                 
            SeagoIntegrationUser.LastName='efesfwafetr';                 
            SeagoIntegrationUser.Username = BrandUtilities.SEAGO + dateTimeStr + '@ust-global.com';
            SeagoIntegrationUser.Email='Seago646gjh241' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SeagoIntegrationUser.Alias='tseago';                 
            SeagoIntegrationUser.CommunityNickname='sgl24da21';                 
            SeagoIntegrationUser.TimeZoneSidKey='Europe/London';                 
            SeagoIntegrationUser.LocaleSidKey='en_GB';                 
            SeagoIntegrationUser.EmailEncodingKey='ISO-8859-1';                 
            SeagoIntegrationUser.ProfileId = integrationProfileId;
            SeagoIntegrationUser.Country = recGeo.Name;                 
            SeagoIntegrationUser.Cluster__c=recBDA.Name;
            //SeagoIntegrationUser.Quoting_Tool__c='Quote Builder';     //#RQ-004643            
            SeagoIntegrationUser.LanguageLocaleKey='en_US';  
            SeagoIntegrationUser.Liner_Brand__c = BrandUtilities.SEAGO;     // Seago; Integration User  
            SeagoIntegrationUser.Maersk_User_id__c ='INT006';                 
            userList.add( SeagoIntegrationUser);
            
            insert userList;  
        }
    }  
    
    public static void initializeSystemAdminUser()
    {
        Id systemAdminProfileId = Label.TestClean_ProfileIdsSystemAdmin;
        Geography__c recGeo;
        BDA__c testBDA = new BDA__c();
        testBDA.Name = 'Centre Function'; //'France Area';
        testBDA.Type__c = 'Cluster';
        testBDA.BDA_Code__c = 'qe3e4ee';
        //#RQ-004639         Added new field GEO_id__c field 
        testBDA.GEO_ID__c= 'qe3e4ee';
        testBDA.Active__c  =  true;
        insert testBDA;
        
         //#RQ-004759
        recGeo = new Geography__c(
                        Name = 'TESTCOUNTRY',
                        Active__c =true,
                        GEO_Code__c = 'IN',
                        GEO_ID__c = '10Z2W9Zkjh3q4ab4',
                        Is_Port__c = false,
                        Type_Of_Location__c = 'Country');
                        
        Database.insert(recGeo);
        
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            systemAdminUser =  new User();                 
            systemAdminUser.FirstName = 'Demffo';                 
            systemAdminUser.LastName = 'System User';                 
            systemAdminUser.Username = 'Srgn5771r@ust-global.com';                 
            systemAdminUser.Email = 'Syb121077d' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            systemAdminUser.Alias = 'suser';                 
            systemAdminUser.CommunityNickname = 'sya1';                 
            systemAdminUser.TimeZoneSidKey = 'Europe/London';                 
            systemAdminUser.LocaleSidKey = 'en_GB';                 
            systemAdminUser.EmailEncodingKey = 'ISO-8859-1';                 
            systemAdminUser.ProfileId = systemAdminProfileId;
            systemAdminUser.Country = recGeo.Name;                
            systemAdminUser.Cluster__c = testBDA.Name;
            systemAdminUser.LanguageLocaleKey = 'en_US';      
            systemAdminUser.Liner_Brand__c = BrandUtilities.getAllBrandsString(); //'Maersk Line;MCC;Seago;Sealand';  // Dual Brand ; System Admin //#PR-0055
            systemAdminUser.Maersk_User_Id__c  =  'SYS001' ; //#RQ-001260 Adding Maersk user Id             
            insert systemAdminUser;    
            
            MSLSystemAdminUser =  new User();                 
            MSLSystemAdminUser.FirstName = 'dasdf324';                 
            MSLSystemAdminUser.LastName = 'System User';                 
            MSLSystemAdminUser.Username = 'Sase123dsaf@ust-global.com';                 
            MSLSystemAdminUser.Email = 'Sasdger65wefa' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MSLSystemAdminUser.Alias = 'suser';                 
            MSLSystemAdminUser.CommunityNickname = 'sya2';                 
            MSLSystemAdminUser.TimeZoneSidKey = 'Europe/London';                 
            MSLSystemAdminUser.LocaleSidKey = 'en_GB';                 
            MSLSystemAdminUser.EmailEncodingKey = 'ISO-8859-1';                 
            MSLSystemAdminUser.ProfileId = systemAdminProfileId; 
            MSLSystemAdminUser.Country = recGeo.Name;               
            MSLSystemAdminUser.Cluster__c = testBDA.Name;
            MSLSystemAdminUser.LanguageLocaleKey = 'en_US';      
            MSLSystemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // Maersk Line ; System Admin   
            MSLSystemAdminUser.Maersk_User_Id__c  =  'SYS002' ; //#RQ-001260 Adding Maersk user Id             
            insert MSLSystemAdminUser;
            
            MSLTenderSystemAdminUser =  new User();                 
            MSLTenderSystemAdminUser.FirstName = 'Demo';                 
            MSLTenderSystemAdminUser.LastName = 'System User';                 
            MSLTenderSystemAdminUser.Username = 'MSLTender.Sysadmin@ust-global.com';                 
            MSLTenderSystemAdminUser.Email = 'TeweTender766582' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MSLTenderSystemAdminUser.Alias = 'suser';                 
            MSLTenderSystemAdminUser.CommunityNickname = 'dm2asfwer2';                 
            MSLTenderSystemAdminUser.TimeZoneSidKey = 'Europe/London';                 
            MSLTenderSystemAdminUser.LocaleSidKey = 'en_GB';                 
            MSLTenderSystemAdminUser.EmailEncodingKey = 'ISO-8859-1';                 
            MSLTenderSystemAdminUser.ProfileId = systemAdminProfileId;
            MSLTenderSystemAdminUser.Country = recGeo.Name;                 
            MSLTenderSystemAdminUser.Cluster__c = testBDA.Name;
            MSLTenderSystemAdminUser.LanguageLocaleKey = 'en_US';  
            MSLTenderSystemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;     // Maersk Line; Integration User        
            MSLTenderSystemAdminUser.Maersk_User_id__c  = 'SYS102';      //#RQ-001260 Adding Maersk user Id 
            insert MSLTenderSystemAdminUser ;
            
            SCLSystemAdminUser =  new User();                 
            SCLSystemAdminUser.FirstName = 'Demo';                 
            SCLSystemAdminUser.LastName = 'Sdfweef';                 
            SCLSystemAdminUser.Username = 'Ssdfsgd3212tr@ust-global.com';                 
            SCLSystemAdminUser.Email = 'Sgfh12e6ssr' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SCLSystemAdminUser.Alias = 'suser';                 
            SCLSystemAdminUser.CommunityNickname = 'sya3';                 
            SCLSystemAdminUser.TimeZoneSidKey = 'Europe/London';                 
            SCLSystemAdminUser.LocaleSidKey = 'en_GB';                 
            SCLSystemAdminUser.EmailEncodingKey = 'ISO-8859-1';                 
            SCLSystemAdminUser.ProfileId = systemAdminProfileId;
            SCLSystemAdminUser.Country = recGeo.Name;                
            SCLSystemAdminUser.Cluster__c = testBDA.Name;
            SCLSystemAdminUser.LanguageLocaleKey = 'en_US';      
            SCLSystemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // Safmarine ; System Admin      
            SCLSystemAdminUser.Maersk_User_Id__c  =  'SYS003' ; //#RQ-001260 Adding Maersk user Id             
            insert SCLSystemAdminUser;  
            
           // List <User> userList  =  new List <User>{systemAdminUser,MSLSystemAdminUser,SCLSystemAdminUser};
           // insert userList;   
           //#RQ-000803 Added the beow user creation       
            SEASystemAdminUser =  new User();                 
            SEASystemAdminUser.FirstName = 'Demo';                 
            SEASystemAdminUser.LastName = 'Sdfweef';                 
            SEASystemAdminUser.Username = 'Ssdfsgd3212ter@ust-global.com';                 
            SEASystemAdminUser.Email = 'Sgfh12e6sser' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SEASystemAdminUser.Alias = 'suser';                 
            SEASystemAdminUser.CommunityNickname = 'sya4';                 
            SEASystemAdminUser.TimeZoneSidKey = 'Europe/London';                 
            SEASystemAdminUser.LocaleSidKey = 'en_GB';                 
            SEASystemAdminUser.EmailEncodingKey = 'ISO-8859-1';                 
            SEASystemAdminUser.ProfileId = systemAdminProfileId;                 
            SEASystemAdminUser.Cluster__c = testBDA.Name;
            SEASystemAdminUser.Country = recGeo.Name;
            SEASystemAdminUser.LanguageLocaleKey = 'en_US';      
            SEASystemAdminUser.Liner_Brand__c = BrandUtilities.SEALAND;      // Sealand ; System Admin 
            SEASystemAdminUser.Maersk_User_Id__c  =  'SYS004' ; //#RQ-001260 Adding Maersk user Id             
            insert SEASystemAdminUser; 
            
            //#PR-0047 MCC Brand Integration
            MCCSystemAdminUser =  new User();                 
            MCCSystemAdminUser.FirstName = 'Demo';                 
            MCCSystemAdminUser.LastName = 'Sdfweef';                 
            MCCSystemAdminUser.Username = 'Ssdfsgd3212te2r@ust-global.com';                 
            MCCSystemAdminUser.Email = 'Sgfh12e6sse2r' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MCCSystemAdminUser.Alias = 'suser';                 
            MCCSystemAdminUser.CommunityNickname = 'sya42';                 
            MCCSystemAdminUser.TimeZoneSidKey = 'Europe/London';                 
            MCCSystemAdminUser.LocaleSidKey = 'en_GB';                 
            MCCSystemAdminUser.EmailEncodingKey = 'ISO-8859-1';                 
            MCCSystemAdminUser.ProfileId = systemAdminProfileId; 
            MCCSystemAdminUser.Country = recGeo.Name;               
            MCCSystemAdminUser.Cluster__c = testBDA.Name;
            MCCSystemAdminUser.LanguageLocaleKey = 'en_US';      
            MCCSystemAdminUser.Liner_Brand__c = BrandUtilities.MCC;      // MCC ; System Admin   
            MCCSystemAdminUser.Maersk_User_Id__c  =  'M00000' ; //#RQ-001260 Adding Maersk user Id              
            insert MCCSystemAdminUser;           
            
            //#RQ-002301
            MLLSystemAdminUser =  new User();                 
            MLLSystemAdminUser.FirstName = 'hdfdr4';                 
            MLLSystemAdminUser.LastName = 'System User';                 
            MLLSystemAdminUser.Username = 'SayMLLAdmin@ust-global.com';                 
            MLLSystemAdminUser.Email = 'SayMLLAdmin' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MLLSystemAdminUser.Alias = 'suAdjser';                 
            MLLSystemAdminUser.CommunityNickname = 'syMlly';                 
            MLLSystemAdminUser.TimeZoneSidKey = 'Europe/London';                 
            MLLSystemAdminUser.LocaleSidKey = 'en_GB';                 
            MLLSystemAdminUser.EmailEncodingKey = 'ISO-8859-1';                 
            MLLSystemAdminUser.ProfileId = systemAdminProfileId;
            MLLSystemAdminUser.Country = recGeo.Name;
            MLLSystemAdminUser.Cluster__c = testBDA.Name;
            MLLSystemAdminUser.LanguageLocaleKey = 'en_US';
            MLLSystemAdminUser.MLL__c = true;    
            MLLSystemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // MLL ; System Admin   
            MLLSystemAdminUser.Maersk_User_Id__c  =  'SYS00102' ;            
            insert MLLSystemAdminUser;
            
            //#PR-0055 Seago Brand Integration
            SeagoSystemAdminUser= new User();                 
            SeagoSystemAdminUser.FirstName='Demo';                 
            SeagoSystemAdminUser.LastName='Sdfweef';                 
            SeagoSystemAdminUser.Username='Seagogd3212te2r@ust-global.com';                 
            SeagoSystemAdminUser.Email='Sgfh12e6sse2r' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SeagoSystemAdminUser.Alias='suser';                 
            SeagoSystemAdminUser.CommunityNickname='sgl42';                 
            SeagoSystemAdminUser.TimeZoneSidKey='Europe/London';                 
            SeagoSystemAdminUser.LocaleSidKey='en_GB';                 
            SeagoSystemAdminUser.EmailEncodingKey='ISO-8859-1';                 
            SeagoSystemAdminUser.ProfileId=systemAdminProfileId; 
            SeagoSystemAdminUser.Country = recGeo.Name;               
            SeagoSystemAdminUser.Cluster__c=testBDA.Name;
            SeagoSystemAdminUser.LanguageLocaleKey='en_US';      
            SeagoSystemAdminUser.Liner_Brand__c = BrandUtilities.SEAGO;      // Seago ; System Admin   
            SeagoSystemAdminUser.Maersk_User_Id__c = 'SGL000' ;             
            //insert SeagoSystemAdminUser;  
            
            User tenderMSLUser = [SELECT Id From User WHERE Maersk_User_Id__c = 'SYS102' LIMIT 1 ];
            
            List<PermissionSet> permissionSet = [SELECT id, Name FROM PermissionSet where Name = 'Tender_Opportunity_Access' limit 1];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = tenderMSLUser.id;
            psa.PermissionSetId = permissionSet[0].id;
            insert psa;
        }
    } 
    
    public static void initializeSalesUser() {
        
        List<User> userList = new List<User> ();
        Id salesProfileId = Label.TestClean_ProfileIdsSales;        
        Geography__c recGeo;
        BDA__C testBDA = new BDA__C ();
        testBDA.Name = 'Central America, Andina, Caribbean';
        testBDA.Type__c = 'Cluster';
        testBDA.BDA_Code__c = 'dsaewet';
        //#RQ-004639         Added new field GEO_id__c field 
        testBDA.GEO_ID__c= 'dsaewet';
        testBDA.Active__c  =  true;
        insert testBDA;
        
        //#RQ-004759
        recGeo = new Geography__c(
                        Name = 'TESTCOUNTRY',
                        Active__c =true,
                        GEO_Code__c = 'IN',
                        GEO_ID__c = '10Z2W9Zkjh3q4ab5',
                        Is_Port__c = false,
                        Type_Of_Location__c = 'Country');
        Database.insert(recGeo);
        
        System.runAs(new User(Id = UserInfo.getUserId()))
        {        
            salesUser =  new User();                 
            salesUser.FirstName = 'sdff3wr';                 
            salesUser.LastName = 'Sales User';                 
            salesUser.Username = 'Saleasd23rer@ust-global.com';                 
            salesUser.Email = 'Salads85saer' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            salesUser.Alias = 'suser';                 
            salesUser.CommunityNickname = 'sl1';                 
            salesUser.TimeZoneSidKey = 'Europe/London';                 
            salesUser.LocaleSidKey = 'en_GB';                 
            salesUser.EmailEncodingKey = 'ISO-8859-1';                 
            salesUser.ProfileId = salesProfileId; // salesProfile.id;                 
            salesUser.Cluster__c = testBDA.Name;
            salesUser.Country = recGeo.Name;
            //salesUser.Quoting_Tool__c = 'AFLS;Quote Builder';       //#RQ-004643            
            salesUser.LanguageLocaleKey = 'en_US';      
            salesUser.Liner_Brand__c = BrandUtilities.SEAGO;  // Dual Brand ; Sales Admin 
            salesUser.Maersk_User_Id__c  =  'SAL001' ; //#RQ-001260 Adding Maersk user Id     
            salesUser.CM_Visibility__c = 'Single Carrier';         
            userList.add(salesUser);    
            
            MSLsalesUser =  new User();                 
            MSLsalesUser.FirstName = 'sdfewrtfo';                 
            MSLsalesUser.LastName = 'Sales User';                 
            MSLsalesUser.Username = 'Sasjhv23@ust-global.com';                 
            MSLsalesUser.Email = 'Sajkb21w3r' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MSLsalesUser.Alias = 'suser';                 
            MSLsalesUser.CommunityNickname = 'sl2';                 
            MSLsalesUser.TimeZoneSidKey = 'Europe/London';                 
            MSLsalesUser.LocaleSidKey = 'en_GB';                 
            MSLsalesUser.EmailEncodingKey = 'ISO-8859-1';                 
            MSLsalesUser.ProfileId = salesProfileId; //salesProfile.id;
            MSLsalesUser.Country = recGeo.Name;                 
            MSLsalesUser.Cluster__c = testBDA.Name;
            //MSLsalesUser.Quoting_Tool__c = 'Quote Builder';     //#RQ-004643            
            MSLsalesUser.LanguageLocaleKey = 'en_US';       
            MSLsalesUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // Maersk Line ; Sales Admin          
            MSLsalesUser.Maersk_User_Id__c  =  'SAL002' ; //#RQ-001260 Adding Maersk user Id             
            MSLsalesUser.CM_Visibility__c = 'Single Carrier';  
            userList.add(MSLsalesUser);
            
            SCLsalesUser =  new User();                 
            SCLsalesUser.FirstName = 'weq43243';                 
            SCLsalesUser.LastName = 'Sales User';                 
            SCLsalesUser.Username = 'sas2safszrs@ust-global.com';                 
            SCLsalesUser.Email = 'sad211hjhr' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SCLsalesUser.Alias = 'suser'; 
            SCLsalesUser.IsActive = true;//#PR-0055                
            SCLsalesUser.CommunityNickname = 'sl3';                 
            SCLsalesUser.TimeZoneSidKey = 'Europe/London';                 
            SCLsalesUser.LocaleSidKey = 'en_GB';                 
            SCLsalesUser.EmailEncodingKey = 'ISO-8859-1';                 
            SCLsalesUser.ProfileId = salesProfileId; //salesProfile.id;   
            SCLsalesUser.Country = recGeo.Name;              
            SCLsalesUser.Cluster__c = testBDA.Name;
            //SCLsalesUser.Quoting_Tool__c = 'Quote Builder';       //#RQ-004643          
            SCLsalesUser.LanguageLocaleKey = 'en_US';      
            SCLsalesUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // Safmarine ; Sales Admin  
            SCLsalesUser.Maersk_User_Id__c  =  'SAL003' ; //#RQ-001260 Adding Maersk user Id  
            SCLsalesUser.CM_Visibility__c = 'Single Carrier';            
            userList.add( SCLsalesUser );  
            
            
            //#RQ-000803 Addeded the beow user creation            
            SEAsalesUser =  new User();                 
            SEAsalesUser.FirstName = 'weq43243';                 
            SEAsalesUser.LastName = 'Sales User';                 
            SEAsalesUser.Username = 'sas2safszr@ust-global.com';                 
            SEAsalesUser.Email = 'sad211hjhr' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SEAsalesUser.Alias = 'suser';                 
            SEAsalesUser.CommunityNickname = 'sl4';                 
            SEAsalesUser.TimeZoneSidKey = 'Europe/London';                 
            SEAsalesUser.LocaleSidKey = 'en_GB';                 
            SEAsalesUser.EmailEncodingKey = 'ISO-8859-1';                 
            SEAsalesUser.ProfileId = salesProfileId; //salesProfile.id;                 
            SEAsalesUser.Cluster__c = testBDA.Name;
            SEAsalesUser.Country = recGeo.Name;
            //SEAsalesUser.Quoting_Tool__c = 'Quote Builder';     //#RQ-004643           
            SEAsalesUser.LanguageLocaleKey = 'en_US';      
            SEAsalesUser.Liner_Brand__c = BrandUtilities.SEALAND;      // Safmarine ; Sales Admin    
            SEAsalesUser.Maersk_User_Id__c  =  'SAL004' ; //#RQ-001260 Adding Maersk user Id
            SEAsalesUser.CM_Visibility__c = 'Single Carrier'; 
            userList.add( SEAsalesUser); 
            //List <User> userList  =  new List <User>{salesUser,MSLsalesUser,SCLsalesUser};
            //insert userList;        
            
            //#PR-0047 MCC brand Integration
            MCCsalesUser =  new User();                 
            MCCsalesUser.FirstName = 'weq43243';                 
            MCCsalesUser.LastName = 'Sales User';                 
            MCCsalesUser.Username = 'sas2safszr2@ust-global.com';                 
            MCCsalesUser.Email = 'sad211hjhr2' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MCCsalesUser.Alias = 'suser';                 
            MCCsalesUser.CommunityNickname = 'sl44';                 
            MCCsalesUser.TimeZoneSidKey = 'Europe/London';                 
            MCCsalesUser.LocaleSidKey = 'en_GB';                 
            MCCsalesUser.EmailEncodingKey = 'ISO-8859-1';                 
            MCCsalesUser.ProfileId = salesProfileId; //salesProfile.id;                 
            MCCsalesUser.Cluster__c = testBDA.Name;
            MCCsalesUser.Country = recGeo.Name;
            //MCCsalesUser.Quoting_Tool__c = 'Quote Builder'; //#RQ-004643               
            MCCsalesUser.LanguageLocaleKey = 'en_US';      
            MCCsalesUser.Liner_Brand__c = BrandUtilities.MCC;      // MCC ; Sales Admin   
            MCCsalesUser.Maersk_User_Id__c = 'S00005'; //#RQ-001260 Adding Maersk user Id      
            MCCsalesUser.CM_Visibility__c = 'Single Carrier'; 
            userList.add( MCCsalesUser);
            
            //#PR-0047 MCC brand Integration
            MCCsalesUser =  new User();                 
            MCCsalesUser.FirstName = 'weq43243';                 
            MCCsalesUser.LastName = 'Sales User';                 
            MCCsalesUser.Username = 'sasMcc34dd@ust-global.com';                 
            MCCsalesUser.Email = 'sad211hjhr2' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MCCsalesUser.Alias = 'suser';                 
            MCCsalesUser.CommunityNickname = 'sg5l44';                 
            MCCsalesUser.TimeZoneSidKey = 'Europe/London';                 
            MCCsalesUser.LocaleSidKey = 'en_GB';                 
            MCCsalesUser.EmailEncodingKey = 'ISO-8859-1';                 
            MCCsalesUser.ProfileId = salesProfileId; //salesProfile.id;                 
            MCCsalesUser.Cluster__c = testBDA.Name;
            MCCsalesUser.Country = recGeo.Name;
            //MCCsalesUser.Quoting_Tool__c = 'Quote Builder';            //#RQ-004643     
            MCCsalesUser.LanguageLocaleKey = 'en_US';      
            MCCsalesUser.Liner_Brand__c = BrandUtilities.MCC;      // MCC ; Sales Admin   
            MCCsalesUser.Maersk_User_Id__c = 'L00005'; //#RQ-001260 Adding Maersk user Id   
            MCCsalesUser.CM_Visibility__c = 'Single Carrier'; 
            userList.add( MCCsalesUser);
            
            //#PR-0054 : MLL Sales User
            MLLSalesUser =  new User();                 
            MLLSalesUser.FirstName = 'testMll';                 
            MLLSalesUser.LastName = 'Salesusr21';                 
            MLLSalesUser.Username = 'teestfMll43@ust-global.com';                 
            MLLSalesUser.Email = 'testMdll43' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MLLSalesUser.Alias = 'ml3zdfw';                 
            MLLSalesUser.CommunityNickname = 'mlsdqw';                 
            MLLSalesUser.TimeZoneSidKey = 'Europe/London';                 
            MLLSalesUser.LocaleSidKey = 'en_GB';                 
            MLLSalesUser.EmailEncodingKey = 'ISO-8859-1';                 
            MLLSalesUser.ProfileId = salesProfileId; //salesProfile.id;                 
            MLLSalesUser.Cluster__c = testBDA.Name;
            MLLSalesUser.Country = recGeo.Name;
            //MLLSalesUser.Quoting_Tool__c = 'Quote Builder';       //#RQ-004643          
            MLLSalesUser.LanguageLocaleKey = 'en_US';      
            MLLSalesUser.Liner_Brand__c = BrandUtilities.MAERSKLINE; 
            MLLSalesUser.Maersk_User_Id__c = 'K00000';   
            MLLSalesUser.MLL__c = true;  
            MLLSalesUser.CM_Visibility__c = 'Single Carrier';         
            userList.add( MLLSalesUser);
            
             //#PR-0055 : Seago Sales User
            SeagosalesUser= new User();                 
            SeagosalesUser.FirstName='TestSeago';                 
            SeagosalesUser.LastName='Sales User';                 
            SeagosalesUser.Username='sas2saf4556@ust-global.com';                 
            SeagosalesUser.Email='sad211hjhr' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SeagosalesUser.Alias='suser';                 
            SeagosalesUser.CommunityNickname='sgll3';                 
            SeagosalesUser.TimeZoneSidKey='Europe/London';                 
            SeagosalesUser.LocaleSidKey='en_GB';                 
            SeagosalesUser.EmailEncodingKey='ISO-8859-1';  
            SeagosalesUser.Country = recGeo.Name;               
            SeagosalesUser.ProfileId = salesProfileId; //salesProfile.id;                 
            SeagosalesUser.Cluster__c=testBDA.Name;
            //SeagosalesUser.Quoting_Tool__c='Quote Builder';    //#RQ-004643             
            SeagosalesUser.LanguageLocaleKey='en_US';      
            SeagosalesUser.Liner_Brand__c = BrandUtilities.SEAGO;      // Seago ; Sales Admin  
            SeagosalesUser.Maersk_User_Id__c = 'SGL003' ;  
            SeagosalesUser.CM_Visibility__c = 'Single Carrier';          
            userList.add( SeagosalesUser);
            insert userList;
        }
    }
    
    
    //#RQ-002247 : Start
    //Create Customer Service Users
    public static void initializeCustomerServiceUser()
    {
        List<User>customerServiceUserList = new List<User>();
        Id customerServiceProfileId = Label.TestClean_ProfileIdCustomerServiceUser;
        Geography__c recGeo;
        BDA__c testBDA=new BDA__c();
        testBDA.Name = 'Centre Function'; //'France Area';
        testBDA.Type__c='Cluster';
        testBDA.BDA_Code__c='zx22d5d3';
        //#RQ-004639         Added new field GEO_id__c field 
        testBDA.GEO_id__c='zx22d5d3';
        testBDA.Active__c = true;
        insert testBDA;
        
        //#RQ-004759
        recGeo = new Geography__c(
            Name = 'TESTCOUNTRY',
            Active__c =true,
            GEO_Code__c = 'IN',
            GEO_ID__c = '10Z2W9Zkjh3q4ab6',
            Is_Port__c = false,
            Type_Of_Location__c = 'Country');
        
        Database.insert(recGeo);
        
        System.runAs(new User(Id = UserInfo.getUserId()))
        {        
            MSLCustomerServiceUser = new User();                 
            MSLCustomerServiceUser.FirstName = 'sdff3wr';                 
            MSLCustomerServiceUser.LastName = 'Customer Service User';                 
            MSLCustomerServiceUser.Username = 'CustomerServiceUser2015@ust-global.com';                 
            MSLCustomerServiceUser.Email = 'CustomerServiceUser2015' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MSLCustomerServiceUser.Alias = 'suser';                 
            MSLCustomerServiceUser.CommunityNickname = 'ML45';                 
            MSLCustomerServiceUser.TimeZoneSidKey = 'Europe/London';                 
            MSLCustomerServiceUser.LocaleSidKey = 'en_GB';                 
            MSLCustomerServiceUser.EmailEncodingKey = 'ISO-8859-1';                 
            MSLCustomerServiceUser.ProfileId = customerServiceProfileId;
            MSLCustomerServiceUser.Country = recGeo.Name;                
            MSLCustomerServiceUser.Cluster__c = testBDA.Name;
            //MSLCustomerServiceUser.Quoting_Tool__c = 'AFLS;Quote Builder';    //#RQ-004643               
            MSLCustomerServiceUser.LanguageLocaleKey = 'en_US';      
            MSLCustomerServiceUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;  // Dual Brand ; Sales Admin 
            MSLCustomerServiceUser.Maersk_User_Id__c  =  'CSA020' ; //#RQ-001260 Adding Maersk user Id             
            MSLCustomerServiceUser.USERPERMISSIONSSUPPORTUSER  =  TRUE; 
            MSLCustomerServiceUser.Receive_Case_Ownership_Change__c =TRUE;//#RQ-008547  
            MSLCustomerServiceUser.CM_Visibility__c = 'Single Carrier';             
            customerServiceUserList.add(MSLCustomerServiceUser);    
            
            MLLCustomerServiceUser =  new User();                 
            MLLCustomerServiceUser.FirstName = 'MLL';                 
            MLLCustomerServiceUser.LastName = 'Customer Service User';                 
            MLLCustomerServiceUser.Username = 'testUserForMLL@ust-global.com';                 
            MLLCustomerServiceUser.Email = 'testUserForMLL' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MLLCustomerServiceUser.Alias = 'sleer';                 
            MLLCustomerServiceUser.CommunityNickname = 'ML46';                 
            MLLCustomerServiceUser.TimeZoneSidKey = 'Europe/London';                 
            MLLCustomerServiceUser.LocaleSidKey = 'en_GB';                 
            MLLCustomerServiceUser.EmailEncodingKey = 'ISO-8859-1';                 
            MLLCustomerServiceUser.ProfileId = customerServiceProfileId;
            MLLCustomerServiceUser.Country = recGeo.Name;                  
            MLLCustomerServiceUser.Cluster__c = testBDA.Name;
            //MLLCustomerServiceUser.Quoting_Tool__c = 'Quote Builder';    //#RQ-004643             
            MLLCustomerServiceUser.LanguageLocaleKey = 'en_US';       
            MLLCustomerServiceUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;          
            MLLCustomerServiceUser.Maersk_User_Id__c  =  'CSA021' ;           
            MLLCustomerServiceUser.MLL__c  =  True;
            MLLCustomerServiceUser.USERPERMISSIONSSUPPORTUSER  =  TRUE;
            MLLCustomerServiceUser.CM_Visibility__c = 'Single Carrier';
            customerServiceUserList.add(MLLCustomerServiceUser);
            
            SCLCustomerServiceUser =  new User();                 
            SCLCustomerServiceUser.FirstName = 'SCL Customer';                 
            SCLCustomerServiceUser.LastName = 'Service User';                 
            SCLCustomerServiceUser.Username = 'sclcustomerserviceuser1@ust-global.com';                 
            SCLCustomerServiceUser.Email = 'sclcustomerserviceuser1' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SCLCustomerServiceUser.Alias = 'sclk';                 
            SCLCustomerServiceUser.CommunityNickname = 'ML47';                 
            SCLCustomerServiceUser.TimeZoneSidKey = 'Europe/London';                 
            SCLCustomerServiceUser.LocaleSidKey = 'en_GB';                 
            SCLCustomerServiceUser.EmailEncodingKey = 'ISO-8859-1';                 
            SCLCustomerServiceUser.ProfileId = customerServiceProfileId; 
            SCLCustomerServiceUser.Country = recGeo.Name;                
            SCLCustomerServiceUser.Cluster__c = testBDA.Name;
            //SCLCustomerServiceUser.Quoting_Tool__c = 'Quote Builder';       //#RQ-004643          
            SCLCustomerServiceUser.LanguageLocaleKey = 'en_US';      
            SCLCustomerServiceUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;      // Safmarine ; Sales Admin  
            SCLCustomerServiceUser.Maersk_User_Id__c  =  'CSA022' ; //#RQ-001260 Adding Maersk user Id             
            SCLCustomerServiceUser.USERPERMISSIONSSUPPORTUSER  =  TRUE;
            SCLCustomerServiceUser.CM_Visibility__c = 'Single Carrier';
            customerServiceUserList.add(SCLCustomerServiceUser);  
            
            SEACustomerServiceUser =  new User();                 
            SEACustomerServiceUser.FirstName = 'weq43243';                 
            SEACustomerServiceUser.LastName = 'Sales User';                 
            SEACustomerServiceUser.Username = 'seacustomerserviceuser1@ust-global.com';                 
            SEACustomerServiceUser.Email = 'seacustomerserviceuser1' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            SEACustomerServiceUser.Alias = 'sead';                 
            SEACustomerServiceUser.CommunityNickname = 'ML48';                 
            SEACustomerServiceUser.TimeZoneSidKey = 'Europe/London';                 
            SEACustomerServiceUser.LocaleSidKey = 'en_GB';                 
            SEACustomerServiceUser.EmailEncodingKey = 'ISO-8859-1';                 
            SEACustomerServiceUser.ProfileId = customerServiceProfileId;                 
            SEACustomerServiceUser.Cluster__c = testBDA.Name;
            SEACustomerServiceUser.Country = recGeo.Name;
            //SEACustomerServiceUser.Quoting_Tool__c = 'Quote Builder';      //#RQ-004643           
            SEACustomerServiceUser.LanguageLocaleKey = 'en_US';      
            SEACustomerServiceUser.Liner_Brand__c = BrandUtilities.SEALAND;      // Safmarine ; Sales Admin    
            SEACustomerServiceUser.Maersk_User_Id__c  =  'CSA023' ; //#RQ-001260 Adding Maersk user Id             
            SEACustomerServiceUser.USERPERMISSIONSSUPPORTUSER = TRUE;
            SEACustomerServiceUser.CM_Visibility__c = 'Single Carrier';
            customerServiceUserList.add(SEACustomerServiceUser); 
            
            //#PR-0047 MCC brand Integration
            MCCCustomerServiceUser =  new User();                 
            MCCCustomerServiceUser.FirstName = 'weq43243';                 
            MCCCustomerServiceUser.LastName = 'Service User';                 
            MCCCustomerServiceUser.Username = 'mccCustomerServiceUser1@ust-global.com';                 
            MCCCustomerServiceUser.Email = 'mccCustomerServiceUser1' + Math.round(Math.random()*1000) + '@ust-global.com';                 
            MCCCustomerServiceUser.Alias = 'mcc987';                 
            MCCCustomerServiceUser.CommunityNickname = 'ML49';                 
            MCCCustomerServiceUser.TimeZoneSidKey = 'Europe/London';                 
            MCCCustomerServiceUser.LocaleSidKey = 'en_GB';                 
            MCCCustomerServiceUser.EmailEncodingKey = 'ISO-8859-1';                 
            MCCCustomerServiceUser.ProfileId = customerServiceProfileId;                 
            MCCCustomerServiceUser.Cluster__c = testBDA.Name;
            MCCCustomerServiceUser.Country = recGeo.Name;
            //MCCCustomerServiceUser.Quoting_Tool__c = 'Quote Builder';       //#RQ-004643          
            MCCCustomerServiceUser.LanguageLocaleKey = 'en_US';      
            MCCCustomerServiceUser.Liner_Brand__c = BrandUtilities.MCC;      // MCC ; Sales Admin 
            MCCCustomerServiceUser.USERPERMISSIONSSUPPORTUSER  =  TRUE;
            MCCCustomerServiceUser.CM_Visibility__c = 'Single Carrier';
            customerServiceUserList.add(MCCCustomerServiceUser);
            Database.Insert(customerServiceUserList );
        }
    } //#RQ-002247 : End 
    
    //Create Super User
    public static void initializeSuperUser()
	{
        Geography__c recGeo;

        BDA__C testBDA=new BDA__C ();
        testBDA.Name = 'Centre Function'; //'France Area';
        testBDA.Type__c='Cluster';
        testBDA.BDA_Code__c='dsaerre';
        //#RQ-004639         Added new field GEO_id__c field 
        testBDA.GEO_Id__c='dsaerre';
        testBDA.Active__c = true;
        insert testBDA;
        
         //#RQ-004759
        recGeo = new Geography__c(
                        Name = 'TESTCOUNTRY1',
                        Active__c =true,
                        GEO_Code__c = 'IN',
                        GEO_ID__c = '10Z2W9Zkjh3q4ab7',
                        Is_Port__c = false,
                        Type_Of_Location__c = 'Country');
                        Database.insert(recGeo);
        
        System.runAs(new User(Id = UserInfo.getUserId()))
        {         
            SuperUser =  new User();  
            SuperUser.LastName='testuser';
            SuperUser.Email='abclmjnhb@ust-global.com';
            SuperUser.Username='testusername' + Math.round(Math.random()*1000) + '@gg.play';
            SuperUser.CommunityNickname='testcomname';
            SuperUser.LanguageLocaleKey='en_US';
            SuperUser.LocaleSidKey='en_GB';
            SuperUser.timezonesidkey='Europe/London';
            SuperUser.emailencodingkey='ISO-8859-1';
            SuperUser.alias='tAls';
            SuperUser.Cluster__c = testBDA.Name;        
            SuperUser.Profileid=Label.Super_User_Profile_Id;//#RQ-000875
            SuperUser.Country = recGeo.Name;
            SuperUser.Manager=UserDataGeneratorHelper_Test.MSLSystemAdminUser;
            SuperUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            SuperUser.CM_Visibility__c = 'Single Carrier';
            //SuperUser.Quoting_Tool__c = 'AFLS';  //#RQ-004643
            insert SuperUser;
        }
    }
    
    public static void AddUserToGroup(Id UserId, Id GroupId) {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gMbr = new GroupMember();
            gMbr.UserorGroupId = UserId;
            gMbr.groupId = GroupId;
            insert gMbr;
       }
    }
}