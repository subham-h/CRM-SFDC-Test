public class HighlightController{
    /*
* @description | SC-6780  get the record higlight details
* @param recId accepts the recId
*/
    @AuraEnabled
    public static HighlightWrapper getRecordHighlights(Id recId){
        try{
            HighlightWrapper hWrap = new HighlightWrapper();
            Map<String, FormField> formFieldMap = new Map<String, FormField>();
            List<FormField> selectedFormFieldList = new List<FormField>();
            String recTypeDevName = '';
            List<Highlight__c> highlightList = new List<Highlight__c>();
            String objApiName = recId.getSObjectType().getDescribe().getName();
            String objLabel = recId.getSObjectType().getDescribe().getLabel();
            hWrap.objApiName = objApiName;
            String query = 'Select RecordTypeId From '+objApiName+' Where Id=: recId';
            List<sObject> obj = Database.query(query);
            String recTypeId = String.valueOf(obj[0].get('RecordTypeId'));
            if(!String.isEmpty(recTypeId)){
                recTypeDevName = [Select DeveloperName From RecordType Where Id =: recTypeId].DeveloperName;
            }
            hWrap.recType = recTypeDevName;
            List<General_Key_Value_Configurations__mdt> gKey = [Select First_Field_Name__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Sobject_Name__c =: objApiName AND Key__c = 'Highlight' AND First_Field_Name__c =: recTypeDevName LIMIT 1];
            
            String fieldSet = !gKey.isEmpty() ? gKey[0].First_Field_Value__c : '';
            if(!String.isEmpty(fieldSet)){
                hWrap.fields = getFields(recId, '', recTypeDevName, fieldSet, formFieldMap);
            }
            
            highlightList = [Select Id, Agent_Name__c, Selected_Fields__c From Highlight__c Where Agent_Name__c =: UserInfo.getUserId() AND Object_Name__c =: objApiName AND Record_Type__c =: recTypeDevName Order By CreatedDate DESC LIMIT 1];
            if(!highlightList.isEmpty() && !String.isEmpty(highlightList[0].Selected_Fields__c)){
                for(String field : highlightList[0].Selected_Fields__c.split(',')){
                    if(formFieldMap.containsKey(field)){
                        FormField f = new FormField();
                        f.IsRequired = formFieldMap.get(field).IsRequired;
                        f.APIName = formFieldMap.get(field).APIName;                        
                        f.Required = formFieldMap.get(field).Required;
                        f.Type = formFieldMap.get(field).Type;
                        f.Label = formFieldMap.get(field).Label;
                        //SC-8046: Name should be ddisplayed instead of Id in the field selection section
                        if(f.Type == 'REFERENCE' && f.Label.contains('ID') && !f.APIName.contains('__C') &&  f.APIName.contains('OwnerId')){
                            f.Label = objLabel+' '+formFieldMap.get(field).Label.replace('ID', '');
                        } else if(f.Type == 'REFERENCE' && formFieldMap.get(field).Label.contains('ID') && !f.APIName.contains('__C') && (f.APIName.contains('CreatedById') || f.APIName.contains('LastModifiedById') || f.APIName.contains('ParentId')) ){
                            f.Label = formFieldMap.get(field).Label.replace('ID','');
                        } else if(f.Type == 'REFERENCE' && formFieldMap.get(field).Label.contains('ID') && !f.APIName.contains('__C')){
                            f.Label = formFieldMap.get(field).Label.replace('ID','Name');
                        } else if(!f.APIName.contains('__C') &&  f.APIName == 'SuppliedName') {
                            f.Label = 'Web Name';
                        } else if(!f.APIName.contains('__C') &&  f.APIName == 'SuppliedEmail') {
                            f.Label = 'Web Email';
                        }
                        selectedFormFieldList.add(f);
                    }
                }
                hWrap.selectedFormFieldList = selectedFormFieldList;
                hWrap.highlightRecId = highlightList[0].Id;
            }
            else{
                //Show Default fields
                List<General_Key_Value_Configurations__mdt> defGenKey = [Select First_Field_Name__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Sobject_Name__c =: objApiName AND Key__c = 'Default_Highlight' LIMIT 1];
                if(!defGenKey.isEmpty()){
                    String defaultFieldSet = !defGenKey.isEmpty() ? defGenKey[0].First_Field_Value__c : '';
                    if(!String.isEmpty(defaultFieldSet)){
                        hWrap.selectedFormFieldList = getFields(recId, '', recTypeDevName, defaultFieldSet, formFieldMap);
                    }
                }
                hWrap.highlightRecId = '';
            }
            hWrap.maxRecords = Integer.valueOf(General_Key_Value_Configurations__mdt.getInstance('Highlight_Max_Size').First_Field_Value__c);
            return hWrap;
        }
        catch(Exception e){
            throw new AuraHandledException(Label.System_Error+e.getMessage()+e.getLineNumber());
        }
    }
    
    /*
* @description | SC-6780  get the fields data from fieldset
* @param recordId accepts the recordId
* @param objectName accepts the objectName
* @param fieldSetName accepts the fieldSetName
*/
    private static List<FormField> getFields(Id recordId, String objectName, String recTypeDevName, String fieldSetName, Map<String, FormField> formFieldMap) {
        Schema.SObjectType objectType = null;
        if(recordId != null){
            objectType = recordId.getSobjectType();
        }
        else if(!String.isEmpty(objectName)){
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        String objLabel = recordId.getSObjectType().getDescribe().getLabel();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
        List<FormField> fields = new List<FormField>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            FormField f = new FormField(fsm);
            //SC-8046: Name should be ddisplayed instead of Id in the field selection section
            if(f.Type == 'REFERENCE' && f.Label.contains('ID') && !f.APIName.contains('__C') &&  f.APIName.contains('OwnerId')){
                f.Label = objLabel + ' ' + f.Label.replace('ID','');
            } else if(f.Type == 'REFERENCE' && f.Label.contains('ID') && !f.APIName.contains('__C') && (f.APIName.contains('CreatedById') || f.APIName.contains('LastModifiedById') || f.APIName.contains('ParentId'))){
                f.Label = f.Label.replace('ID','');
            } else if(f.Type == 'REFERENCE' && f.Label.contains('ID') && !f.APIName.contains('__C')){
                f.Label = f.Label.replace('ID','Name');
            } else if(!f.APIName.contains('__C') &&  f.APIName == 'SuppliedName') {
                f.Label = 'Web Name';
            } else if(!f.APIName.contains('__C') &&  f.APIName == 'SuppliedEmail') {
                f.Label = 'Web Email';
            } else {
                f.Label = f.Label;
            }
            fields.add(f);
            formFieldMap.put(f.APIName, f);
        }
        fields.sort();
        return fields;
    }
    
    /*
* @description | SC-6780  save the higlight record details
* @param highlightId accepts the highlightId
* @param objName accepts the objName
* @param recTypeDevName accepts the recTypeDevName
* @param selectedFields accepts the selectedFields
*/
    @AuraEnabled
    public static HighlightWrapper saveHighlightDetails(String objName, String recTypeDevName, String selectedFields){
        HighlightWrapper hWrap = new HighlightWrapper();
        List<Highlight__c> hRecList = new List<Highlight__c>();
        List<Highlight__c> existingHighlight = new List<Highlight__c>();
        Highlight__c hRec = new Highlight__c();
        
        try{
            existingHighlight = [Select Id From Highlight__c Where Agent_Name__c =: UserInfo.getUserId() AND Object_Name__c =: objName AND Record_Type__c =: recTypeDevName Order By CreatedDate DESC LIMIT 1];
            if(!existingHighlight.isEmpty()){
                existingHighlight[0].Selected_Fields__c = selectedFields;
                update existingHighlight;
            }
            else{
                hRec.Agent_Name__c = UserInfo.getUserId();
                hRec.Object_Name__c = objName;
                hRec.Record_Type__c = recTypeDevName;
                hRec.Selected_Fields__c = selectedFields;
                hRecList.add(hRec);
                insert hRecList;
            }
            hWrap.errorMsg = '';
        }catch(exception e){
            hWrap.errorMsg = 'Highlight record update failed. '+e.getMessage();
        }
        if(!String.isEmpty(hRec.Id)){
            hWrap.highlightRecId = hRec.Id;
        }
        return hWrap;
    }
    
    public class HighlightWrapper{
        @AuraEnabled
        public String objApiName;
        @AuraEnabled
        public List<FormField> fields;
        @AuraEnabled
        public List<FormField> selectedFormFieldList;
        @AuraEnabled
        public String highlightRecId;
        @AuraEnabled
        public String recType;
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public Integer maxRecords;
    }
    
    public class FormField implements Comparable{
        public FormField(Schema.FieldSetMember f) {
            this.IsRequired = f.DBRequired;
            this.APIName = f.fieldPath;
            this.Label = f.label;
            this.Required = f.required;
            this.Type = String.valueOf(f.getType());
        }
        
        public FormField(Boolean required) {
            this.IsRequired = required;
        }
        
        public FormField() {
            
        }
        
        public Integer compareTo(Object objToCompare){
            return Label.compareTo(((FormField)objToCompare).Label);
        }
        
        @AuraEnabled
        public Boolean IsRequired;
        @AuraEnabled
        public String APIName;  
        @AuraEnabled
        public String Label;
        @AuraEnabled
        public Boolean Required;
        @AuraEnabled
        public String Type;
    }
}