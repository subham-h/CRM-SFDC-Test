/* ******************************************************  
Class Name    : flowDynamicScreenApexController
Description   : Controller for Aura Component .
-----------------------  Revision History -------------------

Sno      Version      Author    Date            Descrition                  
1.       1.0          Neha-TCS      04/07/2019      This is created for RQ-010090, which is to allow and Encourage Sales to Update Profiles
                                                when they login into Salesforce. This is invoked from Screen Flow
*********************************************************/
public class flowDynamicScreenApexController {
    
  
    // This method get the user detail of the current User for which Login Flow is being fired
    @AuraEnabled
    public static User getUserDetails(String flowUserID){       
        User userRecord = [select id, Industry_Focus__c,Segment_Focus__c, Sales_Job_Function__c,Date_User_Last_Validated_Profile_Data__c from User where id = : flowUserID];        
        return userRecord;       
    }
  
    // This method updates the Vertical and Value Proposition Focus when the User select the values from the screen
    @AuraEnabled
    public static User upadetUserInfo(String flowUserID,List<String> selectedSegmentFocus,List<String> selectedVerticalFocus, String selectedJobFuctionValue){              
        User userRecord = [select id, Industry_Focus__c,Segment_Focus__c, Sales_Job_Function__c,Date_User_Last_Validated_Profile_Data__c from User where id = : flowUserID];        
        userRecord.Segment_Focus__c=formatListToMultiSelect(selectedSegmentFocus);  // Set the Value Proposition Focus from the selected records.
        userRecord.Industry_Focus__c=formatListToMultiSelect(selectedVerticalFocus);// Set the Vertical Focus from the selected records
        userRecord.Date_User_Last_Validated_Profile_Data__c= Date.today(); // Set the date which user modified the current Sales Job function to today     
        userRecord.Sales_Job_Function__c=selectedJobFuctionValue;
        update userRecord;
        return userRecord;       
    }
    
  // This method will display the list of Options for VP and vertical Focus field on the screen
  @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {        
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        
        allOpts.sort();
        return allOpts;
    }  
  
  // This will return the multi select picklist for list of Options
    @AuraEnabled
    public static String formatListToMultiSelect(List<String> values) {        
        if (values == null) return null;
        List<String> listOfVal = new List<String>(values);        
        if (!listOfVal.isEmpty()){
            listOfVal.sort();
            String finalSelectedValues= String.join(values,';');            
            return finalSelectedValues;
        }else{
            return null;
        }
    }

}