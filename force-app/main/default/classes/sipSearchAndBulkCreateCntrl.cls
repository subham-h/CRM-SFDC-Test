/*
* Version	 Story #		 Date		    Developer		Comments 
* 1.0		 SFSE-6973		11/10/2021	    Meghana@UST		Code created
* 1.1		 SFSE-8142      26/09/2022      Bharti@Maersk   Modify the logic to get eligible sip participant & update respective Employee HR Records
* 1.2 		 SFSE-9542 		12/10/2022     	Vazid 			Removed Months_for_annualization__c field reference from 'getEligibleUserList' & 'createSIPrecords' methods.
															Added code in 'getEligibleUserList' & 'createSIPrecords' methods to update the SIP records for selected users.	
* 1.3		 SFSE-9443		03/11/2022		Vazid			Marking status to 'No longer eligible' for employee records excluded from the workday.		
* 1.4 		 SFSE-9882		23/11/2022		Vazid			Mapping SIP_Participant_Id__c field from Employee HR Data
* 1.5		 SFSE-9928 		29/11/2022		Vazid 			Excluding Employee HR Data Records for 'No Longer Eligible', 'Update Received on SIP Ineligibility' and, 'Update Received' on SIP Manage screen for 'New' filter
* 1.8        SFSE-10183		11/01/2023		Vazid			Added if condition in createSIPrecords method to update the emp records irrespective of year condition
*/



