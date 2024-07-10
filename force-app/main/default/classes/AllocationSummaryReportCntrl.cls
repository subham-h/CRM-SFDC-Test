/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		03-Oct-2023		Vazid					This is an apex class for the target Allocation summary (customBudgetSummaryReport) lwc component.	
* 1.2		18-Oct-2023		Seba					Modified for SFSE-13019
* 1.3		24-Oct-2023		Vazid					Modified report run from synchronous  to asynchronousi.c
* 1.4       24-Nov-2023     Aditi                   Modified for SFSE-13332 to add filter Assigned_Sales_Rep__r.Manager = logged in user
* 1.5		28-Nov-2023		Vazid					SFSE-13481 : Added one new variable in matrixReportResponse wrapper
* 1.6		22-Jan-2024		Seba					SFSE-13698 : Modified code for Sales Rep and Manager filters, and row Total
* 1.7		27-Feb-2024		Seba					SFSE-13698 : Modified code to fix test class coverage
*/
public class AllocationSummaryReportCntrl {
    
    @AuraEnabled
    public static string getReportMetadata(string groupByValue, string filterValue, string recId, string partyTypeValue, string sipEligibleVal, string attractiveness, string brand, string productFamily, string controllingCountry, String controllingArea, String controllingRegion, string executingCountry, string executingArea, string executingRegion, string salesChannel, string vertical, string customerCode, string concernCode, String targetItemType, Id salesRepId, Id salesManagerId){
        
        string reportId = system.Label.targetAllocationSumReportLabel;
        Target__c targetRecord = [Select Id, Name from Target__c where Id=:recId];
        
        Reports.ReportMetadata ReportData = new Reports.ReportMetadata();
        
        List<Reports.ReportFilter> reportFilterList = new List<Reports.ReportFilter>(); 
        //Used to set AND/OR logical condition in Report
        String reportBooleanFilter = '';//SFSE-13698
        Integer reportBool = 0;//SFSE-13698
        Boolean isCurrentUserL1Approver = FALSE;//SFSE-13698
        
        //SFSE-13332-start
        String currentUser = UserInfo.getUserId();
        String approvalStage = TargetSettingConstants.APPROVAL_STAGE_3;
        Boolean hasPermission = FeatureManagement.checkPermission(TargetSettingConstants.LEVEL1_APPROVER_PERMISSION_SET);
         
        if(hasPermission){
            List<Target_Reviewer__c> lstApprovalUser = [SELECT Id, Target_Approval_Matrix__c FROM Target_Reviewer__c WHERE Related_User__c =: currentUser AND Target_Approval_Matrix__r.Target_Stage__c =: approvalStage AND Target_Approval_Matrix__r.Target__c =: recId];
            if(!lstApprovalUser.isEmpty()){ 
                reportBool++; //SFSE-13698
                //Used to apply Effective end date filter for L1 approver
                isCurrentUserL1Approver = TRUE;//SFSE-13698
                reportBooleanFilter = String.valueOf(reportBool);//SFSE-13698
                Reports.ReportFilter filterSalesRepManager = new Reports.ReportFilter('Target_Customer_Portfolio__c.Assigned_Sales_Rep__c.Manager.Id','equals',currentUser);
                reportFilterList.add(filterSalesRepManager);
            }
        }  
        //SFSE-13332-end
        
        Reports.ReportFilter filterName = new Reports.ReportFilter('Target_Item__c.Target__c.Name','equals',targetRecord.Name); 
        reportBool++;//SFSE-13698
        reportBooleanFilter = reportBooleanFilter != '' ? reportBooleanFilter + ' AND ' + String.valueOf(reportBool) : String.valueOf(reportBool);//SFSE-13698
        reportFilterList.add(filterName);
        
        if(string.isNotEmpty(filterValue)){ 
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter filterMeasureType = new Reports.ReportFilter('Target_Measure__c.Measure_Type__c','equals',filterValue);
            reportFilterList.add(filterMeasureType);  
        }
        
        if(string.isNotEmpty(partyTypeValue)){ 
            reportBool++;  reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter filterPartyType = new Reports.ReportFilter('Target_Measure__c.Party_Type__c','equals',partyTypeValue);
            reportFilterList.add(filterPartyType); 
        }
        
        if(string.isNotEmpty(sipEligibleVal)){
            reportBool++;  reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698 
            Reports.ReportFilter filterCreditEligible = new Reports.ReportFilter('Target_Measure__c.Credit_Eligible__c','equals',sipEligibleVal);
            reportFilterList.add(filterCreditEligible); 
        }
        
        if(string.isNotEmpty(attractiveness)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool); //SFSE-13698
            Reports.ReportFilter attractivenessType  = new Reports.ReportFilter('Target_Item__c.Attractiveness__c','contains',attractiveness);
            reportFilterList.add(attractivenessType); 
        }
        
