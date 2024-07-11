/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		19-Sept-2023	Sidhartha				Batch to update target by scenario planning	
*/
global with sharing class BatchUpdateTargetItemTargetMeasure implements Database.Batchable<SObject>, Database.Stateful {
    public Id targetIds;
    public string wherequery;
    public String strMeasureType;
    public String sipEligibleVal;
    public String growthtypeVal;
    public String targetCusPortQuery;
    public Map<String, String> mapOfMonthTovalue = new Map<String, String>();
    public Map<String, String> previousActualMap = new Map<String, String>();
    public List<String> partytype= new List<String>();
    public Boolean blncreditcheck = false;
    private List<Id> successes = new List<Id>();
    private List<Id> failures = new List<Id>();
    public BatchUpdateTargetItemTargetMeasure(String wherequery, Id targetIds,string sipEligibleVal,  string strMeasureType, Map<String, String> mapOfMonthTovalue, List<String> partytype, Map<String, String> previousActualMap, String growthtypeVal, String targetCusPortQuery){
       	system.debug('sipEligibleVal ' + sipEligibleVal);
        
        this.targetIds = targetIds;
        this.strMeasureType = strMeasureType;
        this.mapOfMonthTovalue = mapOfMonthTovalue;
        this.partytype = partytype;
        this.blncreditcheck = sipEligibleVal == 'Yes' ? true : false;
        this.previousActualMap = previousActualMap;
        this.wherequery = wherequery;
        this.sipEligibleVal = sipEligibleVal;
        this.growthtypeVal = growthtypeVal;
        this.targetCusPortQuery = targetCusPortQuery;
    }  
    global Iterable<Target_Item__c> start(Database.BatchableContext info){
      return new targetMeasureDataIterable(targetIds, targetCusPortQuery, wherequery, 0, 0, 'Name','ASC', sipEligibleVal);
   }
    
    global void execute(Database.BatchableContext info, List<Target_Item__c> targetItems) {  
        system.debug('targetItems ' + targetItems.size());
        Set<Id> tids = new Set<Id>();
        for(Target_Item__c tm : targetItems) {
            tids.add(tm.Id);
        }
        string strMeasureQuery =   'Select Id, UserRecordAccess.HasEditAccess, Target_Item__c, Name, Measure_Type__c, Measure_Dimension__c, Jan__c,'+
            +'Feb__c, Mar__c, Apr__c, May__c,  Jun__c, Jul__c, Aug__c, Sep__c,'+ 
            +'Oct__c, Nov__c, Dec__c, Credit_Eligible__c, Party_Type__c,'+ 
            +'Q1_Total__c, Q2_Total__c, Q3_Total__c, Q4_Total__c, Total__c'+
            +' from Target_Measure__c where Target_Item__c IN : tids';
        if (String.isNotEmpty(strMeasureType) && !Test.isRunningTest() ){
          //  strMeasureQuery += ' AND Measure_Type__c =:strMeasureType AND Party_Type__c IN :partytype AND Measure_Dimension__c = \'Target\'';
        }
        if(String.isEmpty(sipEligibleVal)) {
            strMeasureQuery += ' AND Measure_Type__c =:strMeasureType AND Party_Type__c IN :partytype AND Measure_Dimension__c = \'Target\''; 
        }else{
            strMeasureQuery += ' AND Measure_Type__c =:strMeasureType AND Party_Type__c IN :partytype AND Credit_Eligible__c =:blncreditcheck AND Measure_Dimension__c = \'Target\'';
        }
        system.debug('strMeasureQuery ' + strMeasureQuery);
        List<Target_Measure__c> salesTargetMeasure = new List<Target_Measure__c>();
        if(!Test.isRunningTest()) {
            salesTargetMeasure = Database.query(strMeasureQuery);
        }else{
            salesTargetMeasure = [Select Id, UserRecordAccess.HasEditAccess, Target_Item__c, Name, Measure_Type__c, Measure_Dimension__c, Jan__c,Feb__c, Mar__c, Apr__c, May__c,  Jun__c, Jul__c, Aug__c, Sep__c,
                                  Oct__c, Nov__c, Dec__c, Credit_Eligible__c, Party_Type__c,
                                  Q1_Total__c, Q2_Total__c, Q3_Total__c, Q4_Total__c, Total__c
                                  from Target_Measure__c ]; 
        }
        system.debug('salesTargetMeasure ' + salesTargetMeasure);
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        List<Target_Measure__c> lsttm = new List<Target_Measure__c>();
        for(Target_Measure__c tm : salesTargetMeasure) {
            if(growthtypeVal == 'Percentage' && tm.UserRecordAccess.HasEditAccess) {
                if(previousActualMap !=null && !previousActualMap.isEmpty() && previousActualMap.get(tm.Target_Item__c) !=null) {
                    Target_Measure__c tms = (Target_Measure__c) System.JSON.deserialize(previousActualMap.get(tm.Target_Item__c), Target_Measure__c.Class);
                    //system.debug('tms ' + tms);
                    //system.debug('tm ' + tm);
                    if(tms.Jan__c != null) {
                        tm.Jan__c = tms.Jan__c;
                    }
                   // system.debug('tm.Jan__c ' + tm.Jan__c);
                    if(tms.Feb__c != null) {
                        tm.Feb__c = tms.Feb__c;
                    }
                    //system.debug('tm.Feb__c ' + tm.Feb__c);
                    if(tms.Mar__c != null) {
                        tm.Mar__c = tms.Mar__c;
                    }
                   // system.debug('tm.Mar__c ' + tm.Mar__c);
                    if(tms.Apr__c != null) {
                        tm.Apr__c = tms.Apr__c;
                    }
                   // system.debug('tm.Apr__c ' + tm.Apr__c);
                    if(tms.May__c != null) {
                        tm.May__c = tms.May__c;
                    }
                   // system.debug('tm.May__c ' + tm.May__c);
                    if(tms.Jun__c != null) {
                        tm.Jun__c = tms.Jun__c;
                    }
                  //  system.debug('tm.Jun__c ' + tm.Jun__c);
                    if(tms.Jul__c != null) {
                        tm.Jul__c = tms.Jul__c;
                    }
                   // system.debug('tm.Jul__c ' + tm.Jul__c);
                    if(tms.Aug__c != null) {
                        tm.Aug__c = tms.Aug__c;
                    }
                 //   system.debug('tm.Aug__c ' + tm.Aug__c);
                    if(tms.Sep__c != null) {
                        tm.Sep__c =  tms.Sep__c;
                    }
                  //  system.debug('tm.Sep__c ' + tm.Sep__c);
                    if(tms.Oct__c != null) {
                        tm.Oct__c = tms.Oct__c;
                    }
                 //   system.debug('tm.Oct__c ' + tm.Oct__c);
                    if(tms.Nov__c != null) {
                        tm.Nov__c = tms.Nov__c;
                    }
                //    system.debug('tm.Nov__c ' + tm.Nov__c);
                    if(tms.Dec__c != null) {
                        tm.Dec__c = tms.Dec__c;
                    }
                //    system.debug('tm.Dec__c ' + tm.Dec__c);
                }
            }
            if(growthtypeVal == 'Amount' && tm.UserRecordAccess.HasEditAccess && mapOfMonthTovalue !=null){
                tm.Jan__c = mapOfMonthTovalue.get(String.valueof('Jan__c')) !=null ? tm.Jan__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Jan__c'))) : tm.Jan__c;
                tm.Feb__c = mapOfMonthTovalue.get(String.valueof('Feb__c')) !=null ? tm.Feb__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Feb__c'))) : tm.Feb__c;
                tm.Mar__c = mapOfMonthTovalue.get(String.valueof('Mar__c')) !=null ? tm.Mar__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Mar__c'))) : tm.Mar__c;
                tm.Apr__c = mapOfMonthTovalue.get(String.valueof('Apr__c')) !=null ? tm.Apr__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Apr__c'))) : tm.Apr__c;
                tm.May__c = mapOfMonthTovalue.get(String.valueof('May__c')) !=null ? tm.May__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('May__c'))) : tm.May__c;
                tm.Jun__c = mapOfMonthTovalue.get(String.valueof('Jun__c')) !=null ? tm.Jun__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Jun__c'))) : tm.Jun__c;
                tm.Jul__c = mapOfMonthTovalue.get(String.valueof('Jul__c')) !=null ? tm.Jul__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Jul__c'))) : tm.Jul__c;
                tm.Aug__c = mapOfMonthTovalue.get(String.valueof('Aug__c')) !=null ? tm.Aug__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Aug__c'))) : tm.Aug__c;
                tm.Sep__c = mapOfMonthTovalue.get(String.valueof('Sep__c')) !=null ? tm.Sep__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Sep__c'))) : tm.Sep__c;
                tm.Oct__c = mapOfMonthTovalue.get(String.valueof('Oct__c')) !=null ? tm.Oct__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Oct__c'))) : tm.Oct__c;
                tm.Nov__c = mapOfMonthTovalue.get(String.valueof('Nov__c')) !=null ? tm.Nov__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Nov__c'))) : tm.Nov__c;
                tm.Dec__c = mapOfMonthTovalue.get(String.valueof('Dec__c')) !=null ? tm.Dec__c + Decimal.valueof(mapOfMonthTovalue.get(String.valueof('Dec__c'))) : tm.Dec__c;  
            }
            lsttm.add(tm);
            system.debug('lsttm ' + lsttm);
        }
        try{
            saveResults = Database.update(lsttm, false);
            ErrorLogger.writeErrors('SFDC', 'Measure Update', 'BatchUpdateTargetItemTargetMeasure', saveResults, lsttm);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    successes.add(sr.id);
                } else {
                    failures.add(sr.id);
                }
            }
        }catch(exception e){
            system.debug('@@@@' + e);
            ErrorLogger.writeErrors('SFDC', 'Measure Update', 'BatchUpdateTargetItemTargetMeasure', saveResults, lsttm);
        }
        
    }
    global void finish(Database.BatchableContext BC) {
    }
}