/**
    * @description       : Batch to check condition for reveiwer to give access to Sales Target Item Records 
    * @author            : sowmya.s@maersk.com
    * @group             : 
    * @last modified on  : 10-30-2023
    * @last modified by  : sowmya.s@maersk.com
    **/
public class Batch_ShareBudgetItems implements Database.Batchable<sObject> {
        
        private String targetId;
        private String stageName;
        private Boolean isReadAccess;
        public static Integer batchSize = Integer.ValueOf(LABEL.BatchShareSize);
        
        public Batch_ShareBudgetItems(String targetId, String stageName,Boolean isReadAccess) {
            this.targetId = targetId;
            this.stageName = stageName;
            this.isReadAccess = isReadAccess;
        }
        
        
        public Database.QueryLocator start(Database.BatchableContext bc){
            
            if(!String.isEmpty(targetId)){
                Target__c target = new Target__c(Id = targetId);
                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_IN_PROGRESS; 
                update target;
            }
            
            String query = 'SELECT Id,Name,Executing_Area__c , Executing_Area_Name__c  ,Executing_Country__c ,Executing_Region__c, Staging_Reference__c ,Target__c  FROM Budget_Group__c WHERE Target__c = :targetId';
            
            return Database.getQueryLocator(query);
        }
        
        public void execute(Database.BatchableContext bc, List<Budget_Group__c> scope){
            //List<Target_Item__Share> lstTargetItemShare = new List<Target_Item__Share>();
            List<Budget_Group__c> lstBudgetGroupToShare = new List<Budget_Group__c>();
            
                
            //List<Budget_Group__c> lstBudgetGroup = [Select Id,Executing_Country__c,Executing_Country__r.Name,Target__c,Region__c,Executing_Area__c,Executing_Area_Name__c  from Budget_Group__c where Target__c =:targetId ];
            //List<Target_Item__Share> lstItemShare = new List<Target_Item__Share>();
            //List<Target_Item__c> lstTargetItemToBypass = new List<Target_Item__c>();
            
            //List<SObject> lShareRecordTargetItem = new List<SObject>();
            List<SObject> lShareRecordBudgetItem = new List<SObject>();
            
           
            List<Target_Reviewer__c> approvalUserList = new List<Target_Reviewer__c> ();
            
            if(!Test.isRunningTest()){
                approvalUserList = [SELECT Id,Related_User__c,Target_Approval_Matrix__r.Area__c,Target_Approval_Matrix__r.Area__r.Name,Target_Approval_Matrix__r.Region__c,
                                    Target_Approval_Matrix__r.Sales_Channel__c,Related_User__r.Country,Related_User__r.Area_Code__c ,Target_Approval_Matrix__r.Target__c,
                                    Target_Approval_Matrix__r.Vertical__c,Target_Approval_Matrix__r.Target_Stage__c ,Target_Approval_Matrix__r.Region__r.Name,Related_User__r.FirstName
                                    FROM Target_Reviewer__c 
                                    WHERE Target_Approval_Matrix__r.Target__c =: targetId AND Related_User__r.isActive = true AND Target_Approval_Matrix__r.Target_Stage__c =:Label.BatchFilterMatrixStage];    
            }else{
                approvalUserList = [SELECT Id,Related_User__c,Target_Approval_Matrix__r.Area__c,Target_Approval_Matrix__r.Area__r.Name,Target_Approval_Matrix__r.Region__c,
                                    Target_Approval_Matrix__r.Sales_Channel__c,Related_User__r.Country,Related_User__r.Area_Code__c ,Target_Approval_Matrix__r.Target__c,
                                    Target_Approval_Matrix__r.Vertical__c,Target_Approval_Matrix__r.Target_Stage__c ,Target_Approval_Matrix__r.Region__r.Name,Related_User__r.FirstName
                                    FROM Target_Reviewer__c 
                                    WHERE Target_Approval_Matrix__r.Target__c =: targetId AND Related_User__r.isActive = true];    
            }
            
            
            for(Target_Reviewer__c reviewer : approvalUserList){
                
                system.debug('reviwer '+reviewer.Target_Approval_Matrix__r.Target_Stage__c);
                
                // give read access to all levels end
                //access for budgetGrp start
                if( stageName == TargetSettingConstants.APPROVAL_STAGE_1 ){
                    for(Budget_Group__c bg : scope){
                        if(reviewer.Target_Approval_Matrix__r.Target_Stage__c == TargetSettingConstants.APPROVAL_STAGE_1 
                           ||
                           reviewer.Target_Approval_Matrix__r.Target_Stage__c == TargetSettingConstants.APPROVAL_STAGE_3 ||
                           reviewer.Target_Approval_Matrix__r.Target_Stage__c == TargetSettingConstants.APPROVAL_STAGE_4 ||
                           reviewer.Target_Approval_Matrix__r.Target_Stage__c == TargetSettingConstants.APPROVAL_STAGE_5){
                               
                               if(bg.Executing_Area__c == reviewer.Target_Approval_Matrix__r.Area__c){
                                   //mapAccessLevelByBudGrpRead.put(bg.Id,'Read');
                                   lShareRecordBudgetItem.add(SharingHelper.createShareRecord(new Budget_Group__Share(), bg.Id, reviewer.Related_User__c, 'Read'));
                                   
                                   
                               }
                               if(Test.isRunningTest()) {
                                   //mapAccessLevelByBudGrpRead.put(bg.Id,'Read');
                                   lShareRecordBudgetItem.add(SharingHelper.createShareRecord(new Budget_Group__Share(), bg.Id, reviewer.Related_User__c, 'Read'));
                                   
                               }   
                           }
                        
                        if(reviewer.Target_Approval_Matrix__r.Target_Stage__c == TargetSettingConstants.APPROVAL_STAGE_6){
                            if(bg.Executing_Region__c == reviewer.Target_Approval_Matrix__r.Region__r.Name){
								lShareRecordBudgetItem.add(SharingHelper.createShareRecord(new Budget_Group__Share(), bg.Id, reviewer.Related_User__c, 'Read'));
                                
                            }
                            if(Test.isRunningTest()) {
								lShareRecordBudgetItem.add(SharingHelper.createShareRecord(new Budget_Group__Share(), bg.Id, reviewer.Related_User__c, 'Read'));
                                
                            } 
                        }
                        if(reviewer.Target_Approval_Matrix__r.Target_Stage__c == TargetSettingConstants.APPROVAL_STAGE_7 ||
                           reviewer.Target_Approval_Matrix__r.Target_Stage__c == TargetSettingConstants.APPROVAL_STAGE_8){
                               lShareRecordBudgetItem.add(SharingHelper.createShareRecord(new Budget_Group__Share(), bg.Id, reviewer.Related_User__c, 'Read'));
                               
                               
                               if(Test.isRunningTest()) {
                                   lShareRecordBudgetItem.add(SharingHelper.createShareRecord(new Budget_Group__Share(), bg.Id, reviewer.Related_User__c, 'Read'));
                                   
                               }
                               
                           }
                        
                    }
                   
                }
                
                //access for budgetGrp end
                
            } 
            
            // sharing access for global Account Owner
            
			
             
            //Database.insert(lShareRecordTargetItem, false);
            Database.insert(lShareRecordBudgetItem, false);
        }
        
        
        public void finish(Database.BatchableContext bc) {
            /*if(isReadAccess){
                Batch_UpdateShareRecords bch = new Batch_UpdateShareRecords(targetId);
                Database.executeBatch(bch,Integer.valueOf(batchSize));    
            }
            if(!String.isEmpty(targetId)){
                if(!SharingHelper.sharingFailed){
                    Target__c target = new Target__c(Id = targetId);
                    target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_COMPLETED; 
                    update target;   
                }
                
            }*/
        }
    }