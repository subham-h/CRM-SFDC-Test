/**
 * Helper class for generating Opportunity for all Liner Brands 
 * 
 * Date         Owner                                   Refn Number   Description
 **************************************************************************************************************************************
 * 17/02/2015   Deepa.Raman@ust-global.com              #RQ-000917    Move ALL test data generation to Helper classes.
 * 12/12/2015   Sunu.Paul@ust-global.com                #PR-0055      Created methods to create opportunities with return and also, for creating a 
 *                                                                    Close-Won opportunity 
 * 27/01/2016   Sunu.Paul@ust-global.com                #RQ-002775    Optimize code to use less methods
 * 31/03/2016   Madhava.kotte@ust-global.com            #RQ-002301    OpportunityTrigger Refactoring
 * 27/09/2016   Meghana.Gupta@ust-global.com                          Actuals-Redevevlopment project: Added method to create multiple oppties
 * 01/06/2017   ramadevi.palaniswamy@ust-global.com                   Added new method to create opportunity first and last shipment date indifferent quarter
 * 07/06/2017   sandhya.sambasivan@ust-global.com       #RQ-005190    Added data for validation rule
 * 14/12/2018   sidhartha mohapatra                                   Modified the code for SalesMetric_Test
 * 06/06/2019   manjunath.c.holekade@maersk.com         #RQ-010819    Removal of references of deprecated fields
 * 03/09/2019   manjunath.c.holekade@maersk.com         #RQ-011746    Removal of unused methods for improving the code coverage
 * 29/11/2019   manjunath@maersk                        #RQ-012233    Set "Opportunity_contains_Dangerous_Goods__c" value for all Opp'ty insertion
 * 29/05/2020   manjunath@maersk                        SFSE-94       Replaced 'OppTenderRecordTypeId' label with 'OppShippingCargoRecordType'
 * 08/09/2020   manjunath@maersk                        SFSE-4548     Test data fix related to new validation rule
 * 14/09/2020   Neha@tcs                                SFSE-170      Updated commodity value to new values 
 * 15/10/2020   meghana.gupta@ust                       SFSE-4767     Safmarine brand deprecated
 * 08/06/2022   Ronnie@SF                               SPI-100       Removed brand hardcoding
 * 02/01/2023   Aleena@Maersk                           SFSE-9813     Added one method to create Supply Chain Services record type opty
 * 01/02/2023   Aditi@Maersk                            SFSE-10220    Added Offer_Type__c field value
 */
   
public class OpportunityDataGeneratorHelper_Test {  

    /*** Constructor  **/    
    public OpportunityDataGeneratorHelper_Test () { 

    }   
    
    //Call method to create Test Users 
    static {
        
        // create method if users are created already by anyother test data generator class
        if (UserDataGeneratorHelper_Test.SystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser(); 
        }         
    } 
    
    /*** Method to create Opportunity  **/
    public static Opportunity createOpportunity( ID AccountID, ID primaryContactID, String lbrand, String Stage, User RunAsUser, String CargoType ){  
        
        Opportunity recOpportunity = createOpportunity(AccountID,primaryContactID,lbrand,Stage,RunAsUser,CargoType,null);
        return recOpportunity;
    }    
    
    
    public static Opportunity createOpportunity( ID AccountID, ID primaryContactID, String lbrand, String Stage, User RunAsUser, String CargoType,Id PriceBookId ){
   
        AccountDataHelper_Test.createClientNamedAccount();
       
        Opportunity recOpportunity = new Opportunity();        
        recOpportunity.Name =  lbrand + 'Test opportunity';
        recOpportunity.AccountId = AccountID;
        recOpportunity.CloseDate = date.today() + 10;
        recOpportunity.StageName = Stage;
        recOpportunity.Cargo_Type__c = CargoType;
        recOpportunity.Primary_Contact__c = primaryContactID;
        recOpportunity.Type = 'Transactional';
        recOpportunity.Liner_Brand__c = lbrand;    
        recOpportunity.First_Shipment_Date__c = date.today() + 30;
        recOpportunity.Last_Shipment_Date__c = date.today() + 40; 
        recOpportunity.Opp_Owners_Manager__c = UserDataGeneratorHelper_Test.MSLSystemAdminUser.id;
        recOpportunity.Named_Account__c =AccountDataHelper_Test.testNamedAccount.id;
        recOpportunity.Opportunity_contains_Dangerous_Goods__c = 'No';
        recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        recOpportunity.Expected_Handling_Rounds__c = 2;
        If(PricebookId != null){
            recOpportunity.Pricebook2Id = PricebookId;
        }
        
        System.runAs( RunAsUser ){
            insert recOpportunity; 
            system.debug('recOpportunity' + recOpportunity);
        } 
        System.debug('PriceBook of Opportunity'+recOpportunity.Pricebook2Id);
        return recOpportunity;  
    }
    
