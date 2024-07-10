/*  
* Version	Date			#Reference				Owner					Description
* --------	-----------		-------------------		-----------				---------------
* 1.0		09-Jan-2024								Sowmya@maersk			
*/

public class Batch_ShareRecordsTempV2 implements Database.Batchable<sObject> {
    
    private String targetId;
    private Boolean isReadAccess;
    private String stageName;
    public Set<Id> reviewers;
    private Map<String, Set<Id>> mapUserIdByApprovalKey;
    Map<String,Integer> mapStageNumber = new Map<String,Integer>{TargetSettingConstants.APPROVAL_STAGE_1 => 1,
        														TargetSettingConstants.APPROVAL_STAGE_2 => 2,
        														TargetSettingConstants.APPROVAL_STAGE_3 => 3,
        														TargetSettingConstants.APPROVAL_STAGE_4 => 4,
        														TargetSettingConstants.APPROVAL_STAGE_5 => 5,
        														TargetSettingConstants.APPROVAL_STAGE_6 => 6,
        														TargetSettingConstants.APPROVAL_STAGE_7 => 7,
        														TargetSettingConstants.APPROVAL_STAGE_8 => 8};
    public static Integer batchSize = Integer.ValueOf(LABEL.BatchShareSize);
    public String whereClause;
    
    public Batch_ShareRecordsTempV2(String targetId, String whereClause,Set<Id> reviewers) {
        this.reviewers = reviewers;
        this.targetId = targetId;
        this.mapUserIdByApprovalKey = getMapUserIdByApprovalKey(targetId);
        this.whereClause = whereClause;
    }
    
