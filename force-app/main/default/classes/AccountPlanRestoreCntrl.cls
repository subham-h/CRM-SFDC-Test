/*  
* Version	Date			Referance				Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		01-Aug-2023								Vazid@UST				This Apex class is used in the lwcAccPlanRestoreCmp LWC component
*/
public class AccountPlanRestoreCntrl {
    
    //Get all the records from custom metadata, creating a map label as key and developername as key and this map will be used in the lightning-combobox
    @AuraEnabled(cacheable=false)
    public static Map<string,string> getObjectRecords(){
        Map<string,string> mapOfObjOptions = new Map<string,string>();
        Map<String, AccountPlan_Restore_DataTable__mdt> dynamicTableList = AccountPlan_Restore_DataTable__mdt.getAll(); //map of all records
        
        for(AccountPlan_Restore_DataTable__mdt medaRec: dynamicTableList.values()){
            mapOfObjOptions.put(medaRec.label,medaRec.developerName);
        }
        
        system.debug('mapOfObjOptions'+mapOfObjOptions);
        return mapOfObjOptions;
        
    }
    
    //Based on the selected object on the UI get the resective records using the parent account plan record
    @AuraEnabled(cacheable=false)
    public static DataTableResponse GetWrapperOfSObjectFieldColumnActionValues(string selectedObjName, string recId)
    {
        system.debug('selectedObjName###'+selectedObjName);
        system.debug('recId###'+recId);
        string selectedFinalObjName = selectedObjName.trim()+'__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = schemaMap.get(selectedFinalObjName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
        List<SObject> lstDataTableData                   = new List<SObject>();
        List<string> columnList                          = new List<string>();
        List<string> fieldAPINameList                    = new List<string>();
        
        // To get the Account plan API name for the selected child object
        AccountPlan_Restore_DataTable__mdt dynamicTableList = AccountPlan_Restore_DataTable__mdt.getInstance(selectedObjName); //map of all records
        string parentObjAPIName = dynamicTableList.Parent_Object_API_Name__c;
        
        //Get the columns and data using field set name stored in metadata
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : DescribeSObjectResultObj.FieldSets.getMap().get(dynamicTableList.FieldSet_Name__c).getFields()) {
            
            query += f.getFieldPath() + ', ';
            DataTableColumns datacolumns;
            //If the field path is Name, then formating data type as URL otherwise using saleforce data type.
            if(f.getFieldPath() == 'Name'){
                typeAttr typeAttrb = new typeAttr();
                lab typelab = new lab();
                typelab.fieldName = 'Name';
                typeAttrb.label = typelab;
                typeAttrb.target = '_blank';
                datacolumns = new DataTableColumns(f.getLabel() , 
                                                   'RecordName', 
                                                   'url',typeAttrb);
            }else{
                datacolumns = new DataTableColumns( f.getLabel() , 
                                                   f.getFieldPath(), 
                                                   string.valueof(f.getType()),null);
            }
            lstDataColumns.add(datacolumns);
        }
        query += 'Id FROM '+selectedFinalObjName+ ' WHERE Archived__c = true AND '+parentObjAPIName+ '=\'' + String.escapeSingleQuotes(recId)+'\'';
        system.debug('Apex query'+query);   
        lstDataTableData = Database.query(query);
        
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.lstDataTableColumns = lstDataColumns;
        finalWrapper.lstDataTableData    = lstDataTableData;
        return finalWrapper;
    }
    
    //Updating Acrhived = false for selected records on the UI.
    @AuraEnabled(cacheable=false)
    public static string restoreObjectData(List<Sobject> lstObject){
        string resultMsg = 'success';
        
        if(!lstObject.isEmpty()){
            try{
                update lstObject;
            }
            catch(DmlException de){
                resultMsg = de.getMessage();
                ErrorLogger.writeError('SFDC', 'Account Plan Restore LWC Page', 'AccountPlanRestoreCntrl.restoreObjectData', de.getTypeName(), de.getMessage(), de.getMessage());
            }
        }
        return resultMsg;
    }
    
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public typeAttr typeAttributes{get;set;}
        
        public DataTableColumns(String label, String fieldName, String type, typeAttr typeAttributes)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;     
            this.typeAttributes = typeAttributes;
        }
    }
    
    public class typeAttr{
        @AuraEnabled
        public lab label {get;set;}
        @AuraEnabled
        public string target {get;set;}
    }
    
    public class lab {
        @AuraEnabled       
        public String fieldName {get;set;}
    }
    
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}
              
    }
    
}