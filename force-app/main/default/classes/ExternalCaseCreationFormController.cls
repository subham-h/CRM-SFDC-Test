/**
* Author   : Avinash@Maersk
* Purpose  : Used in ExternalCaseCreationFormLWC Component
* 
* Revision Ref Number  Date          Owner                  Description
* -------- ----------  -----------   -------------------    -----------
* 1.0      SC-7492     11-Apr-2023   Avinash@Maersk      Simplify External Manual Case Creation - POC
*/
public class ExternalCaseCreationFormController {

    @AuraEnabled(cacheable=true)
    public static ExtWrapper getFields(String recordTypeName, String recordId){
        ExtWrapper ext = new ExtWrapper();
        List<FormFieldSectionWrapper> lstFormFieldSectionWrapper = new List<FormFieldSectionWrapper>();
        
        for(Case_Field_Set_Configuration__mdt fieldSetmdt : [Select Field_Set_API_Name__c,Section_Name__c from Case_Field_Set_Configuration__mdt where Record_Type__c =:recordTypeName]){
            FormFieldSectionWrapper formFieldSectionObj = new FormFieldSectionWrapper();
            formFieldSectionObj.SectionName = fieldSetmdt.Section_Name__c;
            formFieldSectionObj.Fields = readFieldSet(fieldSetmdt.Field_Set_API_Name__c);
            lstFormFieldSectionWrapper.add(formFieldSectionObj);
        }
        ext.formFieldSectionWrapperList = lstFormFieldSectionWrapper;
        ext.recId = recordId;
        return ext;
    }
    
    public static List<FormField> readFieldSet(String fieldSetName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Case');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSet = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
        List<FormField> fields = new List<FormField>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            FormField f = new FormField(fsm);
            fields.add(f);
        }
        return fields; 
    } 
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getBrandAndProductValues() {
        Map<String, String> result = new Map<String, String>();
        
        try{
            User currentUser = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
            String userRole = currentUser.UserRole != null ? currentUser.UserRole.Name : null;
            Map<String, General_Key_Value_Configurations__mdt> keyValuePairMap = new Map<String, General_Key_Value_Configurations__mdt>();
            for (General_Key_Value_Configurations__mdt keyValue : [SELECT First_Field_Value__c, Second_Field_Value__c, Key__c,First_Field_Name__c,Second_Field_Name__c FROM General_Key_Value_Configurations__mdt WHERE Label LIKE '%ProductBrandDefault%']) 
            {
                keyValuePairMap.put(keyValue.Key__c, keyValue);
            }
            if (!String.isBlank(userRole)) {
                for (String key : keyValuePairMap.keySet()) {
                    if (userRole.contains(key)) {
                        General_Key_Value_Configurations__mdt config = keyValuePairMap.get(key);
                        result.put(config.First_Field_Name__c, config.First_Field_Value__c);
                        result.put(config.Second_Field_Name__c, config.Second_Field_Value__c);
                        return result; 
                    }
                }
            }
            result.put('Brand', 'Maersk Line');
            result.put('Product', 'Ocean');
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        return result;
    }
    public class ExtWrapper{
        @AuraEnabled
        public List<FormFieldSectionWrapper> formFieldSectionWrapperList;
        @AuraEnabled
        public String recId;
    }
    
    public class FormFieldSectionWrapper{
        @AuraEnabled
        public List<FormField> Fields;
        @AuraEnabled
        public String SectionName;
    }
    
    public class FormField {
        @AuraEnabled
        public String APIName;  
        @AuraEnabled
        public Boolean Required;
        @AuraEnabled
        public String Type;
        
        public FormField(Schema.FieldSetMember f) {
            this.APIName = f.fieldPath;
            this.Required = f.required;
            this.Type = String.valueOf(f.getType());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeDetailsWrapper> getRecordTypeDetails(){
        List<RecordTypeDetailsWrapper> lstRecordTypeDetailsWrapper = new List<RecordTypeDetailsWrapper>();
        for(RecordType rec : [Select Id,Name,Description from RecordType where SobjectType = 'Case' order by createddate]){
            if(rec != null){
                RecordTypeDetailsWrapper recTypeDetail = new RecordTypeDetailsWrapper();
                recTypeDetail.recordTypeId = rec?.Id;
                recTypeDetail.recordTypeName = rec?.Name;
                recTypeDetail.recordTypeDescription = rec?.Description;
                recTypeDetail.isDefault = rec?.Name == 'External Case' ? true : false;
                lstRecordTypeDetailsWrapper.add(recTypeDetail);
            }
        }
        return lstRecordTypeDetailsWrapper;
    }
    
    public class RecordTypeDetailsWrapper{
        @AuraEnabled
        public String recordTypeId;
        @AuraEnabled
        public String recordTypeName;
        @AuraEnabled
        public String recordTypeDescription;
        @AuraEnabled
        public Boolean isDefault;
    }
}