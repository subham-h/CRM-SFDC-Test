/*
* Author   : Ayush.k@Maersk
* Purpose  : To update the various fields for Non KC Case.
  
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0       SS-5430    16-Nov-2022     Ayush.k@Maersk        To identify the SO Number and related Customer Name for Non KC Case.
* 2.0       SC-7616    30-Jul-2023     Harmeet@Maersk        Update SO Number and OBA on Case Creation from CTM records 
   
*/

public class PopulateNonKeyClientCase {
    
    public class applicationException extends Exception {}
    public static General_Key_Value_Configurations__mdt fieldValues = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogFieldValues');
    public static General_Key_Value_Configurations__mdt fieldValues2 = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogFieldValues2');

    public static General_Key_Value_Configurations__mdt response = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogResult');

    public static void populateSOandOBA(list<Case> newCaselist){
      try{
          Integer flagSize = 0;
          String soNumber;
          Id onBehalfAccountId;
          Map<String, String> mapCTask = new Map<String, String>();
          Map<String, String> mapResponse = new Map<String, String>();
          Case newCase = [Select Id,subject,description from Case WHERE Id = :newCaselist[0].Id limit 1]; 
          Map<String,String> mapSOAndCustomer = new Map<String,String>();
          General_Key_Value_Configurations__mdt regexPattern = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogRegex');
          //Set of all the substring with the pattern in Subject
          Set<String> matchInSubject = new Set<String>();
          if(newCase.subject!=null){
             matchInSubject = patternMatch(regexPattern.First_Field_Value__c,newCase.subject);
           }
            //Set of all the substring with the pattern in Description
           Set<String> matchInDescription = new Set<String>();
           if(newCase.description!=null){
             matchInDescription = patternMatch(regexPattern.First_Field_Value__c,newCase.description); 
           }
                
           List<String> lstMatchAll = new List<String>();
           lstMatchAll.addAll(matchInSubject);
           lstMatchAll.addAll(matchInDescription);
                
           //Set of all Substring with matches with the given SO Number and Customer Name from IDA.
          Set<String> matchAll = new Set<String>(lstMatchAll);
          String matchStr;
          list<String> matchList = new list<String>();
          if(!matchAll.isEmpty()){
             matchStr = (new list<string>(matchAll)[0]);
             matchList = matchStr.split(',');
          }
          
          if(matchAll.size() == 1 ){
            for(LS_TM_Connective_Task__c objCTask : [SELECT LS_TM_Consignee_Name__c,LS_TM_External_Reference_Type__c,LS_TM_External_Reference_Number__c,Related_SO_BLs__c FROM LS_TM_Connective_Task__c where (LS_TM_External_Reference_Type__c ='SO' and LS_TM_External_Reference_Number__c = :matchAll) OR (LS_TM_External_Reference_Type__c != 'SO' AND Related_SO_BLs__c LIKE :('%'+matchStr+'%')) limit 1]){
                if(objCTask != null  && (!mapCTask.containsKey(objCTask.LS_TM_External_Reference_Number__c) || !mapCTask.containsKey(objCTask.Related_SO_BLs__c) ) ){
				   if(objCTask.LS_TM_External_Reference_Type__c == 'SO' && objCTask.LS_TM_External_Reference_Number__c != null){
                     mapCTask.put(objCTask.LS_TM_External_Reference_Number__c, objCTask.LS_TM_Consignee_Name__c); 
                     flagsize += 1;
			       }else if(objCTask.LS_TM_External_Reference_Type__c !='SO' && objCTask.Related_SO_BLs__c!=null ){
				      for(String str : matchList){
                        if(objCTask.Related_SO_BLs__c.contains(str)){
                           mapCTask.put(str, objCTask.LS_TM_Consignee_Name__c); 
                           flagsize += 1;
                           break;
                        }
                     }
				   }	
	            }else if(mapCTask.containsKey(objCTask.LS_TM_External_Reference_Number__c) || mapCTask.containsKey(objCTask.Related_SO_BLs__c)){
                  continue;
                }
             }
            if(flagsize == 1){ 
              for(String keyValue :mapCTask.keySet()){
                mapResponse.put(fieldValues.First_Field_Value__c, keyValue);
                mapResponse.put(fieldValues.Second_Field_Value__c, mapCTask.get(keyValue) );
               }
            }
           if(!mapResponse.isEmpty()){
              soNumber = mapResponse.get(fieldValues.First_Field_Value__c);
              String customerName = mapResponse.get(fieldValues.Second_Field_Value__c);
              List<Account> lstTempAcc = new List<Account>([SELECT id FROM Account WHERE name = :customerName limit 1]);
              if(!lstTempAcc.isEmpty()){
                onBehalfAccountId = lstTempAcc[0].Id;
              }
              Case tempCase = new Case();
              tempCase.Id = newCase.Id;
              tempCase.SO_Number__c = soNumber;
              tempCase.On_Behalf_Account__c = onBehalfAccountId;
              TriggerExecutionController.skipCaseTrigger(true);
                update tempCase;
              TriggerExecutionController.skipCaseTrigger(false);
           }
       }
               
     }catch(Exception ex) {
        ErrorLogger.writeErrors( 'SFDC', 'Case', 'PopulateNonKeyClientCase.populateSOandOBA', new list<Exception>{ex});  
     }

               
    } 
     
