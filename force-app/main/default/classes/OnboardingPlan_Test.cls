/**
 * Test class for 
 *  OnboardingPlanTrigger    
 *  OnboardingPlanTriggerHandler
 * 
 * Version     Date            Owner                                    RQ#               Description
 **************************************************************************************************************************
 * 1.0         11/10/2014      Ranjini.Janardhanan@ust-global.com       #PR-0028          Code created 
 *                             Madhava.kotte@ust-global.com
 * 
 * 2.0         12/12/2014      Ranjini.Janardhanan@ust-global.com       #SP-0007          Code updated.
 * 
 * 3.0         03-03-2017      deepak.r.mahapatra@in.ibm.com            #RQ-004643        Delete Quoting Tool Field in the User object
 * 4.0         04-04-2017      Abby.Abraham@ust-global.com              #RQ-004759        Modified test class to accomodate User Country Mandatory Validation Rule
 * 5.0         08-06-2022      Ronnie@SF                                SPI-100           Removed brand hardcoding
 */

@isTest
public class OnboardingPlan_Test {
    
    //Making the below variables as public for resuing this users in some other test classes
    public static user salex;
    public static user onboarder;
    public static user newhire;
    public static user onboarder1;
    public static user newhire1;
    public static BDA__C testBDA;
    
    /*
    * Creates the necsessary users for the onboarding plan.
    */   
    public static void createUsers(){
         
         // #RQ-004759
         Geography__c recGeo = new Geography__c(
                        Name = 'India',
                        Active__c =true,
                        GEO_Code__c = 'IN',
                        GEO_ID__c = '10Z2W9Zkjh3q4a35',
                        Is_Port__c = false,
                        Type_Of_Location__c = 'Country');
        insert recGeo;
            
        List <User> userListToCreate = new List <User>();
        Profile salesProfile=[Select Id,Name from Profile where Id = :Label.TestClean_ProfileIdsSales];  
        
        salex= new User();                 
        salex.FirstName='Test ABC';                 
        salex.LastName='salex';                 
        salex.Username='salex234423@salex.com';                 
        salex.Email='Tesreqazxswedce34v@ust-global.com';                 
        salex.Alias='tuser';                 
        salex.CommunityNickname='salex5312456';                 
        salex.TimeZoneSidKey='Europe/London';                 
        salex.LocaleSidKey='en_GB';                 
        salex.EmailEncodingKey='ISO-8859-1';                 
        salex.ProfileId=salesProfile.id;                 
        salex.Cluster__c='Dummy Cluster';
        salex.Country=recGeo.Name; //#RQ-004759
        //salex.Quoting_Tool__c='Quote Builder';                 
        salex.LanguageLocaleKey='en_US';  
        salex.Liner_Brand__c=BrandUtilities.MAERSKLINE;   
        salex.CM_Visibility__c='Single Carrier'; 
        userListToCreate.add(salex) ;
        
        onboarder= new User();                 
        onboarder.FirstName='Test Onb23';                 
        onboarder.LastName='onboarder243';                 
        onboarder.Username='onboarder24238@onboarder.com';                 
        onboarder.Email='tesrev567hgf@ust-global.com';                 
        onboarder.Alias='tuser';                 
        onboarder.CommunityNickname='onboardersdg2345';                 
        onboarder.TimeZoneSidKey='Europe/London';                 
        onboarder.LocaleSidKey='en_GB';                 
        onboarder.EmailEncodingKey='ISO-8859-1';                 
        onboarder.ProfileId=salesProfile.id;                 
        onboarder.Cluster__c='Dummy Cluster';
        onboarder.Country=recGeo.Name; //#RQ-004759
        //onboarder.Quoting_Tool__c='Quote Builder';                 
        onboarder.LanguageLocaleKey='en_US';  
        onboarder.Liner_Brand__c=BrandUtilities.MAERSKLINE;
        onboarder.CM_Visibility__c='Single Carrier'; 
        userListToCreate.add(onboarder) ;
        
        newhire= new User();                 
        newhire.FirstName='Test';                 
        newhire.LastName='newhire';                 
        newhire.Username='newhire3241g6@newhire.com';                 
        newhire.Email='Tes98tgbnhyujm@ust-global.com';                 
        newhire.Alias='tuser';                 
        newhire.CommunityNickname='newhirejh641282';                 
        newhire.TimeZoneSidKey='Europe/London';                 
        newhire.LocaleSidKey='en_GB';                 
        newhire.EmailEncodingKey='ISO-8859-1';                 
        newhire.ProfileId=salesProfile.id;                 
        newhire.Cluster__c='Dummy Cluster';
        newhire.Country=recGeo.Name; // #RQ-004759
        //newhire.Quoting_Tool__c='Quote Builder';                 
        newhire.LanguageLocaleKey='en_US';  
        newhire.Liner_Brand__c=BrandUtilities.MAERSKLINE;
        newhire.CM_Visibility__c='Single Carrier';  
        userListToCreate.add(newhire) ;
        
        onboarder1= new User();                 
        onboarder1.FirstName='Test Onb35466';                 
        onboarder1.LastName='onboarder164365';                 
        onboarder1.Username='onboarder1256523@onboarder1.com';                 
        onboarder1.Email='tesrev098nhbgzsa@ust-global.com';                 
        onboarder1.Alias='tuser';                 
        onboarder1.CommunityNickname='onboarder12135not';                 
        onboarder1.TimeZoneSidKey='Europe/London';                 
        onboarder1.LocaleSidKey='en_GB';                 
        onboarder1.EmailEncodingKey='ISO-8859-1';                 
        onboarder1.ProfileId=salesProfile.id;                 
        onboarder1.Cluster__c='Dummy Cluster';
        onboarder1.Country=recGeo.Name; // #RQ-004759
        //onboarder1.Quoting_Tool__c='Quote Builder';                 
        onboarder1.LanguageLocaleKey='en_US';  
        onboarder1.Liner_Brand__c=BrandUtilities.MAERSKLINE;
        onboarder1.CM_Visibility__c='Single Carrier';  
        userListToCreate.add(onboarder1) ;
        
        newhire1= new User();                 
        newhire1.FirstName='Test Nh23523';                 
        newhire1.LastName='newhire1';                 
        newhire1.Username='newhire123589jml@newhire1.com';                 
        newhire1.Email='Tesreikmjnh098xdc@ust-global.com';                 
        newhire1.Alias='tuser';                 
        newhire1.CommunityNickname='newhi4t1gher5233';                 
        newhire1.TimeZoneSidKey='Europe/London';                 
        newhire1.LocaleSidKey='en_GB';                 
        newhire1.EmailEncodingKey='ISO-8859-1';                 
        newhire1.ProfileId=salesProfile.id;                 
        newhire1.Cluster__c='Dummy Cluster';
        newhire1.Country=recGeo.Name; // #RQ-004759
        //newhire1.Quoting_Tool__c='Quote Builder';                 
        newhire1.LanguageLocaleKey='en_US';  
        newhire1.Liner_Brand__c=BrandUtilities.MAERSKLINE;
        newhire1.CM_Visibility__c='Single Carrier'; 
        userListToCreate.add(newhire1) ;

        insert userListToCreate;    
    }
    
