/**
* Author   : Shahanawaz@Maersk
* Purpose  : Used in customPathLWC component
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-6779    17-Jan-2023   Shahanawaz@Maersk      Used in customPathLWC component
* 2.0      SC-7737    19-Apr-2023   ramadevi@Maersk        Show direction,country,contactId only when the value is not provided
*/
public class PathController {
    
    /*
    * @description | SC-6779  getPathKeyFields
    * @param objectName accepts the objectName
    * @param recTypeDevName accepts the recTypeDevName
    */
    @AuraEnabled(cacheable = true)
    public static FormWrapper getPathKeyFields(String objectName, String recTypeDevName){
        FormWrapper fWrap = new FormWrapper();
        Map<String, List<FormField>> statusToFormFieldsList = new Map<String, List<FormField>>();
        Map<String, Boolean> statusToFormDisplay = new Map<String, Boolean>();
        //SC-7737
        List<String> nullFieldList = new List<String>();
        for(General_Key_Value_Configurations__mdt gKey : [Select First_Field_Name__c, First_Field_Value__c, Key__c From General_Key_Value_Configurations__mdt Where Sobject_Name__c =: objectName AND Key__c = 'FieldNotNull' AND First_Field_Name__c =: recTypeDevName Order By Second_Field_Value__c ASC]){
            nullFieldList.add(gKey.First_Field_Value__c);
        }
        
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get('Case');
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        system.debug('nullFieldList###'+nullFieldList);
        for(Path_Configuration__mdt pConfig : [Select DeveloperName, Status__c, Fields_Required__c, Page_Layout_Required_Fields__c, Skip_Form_Display__c From Path_Configuration__mdt Where Object__c =: objectName AND Record_Type_Dev_Name__c =: recTypeDevName]){
            if(!String.isEmpty(pConfig.Fields_Required__c)){
                List<FormField> fieldList = new List<FormField>();
                List<String> requiredPageLayoutFields = new List<String>();
                if(!String.isEmpty(pConfig.Page_Layout_Required_Fields__c)){
                    requiredPageLayoutFields = pConfig.Page_Layout_Required_Fields__c.split(',');
                }
                for(String field : pConfig.Fields_Required__c.trim().split(',')){
                
                    Schema.SObjectField fields = MapofField.get(field);
                    Schema.DescribeFieldResult F = fields.getDescribe();
                    fieldWrapper newFieldWrapper = new fieldWrapper();
                    String fType = String.valueof(F.getType());
                    String styleType = '';
                    
                    if(requiredPageLayoutFields.isEmpty() || !requiredPageLayoutFields.contains(field)){
                        if(nullFieldList <> null){
                            if(!nullFieldList.contains(field)){
                                fieldList.add(new FormField(field, false,fType,styleType));
                            }
                            
                        } else {
                            fieldList.add(new FormField(field, false,fType,styleType));
                        }
                    }
                }
                if(!requiredPageLayoutFields.isEmpty()){
                    for(String field : requiredPageLayoutFields){
                    
                        Schema.SObjectField fields = MapofField.get(field);
                        Schema.DescribeFieldResult F = fields.getDescribe();
                        fieldWrapper newFieldWrapper = new fieldWrapper();
                        String fType = String.valueof(F.getType());
                        String styleType = '';
                        
                        if(nullFieldList <> null){
                            if(!nullFieldList.contains(field)){
                                fieldList.add(new FormField(field, false,fType,styleType));
                            }
                        } else {
                            fieldList.add(new FormField(field, false,fType,styleType));
                        }
                    }
                }
                system.debug('fieldList ##'+pConfig.Status__c+fieldList);
                statusToFormFieldsList.put(pConfig.Status__c.trim(), fieldList);
                
            }
            statusToFormDisplay.put(pConfig.Status__c.trim(), pConfig.Skip_Form_Display__c);
        }
        fWrap.statusToFormFieldsList = statusToFormFieldsList;
        fWrap.statusToFormDisplay = statusToFormDisplay;
        fWrap.notApplicableNullStatuses = General_Key_Value_Configurations__mdt.getInstance('NA_Null_Field_Status').First_Field_Value__c.split(',');
        return fWrap;
    }
    
    /*
    * @description | SC-6779  getExceptionFields
    * @param recId accepts the recId
    * @param objName accepts the objName
    */
    @AuraEnabled(cacheable = true)
    public static List<fieldWrapper> getExceptionFields(String recId, String objName, String recType){        
        List<String> fieldList = new List<String>();
        List<fieldWrapper> fieldWrapperList = new List<fieldWrapper>();
        
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get('Case');
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(General_Key_Value_Configurations__mdt gKey : [Select First_Field_Name__c, First_Field_Value__c, Key__c From General_Key_Value_Configurations__mdt Where Sobject_Name__c =: objName AND Key__c = 'FieldNotNull' AND First_Field_Name__c =: recType Order By Second_Field_Value__c ASC]){
            fieldList.add(gKey.First_Field_Value__c);
        }
        if(!fieldList.isEmpty()){
            String query = 'Select Id, '+String.join(fieldList, ',')+ ' From Case Where Id =: recId';
            Case cs = Database.query(query);
            for(String field : fieldList){
                if(cs.get(field) == null){
                    Schema.SObjectField fields = MapofField.get(field);
                    Schema.DescribeFieldResult F = fields.getDescribe();
                    fieldWrapper newFieldWrapper = new fieldWrapper();
                    newFieldWrapper.fieldName = field;
                    newFieldWrapper.fieldType = String.valueof(F.getType());
                    fieldWrapperList.add(newFieldWrapper);
                    //finalFieldList.add(field);
                }
            }
        }
        return fieldWrapperList;
        
    }

    //SC-7737
    public class fieldWrapper{
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String fieldType;
    }
    
    public class FormWrapper{
        @AuraEnabled
        public Map<String, List<FormField>> statusToFormFieldsList;
        @AuraEnabled
        public Map<String, Boolean> statusToFormDisplay;
        @AuraEnabled
        public List<String> notApplicableNullStatuses;
    }   
    
    public class FormField {
        @AuraEnabled
        public Boolean IsRequired;
        @AuraEnabled
        public String APIName;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public String sizeStyle;
        
        public FormField(String apiName, Boolean required, String fType,String sizeStyle){
            this.APIName = apiName;
            this.IsRequired = required;
            this.fieldType = fType;
            this.sizeStyle = sizeStyle;
        }
    }
    
    public class FormDisplay {
        @AuraEnabled
        public Boolean showForm;
        @AuraEnabled
        public String APIName;
        
        public FormDisplay(String apiName, Boolean showForm){
            this.APIName = apiName;
            this.showForm = showForm;
        }
    }
    
}