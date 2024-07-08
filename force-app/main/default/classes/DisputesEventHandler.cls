/*
* Author   : Vivek.agrawal@Maersk
* Purpose  : Handle the Insert of the Parent Dispute Case Platform event and updates/Insert those 
records as Case records when the disputes cases are consumed from EMP 

* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0      SS-4473     05-March-2022 Vivek.agrawal@Maersk     Handler class to convert events into Cases
DisputesEventHandlerTest() handles code coverage for this method.
2.0      SS-5304     25-May-2022   Vivek.agrawal@Maersk     Code updated to fix the issues with Case Visibility flag,
Case updates based on the changeTs flag
3.0      SS-6070     29-Aug-2022   Vivek.agrawal@Maersk     Code updated to accomodate the case Channel field updats

4.0      SC-6227     27-Jan-2023   Harmmet.Singh@Maersk     Updating the Case Owner to the User which has matching Maersk_User_Id__c as Processor Name field of Dispute Event

5.0	   SC-8532     04-July-2023  Vivek.agrawal@Maersk     Code updated to update Liner Brand on the Update Event                                 

*/
public with sharing class DisputesEventHandler  {
    
    public static void createDisputesCases(List<Disputes_Event__e> newList) {        
        //1. get the metadata and store in a map
        
        Map<String, String> consumerMetadataMap = new Map<String, String>();        
        //2. List of CaseComments to be inserted when an update events consumes        
        Set<CaseComment> caseCommentSet = new Set<CaseComment>(); // to remove duplicates
        List<CaseComment> caseCommentList = new List<CaseComment>();        
        //3. Dispute case recordType Id
        
        Id disputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        
        //4. Map of status code , status values, and resolved reason for case . Store the values as the mapping given by OHP
        
        Map<String, String> statusCodeMap = new Map<String, String>();        
        Map<String, String> statusCodeToResolvedReasonMap = new Map<String, String>();
        Map<String, General_Key_Value_Configurations__mdt> fieldvalueMap = General_Key_Value_Configurations__mdt.getAll();
        Map<String, String> companyCodeBrandMap = new Map<String, String>();
        
        for(String thisString : fieldvalueMap.keySet()){            
            if(thisString.contains('StatusCodetoStatusMap')){
                statusCodeMap.put(fieldvalueMap.get(thisString).Key__c, fieldvalueMap.get(thisString).First_Field_Value__c);
                statusCodeToResolvedReasonMap.put(fieldvalueMap.get(thisString).Key__c, fieldvalueMap.get(thisString).Second_Field_Value__c);
            }else if(thisString.contains('CarrierToBrandMap')){                
                companyCodeBrandMap.put(fieldvalueMap.get(thisString).Key__c, fieldvalueMap.get(thisString).First_Field_Value__c);                
            }
        }
        //4. Map of Company code , Brand for case . Store the values as the mapping given by OHP
        //5. For loop to gather the metadata records
        
        Map<String, EMP_Consumer_settings__mdt> mapConsumerData = EMP_Consumer_settings__mdt.getAll();        
        for(String thisData: mapConsumerData.keySet()){
            if(thisData.contains('DisputesMapping')){
                consumerMetadataMap.put(mapConsumerData.get(thisData).Json_Key__c, mapConsumerData.get(thisData).Field_Value__c);
            }
        }
        
        //6. List to store case records 
        List<Case> caseInsertList = new List<Case>();
        //7. Map to store updated case details where key will be invoice number , List to store cases
        Map<String, Map<String, Disputes_Event__e>> invoiceNumberEventUpdateMap  = new Map<String, Map<String,Disputes_Event__e>>();
        //3 lists to catch 3 different types of case updates in a single transaction. 
        List<Case> caseUpdateList = new List<Case>();
        List<Case> caseUpdateList2 = new List<case>();
        List<Case> caseUpdateList3 = new List<case>();
        //8. Map to store the Json field values coming from Heroku in string , string format
        Map<String, String> mapOfJsonData ;
        // SC - 6227
        Map<String, String> processorMap = new Map<String, String>();
        Map<String, Id> userOwnerMap = new Map<String, Id>();
        
        //9. Iterate through each notification Event and form the maps and List to insert /update cases       
        try{
            for(Disputes_Event__e thisEvent : newList){
                String jsonStr =  thisEvent.Json_1__c;
                mapOfJsonData = (Map<String, String>) JSON.deserialize(jsonStr, Map<String, String>.class);                
                if(mapOfJsonData != null && !mapOfJsonData.isEmpty() && mapOfJsonData.containsKey('processorName') && !String.isBlank(mapOfJsonData.get('processorName'))){
                    processorMap.put(mapOfJsonData.get('processorName'), mapOfJsonData.get('invoiceNumber')); 
                }
            }
            
            if(!processorMap.isEmpty() && processorMap.size()>= 1){
                userOwnerMap = getUserOwner(processorMap);
            }
            
            for (Disputes_Event__e thisEvent : newList) {
                String jsonStr =  thisEvent.Json_1__c;                
                mapOfJsonData = (Map<String, String>) JSON.deserialize(jsonStr, Map<String, String>.class);
                //Form  map for Update events
                if(mapOfJsonData != null && !mapOfJsonData.isEmpty() && mapOfJsonData.containsKey('eventType') && mapOfJsonData.get('eventType') == 'Update' && mapOfJsonData.containsKey('statusCode') && !String.isBlank(mapOfJsonData.get('statusCode')) && statusCodeMap.keySet().contains(mapOfJsonData.get('statusCode')) && mapOfJsonData.containsKey('invoiceNumber')){
                    if(invoiceNumberEventUpdateMap.containsKey(mapOfJsonData.get('invoiceNumber'))){                        
                        invoiceNumberEventUpdateMap.get(mapOfJsonData.get('invoiceNumber')).put(mapOfJsonData.get('changedTs'),thisEvent);
                    }
                    else{
                        invoiceNumberEventUpdateMap.put(mapOfJsonData.get('invoiceNumber'), new Map<String,Disputes_event__e>{mapOfJsonData.get('changedTs')=>thisEvent});                          
                    }                    
                }
                //store the details for  Insert events
                else if(mapOfJsonData != null && !mapOfJsonData.isEmpty() && mapOfJsonData.containsKey('eventType') && (mapOfJsonData.get('eventType') == 'Insert' || mapOfJsonData.get('eventType') == 'Create') && mapOfJsonData.containsKey('statusCode') && !String.isBlank(mapOfJsonData.get('statusCode')) && statusCodeMap.keySet().contains(mapOfJsonData.get('statusCode'))){
                    Case caseEvent = new case();
                    for(String str : consumerMetadataMap.keySet()){                        
                        caseEvent.put(consumerMetadataMap.get(str), mapOfJsonData.get(str));                         
                    }
                    
                    //hardcoded fields as per the Mapping file
                    caseEvent.Type = fieldvalueMap.get('HarcodeFieldMap1').First_Field_Value__c;
                    caseEvent.Sub_Type__c = fieldvalueMap.get('HarcodeFieldMap2').First_Field_Value__c;
                    
                    //Below logic for case channel coming from OHP .
                    //If(createdSource == OHP) then case Channel= 'OHP Disputes', if(createdSource == MAERSK.COM or MYFINANCE) then case channe= 'MYFINANCE' else case channel ='Others'
                    if(mapOfJsonData.containsKey('createdSource') && mapOfJsonData.get('createdSource').toUpperCase() == 'OHP'){
                        caseEvent.Case_Channel__c = 'OHP Disputes';
                    }else if(mapOfJsonData.containsKey('createdSource') && (mapOfJsonData.get('createdSource').toUpperCase() == 'MAERSK.COM' || mapOfJsonData.get('createdSource').toUpperCase() =='MYFINANCE')){
                        caseEvent.Case_Channel__c = 'MyFinance';
                    }else{
                        caseEvent.Case_Channel__c = 'Other';
                    }
                    caseEvent.Priority = fieldvalueMap.get('HarcodeFieldMap4').First_Field_Value__c;
                    caseEvent.Subject = 'Invoice Query -  '+mapOfJsonData.get('invoiceNumber');
                    caseEvent.recordTypeId = disputeRecordTypeId;
                    caseEvent.Status = statusCodeMap.get(mapOfJsonData.get('statusCode'));
                    caseEvent.Resolved_Reason__c = statusCodeToResolvedReasonMap.get(mapOfJsonData.get('statusCode'));
                    caseEvent.Reason_For_Case__c = fieldvalueMap.get('HarcodeFieldMap5').First_Field_Value__c;
                    caseEvent.Description = 'Sender: '+mapOfJsonData.get('contactPerson')+'\nSenderEmail:'+mapOfJsonData.get('contactEmail')+'\nExternal Notes: '+mapOfJsonData.get('noteDescription');
                    caseEvent.Case_Visibility__c = 'All Users';
                    caseEvent.Liner_Brand__c = companyCodeBrandMap.get(mapOfJsonData.get('companyCode'));
                    //SC - 6227
                    if(userOwnerMap!=null && !userOwnerMap.isEmpty() && userOwnerMap.size()>= 1 && userOwnerMap.containsKey(mapOfJsonData.get('processorName').toLowerCase())){
                        caseEvent.ownerId = userOwnerMap.get(mapOfJsonData.get('processorName').toLowerCase());
                    }
                    caseInsertList.add(caseEvent);
                }
                else{
                    String thisEventString = json.serialize(thisEvent);
                    ErrorLogger.writeError( 'Heroku EMP', 'Case', 'DisputeEventHandler', 'failed during insert',thisEventString, mapofJsonData.get('invoiceNumber'));
                }
            }
            
            //DML insert happens first to prevent the records coming with updates at the same time
            if(!caseInsertList.isEmpty()){
                Database.insert(caseInsertList, false);
            }
            Map<String, Case> UpdateMap ;
            Set<String> changeTSSet;
            List<String> changeTSList  ;
            //Store the case details for the update map
            //Fetch the existing cases and their related case comments
            //For inserting a case comment record
            //1. when update happens for the first time, if the description is not matching with the description on case, it will insert a case comment
            //2. for the update second time, if the recently created case comment commentbody does nto match with the noteDescription coming from EMP, it inserts a case comment record
            if(!invoiceNumberEventUpdateMap.isEmpty()){
                For(Case thiscase :[SELECT Disputed_Invoice_Number__c, Id, Status, Description ,OwnerId,Liner_Brand__c,
                                    (SELECT Id, createddate,CommentBody from CASECOMMENTS ORDER BY createddate DESC limit 200)
                                    FROM CASE WHERE   
                                    Disputed_Invoice_Number__c != null AND Disputed_Invoice_Number__c IN: invoiceNumberEventUpdateMap.keySet()]){
                                        if(invoiceNumberEventUpdateMap.containsKey(thisCase.Disputed_Invoice_Number__c)){
                                            Map<String, Disputes_Event__e> temp = invoiceNumberEventUpdateMap.get(thisCase.Disputed_Invoice_Number__c);
                                            
                                            //logic to sort the list of records for changeTs value
                                            changeTSSet= new Set<String>();
                                            changeTSSet.addAll(temp.keySet());
                                            changeTSList  = new List<String>();
                                            changeTSList.addAll(changeTSSet);
                                            changeTSList.sort();
                                            system.debug('-changeTSList'+changeTSList);
                                            //to capture description for case comment record creation
                                            String Description ;
                                            String Description2;
                                            
                                            updateMap = new Map<String, Case>();                                            
                                            for(String thisEventTemp: changeTSList){
                                                String jsonStr =  temp.get(thisEventTemp).Json_1__c;                                                
                                                mapOfJsonData = (Map<String, String>) JSON.deserialize(jsonStr, Map<String, String>.class);
                                                system.debug('**temp'+mapOfJsonData);
                                                Case tempCase = new Case(Id = thisCase.Id);
                                                
                                                //6227
                                                //Checking if ownerId is different from Existing owner on case record
                                                if(userOwnerMap!=null && !userOwnerMap.isEmpty() && userOwnerMap.size()>= 1 && mapOfJsonData.containsKey('processorName') && !String.isBlank(mapOfJsonData.get('processorName')) && userOwnerMap.containsKey(mapOfJsonData.get('processorName').toLowerCase()) && userOwnerMap.get(mapOfJsonData.get('processorName').toLowerCase()) != thiscase.ownerId){
                                                    tempCase.OwnerId = userOwnerMap.get(mapOfJsonData.get('processorName').toLowerCase());
                                                }
                                                
                                                //SC-8532
                                                //updating Liner Brand in update event if Liner Brand is not populated during insert , and is provided with update event
                                                if(thisCase.Liner_Brand__c== null && !companyCodeBrandMap.isEmpty() && companyCodeBrandMap.containsKey(mapOfJsonData.get('companyCode'))){
                                                    tempCase.Liner_Brand__c = companyCodeBrandMap.get(mapOfJsonData.get('companyCode'));
                                                }
                                                
                                                if(thisCase.Status != statusCodeMap.get(mapOfJsonData.get('statusCode')) && mapOfJsonData.get('statusCode') != '75'){
                                                    if((thisCase.status.contains('Closed') && (mapOfJsonData.get('statusCode')== '10' ||  mapOfJsonData.get('statusCode')== '20' || mapOfJsonData.get('statusCode')== '30')) || (thisCase.status.contains('In Progress') && mapOfJsonData.get('statusCode')=='10')){
                                                        //no updates as status can not be updated to triaged or IN Progress from Closed.
                                                        //no updates as status can not be updated to triaged from In Progress
                                                        continue;
                                                    }
                                                    else{
                                                        //    Case tempCase = new Case(Id = thisCase.Id);                                                        
                                                        thisCase.Status = statusCodeMap.get(mapOfJsonData.get('statusCode'));
                                                        tempCase.Status = statusCodeMap.get(mapOfJsonData.get('statusCode'));
                                                        tempCase.Resolved_Reason__c = statusCodeToResolvedReasonMap.get(mapOfJsonData.get('statusCode'));
                                                        UpdateMap.put(mapOfJsonData.get('statusCode'), tempCase);
                                                    }
                                                }
                                                else if(mapOfJsonData.get('statusCode') == '75' && thisCase.Status.contains('Closed')){// if redispute is coming after closed
                                                    thisCase.Status = statusCodeMap.get(mapOfJsonData.get('statusCode')); 
                                                    tempCase.Status = statusCodeMap.get(mapOfJsonData.get('statusCode')); 
                                                    tempCase.Resolved_Reason__c = statusCodeToResolvedReasonMap.get(mapOfJsonData.get('statusCode'));
                                                    UpdateMap.put(mapOfJsonData.get('statusCode'), tempCase);
                                                }
                                                if(!UpdateMap.containsKey(mapOfJsonData.get('statusCode'))){
                                                    updateMap.put(mapOfJsonData.get('statusCode'), tempCase);
                                                }
                                                //Case comment logic
                                                //fetch the latest case comment related to case for comparision
                                                if(thisCase.caseComments != null && thisCase.caseComments.size()>0){
                                                    for(CaseComment thisCaseComment : thisCase.CaseComments){                                                        
                                                        Description = 'Sender: '+mapOfJsonData.get('contactPerson')+'\nSenderEmail:'+mapOfJsonData.get('contactEmail')+'\nExternal Notes: '+mapOfJsonData.get('noteDescription');
                                                        Description2 = thisCaseComment.CommentBody;
                                                        break;
                                                    }
                                                }
                                                else{ //Fetch the description from case record to compare                                                    
                                                    Description =  'Sender: '+mapOfJsonData.get('contactPerson')+'\nSenderEmail:'
                                                        +mapOfJsonData.get('contactEmail')+'\nExternal Notes: '+mapOfJsonData.get('noteDescription');
                                                    Description2 = thisCase.Description != null ? thisCase.Description : 'Sender: ';
                                                }
                                                
                                                //When description is different then the present description of case Or latest case comment description, create a case comment record
                                                if(Json.serialize(Description2) != json.serialize(Description) && Description.length() != Description2.Length()){
                                                    CaseComment thisComment  = new CaseComment();
                                                    thisComment.parentId = thisCase.Id;
                                                    
                                                    //Check case comment Size body if greater than 4000 trim it                                                    
                                                    if(Description.length() > 4000 ){
                                                        Description = Description.substring(0, 4000);
                                                    }
                                                    thisComment.CommentBody = Description;                                                    
                                                    caseCommentSet.add(thisComment);
                                                }
                                            }
                                            if(!updateMap.isEmpty()){
                                                Integer noOfCases = updateMap.keySet().size();
                                                for(Case tempCase : updateMap.values()){
                                                    //if update map contains 2 or more records for the same maximum can be 3 updates for a case at a time
                                                    noOfCases = noOfCases-1;
                                                    if(noOfCases == 0)
                                                        caseUpdateList.add(tempCase);
                                                    else if(noOfCases ==1)
                                                        caseUpdateList2.add(tempCase);
                                                    else if(noOfCases ==2)
                                                        caseUpdateList3.add(tempCase);
                                                }
                                            }
                                        }else{
                                            ErrorLogger.writeError( 'Heroku EMP', 'Case', 'DisputeEventHandler', 'failed during Update',thisCase.Disputed_Invoice_Number__c, 'Map invoiceNumberEventUpdateMap.containsKey(thisCase.Disputed_Invoice_Number__c) is null' );
                                        }
                                    }
                
            }
            
            //DML Operations
            if(!caseUpdateList.isEmpty()){
                database.update(caseUpdateList, false);
            }
            if(!caseUpdateList2.isEmpty()){
                database.update(caseUpdateList2, false);                
            }
            if(!caseUpdateList3.isEmpty()){
                database.update(caseUpdateList3, false);
            }
            if(!caseCommentSet.isEmpty()){
                caseCommentList.addAll(caseCommentSet);
                database.insert(caseCommentList, false);                
            }
        }
        catch(Exception ex){            
            if (EventBus.TriggerContext.currentContext().retries < 1) {
                // Condition isn't met, so try again later.
                throw new EventBus.RetryableException(
                    Label.RetryPlatformEvent);
            } else {
                String thisEventList = newList.toString();
                ErrorLogger.writeError( 'Heroku EMP', 'Case', 'DisputeEventHandler', ex.getTypeName(), ex.getMessage() +' '+ex.getLineNumber(), ex.getStackTraceString()+thisEventList);
            }
        } 
    }
    
    //SC-6227  Query the users which has matching Maersk_User_Id__c with Dispute Event ProcessorName
    public static Map<String, Id> getUserOwner(Map<String, String> processorNameMap){
        Map<String, Id> userMap = new Map<String, Id>();
        for(User usr : [Select id,Name,Maersk_User_Id__c from User WHERE Maersk_User_Id__c != null AND Maersk_User_Id__c IN: processorNameMap.keyset()]){
            userMap.put(usr.Maersk_User_Id__c.toLowerCase(), usr.Id);
        }
        if(!userMap.isEmpty() && userMap.size() > 0){
            return userMap;
        }else{
            return null;
        }
    }
    
    public class disputesCustomException extends Exception{}
}