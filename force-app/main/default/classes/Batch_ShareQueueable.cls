public class Batch_ShareQueueable implements Queueable {

    public List<Target_Item__c> listIncomingTargetItem;
    public Map<String, Set<Id>> mapUserIdByApprovalKey;

    public Batch_ShareQueueable( List<Target_Item__c> listIncomingTargetItem,Map<String, Set<Id>>mapUserIdByApprovalKey) {

       this.listIncomingTargetItem = listIncomingTargetItem;
        this.mapUserIdByApprovalKey = mapUserIdByApprovalKey;

    }

    public void execute(QueueableContext qc) {  

        Set<SObject> lShareRecordTargetItem = new Set<SObject>();
        String tempControlAreaKey;
        String tempExecAreaKey;
        String tempStage3ControlArea;
        String tempStage3ExecArea;
        String tempStage4ControlArea;
        String tempStage4ExecArea;
        String tempStage7ControlArea;
        String tempStage7ExecArea;
        String tempStage5ControlArea;
        String tempStage5ExecArea;
        String tempStage6ControlRegion;
        String tempStage6ExecRegion; 
        String tempStage7SalesChannel;
        Set<Id> lGlobalAccountOwnerId = new Set<Id>();
        boolean givenAccess = false;
        List<Target_Item__c> listTargetItemsToUpdate = new List<Target_Item__c>();
        Map<String,Integer> mapStageNumber = new Map<String,Integer>();
        
        for (Target_Item__c item : listIncomingTargetItem) {
            SYSTEM.DEBUG('##item.Target__r.Review_Stage__c'+item.Target__r.Review_Stage__c);
             if(item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_6 || item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_7 || item.Target__r.Review_Stage__c == TargetSettingConstants.APPROVAL_STAGE_8){        //When target review stage moved to level 3
                
                
                
                //L4 l7 Access
                if(item.Sales_Channel__c != null){
                    // give read Access - review Stage 4
                    tempStage4ControlArea = TargetSettingConstants.APPROVAL_STAGE_4 + item.Controlling_Area__r.Name + item.Sales_Channel__c;
                    tempStage4ExecArea = TargetSettingConstants.APPROVAL_STAGE_4 + item.Executing_Area__c + item.Sales_Channel__c;
                    
                    
                    if(mapUserIdByApprovalKey.containsKey(tempStage4ControlArea)  ){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage4ControlArea),'Read'));    
                    }
                    if(mapUserIdByApprovalKey.containsKey(tempStage4ExecArea) ){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage4ExecArea),'Read'));    
                    }
                    
                    
                }
                // give read Access - review Stage 5
                tempStage5ControlArea = TargetSettingConstants.APPROVAL_STAGE_5 + item.Controlling_Area__r.Name;
                tempStage5ExecArea = TargetSettingConstants.APPROVAL_STAGE_5 + item.Executing_Area__c;
                if(mapUserIdByApprovalKey.containsKey(tempStage5ControlArea) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage5ControlArea),'Edit'));    
                }
                if(mapUserIdByApprovalKey.containsKey(tempStage5ExecArea) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage5ExecArea),'Read'));    
                }
                // give read access - review Stage 6
                tempStage6ControlRegion = TargetSettingConstants.APPROVAL_STAGE_6 + item.Controlling_Region__c;
                tempStage6ExecRegion = TargetSettingConstants.APPROVAL_STAGE_6 + item.Executing_Region__c;
                
                if(mapUserIdByApprovalKey.containsKey(tempStage6ControlRegion) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage6ControlRegion),'Edit'));    
                }
                if(mapUserIdByApprovalKey.containsKey(tempStage6ExecRegion) ){
                    lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage6ExecRegion),'Read'));    
                }
                 
                tempControlAreaKey = TargetSettingConstants.APPROVAL_STAGE_1 + item.Controlling_Area__r.Name ;
                tempExecAreaKey = TargetSettingConstants.APPROVAL_STAGE_1 + item.Executing_Area__c;
                    // if Controlling Area and Executing Area both Match , give Edit Access
                    
                    if(mapUserIdByApprovalKey.containsKey(tempExecAreaKey)){ //if only Executing Area Matches give Read
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempExecAreaKey),'Read'));
                    }
                if (mapUserIdByApprovalKey.containsKey(tempControlAreaKey)) {
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id ,mapUserIdByApprovalKey.get(tempControlAreaKey),'Edit'));
                    }
                //access for L2
                if(item.Global_Account_Owner__c != null && item.isGlobalAccountOwnerActive__c){
                    lShareRecordTargetItem.add(SharingHelper.createShareRecord(new Target_Item__Share(),item.Id, item.Global_Account_Owner__c,'Edit'));
                }
                //access for L3
                if(item.Sales_Channel__c != null && item.Vertical__c != null){
                    tempStage3ControlArea = TargetSettingConstants.APPROVAL_STAGE_3 + item.Controlling_Area__r.Name + item.Sales_Channel__c+ item.Vertical__c; 
                    tempStage3ExecArea = TargetSettingConstants.APPROVAL_STAGE_3 + item.Executing_Area__c+ item.Sales_Channel__c+ item.Vertical__c;
                    
                    if(mapUserIdByApprovalKey.containsKey(tempStage3ExecArea)){
                        
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage3ExecArea),'Read'));    
                    }
                    if(mapUserIdByApprovalKey.containsKey(tempStage3ControlArea) ){
                        givenAccess = true;
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage3ControlArea),'Edit'));    
                    }
                }
                 
                 //give access for review Stage 7
                    tempStage7SalesChannel = TargetSettingConstants.APPROVAL_STAGE_7 + item.Sales_Channel__c;
                    if(mapUserIdByApprovalKey.containsKey(tempStage7SalesChannel) ){
                        lShareRecordTargetItem.addAll(SharingHelper.createShareRecordList(new Target_Item__Share(),item.Id, mapUserIdByApprovalKey.get(tempStage7SalesChannel),'Edit'));
                    }
              
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
        

    }
}