        if(string.isNotEmpty(brand)){
            reportBool++;  reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698 
            Reports.ReportFilter brandType  = new Reports.ReportFilter('Target_Item__c.Brand__c','contains',brand);
            reportFilterList.add(brandType); 
        }
        
        if(string.isNotEmpty(customerCode)){
            reportBool++;  reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool); //SFSE-13698
            Reports.ReportFilter customerCodeType  = new Reports.ReportFilter('Target_Item__c.Account_Customer_Code__c','contains',customerCode);
            reportFilterList.add(customerCodeType); 
        }
        
        if(string.isNotEmpty(concernCode)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter concernCodeType  = new Reports.ReportFilter('Target_Item__c.Account_Concern_Code__c','contains',concernCode);
            reportFilterList.add(concernCodeType); 
        }
        
        if(string.isNotEmpty(productFamily)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter productFamilyType  = new Reports.ReportFilter('Target_Item__c.Product_Family__c','contains',productFamily);
            reportFilterList.add(productFamilyType); 
        }
        
        if(string.isNotEmpty(controllingCountry)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter controllingCountryType  = new Reports.ReportFilter('Target_Item__c.Controlling_Country__c','contains',controllingCountry);
            reportFilterList.add(controllingCountryType); 
        }
        
        if(string.isNotEmpty(controllingArea)){//SFSE-13019
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter controllingAreaType  = new Reports.ReportFilter('Target_Item__c.Controlling_Area__c.Name','contains',controllingArea);
            reportFilterList.add(controllingAreaType); 
        }
        
        if(string.isNotEmpty(controllingRegion)){//SFSE-13019
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter controllingRegionType  = new Reports.ReportFilter('Target_Item__c.Controlling_Region__c','contains',controllingRegion);
            reportFilterList.add(controllingRegionType);  
        }
        if(string.isNotEmpty(executingCountry)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter executingCountryType  = new Reports.ReportFilter('Target_Item__c.Executing_Country__c','contains',executingCountry);
            reportFilterList.add(executingCountryType);  
        }
        if(string.isNotEmpty(executingArea)){
            reportBool++;   reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter executingAreaType  = new Reports.ReportFilter('Target_Item__c.Executing_Area__c','contains',executingArea);
            reportFilterList.add(executingAreaType);  
        }
        if(string.isNotEmpty(executingRegion)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter executingRegionType  = new Reports.ReportFilter('Target_Item__c.Executing_Region__c','contains',executingRegion);
            reportFilterList.add(executingRegionType);  
        }
        
        if(string.isNotEmpty(salesChannel)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter salesChannelType  = new Reports.ReportFilter('Target_Item__c.Sales_Channel__c','contains',salesChannel);
            reportFilterList.add(salesChannelType); 
        }
        
        if(string.isNotEmpty(vertical)){
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter verticalType  = new Reports.ReportFilter('Target_Item__c.Vertical__c','contains',vertical);
            reportFilterList.add(verticalType); 
        }   
        
        if(string.isNotEmpty(targetItemType)){//SFSE-13019
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter targetItemTypeValue  = new Reports.ReportFilter('Target_Item__c.Target_Item_Type__c','contains',targetItemType);
            reportFilterList.add(targetItemTypeValue); 
        } 
        
        /*SFSE-13698*/
        if(string.isNotEmpty(salesRepId)){ //SFSE-13698  
            reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter salesRepIdValue = new Reports.ReportFilter('Target_Customer_Portfolio__c.Assigned_Sales_Rep__c.Id','equals',salesRepId);
            reportFilterList.add(salesRepIdValue); 
        }
        if(string.isNotEmpty(salesManagerId)){//SFSE-13698 
            reportBool++;  reportBooleanFilter = reportBooleanFilter + ' AND ' + String.valueOf(reportBool);//SFSE-13698
            Reports.ReportFilter salesManagerIdValue = new Reports.ReportFilter('Target_Customer_Portfolio__c.Assigned_Sales_Rep__c.Manager.Id','equals',salesManagerId);
            reportFilterList.add(salesManagerIdValue);  
        }
        if(String.isNotEmpty(salesRepId) || String.isNotEmpty(salesManagerId) || isCurrentUserL1Approver){  
           reportBool++; reportBooleanFilter = reportBooleanFilter + ' AND ' + '(' + String.valueOf(reportBool);//SFSE-13698
           Reports.ReportFilter endDateCondition = new Reports.ReportFilter('Target_Customer_Portfolio__c.Effective_End_Date__c', 'equals' , NULL);
           reportFilterList.add(endDateCondition);
            
           reportBool++; reportBooleanFilter = reportBooleanFilter + ' OR '+ String.valueOf(reportBool) + ')';//SFSE-13698
           Reports.ReportFilter endDateCondition2 = new Reports.ReportFilter('Target_Customer_Portfolio__c.Effective_End_Date__c', 'greaterOrEqual' , String.valueOf(Date.today().format())); 
           reportFilterList.add(endDateCondition2);
        } 
        ReportData.setReportBooleanFilter(reportBooleanFilter); //SFSE-13698
        ReportData.setShowGrandTotal(TRUE);//SFSE-13698
        /*SFSE-13698*/
        
        ReportData.setReportFilters(reportFilterList); 
         
        //Set the aggregate fields in report
        string aggColumns = 's!Target_Measure__c.Jan__c,s!Target_Measure__c.Feb__c,s!Target_Measure__c.Mar__c,s!Target_Measure__c.Apr__c,'+
            +'s!Target_Measure__c.May__c,s!Target_Measure__c.Jun__c,s!Target_Measure__c.Jul__c,s!Target_Measure__c.Aug__c,'+
            +'s!Target_Measure__c.Sep__c,s!Target_Measure__c.Oct__c,s!Target_Measure__c.Nov__c,s!Target_Measure__c.Dec__c,s!Target_Measure__c.Q1_Total__c,s!Target_Measure__c.Q2_Total__c,s!Target_Measure__c.Q3_Total__c,s!Target_Measure__c.Q4_Total__c,s!Target_Measure__c.Total__c,RowCount';
        List<String> stragg=new List<String>();
        stragg = aggColumns.split(',');
        ReportData.setAggregates(stragg);
        
        //set fields for grouping down
        List<Reports.GroupingInfo> listgrp=new List<Reports.GroupingInfo>();
        string str = groupByValue;//'Target_Item__c.'+groupByValue; //SFSE-13022
        if(str != null){
            Reports.GroupingInfo groupset=new Reports.GroupingInfo();
            groupset.setName(str);
            listgrp.add(groupset);
            
        } 
        //set fields for grouping columns
        List<Reports.GroupingInfo> listgrpacross=new List<Reports.GroupingInfo>();
        string str2 = 'Target_Measure__c.Measure_Dimension__c';
        if(str2 != null){
            Reports.GroupingInfo groupset3=new Reports.GroupingInfo();
            groupset3.setName(str2);
            listgrpacross.add(groupset3);
        }
        ReportData.setGroupingsAcross(listgrpacross);
        
        //Columns to Pass
        List<string> columnsToSet=new List<String>();
        string columpass = 'Target_Measure__c.Jan__c,Target_Measure__c.Feb__c,Target_Measure__c.Mar__c,Target_Measure__c.Apr__c,Target_Measure__c.May__c,'+
            +'Target_Measure__c.Jun__c,Target_Measure__c.Jul__c,Target_Measure__c.Aug__c,'+
            +'Target_Measure__c.Sep__c,Target_Measure__c.Oct__c,Target_Measure__c.Nov__c,'+
            +'Target_Measure__c.Dec__c,Target_Measure__c.Q1_Total__c,Target_Measure__c.Q2_Total__c,Target_Measure__c.Q3_Total__c,Target_Measure__c.Q4_Total__c,Target_Measure__c.Total__c';
        
        columnsToSet = columpass.split(',');
        
        ReportData.setDetailColumns(columnsToSet);
        
        ReportData.setGroupingsDown(listgrp);
        
        ReportData.setShowGrandTotal(true);
        ReportData.setShowSubtotals(true);
        ReportData.setHasRecordCount(true);
        ReportData.setHasDetailRows(true); 
        //returning latest instance Id
        Reports.ReportInstance instance = Reports.ReportManager.runAsyncReport(reportId, ReportData, true); 
        string jsonStr = instance.getId();  
        return jsonStr; 
        
        
    }
    //Added below method by Vazid : To avoid 500001 row error
    @AuraEnabled
    public static matrixReportResponse getAsyncReportData(string instanceId){ 
        string reportId = system.Label.targetAllocationSumReportLabel;
        
        //get all the cached async ReportInstances performed against this report
        List<Reports.ReportInstance> repInstances = Reports.ReportManager.getReportInstances(reportId);
        
        //find the latest instance
        Reports.ReportInstance latestInstance;
        Reports.ReportResults results;
        for(Reports.ReportInstance ints : repInstances){
            //SFSE-13698 Removing condition !Test.isRunningtest()
            //if(ints.getId() == instanceId && !Test.isRunningtest()){
             if(ints.getId() == instanceId){   
                if(ints.getStatus() == 'Success')
                    latestInstance = ints;
                break;
            }
           
        }
        
        
        if(latestInstance != null || Test.isRunningtest()){
            //this is latest Result
            //SFSE-13698 Commenting Test.isRunningTest
            //if(!Test.isRunningtest()){
            	results = latestInstance.getReportResults();
            //}
            /*if(Test.isRunningtest()){ 
                results = reports.ReportManager.runReport(reportId, true); 
            }SFSE-13698*/
            
             
            string jsonStr = JSON.serialize(results); 
            matrixReportResponse mat = new matrixReportResponse();
            mat.instanceId = instanceId;//SFSE-13481
            List<fieldDef> reportFields = new List<fieldDef>();
            List<fieldDef> reportColumns = new List<fieldDef>(); 
            
            //get the metadata
            Reports.ReportMetadata reportMetadata = results.getReportMetadata();  
  
            //get a string array of the field names
            List<String> fieldNames = reportMetadata.getDetailColumns();		
            //get the extended metadata
            Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();
            
            //get the map of the grouping column names to their name and label
            Map<String, Reports.GroupingColumn> detailColumnMap = reportExtendedMetadata.getGroupingColumnInfo(); 
            //create the reportFields header row from the grouping fields
            //get the map of the column names to their name and label
            Map<String, Reports.DetailColumn> detailColumnMap2 = reportExtendedMetadata.getDetailColumnInfo();
            //first add the grouping down field info
            Reports.GroupingInfo groupingInfoDown = reportMetadata.getGroupingsDown()[0]; //only supports one grouping level
            Reports.GroupingColumn groupingColumnDown = detailColumnMap.get(groupingInfoDown.getName());
            
            //loop over the detailColumnMap and get the name, label, and data type
            for (String fieldName: fieldNames) {
                Reports.DetailColumn detailColumn = detailColumnMap2.get(fieldName);
                fieldDef fd = new fieldDef();
                if(detailColumn.getLabel() == 'Executing Country: Location Name'){
                    fd.fieldName = 'CountryName';
                }else if(detailColumn.getLabel()  == 'Quarter 1 Total'){
                    fd.fieldName = 'Quarter1Total';                            
                }else if(detailColumn.getLabel()  == 'Quarter 2 Total'){
                    fd.fieldName = 'Quarter2Total';  
                }else if(detailColumn.getLabel()  == 'Quarter 3 Total'){
                    fd.fieldName = 'Quarter3Total'; 
                }else if(detailColumn.getLabel()  == 'Quarter 4 Total'){
                    fd.fieldName = 'Quarter4Total'; 
                }else{
                    fd.fieldName = detailColumn.getLabel(); 
                }
                fd.fieldLabel = detailColumn.getLabel();
                fd.dataType = detailColumn.getDataType().name();
                reportColumns.add(fd);
            }
               
            //now add all the groupings across
            for (Reports.GroupingValue groupingValue: results.getGroupingsAcross().getGroupings()) { 
                fieldDef fd = new fieldDef();
                fd.fieldName = (String)groupingValue.getValue(); 
                fd.fieldLabel = groupingValue.getLabel();
                fd.dataType = 'DOUBLE_DATA';
                fd.key = Integer.valueof(groupingValue.getkey());
                reportFields.add(fd);			
            }
            
            //get the matrix grouping down dimension grouping values.  only going 1 level deep
            List<summaryReportGroup> groupListDown = new List<summaryReportGroup>();
            for (Reports.GroupingValue groupingValue: results.getGroupingsDown().getGroupings()) { 
                summaryReportGroup srg = new summaryReportGroup();
                srg.fieldValue = (String)groupingValue.getValue();
                srg.fieldLabel = groupingValue.getLabel();
                srg.groupKey = groupingValue.getKey(); 
                groupListDown.add(srg);
            }
              
            //get the matrix grouping across dimension grouping values.  only going 1 level deep
            List<summaryReportGroup> groupListAcross = new List<summaryReportGroup>();
            for (Reports.GroupingValue groupingValue: results.getGroupingsAcross().getGroupings()) { 
                summaryReportGroup srg = new summaryReportGroup(); 
                srg.fieldValue = (String)groupingValue.getValue();
                srg.fieldLabel = groupingValue.getLabel();
                srg.groupKey = groupingValue.getKey(); 
                groupListAcross.add(srg);
            }		
            List<MatrixReportGroup> groupList = new List<MatrixReportGroup>();
            
            //Used to check if the elements in groupListDown is completely looped
            Integer groupDownNum = 0; //SFSE-13698
            //now we need to do a nested loop of the groupings down and across to get all the data from the fact map
            for (summaryReportGroup down: groupListDown) {  
                
                groupDownNum = groupDownNum+1;//SFSE-13698 
                
                matrixReportGroup srg = new matrixReportGroup();
                srg.rowName = down.fieldLabel;
                
                List<List<fieldData>> fieldDataList = new List<List<fieldData>>();
                
                
                for (summaryReportGroup across: groupListAcross) { 
                    
                    List<fieldData> fieldDataRow = new List<fieldData>();
                     
                    //use our composite down!across key to get values from the fact map 
                    Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(down.groupKey+'!'+across.groupKey);	
                     
                    List<Reports.SummaryValue> reportAggregateList = factDetails.getAggregates();	 
                    
                    Integer cellCounter = 0;
                    
                    //loop over the cells in the row
                    for ( Reports.SummaryValue reportDataCell: reportAggregateList) {
                        fieldData fd = new fieldData();
                        fd.fieldValue = string.valueof(reportDataCell.getValue());
                        fd.fieldLabel = string.valueof(reportDataCell.getLabel());
                        fd.uniqueKey = down.fieldLabel+across.fieldLabel;
                        fd.isSubTotal = false;
                        fd.rowName = down.fieldLabel;
                        string columName;
                        if(across.fieldLabel == 'Previous Year Actuals'){
                            columName = 'PYActuals';
                        } else{
                            columName = across.fieldLabel;
                        }
                        fd.columnName = columName;
                        cellCounter++;
                        fieldDataRow.add(fd); 
                    }
                    fieldDataList.add(fieldDataRow); 
                }
                srg.fieldDataList = fieldDataList; 
                groupList.add(srg); 
                
                //SFSE-13698 If the groupListDown and groupListAcross is completely looped, add the row Total at the bottom
                if(groupDownNum == groupListDown.size() && reportMetadata.getShowGrandTotal() == TRUE){ 
                    List<List<fieldData>> fieldDataListTotal = new List<List<fieldData>>();
                    matrixReportGroup srgTotal = new matrixReportGroup();
                	srgTotal.rowName = 'TOTAL';
                    
                       for(summaryReportGroup across: groupListAcross) {  
                        	List<fieldData> fieldDataRowTotal = new List<fieldData>();
                        
                            //use composite T!across key to get Total values from the fact map 
                            Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!'+across.groupKey);	
                             
                        	List<Reports.SummaryValue> reportAggregateListTotal = factDetails.getAggregates();	 
                          
                        	//loop over the cells in the row
                            for ( Reports.SummaryValue reportDataCell: reportAggregateListTotal) {  
                                fieldData fd = new fieldData();
                                fd.fieldValue = string.valueof(reportDataCell.getValue());
                                fd.fieldLabel = string.valueof(reportDataCell.getLabel());
                                fd.uniqueKey = 'Total'+across.fieldLabel;
                                fd.isSubTotal = false;
                                fd.rowName = 'TOTAL';
                                string columName;
                                if(across.fieldLabel == 'Previous Year Actuals'){
                                    columName = 'PYActuals';
                                } else{
                                    columName = across.fieldLabel;
                                }
                                fd.columnName = columName; 
                                fieldDataRowTotal.add(fd); 
                            }
                            fieldDataListTotal.add(fieldDataRowTotal);  
                    }
                    srgTotal.fieldDataList = fieldDataListTotal; 
                    groupList.add(srgTotal);  
                }
                //SFSE-13698
            }   
            mat.reportFields = reportFields;
            mat.reportColumns = reportColumns;
            mat.groupList = groupList;  
            return mat;
        }else{
            return null;
        }
    }
    
    
    //SFSE-13019
    //Method to get the options for selected picklist field from the system
    @AuraEnabled
    public static List<Map<String,Map<String,String>>> getOptionsForPicklistFields(List<String> listObjectFld){
        try {
            List<Map<String,Map<String,String>>> options = new List<Map<String,Map<String,String>>>();
            Map<String,Map<String,String>> mapFieldNameToPicklist; 
            Map<String,String> labelPicklistOptions;
            for(String str : listObjectFld){
                labelPicklistOptions = new Map<String,String>();
                mapFieldNameToPicklist = new Map<String,Map<String,String>>();
                String strObj = str.subStringBefore('-');
                String strFld = str.subStringAfter('-');
                labelPicklistOptions = fetchPicklistOptions(strObj,strFld);
                mapFieldNameToPicklist.put(strFld,labelPicklistOptions);
                options.add(mapFieldNameToPicklist);
            } 
            return options;
        } catch (Exception e) {
            return null;
        }
    }
    
    //It is used to get the options for selected picklist field from the system
    @AuraEnabled(cacheable = true)
    public static Map<String,String> fetchPicklistOptions(string selectedObjectName, string selectedField){
        try { 
            Map<String,String> options = new  Map<String,String>(); 
            Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(selectedObjectName).getDescribe().fields.getMap();
            Schema.DescribeFieldResult pickFieldResult = mapFields.get(selectedField).getDescribe(); 
            List<Schema.PicklistEntry> picklistFields1 = pickFieldResult.getPicklistValues(); 
            
            for( Schema.PicklistEntry pickListFields2 : picklistFields1)
            { 
                options.put(pickListFields2.getLabel(),pickListFields2.getValue());
            }        
            return options;
        } catch (Exception e) {
            return null;
        }
    } 
    
    
    public class fieldDef {
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public String fieldLabel {get; set;}
        @AuraEnabled public String dataType {get; set;}
        @AuraEnabled public Integer key {get; set;}
    }
    
    public class fieldData {
        @AuraEnabled public String fieldValue {get; set;}
        @AuraEnabled public String fieldLabel {get; set;}
        @AuraEnabled public String dataType  {get; set;}
        @AuraEnabled public String uniqueKey {get; set;}
        @AuraEnabled public Boolean isSubTotal {get; set;}   
        @AuraEnabled public String rowName 		{get; set;}
        @AuraEnabled public String columnName 	{get; set;}
    }
    
    public class summaryReportResponse {
        @AuraEnabled public List<fieldDef> reportFields {get; set;}
        @AuraEnabled public List<summaryReportGroup> groupList {get; set;}
    }	
    
    public class summaryReportGroup {
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public String fieldValue {get; set;}
        @AuraEnabled public String fieldLabel {get; set;}
        @AuraEnabled public String groupKey {get; set;}
        @AuraEnabled public List<List<fieldData>> fieldDataList {get; set;}
    }
    
    public class matrixReportResponse {
        @AuraEnabled public String instanceId 		{get; set;}//SFSE-13481
        @AuraEnabled public List<fieldDef> reportFields {get; set;}
        @AuraEnabled public List<fieldDef> reportColumns {get; set;}
        @AuraEnabled public List<matrixReportGroup> groupList {get; set;}
    }	
    
    public class matrixReportGroup {
        @AuraEnabled public String rowName 		{get; set;}
        @AuraEnabled public String columnName 	{get; set;}
        @AuraEnabled public String groupKey {get; set;}
        @AuraEnabled public List<List<fieldData>> fieldDataList {get; set;}
    }
}