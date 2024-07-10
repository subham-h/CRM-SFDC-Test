/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-8141        22/08/2022     Meghana Gupta            Code Created
*  SFSE-9294        25/09/2022     Bharti Rana             Add & Map the new fields 
*  SFSE-8142        26/09/2022     Bharti Rana             Add the logic to set the Sales Roles
*  SFSE-9542 		12/10/2022     Vazid 				   Removed Months_for_annualization__c field reference from 'formEmpRecords' method and sipEmployeeDataWrapper.
*  SFSE-9443 		03/11/2022	   Vazid				   Added logic to indentify the employee records which are excluded from workday process
*  SFSE-10815       27/04/2023     Bharti Rana             Added logic to make Exclude from workday checkbox true of existing employee,if we start getting update from workday.   
*  SFSE-11111		04/07/2023     Vazid				   Removed Region/Area code and Moved to EmployeeHRData Trigger.	
*  SFSE-12319		31/08/2023	   Aditi Srivastava		   Mapping blank and other(ones that cannot be found in SFDC) Brand values to 'Maersk'

* ***/

public class sipWorkdayUtilities {
    
    //wrapper for json response from workday 
    public class sipEmployeeDataWrapper {
        
        public String PositionTitle;
        //public String Months_For_Annualization;
        public String Manager_Unique_ID;
        public String Brand_Name;
        public String Employee_Unique_ID;
        public String SIP_Eligiblity;
        public String Country_Alpha_2_Code;
        public String SIP_Eligible_date;
        public String Paymix; 
        public String SIP_Noneligible;
        public String termination_date;
        public String Employee_ID;
        public String IsManager;
	
	}
    
    // Get response from workday and form List<Employee_HR_Data>
    public static List<Employee_HR_Data__c>  getEmpHrData(){
        
        List<Employee_HR_Data__c> lstInsertEmpData = new List<Employee_HR_Data__c>();
        String hostName = 'workday_prod'; // Named credetial for PROD
        // in case of sandbox get hostname to form respective Named Credential 
        if(StaticFactory.getEnvironment() == 'Sandbox') {
            hostName = 'workday_'+ URL.getSalesforceBaseUrl().getHost().substringBetween('--','.').toLowerCase();
        }
        if(Test.isRunningTest()) {
            hostName = 'workday_sit';
        }
        system.debug('hostName:'+ hostName);
        
        // get connection details from metadata
        SIP_Connection_Details__mdt sipConnection = SIP_Connection_Details__mdt.getInstance(hostName);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(sipConnection.Endpoint_URL__c);
        req.setMethod('GET');
        req.setTimeout((integer)sipConnection.Timeout__c);
        
        try{
        	HTTPResponse response = http.send(req);
        	Map<String, List<sipEmployeeDataWrapper>> mapJsonResponse = (Map<String,List<sipEmployeeDataWrapper>>) System.JSON.deserialize(response.getBody(),Map<String, List<sipEmployeeDataWrapper>>.class);
        	lstInsertEmpData = formEmpRecords(mapJsonResponse.get('Report_Entry'));
        }
        catch(System.CalloutException ex){
            ErrorLogger.writeError('SFDC', 'SIP-Employee HR Data', 'sipWorkdayUtilities.getEmpHrData', ex.getTypeName(), ex.getMessage(), ex.getMessage());
        }
        return lstInsertEmpData;
    }
    
