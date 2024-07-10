/**
* Helper class for generating Test data for :
         
          - BDAs
                BDA__c createBDA(String Type, Id parentBDAId,Id userID)
                List<BDA__c> createBDA(String Type, Id parentBDAId,Id userID, integer count)
          - Task
                List<Task> createTasks (integer noOfTasks, Id WhatId)
          - Event
                List<Event> createEvents (integer noOfEvents, Id WhatId)
          - User Cluster
                User_Cluster__c createUserCluster(Id userId,Id clusterId)
          - Geography
                List<Geography__c> createGeography (Map<String,String> geoName_TypeOfLocation)
                
          - BDA Geography
                List<BDA_Geography__c> createBDAGeography (Map<Id,Id> bdaId_geoIdMap) 
          - Parent BDA

          -AFLS Quote
            List<Qt_Quote__c> createAFLSQuotes(Id OpptyID,Integer RecordCount)
    
         
          -Product2
            List <product2> products = new List <product2>();
             
          -PriceBook
            Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true)    

          -PriceBookEntry
            PricebookEntry customPrice1 = new PricebookEntry

          -OpportunityLineItem
            OpportunityLineItem Oli = New OpportunityLineItem();
            
            
 * Date         Owner                                        Ref Number   Description
**************************************************************************************************************************************
 * 26/11/2015   meghana.gupta@ust-global.com                 #RQ-002192   Code created for creating test data of different objects
 * 01/02/2016   Sunu.Paul@ust-global.com                     #RQ-002775   Included code for creating AFLS quote,quote lines,subscription and trade interests  
 * 09/02/2016   Sunu.Paul@ust-global.com                     #RQ-002978   Included code for creating Product2,PriceBook and PriceBookEntry.
 * 24/03/2016   Dinesh.Moorthy@ust-global.com                #RQ-002098   Decommission Customer Subscription management       
 * 10/10/2016   meghana.gupta@ust-global.com                 #RQ-004124   Remove Accout Actulas & Target related methods.
 *10/17/2017    ramadevi.palaniswamy@ust-global.com          #RQ-005073   Added the Requires_Review__c field and value to program module and new hire module object record
 *04/01/2018    Meenakshi.Rajasekaran@ust-global.com         #RQ-007596   Added a method that creates Unassigned Product   
 * 06/03/2018   Madhubharathi.Gopalakrishnan@ust-global.com  #RQ-007902   Deprecate all prior logic which relates to the Module Review Object                
* 08-Apr-2019  manjunath.c.holekade@maersk.com              #RQ-010441  Set scheduling related fields on Product2 insert related methods
* 29-Apr-2019  Junaid.Khader@ust-global.com                 #RQ-010156  Added Nominated_Quantity__c in the method createOpportunityLineItem
* 30-Apr-2019  Sidhartha Mohapatra                          #RQ-010374  Added Commiment__c field.
 * 11-Jul-2019  Junaid.Khader@ust-global.com                 #RQ-010654   Removed method createTarget() which creates deprecated object Target__c
* 05-Sep-2019  Junaid.Khader@ust-global.com                 #RQ-011734  Replaced assigning of Commitment__c field with custom label.
* 12-Dec-2019  manjunath@maersk                             #RQ-012233  Made changes related to User.Cluster__c
* 16-Dec-2019  manjunath@maersk                             #RQ-012366  Removal of references of deprecated Product fields
 * 14/04/2020   Amritesh@UST	          				     #RQ-013373   Fixed bad cluster value
 * 30/06/2020.  meghana@UST									 SFSE-2652    Change cluster name to a valid user cluster from Centre function
 * 08/06/2022   Ronnie@SF                                    SPI-100      Removed brand hardcoding
*/

 @isTest
public class DataGeneratorHelper1_Test{

    public static Qt_Quote__c testAFLSQuote;
   
    /**
    * Constructor
    **/    
    public DataGeneratorHelper1_Test() {       
    
    }
    
    static {
       
         // check if users are already initialized due to some other test data generator class being used in test class       
        if ( UserDataGeneratorHelper_Test.integrationUser == null ){
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        }
        
        if ( UserDataGeneratorHelper_Test.salesUser == null ){
            UserDataGeneratorHelper_Test.initializeSalesUser();
        }
        
    } 
    /** Create BDA records  **/
    public static BDA__c createBDA( String Type, Id parentBDAId, Id userID ){
        
        list<BDA__c> bdaList = createBDA( Type, parentBDAId, userId, 1 );
        BDA__c recBDA = bdaList.get(0);
        
        return recBDA;        
        
    }    
    
