/*
* Author    : Arpitha J
* Description   : Scheduler class for TargetSettingBaseDataBatch
*       : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                              Arpitha@maersk           Created. 
* 
*/

global class TargetSettingBaseDataBatchSchedule implements Schedulable {
   public string targetId; 
   public string measureDimension;
   public string corelationId;
   public string stagingStatus;
   
   global TargetSettingBaseDataBatchSchedule(String targetId,String measureDimension,String corelationId, String stagingStatus){
       this.targetId = targetId;
       this.measureDimension = measureDimension;
       this.corelationId = corelationId;
       this.stagingStatus=stagingStatus;
   }
   global void execute(SchedulableContext sc) {
      TargetSettingBaseDataBatch b = new TargetSettingBaseDataBatch(this.targetId,this.measureDimension,this.corelationId,this.stagingStatus); 
      Database.executeBatch(b);
   }
}