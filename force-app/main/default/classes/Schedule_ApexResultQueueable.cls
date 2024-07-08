/* Email result queable class
 */
public class Schedule_ApexResultQueueable implements Queueable, Database.AllowsCallouts {
    
    public String strScheduledJobId;
    public String strResultEmailBody;
    public static Integer percentageCovered;
    public OrgPercentageCoverageWrapper orgwrapper;
    public ApexPercentageConverageWrapper apexwrapper;
    private Decimal converagePercentage;
    private String classOrTriggerName;
    @testvisible
    private Map<String,Decimal> percenCoveragemap;
    public List<String> exclusionList;
    
    /* Execute method 
     */
    public void execute(QueueableContext context) {
        
        exclusionList = new List<String>();
        exclusionList.add('Schedule_MyNameSpaceApexTestResult');
        exclusionList.add('Schedule_MyNameSpaceApexTestExecution');
        exclusionList.add('OrgPercentageCoverageWrapper');
        exclusionList.add('ApexPercentageConverageWrapper');
        exclusionList.add('Schedule_ApexResultQueueable');
        exclusionList.add('PercentageCoverageMapValueSort');
        
        List<My_Namespace_RunAllTest_Setting__c> lstMyNameSpaceRunAllTestSetting = [SELECT Id, Name, QueueItem_IdList__c, Recipient_Email_Address__c 
                                                                                    FROM My_Namespace_RunAllTest_Setting__c 
                                                                                    WHERE Name = 'shipping_org' Limit 1]; 
        
        // config is set correctely and Queue Item Ids are not null then progress
        if (lstMyNameSpaceRunAllTestSetting.size() > 0 
            && lstMyNameSpaceRunAllTestSetting[0].QueueItem_IdList__c != null
            && lstMyNameSpaceRunAllTestSetting[0].Recipient_Email_Address__c != null){
                
                String strQueueItemIds = lstMyNameSpaceRunAllTestSetting[0].QueueItem_IdList__c;
                String strRecipientEmailAddress = lstMyNameSpaceRunAllTestSetting[0].Recipient_Email_Address__c;
                Set<String> setQueuItemId = new Set<String>();
                String strEnvName = UserInfo.getUserName().substringAfterLast('.'); 
                Boolean blnScheduleTestClassesRunCompleted = true;
                
                for (String s : strQueueItemIds.split(',')){
                    setQueuItemId.add(s);
                }
                
                Integer intClassesCompleted = 0;
                Integer intMethodsCompleted = 0;
                Integer intMethodsFailed = 0;
                List<ApexTestRunResult> lstApexTestRunResult = [SELECT Id, AsyncApexJobId, ClassesCompleted, ClassesEnqueued, MethodsCompleted, MethodsEnqueued, MethodsFailed, StartTime, Status, TestTime 
                                                                FROM ApexTestRunResult WHERE AsyncApexJobId in :setQueuItemId ];
                 if(Test.isRunningTest()){
                    
                    time timenow =Time.newInstance(18, 30, 2, 20);
                    Integer starttime = 22;
                    DateTime timetest = DateTime.newInstance(date.today(), timenow);
                    lstApexTestRunResult.add(new ApexTestRunResult(Id='05m3N000000B8HRQA0', AsyncApexJobId='7073N00001VLfgHQAT', ClassesCompleted=1, ClassesEnqueued=1, MethodsCompleted=1, MethodsEnqueued=1, MethodsFailed=0, StartTime=timetest, Status='Completed', TestTime=starttime));
                }
                for (ApexTestRunResult atr : lstApexTestRunResult){
                    blnScheduleTestClassesRunCompleted = (atr.Status != 'Completed') ? false : blnScheduleTestClassesRunCompleted;
                    intClassesCompleted += atr.ClassesCompleted;
                    intMethodsCompleted += atr.MethodsCompleted;
                    intMethodsFailed += atr.MethodsFailed; 
                }
                
                if (blnScheduleTestClassesRunCompleted) {
                    
                    // get org coverage
                    HttpRequest req = new HttpRequest();
                    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint(URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v41.0/tooling/query/?q=Select+PercentCovered+from+ApexOrgWideCoverage');
                    req.setMethod('GET');
                    Http h = new Http();
                    HttpResponse res = h.send(req);
                    
                    If(res !=null){
                        Orgwrapper = (OrgPercentageCoverageWrapper) JSON.deserializeStrict(res.getBody(), OrgPercentageCoverageWrapper.class);  
                    }
                    if(Orgwrapper !=null){
                        percentageCovered = Orgwrapper.records[0].PercentCovered; 
                    }
                    
                    HttpRequest req1 = new HttpRequest();
                    req1.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                    req1.setHeader('Content-Type', 'application/json');
                    General_Key_Value_Configurations__mdt thisMetadata= General_Key_Value_Configurations__mdt.getInstance('ApexSmokeTestSuiteClasses');
    				String apexClassNames;
       				if(thisMetadata!= null){
                    	apexClassNames = thisMetadata.First_Field_Value__c;

    				}
                    
                    req1.setEndpoint(URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v41.0/tooling/query/?q=Select+id,ApexClassorTrigger.Name,NumLinesCovered,NumLinesUncovered+from+ApexCodeCoverageAggregate+where+ApexClassorTrigger.Name+IN+('+apexClassNames+')');
                    //req1.setEndpoint(URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v41.0/tooling/query/?q=Select+id,ApexClassorTrigger.Name,NumLinesCovered,NumLinesUncovered+from+ApexCodeCoverageAggregate');+                    req1.setMethod('GET');
                    req1.setMethod('GET');
                    Http h1 = new Http();
                    HttpResponse res1 = h1.send(req1);
                    apexwrapper = (ApexPercentageConverageWrapper) JSON.deserializeStrict(res1.getBody(), ApexPercentageConverageWrapper.class);
                    percenCoveragemap = new Map<String,Decimal>();
                    
                    Decimal totallines = 0;
                    converagePercentage = 0;
                    for(ApexPercentageConverageWrapper.records a:apexwrapper.records){
                        if(a.ApexClassOrTrigger !=null) {
                            totallines = a.NumLinesCovered + a.NumLinesUncovered;
                            if(totallines !=0){
                                converagePercentage = ((a.NumLinesCovered/totallines)*100).setScale(2);
                                if(converagePercentage < 78){
                                    classOrTriggerName = a.ApexClassOrTrigger.Name;
                                    if(!exclusionList.contains(classOrTriggerName)){
                                        percenCoveragemap.put(classOrTriggerName,converagePercentage);  
                                    } 
                                }
                            }
                        }
                    }
                    
                    List<String> lstToAddresses = new List<String>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String strEmailSubject = strEnvName + ' run all test result on ' + String.valueOf(Date.today());
                    
                    
                    if (strRecipientEmailAddress.contains(',')){
                        for (String rea : strRecipientEmailAddress.split(',')){
                            lstToAddresses.add(rea);
                        }
                    } else {
                        lstToAddresses.add(strRecipientEmailAddress);
                    }
                    
                    mail.setToAddresses(lstToAddresses);
                    mail.setSubject(strEmailSubject);
                    
                    List<ApexTestResult> lstResultApexTests = [SELECT Outcome, MethodName, Message, StackTrace, AsyncApexJobId, 
                                                               ApexClass.Name, ApexClass.LengthWithoutComments, ApexClass.NamespacePrefix, ApexClass.Status,
                                                               ApexLogId, ApexLog.Status, ApexClass.LastModifiedById
                                                               FROM ApexTestResult
                                                               WHERE AsyncApexJobId in :setQueuItemId
                                                               ORDER BY ApexClass.Name, MethodName];
                    
                   
                     if(Test.isRunningTest())
                    {
                        percenCoveragemap = new Map<String,Decimal> ();
                        percenCoveragemap.put('EmailSendingtoBA',24.5);  
                        lstresultApexTests.add(new ApexTestResult(Outcome='Fail', MethodName='testEmailSendingtoBA', AsyncApexJobId='7073N00001VLfgHQAT', ApexClassId='01p3N000008NeP0QAK', ApexLogId='07L3N00000BKbfjUAD', Id='07M3N000009iIk6UAE'));
                    }
                        strResultEmailBody = getHTMLResultBody(lstResultApexTests, intClassesCompleted, intMethodsCompleted, intMethodsFailed, strEnvName,percenCoveragemap); 
                        mail.setHtmlBody(strResultEmailBody);
                    
                    if(strResultEmailBody!=null)
                        Messaging.sendEmail(new Messaging.Email[] {mail});
                    
                    //reset custom setting so that email is not sent again
                    List<My_Namespace_RunAllTest_Setting__c> lstMyNameSpaceRunAllTestSettingToUpdate = new List<My_Namespace_RunAllTest_Setting__c>();
                    for (My_NameSpace_RunAllTest_Setting__c r : lstMyNameSpaceRunAllTestSetting){
                        
                        r.QueueItem_IdList__c = '';
                        lstMyNameSpaceRunAllTestSettingToUpdate.add(r);
                    }
                    
                    if (lstMyNameSpaceRunAllTestSettingToUpdate.size() > 0 ){
                        update lstMyNameSpaceRunAllTestSettingToUpdate;
                    }
                } else {
                    system.debug(LoggingLevel.WARN,' My namespace run all test is not completed yet');
                }
            } else {
                system.debug(LoggingLevel.WARN,'My namespace run all test config is not set correctly OR Queue Item Id field is blank');
            }
    }
    /*getHtml body method
     */
    @testvisible
    private static String getHTMLResultBody(List<ApexTestResult> atresult, Integer intClassesCompleted, Integer intMethodsCompleted, Integer intMethodsFailed, String strEnvName,Map<String,Decimal> percenCoveragemap){
        
        List<ApexTestResult> lstFailedTestResult = new List<ApexTestResult>();
        String strResultBodyText = '';
        
        for (ApexTestResult ar : atresult){
            if (!ar.Outcome.equalsIgnoreCase('Pass')){
                lstFailedTestResult.add(ar);
            }
        }
        
        strResultBodyText += 'A test run has completed for <b>' + strEnvName + '</b> environment. </br>';
        strResultBodyText += 'Total Org Coverage: ' + percentageCovered + '%'+ '<br>';
        strResultBodyText += 'Total Tests: ' + intClassesCompleted + '<br>';
        strResultBodyText += 'Total Unit Tests: ' + intMethodsCompleted + '<br>';
        strResultBodyText += 'Total Unit Tests Failed: ' + intMethodsFailed + '<br></br>';
        
        strResultBodyText += 'Failed Unit tests details are - <br>';
        strResultBodyText += '<table border="1" style="border:1px solid black;border-collapse:collapse;"> ';
        strResultBodyText += '<tr style="background-color:#D0D0D0;margin:0;border:0;padding:0;">';
        strResultBodyText += '<th width="22%">Class Name</th>';
        strResultBodyText += '<th width="23%">Unit Test</th>';
        strResultBodyText += '<th width="55%">Message</th>';
        strResultBodyText += '</tr>';
        
        if(lstFailedTestResult.size()>0 && !lstFailedTestResult.isEmpty()){
            for (ApexTestResult r : lstFailedTestResult){
                
                strResultBodyText += '<tr><td>' + r.ApexClass.Name + '</td>';
                strResultBodyText += '<td>' + r.MethodName + '</td>';
                strResultBodyText += '<td>' + r.Message + '</td>';
            }
        
        
        strResultBodyText += '</tr></table><br><br>';
        
        strResultBodyText += 'List of Apex Class/Trigger with less than 78% code coverage <br>';
        strResultBodyText += '<table border="1" style="width:50%;border:1px solid black;border-collapse:collapse;"> ';
        strResultBodyText += '<tr style="background-color:#D0D0D0;margin:0;border:0;padding:0;">';
        strResultBodyText += '<th width="10%">Type</th>';
        strResultBodyText += '<th width="22%">Name</th>';
        strResultBodyText += '<th width="2%">Code Coverage %</th>';
        strResultBodyText += '<th width="22%">Created Date</th>';
        
        strResultBodyText += '</tr>';
        
        PercentageCoverageMapValueSort[] addressList = new PercentageCoverageMapValueSort[0];
        for(String key: percenCoveragemap.keyset()) {
            addressList.add(new PercentageCoverageMapValueSort(key, percenCoveragemap.get(key)));
        }
        addressList.sort();
        
        Map<String,String> classNameMap = new Map<String,String>();
        Map<String,Datetime> classCreatedDateMap = new Map<String,Datetime>();
        Map<String,String> TriggerNameMap = new Map<String,String>();
        Map<String,Datetime> triggerCreatedDateMap = new Map<String,Datetime>();
        List<ApexClass> className = new List<ApexClass>();
        List<ApexTrigger> triggerName = new List<ApexTrigger>();
        className = [select CreatedDate,Name from ApexClass where Name =:percenCoveragemap.keyset() AND NamespacePrefix = null];
        triggerName = [select CreatedDate,Name from ApexTrigger where Name =:percenCoveragemap.keyset() AND NamespacePrefix = null];
        if(!className.isEmpty()){
            for(ApexClass a: className){
                classNameMap.put(a.Name,'Apex Class');
                classCreatedDateMap.put(a.Name,a.CreatedDate);
            }
        }
        
        if(!triggerName.isEmpty()){
            for(ApexTrigger at: triggerName){
                TriggerNameMap.put(at.Name,'Apex Trigger');
                triggerCreatedDateMap.put(at.Name,at.CreatedDate);
            }
        }
        
        If(percenCoveragemap !=null && !percenCoveragemap.isEmpty()){
            for(PercentageCoverageMapValueSort p: addressList){
                if(classNameMap.containskey(p.className)){
                    strResultBodyText += '<tr><td>' + classNameMap.get(p.className) + '</td>';    
                }
                if(TriggerNameMap.containskey(p.className)){
                    strResultBodyText += '<tr><td>' + TriggerNameMap.get(p.className) + '</td>';    
                }
                strResultBodyText += '<td>' + p.className + '</td>';
                strResultBodyText += '<td>' + p.d + '%'+'</td>';
                if(classCreatedDateMap.containskey(p.className)){
                    strResultBodyText += '<td>' + classCreatedDateMap.get(p.className) + '</td>';    
                }
                if(triggerCreatedDateMap.containskey(p.className)){
                    strResultBodyText += '<td>' + triggerCreatedDateMap.get(p.className) + '</td>';    
                }
            }
        }
        strResultBodyText += '</tr></table><br><br>';
        
        return strResultBodyText;
        }return null;
    }
    
}