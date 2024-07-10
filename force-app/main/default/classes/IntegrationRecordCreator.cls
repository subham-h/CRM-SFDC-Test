/*
* Created By   : Shahanawaz@Maersk
* Purpose  : Integration record Creator class to make api calls for parallel API calls from case trigger. 
*              
* Revision Ref Number  	Date        	Owner                   Description
* -------- ----------  	----------- 	-------------------     -----------
* 1.0      #SC-8789   	22-Sept-2023  	Shahanawaz@Maersk		Created the class
* 2.0	   #SC-9545   	08-Jan-2024   	Vivek.agrawal@Maersk	Added extra paramter for updateCaseClassification api to receive correct language data from IDA
* 3.0      #SC-8937   	23-Jan-2024   	sandhya@Maersk			Added method to calculate Short Transit using reference API
* 4.0	   #SC-8631		24-Apr-2024		Kiran@Maersk			Auto Case Assignment - Ocean - based on Cargo types - Reefer, OOG, Break Bulk
* 5.0	   #SC-10045    14-May-2024	    Shahanawaz@maersk	    Store Vessel service numbers from shipment
*/
public class IntegrationRecordCreator {
    
    public static void createIntegrationRecord(Map<Id, Set<String>> caseOperations, String transactionName) {
        if(!caseOperations.isEmpty()){
            List<Integration_Staging__c> integrationStagingList = new List<Integration_Staging__c>();
            Map<Id, Integration_Staging__c> caseIdToIntegrationStagingMap = new Map<Id, Integration_Staging__c>();
            List<Integration_Results__c> integrationResultList = new List<Integration_Results__c>();
            
            for(Id caseId : caseOperations.keySet()){
                Set<String> operations = caseOperations.get(caseId);
                Integration_Staging__c integrationStaging = new Integration_Staging__c(
                    Related_Record_Id__c = caseId,
                    Transaction__c = transactionName, 
                    Operations__c = String.join(new List<String>(operations), ';'),
                    Operations_Count__c = operations.size()
                );
                integrationStagingList.add(integrationStaging);
            }
            if(!integrationStagingList.isEmpty()){
                insert integrationStagingList;
            }
            for(Integration_Staging__c ins : integrationStagingList){
                caseIdToIntegrationStagingMap.put(ins.Related_Record_Id__c, ins);
            }
            if(!caseIdToIntegrationStagingMap.isEmpty()){
                for(Id caseId : caseOperations.keySet()){
                    for(String operation : caseOperations.get(caseId)) {
                        Integration_Results__c integrationResult = new Integration_Results__c(
                            Integration_Staging__c = caseIdToIntegrationStagingMap.get(caseId).Id,
                            Operation_Name__c = operation,
                            Status__c = 'New' 
                        );
                        integrationResultList.add(integrationResult);
                    }
                }
            }
            if(!integrationResultList.isEmpty()){
                insert integrationResultList;
            }
        }
    }
    