    public static Map<String, Set<Id>> getMapUserIdByApprovalKey(String targetId){
        
        Map<String, Set<Id>> mapUserIdByApprovalKey = new Map<String, Set<Id>>();
        String uniqueKey;
        
        // create map of reviewers based on Condition
        for (Target_Stage_Matrix__c eachApprovalMatrix :[SELECT Id, Area__c, Area__r.Name, Region__c, Region__r.Name, Sales_Channel__c, Vertical__c, Target_Stage__c, 
                                                         ( SELECT Id, Related_User__c, Related_User__r.Country, Related_User__r.FirstName, Related_User__r.Area_Code__c, Related_User__r.IsActive
                                                          FROM Sales_Target_Approval_Users__r where Related_User__r.IsActive = true AND Related_User__r.UserType = 'Standard')
                                                         FROM Target_Stage_Matrix__c 
                                                         WHERE Target__c = :targetId]) {
                                                             if (TargetSettingConstants.APPROVAL_STAGE_1.equals(eachApprovalMatrix.Target_Stage__c)) {
                                                                 uniqueKey = eachApprovalMatrix.Target_Stage__c + eachApprovalMatrix.Area__r.Name;
                                                             } else if (TargetSettingConstants.APPROVAL_STAGE_3.equals(eachApprovalMatrix.Target_Stage__c)) {
                                                                 uniqueKey = eachApprovalMatrix.Target_Stage__c + eachApprovalMatrix.Area__r.Name + eachApprovalMatrix.Sales_Channel__c + eachApprovalMatrix.Vertical__c;
                                                             } else if (TargetSettingConstants.APPROVAL_STAGE_4.equals(eachApprovalMatrix.Target_Stage__c)) {
                                                                 uniqueKey = eachApprovalMatrix.Target_Stage__c + eachApprovalMatrix.Area__r.Name + eachApprovalMatrix.Sales_Channel__c;
                                                             } else if (TargetSettingConstants.APPROVAL_STAGE_5.equals(eachApprovalMatrix.Target_Stage__c)) {
                                                                 uniqueKey = eachApprovalMatrix.Target_Stage__c + eachApprovalMatrix.Area__r.Name;
                                                             } else if (TargetSettingConstants.APPROVAL_STAGE_6.equals(eachApprovalMatrix.Target_Stage__c)) {
                                                                 uniqueKey = eachApprovalMatrix.Target_Stage__c + eachApprovalMatrix.Region__r.Name;
                                                             } else if (TargetSettingConstants.APPROVAL_STAGE_7.equals(eachApprovalMatrix.Target_Stage__c)) {
                                                                 uniqueKey = eachApprovalMatrix.Target_Stage__c + eachApprovalMatrix.Sales_Channel__c;
                                                             } else if (TargetSettingConstants.APPROVAL_STAGE_8.equals(eachApprovalMatrix.Target_Stage__c)) {
                                                                 uniqueKey = eachApprovalMatrix.Target_Stage__c;
                                                             }
                                                             system.debug('##'+eachApprovalMatrix.Sales_Target_Approval_Users__r);
                                                             for (Target_Reviewer__c eachReviewer :eachApprovalMatrix.Sales_Target_Approval_Users__r) {
                                                                 if(eachReviewer.Related_User__r.isActive){
                                                                     if (!mapUserIdByApprovalKey.containsKey(uniqueKey)) {
                                                                         mapUserIdByApprovalKey.put(uniqueKey, new Set<Id> { eachReviewer.Related_User__c });
                                                                     }
                                                                     mapUserIdByApprovalKey.get(uniqueKey).add(eachReviewer.Related_User__c);  
                                                                 }
                                                             }
                                                         }
        system.debug('##mapUserIdByApprovalKey'+mapUserIdByApprovalKey);
        
        return mapUserIdByApprovalKey;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('inside Start');
        Target__c target;
        // set the Target Status as in Progress
        if(!String.isEmpty(targetId)){
            target = [SELECT Id, Name, Review_Stage__c, Stage_Status__c from Target__c WHERE Id =:targetId];
            if(target.Stage_Status__c != TargetSettingConstants.STAGE_STATUS_IN_PROGRESS){
                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_IN_PROGRESS; 
                update target;   
            }
        }
        String query = 'SELECT Id, Name, isGlobalAccountOwnerActive__c, Sales_Target_Item_Group__r.Budget_Group__c, Target__r.Review_Stage__c,Executing_Region__c, Global_Account_Owner_Name__c,Global_Account_Owner_Country__c , Controlling_Region__c, Sales_Channel__c, Controlling_Area__c,Controlling_Area__r.Name, Vertical__c, Global_Account_Owner__c, Review_Stage__c, Account__c ,Executing_Country__c,Executing_Area__c,Sales_Target_Item_Group__r.Executing_Area__r.BDA_Code__c , Account__r.Account_Address_Area__c,Represent_Concern_Account__c,Represent_Concern_Account__r.Account_Address_Area__c, Dummy_Update_For_Batch__c  FROM Target_Item__c WHERE Target__c = :targetId ';
        /*if(target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_2){
            query = query + ' AND Global_Account_Owner__c != null AND isGlobalAccountOwnerActive__c = true ';
        }else if(target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_3){
            query = query + ' AND Sales_Channel__c != null AND Vertical__c != null ';
        }else if(target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_4 || target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_7){
            query = query + ' AND Sales_Channel__c != null ';
        }*/
        if(whereClause != null && whereClause != ''){
            query = query + whereClause;
        }
        System.debug('query '+query);
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Item__c> listIncomingTargetItem) {
        System.debug('execute');
        Batch_ShareQueueable bq = new Batch_ShareQueueable(listIncomingTargetItem,mapUserIdByApprovalKey);
        System.enqueueJob(bq);
        
    }
    
    public void finish(Database.BatchableContext bc) {
        /*if(isReadAccess){
            Batch_UpdateShareRecords bch = new Batch_UpdateShareRecords(targetId);
            Database.executeBatch(bch,Integer.valueOf(batchSize));    
        }*/
        if(!String.isEmpty(targetId)){
            if(!SharingHelper.sharingFailed){
                Target__c target = new Target__c(Id = targetId);
                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_COMPLETED; 
                update target;   
            }
            
        }
    }
    
}