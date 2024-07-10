/**
 * Version     RQ           Date             Dev          Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------
 * 1.0     SFSE-13391    17-May-2024    Shashi@Maersk     Scheduler for LockOpportunitiesBatch
 */

global class LockOpportunitiesBatchScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
      LockOpportunitiesBatch b = new LockOpportunitiesBatch(); 
      database.executebatch(b, 200);
    }
}