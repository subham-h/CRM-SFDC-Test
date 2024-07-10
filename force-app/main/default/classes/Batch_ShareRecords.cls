public class Batch_ShareRecords implements Database.Batchable<sObject> {
    
    private String targetId;
    private Boolean isReadAccess;
    private String stageName;
    private Map<String, Set<Id>> mapUserIdByApprovalKey;
    public static Integer batchSize = Integer.ValueOf(LABEL.BatchShareSize);
    public String whereClause;
    
    public Batch_ShareRecords(String targetId, String whereClause) {
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
                                                         WHERE Target__c = :targetId ]) {
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
                                                             
                                                             for (Target_Reviewer__c eachReviewer :eachApprovalMatrix.Sales_Target_Approval_Users__r) {
                                                                 if(eachReviewer.Related_User__r.isActive){
                                                                     if (!mapUserIdByApprovalKey.containsKey(uniqueKey)) {
                                                                         mapUserIdByApprovalKey.put(uniqueKey, new Set<Id> { eachReviewer.Related_User__c });
                                                                     }
                                                                     mapUserIdByApprovalKey.get(uniqueKey).add(eachReviewer.Related_User__c);
                                                                 }
                                                             }
                                                         }
        
        return mapUserIdByApprovalKey;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
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
        if(target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_2){
            query = query + ' AND Global_Account_Owner__c != null AND isGlobalAccountOwnerActive__c = true ';
        }else if(target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_3){
            query = query + ' AND Sales_Channel__c != null AND Vertical__c != null ';
        }else if(target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_4 || target.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_7){
            query = query + ' AND Sales_Channel__c != null ';
        }
        if(whereClause != null && whereClause != ''){
            query = query + whereClause;
        }
        System.debug('query '+query);
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Item__c> listIncomingTargetItem) {
        
        Set<SObject> lShareRecordTargetItem = new Set<SObject>();
        String tempControlAreaKey;
        String tempExecAreaKey;
        String tempStage3ControlArea;
        String tempStage3ExecArea;
        String tempStage4ControlArea;
        String tempStage4ExecArea;
        String tempStage5ControlArea;
        String tempStage5ExecArea;
        String tempStage6ControlRegion;
        String tempStage6ExecRegion; 
        String tempStage7SalesChannel;
        Set<Id> lGlobalAccountOwnerId = new Set<Id>();
        List<Target_Item__c> listTargetItemsToUpdate = new List<Target_Item__c>();
        
        for (Target_Item__c item : listIncomingTargetItem) {
            
            if (item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_1) {// update to StageName
                
                if(Label.STS_Level_One_Creator_Access != 'true' || Test.isRunningTest()){
                    tempControlAreaKey = TargetSettingConstants.APPROVAL_STAGE_1 + item.Controlling_Area__r.Name ;
                    tempExecAreaKey = TargetSettingConstants.APPROVAL_STAGE_1 + item.Executing_Area__c;
                    // if Controlling Area and Executing Area both Match , give Edit Access
                    if (mapUserIdByApprovalKey.containsKey(tempControlAreaKey)) {
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id ,mapUserIdByApprovalKey.get(tempControlAreaKey),'Edit'));
                    }
                    if(!mapUserIdByApprovalKey.containsKey(tempControlAreaKey) && mapUserIdByApprovalKey.containsKey(tempExecAreaKey)){ //if only Executing Area Matches give Read
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempExecAreaKey),'Read'));
                    }
                }
                //give read Access to Global Account Owner - reviewer STage 2
                if(item.Global_Account_Owner__c != null && item.isGlobalAccountOwnerActive__c){
                    //lGlobalAccountOwnerId.add(item.Global_Account_Owner__c);
                    lShareRecordTargetItem.add(SharingHelper.createShareRecord(new Target_Item__Share(),item.Id, item.Global_Account_Owner__c,'Read'));
                }
                //give read Access - reviewer STage 3
                if(item.Sales_Channel__c != null && item.Vertical__c != null){
                    
                    tempStage3ControlArea = TargetSettingConstants.APPROVAL_STAGE_3 + item.Controlling_Area__r.Name + item.Sales_Channel__c+ item.Vertical__c;
                    tempStage3ExecArea = TargetSettingConstants.APPROVAL_STAGE_3 + item.Executing_Area__c+ item.Sales_Channel__c+ item.Vertical__c;
                    
                    if(mapUserIdByApprovalKey.containsKey(tempStage3ControlArea) ){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage3ControlArea),'Read'));    
                    }
                    if(mapUserIdByApprovalKey.containsKey(tempStage3ExecArea)){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage3ExecArea),'Read'));    
                    }
                    
                }
                if(item.Sales_Channel__c != null){
                    // give read Access - review Stage 4
                    tempStage4ControlArea = TargetSettingConstants.APPROVAL_STAGE_4 + item.Controlling_Area__r.Name + item.Sales_Channel__c;
                    tempStage4ExecArea = TargetSettingConstants.APPROVAL_STAGE_4 + item.Executing_Area__c + item.Sales_Channel__c;
                    if(mapUserIdByApprovalKey.containsKey(tempStage4ControlArea) ){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage4ControlArea),'Read'));    
                    }
                    if(mapUserIdByApprovalKey.containsKey(tempStage4ExecArea)){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage4ExecArea),'Read'));    
                    }
                    
                    //give access for review Stage 7
                    tempStage7SalesChannel = TargetSettingConstants.APPROVAL_STAGE_7 + item.Sales_Channel__c;
                    if(mapUserIdByApprovalKey.containsKey(tempStage7SalesChannel)){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage7SalesChannel),'Read'));
                    }
                    
                }
                // give read Access - review Stage 5
                tempStage5ControlArea = TargetSettingConstants.APPROVAL_STAGE_5 + item.Controlling_Area__r.Name;
                tempStage5ExecArea = TargetSettingConstants.APPROVAL_STAGE_5 + item.Executing_Area__c;
                if(mapUserIdByApprovalKey.containsKey(tempStage5ControlArea) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage5ControlArea),'Read'));    
                }
                if(mapUserIdByApprovalKey.containsKey(tempStage5ExecArea)){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage5ExecArea),'Read'));    
                }
                // give read access - review Stage 6
                tempStage6ControlRegion = TargetSettingConstants.APPROVAL_STAGE_6 + item.Controlling_Region__c;
                tempStage6ExecRegion = TargetSettingConstants.APPROVAL_STAGE_6 + item.Executing_Region__c;
                
                if(mapUserIdByApprovalKey.containsKey(tempStage6ControlRegion) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage6ControlRegion),'Read'));    
                }
                if(mapUserIdByApprovalKey.containsKey(tempStage6ExecRegion)){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage6ExecRegion),'Read'));    
                }
                // give read access - review Stage 8 - Commenting this logic to move this into criteria based sharing rule
                /*if(mapUserIdByApprovalKey.containsKey(TargetSettingConstants.APPROVAL_STAGE_8)){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(TargetSettingConstants.APPROVAL_STAGE_8),'Read'));
                }*/
            }else if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_2) {		//When target review stage moved to level 2
                if(item.Global_Account_Owner__c != null && item.isGlobalAccountOwnerActive__c){
                    //lGlobalAccountOwnerId.add(item.Global_Account_Owner__c);
                    //lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, lGlobalAccountOwnerId,'Edit'));
                    lShareRecordTargetItem.add(SharingHelper.createShareRecord(new Target_Item__Share(),item.Id, item.Global_Account_Owner__c,'Edit'));
                }  
            }else if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_3){		//When target review stage moved to level 3
                if(item.Sales_Channel__c != null && item.Vertical__c != null){
                    tempStage3ControlArea = TargetSettingConstants.APPROVAL_STAGE_3 + item.Controlling_Area__r.Name + item.Sales_Channel__c+ item.Vertical__c; 
                    if(mapUserIdByApprovalKey.containsKey(tempStage3ControlArea) ){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage3ControlArea),'Edit'));    
                    }
                }
            }else if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_4){		//When target review stage moved to level 4
                tempStage4ControlArea = TargetSettingConstants.APPROVAL_STAGE_4 + item.Controlling_Area__r.Name + item.Sales_Channel__c;
                if(mapUserIdByApprovalKey.containsKey(tempStage4ControlArea) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage4ControlArea),'Edit'));    
                }
            }else if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_5){		//When target review stage moved to level 5
                tempStage5ControlArea = TargetSettingConstants.APPROVAL_STAGE_5 + item.Controlling_Area__r.Name;
                if(mapUserIdByApprovalKey.containsKey(tempStage5ControlArea) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage5ControlArea),'Edit'));    
                }
            }else if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_6){		//When target review stage moved to level 6
                tempStage6ControlRegion = TargetSettingConstants.APPROVAL_STAGE_6 + item.Controlling_Region__c;
                if(mapUserIdByApprovalKey.containsKey(tempStage6ControlRegion) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage6ControlRegion),'Edit'));    
                }
            }else if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_7){		//When target review stage moved to level 7
                tempStage7SalesChannel = TargetSettingConstants.APPROVAL_STAGE_7 + item.Sales_Channel__c;
                if(mapUserIdByApprovalKey.containsKey(tempStage7SalesChannel)){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage7SalesChannel),'Edit'));
                }
            }/* Commenting this logic to move this into criteria based sharing rule
              * else if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_8){		//When target review stage moved to level 8
                if(mapUserIdByApprovalKey.containsKey(TargetSettingConstants.APPROVAL_STAGE_8)){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(TargetSettingConstants.APPROVAL_STAGE_8),'Edit'));
                }
            }*/
            if(item.Dummy_Update_For_Batch__c  == true){
                listTargetItemsToUpdate.add(new Target_Item__c(Id = item.Id, Dummy_Update_For_Batch__c = false));
            }
        }
        
        if(lShareRecordTargetItem.size() > 0 ){
            //Database.insert(lShareRecordTargetItem, false);
            List<SObject> listTargetItemShare = new List<SObject>(lShareRecordTargetItem);
            try{
                Database.SaveResult[] results = Database.insert(listTargetItemShare, false);
                ErrorLogger.writeErrors('SFDC', 'STS', 'Batch_ShareRecords.execute', results, listTargetItemShare);
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'STS', 'Batch_ShareRecords.execute', new list<Exception>{ex});
            }
        }
        
        if(listTargetItemsToUpdate.size() > 0){
            try{
                TriggerExecutionController.isTargetItemTriggerSkip = true;
                Database.SaveResult[] results = Database.update(listTargetItemsToUpdate, false);
                TriggerExecutionController.isTargetItemTriggerSkip = false;
                ErrorLogger.writeErrors('SFDC', 'STS', 'Batch_ShareRecords.execute', results, listTargetItemsToUpdate);
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'STS', 'Batch_ShareRecords.execute', new list<Exception>{ex});
            }
        }
        
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