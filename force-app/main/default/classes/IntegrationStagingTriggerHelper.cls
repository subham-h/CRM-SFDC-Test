/*
* Created By   : Shahanawaz@Maersk
* Purpose  : Utility class to hold simple and reusable functionalities for Integration Staging trigger. 
*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      #SC-8789   22-Sept-2023  Shahanawaz@Maersk      Trigger Handler on Integration Staging Object
* 2.0      #SC-8580   19-Oct-2023   Harmeet@Maersk         Update Cluster CS/CE field on basis of Countries Rules 
* 3.0      #SC-8651   25-Nov-2023   Sunil.BS@Maersk        Removed condition which was excluding twill cases for omni routing
* 4.0      #SC-8937   23-Jan-2024   Sandhya@Maersk         Added method to calculate Short Transit using reference API
* 5.0      #SC-9519   08-Dec-2023   Raksha@Maersk          AI Assist-Update Topic based on the nba values
* 6.0	   #SC-8631	  24-Apr-2024	Kiran@maersk		   Auto Case Assignment - Ocean - based on Cargo types - Reefer, OOG, Break Bulk
* 7.0	   #SC-10045  14-May-2024	Shahanawaz@maersk	   Store Vessel service numbers from shipment
* 8.0	   #SC-10138  03-June-2024	Meghna@maersk	       Auto Close Spam Cases

*/
public class IntegrationStagingTriggerHelper {

    //SC-8580
    public static String deliveryChannel = General_Key_Value_Configurations__mdt.getInstance('Delivery_Channel').first_field_value__c; 
    
    /** 
    * @description | process integration results records
    * @param stagingRecordsMap accepts map of Integration_Staging__c
    */
    public static void processIntegrationResult(Map<Id, Integration_Staging__c> stagingRecordsMap){
        try{
            List<Case> csListToUpdate = new List<Case>();
            Map<Id, List<Integration_Results__c>> caseIdToIntegrationResultsMap = new Map<Id, List<Integration_Results__c>>();
            Map<Id, Case> caseMap = new Map<Id, Case>();
            Map<Id, Care_Relationship__c> mapRelatedCareRelation;
            Map<Id, Client_Case_Assignments__c> mapKeyClientIds;
            Set<Id> carerelationshipidstoquery = new Set<id>();
            Set<Id> keyClientIdstoquery = new Set<id>();
            List<String> omniOriginList = new List<String>();
            List<Case> caseListToOmniRoute = new List<Case>();
            List<Batch_Error_Logger__c> errorList = new List<Batch_Error_Logger__c>();
            Map<Id, Case> caseMapToUpdate = new Map<Id, Case>();
            Map<String, Shipment__c> shipmentMap = new Map<string, Shipment__c>();
            Set<String> shipmentNumberSet = new Set<String>();
            List<Shipment__c> shipmentsToUpdateList = new List<Shipment__c>();
            
            for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'OmniChannelOrigins']){
                if(!String.isEmpty(gen.First_Field_Value__c)){
                    omniOriginList.addAll(gen.First_Field_Value__c.trim().split(','));
                }
            }
            
            for(Integration_Results__c inRes : [SELECT Id, Response__c, Operation_Name__c, Integration_Staging__c, Integration_Staging__r.Related_Record_Id__c FROM Integration_Results__c Where Integration_Staging__c =: stagingRecordsMap.keyset() AND Integration_Staging__r.Related_Record_Id__c != null]){
                if(caseIdToIntegrationResultsMap.isEmpty() || !caseIdToIntegrationResultsMap.containsKey(inRes.Integration_Staging__r.Related_Record_Id__c)){
                    caseIdToIntegrationResultsMap.put(inRes.Integration_Staging__r.Related_Record_Id__c, new List<Integration_Results__c>{inRes});
                }
                else{
                    caseIdToIntegrationResultsMap.get(inRes.Integration_Staging__r.Related_Record_Id__c).add(inRes);
                }
            }
            
