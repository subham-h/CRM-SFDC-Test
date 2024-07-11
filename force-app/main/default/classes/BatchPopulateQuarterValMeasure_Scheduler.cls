global class BatchPopulateQuarterValMeasure_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
           Set<Id> participantIds = new Set<Id>();
        Map<Id,List<Id>> mapManagerSubOrds = new Map<Id,List<Id>>();
        Map<string,Sales_Rep_target_Quarter_Data__c> keyForMeasures = new Map<string,Sales_Rep_target_Quarter_Data__c>();
        Map<string,List<Sales_Rep_target_Quarter_Data__c>> keyForMeasuresWithoutPF = new  Map<string,List<Sales_Rep_target_Quarter_Data__c>>();
        List<Sales_Rep_target_Quarter_Data__c> listOfRecordToUpdate = new List<Sales_Rep_target_Quarter_Data__c>();
        String key;
        string currentYear = String.ValueOf(Date.Today().year());
 
        List<sip_Measure__c> lstOfSipMeasure = [SELECT id,SIP_Participant__c,SIP_Participant__r.SIP_Participant__c,SIP_KPI__r.L_S_product_family__c,SIP_KPI__r.Measure_Type__c FROM Sip_Measure__c where Load_Target_from_STS__c = true  AND SIP_Participant__r.Year__c = :currentYear];
        
        for(Sip_measure__c sipMeasure :lstOfSipMeasure){
            participantIds.add(sipMeasure.SIP_Participant__r.SIP_Participant__c);
        }
        List<Sales_Rep_target_Quarter_Data__c> lstSipPartcipant = [Select id,Sales_Rep__c,Measure_Type__c,L_S_product_family__c,Q1_Total__c,Q2_Total__c,Q3_Total__c,Q4_Total__c from Sales_Rep_target_Quarter_Data__c WHERE Sales_Rep__c In :ParticipantIds ];
         
        For(Sales_Rep_target_Quarter_Data__c targetData : lstSipPartcipant ){
            //Prepare map without PF combination
            if(!keyForMeasuresWithoutPF.containskey(targetData.Sales_Rep__c + '-' + targetData.Measure_Type__c)){
				keyForMeasuresWithoutPF.put(targetData.Sales_Rep__c + '-' + targetData.Measure_Type__c, new List<Sales_Rep_target_Quarter_Data__c>{targetData});
			}
				keyForMeasuresWithoutPF.get(targetData.Sales_Rep__c + '-' + targetData.Measure_Type__c).add(targetData);
            //prepare map with PF Comination
            if(!keyForMeasures.containsKey(targetData.Sales_Rep__c + '-'+ targetData.L_S_product_family__c +'-' + targetData.Measure_Type__c)){
                keyForMeasures.put(targetData.Sales_Rep__c + '-'+ targetData.L_S_product_family__c +'-' + targetData.Measure_Type__c, targetData);
            }
                  
        }
        for(Sip_measure__c sipMeasure :lstOfSipMeasure){
           
            if(sipMeasure.SIP_KPI__r.L_S_product_family__c != null){
                if(sipMeasure.SIP_KPI__r.L_S_product_family__c.contains(';')){
                    For(String pf : sipMeasure.SIP_KPI__r.L_S_product_family__c.split(';')){
                        if(keyForMeasures.get(sipMeasure.SIP_Participant__r.SIP_Participant__c + '-' + pf + '-' + sipMeasure.SIP_KPI__r.Measure_Type__c) != null){
                        listOfRecordToUpdate.add(keyForMeasures.get(sipMeasure.SIP_Participant__r.SIP_Participant__c + '-' + pf + '-' + sipMeasure.SIP_KPI__r.Measure_Type__c));
                       
                    }
                    }
                }else if(keyForMeasures.get(sipMeasure.SIP_Participant__r.SIP_Participant__c + '-' + sipMeasure.SIP_KPI__r.L_S_product_family__c + '-' + sipMeasure.SIP_KPI__r.Measure_Type__c)!= null){
                    
                    listOfRecordToUpdate.add(keyForMeasures.get(sipMeasure.SIP_Participant__r.SIP_Participant__c + '-' + sipMeasure.SIP_KPI__r.L_S_product_family__c + '-' + sipMeasure.SIP_KPI__r.Measure_Type__c));
                       
                }
                
            }else if(keyForMeasuresWithoutPF.get(sipMeasure.SIP_Participant__r.SIP_Participant__c + '-' +sipMeasure.SIP_KPI__r.Measure_Type__c) != null){
					listOfRecordToUpdate.addAll(keyForMeasuresWithoutPF.get(sipMeasure.SIP_Participant__r.SIP_Participant__c + '-' +sipMeasure.SIP_KPI__r.Measure_Type__c));
                       
            }
        }
        Map<id,Sales_Rep_target_Quarter_Data__c> mapOfIntermediateRecord = new Map<id,Sales_Rep_target_Quarter_Data__c>();
        for(Sales_Rep_target_Quarter_Data__c s: listOfRecordToUpdate){
            s.Q1_Total__c = 0;
            s.Q2_Total__c = 0;
            s.Q3_Total__c = 0;
            s.Q4_Total__c = 0;
            mapOfIntermediateRecord.put(s.id,s);
 
        }
        if(!mapOfIntermediateRecord.isEmpty()){
            Database.SaveResult[] updateList = Database.Update(mapOfIntermediateRecord.values(),false);
            ErrorLogger.writeErrors('SFDC', 'Sales Target', 'STS SIP Targets Rollout Schedular', updateList, mapOfIntermediateRecord.values());            
        }

        if(!participantIds.isEmpty()){
            mapManagerSubOrds = GetHierarchicalUsers.retriveSubordinatesList(participantIds);}
       
        if(!mapManagerSubOrds.isEmpty()){
            participantIds.removeAll(mapManagerSubOrds.keySet());
        }
        BatchPopulateQuarterValuesOnMeasure b = new BatchPopulateQuarterValuesOnMeasure(participantIds,currentYear); 
        database.executebatch(b, Integer.valueOf(Target_Setting_Batch_Query__mdt.getInstance('STS_SIP_BATCH1').Batch_Size__c));
    }
}