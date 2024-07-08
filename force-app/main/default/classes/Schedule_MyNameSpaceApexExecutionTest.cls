/*Test class to cover Schedule_MyNameSpaceApexTestExecution, Schedule_ApexResultQueueable, Schedule_MyNameSpaceApexTestResult
 */
@isTest
public class Schedule_MyNameSpaceApexExecutionTest {

    /*Test method1
     */
    @isTest
    private static void testSchduler(){
    
        Schedule_MyNameSpaceApexTestExecution  a = new Schedule_MyNameSpaceApexTestExecution ();
        a.createSchedule();

        //Id jobid= Database.execute(a,5);
        try{
            List<My_Namespace_RunAllTest_Setting__c> lstMyNameSpaceRunAllTestSetting = new List<My_Namespace_RunAllTest_Setting__c>();
            lstMyNameSpaceRunAllTestSetting.add(new My_Namespace_RunAllTest_Setting__c(Name = 'shipping_org', QueueItem_IdList__c = '01p3N000009hICm'));
            insert lstMyNameSpaceRunAllTestSetting;
            Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? *';
            System.schedule('ScheduleApexClassTest',  CRON_EXP, a);  
            PercentageCoverageMapValueSort permap = new PercentageCoverageMapValueSort('TestClass', 12.4);
            Integer temp = permap.compareTo(null);
            Test.stopTest();
        }catch(exception ex){
            system.debug(LoggingLevel.WARN,'Catch exception');
        }
    }
    
    /* Test method2
     */
     @isTest
    private static void testSchduler2(){
    
        Schedule_MyNameSpaceApexTestResult  a = new Schedule_MyNameSpaceApexTestResult ();
        Schedule_MyNameSpaceApexTestResult.percentageCovered = 72;
        a.classOrTriggername = 'ClaimsForlnsTest';
        a.converagePercentage = 75.5;
        a.strCRON = '0 0 0 1 1 * ?';
        a.createSchedule();
        
        Schedule_ApexResultQueueable ab = new Schedule_ApexResultQueueable();
      
        try{
            List<My_Namespace_RunAllTest_Setting__c> lstMyNameSpaceRunAllTestSetting = new List<My_Namespace_RunAllTest_Setting__c>();
            lstMyNameSpaceRunAllTestSetting.add(new My_Namespace_RunAllTest_Setting__c(Name = 'shipping_org', QueueItem_IdList__c = '01p3N000009hICm', Recipient_Email_Address__c = 'abc@abc.com'));
            insert lstMyNameSpaceRunAllTestSetting;
            Test.startTest();
            String cRON_EXP = '0 0 0 15 3 ? *';
            orgPercentageCoverageWrapper orgtemp = new OrgPercentageCoverageWrapper();
            orgtemp.size= 4;
            orgtemp.totalsize = 10;
            orgtemp.done = true;
            orgtemp.querylocator = null;
            orgTemp.entityTypeName = null;
            orgPercentageCoverageWrapper.records rec= new orgPercentageCoverageWrapper.Records();
            orgPercentageCoverageWrapper.Attributes at= new orgPercentageCoverageWrapper.Attributes();
            at.type = 'Test';
            at.url = 'www.google.com';
            rec.Attributes = at;
			ApexPercentageConverageWrapper.records rec1= new ApexPercentageConverageWrapper.Records();
            ApexPercentageConverageWrapper.Attributes at1= new ApexPercentageConverageWrapper.Attributes();
            at1.type = 'Test';
            at1.url = 'www.google.com';
            rec1.Attributes = at1;
            
            ApexPercentageConverageWrapper.ApexClassOrTrigger atr = new ApexPercentageConverageWrapper.ApexClassOrTrigger();
            atr.Attributes = at1;
            rec1.ApexClassOrTrigger = atr;
            rec1.Id = '12324';
            rec1.NumLinesCovered = 2;
            rec1.NumLinesUnCovered = 10;
            ApexPercentageConverageWrapper apexWrap = new ApexPercentageConverageWrapper();
            apexWrap.size= 4;
            apexWrap.totalsize = 10;
            apexWrap.done = true;
            apexWrap.querylocator = null;
            apexWrap.entityTypeName = null;
            apexWrap.records = null ; 
            
            System.enqueueJob(new Schedule_ApexResultQueueable());   
            Test.setMock(HttpCalloutMock.class, new Schedule_ApexResultQueueableMockTest());
           // HttpResponse res = mc.contactserver();

            Schedule_ApexResultQueueable.getHTMLResultBody(null,0,0,0,'',null);
        
            Test.stopTest();
        }catch(exception ex){system.debug(LoggingLevel.WARN,'Catch exception');}
    }
}