/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0       06-Jul-2023     Shubham@Maersk          Mass transfer TAAs from CSV file
* 2.0       18-Sep-2023     Shubham@Maersk          Correct Error Message
*/

public class MassTransferCSVController {
    
    public static Map<String,ResponseResultWrapper> mapIdToWrap = new Map<String,ResponseResultWrapper>();
    
    @AuraEnabled
    public static projectResponseWrapper uploadData(String data) {
        List<String> finalRecords = new List<String>();
        List<String> templateColumns = new List<String>();
        Set<String> taaNumberSet = new Set<String>();
        Set<String> portMaerskUserIdSet = new Set<String>();
        List<Territory_Account_Association__c> transferRecsToInsert = new List<Territory_Account_Association__c>();
        List<Territory_Account_Association__c> filterTransferListToInsert = new List<Territory_Account_Association__c>();
        List<Territory_Account_Association__c> selectedRecsToUpdate = new List<Territory_Account_Association__c>();
        List<ResponseResultWrapper> responseWrapperList = new List<ResponseResultWrapper>();
        Map<String, Territory_Account_Association__c> mapIdToKey = new Map<String, Territory_Account_Association__c>();
        Map<String, Date> mapIdToKeyDate = new Map<String, Date>();
        ProjectResponseWrapper resWrapper = new ProjectResponseWrapper();
        List<String> records = data.split('],');
        if (records.size() -1 >=1) {
            resWrapper.totalRecords = records.size() -1;    
        }
        
        if(records != null) {
            for(String columns: records[0].split(',')){
                if(columns != null){
                    templateColumns.add(columns.replace('"','').replace('[','').trim()); 
                }            
            }
            for(Integer i=1; i<=records.size()-1; i++){
                String taaData = records[i].replace('[','').replace('"','').replace(']','');
                if (String.isNotBlank(taaData)) {
                    if (taaData.right(1) == ',') taaData += ' ';
                    List<String> templateData = taaData.split(',');
                    if(templateData != null && templateData.size()>0){
                        Integer index = 0;
                        Boolean hasError = false;
                        ResponseResultWrapper wrap = new ResponseResultWrapper();
                        for(String templateField: templateData){
                            templateField = templateField.trim();
                            if (!String.isBlank(templateField)) {
                                if (templateColumns[index].toUpperCase().contains(LABEL.Mass_Transfer_Header_1.toUpperCase())) {
                                    wrap.taaNumber = templateField;
                                    taaNumberSet.add(templateField);
                                } else if (templateColumns[index].toUpperCase().contains(LABEL.Mass_Transfer_Header_2.toUpperCase())) {
                                    wrap.portfolioMaerskUserId = templateField;
                                    portMaerskUserIdSet.add(templateField);
                                } else {
                                    getDate(templateField,wrap);
                                    if (String.isNotBlank(wrap.responseMessage)) {
                                        hasError = true;
                                    }
                                    wrap.startDate = templateField;
                                }
                            } else if (templateColumns[index].toUpperCase().contains(LABEL.Mass_Transfer_Header_1.toUpperCase()) || templateColumns[index].toUpperCase().contains(LABEL.Mass_Transfer_Header_2.toUpperCase())){
                                wrap.responseMessage = LABEL.Mass_Transfer_Header_1 + ' and ' + LABEL.Mass_Transfer_Header_2 + ' is required. ';
                                hasError = true;
                            }
                            index++;
                        }
                        if (hasError) {
                            resWrapper.totalFailureRecords++;
                            responseWrapperList.add(wrap);
                        } else {
                            finalRecords.add(records[i]);
                        }
                    }
                }
            }
            
            if (finalRecords.size() > 0) {
                
                Map<String,Territory_Account_Association__c> taaNumberToTAAMap = new Map<String,Territory_Account_Association__c>();
                Map<Id, Territory_Account_Association__c> mapOfTAA = new Map<Id, Territory_Account_Association__c>();
                if (taaNumberSet.size() > 0) {
                    //Using Dynamic query to clone all the records
                    string tAAquery = SOQLUtility.getSelectQueryAvoidFormulaSystemFields(new Territory_Account_Association__c());
                    tAAquery = 'Select ' + tAAquery + ' ,Territory__r.Name, Name, Account__r.Name from Territory_Account_Association__c';
                    tAAquery = tAAquery + ' WHERE Name IN :taaNumberSet';
                    
                    mapOfTAA = new Map<Id, Territory_Account_Association__c>((List<Territory_Account_Association__c>)Database.query(tAAquery));
                    for (Territory_Account_Association__c taa : mapOfTAA.values()) {
                        taaNumberToTAAMap.put(taa.Name.toUpperCase(),taa);
                    }   
                }
                
                List<Territory__c> territoryList = new List<Territory__c>();
                Map<String,Territory__c> maerskIdToTerritoryMap = new Map<String,Territory__c>();
                if (portMaerskUserIdSet.size() > 0) {
                    territoryList = [SELECT Id, Portfolio_Owner__r.Maersk_User_Id__c FROM Territory__c where Portfolio_Owner__r.Maersk_User_Id__c IN :portMaerskUserIdSet];
                    for (Territory__c ts :territoryList) {
                        maerskIdToTerritoryMap.put(ts.Portfolio_Owner__r.Maersk_User_Id__c.toUpperCase(),ts);
                    }
                }
                
                for(Integer i=0; i<finalRecords.size(); i++){
                    String taaData = finalRecords[i].replace('[','').replace('"','').replace(']','');
                    if (taaData.right(1) == ',') taaData += ' ';
                    List<String> templateData = taaData.split(',');
                    ResponseResultWrapper wrap = new ResponseResultWrapper();
                    wrap.responseMessage = '';
                    Boolean hasError = false;
                    if(templateData != null && templateData.size()>0){
                        Integer index = 0;
                        for(String templateField: templateData){
                            templateField = templateField.trim();
                            if (!String.isBlank(templateField)) {
                                if (templateColumns[index].toUpperCase().contains(LABEL.Mass_Transfer_Header_1.toUpperCase())) {
                                    if (taaNumberToTAAMap.isEmpty() || !taaNumberToTAAMap.containsKey(templateField.toUpperCase())) {
                                        hasError = true;
                                        wrap.responseMessage += LABEL.Mass_Transfer_Header_1 + ' is Invalid. ';
                                    }
                                    wrap.taaNumber = templateField;
                                } else if (templateColumns[index].toUpperCase().contains(LABEL.Mass_Transfer_Header_2.toUpperCase())) {
                                    if (maerskIdToTerritoryMap.isEmpty() || !maerskIdToTerritoryMap.containsKey(templateField.toUpperCase())) {
                                        hasError = true;
                                        wrap.responseMessage += 'No Active Territory with given portfolio maersk user Id. ';
                                    }
                                    wrap.portfolioMaerskUserId = templateField;
                                } else {
                                    getDate(templateField,wrap);
                                    if (String.isNotBlank(wrap.responseMessage)) {
                                        hasError = true;
                                    }
                                    wrap.startDate = templateField;
                                }
                            }
                            index++;
                        }
                        if (hasError) {
                            resWrapper.totalFailureRecords++;
                            responseWrapperList.add(wrap);
                        } else {
                            Territory_Account_Association__c cloneRec = new Territory_Account_Association__c();
                            Territory_Account_Association__c rec = taaNumberToTAAMap.get(wrap.taaNumber.toUpperCase());
                            cloneRec = rec.clone(false,false,false,false);
                            cloneRec.Start_Date__c = getDate(wrap.startDate,wrap);
                            cloneRec.Territory__c = maerskIdToTerritoryMap.get(wrap.portfolioMaerskUserId.toUpperCase()).Id;
                            cloneRec.End_Date__c = null;
                            transferRecsToInsert.add(cloneRec);
                            String strkey = rec.Account__c + '_' + rec.Brand__c+'_'+rec.Portfolio_Owner_Responsibility__c+'_'+rec.Product_Responsibility__c+'_'+rec.Territory__r.Name+'_'+rec.Business_Defined_Area__c+'_'+rec.Country__c;
                            mapIdToKeyDate.put(strkey, rec.End_Date__c);
                            //Assigning selected TAAs with End Date of selected Start Date - 1
                            rec.End_Date__c = cloneRec.Start_Date__c != null ? cloneRec.Start_Date__c.addDays(-1) : null;
                            mapIdToKey.put(strkey, rec);
                            selectedRecsToUpdate.add(rec);
                            mapIdToWrap.put(strkey,wrap);
                        }
                    }
                }
                
                //Update selected TAAs with End Date of selected Start Date - 1
                if(!selectedRecsToUpdate.isEmpty()) {
                    List<Database.SaveResult> updateResults = Database.update(selectedRecsToUpdate, false);
                    for (Integer i = 0; i < updateResults.size(); i++) {
                        Database.SaveResult result = updateResults[i];
                        if (!result.isSuccess()) {
                            String errorMsg = '';
                            for(Database.Error err : result.getErrors()) {
                                errorMsg = errorMsg + err.getMessage();
                            }
                            if (String.isNotBlank(errorMsg)) {
                                String strKey = transferRecsToInsert[i].Account__c + '_' + transferRecsToInsert[i].Brand__c+'_'+transferRecsToInsert[i].Portfolio_Owner_Responsibility__c+'_'+transferRecsToInsert[i].Product_Responsibility__c+'_'+transferRecsToInsert[i].Territory__r.Name+'_'+transferRecsToInsert[i].Business_Defined_Area__c+'_'+transferRecsToInsert[i].Country__c;
                                if (mapIdToKey.containskey(strKey)) {
                                    ResponseResultWrapper wrap = getWrapper(strKey, errorMsg);
                                    resWrapper.totalFailureRecords++;
                                    responseWrapperList.add(wrap);
                                }
                            }
                        } else {
                            filterTransferListToInsert.add(transferRecsToInsert[i]);
                        }
                    }
                }
                
                //clone selected TAAs
                List<Database.SaveResult> insertResults = Database.insert(filterTransferListToInsert, false);
                
                mapOfTAA = new Map<Id, Territory_Account_Association__c>(); 
                
                for (Integer i = 0; i < insertResults.size(); i++) {
                    Database.SaveResult result = insertResults[i];
                    String strKey = filterTransferListToInsert[i].Account__c + '_' + filterTransferListToInsert[i].Brand__c+'_'+filterTransferListToInsert[i].Portfolio_Owner_Responsibility__c+'_'+filterTransferListToInsert[i].Product_Responsibility__c+'_'+filterTransferListToInsert[i].Territory__r.Name+'_'+filterTransferListToInsert[i].Business_Defined_Area__c+'_'+filterTransferListToInsert[i].Country__c;
                    String responseMsg = '';
                    if (mapIdToKey.containskey(strKey)) {
                        if (!result.isSuccess()) {
                            for(Database.Error err : result.getErrors()) {
                                if (err.getMessage().tolowerCase().contains('invalid date')) {
                                    responseMsg = responseMsg + LABEL.Mass_Transfer_Invalid_Date_Error;
                                } else {
                                    responseMsg = responseMsg + err.getMessage();   
                                }
                            }
                            mapOfTAA.put(mapIdToKey.get(strKey).Id,new Territory_Account_Association__c(Id = mapIdToKey.get(strKey).Id, End_Date__c = mapIdToKeyDate.get(strKey)));
                            resWrapper.totalFailureRecords++;
                        } else {
                            responseMsg = 'Record Transfer Successfully';
                            resWrapper.totalSuccessRecords++;
                        }
                        ResponseResultWrapper wrap = getWrapper(strKey, responseMsg);
                        responseWrapperList.add(wrap);
                    }
                }
                
                //Reverting End date of selected TAAs if transfer opertion is failed.
                system.debug('selectedRecsToUpdate Failure####'+mapOfTAA.values());
                if(!mapOfTAA.isEmpty()){
                    Database.update(mapOfTAA.values(), false);
                }
            }
        }
        resWrapper.recordsList = responseWrapperList;
        return resWrapper;
    }
    
