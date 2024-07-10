/*
* @Name: Schedule_MyNameSpaceApexTestResult
* @description: Scheduler Class to schedule My name space apex test execution result email. 
*
* Version  Date         Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      14/12/2017   nitin.v.more@maersk.com                  RQ-007553     	Created Class
* 1.1      28/08/2019   Sidhartha Mohapatra                               	    Amended to add org code coverage
* 1.2      25/04/2022	VIVEK AGRAWAL											Ameded the code to use it for Apex smoke suite
*/
global class Schedule_MyNameSpaceApexTestResult implements Schedulable, Database.AllowsCallouts {
    
    public String strScheduledJobId;
    public String strScheduleName = 'My namespace run all test apex execution - result email' + Date.today();
    
    public String strCRON ;

    public static Integer percentageCovered;
    public Decimal converagePercentage;
    public String classOrTriggerName;
    @testvisible
    private Map<String,Decimal> percenCoveragemap;
    public List<String> exclusionList;
    
    /*
     * @description Schedule method to run on a schedule
     */
    global void createSchedule() {
        
		
    	General_Key_Value_Configurations__mdt thisMetadata= General_Key_Value_Configurations__mdt.getInstance('SmokeTestClassEmailFrequency');
       		
    	strCRON=thisMetadata.First_Field_Value__c;   
       
        this.strScheduledJobId = system.schedule(this.strScheduleName, this.strCRON, this);
    }
    /*
     * @description Execute method
     */ 
    global void execute(SchedulableContext sc) {
        
        	System.enqueueJob(new Schedule_ApexResultQueueable());
        
    }
}