    // convert response array to List of Employee_HR_Data__c records
    public static List<Employee_HR_Data__c> formEmpRecords(List<sipEmployeeDataWrapper> lstEmpRecords) {
        
        List<Employee_HR_Data__c> lstInsertEmpData = new List<Employee_HR_Data__c>();
        Map<String, String> mapBrands = new Map<String, String>();
        
        // get mapping for brands names between Workday and SFDC allowed values
        for (SIP_Workday_Brand_Mapping__mdt sipBrand : SIP_Workday_Brand_Mapping__mdt.getAll().values()) {
            mapBrands.put(sipBrand.label, sipBrand.Brand__c);
        }      
         //SFSE-11111 : Commented below line and moved to the trigger.   
        //Map<String, BDA_Geography__c> areaMap = getAreaMap();
        set<string> setOfEmpIds = new set<string>(); // SFSE-9443
        
        for (sipEmployeeDataWrapper empRecord : lstEmpRecords) {
            Employee_HR_Data__c newEmpRecord = new Employee_HR_Data__c();
            if(empRecord.IsManager =='0') {
                newEmpRecord.Sales_Role__c ='Sales Rep';
            } else {
                 newEmpRecord.Sales_Role__c ='Sales Manager';
            }
            
  			setOfEmpIds.add(empRecord.Employee_Unique_ID); // SFSE-9443
            
            newEmpRecord.Employee_ID__c = empRecord.Employee_Unique_ID;
            
             //making exclude from workday checkbox false for all records
             //10815
             newEmpRecord.Exclude_from_Workday_process__c = false;
            
            if(empRecord.SIP_Noneligible != null) {
                newEmpRecord.SIP_Ineligible_Date__c = Date.valueOf(empRecord.SIP_Noneligible);
            }
            
            if(empRecord.termination_date != null) {
                newEmpRecord.Termination_Date__c =Date.valueOf(empRecord.termination_date);
            }
            
            newEmpRecord.Employee_HR_Id__c = empRecord.Employee_ID;
            newEmpRecord.Manager__r = new User(Maersk_User_Id__c = empRecord.Manager_Unique_ID);
            newEmpRecord.Employee__r = new User(Maersk_User_Id__c = empRecord.Employee_Unique_ID);
			if (mapBrands.containsKey(empRecord.Brand_Name)) {
                newEmpRecord.Brand__c = mapBrands.get(empRecord.Brand_Name);
            } else {
                newEmpRecord.Brand__c = mapBrands.get('allOtherOrBlank'); //SFSE-12319
            }
            if (empRecord.SIP_Eligible_date != null) {
            	newEmpRecord.From_Date__c = Date.valueOf(empRecord.SIP_Eligible_date);
            }
            
            if (empRecord.Paymix != null) {
            	newEmpRecord.Paymix__c = decimal.valueOf(empRecord.Paymix);
            }
            if (empRecord.Country_Alpha_2_Code != null) { // SFSE-10649
                newEmpRecord.Country_Code__c = empRecord.Country_Alpha_2_Code;
            }
            
            //SFSE-11111 : Commented below snippet and moved to the trigger.
            /*if (empRecord.Country_Alpha_2_Code != null && areaMap.containsKey(empRecord.Country_Alpha_2_Code)){
                newEmpRecord.Area__c = areaMap.get(empRecord.Country_Alpha_2_Code).BDA__r.Name;
            	newEmpRecord.Region__c = areaMap.get(empRecord.Country_Alpha_2_Code).BDA__r.Parent_BDA__r.Name;
            } else if (empRecord.Country_Alpha_2_Code == null) {
                newEmpRecord.Area__c = null;
            	newEmpRecord.Region__c = null;
            }*/
           	lstInsertEmpData.add(newEmpRecord);
        }
        //SFSE-9443
        List<Employee_HR_Data__c> lstExistingEmpRecs = [ SELECT Id
                                                            , Employee_ID__c
                                                            , SIP_Ineligible_Date__c
                                                            , SIP_Status__c
                                                            , From_Date__c
                                                            , Manager__r.Maersk_User_Id__c
                                                            , Sales_Role__c
                                                            , Area__c
                                                            , Region__c
                                                            , Brand__c
                                                            , Paymix__c
                                                        FROM Employee_HR_Data__c
                                                        WHERE Exclude_from_Workday_process__c = false
                                                            AND SIP_Status__c NOT IN ('No longer eligible'
                                                                ,'Update Received on SIP Ineligibility')
                                                            AND Employee__c != null ];
        for(Employee_HR_Data__c empRec: lstExistingEmpRecs) {
            if(!setOfEmpIds.contains(empRec.Employee_ID__c)) {
                empRec.SIP_Status__c = 'Update Received on SIP Ineligibility';
                empRec.SIP_Ineligible_Date__c = system.today();
                lstInsertEmpData.add(empRec);
            }
        }
        
        return lstInsertEmpData;
    }
    
    // form Map of country to Region/Area names
    public static Map<String, BDA_Geography__c> getAreaMap() {
        Map<String, BDA_Geography__c> mapCountryCluster = new  Map<String, BDA_Geography__c>();
        for (BDA_Geography__c bda: [    SELECT Id
                                            , Geography__r.GEO_Code__c
                                            , BDA__r.Name
                                            , BDA__r.Parent_BDA__r.Name
                                        FROM BDA_Geography__c 
                                        WHERE BDA__r.Type__c ='Cluster'
                                            AND Geography__r.Type_Of_Location__c ='Country' ]){
                  mapCountryCluster.put(bda.Geography__r.GEO_Code__c, bda);
        }
        return mapCountryCluster;
    }
    
   }