    public static ResponseResultWrapper getWrapper(String strKey, String responseMsg) {
        ResponseResultWrapper wrap = new ResponseResultWrapper();
        wrap.taaNumber = mapIdToWrap.get(strKey).taaNumber;
        wrap.portfolioMaerskUserId = mapIdToWrap.get(strKey).portfolioMaerskUserId;
        wrap.startDate = mapIdToWrap.get(strKey).startDate;
        wrap.responseMessage = responseMsg;
        return wrap;
    }
    
    public static Date getDate(String val, ResponseResultWrapper wrap) {
        Boolean isError = false;
        try {
            if (String.isNotEmpty(val)) {
                List<String> dateList = val.split('/');
                if (dateList.size() == 3) {
                    return Date.valueOf(dateList[2] + '-' + dateList[1] + '-' + dateList[0]);
                } else {
                    isError = true;
                }
            } else {
                return null;
            }
        } catch (Exception ex) {
            isError = true;
        }
        if(isError) {
            wrap.responseMessage = LABEL.Mass_Transfer_Invalid_Date_Error + '. ';
        }
        return null;
    }
    
    public class ProjectResponseWrapper{
        @AuraEnabled public Integer totalRecords = 0;
        @AuraEnabled public Integer totalSuccessRecords = 0;
        @AuraEnabled public Integer totalFailureRecords = 0;
        @AuraEnabled public  List<ResponseResultWrapper> recordsList;
    }
    
    public class ResponseResultWrapper{
        @AuraEnabled public  String taaNumber;
        @AuraEnabled public  String portfolioMaerskUserId;		   						
        @AuraEnabled public  String startDate;					
        @AuraEnabled public  String responseMessage;  						
    }
    
}