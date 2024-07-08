@isTest
public class createSalesTargetApproverctrlTest {
   @testSetup
    static void setupTestData() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year = new List<String>{'2034','2035','2036'};
        List<String> curr = new List<String>{'USD','USD','USD'};
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        Geography__c testCountry = new Geography__c();
        testCountry.Name = 'India';
        testCountry.Active__c =true;
        testCountry.GEO_Code__c = 'IN';
        testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
        testCountry.Is_Port__c = false;
        testCountry.Type_Of_Location__c = 'Country';
        insert testCountry;
        BDA__c testCluster = new BDA__C ();
        testCluster.Name = 'West Africa Area';
        testCluster.Type__c = 'Cluster';
        testCluster.BDA_Code__c = 'WAF';
        testCluster.GEO_ID__c= 'dsaewetwer';
        testCluster.Active__c  =  true;
        insert testCluster;
        BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
        bdaGeo.BDA__c = testCluster.Id;
        bdaGeo.Geography__c = testCountry.Id;
        insert bdaGeo;
        List<Geography__c> cntry= new List<Geography__c>{testCountry,testCountry,testCountry};
        String countryCode= 'IN';
        List<String> uniqueIds = new List<String>{'INML','DKSM','INSM'};
        List<String> brands = new List<String>{'Maersk Line','Hamburg Sud','HUUB'};
        Account acc = TestBusinessHelper.createAccount('Client_Account',true);

        Target_Stage_Matrix__c stageMatrix = TestBusinessHelper.createSalesTargetApprovalMatrix(testTargets[0], TargetSettingConstants.APPROVAL_STAGE_1, testCluster, null, '', '', true);
        Target_Reviewer__c reviewer = TestBusinessHelper.createSalesTargetApprovalUser(stageMatrix,user1,true,true);
    }
    
     @istest
    static void testgetBDARecords(){
        BDA__c bdaname = [SELECT Id, Name from BDA__c LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        Target_Stage_Matrix__c tsm = [SELECT Id FROM Target_Stage_Matrix__c ];
        system.debug('@@@@ ' + tsm);
        LIst<Target_Reviewer__c> tlst = [SELECT Id, Target_Approval_Matrix__c FROM Target_Reviewer__c];
        system.debug('@@@@ ' + tlst);
        Target__c t = [SELECT Id FROM Target__c LIMIT 1];
        Test.startTest();
        createSalesTargetApproverctrl.getBDARecords(bdaname.Id);
        createSalesTargetApproverctrl.getRecordsByStage('Level 1 creator - Area Commercial FBP', t.Id);
        createSalesTargetApproverctrl.chkifuserAdded(t.Id, u.Id, null);
        createSalesTargetApproverctrl.deleteRecord(t.Id,tsm.Id);
        createSalesTargetApproverctrl.updateTargetStageToComplete(t.Id);
        Test.stopTest();
        
    }
    
     @istest
    static void testgetAllRecords(){
        User u = [SELECT Id FROM User LIMIT 1];
        List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_1;
        tx.Target__c= tr[0].Id;	
        insert tx;
        Assert.isNotNull(tx.Id);
        
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = u.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        Test.startTest();
        createSalesTargetApproverctrl.getAllRecords(tr[0].Id); 
        Test.stopTest();
    }
    
    @istest
    static void testSaveRecords(){
        BDA__c bdaname = [SELECT Id, Name from BDA__c LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        List<Target_Stage_Matrix__c> txlst = new List<Target_Stage_Matrix__c>();
        List<Target_Reviewer__c> trlst = new List<Target_Reviewer__c>();
        Map<String, List<string>> mapofAreaNametoUserId = new Map<String, List<string>>();
        mapofAreaNametoUserId.put(bdaname.Id, new List<String>{u.Id});

        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_1;
        tx.Target__c= tr[0].Id;	
        insert tx;
        txlst.add(tx);
        Assert.isNotNull(tx.Id);
        
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = u.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        trlst.add(Trv);
        createSalesTargetApproverctrl.wrappertest wrap = new createSalesTargetApproverctrl.wrappertest();
        List<createSalesTargetApproverctrl.wrappertest> wraplst = new List<createSalesTargetApproverctrl.wrappertest>();
        wrap.areaid = bdaname.Id;
        wrap.childusrId = u.Id;
        wrap.childrecId = Trv.Id;
        wraplst.add(wrap);
        Test.startTest();
        createSalesTargetApproverctrl.saveRecords(trlst, txlst, mapofAreaNametoUserId, wraplst);
        Test.stopTest();
    }
    
    @istest
    static void testbeforeSaveRecords(){
        BDA__c bdaname = [SELECT Id, Name from BDA__c LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        List<Target_Stage_Matrix__c> txlst = new List<Target_Stage_Matrix__c>();
        List<Target_Reviewer__c> trlst = new List<Target_Reviewer__c>();
        Map<String, List<string>> mapofAreaNametoUserId = new Map<String, List<string>>();
        mapofAreaNametoUserId.put(bdaname.Id, new List<String>{u.Id});
        
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_1;
        tx.Target__c= tr[0].Id;	
        //insert tx;
        txlst.add(tx);
        
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = u.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
       // insert Trv;
        trlst.add(Trv);
        createSalesTargetApproverctrl.wrappertest wrap = new createSalesTargetApproverctrl.wrappertest();
        List<createSalesTargetApproverctrl.wrappertest> wraplst = new List<createSalesTargetApproverctrl.wrappertest>();
        wrap.areaid = bdaname.Id;
        wrap.childusrId = u.Id;
        wrap.childrecId = Trv.Id;
        wraplst.add(wrap);
        Test.startTest();
        createSalesTargetApproverctrl.saveRecords(trlst, txlst, mapofAreaNametoUserId, wraplst);
        Test.stopTest();
    }
}