public class caseAutoResolution implements Queueable,Database.AllowsCallouts {
    //public String responseAutoRes; 
    public List<string> recordIds; 
    public string newstr = 'NA';
    
    //public caseAutoResolution (String responseAutoRes, List<string> recordIds) {  
    //com public caseAutoResolution (List<string> recordIds) {  
        //this.responseAutoRes=responseAutoRes;
    //com     this.recordIds=recordIds;
    //com     system.debug('inside constructor'+recordIds);     
        
    //com }
    
    public void execute(QueueableContext context) {
        system.debug('In the Execute method');
        
        map<String,Case> shipmentNoMap= new map<String,Case>();
        try{
            for(Case cse: [select id,account.Name,account.SCV_Code__c,casenumber,automation_entities__c,Topic__c,Liner_Brand__c,Shipment_Number__c from case where id ='5000D00000BzESIQA3']){
                String[] shipmentNo = (cse.automation_entities__c).split(',');
                for(String shpno:shipmentNo){
                    shipmentNoMap.put(shpno,cse);        
                }
            }   
            system.debug('@@shipmentNoMap'+shipmentNoMap);
            Boolean sendEmail = false;
            List<Automation_Topic_Rule__c> atrlist= [Select id,Automation_Rule__r.Rule_Name__c,Automation_Rule__r.Response_mapping__c,Automation_Rule__r.Failure_Message__c,Automation_Rule__r.Party_Data__c,Automation_Topic__r.name,Automation_Rule__r.is_Normal_Flow__c,Automation_Rule__r.Integration_API_details__c,Automation_Rule__r.Rule_Condition__c,Automation_Rule__r.Rule_Response__c,Automation_Rule__r.API_Details__c,Automation_Topic__r.Topic_Description__c from Automation_Topic_Rule__c where status__c='Active' AND Automation_Rule__r.Status__c ='Active' Order By Automation_Topic__r.Topic_Description__c ASC,Sequence__c ASC];
            string uimapResult = '';
            map<string,string> shpnumResultMap = new map<string,string>();
            map<string,string> caseResultMap = new map<string,string>();
            for(String shpNum:shipmentNoMap.keySet()){
                string operator = BrandUtilities.getBrandOperatorCode(shipmentNoMap.get(shpnum).Liner_Brand__c).toUpperCase();
                string brand= BrandUtilities.getBrandShortForm(shipmentNoMap.get(shpnum).Liner_Brand__c);
                system.debug('@@operator'+operator);
                system.debug('@@brand'+brand);
                String SumRes=ShipmentSummary.getShipmentSummary(shpnum); 
                String taskRes = (String)GcssTasksController.getGcssTasksDetails(shpnum,operator);
                String xmlString= (String)TransportDocumentServiceController.getTransportDocumentDetailsRes(shpnum);
                system.debug(shpnum+':'+shipmentNoMap.get(shpnum).account.SCV_Code__c+':'+operator);
                String invoiceString=(string)InvoiceDetailsController.getInvoiceDetails('',shpnum,shipmentNoMap.get(shpnum).account.SCV_Code__c,'PAID',operator);
                for(Automation_Topic_Rule__c atr:atrlist){
                    if(atr.Automation_Topic__r.Topic_Description__c==shipmentNoMap.get(shpnum).Topic__c){
                        if(atr.Automation_Rule__r.API_Details__c=='Shipment Summary'){
                            system.debug('Inside Shipment');
                            if(atr.Automation_Rule__r.is_Normal_Flow__c){
                                uimapResult = isNormalFlow(SumRes,atr,shipmentNoMap.get(shpnum),operator,brand);
                            }
                        }else if(atr.Automation_Rule__r.API_Details__c=='GCSS Tasks'){
                            system.debug('Inside GCSS Tasks');
                            if(atr.Automation_Rule__r.is_Normal_Flow__c){
                                uimapResult = isNormalFlow(taskRes,atr,shipmentNoMap.get(shpnum),operator,brand);
                            }
                        }else if(atr.Automation_Rule__r.API_Details__c=='TP Doc'){        
                            system.debug('Inside TP DOC');  
                            
                            //Converting XML to JSON
                            Dom.Document xmlDoc = new Dom.Document();  // Parse the XML string using Dom.Document
                            xmlDoc.load(xmlString);                                
                            Dom.XmlNode root = xmlDoc.getRootElement();   // Get the root element of the XML                                
                            String jsonString = convertXmlToJson(root);   // Convert XML to JSON                
                            System.debug('jsonString@@'+jsonString);
                            
                            jsonString = jsonString.replaceAll('[\\x00-\\x1F]', '');   //Remove white spaces to form a valid JSON Structure
                            
                            //Appending TransportDocumentParty with occurrence. Ex: TransportDocumentParty1, TransportDocumentParty2 and so on
                            String subStr = 'TransportDocumentParty'; 
                            Integer occurrences = 0;
                            Integer index = -1;
                            while ((index = jsonString.indexOf(subStr, index + 1)) != -1) {
                                String followingCharacters = jsonString.substring(index + subStr.length());
                                if (followingCharacters.length() > 0 && followingCharacters.substring(0, 1).isAlpha()) {
                                    continue;
                                }
                                occurrences++;
                                jsonString = jsonString.substring(0, index) + subStr + occurrences + jsonString.substring(index + subStr.length());
                            }
                            System.debug('jsonString@@'+jsonString);
                            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                            system.debug('jsonData@@'+jsonData);      
                            /*if(atr.Automation_Rule__r.Party_Data__c!=''){
                                List<party__c> partyDetailslist = new List<party__c>();
                                List<String> partylist=atr.Automation_Rule__r.Party_Data__c.split('==');
                                String partyName = partylist[0].trim();
                                String partyValue = partylist[1].trim();
                                if(partyValue.contains('caseAccountName')){
                                    partyValue=shipmentNoMap.get(shpnum).account.SCV_Code__c;
                                }
                                partyDetailslist = [Select id,party_role_type_name__c,Shipment_Number__c,Customer_Name__c from party__c where party_role_type_name__c =:partyName and Shipment_Number__c IN: shipmentNoMap.keySet()];
                                If(partyDetailslist!=null && !partyDetailslist.isEmpty()){
                                    for(party__c pty:partyDetailslist){
                                        if(pty.Scv_Customer_Code__c ==partyValue){
                                            uimapResult= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                        }else{
                                            uimapResult= atr.Automation_Rule__r.Rule_Name__c + ':false';
                                        }
                                    }                                    
                                }else{
                                    uimapResult = tpDocDetails(jsonData,atr,shipmentNoMap.get(shpnum).account.name);    
                                }
                            }else{ */
                                uimapResult = isNormalFlow(jsonString,atr,shipmentNoMap.get(shpnum),operator,brand);
                            //}               
                        }else if(atr.Automation_Rule__r.API_Details__c=='Invoice'){
                            system.debug('Inside Invoice');
                            if(atr.Automation_Rule__r.is_Normal_Flow__c){
                                uimapResult = isNormalFlow(invoiceString,atr,shipmentNoMap.get(shpnum),operator,brand);
                            }
                        }                    
                        system.debug('rak uimapResult'+atr.Automation_rule__r.rule_name__c + '@@' +uimapResult);   
                        if(uimapResult!=''){
                            List<String> conditionParts = uimapResult.split(':');
                            String fieldName = conditionParts[0].trim();
                            String fieldValue = conditionParts[1].trim();
                            String fieldMsg = atr.Automation_Rule__r.Failure_Message__c;
                            newstr=newstr+shpNum+','+fieldName+','+fieldValue+','+fieldMsg+'@';
                            if(fieldValue!= null && fieldValue== 'false'){
                                system.debug('@@false');
                                shpnumResultMap.put(shpnum,shipmentNoMap.get(shpnum).id);
                                caseResultMap.put(shpnum,newstr);
                                //break; //uncommented to test
                            }
                        }
                    }
                }                       
                
                if(shpnumResultMap!=null){
                    CustomNBARecommendation.getRecommendations(shipmentNoMap.get(shpnum).Id,'Case');
                }
                
                // Send email
                if(sendEmail == true){
                    EnhancedLetterhead letterHeadValue = [SELECT Id, LetterheadFooter,LetterheadHeader FROM EnhancedLetterhead WHERE Id = '0Rn7E000000DP6ASAW' LIMIT 1];
                    system.debug('letterHeadValue :'+letterHeadValue);            
                    String HTMLBody = String.valueOf(letterHeadValue.LetterheadHeader) + '<br/>';
                    HTMLBody+= 'Hello {!Case.CaseNumber} <br/>';
                    HTMLBody+= String.valueOf(letterHeadValue.LetterheadFooter);           
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTreatBodiesAsTemplate(true);
                    message.setHtmlBody(HTMLBody);
                    message.setSubject('{!Case.Subject}');
                    message.setWhatId('5007E00000DCk9yQAD'); //Remove case#
                    message.toAddresses = new String[] {'nraksha299@gmail.com'};
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                }   
            }

            List<Case_Recommendation__c> caseRecLstToUpdt  = new List<Case_Recommendation__c>();
            List<Case_Recommendation__c> caseRecLstToInsrt  = new List<Case_Recommendation__c>();
            map<string,string> caseRecMap= new map<string,string>();
            if(!shpnumResultMap.isEmpty()){
                List<Case_Recommendation__c> existngCaseRecomndtn = [select id,Recommendation_Name__c,Recommendation_Id__c,Description__c,Priority__c,Case__c,Action_Status__c,Rejected_Reason__c,Result_Summary__c,Shipment_No__c from  Case_Recommendation__c where Shipment_No__c IN:shpnumResultMap.keySet() and case__c IN:shpnumResultMap.Values()];
                for(Case_Recommendation__c extrec:existngCaseRecomndtn){
                    system.debug('@@inside update');
                    extrec.Result_Summary__c=caseResultMap.get(extrec.Shipment_No__c).replace('NA','').removeEnd('@');
                    caseRecLstToUpdt.add(extrec);
                    caseRecMap.put(extrec.Shipment_No__c,extrec.case__c);
                }

                if(shpnumResultMap.size()!=caseRecMap.size()){
                    String nbaRecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NBA Recommendation').getRecordTypeId();
                    for(string shp:shpnumResultMap.keySet()){
                        if (!caseRecMap.containsKey(shp)) {
                            system.debug('@@existngCaseRecomndtn'+existngCaseRecomndtn);
                            Case_Recommendation__c RescaseRec = new Case_Recommendation__c();
                            RescaseRec.Description__c =  'Auto Resolution';
                            RescaseRec.Priority__c =  1;
                            RescaseRec.Case__c = shpnumResultMap.get(shp);  
                            //RescaseRec.Result_Summary__c=newstr.replace('NA','');   
                            RescaseRec.Result_Summary__c=caseResultMap.get(shp).replace('NA','').removeEnd('@');
                            RescaseRec.Shipment_No__c=shp;
                            RescaseRec.recordTypeId = nbaRecommRecTypeId; 
                            caseRecLstToInsrt.add(RescaseRec);
                        }
                    }
                }

                if(caseRecLstToUpdt.size() > 0){
                    system.debug('inside 1');
                    Database.update(caseRecLstToUpdt);                          
                }
                if(caseRecLstToInsrt.size() > 0){
                    system.debug('inside 2');
                    Database.insert(caseRecLstToInsrt);
                }
                system.debug('@@caseRecLstToUpdt'+caseRecLstToUpdt);         
                system.debug('@@caseRecLstToInsrt'+caseRecLstToInsrt);     
            } 
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseAutoResolution.execute ' +recordIds , new list<Exception>{ex});  
        }         
    }    
    
