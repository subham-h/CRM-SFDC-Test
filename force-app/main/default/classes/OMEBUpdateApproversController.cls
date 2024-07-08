/****
* Version	Story Number      Date        Owner                        Description
***********************************************************************************************
*1.0  		SFSE - 10542    05-05-2023    Jay@UST     				OMEBUpdateApproversController
*2.0		SFSE-11845		03-Aug-2023	  Jothsana@Maersk			Delegated Approver logic added
*/
public class OMEBUpdateApproversController {
    public static final String CURRENT_APPROVER = 'Current_owner__c';
    public static final String ESCALATION_APPROVER = 'Escalation_owner__c';
    public static final String PENDING = System.label.Status_Pending;
    public static list<Approval_Process_Escalation_Matrix__c> listFetched;
    public static list<Approval_Process_Escalation_Matrix__c> updatedListOfApm;
   
    @AuraEnabled
    public static List<Approval_Process_Escalation_Matrix__c> getApprovalMatrix(String userId, String country, String gateName, String subgateName, String vertical, String areaCode, String region, String fieldName, List<String> productCode, String totalGP){
       
        String parentApiName = '';
        String prodCode = '';
        if(fieldName != null && fieldName.length() > 0){
            parentApiName = fieldName.substring(0, fieldName.length()-1)+'r';
        }
        //System.debug('Parent Api Name'+parentApiName);
        //String query = 'SELECT Id, name, Approval_Process_Name__c, Key__c, Region__c, Approval_Process_Name__r.Name, Step_Name__c,' +fieldName+','+parentApiName+'.Name, Area_code__c, Country__c, Country__r.Name, Gate_Name__c, Vertical__c FROM Approval_Process_Escalation_Matrix__c WHERE Approval_Process_Name__c != null AND Active__c = True AND ';
        String query = 'SELECT Id, name, Approval_Process_Name__c, Key__c, Region__c, Approval_Process_Name__r.Name, Step_Name__c, Current_owner__c, Current_owner__r.Name, Escalation_owner__c, Escalation_owner__r.Name, Area_code__c, Country__c, Country__r.Name, Gate_Name__c, Vertical__c, Product_for_approval__c, Total_GP__c FROM Approval_Process_Escalation_Matrix__c WHERE Approval_Process_Name__c != null AND Active__c = True AND ';
        if(userId != null && userId != ''){
            query += fieldName+' =: userId AND ';
        }
        if(country != null && country != ''){
            query += 'Country__c =:  country AND ';
        }
        if(gateName != null && gateName != ''){
            query += 'Approval_Process_Name__r.Gate__c =: gateName AND ';
        }
        if(subgateName != null && subgateName != ''){
            query += 'Approval_Process_Name__r.Sub_Gate__c =: subgateName AND ';
        }
        if(vertical != null && vertical != ''){
            if(vertical != 'NV'){
                query += 'Vertical__c =: vertical AND ';   
            }else{
                query += 'Vertical__c = \'\' AND ';
            }
        }
        if(areaCode != null && areaCode != ''){
            query += 'Area_code__c =: areaCode AND ';
        }
        if(region != '' && region != null){
            query += 'Region__c =: region AND ';
        }
        if(totalGP != '' && totalGP != null && totalGP != 'All'){
            query += 'Total_GP__c =: totalGP AND ';
        }
        
        if(productCode != null && productCode.size() > 0){
            System.debug('productCode '+productCode);
            List<String> codes = new List<String>();
            String subQuery = '';
            for(String code : productCode){
                code = code.replaceAll('[0-9]','');
                if(!codes.contains(code)){
                    codes.add(code);
                }
            }
            
            for(String code : codes){
                prodCode = '\'%' + code  + '%\'';
                subQuery += 'Product_for_approval__c like '+prodCode+' OR ';
            }
            if(subQuery != ''){
                subQuery = subQuery.removeEnd(' OR ');
                subQuery = '('+subQuery+')';
            }
            
            System.debug('subQuery '+subQuery);
            query += subQuery+' AND ';
        }

        if(query.endsWithIgnoreCase('AND ')){
            query = query.removeEndIgnoreCase('AND ');                                          
        }
        
        System.debug('Query >> '+query);
        listFetched = Database.query(query);
       return listFetched;
    }