    public static void populateAccountDetails(ID caseId, String soNumberFromIDA, String customerNameFromIDA, String customerNameExtractedFromIDA) {
        //List to Store the Details about the case
        List<Case> lstCase = new List<Case>([SELECT Id,subject,description,SO_Number__c,On_Behalf_Account__c from Case WHERE id = :CaseId]);
        
        //Map to Store the SO Number and customer Name with the matching case ID
        Map<String,String> mapSOAndCustomer = new Map<String,String>();  
        
        General_Key_Value_Configurations__mdt regexPattern = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogRegex');
        
        try{
            if(!lstCase.isEmpty()){
                Case tempCase = lstCase[0];
                //Set of all Substring with matches with the given SO Number and Customer Name from IDA.
                Set<String> matchAll = new Set<String>();
                
                if(soNumberFromIDA != response.First_Field_Value__c && soNumberFromIDA != response.Second_Field_Value__c && soNumberFromIDA != '' && soNumberFromIDA != null){
                    matchAll.add(soNumberFromIDA.toUpperCase().replaceAll(' ',''));
                }
                //Check if the count of SO Number from IDA and from Subject and Description of Case is 1.
                if(matchAll.size() == 1 && soNumberFromIDA != response.Second_Field_Value__c){
                    mapSOAndCustomer = confirmSONumber(matchAll);
                    //If we have no customer name related to the Single SO Number
                    if(mapSOAndCustomer.get(fieldValues.First_Field_Value__c) != null && (mapSOAndCustomer.get(fieldValues.First_Field_Value__c) == response.First_Field_Value__c || mapSOAndCustomer.get(fieldValues.First_Field_Value__c) == response.Second_Field_Value__c)){
                    	//Go with the Customer Name Logic
                    	mapSOAndCustomer = populateViaCustomerName(customerNameFromIDA,tempCase,mapSOAndCustomer);
                    }//If we have customer name associated with the So Number
                    else{
                       mapSOAndCustomer = populateSONumberAndCustomerName(tempCase,mapSOAndCustomer,customerNameFromIDA);
                    }
				}//Check if the count of SO Number is more than 1, use the Customer Name Logic.
                else if(matchAll.size() > 1 || soNumberFromIDA == response.Second_Field_Value__c ){
                    mapSOAndCustomer.put(fieldValues.First_Field_Value__c, response.Second_Field_Value__c);
                    mapSOAndCustomer = populateViaCustomerName(customerNameFromIDA,tempCase,mapSOAndCustomer);
                }//If the count of SO Number is 0, use the Customer Name Logic.
                else{
                    mapSOAndCustomer.put(fieldValues.First_Field_Value__c, response.First_Field_Value__c);
                    mapSOAndCustomer = populateViaCustomerName(customerNameFromIDA,tempCase,mapSOAndCustomer);
                }               
                TriggerExecutionController.skipCaseTrigger(true);
                  update lstCase;
                TriggerExecutionController.skipCaseTrigger(false);
                updateIntegrationLog(mapSOAndCustomer,caseId,soNumberFromIDA,customerNameFromIDA, customerNameExtractedFromIDA);
            }
        }
		Catch(Exception ex){
            ErrorLogger.writeError( 'Populate Non KC Case', 'Case', 'PopulateNonKeyClientCase.populateAccountDetails', ex.getMessage(),caseId,'Unknown exception' );     
        }
    }
    
