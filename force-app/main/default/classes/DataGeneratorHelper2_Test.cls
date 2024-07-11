/**
* Helper class for generating Test data for different objects/custom settings
*
* Date         Owner                                    Ref Number      Description
**************************************************************************************************************************************
* 09/02/2016   meghana.gupta@ust-global.com             RQ-002978       Code created for creating test data of different objects
* 20/05/2016   Kishore.Dupam@ust-global.com             RQ-003428       add methods to create RateStructure related objects
* 20/10/2017   meghana.gupta@ust-global.com             RQ-007182       Modfy fields for RateStructure related objects/custom setting
* 01-Jul-2019  manjunath.c.holekade@maersk.com          RQ-010753       Remove reference of "Liner_Brand_Of_User_Not_Aligned_With_Opportunity" custom label
* 14-Aug-2019  manjunath.c.holekade@maersk.com          RQ-011436       Removal of "Customer_Rating__c" references
* 12-Sep-2019  manjunath.c.holekade@maersk.com          RQ-011884       Comment out unnecessary lines to improve code coverage
* 30-Jan-2020  manjunath.c.holekade@maersk.com          RQ-012371       Removed references of deprecated fields in Corridor_Guidance_Detail__c (Suggested_Guidance__c,Volume_Guidance__c)
* 08-Feb-2021  meghana.gupta@ust-global.com             SFSE-5541       Modify Modfy fields for RateStructureItems list custom setting
* 08-Jun-2022  Ronnie@SF                                SPI-100         Removed brand hardcoding
* 03-11-23	   Ritika@Maersk							SFSE-11753		To change the hard coded product family references to custom label
*/
@istest
public class DataGeneratorHelper2_Test {
    
    public static Id pricingMgmtQuartDealRecordTypeId; 
    /**
    * Constructor
    **/    
    public DataGeneratorHelper2_Test() {       
        
    }
    
    static {
        // check if users are already initialized due to some other test data generator class being used in test class       
        if ( UserDataGeneratorHelper_Test.integrationUser == null ) {
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        }
        if ( UserDataGeneratorHelper_Test.salesUser == null ) {
            UserDataGeneratorHelper_Test.initializeSalesUser();
        }
        pricingMgmtQuartDealRecordTypeId=Schema.SObjectType.Pricing_Management__c.getRecordTypeInfosByName()
            .get(system.label.QuarterlyDealsRecordTypeName).getRecordTypeId(); 
    } 
    