    @AuraEnabled
    public static Integer getOptyCount(Object data, String fieldName, List<Approval_Process_Escalation_Matrix__c> searchResult){
        String type1;
        String type2;
        if(fieldName == CURRENT_APPROVER){
            type1 = 'Initial submission';
            type2 = 'Change of Approver';
        }else if(fieldName == ESCALATION_APPROVER){
            type1 = 'Escalation';
            type2 = 'Change of Escalation Approver';
        }
        List<Approval_Process_Escalation_Matrix__c> updateMatrix = getNewList(data,fieldName,searchResult); 
        Map<Id, Approval_Process_Escalation_Matrix__c> updateMatrixMap = New Map<Id, Approval_Process_Escalation_Matrix__c>(updateMatrix);
        Set<Id> keySet = updateMatrixMap.KeySet();
        String query = 'SELECT Id, TargetObjectId__c FROM Approval_History__c WHERE (Approval_Step__c =: keySet AND Status__c =: PENDING) AND (Type__c = \''+type1+'\' OR Type__c = \''+type2+'\')';
        System.debug('Count query >> '+query);
        List<Approval_History__c> aphList = Database.query(query);
        Set<Id> optyIds = New Set<Id>();
        for(Approval_History__c aph : aphList){
            optyIds.add(aph.TargetObjectId__c);
        }
        return optyIds.size();
    }

    @AuraEnabled
    public static List<Approval_Process_Escalation_Matrix__c> updateApprovalMatrix(Object data, String fieldName, List<Approval_Process_Escalation_Matrix__c> searchResult) {
        List <Approval_Process_Escalation_Matrix__c> updateMatrix = getNewList(data,fieldName,searchResult); 
        System.debug('New updated Matrix >> '+updateMatrix);
        update updateMatrix; 
        updateApprovalHistory(fieldName, updateMatrix);
        return updateMatrix;
    }

    @AuraEnabled
    public static List<Approval_Process_Escalation_Matrix__c> getNewList(Object data, String fieldName, List<Approval_Process_Escalation_Matrix__c> searchResult){
        List<Approval_Process_Escalation_Matrix__c> searchedData = searchResult;
        System.debug('Record List >> '+searchedData);
        Map<String, List<Id>> keyIdMap = New Map<String, List<Id>>();
        for(Approval_Process_Escalation_Matrix__c ape : searchedData){
            List<string> splitKey = ape.Key__c.split('-');
            string combinedKey = '';
            for(integer i=0;i<=5;i++){
                combinedKey = combinedKey + splitKey[i] + '-';
            }
            if(combinedKey.endswith('-')){
                combinedKey = combinedKey.removeEnd('-');
            }  
            if(keyIdMap.containsKey(combinedKey)){
                keyIdMap.get(combinedKey).add(ape.Id);
            }else {
                keyIdMap.put(combinedKey, New List<Id>{ape.Id});
            }
        }
    
        System.debug('Searched Data Map >> '+keyIdMap);
        System.debug('Updated Data >> '+data);
        updatedListOfApm = (List<Approval_Process_Escalation_Matrix__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Approval_Process_Escalation_Matrix__c>.class
        );
        List<Approval_Process_Escalation_Matrix__c> newUpdatedMatrix = New List<Approval_Process_Escalation_Matrix__c>();
        Map<Id, Approval_Process_Escalation_Matrix__c> updatedOwner = New Map<Id, Approval_Process_Escalation_Matrix__c>(updatedListOfApm);
        Map<String, Map<Id, String>> keyOwnerMap = New Map<String, Map<Id, String>>();
        List<Approval_Process_Escalation_Matrix__c> apeList = Database.query('SELECT Id, Key__c, '+fieldName+' FROM Approval_Process_Escalation_Matrix__c WHERE Id IN : updatedListOfApm');
        
        for(Approval_Process_Escalation_Matrix__c ape : apeList){
            List<string> splitKey = ape.Key__c.split('-');
            string combinedKey = '';
            for(integer i=0;i<=5;i++){
                combinedKey = combinedKey + splitKey[i] + '-';
            }
            if(combinedKey.endswith('-')){
                combinedKey = combinedKey.removeEnd('-');
            }  
            System.debug('Field Value >> '+updatedOwner.get(ape.Id).get(fieldName));
            if(keyOwnerMap.containsKey(combinedKey)) {
                keyOwnerMap.get(combinedKey).put(ape.Id, (String)updatedOwner.get(ape.Id).get(fieldName));
            }else{
               keyOwnerMap.put(combinedKey, New Map<Id, String>{ape.Id => (String)updatedOwner.get(ape.Id).get(fieldName)});
            }
        }
        
        System.debug('KeyOwnerMap >> '+keyOwnerMap);
        System.debug('Updated Matrix >> '+updatedListOfApm);
        for(String key : keyOwnerMap.keySet()){
            if(keyIdMap.containsKey(key)){
                Map<Id, String> changedOwner = keyOwnerMap.get(key);
                List<Id> apeIds = keyIdMap.get(key);
                String owner;
                for(Id apeId : apeIds){
                    if(changedOwner.containsKey(apeId)){
                        owner = changedOwner.get(apeId);
                    }
                }
                System.debug('Changed Owner');
                for(Id keyId : keyIdMap.get(key)){
                    Approval_Process_Escalation_Matrix__c ape = New Approval_Process_Escalation_Matrix__c();
                    ape.Id = keyId;
                    ape.put(fieldName,owner);
                    newUpdatedMatrix.add(ape);
                }
            }
        }
        return newUpdatedMatrix;
    }

