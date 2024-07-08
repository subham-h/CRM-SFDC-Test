/*
 * Version		Story #			Date		Developer		Comments 
 * 1.0			SFSE-5541		5/2/2021	Meghana@UST		Code created, used in LWC		
 * 2.0      	SFSE-7742   	18/2/2022   Meghana@UST		Hamburg Sud brand related code changes
 * 3.0 			SFSE-8493   	04/8/2022   Vazid@UST		Alianca brand related code changes and Modified hard coded values BrandUtilities class
 * 4.0	    	SFSE-11753		03-11-23	Ritika@Maersk	To change the product family references to custom label
 */

public with sharing class RateStructureItemLwcCntrl {
	
    // wrapper class to send data to LWC - Rate Structure Item records, filter options, default filter to apply, field label to api map
    public class rsiData {
        
        @AuraEnabled public Map<String, String> mapFieldLabels {get; set;}
        @AuraEnabled public List<Rate_Structure_Item__c> lstRSI {get; set;}
        @AuraEnabled public Map<String, List<String>> mapFilterOptions {get; set;}
        @AuraEnabled public Map<String, String> mapFilterDefaults {get; set;}
        @AuraEnabled public Map<String, List<String>> mapsaleAppType {get; set;}
        @AuraEnabled public boolean blnRsiIsEditable {get; set;}
        @AuraEnabled public String strOpptyBrand {get; set;}
        
        public rsiData(){
            mapsaleAppType = new Map<String, List<String>>();
            lstRSI = new List<Rate_Structure_Item__c>();
            mapFilterOptions = new Map<String,List<String>>();
            mapFieldLabels = new Map<String, String>();
            mapFilterDefaults = new Map<String, String>();
			mapFilterDefaults.put('type__c', 'All');
            mapFilterDefaults.put('charge_type__c', 'All');
            mapFilterDefaults.put('occurrence__c', 'All');   
            mapFilterDefaults.put('cargo_type__c', '--NA--');
            mapFilterDefaults.put('product_family__c', 'All');
            blnRsiIsEditable = false;
            strOpptyBrand = '';
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static rsiData getRateStructureItemList(Id recordId) {

        Map<String, List<String>> ctrldependentMap = Lightning_Utilities.getDependentMap('Rate_Structure_Item__c','Type__c','Sales_Approach__c');

        // get Rate Structure Item records related to rate structure 
        Id relatedOpportunityId;
        rsiData response = new rsiData(); // create warpper class instance
        Set<String> setHSApprovalTypes = new Set<String>();
        setHSApprovalTypes.addAll(Label.RateStructure_Approval_Type_HS.split(';'));

        List<Rate_Structure_Item__c> lstRSItems = [SELECT Id, Name, Type__c, Charge_Name__c, New_Code__c, Exceptions__c,Cargo_Type__c, Occurrence__c,Previous_Sales_Approach__c,
                                                    Sales_Approach__c, Sales_Comments__c, Product_Family__c, Charge_Type__c, Rate_Structure__r.Opportunity__c, Rate_Structure__r.Brand__c
                                                    FROM Rate_Structure_Item__c
                                                    WHERE Rate_Structure__c =: recordId 
                                                    ORDER BY Type__c];
        
        if (!lstRSItems.isEmpty()){
            relatedOpportunityId = lstRSItems[0].Rate_Structure__r.Opportunity__c; // get opportunity id
            response.strOpptyBrand = lstRSItems[0].Rate_Structure__r.Brand__c;
        }
        system.debug('relatedOpportunityId: '+relatedOpportunityId);
                                                    
        response.lstRSI = lstRSItems;
        System.Debug('rsi list' +response.lstRSI);
       
        // form map of field label to field api names
            
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType rsiSchema = schemaMap.get('Rate_Structure_Item__c');
        Map<String, Schema.SObjectField> fieldMap = rsiSchema.getDescribe().fields.getMap();
        
        if (Schema.sObjectType.Rate_Structure_Item__c.isUpdateable()){
            response.blnRsiIsEditable = true;
        }
        system.debug('blnRsiIsEditable : '+  response.blnRsiIsEditable);
        
        for (String fieldName: fieldMap.keySet()) {    
            
            Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();               
            response.mapFieldLabels.put(fieldName, fieldResult.getLabel()); 
            
            if (fieldName == 'type__c' || fieldName == 'product_family__c' || fieldName == 'charge_type__c' || fieldName == 'occurrence__c' || fieldName == 'cargo_type__c'){
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
                List<String> strPicklistValues = new List<String>();
                strPicklistValues.add('All');

                for( Schema.PicklistEntry f : ple) {

                    String fieldLabel = f.getLabel();
                    if (fieldName == 'type__c'){
                        //SFSE-8493
                        if ( ((response.strOpptyBrand == BrandUtilities.HAMBURGSUD || response.strOpptyBrand == BrandUtilities.ALIANCA) && setHSApprovalTypes.contains(fieldLabel)) || (response.strOpptyBrand != BrandUtilities.HAMBURGSUD && response.strOpptyBrand != BrandUtilities.ALIANCA && ! setHSApprovalTypes.contains(fieldLabel)) ){
                            strPicklistValues.add(f.getLabel());
                        } 

                    } else {
                        strPicklistValues.add(fieldLabel);
                    }

                }       
                response.mapFilterOptions.put(fieldName, strPicklistValues);
            }
        }
        
       
        if (relatedOpportunityId != null){
            // find default values for filters
            List<String> oipc_code_Landside = System.Label.Landside_Transportation_OipcCodes.split(';');
            List<Opportunity_Product__c> lstOLI = [SELECT Id FROM Opportunity_Product__c 
                                            WHERE OpportunityId__c =:relatedOpportunityId AND OIPC_Product_Code__c In :oipc_code_Landside LIMIT 1 ];
        
            if (lstOLI.isEmpty()){
                response.mapFilterDefaults.put('product_family__c', 'Ocean');
            }
            List<Opportunity> opp = [SELECT Id, Cargo_Type__c, Opportunity_contains_Dangerous_Goods__c FROM Opportunity
                                     WHERE Id =:relatedOpportunityId ];
            
            if (opp[0].Opportunity_contains_Dangerous_Goods__c == 'No' && opp[0].Cargo_Type__c == 'Reefer')
                response.mapFilterDefaults.put('cargo_type__c', 'Reefer');
            else if (opp[0].Opportunity_contains_Dangerous_Goods__c != 'No' && opp[0].Cargo_Type__c != 'Reefer')
                response.mapFilterDefaults.put('cargo_type__c', 'Dangerous Goods');
            else if (opp[0].Opportunity_contains_Dangerous_Goods__c != 'No' && opp[0].Cargo_Type__c == 'Reefer')
                response.mapFilterDefaults.put('cargo_type__c', 'All');
        }
        response.mapsaleAppType.putAll(ctrldependentMap);
        return response;
    }   
    
     @AuraEnabled(cacheable=false)
    public static boolean updateRateStructureItemList(List<Rate_Structure_Item__c> lstToUpdate) {
        system.debug('in updateRSI ');
        system.debug(lstToUpdate);
        Map<Id, Rate_Structure_Item__c> mapToUpdate = new Map<Id, Rate_Structure_Item__c>();
        for (Rate_Structure_Item__c rec :lstToUpdate ){
            mapToUpdate.put(rec.Id, rec);
        }
        system.debug(mapToUpdate);

        database.update(mapToUpdate.values());
		return null; 
    }
}