            if(!caseIdToIntegrationResultsMap.isEmpty()){
                caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c,Case_Channel__c,Reason_For_Case__c,SF_4PL_Account__c,recordtypeid,Cluster__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name,Cargo_Flow__c,On_Behalf_Account__c,AccountId,Direction__c, Vessel_Service_Numbers__c From Case Where Id =: caseIdToIntegrationResultsMap.keyset()]);
                for(case caseinput : caseMap.values()){
                    if(caseinput.Care_Relationship__c != null){
                        carerelationshipidstoquery.add(caseinput.Care_Relationship__c);
                    }
                    if(!String.isBlank(caseinput.Shipment_Number__c)){
                        shipmentNumberSet.add(caseinput.Shipment_Number__c);
                    }
                    if(caseinput.On_Behalf_Account__c!=null){
                        keyClientIdstoquery.add(caseinput.On_Behalf_Account__c);
                    }
                    else if(caseinput.On_Behalf_Account__c==null && caseinput.AccountId!=null){
                        keyClientIdstoquery.add(caseinput.AccountId);
                    }
                }
                if(!carerelationshipidstoquery.isEmpty()){
                    mapRelatedCareRelation = new map<id, Care_Relationship__c>([select Id, Care_Business_Partner__c,GSC_Agent__c,Frontline_backup__c, GSC_Backup_Agent__c from Care_Relationship__c where Id IN: carerelationshipidstoquery]);
                }
                if(!keyClientIdstoquery.isEmpty()){
                    mapKeyClientIds = new map<id, Client_Case_Assignments__c>([select id, Active__c,Account__c, Direction__c,Country__c,Dedicated_Agent__c,Back_up_Dedicated_Agent__c from Client_Case_Assignments__c where Id in:keyClientIdstoquery]);
                }
                if(!shipmentNumberSet.isEmpty()){
                    for (Shipment__c shipment : [SELECT Id, IsShortShipped__c, Shipment_Number__c FROM Shipment__c WHERE Shipment_Number__c IN :shipmentNumberSet]) {
                            shipmentMap.put(shipment.Shipment_Number__c, shipment);
                        }
                    }
                
            }
            String deliveryChannel = General_Key_Value_Configurations__mdt.getInstance('Delivery_Channel').first_field_value__c;
            Map<Id,Case> twillCaseMap=new Map<Id,Case>();
            for(Id csId : caseIdToIntegrationResultsMap.keyset()){
                Case cs = new Case();
                cs.Id = csId;
                for(Integration_Results__c inres : caseIdToIntegrationResultsMap.get(csId)){
                    if(inres.Operation_Name__c == 'Sentiment Analysis'){
                        processSentimentResponse(inres.Response__c, cs, errorList);
                    }else if(inres.Operation_Name__c == 'Shipment Summary'){
                        processShipmentSummaryResponse(inres.Response__c,cs, errorList);
                    }else if(inres.Operation_Name__c == 'Short transit'){
                        processShipmentReferenceResponse(inres.Response__c,cs,caseMap, shipmentsToUpdateList, shipmentMap, errorList);
                    }else if(inres.Operation_Name__c == 'IDA Classification'){
                        processCaseClassificationResponse(inres.Response__c, cs, caseMap, caseListToOmniRoute, omniOriginList, errorList);
                    }else if(inres.Operation_Name__c == 'Break bulk'){
                        processBreakBulkResponse(inres.Response__c, cs, errorList);
                    }
                }
                csListToUpdate.add(cs);
                /*for translation of the cases*/
                if(deliveryChannel!=null && cs!=null && cs.Id!=null && caseMap.get(cs.Id).Delivery_Channel__c!=null &&
                    deliveryChannel.containsignorecase(caseMap.get(cs.Id).Delivery_Channel__c) &&
                    (String.isBlank(cs.Language)  ||(cs.Language!=null && //either language is null or its not english
                                          !cs.Language.contains('en_US'))
                    )&&
                    !String.isBlank(caseMap.get(cs.Id).Description))
                {
                    cs.Description=caseMap.get(cs.Id).Description;
                    twillCaseMap.put(cs.id,cs);
                }
                /*end of for translation of the cases*/
            }
            if(!caseListToOmniRoute.isEmpty()){
                CaseOmniSkillBasedRouting.defineCaseSkillMap(caseListToOmniRoute, mapRelatedCareRelation,mapKeyClientIds, false, false, caseMap, caseMapToUpdate);
            }
            
            if(!csListToUpdate.isEmpty() && !caseMapToUpdate.isEmpty()){
                for(Case cs : csListToUpdate){
                    if(caseMapToUpdate.containsKey(cs.Id)){
                        cs.Omni_Skill_Type__c = caseMapToUpdate.get(cs.Id).Omni_Skill_Type__c;
                    }
                }
            }
            
            if(!csListToUpdate.isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                update csListToUpdate;
                TriggerExecutionController.skipCaseTrigger(false);
            }
            if (!shipmentsToUpdateList.isEmpty()) {
                update shipmentsToUpdateList;
            }
            if(!errorList.isEmpty()){
                insert errorList;
            }
            if(!twillCaseMap.isEmpty()){
                //call to enqueue;
                System.enqueueJob(new CaseTranslatorQueuable(twillCaseMap));
            }
        }catch(Exception e){
            if(!String.isBlank(e.getMessage()) && !e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'IntegrationStagingTriggerHelper.processIntegrationResult' , new list<Exception>{e});  
            }
        }
    }
    
    /** 
    * @description | process Sentiment Response
    * @param response accepts response
    * @param cs accepts Case
    * @param errorList accepts Batch_Error_Logger__c list
    */
    public static void processSentimentResponse(String response, Case cs, List<Batch_Error_Logger__c> errorList){
        try{
            if(!String.isEmpty(response)){
                String sentiment;
                Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response);
                List<Object> lstDocs = (List<Object>) mapResponse.get('documents');
                if(!lstDocs.isEmpty() && lstDocs.size()>0){
                    for(Object obj: lstDocs){
                        Map<String,Object> data = (Map<String,Object>)obj;
                        String azSent = (String)data.get('sentiment'); 
                        sentiment = azSent == 'Mixed' ? 'Negative' : azSent;
                    }
                }               
                if(sentiment != Null){  
                    cs.Sentiment_Analysis__c = sentiment; 
                    cs.SentimentAnalysis_By_Api__c = sentiment;
                }
            }
        }catch(Exception e){
            errorList.add(getGlobalErrorLogger('SFDC', 'Case', 'IntegrationStagingTriggerHelper.processSentimentResponse', e.getTypeName()+' '+cs.Id, e.getMessage(), e.getStackTraceString()));
        }
    }
    
    /** 
    * @description | process Shipment Summary Response
    * @param response accepts response
    * @param cs accepts Case
    * @param errorList accepts Batch_Error_Logger__c list
    */
    public static void processShipmentSummaryResponse(String response, Case cs, List<Batch_Error_Logger__c> errorList){
        try{
            if(!String.isEmpty(response)){
                Boolean isdangerous = false;
                Boolean isOOG = false;
                Boolean isReefer = false;
                ShipmentSummaryWrapper shipsummarywrap = (ShipmentSummaryWrapper)JSON.deserialize(response, ShipmentSummaryWrapper.class); 
                isdangerous = !String.isBlank(shipsummarywrap.shipmentSummary.header.isDangerous) ? Boolean.valueOf(shipsummarywrap.shipmentSummary.header.isDangerous) : false;
                isOOG = !String.isBlank(shipsummarywrap.shipmentSummary.header.isOOG) ? Boolean.valueOf(shipsummarywrap.shipmentSummary.header.isOOG) : false;
                isReefer = !String.isBlank(shipsummarywrap.shipmentSummary.header.isReefer) ? Boolean.valueOf(shipsummarywrap.shipmentSummary.header.isReefer) : false;
                if(isDangerous){
                    cs.Cargo_Type__c = 'Dangerous Cargo';
                }else if(isOOG){									//SC-8631
                    cs.Cargo_Type__c = 'Out-of-gauge';
                }else if(isReefer){
                    cs.Cargo_Type__c = 'Reefer';
                }
                
                //SC-10045
                if(shipsummarywrap.shipmentSummary.transportRoutePlan != null && !shipsummarywrap.shipmentSummary.transportRoutePlan.isEmpty()){
					List<String> serviceNos = new List<String>();
                    for(ShipmentSummaryWrapper.TransportRoutePlan tp : shipsummarywrap.shipmentSummary.transportRoutePlan){
                        if(!String.isBlank(tp.service)){
                            serviceNos.add(tp.service);
                        }
                    }
                    if(!serviceNos.isEmpty()){
                        cs.Vessel_Service_Numbers__c = String.join(serviceNos, ',');
                    }                    
                }
            }
        }catch(Exception e){
            errorList.add(getGlobalErrorLogger('SFDC', 'Case', 'IntegrationStagingTriggerHelper.processShipmentSummaryResponse', e.getTypeName()+' '+cs.Id, e.getMessage(), e.getStackTraceString()));
        }
    }
    
    /** 
    * @description | process Break bulk Response
    * @param response accepts response
    * @param cs accepts Case
    * @param errorList accepts Batch_Error_Logger__c list
    * SC-8631 : Auto case assignment for Break Bulk
    */
    public static void processBreakBulkResponse(String response, Case cs, List<Batch_Error_Logger__c> errorList){
        try{
            if(!String.isEmpty(response)){
                String isBreakBulk = 'false';
                BreakBulkWrapper breakBulkWrap = (BreakBulkWrapper)JSON.deserialize(response, BreakBulkWrapper.class); 
                isBreakBulk = breakBulkWrap.isBreakBulk;
                if(isBreakBulk == 'true'){
                    cs.Cargo_Type__c = 'Break Bulk';
                }
            }
        }catch(Exception e){
            errorList.add(getGlobalErrorLogger('SFDC', 'Case', 'IntegrationStagingTriggerHelper.processBreakBulkResponse', e.getTypeName()+' '+cs.Id, e.getMessage(), e.getStackTraceString()));
        }
    }
    
    
    /** 
    * @description | process Shipment Reference API Response
    * @param response accepts response
    * @param cs accepts Case
    * @param caseMap accepts Case Map
    * @param shipmentsToUpdateList accepts  Shipment List 
    * @param shipmentMap accepts Shipment Map
    * @param errorList accepts Batch_Error_Logger__c list
    */
    
    public static void processShipmentReferenceResponse(String response, Case cs, Map<Id, Case> caseMap, List<Shipment__c> shipmentsToUpdateList, Map<String, Shipment__c> shipmentMap, List<Batch_Error_Logger__c> errorList){
        try{
            if(!String.isEmpty(response)){
                
                Boolean shortTransitIdentified = false;
                ShipmentReferenceWrapper shipmentWrapper = (ShipmentReferenceWrapper)JSON.deserialize(response, ShipmentReferenceWrapper.class);
                String shortSeaValue = shipmentWrapper.getShortSeaValue();
                if(!String.isBlank(shortSeaValue) && shortSeaValue.equalsIgnoreCase('Yes'))
                {
                    cs.Priority = 'High'; 
                    cs.Short_Transit__c = True;  
                    shortTransitIdentified = True;
                    if (!shipmentMap.isEmpty() && !String.isBlank(caseMap.get(cs.Id).Shipment_Number__c)) {
                        Shipment__c shipment = shipmentMap.get(caseMap.get(cs.Id).Shipment_Number__c);
                        shipment.IsShortShipped__c = true;
                        shipmentsToUpdateList.add(shipment);
                    }
                }
                else
                {
                    cs.Short_Transit__c = false;
                }
                if(shortTransitIdentified !=true && cs.Priority == 'High' && cs.Short_Transit__c == True ){
                    cs.Priority = 'Medium'; 
                    cs.Short_Transit__c = False;  
                }
                
            }}
        catch(Exception e){
            errorList.add(getGlobalErrorLogger('SFDC', 'Case', 'IntegrationStagingTriggerHelper.processShipmentReferenceResponse', e.getTypeName()+' '+cs.Id, e.getMessage(), e.getStackTraceString()));
        }
    }
    
    /** 
    * @description | process Case Classification Response
    * @param response accepts response
    * @param cs accepts Case
    * @param caseMap accepts Case map
    * @param caseListToOmniRoute accepts Case list
    * @param omniOriginList accepts omni origins list
    * @param errorList accepts Batch_Error_Logger__c list
    */
    public static void processCaseClassificationResponse(String response, Case cs, Map<Id, Case> caseMap, List<Case> caseListToOmniRoute, List<String> omniOriginList, List<Batch_Error_Logger__c> errorList){
        String slaWait;
        try{
           //SC-8580 
           Set<String> countryList = new Set<String>();
           Map<String, list<String>> countrySubTypeMap = new Map<String, list<String>>();
           Id externalCaseRTId = Label.External_Case_RT_Id;
           if(!String.isBlank(caseMap.get(cs.Id).Delivery_Channel__c) && deliveryChannel.contains(caseMap.get(cs.Id).Delivery_Channel__c) && caseMap.get(cs.Id).Country__c != null){
             for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c From General_Key_Value_Configurations__mdt where key__c != null AND key__c = :caseMap.get(cs.Id).country__r.name ] ){
                if(!String.isEmpty(gen.First_Field_Value__c) && !countrySubTypeMap.isEmpty() && countrySubTypeMap.containsKey(gen.key__c)){
                   countrySubTypeMap.get(gen.key__c).addAll(gen.First_Field_Value__c.trim().split(','));
                }else if(!String.isEmpty(gen.First_Field_Value__c)){
                   countrySubTypeMap.put(gen.key__c, gen.First_Field_Value__c.trim().split(','));
                }
             }
           }
            if(!String.isEmpty(response)){
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
                Map<String,String> mapSupTypetoType = CaseFieldPopulator.createSubTypeTypeMap();
                List<Object> listResult = (List<Object>) mapResponse.get('Results'); 
                
                if(listResult != null && listResult.size() > 0){
                    for(Object obj : listResult){
                        Map<String, Object> data = (Map<String, Object>)obj;
                        String caseNumber = (String)data.get('Case_number');
                        String type = (String)data.get('Type');
                        String subType = (String)data.get('Sub_Type');
                        String product = (String)data.get('Product');
                        String rfc = (String)data.get('Reason_For_Case');
                        String language = (String)data.get('Language');
                        slaWait = (String)data.get('slaWait');
                        if(!String.isEmpty(subType) && !String.isEmpty(type)){
                            cs.Custom_SubType__c = subType;                                   
                            cs.Type = type; 
                            cs.Custom_Type__c = type;
                            cs.Language = language; 
                            cs.Sub_Type__c = subType;
                            cs.SubType_Updated_At__c = System.now();
                            if(!String.isEmpty(product)){
                                cs.Product__c = product; //SC-6639
                            }
                            //SC-8816
                            if(!caseMap.isEmpty() && caseMap.containsKey(cs.Id) && caseMap.get(cs.Id).Status == 'New' && !String.isEmpty(cs.Type) && !String.isEmpty(cs.Sub_Type__c) && (!cs.MLL__c || (cs.MLL__c && !String.isEmpty(cs.Cargo_Classification__c)))){
                                cs.Status = 'Triaged';
                            }
                            //SC-8404
                            if(String.isNotBlank(rfc)){
                                cs.Reason_For_Case__c = rfc;
                                cs.Custom_ReasonForCase__c = rfc;
                            }
                            
                            //SC-8580
                            if(caseMap.get(cs.Id).Country__c != null && !String.isBlank(cs.Sub_Type__c) && !countrySubTypeMap.isEmpty() && countrySubTypeMap.containsKey(caseMap.get(cs.Id).Country__r.name) && !countrySubTypeMap.get(caseMap.get(cs.Id).Country__r.name).contains(cs.Sub_type__c)){
                               cs.Cluster_CSCE__c = true;
                            }
                           
                        }
                    }    
                }
            }
            //SC-SC-10138 Auto Close Spam Cases
            if(caseMap.containskey(cs.id)){	
                Integer defaultTime=8;
                Case c=caseMap.get(cs.id);
            	if(cs.Type == 'Non-Case' && cs.Status !='Closed - Not a Case' && c.recordtypeid == externalCaseRTId && cs.Product__c !='Ocean' && UserInfo.getUserName().contains('system.owner@maersk.com')){
                        system.debug('auto closure started');
                        List<Case> lstcasetoUpdate = new List<Case>();
                        Map<String,Maersk_Admin_Configuration__c> Mapautoclosure=new Map<String,Maersk_Admin_Configuration__c>();
                        List<Maersk_Admin_Configuration__c> lstMapautoclosure = new List<Maersk_Admin_Configuration__c>();
                        for(Maersk_Admin_Configuration__c autoclousre:[Select id,Area__c,Type__c,Sub_Type__c,Reason_For_Case__c,Business_Hour__c,Case_Accepted_by_user__c,Excluded_4PL_Identifier__c,Excluded_Country__c from Maersk_Admin_Configuration__c where recordtypeid='0120D000000BLdvQAG']){
                            Mapautoclosure.put(autoclousre.Area__c, autoclousre);
                            lstMapautoclosure.add(autoclousre);
                            system.debug('1st for'+Mapautoclosure);
                        }
                            system.debug('checking'+c.Cluster__c);
                            system.debug('2nd for'+ Mapautoclosure.get(c.Cluster__c));

            
                            
                            if(c.Cluster__c!=null && Mapautoclosure.containskey(c.Cluster__c))
                            {	
                                system.debug('3rd if');
                                Maersk_Admin_Configuration__c mac = Mapautoclosure.get(c.Cluster__c);
                                system.debug('mac rfc'+mac.Reason_For_Case__c);
                                 if((mac.Sub_Type__c == null || (cs.Sub_Type__c!= null && mac.Sub_Type__c.split(';').contains(cs.Sub_Type__c))) &&
                                    (mac.Reason_For_Case__c == null || (cs.Reason_For_Case__c!= null && mac.Reason_For_Case__c.split(';').contains(cs.Reason_For_Case__c))) &&
                                    (mac.Case_Accepted_by_user__c || String.valueof(c.OwnerId).startswith('OOG')) &&
                                    ((mac.Excluded_4PL_Identifier__c == null) || (mac.Excluded_Country__c!=null && !mac.Excluded_4PL_Identifier__c.contains(c.SF_4PL_Account__c) && !mac.Excluded_Country__c.contains(c.Case_Country__c))))
                                    {	
                                        system.debug('inside final if');
                                        cs.Auto_Closure_Time__c = System.now().addHours(Integer.valueof(Mapautoclosure.get(c.Cluster__c).Business_Hour__c));
                                     }
                              }
                    
                    		if(c.Cluster__c!=null && !Mapautoclosure.containskey(c.Cluster__c))
                            {
                                cs.Auto_Closure_Time__c = System.now().addHours(defaultTime);
                            }
   
                          
                    }
            }
        }catch(Exception e){
            errorList.add(getGlobalErrorLogger('SFDC', 'Case', 'IntegrationStagingTriggerHelper.processCaseClassificationResponse', e.getTypeName()+' '+cs.Id, e.getMessage(), e.getStackTraceString()));
        }
        
        // Route by invoking Omni Method   
        //SC-6165 Exclude Omni channel routing
        Case csOmniRoute = !caseMap.isEmpty() && caseMap.containsKey(cs.Id) ? caseMap.get(cs.Id) : null;
        if(slaWait == 'No' && csOmniRoute != null && !omniOriginList.isEmpty() && !String.isEmpty(csOmniRoute.Origin) && omniOriginList.contains(csOmniRoute.Origin) && csOmniRoute.Case_Channel__c == 'E-mail'  && !(string.isnotblank(csOmniRoute.Delivery_Channel__c) && deliveryChannel.containsIgnoreCase(csOmniRoute.Delivery_Channel__c) && cs.Cluster_CSCE__c)){
            cs.OwnerId = csOmniRoute.OwnerId;
            cs.Origin = csOmniRoute.Origin;
            cs.Subject = csOmniRoute.Subject;
            cs.Description = csOmniRoute.Description;
            cs.Case_Channel__c = csOmniRoute.Case_Channel__c;
            cs.Shipment_Number__c = csOmniRoute.Shipment_Number__c;
            cs.Care_Relationship__c = csOmniRoute.Care_Relationship__c;
            cs.Omni_Skill_Type__c = csOmniRoute.Omni_Skill_Type__c;
            cs.Value_Proposition__c = csOmniRoute.Value_Proposition__c;
            cs.Delivery_Channel__c = csOmniRoute.Delivery_Channel__c;
            cs.country__c = csOmniRoute.country__c;
            cs.Cargo_Flow__c = csOmniRoute.Cargo_Flow__c;
            cs.Cargo_Flow__c = csOmniRoute.Cargo_Flow__c;
            cs.Direction__c = csOmniRoute.Direction__c;
            cs.On_Behalf_Account__c = csOmniRoute.On_Behalf_Account__c;
            cs.AccountId = csOmniRoute.AccountId;
            cs.Vessel_Service_Numbers__c = !String.isBlank(cs.Vessel_Service_Numbers__c) ? cs.Vessel_Service_Numbers__c : csOmniRoute.Vessel_Service_Numbers__c;
            caselistToOmniRoute.add(cs);
        }
		
	if(String.isBlank(cs.Type) && String.isBlank(cs.Sub_Type__c)){
            cs.EntitlementId = Label.Default_Entitlement_Id;
        }
    }
    
    /** 
    * @description | Get global error logger
    * @param strSourceSystem accepts strSourceSystem
    * @param strObjectName accepts strObjectName
    * @param strMethodName accepts strMethodName
    * @param strExceptionCode accepts strExceptionCode
    * @param strExceptionSummary accepts strExceptionSummary
    * @param strExceptionDetails accepts strExceptionDetails
    * @return Batch_Error_Logger__c
    */
    public static Batch_Error_Logger__c getGlobalErrorLogger(String strSourceSystem, String strObjectName, String strMethodName, String strExceptionCode, String strExceptionSummary, String strExceptionDetails) {
        Batch_Error_Logger__c globalErrorLogger = new Batch_Error_Logger__c();
        String nameString = (String.isBlank(strSourceSystem) ? System.label.Default_Error_Logger_Category : (String.isBlank(strObjectName) ? strSourceSystem : strSourceSystem + ':' + strObjectName));
        globalErrorLogger.Name = nameString.left(55) + ' - ' + System.now().format();
        globalErrorLogger.Source_System__c = strSourceSystem;
        globalErrorLogger.Object__c = strObjectName;
        globalErrorLogger.Batch_Name__c = strMethodName;
        globalErrorLogger.Operation_Type__c = 'Execution Error';
        globalErrorLogger.Exception_Code__c = strExceptionCode;
        if(!String.isBlank(strExceptionSummary)) {
            globalErrorLogger.Exception_Summary__c = strExceptionSummary.left(254);
        }
        globalErrorLogger.Exception_Detail__c = strExceptionDetails;
        return globalErrorLogger;
    }
    
}