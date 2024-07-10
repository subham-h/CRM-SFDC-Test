/*      
 * Revision Ref Number  Date             Owner                   Description
 * -------- ----------  -----------    -------------------    -------------------------
 * 1.0      SFSE-5986  28-04-2021     Meghana@UST               Code created. 
 * */

public with sharing class flowDatatableCntrl {
    
    //wrapper class
    public class TableData {
        
        @AuraEnabled public Map<String, String> mapFieldLabels {get; set;}
        @AuraEnabled public List<sObject> lstData {get; set;}
        @AuraEnabled public Map<String, String> mapFieldDataType {get; set;}

        public TableData(){
            lstData = new List<sObject>();
            mapFieldLabels = new Map<String,String>();
            mapFieldDataType = new Map<String,String>();
        }
    }

    // method to form dynamic SOQL and excute it. If data rows are passed - get field labels and datatype.
    @AuraEnabled(cacheable = true)
    public static TableData getDataRows(String objName, String fieldList, String criteria,
                                             String sortByAndDirection,  String maxRows,
                                             String columnLabels, String keyfield,
                                             List<sObject> lstDataRows){
        
        system.debug('$$$ getResults: '+ objName + ':' + fieldList + ':'+ criteria +':'+ sortByAndDirection+':' +maxRows);
        system.debug('$$$ lstDataRows: '+ lstDataRows);

        Set<String> setFieldList = new Set<String>(fieldList.split(','));
        tableData response = new tableData(); // create warpper class instance

        if (lstDataRows != null && lstDataRows.size() != 0){
            response.lstData = lstDataRows;
            if (objName == null || objName == ''){
                objName = lstDataRows[0].getSObjectType().getDescribe().getName();
            }
            
        } else if (objName != null && objName != ''){

            if (!setFieldList.contains(keyfield)){
                fieldList = fieldList + ',' + keyfield ;
            }

            //form SOQL
            String strQuery = 'SELECT ' + fieldList + ' FROM ' + objName;
            
            if (criteria != null && criteria != ''){
                strQuery += ' WHERE  ' + criteria;
            }

            if (sortByAndDirection != null && sortByAndDirection != ''){
                strQuery += ' ORDER BY ' + sortByAndDirection;
            }

            if (maxRows != null && maxRows != ''){
                strQuery += ' LIMIT ' + maxRows;
            }

            system.debug('strQuery:' + strQuery);                                         
            List<sObject> lstResult = database.query(strQuery);
            response.lstData = lstResult;

        }  
       
        Map<String,String> mapFieldToNewLabel = new Map<String,String>();
        if (columnLabels != null && columnLabels != ''){
           for (String field : columnLabels.split(',')){
                List<String> tmpList = field.split(':');
                mapFieldToNewLabel.put(tmpList[0], tmpList[1]);
           }
        }

        if (objName != null && objName != ''){
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType rsiSchema = schemaMap.get(objName);
            Map<String, Schema.SObjectField> fieldMap = rsiSchema.getDescribe().fields.getMap();
        
            for (String fieldName: setFieldList) {    
                String strDataTypeforLwc = 'text';
    
                Schema.DescribeFieldResult fieldResult;
                if(fieldMap.containsKey(fieldName.toLowerCase())){
                    
                    fieldResult = fieldMap.get(fieldName.toLowerCase()).getDescribe(); 
                    
                    Schema.DisplayType fieldDatatype = fieldResult.getType();
                    if ( fieldDatatype == Schema.DisplayType.Currency) {strDataTypeforLwc = 'currency';}
                    if ( fieldDatatype == Schema.DisplayType.Integer) {strDataTypeforLwc = 'number';}
                    if ( fieldDatatype == Schema.DisplayType.Boolean) {strDataTypeforLwc = 'boolean';}
                    if ( fieldDatatype == Schema.DisplayType.DateTime || fieldDatatype == Schema.DisplayType.Date)
                         {strDataTypeforLwc = 'date';}
                    if ( fieldDatatype == Schema.DisplayType.Email) {strDataTypeforLwc = 'email';}
                    if ( fieldDatatype == Schema.DisplayType.URL) {strDataTypeforLwc = 'url';}
                        
                }
                response.mapFieldDataType.put(fieldName, strDataTypeforLwc);
      
                if (mapFieldToNewLabel.containsKey(fieldName)) {
                    response.mapFieldLabels.put(fieldName, mapFieldToNewLabel.get(fieldName)); 
                } else if(fieldResult != null) {      
                    response.mapFieldLabels.put(fieldName, fieldResult.getLabel()); 
                }          
            }
        }
        system.debug('$$$ response: ' + response);
        return response;
    }
}