    /*
    * Checks if the newhire is the owner of the onboarding plan.
    */ 
    static testMethod void onboardingPlanOwnerUpdate() {
        
        createUsers();
        Onboarding_Plan__c op = new Onboarding_Plan__c();
        op.Name = 'Plan for Test user';
        op.Coordinator__c = salex.Id;
        op.Onboarder__c = onboarder.Id;
        op.New_Hire__c = newhire.Id;
        op.start_date__c = system.today();
        insert op;
        
        Id opOwner = [SELECT Id,OwnerId FROM Onboarding_Plan__c WHERE Id =:op.Id].OwnerId;
        //System.assertEquals(opOwner, newhire.Id);
        
        op.New_Hire__c = newhire1.Id;
        update op;
        
        Id opOwnerUpdated = [SELECT Id,OwnerId FROM Onboarding_Plan__c WHERE Id =:op.Id].OwnerId;
        //System.assertEquals(opOwnerUpdated, newhire1.Id);   
    }
    
    /*
     * Checks if the onboarding share is added correctly.
     */ 
    static testMethod void onboarderUpdate() {
        
        createUsers();
        Onboarding_Plan__c op = new Onboarding_Plan__c();
        op.Name = 'Plan for Test user';
        op.Coordinator__c = salex.Id;
        op.Onboarder__c = onboarder.Id;
        op.New_Hire__c = newhire.Id;
        op.start_date__c = system.today();        
        insert op;
        
        New_Hire_Module__c nhm = new New_Hire_Module__c();
        nhm.Name = 'nhm 1';
        nhm.Onboarding_Plan__c = op.Id;
        nhm.Status__c = 'Not Started';
        insert nhm;
        
        string OnboarderEmail = [SELECT Id,Onboarder_Email__c FROM New_Hire_Module__c WHERE Id =:nhm.Id].Onboarder_Email__c;
        
        List <Onboarding_Plan__Share> opShare = [SELECT Id, ParentId, UserOrGroupId, RowCause
                                                 FROM Onboarding_Plan__Share
                                                 WHERE ParentId =: op.Id AND RowCause =: Schema.Onboarding_Plan__Share.RowCause.Onboarder_Access__c];
        
        //System.assertEquals(opShare[0].UserOrGroupId, onboarder.Id);
        //System.assertEquals(opShare.size(), 1);
        //System.assertEquals(OnboarderEmail, onboarder.Email);
        
        op.Onboarder__c = onboarder1.Id;
        update op;
        
        string OnboarderEmailUpdated = [SELECT Id,Onboarder_Email__c FROM New_Hire_Module__c WHERE Id =:nhm.Id].Onboarder_Email__c;
        List <Onboarding_Plan__Share> opShareUpdated = [SELECT Id, ParentId, UserOrGroupId, RowCause
                                                        FROM Onboarding_Plan__Share
                                                        WHERE ParentId =: op.Id AND RowCause =: Schema.Onboarding_Plan__Share.RowCause.Onboarder_Access__c];
        
        //System.assertEquals(opShareUpdated[0].UserOrGroupId, onboarder1.Id);
        //System.assertEquals(opShareUpdated.size(), 1);
        //System.assertEquals(OnboarderEmailUpdated, onboarder1.Email);
    }
    