    // insert Opportunity Team Member
    public static List<OpportunityTeamMember> createOppTeamMembr( Integer count, User OTMUser, Id OpptyId, String TeamRole, boolean SetEditAccess ) {
        
        List<OpportunityTeamMember> OpptyTeamMbrList = new List<OpportunityTeamMember>();
        for( integer i = 0; i < count; i++ ) {
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.UserId = OTMUser.Id;
            otm.OpportunityId = OpptyId;
            otm.TeamMemberRole = TeamRole;
            OpptyTeamMbrList.add( otm );
        }
        try {
            Database.Upsert( OpptyTeamMbrList );
        } catch( Exception e ) {
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                if ( String.valueOf(msg) == Label.Error_User_Exists_As_Owner_Creator ) {
                    System.assertEquals(Label.Error_User_Exists_As_Owner_Creator, msg.getSummary());   
                }
            }        
        }   
        if ( SetEditAccess ) {
            List<OpportunityShare> shares = [SELECT Id, OpportunityAccessLevel, RowCause 
                                             FROM OpportunityShare 
                                             WHERE OpportunityId = :OpptyId  
                                             AND RowCause = 'Team' 
                                             AND OpportunityAccessLevel != 'Edit'];
            for ( OpportunityShare share : shares ) {
                share.OpportunityAccessLevel = 'Edit';
            } 
            update shares;
        }
        return OpptyTeamMbrList;
    }
    
    //insert Opportunity Team Member
    public static List<OpportunityTeamMember> createOppTeamMembr(Integer count,User OTMUser,Id OpptyId,String TeamRole) {
        List<OpportunityTeamMember> OpptyTeamMbrList = new List<OpportunityTeamMember>();
        for(integer i=0;i<count; i++) {
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.UserId = OTMUser.Id;
            otm.OpportunityId=OpptyId;
            otm.TeamMemberRole=TeamRole;//#RQ-000803 role renamed
            OpptyTeamMbrList.add(otm);
        }  
        
        try {
            // #RQ-000222 : This Opportunity Team Member will rejected because there are mismatched Liner Brand of Opportunity and User
            Database.Upsert(OpptyTeamMbrList);
        } catch(Exception e) {
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                if (String.valueOf(msg) == Label.Error_User_Exists_As_Owner_Creator) {
                    System.assertEquals(Label.Error_User_Exists_As_Owner_Creator, msg.getSummary());
                }
            }
        }   
        return OpptyTeamMbrList;
    }
    
    //insert Quote
    public static List<Quote> createQuote(Integer count,Id OpptyId) {
        List<Quote> QuoteList = new List<Quote>();
        for(Integer i= 0;i<count;i++) {
            Quote quoteObj = new Quote();
            quoteObj.Name='Test Quote';
            quoteObj.Effective_From_Date__c=date.today();
            quoteObj.ExpirationDate=date.today()+30;
            quoteObj.Segment__c='BCO';
            quoteObj.OpportunityId = OpptyId;
            QuoteList.add(quoteObj);
        }    
        insert QuoteList;
        return QuoteList;
    }
    
    //Insert Campaign
    public static List<Campaign> createCampaign(Integer count,String LinerBrand, Boolean Active,User RunAs) {
        List <Campaign> CampaignList = new List <Campaign>();    
        for(Integer i= 0;i<count;i++) {
            Campaign cpg=new Campaign();
            cpg.name='testcmngn';
            cpg.Liner_Brand__c = LinerBrand;
            cpg.IsActive = Active;
             cpg.Description= 'Test';
            CampaignList.add(cpg);
        }    
        system.runAs(RunAs) {
            System.debug('######Before inserting campaign in the data generator class'+CampaignList);
            insert CampaignList;
        }
        System.debug('Inserted campaigns'+CampaignList);
        return CampaignList;
    }
    
    public static List<Attachment> addAttachment ( Integer count ,Id ParentId, String contentType ) {
        List<Attachment> AttachmentList = new list <Attachment>();
        for(Integer i=0; i<count; i++) {
            Attachment attach = new Attachment();
            attach.Body = Blob.valueOf( 'test data ' );
            attach.Name = 'Test Attachement';
            attach.ContentType = contentType;
            attach.ParentId = ParentId; 
            AttachmentList.add(attach);
        }
        insert AttachmentList;
        return AttachmentList;
    }
    
    //Create test data for AFLSQuoteAttachment
    public static AFLS_Quote_Attachment__c createAFLSQuoteAttachment(Id QuoteId) {
        AFLS_Quote_Attachment__c quoteAttObjSingle = new AFLS_Quote_Attachment__c();
        quoteAttObjSingle.Quote__c = QuoteId; 
        insert quoteAttObjSingle;
        return quoteAttObjSingle;
    }
    
    public static Rate_Structure__c CreateRateStructure ( Id OpptyId ) {
        Rate_Structure__c recRS = new Rate_Structure__c();
        recRS.Description__c = 'test';
        recRS.Opportunity__c = OpptyId;
        recRs.Status__c = 'Approved';
        insert recRS;
        return recRS;
    }
    
    public static List<Rate_Structure_Item_List__c> CreateRateStructureItemList () {
        List<Rate_Structure_Item_List__c> insertList = new List<Rate_Structure_Item_List__c>();
        Rate_Structure_Item_List__c recRSL = new Rate_Structure_Item_List__c();
        recRSL.Name = 'test record1';
        recRSL.Charge_Name__c = 'Bunker Adjustment Factor';
        recRSL.New_Code__c = 'BAF';
        recRSL.Type__c = 'Required - BAF';
        recRSL.Sales_Approach__c = 'Subject to and Floating';
        recRSL.isActive__c = true;
        recRSL.Order__c = 1;
        recRSL.Product_Family__c = 'Ocean';
        recRSL.Charge_Type__c = 'Mandatory';
        recRSL.Occurrence__c = 'Transportation';
        recRSL.Cargo_type__c = '';	 	 
        insertList.add(recRSL);
        
        Rate_Structure_Item_List__c recRSL1 = new Rate_Structure_Item_List__c();
        recRSL1.Name = 'test record-2';
        recRSL1.Charge_Name__c = 'Bunker Increase Insurance';
        recRSL1.New_Code__c = 'BII';
        recRSL1.Type__c = 'Required';
        recRSL1.Sales_Approach__c = 'Subject to and Floating';
        recRSL1.isActive__c = true;
        recRSL1.Order__c = 2;
        recRSL.Product_Family__c = 'Ocean';
        recRSL.Charge_Type__c = 'Mandatory';
        recRSL.Occurrence__c = 'Transportation';
        recRSL.Cargo_type__c = 'Reefer';	
        insertList.add(recRSL1);
        
        Rate_Structure_Item_List__c recRSL3 = new Rate_Structure_Item_List__c();
        recRSL3.Name = 'test record3';
        recRSL3.Charge_Name__c = 'Single Truck Surcharge -Origin';
        recRSL3.New_Code__c = 'STO';
        recRSL3.Type__c = 'Not Required';
        recRSL3.Sales_Approach__c = 'Subject to and Floating';
        recRSL3.isActive__c = true;
        recRSL3.Order__c = 2;
        recRSL.Product_Family__c = System.Label.ProductFamily_Landside; //SFSE-11753
        recRSL.Charge_Type__c = 'Mandatory';
        recRSL.Occurrence__c = 'Origin';
        recRSL.Cargo_type__c = 'Reefer';	
        insertList.add(recRSL3);
        insert insertList;
        return insertList;
    }
    
    public static Corridor_Guidance__c createCorriodorGuidance( Id OpptyId, Id prodId ) {
        Corridor_Guidance__c recCorrGuidance = new Corridor_Guidance__c();
        recCorrGuidance.Comments__c = 'test comments';
        recCorrGuidance.Opportunity__c = OpptyId;
        recCorrGuidance.Product__c = prodId;
        insert recCorrGuidance;
        return recCorrGuidance;
    }
    
    public static Corridor_Guidance_Detail__c createCorriodorGuidanceDetail ( Id CorrGuidanceId, Id OriginId, Id DestinationId ) {
        Corridor_Guidance_Detail__c recCGDetail = new Corridor_Guidance_Detail__c();
        recCGDetail.CY_Per_FFE__c = 20;
        recCGDetail.Destination__c = DestinationId;
        recCGDetail.Origin__c = OriginId;
        recCGDetail.Relative_CY_vs_Trade__c = 40;
        recCGDetail.Target_Volume_FFE__c = 50;
        recCGDetail.Trade_Average_CY__c = 60;
        recCGDetail.Corridor_Guidance__c = CorrGuidanceId;
        recCGDetail.Origin_Cluster__c = 'Test Cluster1';
        recCGDetail.Destination_Cluster__c = 'Test Cluster2';
        recCGDetail.Weekly_FFE__c = 40;
        recCGDetail.Comments__c = 'Test Comments1';
        recCGDetail.RecordTypeId=system.label.CG_Detail_Tender_Record_Type_Id;
        insert recCGDetail;
        return recCGDetail;   
    }
    
    Public Static Onboarding_Program__c createOnboardingProgram() {
        //for inserting the Onboarding Program
        Onboarding_Program__c onbProgram = new Onboarding_Program__c();
        onbProgram.name = 'Onboarding Prgm for new hire';
        onbProgram.Brand__c = BrandUtilities.MAERSKLINE;
        onbProgram.Department__c = 'IT';
        //onbProgram.Description__c = 'onb program for new user'; //#SP-0013/#RQ-000640
        onbProgram.Role__c = 'Solution architect';
        onbProgram.Source__c = 'internal Hire';
        onbProgram.Status__c = 'Draft';
        insert onbProgram;
        return onbProgram;
    }
    
    Public Static Program_Module__c createProgramModule(Id onbProgramId) {
        //for inserting the Program module
        Program_Module__c programModule = new Program_Module__c();
        programModule.Duration__c = 3;
        programModule.Module__c = EnrollmentWizard_Test.moduleInsert.id;
        programModule.Onboarding_Program__c = onbProgramId;
        programModule.Order__c = 12;
        insert programModule;
        return programModule;
    }
    
    Public Static Program_Assignment__c createProgramAssignment(Id programModuleId,Id onbProgramId) {
        //for inserting the program assignment
        Program_Assignment__c prgmAssgn = new Program_Assignment__c();
        prgmAssgn.Program_Module__c = programModuleId;
        prgmAssgn.Module_Assignment__c = EnrollmentWizard_Test.assignmentInsert.id;
        prgmAssgn.Onboarding_Program__c = onbProgramId;
        insert prgmAssgn;
        return prgmAssgn;
    }
    
    Public Static New_Hire_Module__c createNewHireModule() {
        //for inserting the New hire module
        New_Hire_Module__c nhMdle= new New_Hire_Module__c();
        nhMdle.name = EnrollmentWizard_Test.moduleInsert.name;
        nhMdle.status__c = 'Not started';
        nhMdle.Order__c = EnrollmentWizard_Test.moduleInsert.Order__c;
        nhMdle.Onboarding_Plan__c = EnrollmentWizard_Test.onbPlan.id;
        nhMdle.Duration__c = EnrollmentWizard_Test.moduleInsert.Duration__c;
        //nhMdle.Description__c = EnrollmentWizard_Test.moduleInsert.Description__c; //#SP-0013/#RQ-000640
        nhMdle.Badge_Name__c = EnrollmentWizard_Test.moduleInsert.Badge_Name__c;
        nhMdle.Badge_URL__c = EnrollmentWizard_Test.moduleInsert.Badge_URL__c;
        nhMdle.Category__c = EnrollmentWizard_Test.moduleInsert.Category__c;
        nhMdle.Module_OR_Program_Module_Id__c = EnrollmentWizard_Test.moduleInsert.id;
        insert nhMdle;
        return nhMdle;
    }
    
    Public Static New_Hire_Assignments__c createNewHireAssignments(Id newHireModId) {
        //for inserting the new hire assignments
        New_Hire_Assignments__c nhAssgn = new New_Hire_Assignments__c();
        nhAssgn.New_Hire_Module__c = newHireModId;
        //nhAssgn.Description__c = EnrollmentWizard_Test.assignmentInsert.Description__c; //#SP-0013/#RQ-000640
        nhAssgn.Onboarding_Plan__c = EnrollmentWizard_Test.onbPlan.id;
        nhAssgn.Order__c =  EnrollmentWizard_Test.assignmentInsert.Order__c;
        nhAssgn.Status__c = 'Not started';
        nhAssgn.Assignment_OR_Program_Assignment_Id__c = EnrollmentWizard_Test.assignmentInsert.id;
        insert nhAssgn;
        return nhAssgn;
    }
    
    Public Static Assignmen_Content__c createAssignmenContent() {
        //for inserting the content
        Assignmen_Content__c content = new Assignmen_Content__c();
        content.name = 'Test Content124';
        content.Link_To_Document__c = 'https://www.office.com';
        content.Module_Assignment__c = EnrollmentWizard_Test.assignmentInsert.id;
        content.Description__c = 'Content for the assignment';
        insert content;
        return content;
    }
    
    public static Corridor_Guidance__c createQdealCorriodorGuidance( Id OpptyId, Id prodId ) {
        Corridor_Guidance__c recCorrGuidance = new Corridor_Guidance__c();
        system.debug('$$$$$$$OpptyId: '+ OpptyId );
        system.debug('$$$$$$$prodId: '+ prodId );
        recCorrGuidance.Description__c = 'test Description';
        recCorrGuidance.Opportunity__c = OpptyId;
        recCorrGuidance.Product__c = prodId;
        insert recCorrGuidance;
        return recCorrGuidance;
    }
    
    public static Corridor_Guidance_Detail__c createQuarterlyDealCorriodorGuidanceDetail ( Id CorrGuidanceId, String Origin, String Destination ) {
        Corridor_Guidance_Detail__c recCGDetail = new Corridor_Guidance_Detail__c();
        recCGDetail.Origin_Micromarket__c=Origin;
        recCGDetail.Destination_Micromarket__c=Destination;
        recCGDetail.Target_20__c=40;
        recCGDetail.Target_40__c=40;
        recCGDetail.Target_40h__c=40;
        recCGDetail.CEN_Final_Agreed_Rate_20__c=10;
        recCGDetail.CEN_Final_Agreed_Rate_40__c=10;
        recCGDetail.CEN_Final_Agreed_Rate_40h__c=10;
        recCGDetail.Corridor_Guidance__c = CorrGuidanceId;
        recCGDetail.RecordTypeId=system.label.CG_Detail_Quarterly_Deal_Record_Type_Id;
        insert recCGDetail;
        return recCGDetail;
    }    
}