    // Helper method to convert XML to JSON recursively
    public static String convertXmlToJson(Dom.XmlNode node) {
        if (node == null) {
            return '';
        }
        
        String jsonString = '{';
        List<String> elements = new List<String>();
        
        for (Dom.XmlNode child : node.getChildElements()) {
            String key = '"' + child.getName() + '"';
            String value = '';
            
            if (child.getChildElements().size() > 0) {
                // Recursively convert child elements to JSON
                value = convertXmlToJson(child);
            } else {
                // Convert leaf node value to JSON string
                value = '"' + child.getText() + '"';
            }
            
            elements.add(key + ':' + value);
        }
        
        jsonString += String.join(elements, ',') + '}';
        return jsonString;
    }
    
    public static string fetchTPDoc(Map<String, Object> data, Automation_Topic_Rule__c autotopicrule, string cs) {    
        system.debug('@@autotopicrule'+autotopicrule);
        system.debug('@@cs'+cs);
        Automation_Topic_Rule__c atr= autotopicrule;
        system.debug('@@atr'+atr);
        if (data.containsKey('TransportDocumentPartyRole')) {
            Map<String, Object> TransportDocumentPartyRole = (Map<String, Object>) data.get('TransportDocumentPartyRole');
            Map<String, Object> PartyRoleType = (Map<String, Object>) TransportDocumentPartyRole.get('PartyRoleType');
            Map<String, Object> PartyRole = (Map<String, Object>) TransportDocumentPartyRole.get('PartyRole');
            Map<String, Object> Party = (Map<String, Object>) PartyRole.get('Party'); 
            system.debug('val  get1 '+PartyRoleType.get('PartyRoleTypeName'));   
            system.debug('val  get2 '+Party.get('PartyName'));   
            if((PartyRoleType.get('PartyRoleTypeName')==atr.Automation_Rule__r.Rule_Response__c) && (Party.get('PartyName') == cs)){
                system.debug('@@rak rule4 Pass: TP Doc Rule4 Passed');  
                return atr.Automation_Rule__r.Rule_Name__c + ':true';
            }
            
        } else {
            for (Object value : data.values()) {
                if (value instanceof Map<String, Object>) {
                    fetchTPDoc((Map<String, Object>) value,autotopicrule,cs);
                } else if (value instanceof List<Object>) {
                    for (Object item : (List<Object>) value) {
                        if (item instanceof Map<String, Object>) {
                            fetchTPDoc((Map<String, Object>) item,autotopicrule,cs);
                        }
                    }
                }
            }
        }    
        return atr.Automation_Rule__r.Rule_Name__c + ':false';
    }
    
