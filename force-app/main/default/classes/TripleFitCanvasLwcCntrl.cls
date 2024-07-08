/*
* Version    Story #      Date    Developer    Comments 
* 1.0      SFSE-6747    19/08/2021  Neha@TCS    Code created, used in LWC 
* 2.0      SFSE-7304    15/12/2021  Neha@TCS    Added Main competitor field   
*/
public with sharing class TripleFitCanvasLwcCntrl {
    
    @AuraEnabled(cacheable=false)
    public static tfcData getTripleFitCanvasItemList(Id recordId) {
        Map<String, List<Integer>> ctrldependentMap = getDependentMap();
        double tempTotalOfCurrScore =0;
        double tempTotalOfTargetScore = 0; 
		double tempTotalOfMainCompetitorScore = 0;
        List<Triple_Fit_Canvas__c>  lstTFCRecords = [SELECT id, Account_Plan__c, Name, Current_Score__c, Main_Competitor_Score__c, Target_Score__c, Priority__c,Remarks__c
                                                     FROM Triple_Fit_Canvas__c
                                                     WHERE Account_Plan__c =: recordId
                                                     ORDER BY Order__c];
        tfcData response = new tfcData(); // create warpper class instance
        response.lstTFC = lstTFCRecords;    
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType tfcSchema = schemaMap.get('Triple_Fit_Canvas__c');
        Map<String, Schema.SObjectField> fieldMap = tfcSchema.getDescribe().fields.getMap();
        
        System.debug('fieldMap::::'+fieldMap);
        for (String fieldName: fieldMap.keySet()) { 
            Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();               
            response.mapFieldLabels.put(fieldName, fieldResult.getLabel()); 
            
        }
        //create summary row 
        for (Triple_Fit_Canvas__c  lstTFC :  lstTFCRecords) { 
            if(lstTFC.Current_Score__c != null) 
                tempTotalOfCurrScore+= lstTFC.Current_Score__c;
            if(lstTFC.Target_Score__c != null)
                tempTotalOfTargetScore += lstTFC.Target_Score__c;
			if(lstTFC.Main_Competitor_Score__c != null)
                tempTotalOfMainCompetitorScore += lstTFC.Main_Competitor_Score__c;
            
        }
        response.totalOfCurrScore =tempTotalOfCurrScore;
        response.totalOfTargetScore =tempTotalOfTargetScore;
		response.totalOfMainCompetitorScore =tempTotalOfMainCompetitorScore;
        response.mapScores = ctrldependentMap;
        return response;
        
    }  
    
    // wrapper class to send data to LWC
    public class tfcData {
        @AuraEnabled public List<Triple_Fit_Canvas__c> lstTFC {get; set;}
        @AuraEnabled public Map<String, String> mapFieldLabels {get; set;}
        @AuraEnabled public double totalOfCurrScore {get; set;}
        @AuraEnabled public double totalOfTargetScore {get; set;}
		@AuraEnabled public double totalOfMainCompetitorScore {get; set;}
        @AuraEnabled public Map<String, List<Integer>> mapScores {get; set;}
        
        public tfcData(){
            lstTFC = new List<Triple_Fit_Canvas__c>();
            mapFieldLabels = new Map<String, String>();        
        }
        
    } 
    // Method to display teh help section on TFC Page on Account Plan
    @AuraEnabled(cacheable=true)
    public static List<Triple_Fit_Canvas_Help__mdt> getTripleFirHelpSectionData(){
        List<Triple_Fit_Canvas_Help__mdt> tfCLst = [Select MasterLabel,Definition_of_score_5__c,Description__c, Order__c from Triple_Fit_Canvas_Help__mdt where isActive__c = true  Order by Order__c ASC];
        System.debug('tfCLst::'+tfCLst);
        return tfCLst;
    }
    // Method to update the Triple Fit Canvas Record via UI  
    @AuraEnabled(cacheable=false)
    public static boolean updateTripleFitRecordList(List<Triple_Fit_Canvas__c> lstToUpdate) {
        Map<Id, Triple_Fit_Canvas__c> mapToUpdate = new Map<Id, Triple_Fit_Canvas__c>();
        for (Triple_Fit_Canvas__c rec :lstToUpdate ){
            mapToUpdate.put(rec.Id, rec);
        }
        system.debug(mapToUpdate);
        
        database.update(mapToUpdate.values());
        return null; 
    }
    public static Map<String, List<Integer>> getDependentMap(){
        Map<String, List<Integer>> ctrldependentMap = new Map<String, List<Integer>>();
        List<Triple_Fit_Canvas_Help__mdt> tfCLst = [Select MasterLabel, Order__c from Triple_Fit_Canvas_Help__mdt where isActive__c = true  Order by Order__c ASC];
        for(Triple_Fit_Canvas_Help__mdt tfc : tfCLst){
            ctrldependentMap.put(tfc.MasterLabel, new List<Integer>{1,2,3,4,5});
        }
        return ctrldependentMap;
    }       
}