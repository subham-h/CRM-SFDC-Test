/*

* Purpose  : Controller class for VF page 'SIP Target Setting
*        
 * Revision     Ref Number      Date            Owner                                Description
* --------     ----------      -----------     -------------------                   -----------
* 1.0          RQ-004150       26-Aug-2016     meghana.gupta@ust-global.com        Code created
* 2.0          RQ-010223       15-Mar-2019     meghana.gupta@ust-global.com        From 2019Q2 onwards show temporary message that feature not available temporarily, hence commneting code for now
* 3.0          RQ-010682       10-Jun-2019     Junaid.Khader@ust-global.com        Updated code to incorporate LWC changes
* 4.0       RQ-012770     26-Dec-2019     manjunath@maersk             Added and replaced few fields as part of the SIP page  
* 5.0       RQ-013101     20-Feb-2020     Amritesh@UST                 Added FirstName and LastName fields for Sales_Rep__r in query 
* 6.0       SFSE-4864     02-Dec-2020     Neha@Tcs					   SIP target changes
* 7.0 		SFSE-13440		29-Nov-2023			Vazid				 To avoid operations in loops that may hit governor limits
*/
public without sharing  class SIPTargetController{
    
        
    
    @AuraEnabled(cacheable=true)
    public static SipDataModel getSIPModelDetails(String idSip){
        SipDataModel rowSipDataModel;
        
        if(String.isNotBlank(idSip)){
            Map<Id, SIP__c> mapIdtoSip = new Map<Id, SIP__c>();
            Set<Id> setRecordTypeIds;
            Id idEaseAdvancementRT = Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Ease_Advancement').getRecordTypeId();
            Id idEfficiencySuperSaverRT = Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Efficiency_Super_Saver').getRecordTypeId();
            Id idExpertiseAmbitionRT = Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Expertise_Ambition').getRecordTypeId();
            
            setRecordTypeIds = new Set<Id>();
            setRecordTypeIds.add(idEaseAdvancementRT);
            setRecordTypeIds.add(idEfficiencySuperSaverRT);
            setRecordTypeIds.add(idExpertiseAmbitionRT);
            SIP__c recSIP = [SELECT Id, Quarter__c, Sales_Rep__c, RecordTypeId FROM SIP__c WHERE Id = :idSip LIMIT 1];
            
            if(recSIP != null){
                for(SIP__c rowSIP : [SELECT Id, Sales_Rep__c, Sales_Rep__r.Name, Quarter__c, RecordTypeId,
                                        Sales_Rep__r.FirstName, Sales_Rep__r.LastName,
                                         Acquisition_Target__c, E2E_Volume_Target_FFE__c,
                                         Volume_Target__c, Revenue_Growth_VAS_Target__c,
                                         Ocean_Revenue_Target_USD__c,Landside_Trans_VP_Target_FFE__c,Landside_Trans_VP_Weight_Percent__c
                                         ,Revenue_Growth_VAS_Weight_Percent__c,Revenue_Weight_Percent__c,Volume_Weight_Percent__c
                                         ,Maersk_Spot_Volume_Weight_Percent__c,Acquisition_Weight_Percent__c,E2E_Volume_Weight_Percent__c
                                         ,Maersk_Spot_Volume_Target_FFE__c
                                     FROM SIP__c
                                     WHERE Quarter__c = :recSIP.Quarter__c
                                         AND RecordTypeId IN :setRecordTypeIds
                                         AND (Sales_Rep__r.ManagerId = :recSIP.Sales_Rep__c OR Sales_Rep__c = :recSIP.Sales_Rep__c)
                                      ORDER BY Sales_Rep__r.Name ASC]){ 

                    mapIdtoSip.put(rowSIP.Id, rowSIP);
                    /*SFSE-13440 : Commented below code to Avoid Deeply Nested IF Statements*/
                    /*if(rowSIP.Id == recSIP.Id){
                        rowSipDataModel = new SipDataModel(rowSIP);
                        //rowSipDataModel.rowSIPExp = rowSIP;
                        system.debug('a1a:'+rowSIP.Maersk_Spot_Volume_Target_FFE__c);
                        if(rowSIP.RecordTypeId == idEaseAdvancementRT){
                            rowSipDataModel.intAcquisitionTarget = rowSIP.Acquisition_Target__c;
                            rowSipDataModel.intE2EVolumeTarget = rowSIP.E2E_Volume_Target_FFE__c;
                        } else if(rowSIP.RecordTypeId == idEfficiencySuperSaverRT){
                            rowSipDataModel.intVolumeTarget = rowSIP.Volume_Target__c;
                            rowSipDataModel.intLandisdeVPEffTarget = rowSIP.Landside_Trans_VP_Target_FFE__c;
                            rowSipDataModel.intRevenueGrowthTarget = rowSIP.Revenue_Growth_VAS_Target__c;
              rowSipDataModel.intMrskSpotVolTrgt = rowSIP.Maersk_Spot_Volume_Target_FFE__c;
                        } else if(rowSIP.RecordTypeId == idExpertiseAmbitionRT){
                            rowSipDataModel.intVolumeExpTarget = rowSIP.Volume_Target__c;
                            rowSipDataModel.intRevenueGrowthExpTarget = rowSIP.Revenue_Growth_VAS_Target__c;
							rowSipDataModel.intLandisdeVPTarget = rowSIP.Landside_Trans_VP_Target_FFE__c;
                            rowSipDataModel.intRevenueTarget = rowSIP.Ocean_Revenue_Target_USD__c;
                        }
                    }*/
                    /*SFSE-13440 : Ends here*/
                    /*SFSE-13440 : Added 'rowSIP.Id == recSIP.Id' in same if condition to avoid Deeply Nested IF Statements*/
                    if(rowSIP.Id == recSIP.Id && rowSIP.RecordTypeId == idEaseAdvancementRT){
                        rowSipDataModel = new SipDataModel(rowSIP);
                        rowSipDataModel.intAcquisitionTarget = rowSIP.Acquisition_Target__c;
                        rowSipDataModel.intE2EVolumeTarget = rowSIP.E2E_Volume_Target_FFE__c;
                    } else if(rowSIP.Id == recSIP.Id && rowSIP.RecordTypeId == idEfficiencySuperSaverRT){
                        rowSipDataModel = new SipDataModel(rowSIP);
                        rowSipDataModel.intVolumeTarget = rowSIP.Volume_Target__c;
                        rowSipDataModel.intLandisdeVPEffTarget = rowSIP.Landside_Trans_VP_Target_FFE__c;
                        rowSipDataModel.intRevenueGrowthTarget = rowSIP.Revenue_Growth_VAS_Target__c;
                        rowSipDataModel.intMrskSpotVolTrgt = rowSIP.Maersk_Spot_Volume_Target_FFE__c;
                    } else if(rowSIP.Id == recSIP.Id && rowSIP.RecordTypeId == idExpertiseAmbitionRT){
                        rowSipDataModel = new SipDataModel(rowSIP);
                        rowSipDataModel.intVolumeExpTarget = rowSIP.Volume_Target__c;
                        rowSipDataModel.intRevenueGrowthExpTarget = rowSIP.Revenue_Growth_VAS_Target__c;
						rowSipDataModel.intLandisdeVPTarget = rowSIP.Landside_Trans_VP_Target_FFE__c;
                        rowSipDataModel.intRevenueTarget = rowSIP.Ocean_Revenue_Target_USD__c;
                    }
                    /*SFSE-13440 : Ends here*/
                }
                List<SIP__c> listEaseAdvancementSips = new List<SIP__c>();
                List<SIP__c> listEfficiencySuperSaverSips = new List<SIP__c>();
                List<SIP__c> listExpertiseAmbitionSips = new List<SIP__c>();

                //system.debug('$$#'+rowSipDataModel.rowSip.Volume_Target__c);
                for(SIP__c recordSip : mapIdtoSip.values()){
                     /*SFSE-13440 : Commented below code to Avoid Deeply Nested IF Statements*/
                    /*if(recordSip.Id != recSIP.Id){
                        if(recordSip.RecordTypeId == idEaseAdvancementRT) {
                            listEaseAdvancementSips.add(recordSip);
                            if(recordSip.Acquisition_Target__c != null)
                                rowSipDataModel.rowSip.Acquisition_Target__c -= recordSip.Acquisition_Target__c;
                            if(recordSip.E2E_Volume_Target_FFE__c != null)
                                rowSipDataModel.rowSip.E2E_Volume_Target_FFE__c -= recordSip.E2E_Volume_Target_FFE__c;
                        } else if(recordSip.RecordTypeId == idEfficiencySuperSaverRT){
                            listEfficiencySuperSaverSips.add(recordSip);
                            if(recordSip.Volume_Target__c != null)
                                rowSipDataModel.rowSip.Volume_Target__c -= recordSip.Volume_Target__c;
                            if(recordSip.Revenue_Growth_VAS_Target__c != null)
                                rowSipDataModel.rowSip.Revenue_Growth_VAS_Target__c -= recordSip.Revenue_Growth_VAS_Target__c;
                            if(recordSip.Maersk_Spot_Volume_Target_FFE__c != null)
                                rowSipDataModel.rowSip.Maersk_Spot_Volume_Target_FFE__c -= recordSip.Maersk_Spot_Volume_Target_FFE__c;                        
            } else if(recordSip.RecordTypeId == idExpertiseAmbitionRT){
                            listExpertiseAmbitionSips.add(recordSip);
                            if(recordSip.Volume_Target__c != null)
                                rowSipDataModel.rowSipExp.Volume_Target__c -= recordSip.Volume_Target__c;
                            if(recordSip.Revenue_Growth_VAS_Target__c != null)
                                rowSipDataModel.rowSipExp.Revenue_Growth_VAS_Target__c -= recordSip.Revenue_Growth_VAS_Target__c;
                            if(recordSip.Ocean_Revenue_Target_USD__c != null)
                                rowSipDataModel.rowSipExp.Ocean_Revenue_Target_USD__c -= recordSip.Ocean_Revenue_Target_USD__c;
                        }
                    }*/
                    /*SFSE-13440 : Ends here*/
                    /*SFSE-13440 : Added 'recordSip.Id != recSIP.Id)' in same if condition to avoid Deeply Nested IF Statements*/
                    if(recordSip.Id != recSIP.Id && recordSip.RecordTypeId == idEaseAdvancementRT) {
                        listEaseAdvancementSips.add(recordSip);
                        if(recordSip.Acquisition_Target__c != null)
                            rowSipDataModel.rowSip.Acquisition_Target__c -= recordSip.Acquisition_Target__c;
                        if(recordSip.E2E_Volume_Target_FFE__c != null)
                            rowSipDataModel.rowSip.E2E_Volume_Target_FFE__c -= recordSip.E2E_Volume_Target_FFE__c;
                    } else if(recordSip.Id != recSIP.Id && recordSip.RecordTypeId == idEfficiencySuperSaverRT){
                        listEfficiencySuperSaverSips.add(recordSip);
                        if(recordSip.Volume_Target__c != null)
                            rowSipDataModel.rowSip.Volume_Target__c -= recordSip.Volume_Target__c;
                        if(recordSip.Revenue_Growth_VAS_Target__c != null)
                            rowSipDataModel.rowSip.Revenue_Growth_VAS_Target__c -= recordSip.Revenue_Growth_VAS_Target__c;
                        if(recordSip.Maersk_Spot_Volume_Target_FFE__c != null)
                            rowSipDataModel.rowSip.Maersk_Spot_Volume_Target_FFE__c -= recordSip.Maersk_Spot_Volume_Target_FFE__c;                        
                    } else if(recordSip.Id != recSIP.Id && recordSip.RecordTypeId == idExpertiseAmbitionRT){
                        listExpertiseAmbitionSips.add(recordSip);
                        if(recordSip.Volume_Target__c != null)
                            rowSipDataModel.rowSipExp.Volume_Target__c -= recordSip.Volume_Target__c;
                        if(recordSip.Revenue_Growth_VAS_Target__c != null)
                            rowSipDataModel.rowSipExp.Revenue_Growth_VAS_Target__c -= recordSip.Revenue_Growth_VAS_Target__c;
                        if(recordSip.Ocean_Revenue_Target_USD__c != null)
                            rowSipDataModel.rowSipExp.Ocean_Revenue_Target_USD__c -= recordSip.Ocean_Revenue_Target_USD__c;
                    }
                    
                    /*SFSE-13440 : Ends here*/
                }
                rowSipDataModel.strEaseAdv = Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Ease_Advancement').getName();
                rowSipDataModel.strEfficiencySup = Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Efficiency_Super_Saver').getName();
                rowSipDataModel.strExpertiseAmb = Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Expertise_Ambition').getName();
                /*SFSE-13440 : Modified below line using ternary operator to avoid Deeply Nested IF Statements*/
                /*if(listEaseAdvancementSips.size() == 0 && listEfficiencySuperSaverSips.size() == 0 && listExpertiseAmbitionSips.size() == 0)
                    rowSipDataModel.showNoRecords = true;*/
                rowSipDataModel.showNoRecords = (listEaseAdvancementSips.size() == 0 && listEfficiencySuperSaverSips.size() == 0 && listExpertiseAmbitionSips.size() == 0) ? true : false;
                /*SFSE-13440 : Ends here*/
                rowSipDataModel.strEaseAdvancementDetails = JSON.serialize(listEaseAdvancementSips);
                rowSipDataModel.strEfficienySuperSaverDetails = JSON.serialize(listEfficiencySuperSaverSips);
                rowSipDataModel.strExpertiseAmbitionDetails = JSON.serialize(listExpertiseAmbitionSips);
                
                if(recSIP.RecordTypeId == idEaseAdvancementRT){
                    rowSipDataModel.rowSIP.Volume_Target__c = 0;
                    rowSipDataModel.rowSIP.Revenue_Growth_VAS_Target__c = 0;
                    rowSipDataModel.rowSIP.Landside_Trans_VP_Target_FFE__c = 0;
                    rowSipDataModel.rowSIPExp.Volume_Target__c = 0;
                    rowSipDataModel.rowSIPExp.Revenue_Growth_VAS_Target__c = 0;
                    rowSipDataModel.rowSIPExp.Landside_Trans_VP_Target_FFE__c = 0;
                    rowSipDataModel.rowSIPExp.Ocean_Revenue_Target_USD__c = 0;
					rowSipDataModel.rowSIP.Maersk_Spot_Volume_Target_FFE__c = 0;          
                } else if(recSIP.RecordTypeId == idEfficiencySuperSaverRT){
                    rowSipDataModel.rowSIP.Acquisition_Target__c = 0;
                    rowSipDataModel.rowSIP.E2E_Volume_Target_FFE__c = 0;
                    rowSipDataModel.rowSIPExp.Volume_Target__c = 0;
                    rowSipDataModel.rowSIPExp.Revenue_Growth_VAS_Target__c = 0;
                    rowSipDataModel.rowSIPExp.Landside_Trans_VP_Target_FFE__c = 0;
                    rowSipDataModel.rowSIPExp.Ocean_Revenue_Target_USD__c = 0;
                } else if(recSIP.RecordTypeId == idExpertiseAmbitionRT){
                    rowSipDataModel.rowSIP.Acquisition_Target__c = 0;
                    rowSipDataModel.rowSIP.E2E_Volume_Target_FFE__c = 0;
                    rowSipDataModel.rowSIP.Volume_Target__c = 0;
                    rowSipDataModel.rowSIP.Revenue_Growth_VAS_Target__c = 0;
                    rowSipDataModel.rowSIP.Landside_Trans_VP_Target_FFE__c = 0;
					rowSipDataModel.rowSIP.Maersk_Spot_Volume_Target_FFE__c = 0;
                }
                
                rowSipDataModel.rowSIP.Acquisition_Target__c = (rowSipDataModel.rowSIP.Acquisition_Target__c >= 0) ? rowSipDataModel.rowSIP.Acquisition_Target__c : 0;
                rowSipDataModel.rowSIP.E2E_Volume_Target_FFE__c = (rowSipDataModel.rowSIP.E2E_Volume_Target_FFE__c >= 0) ? rowSipDataModel.rowSIP.E2E_Volume_Target_FFE__c : 0;
                rowSipDataModel.rowSIP.Volume_Target__c = (rowSipDataModel.rowSIP.Volume_Target__c >= 0) ? rowSipDataModel.rowSIP.Volume_Target__c : 0;
                rowSipDataModel.rowSIP.Revenue_Growth_VAS_Target__c = (rowSipDataModel.rowSIP.Revenue_Growth_VAS_Target__c >= 0) ? rowSipDataModel.rowSIP.Revenue_Growth_VAS_Target__c : 0;
                rowSipDataModel.rowSIP.Landside_Trans_VP_Target_FFE__c = (rowSipDataModel.rowSIP.Landside_Trans_VP_Target_FFE__c >= 0) ? rowSipDataModel.rowSIP.Landside_Trans_VP_Target_FFE__c : 0;
				rowSipDataModel.rowSIP.Maersk_Spot_Volume_Target_FFE__c = (rowSipDataModel.rowSIP.Maersk_Spot_Volume_Target_FFE__c >= 0) ? rowSipDataModel.rowSIP.Maersk_Spot_Volume_Target_FFE__c : 0;
                
                rowSipDataModel.rowSIPExp.Volume_Target__c = (rowSipDataModel.rowSIPExp.Volume_Target__c >= 0) ? rowSipDataModel.rowSIPExp.Volume_Target__c : 0;
                rowSipDataModel.rowSIPExp.Revenue_Growth_VAS_Target__c = (rowSipDataModel.rowSIPExp.Revenue_Growth_VAS_Target__c >= 0) ? rowSipDataModel.rowSIPExp.Revenue_Growth_VAS_Target__c : 0;
                rowSipDataModel.rowSIPExp.Ocean_Revenue_Target_USD__c = (rowSipDataModel.rowSIPExp.Ocean_Revenue_Target_USD__c >= 0) ? rowSipDataModel.rowSIPExp.Ocean_Revenue_Target_USD__c : 0;
                rowSipDataModel.rowSIPExp.Landside_Trans_VP_Target_FFE__c = (rowSipDataModel.rowSIPExp.Landside_Trans_VP_Target_FFE__c >= 0) ? rowSipDataModel.rowSIPExp.Landside_Trans_VP_Target_FFE__c : 0;
				
                
                
                String strSelectedYear = recSIP.Quarter__c.left(4);
                String strListQuarter = '';
                List<String> listPreviousQuarters = SIP_Utilities.getQuarterList(true, Integer.ValueOf(strSelectedYear));
                /*SFSE-13440 : Modified below line using ternary operator to avoid Deeply Nested IF Statements*/
                /*if(listPreviousQuarters.size() > 0){
                    strListQuarter += listPreviousQuarters[0];
                }*/
                strListQuarter += (listPreviousQuarters.size() > 0) ? listPreviousQuarters[0] : Null;
                /*SFSE-13440 : Ends here*/
                for(String rowQuarter : listPreviousQuarters){
                    /*SFSE-13440 : Modified below line using ternary operator to avoid Deeply Nested IF Statements*/
                    /*if(rowQuarter != listPreviousQuarters[0])
                        strListQuarter += '\',\''+ rowQuarter;*/
                   strListQuarter +=  (rowQuarter != listPreviousQuarters[0]) ? '\',\''+ rowQuarter :  Null;
                    /*SFSE-13440 : Ends here*/
                }
                rowSipDataModel.strListQtr = strListQuarter;
            }
        }
        return rowSipDataModel;
    }
    @AuraEnabled
    public static SaveResultWrapper updateSipDetails(String listEaseAdvancementDetails, String listEfficiencySuperDetails, String listExpertiseAmbitionDetails){
        String returnMessage = '';
        SaveResultWrapper wSaveResult = new SaveResultWrapper();
        List<SIP__c> objList = new List<SIP__c>();
        if(String.isNotBlank(listEaseAdvancementDetails))
            objList.addAll(parseSipRecords(listEaseAdvancementDetails));
        if(String.isNotBlank(listEfficiencySuperDetails))
            objList.addAll(parseSipRecords(listEfficiencySuperDetails));
        if(String.isNotBlank(listExpertiseAmbitionDetails))
            objList.addAll(parseSipRecords(listExpertiseAmbitionDetails));
        if(objList.size() > 0){
      Savepoint sp = Database.setSavepoint();
            List<Database.SaveResult> lstSipUpdateResult= Database.Update(objList, false);
            for(Database.SaveResult sr : lstSipUpdateResult) {
                if(!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        wSaveResult.isSaveSuccess = false;
                        wSaveResult.strMessage = err.getMessage();
                       // Database.rollback(sp);//SFSE-13440 : Commented to Avoid operations in loops that may hit governor limits
                    }
                }
            }
            //SFSE-13440 
            if(!wSaveResult.isSaveSuccess){
                Database.rollback(sp);
            }
        }
        return wSaveResult;
    }
    private static List<SIP__c> parseSipRecords(String strToParse){
        List<SIP__c> objList = new List<SIP__c>();
        JSONParser parser = JSON.createParser(strToParse);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {                        
                        SIP__c objVal = new SIP__c();
                        SIP__c temp = (SIP__c)parser.readValueAs(SIP__c.class);
                        if(temp.Id != null){
                            objVal.Id   = temp.Id;
                            objVal.Acquisition_Target__c = temp.Acquisition_Target__c;
                            objVal.E2E_Volume_Target_FFE__c = temp.E2E_Volume_Target_FFE__c;
                            objVal.Volume_Target__c = temp.Volume_Target__c;
                            objVal.Revenue_Growth_VAS_Target__c = temp.Revenue_Growth_VAS_Target__c;
                            objVal.Ocean_Revenue_Target_USD__c = temp.Ocean_Revenue_Target_USD__c;
              objVal.Maersk_Spot_Volume_Target_FFE__c = temp.Maersk_Spot_Volume_Target_FFE__c;
                            objList.add(objVal);
                        }
                        parser.skipChildren();
                    }
                }
            }
        }
        return objList;
    }
    public class SaveResultWrapper{
        @AuraEnabled public Boolean isSaveSuccess;
        @AuraEnabled public String strMessage;
        
        public SaveResultWrapper(){
            isSaveSuccess = true;
            strMessage = 'Records saved successfully';
        }
    }
    public class SipDataModel{
        @AuraEnabled public SIP__c rowSIP {get; set;}
        @AuraEnabled public SIP__c rowSIPExp;
        @AuraEnabled public String strEaseAdvancementDetails;
        @AuraEnabled public String strEfficienySuperSaverDetails;
        @AuraEnabled public String strExpertiseAmbitionDetails;
        @AuraEnabled public Decimal intAcquisitionTarget;
        @AuraEnabled public Decimal intE2EVolumeTarget;
        @AuraEnabled public Decimal intVolumeTarget;
        @AuraEnabled public Decimal intRevenueGrowthTarget;
        @AuraEnabled public Decimal intVolumeExpTarget;
        @AuraEnabled public Decimal intRevenueGrowthExpTarget;
		@AuraEnabled public Decimal intLandisdeVPTarget;
        @AuraEnabled public Decimal intLandisdeVPEffTarget;
        @AuraEnabled public Decimal intRevenueTarget;
        @AuraEnabled public String strEaseAdv;
        @AuraEnabled public String strEfficiencySup;
        @AuraEnabled public String strExpertiseAmb;
        @AuraEnabled public Boolean showNoRecords;
        @AuraEnabled public String strListQtr;
    @AuraEnabled public Decimal intMrskSpotVolTrgt;
        
        SipDataModel(SIP__c recSip){
            showNoRecords = false;
            rowSIP = new SIP__c();
            rowSIPExp = new SIP__c();
            rowSIP = recSip;
            rowSIPExp = recSip;
            strEaseAdvancementDetails = '';
            strEfficienySuperSaverDetails = '';
            strExpertiseAmbitionDetails = '';
            strListQtr = '';
            intAcquisitionTarget = 0;
            intE2EVolumeTarget = 0;
            intVolumeTarget = 0;
            intRevenueGrowthTarget = 0;
            intVolumeExpTarget = 0;
            intRevenueGrowthExpTarget = 0;
            intRevenueTarget = 0;
            intMrskSpotVolTrgt = 0;
			intLandisdeVPTarget = 0;
            intLandisdeVPEffTarget =0;
	  
        }
    }
}