    public static List<Opportunity> createOpportunities( ID AccountID, ID primaryContactID, String lbrand, String Stage, User RunAsUser, String CargoType,Id PriceBookId, integer count ){
        
        list<Opportunity> opptyList = new list<Opportunity>();
        
        for ( integer i=0; i< count; i++){
            
            Opportunity recOpportunity = new Opportunity();        
            recOpportunity.Name =  lbrand + 'Test opportunity';
            recOpportunity.AccountId = AccountID;
            recOpportunity.CloseDate = date.today() + 10;
            recOpportunity.StageName = Stage;
            recOpportunity.Cargo_Type__c = CargoType;
            recOpportunity.Primary_Contact__c = primaryContactID;
            recOpportunity.Type = 'Transactional';
            recOpportunity.Liner_Brand__c = lbrand;    
            recOpportunity.First_Shipment_Date__c = date.today() + 30;
            recOpportunity.Last_Shipment_Date__c = date.today() + 40;
            recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
            recOpportunity.Expected_Handling_Rounds__c = 2;
            
            if( PricebookId != null ){
                recOpportunity.Pricebook2Id = PricebookId;
            }
            opptyList.add(recOpportunity);       
        }
        
        System.runAs( RunAsUser ){
            insert opptyList;
        } 
        return opptyList;
    }
    
    /*** Method to create Dry Opportunity for MSL Liner Brand  **/  
    public static Opportunity createMSLDryOpportunity( ID AccountID, ID primaryContactID ){  
        
        return createOpportunity ( AccountID, primaryContactID, BrandUtilities.MAERSKLINE, 'Identifying', UserDataGeneratorHelper_Test.MSLSystemAdminUser, 'DRY' );
    }
    
    /*** Method to create Dry Opportunity for SCL Liner Brand  **/  
   /* public static Opportunity createSCLDryOpportunity( ID AccountID, ID primaryContactID ){  
        
        return createOpportunity ( AccountID, primaryContactID, BrandUtilities.SAFMARINE, Label.OppQualify, UserDataGeneratorHelper_Test.SCLSystemAdminUser, 'DRY' );
    }*/
        
    /*** Method to create Dry Opportunity for SEA Liner Brand  **/  
    public static Opportunity createSEADryOpportunity( ID AccountID, ID primaryContactID ){  
        
        return createOpportunity ( AccountID, primaryContactID, BrandUtilities.SEALAND, 'Identifying', UserDataGeneratorHelper_Test.SEASystemAdminUser, 'DRY' );
        
    }
    
    /*** Method to create Dry Opportunity for MCC Liner Brand  **/  
    public static Opportunity createMCCDryOpportunity( ID AccountID, ID primaryContactID ){  
        
        return createOpportunity ( AccountID, primaryContactID, BrandUtilities.MCC, 'Identifying', UserDataGeneratorHelper_Test.MCCSystemAdminUser, 'DRY' );
    }
    
     /*** Method to create Dry Opportunity for MLL Liner Brand  **/  
    public static Opportunity createMLLDryOpportunity( ID AccountID, ID primaryContactID ){  
        
        return createOpportunity ( AccountID, primaryContactID, BrandUtilities.MAERSKLINE, 'Identifying', UserDataGeneratorHelper_Test.MLLSystemAdminUser, 'DRY' );
    }
    
     /*** Method to create Dry Opportunity for Seago Liner Brand  **/  
    public static Opportunity createSegDryOpportunity( ID AccountID, ID primaryContactID ){  
        
        return createOpportunity ( AccountID, primaryContactID, BrandUtilities.SEAGO, 'Identifying', UserDataGeneratorHelper_Test.SeagoSystemAdminUser, 'DRY' );
    }
        
    /*** Method to create Dry Closed Won Opportunity for MSL Liner Brand   **/         
    public static Opportunity createMSLDryClosedOpportunity( ID AccountID, ID primaryContactID ){  
        
        return createOpportunity ( AccountID, primaryContactID, BrandUtilities.MAERSKLINE, 'Identifying', UserDataGeneratorHelper_Test.MSLSystemAdminUser, 'DRY' );
    }
  
