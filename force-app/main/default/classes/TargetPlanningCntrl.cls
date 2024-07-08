/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		19-Sept-2023	Vazid					This is an apex class for the target planning (customTargetPlanning) lwc component.	
* 2.0		18-Oct-2023	    Seba					Modified for SIPEligible value change in LWC
* 3.0		18-Oct-2023	    Vazid					Added getCountOfTargetItems method to get the total count of target items for associated target. 
* 4.0       20-Oct-2023     Seba                    Modified the getItemMeasureRecords parameter type of sipEligible from Booelan to String (SFSE-13044)
* 5.0		07-Nov-2023		Aditi					Modified getTargetItemRecords method to accomodate Target_Customer_Portfolio fields for filter
* 6.0       24-Nov-2023     Aditi                   Modified getTargetItemRecords method to fetch only Target Items whose Target Measure's Target Customer Portfolio records have current user as the Manager
* 7.0       20-Dec-2023     Aditi                   Optimized code to deal with 50001 exception while querying on Target_Customer_Portfolio__c
* 8.0       29-jan-2024     Bharti                  Added condition to show Non sip eligible target items records on UI 
* 9.0       06-Feb-2024     Aditi                   Bug fix for SFSE-14113
* 10.0      09-Feb-2024     Aditi                   Modified code to show onlt TargetItems with Active Target_Customer_Portfolio__c records if any filter from Target_Customer_Portfolio__c object is applied
*/
public with sharing class TargetPlanningCntrl {
    
    /*SFSE-13025 : STARTS HERE*/
    @AuraEnabled
    public static Integer getCountOfTargetItems(string targetRecId, String whereQuery, string sipEligible, String targetCusPortQuery)
    {
        string strQuery = 'Select Count(Id) total from Target_Item__c where Target__c =:targetRecId';
        
        String queryTCP = 'SELECT Assigned_Target__c, End_Date__c, Effective_End_Date__c FROM Target_Customer_Portfolio__c WHERE ';  //Query string to use if filters from Target Customer Portfolio object are applied

        List<Target_Item__c> targetList = new List<Target_Item__c>();
        List<Target_Customer_Portfolio__c> lstTCPs = new List<Target_Customer_Portfolio__c>();
        Set<Id> setTargetMeasureIds = new Set<Id>();
        
        
        String currentUser = UserInfo.getUserId();
        String approvalMatrixStage = TargetSettingConstants.APPROVAL_STAGE_3; 
        
        
        Boolean hasPermission = FeatureManagement.checkPermission(TargetSettingConstants.LEVEL1_APPROVER_PERMISSION_SET); //Check if the user has Sales Target User Permission Set
        Boolean tcpFilter = false;          //Boolean to be set to true if filters from Target Customer Portfolio object are applied
        Boolean isLevel1AppManager = false;

        //Check if user is configured as 'Level 1 approver - Area Head of Sales Channel Verticalized' in the Approval Matrix for the current Target record
        if(hasPermission || Test.isRunningTest()){
            List<Target_Reviewer__c> lstApprovalUser = [SELECT Id, Target_Approval_Matrix__c FROM Target_Reviewer__c WHERE Related_User__c =: currentUser AND Target_Approval_Matrix__r.Target_Stage__c =: approvalMatrixStage AND Target_Approval_Matrix__r.Target__c =: targetRecId];
            if(!lstApprovalUser.isEmpty() || Test.isRunningTest()){  
                isLevel1AppManager = true;
                tcpFilter = true;           
                queryTCP += 'Assigned_Sales_Rep__r.Manager.Id =: currentUser ';
            }
        }
        
        if (String.isNotEmpty(whereQuery) ){
                strQuery += whereQuery ;
        }

        if(String.isNotEmpty(sipEligible)){
            if(sipEligible == 'Yes'){//SFSE-13019
                strQuery += ' AND Count_of_SIP_Eligibles__c > 0' ;
            }else if(sipEligible == 'No'){//SFSE-13019
                strQuery += 'AND  Count_of_SIP_Non_Eligible__c > 0' ;
            }
        }

        
        if(String.isNotBlank(targetCusPortQuery) && String.isNotEmpty(targetCusPortQuery)){            
            tcpFilter = true;
            if(isLevel1AppManager){
                queryTCP += 'AND ';
            }
            queryTCP += targetCusPortQuery.replaceFirst(' AND ', '');            
        }

        if(tcpFilter){
            System.debug('queryTCP: '+queryTCP);
            lstTCPs = Database.query(queryTCP);
            if(lstTCPs != null){
                for(Target_Customer_Portfolio__c rec : lstTCPs){
                    if((rec.Effective_End_Date__c == null && rec.End_Date__c == null) || 
                    ((rec.End_Date__c ==  null && rec.Effective_End_Date__c >= System.today()) || (rec.Effective_End_Date__c == null && rec.End_Date__c >= System.today()))){
                        setTargetMeasureIds.add(rec.Assigned_Target__c);
                    }
                }
            }                  
            strQuery += ' AND Id IN (SELECT Target_Item__c FROM Target_Measure__c WHERE ID IN: setTargetMeasureIds)';
        }

        List<AggregateResult> agg = database.query(strQuery);
        
        System.debug(' Count:::: ' + agg[0].get('total')) ;
        Integer count = (Integer)agg[0].get('total');
        return count;
    }
    /*SFSE-13025 : ENDS HERE*/
    
    //Get the target Item records based on the targetId
    @AuraEnabled
    public static List<Target_Item__c> getTargetItemRecords(string targetRecId, String targetCusPortQuery, String whereQuery, Integer offset, integer noOfRows, String strOrderBy, String strOrderDirection, string sipEligible)
    {
        String strQuery = 'Select Id, Name,Target__c, Account__c, Brand__c, Account_Represents_Concern__c, Account_Name__c, Account_Customer_Code__c, Represent_Concern_Account__c, Sales_Channel__c, Attractiveness__c, Vertical__c,'+
            +'Account_Concern_Code__c, Controlling_Country__c, Executing_Area__c,Sales_Target_Item_Group__c,Sales_Target_Item_Group__r.Name,'+
            +'Executing_Country__c, Executing_Region__c, Product_Family__c, Count_of_SIP_Non_Eligible__c from Target_Item__c where Target__c =:targetRecId';

        String queryTCP = 'SELECT Assigned_Target__c, End_Date__c, Effective_End_Date__c FROM Target_Customer_Portfolio__c WHERE ';  //Query string to use if filters from Target Customer Portfolio object are applied

        List<Target_Item__c> targetList = new List<Target_Item__c>();
        List<Target_Customer_Portfolio__c> lstTCPs = new List<Target_Customer_Portfolio__c>();
        Set<Id> setTargetMeasureIds = new Set<Id>();
        
        
        String currentUser = UserInfo.getUserId();
        String approvalMatrixStage = TargetSettingConstants.APPROVAL_STAGE_3; 
        
        
        Boolean hasPermission = FeatureManagement.checkPermission(TargetSettingConstants.LEVEL1_APPROVER_PERMISSION_SET); //Check if the user has Sales Target User Permission Set
        Boolean tcpFilter = false;          //Boolean to be set to true if filters from Target Customer Portfolio object are applied
        Boolean isLevel1AppManager = false;
        Boolean getTargetItemsByTCPcalled = false;

        //Check if user is configured as 'Level 1 approver - Area Head of Sales Channel Verticalized' in the Approval Matrix for the current Target record
        if(hasPermission || Test.isRunningTest()){
            List<Target_Reviewer__c> lstApprovalUser = [SELECT Id, Target_Approval_Matrix__c FROM Target_Reviewer__c WHERE Related_User__c =: currentUser AND Target_Approval_Matrix__r.Target_Stage__c =: approvalMatrixStage AND Target_Approval_Matrix__r.Target__c =: targetRecId];
            if(!lstApprovalUser.isEmpty() || Test.isRunningTest()){  
                isLevel1AppManager = true;
                tcpFilter = true;           
                queryTCP += 'Assigned_Sales_Rep__r.Manager.Id =: currentUser ';
            }
        }

        if(String.isNotBlank(targetCusPortQuery) && String.isNotEmpty(targetCusPortQuery)){   
            tcpFilter = true;
            if(isLevel1AppManager){
                queryTCP += 'AND ';
            }
            queryTCP += targetCusPortQuery.replaceFirst(' AND ', '');                       
        }    
    
        if (String.isNotEmpty(whereQuery) ){
                strQuery += whereQuery ;
        }

        if(String.isNotEmpty(sipEligible)){
            if(sipEligible == 'Yes'){//SFSE-13019
                strQuery += ' AND Count_of_SIP_Eligibles__c > 0' ;
            }else if(sipEligible == 'No'){//SFSE-13019
                strQuery += ' AND Count_of_SIP_Non_Eligible__c > 0';
            }
        }
        
        if(tcpFilter){
            System.debug('queryTCP: '+queryTCP);
            lstTCPs = Database.query(queryTCP);
            if(lstTCPs != null){
                for(Target_Customer_Portfolio__c rec : lstTCPs){
                    if((rec.Effective_End_Date__c == null && rec.End_Date__c == null) || 
                    ((rec.End_Date__c ==  null && rec.Effective_End_Date__c >= System.today()) || (rec.Effective_End_Date__c == null && rec.End_Date__c >= System.today()))){
                        setTargetMeasureIds.add(rec.Assigned_Target__c);
                    }
                }
            }
            strQuery += ' AND Id IN (SELECT Target_Item__c FROM Target_Measure__c WHERE ID IN: setTargetMeasureIds)';
        }
        
        strQuery += ' Order By ' + strOrderBy + ' ' + strOrderDirection;
        if(noOfRows > 0) {
        // to support lazy loading in LWC, fetch a limited no of records at a time. Use offset to determine which rows to select
        strQuery = strQuery + ' LIMIT ' + noOfRows + ' OFFSET  ' + offset ;
        }
        System.debug('Final query in TargetPlanning Apex'+strQuery);
        
        targetList = database.query(strQuery); 
        
        return targetList;
    }

    //Get the target measure records for the selected target Item
    @AuraEnabled
    public static List<Target_Measure__c> getItemMeasureRecordsForTargetPlanning(List<Id> targetItemRecIds, string strMeasureType, string strMeasureDimension, String partyType, String sipeligible)
    {
        system.debug('targetItemRecIds@@'+targetItemRecIds);
        system.debug('strMeasureType@@'+strMeasureType);
        system.debug('strMeasureDimension@@'+strMeasureDimension);
        system.debug('partyType@@'+partyType);
        system.debug('sipeligible@@'+sipeligible);
         
        Boolean sipEligibleBool = false;
        //SFSE-13044
        if(String.isNotEmpty(sipeligible)){
            if(sipeligible == 'Yes'){//SFSE-13019
                sipEligibleBool = true;
            }else if(sipEligible == 'No'){//SFSE-13019
                sipEligibleBool = false;
            }
        }

        string strQuery =   'Select Id, Target_Item__c, Name, Measure_Type__c, Measure_Dimension__c, Jan__c,'+
            +'Feb__c, Mar__c, Apr__c, May__c,  Jun__c, Jul__c, Aug__c, Sep__c,'+ 
            +'Oct__c, Nov__c, Dec__c, Credit_Eligible__c, Party_Type__c,'+ 
            +'Q1_Total__c, Q2_Total__c, Q3_Total__c, Q4_Total__c, Total__c'+
            +' from Target_Measure__c where Target_Item__c IN : targetItemRecIds';
        
        if (String.isNotEmpty(strMeasureType) ){
            strQuery += ' AND Measure_Type__c =:strMeasureType';
        }
        if (String.isNotEmpty(strMeasureDimension) ){
            strQuery += ' AND Measure_Dimension__c =:strMeasureDimension';
        }
        
        if (String.isNotEmpty(partyType)){
            strQuery += ' AND Party_Type__c =:partyType';
        }  
        if (String.isNotBlank(sipeligible)){ //SFSE-10344  
            strQuery += ' AND Credit_Eligible__c =:sipEligibleBool';
        }

        strQuery += ' Order By Measure_Dimension__c DESC';
        
        system.debug('strQuery@@'+strQuery);
        List<Target_Measure__c> targetMeasureList = database.query(strQuery);
        system.debug('targetMeasureList@@'+targetMeasureList);
        return targetMeasureList;
    }
    
        //Get the target measure records for the selected target Item
    @AuraEnabled
    public static Map<Id, Target_Measure__c> getItemMeasureRecords(String targetId,Map<String, String> datamap,  String targetCusPortQuery , string strMeasureType, string strMeasureDimension, List<String> partyType, String sipeligible, String whereQuery)
    {
        system.debug('targetRecIds@@ '+targetId);
        system.debug('strMeasureType@@'+strMeasureType);
        system.debug('strMeasureDimension@@'+strMeasureDimension);
        system.debug('partyType@@'+partyType);
        system.debug('sipeligible@@'+sipeligible);
        system.debug('datamap@@ '+datamap);
        Map<Id, Target_Measure__c> previousActualMap = new Map<Id, Target_Measure__c>();
        List<Target_Item__c> tIMs = new List<Target_Item__c>();
		tIMs = getTargetItemRecords(targetId, targetCusPortQuery, whereQuery, 0, 0, 'Name', 'ASC', sipeligible);
        system.debug('tIMs@@ '+ tIMs.size());
		Set<Id> tids = new Set<Id>();
        for(Target_Item__c t : tIMs) {
            tids.add(t.Id);
        }
        Boolean sipEligibleBool = false;
        if(String.isNotEmpty(sipeligible)){
            if(sipeligible == 'Yes'){
                sipEligibleBool = true;
            }else if(sipEligible == 'No'){
                sipEligibleBool = false;
            }
        }
        string strQuery =   'Select Id, Target_Item__r.Target__c, Target_Item__c, Name, Measure_Type__c, Measure_Dimension__c, Jan__c,'+
            +'Feb__c, Mar__c, Apr__c, May__c,  Jun__c, Jul__c, Aug__c, Sep__c,'+ 
            +'Oct__c, Nov__c, Dec__c, Credit_Eligible__c, Party_Type__c,'+ 
            +'Q1_Total__c, Q2_Total__c, Q3_Total__c, Q4_Total__c, Total__c'+
            +' from Target_Measure__c where Target_Item__c IN : tids';
        
        if (String.isNotEmpty(strMeasureType) ){
            strQuery += ' AND Measure_Type__c =:strMeasureType';
        }
        if (String.isNotEmpty(strMeasureDimension) ){
            strQuery += ' AND Measure_Dimension__c =:strMeasureDimension';
        }
        
        if (partyType !=null){
            strQuery += ' AND Party_Type__c IN :partyType';
        }  
        if (String.isNotBlank(sipeligible)){
            strQuery += ' AND Credit_Eligible__c =:sipEligibleBool';
        }
        
        strQuery += ' Order By Measure_Dimension__c DESC';
        
        system.debug('strQuery@@'+strQuery);
        List<Target_Measure__c> targetMeasureList = database.query(strQuery);
        system.debug('targetMeasureList@@'+targetMeasureList);
        for(Target_Measure__c tme : targetMeasureList) {
            previousActualMap.put(tme.Target_Item__c, tme);
        }
        for(Id tmids : previousActualMap.keySet()) {
            previousActualMap.get(tmids).Jan__c = previousActualMap.get(tmids).Jan__c + (math.abs(previousActualMap.get(tmids).Jan__c) + decimal.valueof(datamap.get('Jan__c'))/100);
            previousActualMap.get(tmids).Feb__c = previousActualMap.get(tmids).Feb__c + (math.abs(previousActualMap.get(tmids).Feb__c) + decimal.valueof(datamap.get('Feb__c'))/100);
            previousActualMap.get(tmids).Mar__c = previousActualMap.get(tmids).Mar__c + (math.abs(previousActualMap.get(tmids).Mar__c) + decimal.valueof(datamap.get('Mar__c'))/100);
            previousActualMap.get(tmids).Apr__c = previousActualMap.get(tmids).Apr__c + (math.abs(previousActualMap.get(tmids).Apr__c) + decimal.valueof(datamap.get('Apr__c'))/100);
            previousActualMap.get(tmids).May__c = previousActualMap.get(tmids).May__c + (math.abs(previousActualMap.get(tmids).May__c) + decimal.valueof(datamap.get('May__c'))/100);
            previousActualMap.get(tmids).Jun__c = previousActualMap.get(tmids).Jun__c + (math.abs(previousActualMap.get(tmids).Jun__c) + decimal.valueof(datamap.get('Jun__c'))/100);
            previousActualMap.get(tmids).Jul__c = previousActualMap.get(tmids).Jul__c + (math.abs(previousActualMap.get(tmids).Jul__c) + decimal.valueof(datamap.get('Jul__c'))/100);
            previousActualMap.get(tmids).Aug__c = previousActualMap.get(tmids).Aug__c + (math.abs(previousActualMap.get(tmids).Aug__c) + decimal.valueof(datamap.get('Aug__c'))/100);
            previousActualMap.get(tmids).Sep__c = previousActualMap.get(tmids).Sep__c + (math.abs(previousActualMap.get(tmids).Sep__c) + decimal.valueof(datamap.get('Sep__c'))/100);
            previousActualMap.get(tmids).Oct__c = previousActualMap.get(tmids).Oct__c + (math.abs(previousActualMap.get(tmids).Oct__c) + decimal.valueof(datamap.get('Oct__c'))/100);
            previousActualMap.get(tmids).Nov__c = previousActualMap.get(tmids).Nov__c + (math.abs(previousActualMap.get(tmids).Nov__c) + decimal.valueof(datamap.get('Nov__c'))/100);
            previousActualMap.get(tmids).Dec__c = previousActualMap.get(tmids).Dec__c + (math.abs(previousActualMap.get(tmids).Dec__c) + decimal.valueof(datamap.get('Dec__c'))/100);
        }
        system.debug('@@@@ ' + previousActualMap);
        return previousActualMap;
    }
    
    @AuraEnabled
    public static String fireTargetMeasureBatch (String wherequery, Id targetIds, string sipEligibleVal, string strMeasureType, Map<String, String> mapOfMonthTovalue, List<String> partytype, Map<String, String> previousActualMap, String growthtypeVal, String targetCusPortQuery) {       
        system.debug('@@@@' + previousActualMap);
        system.debug('@@@@' + partytype);
        system.debug('@@@@' + sipEligibleVal);
        Boolean sipEligibleBool = false;
        //SFSE-13044
        if(String.isNotEmpty(sipEligibleVal)){
            if(sipEligibleVal == 'Yes'){//SFSE-13019
                sipEligibleBool = true;
            }else if(sipEligibleVal == 'No'){//SFSE-13019
                sipEligibleBool = false;
            }
        }
        
        try {
            BatchUpdateTargetItemTargetMeasure btit = new BatchUpdateTargetItemTargetMeasure(wherequery, targetIds,sipEligibleVal, strMeasureType, mapOfMonthTovalue, partytype, previousActualMap,growthtypeVal, targetCusPortQuery);
            Id batchJobId = Database.executeBatch(btit, 20);
            Cache.Org.put('batchidvalue', batchJobId);
            Cache.Org.put('batchloginuser', UserInfo.getUserId());
            return batchJobId;
            //return null;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     
    //update the target measure record
    @AuraEnabled
    public static List<AsyncApexJob> getBatchIdStatus() {
        String cc = (String)Cache.Org.get('batchidvalue');   
        String uid = (String)Cache.Org.get('batchloginuser');   
        system.debug('@@@@' + cc);
        system.debug('@@@@' + uid);
        system.debug('@@@@' +  UserInfo.getUserId());
        Boolean batchuId = false;
        batchuId  = UserInfo.getUserId() == uid ? true : false;
        List<AsyncApexJob> jobInfo;
        if(batchuId) {
            jobInfo = [SELECT Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id =: String.valueof(cc)
                       /*AND CreatedById =: uid*/];
        }
        return jobInfo;
    }
	//update the target measure record
    @AuraEnabled
    public static string updateMeasureRecords(Target_Measure__c targetMeasureRec)
    {
        system.debug('targetMeasureRec@@@'+targetMeasureRec);

        string strMsg = 'success';
        try {


            if(targetMeasureRec != null)
                update targetMeasureRec;

        } catch (DMLException  e) {

            throw new AuraHandledException(e.getDmlMessage(0));
        }
        return strMsg;
    }
}