/*  
* Version	Date			Owner			Description
* --------	-----------		--------		-----------
* 1.0		19-Sept-2023	Vazid  			This is an apex class for dynamic filters lwc component : customDynamicFilterCmp
* 2.0       17-Oct-2023     Seba            Modified to get the formula field type (SFSE-13019)
* 3.0       22-Oct-2023     Seba            Modified to get the Lookup field type (##SFSE-13019)
*/

public class DynamicMultiFilterCntrl {
    
    //It is used to return the fields of the object
    @AuraEnabled
    public static map<string,list<object>> getObjectFields (String objName){
        map<string,list<object>> retVal = new map<string,list<object>>();
        map<string,list<object>> retfinalVal = new map<string,list<object>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {   
            string fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
            /*##SFSE-13019*/
            if(fieldMap.get(fieldName).getDescribe().isCalculated() || fieldName == 'controlling_area__c'){
              fieldType = 'FORMULA';  
            } 
            /*SFSE-13019*/  
            boolean iscustom = fieldMap.get(fieldName).getDescribe().isCustom(); 
            //Not sure - why string.valueof(Schema.DisplayType.REFERENCE) condition is used
            if((fieldType != string.valueof(Schema.DisplayType.REFERENCE) || fieldName == 'controlling_area__c') && iscustom) {//##SFSE-13019 To allow controlling_area__c
                String FieldAPI=fieldMap.get(fieldName).getDescribe().getName(); 
                List<String> listStrings = new List<String>();  
                listStrings.add(fieldType); //Adding field type 
                string FieldLabelName=fieldMap.get(fieldName).getDescribe().getLabel(); 
                listStrings.add(FieldLabelName);//SFSE-13019 
                retVal.put(FieldAPI,listStrings);//SFSE-13019   
            }
            if (iscustom && fieldName == 'Assigned_Sales_Rep__c') {
                String FieldAPI = fieldMap.get(fieldName).getDescribe().getName();
                List<String> listStrings = new List<String>();
                listStrings.add(fieldType); // Adding field type
                String FieldLabelName = fieldMap.get(fieldName).getDescribe().getLabel();
                listStrings.add(FieldLabelName);
                retVal.put(FieldAPI, listStrings);
            }
            
        }
        //Sorting by Alphabet
        List<string> fldLabelList = new List<string>();
        fldLabelList.addAll(retVal.keySet());
        fldLabelList.sort();
        for(string str: fldLabelList){
            retfinalVal.put(str,retVal.get(str)); 
        } 
        return retfinalVal;
    }
    
    //It is used to get the options for selected picklist field from the system
    @AuraEnabled(cacheable = true)
    public static Map<String,String> getOptionsForSelectedPicklistField(string selectedObjectName, string selectedField){
        try { 
            Map<String,String> options = new  Map<String,String>(); 
            Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(selectedObjectName).getDescribe().fields.getMap();
            Schema.DescribeFieldResult pickFieldResult = mapFields.get(selectedField).getDescribe();   
            List<Schema.PicklistEntry> picklistFields1 = pickFieldResult.getPicklistValues(); 
            
            for( Schema.PicklistEntry pickListFields2 : picklistFields1)
            { 
                options.put(pickListFields2.getLabel(),pickListFields2.getValue());
            } 
            return options;
        } catch (Exception e) {
            return null;
        }
    } 
    
    @AuraEnabled
    public static List<Target_Customer_Portfolio__c> getTargetMeasureFromCustomerPortfolio(String fieldName, String fieldValue){
        List<Target_Customer_Portfolio__c> lstTargetCusPort = new List<Target_Customer_Portfolio__c>();
        try {
            String query = 'SELECT Assigned_Target__c FROM Target_Customer_Portfolio__c WHERE '+fieldName+' = '+ '\''+fieldValue+'\'';
            System.debug('@@@@'+query);
            lstTargetCusPort = Database.query(query);
            System.debug('@@@@'+lstTargetCusPort);
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstTargetCusPort;
    }
}