    @AuraEnabled
    public static void updateApprovalHistory(String fieldName, List<Approval_Process_Escalation_Matrix__c> updatedList){
        Map<Id,Approval_Process_Escalation_Matrix__c> matrixMap = New Map<Id,Approval_Process_Escalation_Matrix__c>(updatedList);
        System.debug('Matrix Ids >> '+matrixMap);
        List<Approval_History__c> ahList = [SELECT Id, Approval_Step__c,Approval_Step__r.Approval_Process_Name__r.Name,Submission_Order__c, Step_Name__c, key__c, CreatedDate, Status__c, TargetObjectId__c, Type__c, CreatedById, CreatedBy.Name, Assigned_To__c,Assigned_To__r.Name, Approved_By__c,Approved_By__r.Name,Delegated_approver__c, 
        Submitter_Comments__c, Approver_Comments__c FROM Approval_History__c WHERE Approval_Step__c IN : matrixMap.keySet() AND Status__c = 'Pending'];
        Map<Id,List<Approval_History__c>> ahMap = New Map<Id, List<Approval_History__c>>();
        for(Approval_History__c ah : ahList){
            if(ahmap.containsKey(ah.Approval_Step__c)){
                ahmap.get(ah.Approval_Step__c).add(ah);
            }else{
                ahMap.put(ah.Approval_Step__c, New List<Approval_History__c>{ah});
            }
        }
        System.debug('History List >> '+ahList.Size());
        List<Approval_History__c> updateList = New List<Approval_History__c>();
        List<Approval_History__c> insertList = New List<Approval_History__c>();
        for(Id key : matrixMap.keySet()){
            if(ahMap.containsKey(key)){
                List<Approval_History__c> updateAhList = ahMap.get(key);
                for(Approval_History__c updateAh : updateAhList){
                    if(fieldName == CURRENT_APPROVER && (updateAh.Type__c == 'Initial submission' || updateAh.Type__c == 'Change of Approver')){
                        Approval_History__c ah = updateAh;
                        //updateAh.Approved_By__c = matrixMap.get(key).Current_owner__c;
                        ah.Approved_By__c = (Id)matrixMap.get(key).get(fieldName);
                        ah.Status__c = 'ReAssigned';
                        ah.Action_Date__c = system.today();
                        updateList.add(ah);
                        Approval_History__c insertAh = ah.clone(false, true, false, false);
                        insertAh.Status__c = 'Pending';
                        insertAh.Action_Date__c = null;
                        insertAh.Type__c = 'Change of Approver';
                        insertAh.Submission_Order__c = ah.Submission_Order__c;
                        insertAh.Process_Name__c = ah.Approval_Step__r.Approval_Process_Name__r.Name;
                        insertAh.Approved_By__c = (Id)matrixMap.get(key).get(fieldName); 
                        insertAh.Assigned_To__c = (Id)matrixMap.get(key).get(fieldName);
                        String DelegatedApproverinitial = [select DelegatedApproverId from user where id =: insertAh.Assigned_To__c limit 1][0].DelegatedApproverId;
                        if(DelegatedApproverinitial != null){
                            insertAh.Delegated_approver__c = DelegatedApproverinitial;
                        }
                        insertList.add(insertAh); 
                    }else if(fieldName == ESCALATION_APPROVER && ( updateAh.Type__c == 'Escalation' || updateAh.Type__c == 'Change of Escalation Approver')){
                        Approval_History__c ah = updateAh;
                        //updateAh.Approved_By__c = matrixMap.get(key).Current_owner__c;
                        ah.Approved_By__c = (Id)matrixMap.get(key).get(fieldName);
                        ah.Status__c = 'ReAssigned';
                        ah.Action_Date__c = system.today();
                        updateList.add(ah);
                        Approval_History__c insertAh = ah.clone(false, true, false, false);
                        insertAh.Status__c = 'Pending';
                        insertAh.Action_Date__c = null;
                        insertAh.Type__c = 'Change of Escalation Approver';
                        insertAh.Submission_Order__c = ah.Submission_Order__c;
                        insertAh.Process_Name__c = ah.Approval_Step__r.Approval_Process_Name__r.Name;
                        insertAh.Approved_By__c = (Id)matrixMap.get(key).get(fieldName); 
                        insertAh.Assigned_To__c = (Id)matrixMap.get(key).get(fieldName);
                        String DelegatedApproverEscalation = [select DelegatedApproverId from user where id =: insertAh.Assigned_To__c limit 1][0].DelegatedApproverId;
                        if(DelegatedApproverEscalation != null){
                            insertAh.Delegated_approver__c = DelegatedApproverEscalation;
                        }
                        insertList.add(insertAh); 
                    }                   
                }
            }
        }
        System.debug('Update List size >> '+updateList.size());
        System.debug('Insert List size >> '+insertList.size());
        try{
            update updateList;
            if(insertList.size() > 0){
                insert insertList;
                sendEmail(insertList);
            }
        }catch(exception ex){
            System.debug('Error >> '+ex.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Opportunity Approver Update', 'OMEBUpdateApproversController.updateApprovalHistory ', new list<Exception>{ex});
            throw new AuraHandledException(ex.getMessage());
        }

    }
    public static void sendEmail(List<Approval_History__c> ahList){
        String Template = System.Label.OMEB_ApprovalHistory;
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name=:Template limit 1];
        List<Approval_History__c> approverList = [SELECT Id, TargetObjectId__c, Assigned_To__r.Email,Delegated_Approver__r.Email,Delegated_approver__r.UserPreferencesReceiveNotificationsAsDelegatedApprover, Assigned_To__r.UserPreferencesReceiveNoNotificationsAsApprover FROM Approval_History__c WHERE Id IN : ahList ];
        System.debug('Approver List >> '+approverList.Size());
        List<Messaging.singleEmailMessage> msgList = New List<Messaging.SingleEmailMessage>();
        for(Approval_History__c ah : approverList){
             Messaging.SingleEmailMessage msg = New Messaging.SingleEmailMessage();
            string[] toAddresses = New String[]{};
            if(ah.Assigned_To__r.UserPreferencesReceiveNoNotificationsAsApprover == false){
                toAddresses.add(ah.Assigned_To__r.Email);
                }
            if(ah.Delegated_approver__c != null && ah.Delegated_approver__r.UserPreferencesReceiveNotificationsAsDelegatedApprover == true){
                toAddresses.add(ah.Delegated_Approver__r.Email);
                }
            msg.setTemplateId(emailTemplate.Id);
            msg.setToAddresses(toAddresses);
            msg.setWhatId(ah.Id);
            msg.setTargetObjectId(ah.Assigned_To__c);
            msg.setReplyTo(Label.Opportunity_Approval_Email_Address);
            msg.setSaveAsActivity(false);
            msg.setTreatTargetObjectAsRecipient(false);
            msgList.add(msg);
        }
        messaging.sendEmail(msgList);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Geography__c> getGeographyCountries() {
        System.debug('inside get geography countries');
        return [SELECT Id, Name FROM Geography__c where Active__c = true and Type_Of_Location__c ='Country' order by Name];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<BDA__c> getTradeRegions() {
        System.debug('inside get geography countries');
        return [select id, Name from BDA__c where Type__c = 'Trade Region' and Active__c = true order by Name];
    }
    
    @AuraEnabled
    public static String saveRecords(String recsString, String fieldName) {
        List<Approval_Process_Escalation_Matrix__c> recs2Save = (List<Approval_Process_Escalation_Matrix__c>) JSON.deserialize(recsString, List<Approval_Process_Escalation_Matrix__c>.class);
        update recs2Save;
                updateApprovalHistory(fieldName, recs2Save);
        return 'success';
    }
    
    @AuraEnabled
    public static PendingRecordsCountWrapper getReassignedHistoryCount(String recsString, String fieldName) {
        List<Approval_Process_Escalation_Matrix__c> matrixToUpdate = (List<Approval_Process_Escalation_Matrix__c>) JSON.deserialize(recsString, List<Approval_Process_Escalation_Matrix__c>.class);
        String query = 'SELECT Id, TargetObjectId__c FROM Approval_History__c WHERE Status__c = \'Pending\' AND Approval_Step__c IN :matrixToUpdate ';
        if(fieldName == CURRENT_APPROVER){
            query += 'AND Type__c IN (\'Initial submission\',\'Change of Approver\')';
        }else if(fieldName == ESCALATION_APPROVER){
            query += 'AND Type__c IN (\'Escalation\',\'Change of Escalation Approver\')';
        }
        System.debug('query '+query);
        List<Approval_History__c> pendingHistoriesToReassign = Database.query(query);
        Set<Id> opptyIds = new Set<Id>();
        for(Approval_History__c history : pendingHistoriesToReassign){
            opptyIds.add(history.TargetObjectId__c);
        }
        PendingRecordsCountWrapper pendingRecs = new PendingRecordsCountWrapper();
        pendingRecs.historiesCount = pendingHistoriesToReassign.size();
        pendingRecs.opportunitiesCount = opptyIds.size();
        return pendingRecs;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Products_For_Approval__mdt> getProductNames() {
        List<Products_For_Approval__mdt> lstProdForApproval = new List<Products_For_Approval__mdt>(); 
        
        for (Products_For_Approval__mdt pf : Products_For_Approval__mdt.getAll().values()){
            if(pf.Active__c){
                lstProdForApproval.add(pf);
            }
        }
        return lstProdForApproval;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> gettotalGPOptions() {
        List<String> totalGPOptions = new List<String>();
        String totalGP;
        for (AggregateResult result : [select Total_GP__c, Count(Id) from Approval_Process_Escalation_Matrix__c WHERE Active__c = true AND Total_GP__c != '' group by Total_GP__c order by Total_GP__c]){
            totalGP = String.valueOf(result.get('Total_GP__c'));
            if(totalGP != null && totalGP != ''){
                totalGPOptions.add(totalGP);
            }
        }
        return totalGPOptions;
    }
    
    public class PendingRecordsCountWrapper{
        @auraEnabled
        public Integer opportunitiesCount		{get;set;}
        @auraEnabled
        public Integer historiesCount			{get;set;}
    }
}