    public static List<BDA__c> createBDA( String Type, Id parentBDAId, Id userID, integer count ){
        
        list<BDA__c> BDAlist = new list<BDA__c>();
        
        for( Integer i=0; i < count; i++ ){  
        
            BDA__c recBDA = new BDA__c();
            //recBDA.Name = 'Scandinavia Area'; // Commenting this line and adding below line as part of SPI-74
            recBDA.Name = System.Label.EUR_Nordic_Area;
            recBDA.Type__c = Type;
            recBDA.GEO_ID__c = 'testing' + Type.left(4) + i; // to get this code as unique
            recBDA.BDA_Code__c =  Type.left(3) + i;
            recBDA.Active__c = true;
            if ( parentBDAId != null ){
                recBDA.Parent_BDA__c = parentBDAId;      
            }
            recBDA.Default_Account_Owner__c = userID;   
            //recBDA.SCL_Default_Account_Owner__c = UserDataGeneratorHelper_Test.SCLintegrationuser.id;   
            
            BDAlist.add( recBDA );
        }
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){ 
            insert BDAlist;
        }
        return BDAlist;        
    }    
    
    public static List<Task> createTasks ( integer noOfTasks, Id WhatId ){
        
        List<Task> tskList = new List<Task>();            
          
        for( Integer i=0; i < noOfTasks; i++ ){
            
            Task tsk = new Task();
            tsk.Subject = 'Test' + i;
            tsk.Status = 'Not Started';
            tsk.Priority = 'Normal';
            tsk.Sales_Rep_ID__c = UserDataGeneratorHelper_Test.salesUser.Maersk_User_Id__c;
            tsk.ScvCode__c = '11111000000';
            tsk.WhatID = WhatId;
            tsk.ActivityDate = date.today();
            tsk.Notify_Assignee__c = true;   
                
            tskList.add( tsk );
        }
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){ 
            insert tskList;
        }
        return tskList;
    }

    public static List<Event> createEvents ( integer noOfEvents, Id WhatId ){
        
        List<Event> eventList = new List<Event>();            
          
        for( Integer i=0; i < noOfEvents; i++ ){   
        
            Event recEvent = new Event();
            recEvent.Subject = 'Test' + i;
            recEvent.EndDateTime = System.now()+1;
            recEvent.StartDateTime = System.now();
            recEvent.OwnerId = UserDataGeneratorHelper_Test.salesUser.Id;          
            recEvent.WhatID = WhatId;
                           
            eventList.add( recEvent );
        }
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){ 
            insert eventList;
        }
        return eventList;
    }   
    
    public static User_Cluster__c createUserCluster( Id userId, Id clusterId ){
        
        User_Cluster__c uCluster = new User_Cluster__c();
        uCluster.User__c = userId;
        uCluster.BDA__c = clusterId; 
        System.runAs( UserDataGeneratorHelper_Test.integrationUser ){
            insert uCluster;
        }
        return uCluster;
    }
    
    
       /* Method to create a Geography of Type Country and isPort = True  */
    public static List<Geography__c> createGeographyPortTrue ( Map<String,String> geoName_TypeOfLocation ) {  
    
        List<Geography__c> geoList = new List<Geography__c> ();
        integer i = 0;

        for (String geoName : geoName_TypeOfLocation.keyset()){
            
            Geography__c recGeography = new Geography__c();
            recGeography.Name = geoName;
            recGeography.Active__c = true;
            recGeography.GEO_Code__c = 'IN'+i;
            recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a'+i;
            recGeography.Is_Port__c = true;
            recGeography.Type_Of_Location__c = geoName_TypeOfLocation.get(geoName); //Country / City / State / terminal...
            i=i+1;
            geoList.add(recGeography);
        }
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){       
            insert geoList;  
        }        
        return geoList ;        
    }
    
    
      /* Method to create a Geography of Type Country  */
    public static List<Geography__c> createGeography ( Map<String,String> geoName_TypeOfLocation ) {  
    
        List<Geography__c> geoList = new List<Geography__c> ();
        integer i = 0;

        for (String geoName : geoName_TypeOfLocation.keyset()){
            
            Geography__c recGeography = new Geography__c();
            recGeography.Name = geoName;
            recGeography.Active__c = true;
            recGeography.GEO_Code__c = 'IN'+i;
            recGeography.GEO_ID__c = '10Z2W9Zkjh3q4a'+i;
            recGeography.Is_Port__c = false;
            recGeography.Type_Of_Location__c = geoName_TypeOfLocation.get(geoName); //Country / City / State / terminal...
            i=i+1;
            geoList.add(recGeography);
        }
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){       
            insert geoList;  
        }        
        return geoList ;        
    }
    
    /**
    * Method to create a BDA record
    **/
    public static List<BDA_Geography__c> createBDAGeography ( Map<Id,Id> bdaId_geoIdMap ) { 
    
        List<BDA_Geography__c> bdaGeoList = new List<BDA_Geography__c>();
        
        for(Id bdaId : bdaId_geoIdMap.keyset()){
            
            BDA_Geography__c bdaGeography = new BDA_Geography__c();  
            bdaGeography.BDA__c = bdaId;
            bdaGeography.Geography__c = bdaId_geoIdMap.get(bdaId);
            bdaGeoList.add( bdaGeography );
        }
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
            insert bdaGeoList;
        }
        return bdaGeoList;        
    }
    
    /** Create BDA records  **/
    public static Parent_BDA__c createParentBDA( Id parentBDAId, Id childBDAId, String Link_ID ){
        
        Parent_BDA__c recpBDA = new Parent_BDA__c();
        recpBDA.Child_BDA__c = childBDAId;
        recpBDA.Parent_BDA__c = parentBDAId;
        recpBDA.Link_ID__c = Link_ID;  
        
        System.runAs( UserDataGeneratorHelper_Test.integrationUser ){ 
            insert recpBDA;
        }
        return recpBDA;
    }   

    // insert custom setting 
    public static void addTeamRolesCannotDeleted ( String csName, String ManagerRoles ){
        
        Team_Roles_Cannot_Deleted__c customSettingVal = new Team_Roles_Cannot_Deleted__c();
        customSettingVal.Name = csName;
        customSettingVal.Manager_Roles__c = ManagerRoles;
        insert customSettingVal; 
    }
    
    /* 
    * Create Test AFLSQuotes
    */
    public static List<Qt_Quote__c> createAFLSQuotes( Id OpptyID, Integer RecordCount ) {    
        
         //inserting AFLS Quote 1        
        List<Qt_Quote__c> qtList = new List<Qt_Quote__c>(); 
        Opportunity opp = [ Select Id,Opportunity_Ref__c from Opportunity Where Id = :OpptyID ];    
        
        for( Integer i = 0; i < RecordCount; i++ ) {
        
            testAFLSQuote = new Qt_Quote__c();                        
            testAFLSQuote.Name = 'test Quote';
            testAFLSQuote.Qt_Customer_Code__c = '11223344';
            testAFLSQuote.Qt_External_Id__c = opp.Opportunity_Ref__c ;
            testAFLSQuote.Qt_Created_By__C = 'SNA140';
            testAFLSQuote.Qt_Carrier__c = BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE); 
            testAFLSQuote.Opportunity__c = OpptyID; 
            
            qtList.add( testAFLSQuote );
        }               
        insert qtList;
        return qtList;
    }
    
    /** Create New_Hire_Module__c record  **/
    public static New_Hire_Module__c createNewHireModule( String BadgeName ){
        
        New_Hire_Module__c recModule = new New_Hire_Module__c();
        recModule.name = 'test nhm';
        recModule.status__c = 'Not Started';
        recModule.Order__c = 1;    
        recModule.Onboarding_Plan__c = EnrollmentWizard_Test.onbPlan.id;
        recModule.Duration__c = 2  ;  
        //recModule.Requires_Review__c=TRUE;  
        recModule.Category__c = 'Our Company';
        recModule.Badge_Name__c = BadgeName;        
        insert recModule;
        return recModule;        
    }   
    
    public static New_Hire_Assignments__c createNewHireModule( Id NewHireModuleId ){
        
        New_Hire_Assignments__c recAssgmt = new New_Hire_Assignments__c();
        recAssgmt.New_Hire_Module__c = NewHireModuleId;
        recAssgmt.Status__c = 'Not Started';
        insert recAssgmt;
        return recAssgmt;      
    }
    
    public static Module__c createModule( ){
        
        Module__c recModule = new Module__c();
        recModule.name = 'Employee Engagement Survey';
        recModule.status__c = 'Draft';
        recModule.Order__c = 56;
        recModule.Duration__c = 5;
        recModule.Category__c = 'Our Company';
        recModule.Badge_Name__c = 'Test Badge';
        recModule.Badge_URL__c = '/resource/1415601834000/ONB_Badge_1';
       
        insert recModule;
        return recModule;      
    }   
    
    public static Module_Assignment__c createModuleAssignment( Id ModuleId ){
        
        Module_Assignment__c recAssgmt = new Module_Assignment__c();
        recAssgmt.name = 'Employee Engagement assignment';
        recAssgmt.Module__c = ModuleId;
        recAssgmt.Order__c = 13;

        insert recAssgmt;                  
        return recAssgmt;      
    }  
    
    public static Assignmen_Content__c createAssignmentContent ( Id ModuleAssginmentId ){
        
        Assignmen_Content__c recContent = new Assignmen_Content__c();
        recContent.name = 'Test Content';
        recContent.Link_To_Document__c = 'https://www.office.com';
        recContent.Module_Assignment__c = ModuleAssginmentId;
        recContent.Description__c = 'Content for the assignment';

        insert recContent;
        return recContent;
    }
    
    public static void updateModuleStatus ( Module__c recModule, String status ){
        
        recModule.Status__c = status;               
        update recModule;
        
    }
    
    public static void updateProgramStatus ( Onboarding_Program__c recProgram, String status ){
        
        recProgram.Status__c = status;               
        update recProgram;
    }
    
    public static Onboarding_Program__c createOnboardingProgram ( ){
        
        Onboarding_Program__c recProgram = new Onboarding_Program__c();
        recProgram.name = 'Onboarding Program for new hire';
        recProgram.Brand__c = BrandUtilities.MAERSKLINE;
        recProgram.Department__c = 'IT';
        recProgram.Role__c = 'Solution architect';
        recProgram.Source__c = 'internal Hire';
        recProgram.Status__c = 'Draft';
        
        insert recProgram;
        return recProgram;
    }
    
    public static Program_Module__c createOnboardingProgramModule ( Id OnboardingProgramId, Id ModuleId ){
        
        Program_Module__c recProgModule = new Program_Module__c();
        recProgModule.Duration__c = 3;
        //recProgModule.Requires_Review__c=TRUE;
        recProgModule.Module__c = ModuleId;
        recProgModule.Onboarding_Program__c = OnboardingProgramId;

        insert recProgModule;
        return recProgModule;
    }
    
     public static CollaborationGroup  createGroup(){
    
        CollaborationGroup cGrp = new CollaborationGroup();
        cGrp.name = 'TestClean_Group';
        cGrp.CollaborationType = 'Public';
        insert cGrp;
        return cGrp;
    }
    
    public static List<Onboarding_Plan__c> createOnboardingPlans ( Integer count, String GroupId ){
        
        List<Onboarding_Plan__c> lstOnbPlans = new  List<Onboarding_Plan__c>();
        Onboarding_Plan__c recPlan;
        
        String ChatterURL = '?g='+ GroupId ;
        
        for ( integer i = 0; i < count; i++){
            
            recPlan = new Onboarding_Plan__c();
            recPlan.name = 'Test Onboarding Plan' + i;
            recPlan.Buddy__c = UserDataGeneratorHelper_Test.MSLSalesUser.id;
            recPlan.Coordinator__c = Userinfo.getUserId();
            recPlan.New_Hire__c = UserDataGeneratorHelper_Test.SCLSalesUser.id;
            recPlan.Onboarder__c = UserDataGeneratorHelper_Test.SalesUser.id;
            recPlan.Start_Date__c = Date.today();
            recPlan.Status__c = 'Ready';
            recPlan.Chatter_Group_URL__c = ChatterURL;
            
            lstOnbPlans.add(recPlan);
        }
        insert lstOnbPlans;
        return lstOnbPlans;
    }
    
    public static void updatePlanStatus ( Onboarding_Plan__c recPlan, String status ){
        
        recPlan.Enrolled_Or_Onboarded__c = 1; 
        recPlan.Status__c = status;               
        update recPlan;
    }
    //Create Product
    public static List<Product2> createProduct2(Integer count,String PrdtCode,String Dirn,String Family){
        
        List <product2> products = new List <product2>();
        for(integer i=0;i<count;i++)
        {
            product2 testP = new product2();
            testp.name = 'test'+String.valueOf(i);
            testp.ProductCode = PrdtCode+String.valueOf(i);
            testp.Direction__c = Dirn+String.valueOf(i);
            testp.family  = Family ;
            testp.description = 'Atlantic North'+String.valueOf(i);
            testp.Route_Direction_Code__c = testp.ProductCode+testp.Direction__c;
            testp.CanUseRevenueSchedule = true;
            testp.CanUseQuantitySchedule = true;
            testp.IsActive = true;
            testp.OIPC_Code__c = 'P-P0-wet';
            testp.Include_in_OMEB_Approvals__c = true;
            products.add(testp);
        }
        insert products;
        return products;
    }
    
    //create unassigned product
      public static List<Product2> createUnassignedProduct2(Integer count1,String Family1){
        
        List <product2> products1 = new List <product2>();
        for(integer i=0;i<count1;i++)
        {
            product2 testP1 = new product2();
            testp1.name = 'Unassigned';
            testp1.ProductCode = 'Un';
            testp1.Direction__c = 'assigned';
            testp1.family  = Family1 ;
            testp1.description = 'Atlantic North'+String.valueOf(i);
            testp1.Route_Direction_Code__c = testp1.ProductCode+testp1.Direction__c;
         //   testp1.CanUseRevenueSchedule = true;
            testp1.CanUseQuantitySchedule = true;
            testp1.IsActive = true;
            products1.add(testp1);
        }
        insert products1;
        return products1;
    }
    //Create Product
    public static List<Product2> createProduct2WithEquipsAndCommodities(Integer count,String PrdtCode,String Dirn,String Family){
        
        List <product2> products = new List <product2>();
        for(integer i=0;i<count;i++)
        {
            product2 testP = new product2();
            testp.name = 'test'+String.valueOf(i);
            testp.ProductCode = PrdtCode+String.valueOf(i);
            testp.Direction__c = Dirn+String.valueOf(i);
            testp.family  = Family ;
            testp.description = 'Atlantic North'+String.valueOf(i);
            testp.Route_Direction_Code__c = testp.ProductCode+testp.Direction__c;
          //  testp.CanUseRevenueSchedule = true;
            testp.CanUseQuantitySchedule = true;            
            products.add(testp);
        }
        system.debug('@@@@' + UserInfo.getProfileId());                                                                    
        insert products;
        return products;
    } 
    
    // Create Opportunity Line Item
    public static OpportunityLineItem createOpportunityLineItem(Id OpptyId,Id PriceBookEntryId){
        return createOpportunityLineItemWithTrade(OpptyId, PriceBookEntryId, null, null);
    }    
    
     // Create Opportunity Line Item with executing country
    public static OpportunityLineItem createOpportunityLineItemWithCountry(Id OpptyId, Id PriceBookEntryId, Id countryId){
        return createOpportunityLineItemWithTrade(OpptyId, PriceBookEntryId, countryId, null);
        
    }

    public static OpportunityLineItem createOpportunityLineItemWithTrade(Id OpptyId, Id PriceBookEntryId, Id countryId, Id tradeRouteId){
         if (tradeRouteId == null ){
            List<Trade_Route__c> lstTradeRoute = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MCC');
            insert lstTradeRoute;
            tradeRouteId = lstTradeRoute[0].Id;
        }

        OpportunityLineItem Oli = New OpportunityLineItem();
        Oli.OpportunityId = OpptyId;
        Oli.Quantity = 1;
        Oli.PriceBookEntryId = PriceBookEntryId;
        Oli.UnitPrice = 1;
        oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
        Oli.Tender_Target__c = 1;
        oli.Nominated_Quantity__c = 1;
        oli.Country__c = countryId;
        oli.Trade_Route__c = tradeRouteId;
        insert oli;
        return Oli;
    }        
    
    // Create Opportunity Line Item
    public static list<OpportunityLineItem> createOpportunityLineItems ( List<Opportunity> OpptyList, Id PriceBookEntryId ){
        
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        
        for ( Opportunity oppty : OpptyList ){
            
            OpportunityLineItem Oli = New OpportunityLineItem();
            Oli.OpportunityId = Oppty.Id;
            Oli.Quantity = 35;
            oli.Opt_Out_Auto_Quantity_Scheduling__c = false;
            Oli.PriceBookEntryId = PriceBookEntryId;
            Oli.UnitPrice = 1;
            
            oliList.add( oli );
        }
        insert oliList;
        return oliList;
    }
    //Add attachment
    public static Attachment addAttachment ( Id ParentId, String contentType ){
        List <Attachment> attach = DataGeneratorHelper2_Test.addAttachment (1,ParentId,contentType);
        return attach[0];
    }
    
    public static Product2 createProduct (){
        
        Product2 dir = new Product2();
        dir.name = 'dir';
        dir.direction__c = 'E';
        dir.Service_Name__c = 'Europe - Far East';
        dir.Route_Direction_Code__c = 'E';
        dir.Description = 'Australia - Europe/Middle East';
     //   dir.CanUseRevenueSchedule = true;
        dir.CanUseQuantitySchedule = true;      
        insert dir;
        return dir;
    }
    
     //Create Standard PriceBookEntry
    public static PriceBookEntry createStdPriceBookEntry(Id Stdprcbk,Product2 pdt){
        PricebookEntry customPrice1 = new PricebookEntry(
            Pricebook2Id = Stdprcbk, Product2Id = pdt.Id,
            UnitPrice = 1, IsActive = true);
        insert customPrice1;
        return customPrice1;
    }
}