    @future(callout=true)
    public static void updateSentimentOnCase(Id integrationResultId, Id insId, Id caseId, String language, String description){
        try{
            List<Sentiment_Language_Mapping__mdt> lstLangMapping = WebserviceUtilities.getLangMapping(language);
            String getLabelName = Label.Excluding_Signature_on_Sentiment_Analysis;
            List<String> signatureList = !String.isEmpty(getLabelName) ? getLabelName.split(';') : new List<String>();
            String reqBody = ''; 
            String sentiment;            
            description = description.stripHtmlTags();
            if(description != null && !signatureList.isEmpty()){
                for(String signatureName: signatureList){
                    if(description.contains(signatureName)){
                        description = description.substringBefore(signatureName);
                    }
                }
            }
            JSONGenerator jg = JSON.createGenerator(false); 
            jg.writeStartObject();
            jg.writeFieldName('documents');
            jg.writeStartArray();
            jg.writeStartObject();
            jg.writeStringField('id',caseId);
            if(lstLangMapping.size()>0 && lstLangMapping[0].Sentiment_Language_Code__c != null){
                jg.writeStringField('language', lstLangMapping[0].Sentiment_Language_Code__c);
            }      
            else{
                jg.writeStringField('language','en');   
            }
            jg.writeStringField('text',description.left(Integer.valueof(System.label.SentimentCharLimit)));            
            jg.writeEndObject();            
            jg.writeEndArray();
            jg.writeEndObject();
            reqBody=jg.getAsString();  
            String response = SentimentAnalysis.getSentimentScore(reqBody);
            Integration_Staging__c ins = [Select Id From Integration_Staging__c Where Id =: insId FOR UPDATE];
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            if(!String.isEmpty(response)){
                irToUpdate.Status_Code__c = '200';  
                irToUpdate.Response__c = response;
                irToUpdate.Status__c ='Success';
            }
            else{
                irToUpdate.Status__c ='Error';
            }
            update irToUpdate; 
        } catch(Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'Integration_Results__c', 'IntegrationRecordCreator.updateSentimentOnCase', new List<Exception>{ex});
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            irToUpdate.Status__c = 'Error';
            update irToUpdate;    
        }
    }
    
    @future(callout = true)
    public static void populateDangerousCargo(Id integrationResultId, Id insId, Id caseId, String shipmentNumber, String caseno){
        try{
            String response = '';
            String result = ShipmentSummary.getShipmentSummary(shipmentNumber);
            if(!String.isEmpty(result)){
                ShipmentSummaryWrapper shipmentSummaryWrap = (ShipmentSummaryWrapper)JSON.deserialize(result, ShipmentSummaryWrapper.class);
                if(shipmentSummaryWrap != null) {
                    response = JSON.serialize(shipmentSummaryWrap);
                }
            }
            Integration_Staging__c ins = [Select Id From Integration_Staging__c Where Id =: insId FOR UPDATE];
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            if(!String.isEmpty(response)){
                irToUpdate.Status_Code__c = '200';  
                irToUpdate.Response__c = response;

                irToUpdate.Status__c = 'Success';
            }
            else{
                irToUpdate.Status__c ='Error';
            }
            update irToUpdate;          
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case' +caseno, 'IntegrationRecordCreator.populateDangerousCargo' , new list<Exception>{ex});
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            irToUpdate.Status__c = 'Error';
            update irToUpdate;    
        }
    }
    
    @future(callout = true)
    public static void populateCargoTypeBreakBulk(Id integrationResultId, Id insId, Id caseId, String shipmentNumber, String Brand, String caseno){
        try{
            String response = '';
            String operator = BrandUtilities.getBrandOperatorCode(Brand);
            operator = operator.toUpperCase();
            String result = ShipmentSummary.getBreakBulkResponse(shipmentNumber, operator);
            if(!String.isEmpty(result)){
                BreakBulkWrapper breakBulkWrap = BreakBulkWrapper.parseBreakBulk(result);
                if(breakBulkWrap != null) {
                    response = JSON.serialize(breakBulkWrap);
                }
            }
            Integration_Staging__c ins = [Select Id From Integration_Staging__c Where Id =: insId FOR UPDATE];
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            if(!String.isEmpty(response)){
                irToUpdate.Status_Code__c = '200';  
                irToUpdate.Response__c = response;

                irToUpdate.Status__c = 'Success';
            }
            else{
                irToUpdate.Status__c ='Error';
            }
            update irToUpdate;          
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case' +caseno, 'IntegrationRecordCreator.populateCargoTypeBreakBulk' , new list<Exception>{ex});
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            irToUpdate.Status__c = 'Error';
            update irToUpdate;    
        }
    }
    
    @future(callout = true)
    public static void populateShortTransit(Id integrationResultId, Id insId, Id caseId, String shipmentNumber,String Brand, String caseno){
        try{
            String response = '';
            String operator = BrandUtilities.getBrandOperatorCode(Brand);
            operator = operator.toUpperCase();
            String result = (String)GetReferences.getShipmentReferences(shipmentNumber,operator);
            
            response = result;
            Integration_Staging__c ins = [Select Id From Integration_Staging__c Where Id =: insId FOR UPDATE];
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            if(!String.isEmpty(result)){
                irToUpdate.Status_Code__c = '200';  
                irToUpdate.Response__c = response;
                
                irToUpdate.Status__c = 'Success';
            }
            else{
                irToUpdate.Status__c ='Error';
            }
            update irToUpdate;          
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case' +caseno, 'IntegrationRecordCreator.populateShortTransit' , new list<Exception>{ex});
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            irToUpdate.Status__c = 'Error';
            update irToUpdate;    
        }
    }
    @future(callout = true)
    public static void updateCaseClassification(Id integrationResultId, Id insId, Set<Id> caseIds){
        List<String> lstCaseOrigins = New List<String>();
        List<Case> lstCase = new list<Case>();
        String response = '';
        
        try{  
            String slaWait;
            lstCase = [Select Id,CaseNumber,Subject,Description,Origin,Status,MLL__c,Cargo_Classification__c, Type,sub_type__c,Case_Channel__c,Case_Country__c,Shipment_Number__c,Care_Relationship__c,Omni_Skill_Type__c,Value_Proposition__c,Product__c,country__c,Account.Name,Account.SCV_Code__c from Case where id in:caseIds];
            Map<String,Case> mapCase = new Map<String,Case>();
            JSONGenerator jsn = JSON.createGenerator(false); 
            jsn.writeStartObject();
            jsn.writeFieldName('emails');
            jsn.writeStartArray();
            for(Case cs:lstCase){
                mapCase.put(cs.CaseNumber, cs);
                jsn.writeStartObject();
                if(cs.origin!= null){
                    jsn.writeStringField('origin',cs.Origin);
                }else{
                    jsn.writeStringField('origin','');
                }
                jsn.writeStringField('Subject',cs.Subject);
                jsn.writeStringField('Email_body',cs.Description);
                jsn.writeStringField('Case_number',cs.CaseNumber);
                if(cs.product__c != null){ //SC-6639
                    jsn.writeStringField('Product',cs.product__c);
                }else{//SC-7133
                    jsn.writeStringField('Product','');
                }
                //SC-8804
                if(cs.Account.Name!= null){
                    jsn.writeStringField('Case_Account_Name',cs.Account.Name);
                }else{
                    jsn.writeStringField('Case_Account_Name','');
                }
                if(cs.Account.SCV_Code__c!= null){
                    jsn.writeStringField('Case_Account_Scv',cs.Account.SCV_Code__c);
                }else{
                    jsn.writeStringField('Case_Account_Scv','');
                }
 				//SC-9545
                if(cs.Case_Country__c!= null){
                    jsn.writeStringField('Country',cs.Case_Country__c);
                }else{
                    jsn.writeStringField('Country','');
                }                
                jsn.writeEndObject();
                
            }
            jsn.writeEndArray();
            jsn.writeEndObject();
            String requestBody = jsn.getAsString();
            if(!mapCase.isEmpty()){
                response = CustomCaseClassificationAutoUpdate.getCaseClassification(requestBody,lstCase[0].CaseNumber,caseIds); 
                Integration_Staging__c ins = [Select Id, Wait_Status__c, Status_Updated_Time__c From Integration_Staging__c Where Id =: insId FOR UPDATE];
                Integration_Results__c irToUpdate = new Integration_Results__c();
                irToUpdate.Id = integrationResultId;
                if(!String.isEmpty(response)){
                    irToUpdate.Status_Code__c = '200';  
                    irToUpdate.Response__c = response;
                    irToUpdate.Status__c ='Success';
                    
                    Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
                    Map<String,String> mapSupTypetoType = CaseFieldPopulator.createSubTypeTypeMap();
                    List<Object> listResult = (List<Object>) mapResponse.get('Results'); 
                    if(listResult != null && listResult.size() > 0){
                        Map<String, Object> data = (Map<String, Object>)listResult[0];
                        slaWait = (String)data.get('slaWait');
                        if(slaWait == 'Yes'){
                            ins.Wait_Status__c = 'Wait';
                            ins.Status_Updated_Time__c = System.now();
                        }
                    }
                }
                else{
                    irToUpdate.Status__c ='Error';
                }
                if(slaWait == 'Yes'){
                    update ins;
                }
                update irToUpdate; 
            }
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'IntegrationRecordCreator.updateCaseClassification', new list<Exception>{ex});
            Integration_Results__c irToUpdate = new Integration_Results__c();
            irToUpdate.Id = integrationResultId;
            irToUpdate.Response__c = response;
            irToUpdate.Status__c = 'Error';
            update irToUpdate;
        }  
    }
}