    /*
    * Checks if the newhire is the owner of the onboarding plan.
    */ 
    static testMethod void onbPlanStatusChangeValidation() {
        
        createUsers();
        
        test.startTest();
        
        Onboarding_Plan__c onbPlan = new Onboarding_Plan__c();
        onbPlan.Name = 'Plan for Test user123';
        onbPlan.Coordinator__c = salex.Id;
        onbPlan.Onboarder__c = onboarder.Id;
        onbPlan.New_Hire__c = newhire.Id;
        onbPlan.start_date__c = system.today();
        onbPlan.Status__c = 'Ready';
        onbPlan.Enrolled_Or_Onboarded__c = 0;

        insert onbPlan;
            
        for(Onboarding_Plan__c onbPln : [SELECT id, name, status__c FROM Onboarding_Plan__c WHERE id =: onbPlan.id]) {
            System.assertEquals(onbPln.Status__c, 'Ready');
        }
        
        onbPlan.Enrolled_Or_Onboarded__c = 1;
        onbPlan.Status__c = 'Enrolled';
        
        update onbPlan;
            
        for(Onboarding_Plan__c onbPln : [SELECT id, name, status__c FROM Onboarding_Plan__c WHERE id =: onbPlan.id]) {
            System.assertEquals(onbPln.Status__c, 'Enrolled');
        }
        test.StopTest();
    }
    
    /*
     * #SP-0007.Test method for onboarding cancelled status record lock.
     */  
    static testMethod void onbPlanLock(){
        
        createUsers();
        Onboarding_Plan__c onbPlan = new Onboarding_Plan__c();
        onbPlan.Name = 'Plan for Test user123';
        onbPlan.Coordinator__c = salex.Id;
        onbPlan.Onboarder__c = onboarder.Id;
        onbPlan.New_Hire__c = newhire.Id;
        onbPlan.start_date__c = system.today();
        onbPlan.Status__c = 'Ready';
        onbPlan.Enrolled_Or_Onboarded__c = 0;
        insert onbPlan;
        
        New_Hire_Module__c nhm = new New_Hire_Module__c();
        nhm.Onboarding_Plan__c = onbPlan.Id;
        nhm.Name = 'test';
        nhm.Order__c = 1;
        nhm.Duration__c = 2;
        nhm.Status__c = 'Not Started';
        insert nhm;
        
        New_Hire_Assignments__c nha = new New_Hire_Assignments__c();
        nha.New_Hire_Module__c = nhm.Id;
        nha.Onboarding_Plan__c = onbPlan.Id;
        nha.Order__c = 1;        
        insert nha;
        
        onbPlan.Enrolled_Or_Onboarded__c = 1;
        onbPlan.Status__c = 'Enrolled';        
        update onbPlan;
        
        onbPlan.Status__c = 'Cancelled';
        update onbPlan;
    }
}