    public static Map<String,String> populateViaCustomerName(String customerNameFromIDA, Case tempCase, Map<String,String> mapSOAndCustomer){
        //If we have no customer name from the IDA.
        if(customerNameFromIDA == response.First_Field_Value__c || customerNameFromIDA == response.Second_Field_Value__c){            
            mapSOAndCustomer.put(fieldValues.Second_Field_Value__c,customerNameFromIDA);
        }//If we get null or blank for Customer Name then it should be updated to No Response
        else if (customerNameFromIDA == null || customerNameFromIDA == ''){
            mapSOAndCustomer.put(fieldValues.Second_Field_Value__c,response.First_Field_Value__c);
        }
        //If we have customer name from IDA.
        else{
            mapSOAndCustomer = populateCustomerName(customerNameFromIDA,tempCase,mapSOAndCustomer);            
        }
        return mapSOAndCustomer;
    }
    

    
     public static Set<String> patternMatch(String patternValue, String text) {      
        Pattern regexPattern = Pattern.compile(patternValue);
        Matcher regexMatcher = regexPattern.matcher(text);
        Set<String> matches = new Set<String>();
        while(regexMatcher.find()){
            String tempSONumber = regexMatcher.group();
            Integer firstIndex= text.indexOf(tempSONumber);
            if(text.length() != tempSONumber.length() && firstIndex>0 && text.subString(firstIndex+10, text.length()) != '' ){

            	if(!text.subString(firstIndex-1,firstIndex).isAlphanumeric() && !text.subString(firstIndex+10, firstIndex+11).isAlphanumeric())
                { 
            		matches.add(tempSONumber.toUpperCase().replaceAll(' ',''));
                }
                }else
                	continue;
    		}
         system.debug('-->matches'+matches);
        return matches;
    }
    
    
    //Confirm if the SO Number has an account related to it or not.
    public static Map<String,String> confirmSONumber(Set<String> matchAll) {
        //String matchStr = (new list<string>(matchAll)[0]);
        //list<String> matchList = matchStr.split(',');
        String matchStr;
        list<String> matchList = new list<String>();
        if(!matchAll.isEmpty()){
           matchStr = (new list<string>(matchAll)[0]);
           matchList = matchStr.split(',');
        }
    	Map<String, String> mapCTask = new Map<String, String>();
        Map<String, String> mapResponse = new Map<String,String>();
        Integer flagSize = 0;
      
        for(LS_TM_Connective_Task__c objCTask : [SELECT LS_TM_Consignee_Name__c,LS_TM_External_Reference_Type__c,LS_TM_External_Reference_Number__c,Related_SO_BLs__c FROM LS_TM_Connective_Task__c where (LS_TM_External_Reference_Type__c ='SO' and LS_TM_External_Reference_Number__c = :matchAll) OR (LS_TM_External_Reference_Type__c != 'SO' AND Related_SO_BLs__c LIKE :('%'+matchStr+'%'))  limit 1]){
            if(objCTask != null  && (!mapCTask.containsKey(objCTask.LS_TM_External_Reference_Number__c) || !mapCTask.containsKey(objCTask.Related_SO_BLs__c) ) ){
				if(objCTask.LS_TM_External_Reference_Type__c == 'SO' && objCTask.LS_TM_External_Reference_Number__c != null){
                  mapCTask.put(objCTask.LS_TM_External_Reference_Number__c, objCTask.LS_TM_Consignee_Name__c); 
                  flagsize += 1;
			    }else if(objCTask.LS_TM_External_Reference_Type__c !='SO' && objCTask.Related_SO_BLs__c!=null ){
                    for(String str : matchList){
                        if(objCTask.Related_SO_BLs__c.contains(str)){
                           mapCTask.put(str, objCTask.LS_TM_Consignee_Name__c); 
                           flagsize += 1;
                           break;
                        }
                     }
				}	
	
            }else if(mapCTask.containsKey(objCTask.LS_TM_External_Reference_Number__c) || mapCTask.containsKey(objCTask.Related_SO_BLs__c)){
                continue;
            }
        }
        if(flagsize == 1){ 
            for(String keyValue :mapCTask.keySet()){
                mapResponse.put(fieldValues.First_Field_Value__c, keyValue);
                mapResponse.put(fieldValues.Second_Field_Value__c, mapCTask.get(keyValue) );
            }
        }else if(flagsize == 0){
            mapResponse.put(fieldValues.First_Field_Value__c, response.First_Field_Value__c);
        }else{
            mapResponse.put(fieldValues.First_Field_Value__c, response.Second_Field_Value__c);
        }
        return mapResponse;
	} 
    
