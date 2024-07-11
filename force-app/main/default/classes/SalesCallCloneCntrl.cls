/*
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          4/09/2018        meghana.gupta@ust-global.com           #RQ-008979-Code created
*/ 

public with sharing class SalesCallCloneCntrl {

    //wrapper class to return response to lightning component
    public class responseWrapper{
        
        @AuraEnabled public Sales_Call__c recSalesCall { get; set; } // cloned record instance
        @AuraEnabled public Map<String, String> mapFieldLabel { get; set; } // map of field api name and field label
        @AuraEnabled public Map<String, boolean> mapFieldEditAccess { get; set; } // map of field api name and Edit Access
    	@AuraEnabled public Map<String, boolean> mapFieldViewAccess { get; set; } // map of field api name and View Access
        @AuraEnabled public Map<String, String> mapHelpText { get; set; } // map of field api name and help text
        @AuraEnabled public String loggedInUser  {get; set;} // logged in user's name
        @AuraEnabled public Boolean blnIsSuccess  {get; set;} // success/failure flag 
        @AuraEnabled public String strMessage  {get; set;} // Exception message
        @AuraEnabled public List<String> lstTypePicklist  {get; set;} // list of picklist values for field Type thats applicable for record type 'Sales Call'
        
		// constructor to initialize variables                
        public responseWrapper(){
            
            mapFieldLabel = new Map<String, String>(); 
            mapFieldEditAccess = new  Map<String, boolean>();
            mapFieldViewAccess = new  Map<String, boolean>();
            mapHelpText = new  Map<String, String>();
            loggedInUser = UserInfo.getName();
            blnIsSuccess = true;
            strMessage = '';
            lstTypePicklist = Label.SalesCallTypePicklist.Split(';');
        }
    }
    
    // method to clone sales call record and return same to lightning component
    @Auraenabled
    public static responseWrapper cloneCustomerCall ( String recordId ){
   	        
        responseWrapper response = new responseWrapper();
        
        // get all fields for Customer call object
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Sales_Call__c').getDescribe().fields.getMap();
                   
        // read filed set to get list of fields to be cleared while cloning record
        List<Schema.FieldSetMember> lstFieldsToClear = Schema.SObjectType.Sales_Call__c.fieldSets.getMap().get('Clone_Fields_To_Clear_List').getFields();
        Set<String> setFieldsToClear = new Set<String>();
        for (Schema.FieldSetMember strFieldName :  lstFieldsToClear ){
            setFieldsToClear.add(strFieldName.getFieldPath().toLowerCase() );
        }
        
        System.debug('$$$ setFieldsToClear: '+ setFieldsToClear);
        System.debug('$$$ fieldMap.keySet(): '+ fieldMap.keySet());
        
        // prepare SOQL
        String strQuery = 'Select Manager__r.Name, Initiative__r.Name,Opportunity__r.Name, Account__r.Name, Contact__r.Name, Lead__r.Name, Campaign__r.Name ';       
        for (String fieldName: fieldMap.keySet()) {   
            
            if ( !setFieldsToClear.contains(fieldName))
            	strQuery = strQuery + ', ' + fieldName ;
            
            // prepare map of field API name to label, view/edit access, help text
            response.mapFieldLabel.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
            response.mapFieldEditAccess.put(fieldName, fieldMap.get(fieldName).getDescribe().isUpdateable());
            response.mapFieldViewAccess.put(fieldName, fieldMap.get(fieldName).getDescribe().isAccessible());
            response.mapHelpText.put(fieldName, fieldMap.get(fieldName).getDescribe().getInlineHelpText());
            
        }
        //strQuery = strQuery.removeEnd(', ');        
        strQuery += ' From Sales_Call__c Where Id = :recordId ';
		system.debug('$$$ strQuery: ' + strQuery);
        
        Sales_Call__c rec = Database.query(strQuery);          
        Sales_Call__c cloneRec = rec.clone(false, true); // clone record
        cloneRec.Status__c = 'New';
        cloneRec.OwnerId = UserInfo.getUserId();
        
        response.recSalesCall = cloneRec;        
        return response;
    }
    
    // method to save cloned record
    @Auraenabled
    public static responseWrapper saveClonedRecord ( Sales_Call__c record){
   	
        responseWrapper response = new responseWrapper();
        
        try{
            
            insert record;
            system.debug('$$$ record: '+record );
            response.recSalesCall = record;
            
        }catch( DmlException dmEx){
                        
            System.debug('$$$ DmlException : ' + dmEx);
            response.blnIsSuccess = false;
            response.strMessage =  dmEx.getDMLMessage(0); // return exception message to lightning component
            response.strMessage =  response.strMessage.replace('&quot;','\"'); // Validation messages may contain &quot - need to convert that to quotes
            
        } catch( Exception ex){
            
            System.debug('$$$ Exception : ' + ex);
            response.blnIsSuccess = false;
            response.strMessage = ex.getMessage();  // return exception message to lightning component
            response.strMessage =  response.strMessage.replace('&quot;','\"'); // Validation messages may contain &quot - need to convert that to quotes
        }       
        system.debug('$$$ response: '+response );
       return response;        
    }
}