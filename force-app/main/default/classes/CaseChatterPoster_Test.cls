/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      21/03/2018   Meenakshi.rajasekaran@ust-global.com        #RQ-008020     Test class for caseChatterPoster
* 2.0      14/06/2018   Meenakshi.rajasekaran@ust-global.com        #RQ-008547      Case Assignment Notification
* 3.0      20/04/202    Ramadevi@UST                                #SC-160         Trigger recursion
*/
@isTest
public class CaseChatterPoster_Test {
    
    public static final String LOGMARK = '##### CaseChatterPoster_Test : ';
    public static List<case> lstParentCse = new list<Case>();  
    public Static List<Id> caseIds = new List<Id>();
    
    static {
        
        // create method if users are not created already by anyother test data generator class
        if (UserDataGeneratorHelper_Test.MSLCustomerServiceUser == null){
            
            UserDataGeneratorHelper_Test.initializeCustomerServiceUser(); 
            
        }   
    }
    
    public static void createData(){
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email =  'test@gmail.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;                
        CaseData_Test.createISRCases();
        lstparentCse =  CaseData_Test.lstCases;
        
        TriggerExecutionController.skipAllTriggers(true);
        insert lstParentCse; 
        TriggerExecutionController.skipAllTriggers(false);        
        
        caseIds.add(lstParentCse[0].Id);            
        lstParentCse[0].Description = 'Test Description';         
        lstParentCse[0].Liner_Brand__c  = 'MSL';
        lstParentCse[0].ownerid = userinfo.getUserId();   
        
        update lstParentCse;
        system.debug(Logginglevel.DEBUG, LOGMARK+'lstParentCse'+lstParentCse);
    }
    
    public static testMethod void test_chatterPost(){
        CaseChatterPoster_Test.createData();
        //#RQ-008547 Case Assignment notification
        map<Id, Case> mapupdatedownerCases = new map<id,case>();  
        list<case> lstISROwnerupdatedcases =new list<Case>();
        List<Id> recordId = new List<Id>();
        for(case c: lstParentCse){  
            c.ownerid = UserDataGeneratorHelper_Test.MSLCustomerServiceUser.id;      
            lstISROwnerupdatedcases.add(c); 
            recordId.add(c.Id);
        } 
        
        Test.startTest();  
        
        update lstISROwnerupdatedcases;         
        
        system.debug(Logginglevel.DEBUG, LOGMARK+'lstISROwnerupdatedcases'+lstISROwnerupdatedcases); 
        
        for(case cs :lstISROwnerupdatedcases )
        {
            mapupdatedownerCases.put(cs.id,cs) ;
        }
        
        system.debug(Logginglevel.DEBUG, LOGMARK+'**mapupdatedownerCases**'+mapupdatedownerCases); //#RQ-008547 Case Assignment notification
        
        /*CaseChatterPoster ccp = new CaseChatterPoster();        
        ccp.postToRequestorForRT(mapClosedCases);
        CaseChatterPoster.isFirstTime = true;//#RQ-008547 Case Assignment notification
        ccp.PostToNotifyCaseowner(mapupdatedownerCases);//#RQ-008547 Case Assignment notification
        */
        list<feeditem> FIList = [Select Id,ParentId,Body FROM feeditem WHERE ParentId  IN: mapupdatedownerCases.keyset()];
        Case CaseUpdated = [SELECT Id,CaseNumber from Case where id=:FIList[0].parentId];
        system.AssertEquals(FIList[0].body,'CASE '+CaseUpdated.CaseNumber);
        
        system.debug(Logginglevel.DEBUG, LOGMARK+'FIList '+FIList);       
        
        system.debug('Updated Case $$ '+mapupdatedownerCases.get(FIList[0].parentId));
        
        //old - system.assertEquals(FIList[0].body, 'CASE'+ ' ' + mapupdatedownerCases.get(FIList[0].parentId).caseNumber);    
        Test.stopTest();
         
    }
    
    public static testMethod void test_chatterPost2(){
        CaseChatterPoster_Test.createData();
        Test.StartTest();
            //Notification for closed cases
            list<case> lstISRupdatedcases =new list<Case>();
            
            for(case c: lstParentCse){
                //c.ownerid =UserDataGeneratorHelper_Test.MSLCustomerServiceUser.id; 
                c.Status ='Closed - Resolved';
                c.Resolution_Summary__c ='Test Resolution Summary';   
                lstISRupdatedcases.add(c);  
            } 
            update lstISRupdatedcases;
            
            system.debug(Logginglevel.DEBUG, LOGMARK+'lstISRupdatedcases'+lstISRupdatedcases);
            
            map<Id, Case> mapClosedCases = new map<id,case>();
            
            for(case cs :lstISRupdatedcases )
            {
                mapClosedCases.put(cs.id,cs) ;
            }
            system.debug(Logginglevel.DEBUG, LOGMARK+'**mapClosedCases**'+mapClosedCases);
            list<feeditem> FIList_CaseClosure = [Select Id,ParentId,Body FROM feeditem WHERE ParentId  IN: mapClosedCases.keyset()];
            Case Case_CaseClosure = [SELECT Id,CaseNumber from Case where id=:FIList_CaseClosure[0].parentId];
            system.assertEquals(FIList_CaseClosure[0].body,'Case Number : '+Case_CaseClosure .CaseNumber+' has been closed.');
        Test.StopTest();
    }
    
    @isTest
    static void testcloneRecord()
    {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        List<Case> lstCases = new List<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Test.startTest();
        lstCases[0].Description = 'Cloned';
        lstCases[0].IsCloned__c = true;
        lstCases[1].Description = 'Parent';
        lstCases[0].Product__c = 'Ocean';
        lstCases[1].Product__c = 'Ocean';
        insert lstCases;
        List<Case> listCases =[SELECT Id, Description,ParentId,RecordtypeId FROM Case LIMIT 2];
        listCases[0].ParentId = listCases[1].Id; 
        Update listCases; 
         
        Test.stopTest();
    }
}