/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -------------           --------------
* 1.0      SFSE-13423  30-Jan-2024    Vinay                  Added Access Modifer to Class and added code to return MetaData records from getConfigs and getConfiguration methods.  
* 2.0      SFSE-13747                 Arpitha J              Added the logic modification to uploadData method.
*/ 
public with sharing class DataImportController {
    
    public static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    
    @AuraEnabled(cacheable=true)
    public static List<Data_Import_Setup__mdt> getConfigs() {
        
        //List<Map<String,String>> options = new List<Map<String,String>>();
        //List<Data_Import_Setup__mdt> dataImportList = [SELECT Id,Label,DeveloperName,Permission_Name__c,Create__c,Update__c FROM Data_Import_Setup__mdt WHERE isActive__c = true];
        List<Data_Import_Setup__mdt> dataImportList = new List<Data_Import_Setup__mdt>();
        List<String> configList = new List<String>();
        Map<String,String> labelToDeveloperNameMap = new Map<String,String>();
        for (Data_Import_Setup__mdt data : [SELECT Id,Label,DeveloperName,Permission_Name__c,Create__c,Update__c FROM Data_Import_Setup__mdt WHERE isActive__c = true ORDER BY Label]) {
            if (data.Permission_Name__c != null) {
                Boolean hasPermission = FeatureManagement.checkPermission(data.Permission_Name__c);
                if (hasPermission) {
                    /*labelToDeveloperNameMap.put(data.Label, data.DeveloperName);
                    configList.add(data.Label);  */
                    dataImportList.add(data);
                }    
            }
        }
        /*if (configList.size() > 0) {
            configList.sort();
            for (String str : configList) {
                Map < String, String > values = new Map < String, String > {
                    'label' => str,
                        'value' => labelToDeveloperNameMap.get(str)
                        };
                            options.add(values);
            }
        }*/
        
        return dataImportList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Data_Import_Setup__mdt> getConfiguration(String config) {
        
        //List<Map<String,String>> options = new List<Map<String,String>>();
        //List<Data_Import_Setup__mdt> dataImportList = [SELECT Id,Label,DeveloperName,Permission_Name__c,Create__c,Update__c FROM Data_Import_Setup__mdt WHERE isActive__c = true AND DeveloperName =:config];
        List<Data_Import_Setup__mdt> dataImportList = new List<Data_Import_Setup__mdt>();
        Map<String,String> labelToDeveloperNameMap = new Map<String,String>();
        for (Data_Import_Setup__mdt data : [SELECT Id,Label,DeveloperName,Permission_Name__c,Create__c,Update__c FROM Data_Import_Setup__mdt WHERE isActive__c = true AND DeveloperName =:config]) {
            if (data.Permission_Name__c != null) {
                Boolean hasPermission = FeatureManagement.checkPermission(data.Permission_Name__c);
                if (hasPermission) {
                   dataImportList.add(data); 
                   /* Map < String, String > values = new Map < String, String > {
                        'label' => data.Label,
                            'value' => data.DeveloperName
                            };
                                options.add(values);*/
                }
            }
        }
        return dataImportList;
    }
    
    @AuraEnabled(cacheable=true)
    public static String validateHeaders(String config, String headers) {
        String message = '';
        if (config != null && headers != null) {
            List<String> headerList = (List<String>)System.JSON.deserialize(headers, List<String>.class);
            
            List<Data_Import_Setup__mdt> dataImportList = [SELECT Id, DeveloperName, Import_Object__c from Data_Import_Setup__mdt WHERE DeveloperName = :config];
            
            List<Data_Import_Staging__mdt> dataImportMappingList = [SELECT Template_Column_Name__c FROM Data_Import_Staging__mdt WHERE Data_Load_Setup__c = :dataImportList[0].Id];
            
            Set<String> templateNameSet = new Set<String>();
            for (Data_Import_Staging__mdt data : dataImportMappingList) {
                templateNameSet.add(data.Template_Column_Name__c.toLowerCase());
            }
            for (String header : headerList) {
                if (!templateNameSet.contains(header.toLowerCase().trim())) {
                    if (String.isBlank(header.trim())) {
                        message = Label.Data_Import_Msg_3;
                        break;
                    } else {
                        if (String.isBlank(message)) {
                            message = Label.Data_Import_Msg_2 + ' ' + header.trim();
                        } else {
                            message += ', ' + header.trim();
                        }
                    }  
                }
            }       
        }
        return message;
    }
    
    @AuraEnabled
    public static void uploadData(String config, String operation,List<List<String>> data ) {
        List<String> templateColumns = new List<String>();
        List<sObject> recordsInsertList = new List<sObject>();
        Set<string> dataImportFields = new Set<string>();
        Map<String,String> templateStgFieldMap = new Map<string,string>();
        Map<String,String> templatetoFieldAPIMap = new Map<String,string>();        
        Id intermediateObj;
        String objApiName;
        
        for(String columns: data[0]){
            if(columns != null){
                templateColumns.add((columns.replace('"','').replace('[','')).trim()); 
            }            
        }
        List<Data_Import_Staging__mdt> listDataStaging = DataImportUtilityClass.getIntermediateMetaData(config,templateColumns);
        if(listDataStaging != null){
            for(Data_Import_Staging__mdt dataStaging: listDataStaging){
                templateStgFieldMap.put(dataStaging.Source_Field__c,dataStaging.Template_Column_Name__c);
                intermediateObj = dataStaging.Source_Object__c;  
            }
        }
        
        if(intermediateObj != null){
            objApiName = [SELECT Id, QualifiedApiName, DurableId FROM EntityDefinition WHERE DurableId =:intermediateObj].QualifiedApiName;
        }
        
        List<FieldDefinition> listFieldDefinitions = new List<FieldDefinition>();
        if(templateStgFieldMap.keyset()!= null){
            listFieldDefinitions = DataImportUtilityClass.getFieldDefinition(templateStgFieldMap.keyset());
        }
        
        if(listFieldDefinitions != null){
            for(FieldDefinition field:listFieldDefinitions){
                if(templateStgFieldMap.get(field.DurableId) != null){
                    templatetoFieldAPIMap.put(templateStgFieldMap.get(field.DurableId), field.QualifiedApiname);
                }
            }
        }
        if(data != null) {
            for(Integer i=1; i<=data.size()-1; i++){
                //String str = records[i].replace('[','').replace('"','').replace(']','');
                //if (String.isNotBlank(str)) {
                    //if (str.right(1) == ',') str += ' ';
                    List<String> templateData = new List<String>();
                    templateData = data[i];
                    system.debug('==templateData=='+templateData);
                    if(templateData != null && templateData.size()>1) {
                        sObject sObj = globalDescribe.get(objApiName).newSObject();
                        sObj.put('Operations__c',operation);
                        sObj.put('Config__c',config);
                        sObj.put('Status__c','New');
                        Integer index = 0;
                        for(String templateField: templateColumns){
                            System.debug('==index=='+index+'==templateData=='+templateData);
                            system.debug('==templateData[index]=='+templateData[index]);
                            if(templatetoFieldAPIMap.get(templateField) != null){   
                                sObj.put(templatetoFieldAPIMap.get(templateField), templateData[index].trim());
                                index++;                       
                            }
                        }
                        recordsInsertList.add(sObj);
                    }    
                }
        }
        
        if(!recordsInsertList.isEmpty()){
            insert(recordsInsertList);
            Set<String> recordIdSet = new Set<String>();
            for (sObject sobj : recordsInsertList) {
                recordIdSet.add((String)sobj.get('Id'));
            }
            Database.executeBatch(new Batch_DataImport(recordIdSet, config, templateColumns, operation), Integer.valueOf(Label.Data_Import_Batch_Size));
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getReportId() {
        return [SELECT Id FROM Report WHERE Name = :Label.Data_Import_Report]?.Id;
    }    
}