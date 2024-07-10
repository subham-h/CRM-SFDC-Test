/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		09-Oct-2023		Vazid					This is a test class for the AllocationSummaryReportCntrl.	
* 2.0		19-Oct-2023		Seba					Modified for SFSE-13019	
* 3.0		22-Jan-2023		Seba					Modified for SFSE-13698  
*/
@isTest
public class AllocationSummaryReportCntrlTest {
    /*Using SeeAllData attribute since, in Apex tests, report runs always ignore the SeeAllData annotation, 
      regardless of whether the annotation is set to true or false.*/
        
    @isTest(SeeAllData='true')
    public static void testgetReportMetadata() {
        User currentUser = new User(Id = UserInfo.getUserId()); 
        TriggerExecutionController.skipUserTrigger(true);
        User salesUserManager = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, FALSE);
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, true);
        System.runAs(currentUser){  
            TriggerExecutionController.skipUserTrigger(true);
        	salesUserManager.Id = null;
            salesUserManager.IsActive=true; 
            salesUserManager.Cluster__c = 'GSC'; 
            salesUserManager.Sales_Job_Function__c='Sales Manager'; 
            insert salesUserManager; 
             
            salesUser.Id = null; 
            salesUser.UserName = 'a'+salesUser.UserName;             
            salesUser.Maersk_User_Id__c = 'a'+salesUser.Maersk_User_Id__c; 
            salesUser.FederationIdentifier = 'a'+salesUser.FederationIdentifier; 
            salesUser.CommunityNickname = 'a'+salesUser.CommunityNickname;
            salesUser.IsActive=true; 
            salesUser.Cluster__c = 'GSC'; 
            salesUser.Sales_Job_Function__c='Other';
            salesUser.ManagerId = salesUserManager.Id;
            insert salesUser;
         
            TriggerExecutionController.skipAllTriggers(true);
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1].Id;
            Id salesTargetUserSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='Sales_Target_User' LIMIT 1].Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE (PermissionSetId = :managePortfolioPermissionSetId OR PermissionSetId = :salesTargetUserSetId)AND AssigneeId = :salesUser.Id];
            List<PermissionSetAssignment> assgnmentsToInsert = new List<PermissionSetAssignment>();
            if(ps.isEmpty()){
                assgnmentsToInsert.add(new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = managePortfolioPermissionSetId));
                assgnmentsToInsert.add(new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = salesTargetUserSetId)); 
            }
            insert assgnmentsToInsert; 
        }
            
        Territory__c salesUserTerritory  = TestBusinessHelper.createTerritory(salesUser, TRUE);
        Territory_Account_Association__c TAA_SalesUser = new Territory_Account_Association__c();  
         
        Target__c targetRec = [SELECT Id from Target__c WHERE Id in (SELECT Target__c from target_item__c where Target__c!=null and Product_Family__c!=null) LIMIT 1]; 
        List<Target_Item_Group__c> lstItemGrpRec = [SELECT Id from Target_Item_Group__c where Target__c= :targetRec.Id and Product_Family__c != null];
        Set<Id> tigIds = new Set<Id>();
        for(Target_Item_Group__c tig : lstItemGrpRec){
            tigIds.add(tig.Id);
        }
        List<Target_item__c> targetItemRec = [Select Id, Target__c, Account__c, Attractiveness__c, Brand__c, Account_Customer_Code__c, 
                                        Account_Concern_Code__c, Product_Family__c, Controlling_Country__c, Executing_Country__c,Target_Item_Type__c, 
                                        Executing_Area__c, Executing_Region__c, Sales_Channel__c, Vertical__c from Target_item__c  WHERE 
                                        Product_Family__c != null and Account__c!= null and  Brand__c != null  and
                                        Sales_Target_Item_Group__c IN :tigIds and Id IN (SELECT Target_Item__c from Target_Measure__c WHERE Measure_Dimension__c = 'Target') LIMIT 10];
        
        Target_measure__C temMeasureRec1 = new Target_measure__C(Measure_Dimension__c='Previous Year Actuals', Target_Item__c = targetItemRec[0].Id, Party_Type__c = 'Price Owner', Measure_Type__c='Revenue',Jan__c = 10, Feb__c = 20); insert temMeasureRec1;
        Target_measure__C temMeasureRec = [SELECT Id,Measure_Dimension__c,Party_Type__c,Target_Item__r.Attractiveness__c,Target_Item__r.Brand__c,target_item__r.Product_Family__c,target_item__r.Executing_Country__c,target_item__r.Executing_Area__c,target_item__r.Sales_Channel__c,target_item__r.Vertical__c,target_item__r.Account_Customer_Code__c, target_item__r.Account_Concern_Code__c, target_item__r.Target_Item_Type__c, Credit_Eligible__c from Target_Measure__c where Target_Item__c = :targetItemRec[0].Id AND Measure_Dimension__c = 'Target' LIMIT 1];
        
        Account accTI = [SELECT Id from Account where Id = :targetItemRec[0].Account__c LIMIT 1];
        Geography__c countryIndia = TestBusinessHelper.createGeography('India', 'Country', null, false);
        countryIndia.Active__c = true; countryIndia.Id = null; insert countryIndia;
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, currentUser.Id, false);
        parentBDA.BDA_Code__c = 'parent1'+ parentBDA.BDA_Code__c; parentBDA.Id = null; insert parentBDA;
        
        BDA__c clusterWestAfrica = TestBusinessHelper.createBDA('West Africa Area', 'Cluster', 'WAF', null, null, false);
        clusterWestAfrica.BDA_Code__c = 'a'+clusterWestAfrica.BDA_Code__c; clusterWestAfrica.ID = null; insert clusterWestAfrica;
        
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(clusterWestAfrica.Id,countryIndia.Id,null, true); 
        TriggerExecutionController.skipAllTriggers(true);
        System.runAs(salesUser){ 
        	TAA_SalesUser = TestBusinessHelper.createTerritoryAccountAssociation(salesUserTerritory, accTI,'Sales Owner','All', 'Maersk Line', true); 
        }
        
        Target_Customer_Portfolio__C targetCustomerPortfolio =  TestBusinessHelper.createTCPRecord(temMeasureRec, TAA_SalesUser, salesUser, true);
        Target_Stage_Matrix__c matrixLevel = TestBusinessHelper.createSalesTargetApprovalMatrix(targetRec, TargetSettingConstants.APPROVAL_STAGE_3, clusterWestAfrica, parentBDA, '', '', true);
        Target_Reviewer__c reviewerLevel = TestBusinessHelper.createSalesTargetApprovalUser(matrixLevel, currentUser, false, true);
         
        String instanceId = '';  
       
        try {  
            Test.startTest();
            instanceId = AllocationSummaryReportCntrl.getReportMetadata('Target_Item__c.Attractiveness__c', 'Revenue',String.valueOf(targetRec.Id),temMeasureRec.Party_Type__c,String.valueOf(temMeasureRec.Credit_Eligible__c),temMeasureRec.target_item__r.Attractiveness__c,temMeasureRec.target_item__r.Brand__c,temMeasureRec.target_item__r.Product_Family__c,null, null, null,temMeasureRec.target_item__r.Executing_Country__c,temMeasureRec.target_item__r.Executing_Area__c,null,temMeasureRec.target_item__r.Sales_Channel__c,temMeasureRec.target_item__r.Vertical__c,temMeasureRec.target_item__r.Account_Customer_Code__c,temMeasureRec.target_item__r.Account_Concern_Code__c,temMeasureRec.target_item__r.Target_Item_Type__c,null,null);
            Test.stopTest();
        } catch (Exception ex) {
           system.debug('Exception thrown: -> '+ex); 
        }
        try {
            AllocationSummaryReportCntrl.getAsyncReportData(instanceId);
           
        } catch (Exception ex) {
            system.debug('Exception thrown: -> '+ex);
        }  
        //SFSE-13019
        List<String> objFldLst = new List<String>{'Account-Attractiveness__c'};
        AllocationSummaryReportCntrl.getOptionsForPicklistFields(objFldLst);
        objFldLst.add('Account-Attractiveness');//To cover exception block
        AllocationSummaryReportCntrl.getOptionsForPicklistFields(objFldLst);
    }
}