   public static Opportunity createTender( ID AccountId, ID primaryContactId, String lbrand, String Stage, User RunAsUser, Id PriceBookId, String nextSteps ){
        List<PermissionSet> permissionSet = [SELECT id, Name FROM PermissionSet where Name = 'Tender_Opportunity_Access' limit 1];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = RunAsUser.id;
        psa.PermissionSetId = permissionSet[0].id;
        system.runas( UserDataGeneratorHelper_Test.SCLSystemAdminUser ){
            database.insert ( psa, false );
        }
        
        Opportunity recOpportunity = new Opportunity();        
        recOpportunity.Name =  lbrand + ' Test Tender1'+system.now();
        recOpportunity.AccountId = AccountID;
        recOpportunity.CloseDate = system.today()+ 10;
        recOpportunity.StageName = Stage;
        recOpportunity.Next_Steps__c = nextSteps;
        recOpportunity.Primary_Contact__c = primaryContactID;
        recOpportunity.Type = 'Acquisition';
        recOpportunity.Customer_Type__c = 'BCO';
        recOpportunity.Tender_Type__c = 'Complex';
        recOpportunity.Tender_Submission_Format__c = 'Long Term Quote';
        recOpportunity.Customer_Requested_Rate_Structure__c = 'Yes';
        recOpportunity.First_Round_Submission_Date__c = system.today()+400;
        recOpportunity.Liner_Brand__c = lbrand;    
        recOpportunity.First_Shipment_Date__c = system.today() + 30;
        recOpportunity.Last_Shipment_Date__c = system.today() + 40; 
        recOpportunity.recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppShippingCargoRecordType ).getRecordTypeId();
        recOpportunity.Expected_Tender_Receipt_Date__c =  System.today() + 360;
        recOpportunity.First_Round_Submission_Date__c   = System.today() + 370;
        recOpportunity.Opportunity_contains_Dangerous_Goods__c = Label.Dangerous_Goods_Team_Support;
        recOpportunity.Commodity__c = 'Pharmaceuticals';
       recOpportunity.Expected_Handling_Rounds__c = 2;
       recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        
        if(PricebookId != null){
            recOpportunity.Pricebook2Id = PricebookId;
        }
        
        System.runAs( RunAsUser ){
            insert recOpportunity;
        } 
        return recOpportunity;  
    }

    /*** Method to create Dry Opportunity for MSL Liner Brand  **/  
    public static Opportunity createMSLTenderOpportunity( ID AccountID, ID primaryContactID ){  
        return createTender ( AccountID, primaryContactID, BrandUtilities.MAERSKLINE, 'Identifying', UserDataGeneratorHelper_Test.MSLTenderSystemAdminUser, null, ' ');
    }    
    
    /*Method to create Quarterly deal Opportunity for MSL Liner Brand */
     public static Opportunity createMSLQuarterlyDealOpportunity( ID AccountID, ID primaryContactID ){  
        return createQuarterlyDeal( AccountID, primaryContactID, BrandUtilities.MAERSKLINE, 'Identifying', null,UserDataGeneratorHelper_Test.MSLSystemAdminUser);
     }
    
    public static Opportunity createQuarterlyDeal( ID AccountId, ID primaryContactId, String lbrand, String Stage, Id PriceBookId,User RunAsUser ){
        
        Opportunity recOpportunity = new Opportunity();
        recOpportunity.Name =  lbrand + ' Test QuarterDeal';
        recOpportunity.AccountId = AccountID;
        recOpportunity.Liner_Brand__c=lbrand;
        recOpportunity.Type = 'Quarterly Deal Acquisition';
        recOpportunity.CloseDate = date.today() + 90;
        recOpportunity.StageName = Stage;
        recOpportunity.CloseDate = date.today() + 30;
        recOpportunity.First_Shipment_Date__c = date.today() + 100;
        recOpportunity.Last_Shipment_Date__c = date.today() + 130;
        recOpportunity.Commodity__c = 'Pharmaceuticals';
        recOpportunity.Freetime_Terms__c='No';
        recOpportunity.recordtypeid=System.label.QuarterlyDealsRecordTypeId;
        recOpportunity.Opportunity_contains_Dangerous_Goods__c = 'No';
        recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        recOpportunity.Expected_Handling_Rounds__c = 2;
        System.runAs( RunAsUser ){
            insert recOpportunity; 
        } 
      return recOpportunity;
    }
    // Method to create an opportunity of Supply Chain Services Record Type.
    public static Opportunity createSupplyChainServicesRecord(Id AccountId){
    
        Opportunity recOpportunity = new Opportunity();
        recOpportunity.Name = 'Test OmebKpiProcess';
        recOpportunity.Submitted_For_approval__c=False;
        recOpportunity.Approval_Status__c=Null;
        recOpportunity.AccountId = AccountID;
        recOpportunity.Liner_Brand__c='Maersk Line';
        recOpportunity.Type='Acquisition';
        recOpportunity.CloseDate=System.today() + 10;
        recOpportunity.StageName='Identifying';
        recOpportunity.Go_Live_Date__c=System.today() + 30;
        recOpportunity.First_Shipment_Date__c=System.today() + 20;
        recOpportunity.Last_Shipment_Date__c=System.today() + 40;    
        recOpportunity.Requires_IT_Integration__c=' Yes, I am sure this is required basis my discussion with customer';
        recOpportunity.Estimated_Agreement_Duration__c=9;
        recOpportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        recOpportunity.Expected_Handling_Rounds__c = 2;
        insert recOpportunity;
        return recOpportunity;
    }

}