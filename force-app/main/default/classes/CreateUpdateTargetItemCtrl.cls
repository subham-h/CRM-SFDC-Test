/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11362  03-July-2023  Vinay                   Controller for createUpdateTargetItem Aura component	
* 2.0      SFSE-12879  10-Oct-2023   Vinay                   Removing isNCB__c field reference.    
*/
public class CreateUpdateTargetItemCtrl {
    
    /* This Method will query on Target Item Group object against record Id */
    @AuraEnabled
    public static Target_Item_Group__c getDetails(String targetItemGroupId) {
        Target_Item_Group__c tig = [SELECT Id,Product_Family__c,Executing_Country__c, Executing_Country__r.Name,Executing_Country__r.GEO_Code__c,BrandMnA__c FROM Target_Item_Group__c WHERE Id=:targetItemGroupId];
        return tig;
    }
    
    /* This method will create Target Item Group and Target Item Measure object records*/
    @AuraEnabled
    public static void createTargetRecords(Id targetItemGroupId, Target_Measure__c measure, String countryCode, Target_Item__c item) {
        try{
            if(targetItemGroupId != null){
                List<Target_Item_Group__c> listTargetItemGroup = [ SELECT Id, BrandMnA__c FROM Target_Item_Group__c WHERE Id = :targetItemGroupId ];
               
                // Insert Target Item Record.
                insert item;
                
                Map<String, Boolean> accCredMap = new  Map<String, Boolean>();
                if(item.Account__c!=NULL){
                   String accCustomerCode = [SELECT Id,Customer_Code__c FROM Account WHERE Id =:item.Account__c LIMIT 1]?.Customer_Code__c; 
                   
                    accCredMap = SalesCreditEligibilityHelper.getCreditEligibilityByPartyType(
                                new Map<String, String>{accCustomerCode=> countryCode}, 
                                new Map<String, String> {accCustomerCode => listTargetItemGroup[0].BrandMnA__c}, 
                                measure.Party_Type__c); 
              measure.Credit_Eligible__c = accCredMap.containsKey(accCustomerCode)?accCredMap.get(accCustomerCode):FALSE; 
            }            
            else{                
                measure.Credit_Eligible__c =TRUE; 
            }
            measure.Target_Item__c = item.Id;            
            insert measure;
            }    
            }
            catch(exception e){
                throw new AuraHandledException(e.getMessage());              
            }
        
    }
    
    /* This Method will fetch Active Picklist Values of fields in Target Measure Object and return them back to Aura Component*/
    @AuraEnabled
    public static Map<String, String> getPicklistValues(String sObjectName,String fieldName){
        
        String strObjectName = sObjectName=='Target Measure'?'Target_Measure__c':'Target_Item__c';
        
        String strPicklistField = fieldName=='Measure Type'?'Measure_Type__c':
        fieldName=='Measure Dimension'?'Measure_Dimension__c':
        fieldName=='Party Type'?'Party_Type__c':
        fieldName=='Target Item Type'?'Target_Item_Type__c':NULL; 	
        Map<String, String> options = new Map<String, String>();  
        Map<String, String> mapPickListValues = new Map<String, String>();
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for(Schema.PicklistEntry plv : lstPickListValues) {
            if(plv.isActive()){
                options.put(plv.getValue(), plv.getLabel());  
            }
        }
        return options;
    }
    
}