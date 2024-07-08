/*
* @Name: Schedule_MyNameSpaceApexTestExecution
* @Description: Scheduler Class to schedule My name space apex test execution. 
*
* Version  Date         Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      14/12/2017   nitin.v.more@maersk.com                  RQ-007553     Created Class
* 2.0      14/07/2022   Vivek.agrawal@maersk.com                 SC-5391       Modified  Class
*/
global class Schedule_MyNameSpaceApexTestExecution implements Schedulable {
  
  	public String strScheduledJobId;
    public String strScheduleName = 'My namespace run all apex test execution'+ Date.today();
    public String strCRON;
    //public String strCRON =  '0 ' + minute + '* * * * ?';
    
	/* schedule method 
	 */
    global void createSchedule() {
        
    	General_Key_Value_Configurations__mdt thisMetadata= General_Key_Value_Configurations__mdt.getInstance('SmokeTestClassRunFrequency');

        strCRON =  thisMetadata.First_Field_Value__c;
        
        this.strScheduledJobId = system.schedule(this.strScheduleName, this.strCRON, this);
    }

    /*Execute method for scheduling test classes run
     */
    global void execute(SchedulableContext SC) {
      
      	Integer intCountTestClass = 0;
        List<My_Namespace_RunAllTest_Setting__c> lstRSToUpdate = new List<My_Namespace_RunAllTest_Setting__c>();
    	String strTestQueueItemParentIds = '';
        Set<String> testQueuItemParentIdSet = new Set<String>();
    	List<ApexTestQueueItem> previousQueueitems = new  List<ApexTestQueueItem>();
        List<My_Namespace_RunAllTest_Setting__c> lstMyNameSpaceRunAllTestSetting = [SELECT Id, Name, QueueItem_IdList__c FROM My_Namespace_RunAllTest_Setting__c WHERE Name = 'shipping_org' Limit 1];
    
    //System.debug('# lstMyNameSpaceRunAllTestSetting: '+ lstMyNameSpaceRunAllTestSetting);
    
    if (lstMyNameSpaceRunAllTestSetting.size() > 0){
    
      strTestQueueItemParentIds = (lstMyNameSpaceRunAllTestSetting[0].QueueItem_IdList__c != null)? lstMyNameSpaceRunAllTestSetting[0].QueueItem_IdList__c : strTestQueueItemParentIds;
      Boolean blnScheduleTestClasses = false;
      
      if ( strTestQueueItemParentIds != null && strTestQueueItemParentIds.length() > 0){
  
        for (String s : strTestQueueItemParentIds.split(',')){
                testQueuItemParentIdSet.add(s);
        }
        
        previousQueueitems = [SELECT Id, ParentJobId, Status 
                     FROM ApexTestQueueItem 
                     WHERE ParentJobId in :testQueuItemParentIdSet 
                     AND Status in ('Processing','Queued')];
        
        blnScheduleTestClasses = (previousQueueitems.size() <= 0) ? true : blnScheduleTestClasses;  
        
      } else {
        // it means testQueueItemParentIds is blank
        blnScheduleTestClasses = true;
      }
      
      //System.debug('# blnScheduleTestClasses: '+ blnScheduleTestClasses);
     Map<String,ApexSmokeTestSuiteClasses__mdt> metadataList = ApexSmokeTestSuiteClasses__mdt.getAll();
	 List<String> testClasses = new List<String>();
	 testClasses.addAll(metadataList.keySet());
  
      if (blnScheduleTestClasses == true){
        List<ApexClass> lstTestClasses =  [SELECT Id, Name, Body, IsValid, NamespacePrefix, Status 	
                                             FROM ApexClass 	
                                            WHERE NamespacePrefix = null AND Status = 'Active' AND Name IN : testClasses//('CTMModuleTest','ClaimRecoveryModuleTest','ClaimsForLNSTest','ClaimsForOceanModuleTest','ISRCaseModuleTest','ServiceCallTest')//,'ProActiveEmailTemplateTest','EmailToCaseModuleTest','MaerskIdeaTest')	
                                             ORDER BY Name ASC NULLS FIRST ];
  
        // schedule test classes
        if (lstTestClasses.size() > 0) {
      
          List<ApexTestQueueItem> lstQueueItems = new List<ApexTestQueueItem>();
          List<ApexTestQueueItem> lstQueueItemsToInsert; 
          List<ApexTestQueueItem> lstQueueItemsInserted = new List<ApexTestQueueItem>();
            for (ApexClass cls : lstTestClasses) {
                boolean blnResult; 
                string strBody = cls.Body.toLowerCase();
  
                blnResult = (strBody.contains('@istest') || strBody.contains('testmethod')) ? true : false;
            
            if ( blnResult == true){
                    intCountTestClass = intCountTestClass + 1;
                      lstQueueItems.add(new ApexTestQueueItem(ApexClassId=cls.Id));
                    }
            }
        
  
          if (lstQueueItems.size() > 0) {
          
            //System.debug(' lstQueueItems size#:' + lstQueueItems.size());
  
            Integer i = 0;
        
            for(ApexTestQueueItem qi : lstQueueItems){
              
              if (i==0){lstQueueItemsToInsert = new List<ApexTestQueueItem>();}
              
              if (i<200){
                lstQueueItemsToInsert.add(qi);
                i += 1;
              }
              
              if (i==200){
                insert lstQueueItemsToInsert;
                i=0;
                lstQueueItemsInserted.addall(lstQueueItemsToInsert);
              }
            }
        
            // we are outside of loop and count is between 0 and 200 it means we have some apex test execution needs queueing 
            if (i>0 && i<200){
            if(!Test.isRunningTest()){	
              insert lstQueueItemsToInsert;
              lstQueueItemsInserted.addall(lstQueueItemsToInsert);
        	 }
          }
          }
          // get Parent Job Id and save in custom settings
          AggregateResult[] groupedItemsResults = [SELECT ParentJobId, Count(Id) FROM ApexTestQueueItem 
                                WHERE Id in :lstQueueItemsInserted
                                GROUP BY ParentJobId
                                ORDER BY ParentJobId];
          String strQueueItemParentIds = '';    

          for (AggregateResult ar : groupedItemsResults){
            strQueueItemParentIds += ar.get('ParentJobId') + ',' ;
          } 
       

          // update custom setting with queue item parent job id
          if ( strQueueItemParentIds.length() > 1 && strQueueItemParentIds.endsWith(',')){
                  strQueueItemParentIds = strQueueItemParentIds.substring(0, strQueueItemParentIds.length() - 1);
  
                  for (My_Namespace_RunAllTest_Setting__c r : lstMyNameSpaceRunAllTestSetting){
                      r.QueueItem_IdList__c = strQueueItemParentIds;
                      lstRSToUpdate.add(r);
                  }
  
                  update lstRSToUpdate;
          }
  
          system.debug(LoggingLevel.WARN,' total test classes scheduled are:' + intCountTestClass);
        }
      }
    }
    }
}