    public static string isNormalFlow(String jsonString,Automation_Topic_Rule__c atr,Case cs,String operator,String brand) {
        string outcome='';
        system.debug('inside Object flow'+jsonString);
        system.debug('Case cs'+cs);
        system.debug('Case cs account name'+cs.Account.Name);
        string accName=cs.Account.Name;
        string accSCV=cs.account.SCV_Code__c;
        String Value;
        if(!jsonString.containsIgnoreCase('Read timed out')){            
            Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
            string fetchValue= atr.Automation_Rule__r.Response_mapping__c;
            //String fetchValue = 'tasks.taskName==Review Notification2 ? tasks.statusId==5';
            if(fetchValue.contains('caseAccountName')){
                if(accName!=null){
                    fetchValue = fetchValue.replace('caseAccountName', accName);
                }else{
                    fetchValue = fetchValue.replace('caseAccountName', '');
                }
            }
            if(fetchValue.contains('BrandShortForm')){
                fetchValue = fetchValue.replace('BrandShortForm', brand);
            }
            system.debug('fetchValue'+fetchValue);    
            List<String> andconditions = fetchValue.split('\\?');
            List<String> conditions = new List<String>();
            conditions.add(andconditions[0].trim());
            List<String> laterconditions = new List<String>();
            if(fetchValue.contains('?')){
                laterconditions.add(andconditions[1].trim());
            }
            system.debug('laterconditions'+laterconditions);    
            for (String condition : conditions) {
                List<String> conditionParts = condition.split('==');
                String fieldName = conditionParts[0].trim();
                String expectedValue = conditionParts[1].trim();
                system.debug('fieldName-->'+fieldName);     
                system.debug('expectedValue-->'+expectedValue);     
                Object result = jsonMap;
                system.debug('result-->'+result);     
                List<String> keys = fieldName.split('\\.');
                for (String key : keys) {
                    system.debug('key-->'+key);     
                    if (result instanceof Map<String, Object>) {
                        system.debug('inside if');     
                        result = ((Map<String, Object>)result).get(key);
                        system.debug('result-->'+result);   
                        if(String.valueOf(result) == expectedValue){        
                            system.debug('rak rule pass'+atr.Automation_Rule__r.Rule_Name__c);  
                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                            break;
                        }else{
                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                            system.debug('In the elsee');
                        }  
                    } 
                    else if (result instanceof List<Object>) {
                        system.debug('in else if'+ result);
                        List<Object> currentList = (List<Object>) result;
                        result = null; 
                        If(currentList!=null && !currentList.isEmpty()){
                            for (Object item : currentList) {
                                system.debug('item'+ item);
                                if (item instanceof Map<String, Object>) {  //A. Here checking the logic if tasks.taskName==Send Prepaid Invoice Request. in the below 2 lines it will check if taskName=Send Prepaid Invoice Request. Segment value gives the current taskName the for loop is running and expectedvalue is the taskName mentioned on the rules field i.e., Send Prepaid Invoice Request      
                                    Object segmentValue = ((Map<String, Object>)item).get(key);      
                                    string seg=(string)segmentValue;             
                                    system.debug('segmentValue'+ segmentValue);
                                    system.debug('expectedValue'+ expectedValue);
                                    if(expectedValue.contains('datetime.now()')){
                                        Datetime Currentvalue= (Datetime)jSON.deserialize('"'+segmentValue+'"',Datetime.class);
                                        system.debug('Currentvalue'+Currentvalue);
                                        system.debug('datetime.now'+datetime.now());                                        
                                        if((Currentvalue).date() != (datetime.now()).date() && (Currentvalue).date() != (datetime.now()).date()-1){
                                            if(expectedValue.contains('<datetime.now()')){
                                                if (Currentvalue <datetime.now()){
                                                    system.debug('@@rak rule1 pass and date is less'); 
                                                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                                    //return false;
                                                }
                                            }else if(expectedValue.contains('>datetime.now()')){
                                                if (Currentvalue >datetime.now()){
                                                    system.debug('@@2rak rule1 pass and date is more'); 
                                                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                                    //return false;
                                                }
                                            }else if(expectedValue.contains('=datetime.now()')){
                                                if (Currentvalue ==datetime.now()){
                                                    system.debug('@@2rak rule1 pass and date is equal'); 
                                                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                                    //return false;
                                                }
                                            }
                                        }else{
                                            system.debug('@@rak rule1 pass and date is less'); 
                                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':' +Currentvalue;
                                        }
                                        break;
                                    }
                                    else if(expectedValue =='Invoice check'){
                                        system.debug('yesss');
                                        string invoice=InvoiceDetailsController.downloadInvoiceDetails(seg,accSCV,operator);
                                        if(invoice!=null){
                                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                        }else{
                                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                                        }                                   
                                    }
                                    else if (segmentValue != null && String.valueOf(segmentValue).equals(expectedValue)) { //If point A is satisfied then it comes here
                                        result = item;
                                        outcome = calculate(item,atr,cs,operator,brand,laterconditions,expectedValue);
                                        system.debug('result'+result);
                                        system.debug('laterconditions'+laterconditions);
                                        break; // Exit loop if condition is matched
                                    }else{
                                        outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                                    }
                                    system.debug('laterconditions'+laterconditions);                                        
                                }
                            }
                        }else{
                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                            system.debug('outcomeee'+outcome);
                        }
                    }else {
                        //Error handling scenarios
                        system.debug('in else'+key);
                    }
                }
            }
        }
        return outcome;
    }
    