public with sharing class sipSearchAndBulkCreateCntrl {
    
    // wrapper class to get picklist options on LWC init
    public class initData{
        
        @AuraEnabled public List<String> lstRoles {get; set;}
        @AuraEnabled public List<String> lstRegion {get; set;}
        @AuraEnabled public List<String> lstArea {get; set;}
        @AuraEnabled public List<String> lstYear {get; set;}
        
        public initData(){
            lstRoles = new List<String>();
            lstRegion = new List<String>();
            lstArea = new List<String>();
            lstYear = new List<String>();
        }
        
    }
    
    // method to fetch region/area/roles and use same in LWC as fiter options
    @AuraEnabled(cacheable=false)
    public static initData getInitLists() {
        
        initData lstDropdownOptions = new initData();
        
        // get unique sales roles from Employee HR Data
        for (AggregateResult groupedResult : [SELECT Sales_Role__c FROM Employee_HR_Data__c WHERE Sales_Role__c != null GROUP BY Sales_Role__c ORDER BY Sales_Role__c]){
            lstDropdownOptions.lstRoles.add((String) groupedResult.get('Sales_Role__c'));
        }
        
        // get regions and areas
        for (BDA__c bda : [SELECT Id, Name, Type__c FROM BDA__c WHERE Active__c = true AND (Type__c = 'Cluster' OR Type__c = 'Trade Region') Order By Name]){
            
            if ( bda.Type__c == 'Cluster'){
                lstDropdownOptions.lstArea.add(bda.Name);
                
            } else if ( bda.Type__c == 'Trade Region'){
                lstDropdownOptions.lstRegion.add(bda.Name);
            } 
        }
        
        Integer exemptedYear = Integer.valueOf(Label.Create_SIP_Exempted_Year);
        // get year list - current year and next year
        integer year = date.today().year();
        if(year > exemptedYear){
            lstDropdownOptions.lstYear.add(String.valueOf(year));
        }        
        lstDropdownOptions.lstYear.add(String.valueOf(year+1));
        //lstDropdownOptions.lstYear.add(String.valueOf(year+2));
        
        System.debug(lstDropdownOptions);
        
        return lstDropdownOptions;
    }
    
    //To get the Id of 'Employee HR Data History Report' in lwc component
    @AuraEnabled(cacheable=true)
    public static String getReportId(){
        return [SELECT Id,Name FROM Report WHERE Name =: system.Label.Employee_HR_Data_Report LIMIT 1]?.Id;
    }
    
    // get eligible SIP participant list
    @AuraEnabled(cacheable=false)
    public static List<Employee_HR_Data__c> getEligibleUserList( String strYear, String strRole, String strArea, String strRegion, integer offset, integer noOfRows, String strOrderBy, String strOrderDirection, Boolean isStatusNew, String strStatus) {
        
        integer intYear = integer.valueOf(strYear);
        
        
        // form SOQL to get eligible participants
        String strQuery = 'SELECT Id, Employee__c, Employee__r.Name, Area__c,Region__c, Manager__r.Name, Sales_Role__c, Paymix__c, Brand__c,SIP_Status__c  ';
        strQuery += ' FROM Employee_HR_Data__c WHERE Employee__c != null ';
        
        
        // get if SIP participant is eligible for selected year
        system.debug('isStatusNew'+isStatusNew);
        if(isStatusNew ){
            string likeyear = '%'+strYear+'%';
            strQuery += 'AND (NOT SIP_Years__c LIKE \''+String.escapeSingleQuotes(likeyear)+'\')';
            strQuery += ' AND (CALENDAR_YEAR(Termination_Date__c) > :intYear or Termination_Date__c = null)';
            strQuery += ' AND (CALENDAR_YEAR(SIP_Ineligible_Date__c) >= :intYear or SIP_Ineligible_Date__c = null)';
            strQuery += 'AND (CALENDAR_YEAR(From_Date__c)<=:intYear)';
            strQuery += ' AND SIP_Status__c NOT IN  (\'No Longer Eligible\',\'Update Received on SIP Ineligibility\',\'Update Received\')';
        }else{
            string strStatusNew = (strStatus == 'No Longer Eligible') ? 'Update Received on SIP Ineligibility' : strStatus ;
            system.debug('status'+ strStatusNew);
            strQuery += ' AND SIP_Status__c= :strStatusNew ';
        }
        
        // if role filter is selected then apply where clause on role
        if (String.isNotEmpty(strRole) ){
            strQuery += ' AND Sales_Role__c= :strRole ';
        }
        
        // if Area filter is selected then apply where clause on Area
        if (String.isNotEmpty(strArea) ){
            strQuery += ' AND Area__c= :strArea ';
        }
        
        // if Region filter is selected then apply where clause on Region
        if (String.isNotEmpty(strRegion) ){
            strQuery += ' AND Region__c= :strRegion ';
        }
        
        strQuery += ' Order By ' + strOrderBy + ' ' + strOrderDirection;
        
        // to support lazy loading in LWC, fetch a limited no of records at a time. Use offset to determine which rows to select
        strQuery = strQuery + ' LIMIT ' + noOfRows + ' OFFSET  ' + offset ;
        system.debug('strQuery: '+ strQuery);
        
        List<Employee_HR_Data__c> userList = database.query(strQuery);
        
        return userList;
    }
    
    // create SIP records for selected users
    @AuraEnabled(cacheable=false)
    public static String createSIPrecords( String strYear, List<Id> selectedHREmployeeIds, Boolean isStatusNew) {
        
        Map<String, Id> mapBDAToId = new Map<String, Id>();
        Set<String> setBDAs = new Set<String>();
        Map<string,Employee_HR_Data__c> mapOfEmpHRdata = new Map<string,Employee_HR_Data__c>();
        // get all column data from Employee HR Data records based on selected Ids
        List<Employee_HR_Data__c> lstHrData = [ SELECT Id, Employee__c, Area__c,Region__c, Sales_Role__c , Paymix__c ,  Manager__r.Name, Brand__c,Employee_HR_Id__c,From_Date__c,SIP_Ineligible_Date__c,Termination_Date__c,SIP_Years__c,SIP_Status__c,Employee_ID__c
                                               FROM Employee_HR_Data__c
                                               WHERE Id in :selectedHREmployeeIds];
        
        // Area and Region are text fields in 'Employee HR Data' and lookup to BDA in 'SIP Participant'
        // Create a set of area/region names from 'Employee HR Data', use same set to fetch Id of corresponding BDA records
        for (Employee_HR_Data__c empRec : lstHrData){
            if(String.isNotEmpty(empRec.Area__c) && ! setBDAs.contains(empRec.Area__c)){
                setBDAs.add(empRec.Area__c);
            }
            
            if(String.isNotEmpty(empRec.Region__c) && ! setBDAs.contains(empRec.Region__c)){
                setBDAs.add(empRec.Region__c);
            }
            // Create map of Employee HR ID and it's releated record to update the SIP records
            if(String.isNotEmpty(empRec.Employee_ID__c)){
                mapOfEmpHRdata.put(empRec.Employee_ID__c,empRec);
            }
        }
        
        for ( BDA__c bdaRec : [SELECT Id, Name FROM BDA__c WHERE Name in :setBDAs and Active__c = true AND (Type__c = 'Cluster' OR Type__c = 'Trade Region') ]){
            mapBDAToId.put(bdaRec.Name, bdaRec.Id);
        }
        
        List<SIP_Participant__c> lstSIPs = new List<SIP_Participant__c>();
       
        if(isStatusNew){
            for (Employee_HR_Data__c empData : lstHrData){
                SIP_Participant__c newSIP = new SIP_Participant__c();
                newSIP.SIP_Participant__c = empData.Employee__c;
                newSIP.Year__c = strYear;
                newSIP.Paymix__c = empData.Paymix__c;
                newSIP.Area__c = mapBDAToId.get(empData.Area__c);
                newSIP.Region__c = mapBDAToId.get(empData.Region__c);
                newSIP.Sales_Role__c = empData.Sales_Role__c;
                newSIP.Manager__c = empData.Manager__c;
                newSIP.Brand__c = empData.Brand__c;
                newSIP.Employee_HR_Id__c = empData.Employee_HR_Id__c;
                newSIP.SIP_Eligible_Date__c =empData.From_Date__c;
                newSIP.Termination_Date__c = empData.Termination_Date__c;
                newSIP.SIP_Ineligible_Date__c = empdata.SIP_Ineligible_Date__c;
                newSIP.SIP_Participant_Id__c = empdata.Employee_ID__c;
                lstSIPs.add(newSIP);
                
                if(empData.SIP_Status__c =='New'){
                    empData.SIP_Status__c ='SIP Participant Created';
                }
                
                empData.SIP_Years__c = (empData.SIP_Years__c != Null) ? (empData.SIP_Years__c + strYear + ';') : strYear + ';' ;
            }
        }
        else{
            // update SIP records for selected users
            if(!mapOfEmpHRdata.keyset().isEmpty()){
                for(SIP_Participant__c sipRec: [select Id,SIP_Participant__c, Employee_HR_Id__c, SIP_Participant_Id__c, Paymix__c,Area__c,Region__c,Sales_Role__c,Manager__c, Brand__c,SIP_Eligible_Date__c,Termination_Date__c,SIP_Ineligible_Date__c,Year__c from SIP_Participant__c where SIP_Participant_Id__c in : mapOfEmpHRdata.keyset() AND Year__c >=: string.valueof(System.today().year())]){
                    if(mapOfEmpHRdata.containsKey(sipRec.SIP_Participant_Id__c)){
                        sipRec.Sales_Role__c =   mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Sales_Role__c;
                        sipRec.Area__c = mapBDAToId.get(mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Area__c);
                        sipRec.Paymix__c = mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Paymix__c;
                        sipRec.Brand__c = mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Brand__c;
                        sipRec.Manager__c = mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Manager__c;
                        sipRec.SIP_Eligible_Date__c = mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).From_Date__c;
                        sipRec.Termination_Date__c = mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Termination_Date__c;
                        sipRec.SIP_Ineligible_Date__c = mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).SIP_Ineligible_Date__c;
                        sipRec.Region__c = mapBDAToId.get(mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Region__c);
                        sipRec.SIP_Participant__c = mapOfEmpHRdata.get(sipRec.SIP_Participant_Id__c).Employee__c;
                        lstSIPs.add(sipRec);
                    }
                }
                for(Employee_HR_Data__c empRec : lstHrData){
                    if(empRec.SIP_Status__c == 'Update Received on SIP Ineligibility'){
                        empRec.SIP_Status__c = 'No longer eligible';
                    }else{
                        if(empRec.SIP_Status__c == 'Update Received'){
                            empRec.SIP_Status__c = 'Update Processed';
                        }
                    }
                }
            }
           
        }
        
        return sipRunDMLinSystemMode.performDMLAsAdmin(lstHrData,lstSIPs);
    }
}