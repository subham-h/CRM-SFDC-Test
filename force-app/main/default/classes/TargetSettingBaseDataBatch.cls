/*
* Author    : Arpitha J
* Description   : Function to capture ROFO & Budget Measures
*       : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                              Arpitha@maersk           Created. 
* 
*/

public class TargetSettingBaseDataBatch implements Database.Batchable<sObject>,Database.Stateful {
    private Target__c targetRec;
    private String strParameter;
    private String targetId;
    private String applicableYear;
    private String measureDimension; 
    private String targetOwnerEmailId;
    private String corelationId;
    private String stagingStatus;
    private Boolean isUpdateStatus = false;
    private Boolean isError = false;
    
    public TargetSettingBaseDataBatch(String targetId, String strParameter, String corelationId, String stagingStatus){
        
        this.strParameter = strParameter;
        this.targetId = targetId;
        this.corelationId = corelationId;
        this.stagingStatus = stagingStatus;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        if(TargetSettingConstants.QUERY_ID_BUDGET == strParameter){
            applicableYear =   String.valueof(Date.today().year()+1);  
            measureDimension = TargetSettingConstants.BUDGET;
            isUpdateStatus = true;
        }
        else if(TargetSettingConstants.QUERY_ID_ROFO == strParameter){
            applicableYear =  String.valueof(Date.today().year());  
            measureDimension = TargetSettingConstants.ROLLING_FORECAST; 
        }
        else if(TargetSettingConstants.QUERY_ID_CYACTUALS == strParameter){
            applicableYear =  String.valueof(Date.today().year());  
            measureDimension = TargetSettingConstants.CY_ACTUALS; 
        }
        else if(TargetSettingConstants.QUERY_ID_PYACTUALS == strParameter){
            applicableYear =  String.valueof(Date.today().year()+1);  
            measureDimension = TargetSettingConstants.PY_ACTUALS;
            isUpdateStatus = true;
        }
        
        List<Target__c>targetRecord;
        if(!String.isEmpty(targetId)){
            targetRecord = [Select id,Applicable_Year__c,Status__c,owner.email, Stage_Status__c from Target__c where id=:targetId limit 1];    
        }
        else{
            targetRecord = [Select id,Applicable_Year__c,Status__c,owner.email, Stage_Status__c from Target__c where Status__c!=null AND Status__c!=:TargetSettingConstants.TARGET_STATUS_CLOSED AND Status__c!=:TargetSettingConstants.TARGET_STATUS_CANCELLED AND Applicable_Year__c=:applicableYear limit 1];
        }
        if(targetRecord!=null && targetRecord.size()>0){
            targetRec = targetRecord.get(0);
            targetOwnerEmailId = targetRec.owner.email;
            List<Target_Setting_Batch_Query__mdt> batchQuery = [SELECT Query__c 
                                                                FROM Target_Setting_Batch_Query__mdt
                                                                WHERE DeveloperName = :strParameter 
                                                                
                                                                LIMIT 1 ];
            String query = '';
            if (isUpdateStatus) {
                targetRec.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_IN_PROGRESS;
                update targetRec;
                query = String.format(batchQuery.get(0).Query__c, new List<String>{'\'' + corelationId + '\'', '\'' + stagingStatus + '\''});
            } else {
                query = batchQuery.get(0).Query__c;
            }
            
            return Database.getQueryLocator(query);
        }
        else{
            return null;
        }
    }
    public void execute(Database.BatchableContext bc, List<Target_Setting_Staging__c> stagingRecords){
        Boolean measureExists; 
        Budget_Group__c budgetGroupRecord;
        List<Budget_Measure__c>measureRecordsUpsertList = new List<Budget_Measure__c>();
        List<Budget_Group__c>budgetGroupUpsertList = new List<Budget_Group__c>();
        List<Budget_Group__c>budgetGroupSuccessList = new List<Budget_Group__c>();
        //map<String,Target_Setting_Staging__c>mapStagBrandFamilyCountry = new map<String,Target_Setting_Staging__c>();
        map<String,List<Target_Setting_Staging__c>>mapStagBrandFamilyCountryRecords = new map<String,List<Target_Setting_Staging__c>>();
        map<Id,Id>mapBudgetStagingId = new map<Id,Id>();
        List<Target_Item_Group__c>salesTargetGroupInsertList = new List<Target_Item_Group__c>();
        List<Target_Item_Group__c>salesTargetGroupSuccessInsertList = new List<Target_Item_Group__c>();
        List<Target_Item__c>salesTargetitemInsertList = new List<Target_Item__c>();
        List<Target_Item__c>salesTargetitemSuccessInsertList = new List<Target_Item__c>();
        set<Id>targetItemIds = new set<Id>();
        List<Target_Measure__c>salesTargetMeasureInsertList = new List<Target_Measure__c>();
        String partyType;
        String targetItemRecId;
        Target_Measure__c targetItemMeasureRec;
        List<Target_Measure__c>updateTargetAggregateMeasureRecord = new List<Target_Measure__c>();
        set<Id>existingTargetItemId = new set<Id>();
        set<String>setPriceShipperConsigneeCode = new set<String>();
        set<String>setBrand = new set<String>();
        set<String>setCountryCode = new set<String>();
        set<String>setProductFamily = new set<String>();
        
        for(Target_Setting_Staging__c stag:stagingRecords){
           
            if(stag.Brand__c!=null){
                setBrand.add(stag.Brand__c);
            }  
            
            if(stag.Country_Code__c!=null){
                setCountryCode.add(stag.Country_Code__c);    
            }
            
            if(stag.Product_Family__c!=null){
                setProductFamily.add(stag.Product_Family__c);    
            }
        
            if(measureDimension == TargetSettingConstants.CY_ACTUALS || measureDimension == TargetSettingConstants.PY_ACTUALS){
                if(!String.isEmpty(stag.Price_Owner__c)){
                    setPriceShipperConsigneeCode.add(stag.Price_Owner__c);        
                }
                if(!String.isEmpty(stag.Shipper__c)){
                    setPriceShipperConsigneeCode.add(stag.Shipper__c);     
                }
                if(!String.isEmpty(stag.Consignee__c)){
                    setPriceShipperConsigneeCode.add(stag.Consignee__c);            
                }
            }
        }
        
        
        //method to exclude the staging the records
        stagingRecords = TargetSettingBatchHelper.stagingRecordsByExclusions(targetRec.Id,stagingRecords); 
        
        //mapping the staging records
        Map<Id,Target_Setting_Staging__c>mapStagingRecords = new Map<Id,Target_Setting_Staging__c>(stagingRecords);
        
        //method to retrive budget group records
        Map<String,Budget_Group__c>budgetGroupMap = TargetSettingBatchHelper.getBudgetGroupRecordsByStaging(targetRec.Id,stagingRecords,measureDimension,setBrand,setCountryCode,setProductFamily);
        
        //method to retrive sales target group records
        Map<String,Target_Item_Group__c>salesTargetItemGroupMap = TargetSettingBatchHelper.getSalesTargetGroupRecordsByStaging(targetRec.Id,setBrand,setCountryCode,setProductFamily);
        
        //method to retrive existing target item records
        Map<String,Target_Item__c>existingSalesTargetItemMap = TargetSettingBatchHelper.checkExistingItemForGroup(targetRec.Id,setBrand,setCountryCode,setProductFamily);
        
        //map to retrieve account based on price owner/shipper/consignee
        Map<String,Id>mapAccountByCustomerCode = new Map<String,Id>();
        
        //map to retrieve account based on price owner/shipper/consignee
        mapAccountByCustomerCode = TargetSettingBatchHelper.getAccountByCustomerCode(setPriceShipperConsigneeCode);
        
        //map to store aggregate measure values
        Map<Id,Target_Measure__c>mapAggregateMeasureValues = new Map<Id,Target_Measure__c>();
        
        for(Target_Setting_Staging__c stag:stagingRecords){
            
            
            if(stag.Brand__c!=null && stag.Country_Code__c!=null && stag.Product_Family__c!=null){
                //mapStagBrandFamilyCountry.put(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c,stag);    
                if(!mapStagBrandFamilyCountryRecords.containskey(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c)){
                    mapStagBrandFamilyCountryRecords.put(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c,new List<Target_Setting_Staging__c>{stag});    
                }
                else{
                    mapStagBrandFamilyCountryRecords.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).add(stag);
                }
            }
            
            if(measureDimension == TargetSettingConstants.BUDGET || measureDimension == TargetSettingConstants.ROLLING_FORECAST){
                measureExists = false;
                if(budgetGroupMap!=null && budgetGroupMap.containskey(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c) && budgetGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c)!=null){//Checking if existing budget group exist
                    mapBudgetStagingId.put(budgetGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id,budgetGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Staging_Reference__c);
                    for(Budget_Measure__c measureRec:budgetGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Sales_Budget_Measures__r){
                        if(stag.Measure_Type__c == measureRec.Measure_Type__c){
                            measureExists = true;
                            break;
                        }
                    } 
                    // measure exist
                    if(measureExists){
                        mapStagingRecords.get(stag.Id).status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                        mapStagingRecords.get(stag.Id).message__c = System.Label.stmeasureexist;
                    }
                    //Create measure record
                    else{
                        measureRecordsUpsertList.add(TargetSettingBatchHelper.createMeasureByStaging(budgetGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id,stag));
                        mapStagingRecords.get(stag.Id).status__c = TargetSettingConstants.STAGING_STATUS_PROCESSED;
                        mapStagingRecords.get(stag.Id).message__c = '';
                    }
                    
                }
                //Create `budget group
                else{
                    budgetGroupRecord = TargetSettingBatchHelper.createBudgetGroupRecord(targetRec.Id,stag);
                    budgetGroupUpsertList.add(budgetGroupRecord);
                }
                
            } 
            