    public static string calculate(object result,Automation_Topic_Rule__c atr,Case cs,String operator,String brand,List<String> laterconditions,String expectedValue){
        string outcomeval='';
        if(laterconditions!=null && !laterconditions.isEmpty()){
            for(string st:laterconditions){
                system.debug('st'+st);
                List<String> conditionPartsand = st.split('==');
                String fieldNameand = conditionPartsand[0].trim();
                String expectedValueand = conditionPartsand[1].trim();
                system.debug('fieldNameand'+fieldNameand);
                List<String> conditionPartskey = fieldNameand.split('\\.');
                String keyValueand = conditionPartskey[1].trim();
                Object segmentValueand = ((Map<String, Object>)result).get(keyValueand);
                system.debug('segmentValueand'+segmentValueand);
                system.debug('expectedValueand'+expectedValueand);
                if (segmentValueand != null && String.valueOf(segmentValueand).equals(expectedValueand)) {
                    system.debug('rak rule2,3 passed'+result);
                    outcomeval= atr.Automation_Rule__r.Rule_Name__c + ':true';
                }else{
                    outcomeval= atr.Automation_Rule__r.Rule_Name__c + ':false';
                    break;
                }
            }   
        }
        return outcomeval;
    }
    
    public static string tpDocDetails(Map<String, Object> jsonData,Automation_Topic_Rule__c atr,string cs){
        string outcomeval='';
        outcomeval=fetchTPDoc(jsonData,atr,cs);  
        return outcomeval;               
    }
    
    private static DateTime convertToOtherTimeZone(DateTime dttime, string sourceTimezone, string targetTimezone){
        TimeZone tz = Timezone.getTimeZone(sourceTimezone);
        Integer offset=tz.getOffset(dttime);
        
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone(targetTimezone);
        integer offsetTotargetTZ = targetTZ.getOffset(dttime);
        integer correction = offsetTotargetTZ- offset;
        
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        
        return targetDT;
    }
    //Convert Any DateTime to other timezone
    public static DateTime convertDateTimeToOtherTimeZone(DateTime dttime, string sourceTimezone, string targetTimezone){
        DateTime targetDT = convertToOtherTimeZone(dttime,sourceTimezone,targetTimezone);
        return DateTime.newInstance(targetDT.year(),targetDT.month(),targetDT.day(),targetDT.hour(), targetDT.minute(), targetDT.second());
    }
}