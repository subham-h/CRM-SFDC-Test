global class TargetSettingPipelineDataSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      TargetSettingPipelineDataBatch b = new TargetSettingPipelineDataBatch(); 
      Database.executeBatch(b);
   }
}