            else if(measureDimension == TargetSettingConstants.CY_ACTUALS || measureDimension == TargetSettingConstants.PY_ACTUALS){
                //Check if Sales Target Group Exist
                if(salesTargetItemGroupMap!=null && salesTargetItemGroupMap.containskey(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c) && salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c)!=null){
                    
                    //Check if PO related Target item Record is created
                    if(stag.PO_Eligible__c && stag.Price_Owner__c!=null && mapAccountByCustomerCode!=null && mapAccountByCustomerCode.containskey(stag.Price_Owner__c) && mapAccountByCustomerCode.get(stag.Price_Owner__c)!=null){
                        if(existingSalesTargetItemMap!=null && existingSalesTargetItemMap.containskey(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Price_Owner__c)) && existingSalesTargetItemMap.get(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Price_Owner__c))!=null){ 
                            existingTargetItemId.add(existingSalesTargetItemMap.get(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Price_Owner__c)).Id);    
                        }
                        else{
                            salesTargetitemInsertList.add(TargetSettingBatchHelper.createSalesTargetItemRecord(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id,mapAccountByCustomerCode.get(stag.Price_Owner__c),stag.Id));    
                            
                        }
                    }  
                    
                    //Check if Shipper related Target item Record is created
                    
                    if(stag.Shipper_Eligible__c && stag.Shipper__c!=null && mapAccountByCustomerCode!=null && mapAccountByCustomerCode.containskey(stag.Shipper__c) && mapAccountByCustomerCode.get(stag.Shipper__c)!=null){
                        if(existingSalesTargetItemMap!=null && existingSalesTargetItemMap.containskey(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Shipper__c)) && existingSalesTargetItemMap.get(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Shipper__c))!=null){ 
                            existingTargetItemId.add(existingSalesTargetItemMap.get(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Shipper__c)).Id);    
                        }
                        else{
                            salesTargetitemInsertList.add(TargetSettingBatchHelper.createSalesTargetItemRecord(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id,mapAccountByCustomerCode.get(stag.Shipper__c),stag.Id));
                        }
                    }  
                    
                    
                    //Check if Consignee related Target item Record is created
                    
                    if(stag.Consignee_Eligible__c && stag.Consignee__c!=null && mapAccountByCustomerCode!=null && mapAccountByCustomerCode.containskey(stag.Consignee__c) && mapAccountByCustomerCode.get(stag.Consignee__c)!=null){
                        if(existingSalesTargetItemMap!=null && existingSalesTargetItemMap.containskey(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Consignee__c)) && existingSalesTargetItemMap.get(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Consignee__c))!=null){ 
                            existingTargetItemId.add(existingSalesTargetItemMap.get(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id+'-'+mapAccountByCustomerCode.get(stag.Consignee__c)).Id);   
                        }
                        else{
                            salesTargetitemInsertList.add(TargetSettingBatchHelper.createSalesTargetItemRecord(salesTargetItemGroupMap.get(stag.Brand__c+stag.Country_Code__c+stag.Product_Family__c).Id,mapAccountByCustomerCode.get(stag.Consignee__c),stag.Id));     
                        }
                    }  
                    
                     
                }
                
                //Both Sales Target Group & Budget Group Exist
                else{
                    mapStagingRecords.get(stag.Id).status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                    mapStagingRecords.get(stag.Id).message__c = 'No budget available for account actuals';    
                }
            }
        } 
        
        
        if(budgetGroupUpsertList!=null && budgetGroupUpsertList.size()>0){
        String errorMsg='';
            Database.UpsertResult[] results = Database.Upsert(budgetGroupUpsertList, false);
            for(Integer i=0; i< results.size();i++){
                errorMsg='';
                if(results[i].isSuccess()){
                    budgetGroupSuccessList.add(budgetGroupUpsertList.get(i));   
                    if(budgetGroupUpsertList[i].Id!=null && budgetGroupUpsertList[i].Staging_Reference__c!=null){
                        mapBudgetStagingId.put(budgetGroupUpsertList[i].Id,budgetGroupUpsertList[i].Staging_Reference__c);  
                    }
                    if(mapStagingRecords.containskey(budgetGroupUpsertList[i].Staging_Reference__c) && mapStagingRecords.get(budgetGroupUpsertList[i].Staging_Reference__c)!=null){
                        mapStagingRecords.get(budgetGroupUpsertList[i].Staging_Reference__c).Status__c = TargetSettingConstants.STAGING_STATUS_PROCESSED;   
                        mapStagingRecords.get(budgetGroupUpsertList[i].Staging_Reference__c).message__c = '';
                    }    
                } else {
                    for(Database.Error err : results[i].getErrors()) {
                        if(!errorMsg.contains(err.getMessage())){
                            errorMsg = errorMsg+err.getMessage();
                        }  
                    }
                    if(mapStagingRecords.containskey(budgetGroupUpsertList[i].Staging_Reference__c) && mapStagingRecords.get(budgetGroupUpsertList[i].Staging_Reference__c)!=null){
                        mapStagingRecords.get(budgetGroupUpsertList[i].Staging_Reference__c).Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                        mapStagingRecords.get(budgetGroupUpsertList[i].Staging_Reference__c).message__c = errorMsg;
                    }
                    
                    if (isUpdateStatus) isError = true;
                }
            }
        }
        budgetGroupUpsertList = null;
        
        //Insert measure record
        if(budgetGroupSuccessList.size()>0){
            for(Budget_Group__c budgetRec:budgetGroupSuccessList){
                if(mapStagingRecords.containskey(budgetRec.Staging_Reference__c) && mapStagingRecords.get(budgetRec.Staging_Reference__c)!=null){
                    measureRecordsUpsertList.add(TargetSettingBatchHelper.createMeasureByStaging(budgetRec.Id,mapStagingRecords.get(budgetRec.Staging_Reference__c)));
                }
            }
        }
        budgetGroupSuccessList = null;
        
        
        
        //Perform upsert on measure records
        if(measureRecordsUpsertList!=null && measureRecordsUpsertList.size()>0){
        String errorMsg='';
            Database.UpsertResult[] results = Database.Upsert(measureRecordsUpsertList, false);
            for(Integer i=0; i< results.size();i++){
                errorMsg='';
                if(results[i].isSuccess()){
                    if(mapBudgetStagingId!=null && mapBudgetStagingId.containskey(measureRecordsUpsertList[i].Budget_Group__c) && mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)!=null && mapStagingRecords.containskey(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)) && mapStagingRecords.get(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c))!=null){                           
                        mapStagingRecords.get(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)).Status__c =  TargetSettingConstants.STAGING_STATUS_PROCESSED;   
                        mapStagingRecords.get(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)).message__c = '';
                    }
                } else {
                    for(Database.Error err : results[i].getErrors()) {
                        if(!errorMsg.contains(err.getMessage())){
                            errorMsg = errorMsg+err.getMessage();
                        }    
                    }    
                    if(mapBudgetStagingId!=null && mapBudgetStagingId.containskey(measureRecordsUpsertList[i].Budget_Group__c) && mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)!=null && mapStagingRecords.containskey(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)) && mapStagingRecords.get(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c))!=null){
                        mapStagingRecords.get(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)).Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                        mapStagingRecords.get(mapBudgetStagingId.get(measureRecordsUpsertList[i].Budget_Group__c)).message__c = errorMsg;
                    }
                    
                    if (isUpdateStatus) isError = true;
                }
            }
        }
        measureRecordsUpsertList = null;
        
        
        //Insert Sales Target Item Record
        if(salesTargetitemInsertList!=null && salesTargetitemInsertList.size()>0){
            String processOnly ='';
            String errorMsg='';
            Database.SaveResult[] results = Database.Insert(salesTargetitemInsertList, false);   
            for(Integer i=0; i< results.size();i++){
                if(results[i].isSuccess()){
                    salesTargetitemSuccessInsertList.add(salesTargetitemInsertList.get(i));  
                    if(mapStagingRecords.containskey(salesTargetitemInsertList[i].Staging_Reference__c) && mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c)!=null){ 
                        mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c).Status__c = TargetSettingConstants.STAGING_STATUS_PROCESSED;  
                        mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c).message__c = '';
                    }   
                } else {
                    //processOnly = processOnly+','+salesTargetitemInsertList[i].Account__c;
                    processOnly = ','+salesTargetitemInsertList[i].Account__c;
                    
                    for(Database.Error err : results[i].getErrors()) {
                        if(!errorMsg.contains(err.getMessage())){
                            errorMsg = errorMsg+err.getMessage();
                        }
                    }   
                    if(mapStagingRecords.containskey(salesTargetitemInsertList[i].Staging_Reference__c) && mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c)!=null){ 
                        mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c).Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                        mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c).message__c = errorMsg;
                        
                        if(mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c).Process_Only__c!=null){
                            mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c).Process_Only__c += processOnly;
                        }
                        else{
                            mapStagingRecords.get(salesTargetitemInsertList[i].Staging_Reference__c).Process_Only__c = processOnly;
                        }
                        
                    }
                    if (isUpdateStatus) isError = true;
                }
            }
            
        }
        salesTargetitemInsertList = null;
        
        //Set to store newly created target item ids
        for(Target_Item__c targetItem:salesTargetitemSuccessInsertList){
            targetItemIds.add(targetItem.Id);
            
        }
        
        //method to retrive existing target item measure
        Map<String,Target_Measure__c>existingSalesTargetItemMeasureMap = TargetSettingBatchHelper.checkExistingMeasureForItem(existingTargetItemId);
        
        //Query new created target item records
        for(Target_Item__c itemRecord:[Select id,Sales_Target_Item_Group__c,Account__c,Sales_Target_Item_Group__r.BrandMnA__c,Sales_Target_Item_Group__r.Product_Family__c,Sales_Target_Item_Group__r.Country_Code__c from Target_Item__c where id=:targetItemIds OR id=:existingTargetItemId]){
            String key = itemRecord.Sales_Target_Item_Group__r.BrandMnA__c+itemRecord.Sales_Target_Item_Group__r.Country_Code__c+itemRecord.Sales_Target_Item_Group__r.Product_Family__c;
            
            if(mapStagBrandFamilyCountryRecords!=null && mapStagBrandFamilyCountryRecords.containskey(key) && mapStagBrandFamilyCountryRecords.get(key)!=null){
                for(Target_Setting_Staging__c stagRecord:mapStagBrandFamilyCountryRecords.get(key)){
                    
                    if(stagRecord.PO_Eligible__c){ 
                        partyType = TargetSettingConstants.PARTY_PO;
                        if(existingSalesTargetItemMeasureMap!=null && existingSalesTargetItemMeasureMap.containskey(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true) && existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true)!=null){
                            targetItemMeasureRec = existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true);  
                            if(mapAggregateMeasureValues!=null && mapAggregateMeasureValues.containskey(targetItemMeasureRec.Id) && mapAggregateMeasureValues.get(targetItemMeasureRec.Id)!=null){
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(mapAggregateMeasureValues.get(targetItemMeasureRec.Id),stagRecord));
                            }
                            else{
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));
                            }
                            //updateTargetAggregateMeasureRecord.add(TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));     
                        }
                        else{
                            salesTargetMeasureInsertList.add(TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(itemRecord.Id,stagRecord,partyType,true));    
                        }
                    }
                    if(!stagRecord.PO_Eligible__c){ 
                        
                        partyType = TargetSettingConstants.PARTY_PO;
                        
                        if(existingSalesTargetItemMeasureMap!=null && existingSalesTargetItemMeasureMap.containskey(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false) && existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false)!=null){
                            targetItemMeasureRec = existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false);                                
                            
                            if(mapAggregateMeasureValues!=null && mapAggregateMeasureValues.containskey(targetItemMeasureRec.Id) && mapAggregateMeasureValues.get(targetItemMeasureRec.Id)!=null){
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(mapAggregateMeasureValues.get(targetItemMeasureRec.Id),stagRecord));
                            }
                            else{
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));
                            }
                            //updateTargetAggregateMeasureRecord.add(TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));
                        }
                        else{
                            salesTargetMeasureInsertList.add(TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(itemRecord.Id,stagRecord,partyType,false));    
                        }
                    }
                    if(stagRecord.Shipper_Eligible__c){ 
                    
                        partyType = TargetSettingConstants.PARTY_SHIPPER;
                        
                        if(existingSalesTargetItemMeasureMap!=null && existingSalesTargetItemMeasureMap.containskey(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true) && existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true)!=null){
                            targetItemMeasureRec = existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true);                                
                            if(mapAggregateMeasureValues!=null && mapAggregateMeasureValues.containskey(targetItemMeasureRec.Id) && mapAggregateMeasureValues.get(targetItemMeasureRec.Id)!=null){
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(mapAggregateMeasureValues.get(targetItemMeasureRec.Id),stagRecord));
                            }
                            else{
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));
                            }
                            //updateTargetAggregateMeasureRecord.add(TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));      
                        }
                        else{
                            salesTargetMeasureInsertList.add(TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(itemRecord.Id,stagRecord,partyType,true));    
                        }
                    }
                    if(!stagRecord.Shipper_Eligible__c){ 
                        partyType = TargetSettingConstants.PARTY_SHIPPER;
                        if(existingSalesTargetItemMeasureMap!=null && existingSalesTargetItemMeasureMap.containskey(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false) && existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false)!=null){
                            targetItemMeasureRec = existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false);                                
                            if(mapAggregateMeasureValues!=null && mapAggregateMeasureValues.containskey(targetItemMeasureRec.Id) && mapAggregateMeasureValues.get(targetItemMeasureRec.Id)!=null){
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(mapAggregateMeasureValues.get(targetItemMeasureRec.Id),stagRecord));
                            }
                            else{
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));
                            }
                            //updateTargetAggregateMeasureRecord.add(TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord)); 
                        }
                        else{
                            salesTargetMeasureInsertList.add(TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(itemRecord.Id,stagRecord,partyType,false));    
                        }
                    }
                    if(stagRecord.Consignee_Eligible__c){ 
                        partyType = TargetSettingConstants.PARTY_CONSIGNEE;
                        if(existingSalesTargetItemMeasureMap!=null && existingSalesTargetItemMeasureMap.containskey(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true) && existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true)!=null){
                            targetItemMeasureRec = existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+true);                                
                            if(mapAggregateMeasureValues!=null && mapAggregateMeasureValues.containskey(targetItemMeasureRec.Id) && mapAggregateMeasureValues.get(targetItemMeasureRec.Id)!=null){
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(mapAggregateMeasureValues.get(targetItemMeasureRec.Id),stagRecord));
                            }
                            else{
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));
                            }
                            //updateTargetAggregateMeasureRecord.add(TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord)); 
                        }
                        else{
                            salesTargetMeasureInsertList.add(TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(itemRecord.Id,stagRecord,partyType,true));    
                        }
                    }
                    if(!stagRecord.Consignee_Eligible__c){ 
                        partyType = TargetSettingConstants.PARTY_CONSIGNEE;
                        if(existingSalesTargetItemMeasureMap!=null && existingSalesTargetItemMeasureMap.containskey(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false) && existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false)!=null){
                            targetItemMeasureRec = existingSalesTargetItemMeasureMap.get(itemRecord.Id+stagRecord.Measure_Dimension__c+partyType+stagRecord.Measure_Type__c+false);                                
                            if(mapAggregateMeasureValues!=null && mapAggregateMeasureValues.containskey(targetItemMeasureRec.Id) && mapAggregateMeasureValues.get(targetItemMeasureRec.Id)!=null){
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(mapAggregateMeasureValues.get(targetItemMeasureRec.Id),stagRecord));
                            }
                            else{
                                mapAggregateMeasureValues.put(targetItemMeasureRec.id,TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord));
                            }
                            //updateTargetAggregateMeasureRecord.add(TargetSettingBatchHelper.updateAggregateMeasureRecord(targetItemMeasureRec,stagRecord)); 
                        }
                        else{
                            salesTargetMeasureInsertList.add(TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(itemRecord.Id,stagRecord,partyType,false));    
                        }
                    }
                }     
            }  
        }
        
        
        if(mapAggregateMeasureValues.values().size()>0){
            updateTargetAggregateMeasureRecord.addall(mapAggregateMeasureValues.values());    
        }
        
        if(salesTargetMeasureInsertList!=null && salesTargetMeasureInsertList.size()>0){
            String processOnly ='';
            String errorMsg='';
            Database.SaveResult[] results = Database.Insert(salesTargetMeasureInsertList, false);   
            for(Integer i=0; i< results.size();i++){
                if(results[i].isSuccess()){  
                    if(mapStagingRecords.containskey(salesTargetMeasureInsertList[i].Staging_Reference__c) && mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c)!=null){ 
                        mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c).Status__c = TargetSettingConstants.STAGING_STATUS_PROCESSED;  
                        mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c).message__c = '';
                    }   
                } else {
                    processOnly = ','+salesTargetMeasureInsertList[i].Target_Item__c+salesTargetMeasureInsertList[i].Measure_Type__c+salesTargetMeasureInsertList[i].Party_Type__c+salesTargetMeasureInsertList[i].Credit_Eligible__c;
                    
                    for(Database.Error err : results[i].getErrors()) {
                        if(!errorMsg.contains(err.getMessage())){
                            errorMsg = errorMsg+err.getMessage();
                        }
                    }   
                    if(mapStagingRecords.containskey(salesTargetMeasureInsertList[i].Staging_Reference__c) && mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c)!=null){ 
                        mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c).Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                        mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c).message__c = errorMsg;
                        
                        if(mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c).ProcessOnlyTargetItemMeasure__c!=null){
                            mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c).ProcessOnlyTargetItemMeasure__c += processOnly;
                        } else{
                            mapStagingRecords.get(salesTargetMeasureInsertList[i].Staging_Reference__c).ProcessOnlyTargetItemMeasure__c = processOnly;
                        }
                        
                    }
                    if (isUpdateStatus) isError = true;
                }
            }
        }
        salesTargetMeasureInsertList = null;
        
        //Aggregate measure record
        if(updateTargetAggregateMeasureRecord!=null && updateTargetAggregateMeasureRecord.size()>0){ 
            List<String>stageref = new List<String>();
            String processOnly ='';
            String errorMsg='';
            Database.SaveResult[] results = Database.update(updateTargetAggregateMeasureRecord, false);   
            for(Integer i=0; i< results.size();i++){
                if(updateTargetAggregateMeasureRecord[i].Staging_Reference__c!=null){
                        stageref = updateTargetAggregateMeasureRecord[i].Staging_Reference__c.split(',');
                    }
                if(results[i].isSuccess()){  
                    for(String str:stageref){
                        if(str!='null'){
                            if(mapStagingRecords.containskey(str) && mapStagingRecords.get(str)!=null){ 
                                if(mapStagingRecords.get(str).Status__c != TargetSettingConstants.STAGING_STATUS_PROCESSED){
                                    mapStagingRecords.get(str).Status__c = TargetSettingConstants.STAGING_STATUS_PROCESSED;  
                                    mapStagingRecords.get(str).message__c ='';
                                }
                            } 
                          }  
                        }
                } else {
                    processOnly = ','+updateTargetAggregateMeasureRecord[i].Target_Item__c+updateTargetAggregateMeasureRecord[i].Measure_Type__c+updateTargetAggregateMeasureRecord[i].Party_Type__c+updateTargetAggregateMeasureRecord[i].Credit_Eligible__c;
                    
                    for(Database.Error err : results[i].getErrors()) {
                        if(!errorMsg.contains(err.getMessage())){
                            errorMsg = errorMsg+err.getMessage();
                        }
                    }   
                    for(String str:stageref){
                    if(str!='null'){
                        if(mapStagingRecords.containskey(str) && mapStagingRecords.get(str)!=null){ 
                            if(mapStagingRecords.get(str).Status__c != TargetSettingConstants.STAGING_STATUS_FAILED){
                                mapStagingRecords.get(str).Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                                mapStagingRecords.get(str).message__c = errorMsg;
                                
                                if(mapStagingRecords.get(str).ProcessOnlyTargetItemMeasure__c!=null){
                                    mapStagingRecords.get(str).ProcessOnlyTargetItemMeasure__c += processOnly;
                                }
                                else{
                                    mapStagingRecords.get(str).ProcessOnlyTargetItemMeasure__c = processOnly;
                                }
                            }
                          }  
                    }
                    if (isUpdateStatus) isError = true;
                    }
                }
            }
        }
        updateTargetAggregateMeasureRecord = null;
        
        //update staging record  
        if(mapStagingRecords.values()!= null && mapStagingRecords.values().size()>0){
            Database.SaveResult[] results = Database.update(mapStagingRecords.values(), false);
        } 
    }
    
    public void finish(Database.BatchableContext bc) {
    AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email  from AsyncApexJob where Id =:BC.getJobId()];
        if (isUpdateStatus) {
            Target__c target = new Target__c();
            target.Id = targetId;
            if (isError || a.NumberOfErrors>0) {
                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_FAILED;
            } else {
                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_COMPLETED;
            }
            Database.SaveResult[] lstUpdateResults = Database.update(new List<Target__c>{target}, false);
            ErrorLogger.writeErrors('SFDC', 'Target Update', 'TargetSettingBaseDataBatch', lstUpdateResults, new List<Target__c>{target});
        }
        if(isError || a.NumberOfErrors>0){
            TargetSettingBatchHelper.sendEmail(TargetSettingConstants.STAGE_STATUS_FAILED,measureDimension,targetOwnerEmailId);
        }
        else{
            TargetSettingBatchHelper.sendEmail(TargetSettingConstants.STAGE_STATUS_COMPLETED,measureDimension,targetOwnerEmailId);
        }
    }    
}