    //Populate the Customer Name in the case if the SO Number does not match
    public static Map<String,String> populateCustomerName(String customerName, Case tempCase, Map<String,String> mapSOAndCustomer) {
        List<Account> lstTempAcc = new List<Account>([SELECT id FROM Account WHERE name = :customerName]);
        if(!lstTempAcc.isEmpty()){
            tempCase.On_Behalf_Account__c = lstTempAcc[0].id;
            tempCase.SO_Number__c = '';
            mapSOAndCustomer.put(fieldValues.Second_Field_Value__c, customerName);
        }
        else{
            mapSOAndCustomer.put(fieldValues.Second_Field_Value__c, response.First_Field_Value__c);
        }        
        return mapSOAndCustomer;
    }

    
    public static Map<String,String> populateSONumberAndCustomerName(Case tempCase, Map<String,String> mapSOAndCustomer, String customerNamedb) {
        String soNumber = mapSOAndCustomer.get(fieldValues.First_Field_Value__c);
        String customerName = mapSOAndCustomer.get(fieldValues.Second_Field_Value__c);
        //Case tempCase  = [Select Id,SO_Number__c,On_Behalf_Account__c from case WHERE Id = :tempCaseId limit 1]; 
        tempCase.SO_Number__c = soNumber;
		
        List<Account> lstTempAccdb = new List<Account>([SELECT id FROM Account WHERE name = :customerNamedb limit 1]);
		List<Account> lstTempAcc = new List<Account>([SELECT id FROM Account WHERE name = :customerName limit 1]);
                  
        if(!lstTempAccdb.isEmpty()){
            tempCase.On_Behalf_Account__c = lstTempAccdb[0].id;
            mapSOAndCustomer.put(fieldValues.Second_Field_Value__c,customerNamedb);     
        }
        else if(!lstTempAcc.isEmpty()){
			tempCase.On_Behalf_Account__c = lstTempAcc[0].id;
            mapSOAndCustomer.put(fieldValues.Second_Field_Value__c, customerName);
			
        }else{
			mapSOAndCustomer.put(fieldValues.Second_Field_Value__c, response.First_Field_Value__c);
		}	
        return mapSOAndCustomer;
    }
    
  	//Publish the changes to customer Name and SO Number in the Integration Logs
    public static void updateIntegrationLog(Map<String,String> mapSOAndCustomer, Id caseId, String soNumberFromIDA, String customerNameFromIDA, String customerNameExtractedFromIDA) {
        Integration_Log_Event__e thisEvent = new Integration_Log_Event__e();
        
        String jsonResponse = '{\"caseId\":\"' + caseId + '\",\"'+fieldValues.Second_Field_Value__c+'\":\"' + mapSOAndCustomer.get(fieldValues.Second_Field_Value__c)+'\",\"'+fieldValues.First_Field_Value__c+'\":\"'+mapSOAndCustomer.get(fieldValues.First_Field_Value__c)+'\",\"request_id\":\"'+soNumberFromIDA+' , '+customerNameFromIDA+'\",\"customerNameExtracted\":\"' + customerNameExtractedFromIDA +'\"}';
        thisEvent.JSON_Response__c = jsonResponse;
        
        Database.SaveResult sr = EventBus.publish(thisEvent);
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            throw new ApplicationException('Platform Event to Update the details has not been published');
        }
	}

      






}