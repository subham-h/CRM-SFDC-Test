/*
Description  : Utlity class for  related methods used for lighning pages

* version       Date                Owner                                 Description
*******************************************************************************************************
* V1.0          1/01/2017          meghana.gupta@ust-global.com          #RE-0307   - Code created for CluAP Release 1
* V1.1          04/05/2017         uvais.komath@ust-global.com           #RQ-005210 - New method added for getting picklist values of multiple fields
* V1.2          16/11/2017         ramadevi.palaniswamy@ust-global.com   #RQ-007290 - Modified to remove certain characters from a picklist field values
* V5.3	        09/09/2019         sidhartha@maersk.com                  #RQ-011539 - Updated code to add dependent picklist
*
*/

public class Lightning_Utilities{
    
    @AuraEnabled
    public static List<Sales_Tracker_Reports__c> getSalesTrackerReports(){
        
        List<Sales_Tracker_Reports__c> reportList = [SELECT Report_Id__c, Report_Label__c, Order__c,description__c,Description_2__c,Description_3__c FROM Sales_Tracker_Reports__c ORDER BY Order__c];
        
        return reportList;
        
    }
    
    @AuraEnabled
    public static List<User> getSalesTeam(){
        
        List<User> salesTeamList= [SELECT id, name FROM User
                                   WHERE managerId = :UserInfo.getUserId() AND isActive = true ];
        return salesTeamList;
        
    }
    
    @AuraEnabled
    public static Id getLoggedInUserId() {
        
        return UserInfo.getUserId() ;
        
    }
    
    @AuraEnabled
    public static List<String> GetFieldPikclistValues( String ObjectApi_name, String picklistField,Integer chartoRemove){        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        
        List<Schema.PicklistEntry> controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        Set<String> values =  new Set<String>();
        for (Schema.PicklistEntry pklVal : controllingFieldValues){
            String valuetoAdd;
            valuetoAdd = pklVal.getValue()+'';    
            if(chartoRemove != NULL) {
                values.add(valuetoAdd.substring(0,valuetoAdd.length()-Integer.valueOf(chartoRemove))); 
            } else {
                values.add(valuetoAdd);
            }
        }
        return New List<String>(values);
    }
    
    //V1.1 START 
    @AuraEnabled
    public static List<String> GetAllPicklistValues( String ObjectApi_name, String picklistField1, String picklistField2, String filterCond, String supportPrefixField,Boolean fieldData){
        
        set<String> values =  new  set<String>();
        values.addAll(GetFieldPikclistValues(ObjectApi_name,picklistField1,0));
        values.addAll(GetFieldPikclistValues(ObjectApi_name,picklistField2,0));                  
        return (new List<string>(values));
    }
    //V1.1 END
    
    @AuraEnabled
    public static List<String> GetRecordValuesForPicklist( String ObjectApi_name, String picklistField, String filterCond, String supportPrefixField ){
        
        String query = 'SELECT Id, ' + picklistField;
        if ( supportPrefixField != '' )
            query += ', ' + supportPrefixField;
        
        query += ' FROM ' + ObjectApi_name;
        
        if ( filterCond != '')
            query += ' WHERE ' +  filterCond;
        
        if ( supportPrefixField != '' )
            query += ' ORDER BY ' + supportPrefixField;
        else
            query += ' ORDER BY ' + picklistField;
        SYstem.debug('$$$query: '+query);
        List<SObject> oList = Database.query(query);
        
        if( oList.size() == 0 ) 
            return null;
        
        else {
            
            List<String> picklistVals = new List<String>();
            Set<String> chkDuplicate = new Set<String>();
            
            String picklistValue = '';
            for ( SObject sObj : oList ){
                
                String pValue = '';
                if( picklistField.contains('.') ){
                    String nextField = picklistField.substringAfter('.');
                    String relation = picklistField.substringBefore('.');
                    
                    if ( sObj.getSobject(relation) != null)
                        pValue = (String) sObj.getSobject(relation).get(nextField);
                } else {
                    pValue = (String) sObj.get(picklistField);
                }
                
                if (! chkDuplicate.contains(pValue)){
                    chkDuplicate.add(pValue);
                    if ( supportPrefixField != '' ){        
                        String prefixValue = '';
                        if( supportPrefixField.contains('.') ){
                            String nextField = supportPrefixField.substringAfter('.');
                            String relation = supportPrefixField.substringBefore('.');
                            
                            if ( sObj.getSobject(relation) != null)
                                prefixValue = (String) sObj.getSobject(relation).get(nextField);
                        } else {
                            prefixValue = (String) sObj.get(supportPrefixField);
                        }
                        
                        picklistVals.add( prefixValue + ' - ' + pValue );
                    }
                    else
                        picklistVals.add( pValue);                
                }
            }
            system.debug('$$$picklistVals'+ picklistVals);
            return picklistVals;
        }
        
        
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(String ObjectApi_name, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType objType = Object_name.getSObjectType();
        //Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        system.debug('contrEntries' + contrEntries);
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        system.debug('depEntries' + depEntries);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            system.debug('plew' + plew);
            String validForBits = base64ToBits(plew.validFor);
            system.debug('validForBits' + validForBits);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                system.debug('bit' + bit);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                    system.debug('objResults' + objResults);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        system.debug('validFor' + validFor);
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
            system.debug('validForBits' + validForBits);
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        system.debug('PLEs' + PLEs);
        system.debug('JSON.serialize(PLEs) ' + JSON.serialize(PLEs));
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
}