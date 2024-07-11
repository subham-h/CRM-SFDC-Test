/*              
* Revision Ref Number  Date          Owner                 Description
* -------- ----------  -----------   -----------------     -----------
* 1.0      SFSE-10882  27-June-2023   Shubham              Utility Class used in Batch_DataImport(Mass upload framework)
* 2.0      SFSE-13447  04-Dec-2023    Seba                 Modified for tech debt 
*/

//SFSE-13447 Added without sharing keyword 
public without sharing class DataImportUtilityClass{
    
 	public static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
 
    
    /*
    * This method is used to fetch the custom metadata type records  
    * @param config - configuration value to get the data import setup metadata  
    * @param headers - header list to fetch the data import staging records
    * @return List<Data_Import_Staging__mdt> - List of data import staging metadata records
    */  
    public static List<Data_Import_Staging__mdt> getIntermediateMetaData(String config, List<String> headers){    
        Data_Import_Setup__mdt setupMdt = Data_Import_Setup__mdt.getInstance(config);
        List<Data_Import_Staging__mdt> listStagingMdt = new  List<Data_Import_Staging__mdt>(); 
        if(setupMdt != null){ 
            listStagingMdt = [SELECT Id,Source_Object__c,Source_Field__c,Template_Column_Name__c,
                              Target_Object__c,Target_Field__c,Target_Field_Reference_Identifier__c,Target_Object_Reference_Identifier__c, Query_Filter_Condition__c  
                              FROM Data_Import_Staging__mdt WHERE Data_Load_Setup__c=:setupMdt.Id AND Template_Column_Name__c IN :headers]; 
        } 
        return listStagingMdt;
    }
    
    
    /*
    * This method is used to get the API names for the custom metadata field values 
    * @param fields -  set of object fields 
    * @return List<FieldDefinition> - list of field definitions for the custom metadata field values
    */   
    public static List<FieldDefinition> getFieldDefinition(Set<String> fields){
        List<FieldDefinition> definitions = new List<FieldDefinition>();
        if(fields != null){    
            for(FieldDefinition field: [SELECT Id,QualifiedApiname,DurableId FROM FieldDefinition WHERE DurableId IN:fields]){
                definitions.add(field);
            }
        }
        return definitions;
    }
    
    /*
    * This method is used to map the staging data to the target object
    * @param interRecords - list of data import mapping object records 
    * @param config - configuration value to get the data import setup metadata  
    * @param headers - header list to fetch the data import staging records
    * @return DataWrapper - Data wrapper which holds the target and source object with error results 
    */    
    public DataWrapper processIntermediateRecords(List<sObject> interRecords, String config, List<String> headers){ 
        
        List<sObject> targetRecords = new List<sObject>();
        List<sObject> sourceRecords = new List<sObject>();
        List<sObject> errorRecords = new List<sObject>();
        List<Data_Import_Staging__mdt> intermediateData = getIntermediateMetaData(config, headers);
        
        Id targetObj = intermediateData[0].Target_Object__c;        
        String targetObjApiName = [SELECT Id, QualifiedApiName, DurableId FROM EntityDefinition WHERE DurableId =:targetObj].QualifiedApiName;
        Map<String, Schema.DisplayType> fieldAPIToTypeMap = getFieldTypes(targetObjApiName);
        Set<String> fieldsInfo = new Set<String>();        
        for(Data_Import_Staging__mdt inter: intermediateData){
            fieldsInfo.add(inter.Source_Field__c);
            fieldsInfo.add(inter.Target_Field__c);
        }
        Map<String,String> fieldAPIMap = new Map<String,String>();
        if(fieldsInfo != null){ 
            for(FieldDefinition field: [SELECT Id,QualifiedApiname,DurableId FROM FieldDefinition WHERE DurableId IN:fieldsInfo]) {
                fieldAPIMap.put(field.DurableId, field.QualifiedApiname);
            }
        }
        
        Map<String, List<String>> lookupAndDataMap = new Map<String,List<string>>();
        for(sObject sobj: interRecords) {
            for(Data_Import_Staging__mdt inter: intermediateData){
                if(inter.Target_Field_Reference_Identifier__c != null) {
                    String lookupFieldsApiName = fieldAPIMap.get(inter.Source_Field__c);
                    String data = (string)sobj.get(lookupFieldsApiName);
                    String key = inter.Target_Object_Reference_Identifier__c+inter.Target_Field_Reference_Identifier__c; 
                    if(lookupAndDataMap.containskey(key)) {
                        lookupAndDataMap.get(key).add(data); 
                    } else {
                        lookupAndDataMap.put(key, new List<String>{data}); 
                    }
                }
            }
        }
        
        Map<String, Id> lookupdata = new Map<String, Id>();  
        for(Data_Import_Staging__mdt inter: intermediateData){
            if(inter.Target_Field_Reference_Identifier__c != null) {
                
                String objApiName = inter.Target_Object_Reference_Identifier__c;
                String fieldApiName = inter.Target_Field_Reference_Identifier__c;
                List<string> data = new List<string>(); 
                //SFSE-13447 Replaced with Ternary operator
                data = lookupAndDataMap.get(objApiName+fieldApiName) != null ? lookupAndDataMap.get(objApiName+fieldApiName) : new List<string>();
                
                String value;
                String query;
                Schema.DisplayType fieldDataType;
                if(data != null) {
                    fieldDataType = getFieldType(objApiName, fieldApiName);
                    //SFSE-13447 Added switch statments to replace nested if
                    switch on fieldDataType { 
                        when Integer {		 
                            List<Integer> dataIntList = getIntList(data); 
                            //SFSE-13447  Replaced with ternary operator
                            query = dataIntList.size() > 0 ? 'SELECT Id,'+ fieldApiName +' FROM '+ objApiName +' WHERE '+ fieldApiName +' IN :dataIntList' : NULL;                            }	
                        when Double {		 
                            List<Double> dataDoubleList = getDoubleList(data); 
                            //SFSE-13447  Replaced with ternary operator
                            query = dataDoubleList.size() > 0 ? 'SELECT Id,'+fieldApiName+' FROM '+objApiName+' WHERE '+fieldApiName+' IN :dataDoubleList' : NULL;
                        }
                        when else {		 
                            data = getFilterValues(data);
                            //SFSE-13447 Replaced with ternary operator
                            value = data.size() > 0 ? '(\'' + String.join(data, '\',\'') + '\')' : NULL; 
                            query = data.size() > 0 && value != NULL ? 'SELECT Id,'+fieldApiName+' FROM '+objApiName+' WHERE '+fieldApiName+' IN '+  value : query;    
                             
                        } 
                    }
                    query = String.isNotBlank(inter.Query_Filter_Condition__c) && String.isNotBlank(query) ? query + ' AND ' + inter.Query_Filter_Condition__c : query;
                    
                }
                List<sObject> records = new List<sObject>();
                if (String.isNotBlank(query)) {
                    records = Database.query(query);
                    if(!records.isEmpty()){
                        for(sObject sObj: records) {
                            if(fieldApiName.contains('.')) {
                                Sobject referenceSobj =  sObj;
                                String[] parentReferences = fieldAPIName.split('\\.'); 
                                while(parentReferences.size() > 1){
                                    referenceSobj = referenceSobj.getSObject(parentReferences.remove(0));
                                    if (referenceSobj != null && String.isNotBlank(((String)referenceSobj.get(parentReferences[0]))))
                                        lookupdata.put(((String)referenceSobj.get(parentReferences[0])).toUpperCase() ,(Id)sObj.get('Id'));    
                                }                        
                            } else if (fieldDataType != null && String.isNotBlank(String.valueof(sObj.get(fieldApiName)))) {
                                if (fieldDataType == Schema.DisplayType.Integer || fieldDataType == Schema.DisplayType.Double) {
                                    lookupdata.put((String.valueof(sObj.get(fieldApiName))).toUpperCase(), (Id)sObj.get('Id'));
                                } else {
                                    lookupdata.put(((String)sObj.get(fieldApiName)).toUpperCase(), (Id)sObj.get('Id'));  
                                }
                            }
                        }
                    }
                }
            }
        } 
        
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        for(sObject sobj: interRecords) {           
            sObject targetObject = globalDescribe.get(targetObjApiName).newSObject(); 
            for(Data_Import_Staging__mdt inter: intermediateData){
                String sourceFieldApi = fieldAPIMap.get(inter.Source_Field__c);
                String targetFieldApi = fieldAPIMap.get(inter.Target_Field__c).toLowercase();
                String data = (String)sobj.get(sourceFieldApi);
                
                if(inter.Target_Field_Reference_Identifier__c == null) {  
                    if(fieldAPIToTypeMap.get(targetFieldApi) != null) {    
                        if(fieldAPIToTypeMap.get(targetFieldApi) == Schema.DisplayType.Integer){
                            targetObject.put(targetFieldApi, getInt(data));  
                        } else if(fieldAPIToTypeMap.get(targetFieldApi) == Schema.DisplayType.Double){
                            targetObject.put(targetFieldApi, getDec(data));
                        } else if(fieldAPIToTypeMap.get(targetFieldApi) == Schema.DisplayType.Boolean){
                            targetObject.put(targetFieldApi, getBool(data));  
                        } else if(fieldAPIToTypeMap.get(targetFieldApi) == Schema.DisplayType.Date){
                            targetObject.put(targetFieldApi, getDate(data,sobj));
                        } else if(fieldAPIToTypeMap.get(targetFieldApi) == Schema.DisplayType.DateTime){
                            targetObject.put(targetFieldApi, getDateTime(data,sobj));                    
                        } else {
                            targetObject.put(targetFieldApi, data);}
                    }
                } else {
                    //If Data Import Staging Record has Target Field Reference Identifier value  
                    String dt = data != null ? data.toUpperCase() : data;
                    targetObject.put(targetFieldApi, lookupdata.get(dt));     
                }
            } 
            if (sobj.get('Status__c') != 'Failed') {
                targetRecords.add(targetObject);
                sourceRecords.add(sobj);
            } else {
                errorRecords.add(sobj);
            }
        } 
        return new DataWrapper(targetRecords, sourceRecords, errorRecords);  
    }
    
    /*
    * This method is used to get field types of all fields in the incoming SObject
    * @param sObjectApiName - object API name
    * @return Map<String, Schema.DisplayType> - Map with key as field API name and value as field data type
    */   
    public Map<String, Schema.DisplayType> getFieldTypes(String sObjectApiName){
        Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(sObjectApiName).getDescribe().fields.getMap();
        Map<String, Schema.DisplayType> fieldAPIandTypeMap = new Map<String, Schema.DisplayType>();
        
        for(String fieldApiName: fieldMap.keySet()){
            Schema.DisplayType fielddataType = fieldMap.get(fieldApiName).getDescribe().getType();
            fieldAPIandTypeMap.put(fieldApiName,fielddataType);
        }
        return fieldAPIandTypeMap;
    }
    
    /*
    * This method is used to get field type of incoming field in the SObject
    * @param sObjectApiName - object API name 
    * @param fieldAPIName - field API name
    * @return Schema.DisplayType - data type of the incoming field
    */  
    @testVisible
    private Schema.DisplayType getFieldType(String sObjectApiName, String fieldAPIName) {
        Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(sObjectApiName).getDescribe().fields.getMap();
        if (fieldMap.containsKey(fieldAPIName)) {
            return fieldMap.get(fieldApiName).getDescribe().getType();
        }
        return null;
    }
    
    /*
    * This method is used to convert list of string to list of integer
    * @param data -  list of string to be converted to list of integers
    * @return List<Integer> -  List of Iintegers
    */ 
    @testVisible
    private List<Integer> getIntList(List<String> data) {
        List<Integer> dataList = new List<Integer>();
        for (String str : data) {
            Integer intValue = getInt(str);
            //SFSE-13447 Added curly braces
            if (intValue != null){
                dataList.add(intValue);
            } 
        }
        return dataList;
    }
    
    /*
    * This method is used to convert list of string to list of double
    * @param data - list of String to be converted to list of double
    * @return List<Double> - List of Double
    */
    @testVisible
    private List<Double> getDoubleList(List<String> data) {
        List<Double> dataList = new List<Double>();
        for (String str : data) {
            Double doubleValue = getDec(str);
            //SFSE-13447 Added curly braces
            if (doubleValue != null){
                dataList.add(doubleValue);
            } 
        }
        return dataList;
    }
    
    /*
    * This method is used to convert string to decimal
    * @param val - string value to be converted to decimal  
    * @return Decimal -  decimal value of String
    */
    @testVisible
    public Decimal getDec(String val) {
        return String.isNotEmpty(val) ? Decimal.valueOf(val) : null;
    }
    
    /*
    * This method is used to convert String to Boolean
    * @param val -  string value to be converted to boolean
    * @return Boolean - boolean value of String
    */
    @testVisible
    private Boolean getBool(String val) {
        return String.isNotEmpty(val) ? Boolean.valueOf(val) : false;
    } 
    
    /*
    * This method is used to convert String to Date
    * @param val -  string value 
    * @param sobj - object record
    * @return Date -  Date value of String
    */  
    @testVisible
    private Date getDate(String val, Sobject sobj) {
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
        if (isError) {
            sobj.put('Message__c', LABEL.Mass_Transfer_Invalid_Date_Error);
            sobj.put('Status__c', 'Failed');
        }
        return null;
    }
    
    /*
    * This method is used to convert String to DateTime
    * @param val -  string value 
    * @param sobj - object record
    * @return: DateTime - Datetime value of String
    */
    @testVisible
    private DateTime getDateTime(String val, Sobject sobj) {
        try {
            return String.isNotEmpty(val) ? DateTime.parse(val) : null;
        } catch (Exception ex) {
            sobj.put('Message__c', ex.getMessage());
            sobj.put('Status__c', 'Failed');
            return null;
        }
    }
    
    /*
    * This method is used to remove empty/null
    * @param dataList -  list of string from which emtpy/null values need to be removed
    * @return List<String> - list without '' or null values
    */ 
    @testVisible
    private List<String> getFilterValues(List<String> dataList) {
        Set<String> dataSet = new Set<String>(dataList);
        dataSet.remove('');
        dataSet.remove(null);
        dataList = new List<String>(dataSet);
        return dataList;
    }
    
    /*
    * This method is used to convert String to Integer
    * @param val -  string value to be converted to integer
    * @return Integer - Integer value of the string
    */
    public Integer getInt(String val) {
        return String.isNotEmpty(val) ? Integer.valueOf(val) : null;
    }
    
    //Wrapper to hold the target and source object with error results 
    public class DataWrapper {
        public List<sObject> targetSobjRecords;        
        public List<sObject> sourceSobjRecords;
        public List<sObject> sourceErrSobjRecords;
        
        //This is the contructor method. When we create a new DataWrapper object, we pass list of target/source and error objects
        public DataWrapper(List<sObject>tRecords, List<sObject>sRecords, List<sObject>errRecords){
            this.targetSobjRecords = tRecords;
            this.sourceSobjRecords = sRecords;
            this.sourceErrSobjRecords = errRecords;
        }  
    }
    
    
}