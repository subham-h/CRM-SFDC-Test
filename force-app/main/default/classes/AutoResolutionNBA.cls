/**
* @description
* Author   : Raksha
* Purpose  : Created for providing Automated Resolution based on shipment number on case record page
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8359     16-06-2023  raksha.n@maersk.com     Created for Automated Resolution
*/
public with sharing class AutoResolutionNBA{    
    public static Boolean checkresult = false;
    public static String sumRes='';

    /** 
    * @description | Computation logic code below
    * @param recordId accepts current page recordId
    * @param shipmentNum accepts shipment number entered in the Search Field
    */
    @AuraEnabled
    public static List<FetchRuleName> fetchRecommendation(String recordId, String shipmentNum) {
        String resultstr = '';
        String strWhere='';
        map<String,Case> shipmentNoMap= new map<String,Case>();        
        list < FetchRuleName > wrapRuleName = new list < FetchRuleName > (); 
        List<party__c> partyDetailslist = new List<party__c>();
        List<Case_Recommendation__c> cserecList = new List<Case_Recommendation__c>();
        List<string> shipmentNo = new List<string>();
        string uimapResult = '';
        // map<string,string> operatorMap = new map<string,string>();
        string getbrand ='';
        string getop ='';
        map<string,string> shpnumResultMap = new map<string,string>();
        map<string,string> caseResultMap = new map<string,string>();
        map<string,string> addRuleMap = new map<string,string>();
        map<string,string> ruleMap = new map<string,string>();
        Boolean checkTpDocApi=false;
        List<Case_Recommendation__c> caseRecLstToUpdt  = new List<Case_Recommendation__c>();
        List<Case_Recommendation__c> caseRecLstToInsrt  = new List<Case_Recommendation__c>();
        map<string,string> caseRecMap= new map<string,string>();
        String jsonData1;
        List<Map<String, Object>> resultList = new List<Map<String, Object>>();
        Map<String, Object> finalResultMap = new Map<String, Object>();
        Map<String, List<Map<String, String>>> shipmentDetailsMap = new Map<String, List<Map<String, String>>>();
        try{
            Case cseDetail= [select id,SuppliedEmail,account.Name,account.SCV_Code__c,RecordTypeId,ContactId,Contact.Recordtype.DeveloperName,Case_Country__c,Status,Contact.Email,Product__c,Case_Channel__c,casenumber,Type,Sub_Type__c,Reason_For_Case__c,Topic__c,Liner_Brand__c,Shipment_Number__c,isRecommendationAvaialble__c,OwnerId,Subject from case where id =: recordId WITH SECURITY_ENFORCED];
            Map<String,Boolean> visibility = CustomNBARecommendation.NBAVisibility(new List<Case>{cseDetail});
            if(cseDetail <> null && cseDetail.Topic__c == 'Invoice' && cseDetail.Product__c == 'Ocean' && cseDetail.Contact.Recordtype.DeveloperName != 'Internal_Contact' && visibility.get('InternalContact') && cseDetail.recordtypeId == StaticFactory.getRecordTypeIdByName('Case',Label.External_Case) && cseDetail.Case_Channel__c=='E-mail'  && !(cseDetail.status.startswith('Closed'))){  //For NBA-Invoice
                if(shipmentNum == null){ //The shipment number on case is picked
                    if(String.isNotBlank(cseDetail.Shipment_Number__c)){
                            shipmentNo = (cseDetail.Shipment_Number__c).split(',');
                        }else{
                            FetchRuleName fetchrulewrap = new FetchRuleName();
                            fetchrulewrap.errormessage='No Task Information';
                            wrapRuleName.add(fetchrulewrap);
                            return wrapRuleName;
                        }
                    }else{
                        shipmentNo=shipmentNum.split(','); //The shipment number from Input is picked
                    }
                for(String shpno:shipmentNo){
                    shipmentNoMap.put(shpno,cseDetail);  
                    shipmentDetailsMap.put(shpno, new List<Map<String, String>>());      
                }

            Set<string> shipmntSet = shipmentNoMap.keySet(); 
            if(shipmntSet!=null && !shipmntSet.isEmpty()){
                if(shipmentNum == null){
                    strWhere='Shipment_No__c IN: shipmntSet and Shipment_Status__c=\'Default\'';
                }else{
                    strWhere='Shipment_No__c =:shipmentNum and Shipment_Status__c=\'Input\'';
                }
                if (Schema.sObjectType.Case_Recommendation__c.isAccessible()){
                    cserecList= Database.query('Select id,case__c,Result_Summary__c,Shipment_No__c,Shipment_Status__c from Case_Recommendation__c where case__c =:recordId and '+strWhere);            
                }
                partyDetailslist = [Select id,party_role_type_name__c,Shipment_Number__c,Customer_Name__c,Scv_Customer_Code__c from Party__c where Shipment_Number__c IN: shipmentNoMap.keySet() WITH SECURITY_ENFORCED];
            }            
            If(cserecList.isEmpty() && !shipmentNoMap.isEmpty()){
                if (Schema.sObjectType.Automation_Topic_Rule__c.isAccessible()){
                    List<Automation_Topic_Rule__c> atrlist= [Select id,Automation_Rule__r.Rule_Name__c,Automation_Rule__r.Type__c,Automation_Rule__r.Sub_Type__c,Automation_Rule__r.Reason_for_Case__c,Automation_Rule__r.Response_mapping__c,Automation_Rule__r.Failure_Message__c,Automation_Rule__r.Party_Data__c,Automation_Topic__r.name,Automation_Rule__r.is_Normal_Flow__c,Automation_Rule__r.Integration_API_details__c,Automation_Rule__r.Rule_Condition__c,Automation_Rule__r.Rule_Response__c,Automation_Rule__r.API_Details__c,Automation_Topic__r.Topic_Description__c from Automation_Topic_Rule__c where status__c='Active' AND Automation_Rule__r.Status__c ='Active' AND Automation_Topic__r.Topic_Description__c =:shipmentNoMap.values().Topic__c Order By Automation_Topic__r.Topic_Description__c ASC,Sequence__c ASC];
                    for(Automation_Topic_Rule__c atr:atrlist){
                        ruleMap.put(atr.Automation_rule__r.rule_name__c,'NA');                           
                    }
                
                    for(String shpNum:shipmentNoMap.keySet()){                   
                        getbrand=fetchOperator(shpnum);
                                                system.debug('getbrand'+getbrand);
                            if(getBrand == 'API Issue'){
                                returnErrorMsg(shpNum);
                            }
                            else if(getbrand!=null){
                                getop=BrandUtilities.getOperatorCodeBasedOnShortForm(getbrand).toUpperCase();
                            }else{
                            FetchRuleName fetchrulewrap = new FetchRuleName();
                            fetchrulewrap.shipmentNo= shpNum;
                            fetchrulewrap.errormessage='No data found';
                            wrapRuleName.add(fetchrulewrap);
                            return wrapRuleName;
                        }
                            String taskRes = (String)GcssTasksController.getGcssTasksDetails(shpnum,getop);
                            if(taskRes.containsIgnoreCase('Read timed out')){      
                                returnErrorMsg(shpNum);
                            }
                            String invoiceString=(string)InvoiceDetailsController.getInvoiceDetails('',shpnum,shipmentNoMap.get(shpnum).account.SCV_Code__c,'PAID',getop);                   
                            if(invoiceString.containsIgnoreCase('Read timed out')){      
                                returnErrorMsg(shpNum);
                            }
                        for(Automation_Topic_Rule__c atr:atrlist){ 
                            if((atr.Automation_Topic__r.Topic_Description__c==shipmentNoMap.get(shpnum).Topic__c && shipmentNoMap.get(shpnum).Topic__c!='Invoice')|| (atr.Automation_Topic__r.Topic_Description__c==shipmentNoMap.get(shpnum).Topic__c && shipmentNoMap.get(shpnum).Topic__c=='Invoice' && atr.Automation_Rule__r.Type__c.split(';').contains(shipmentNoMap.get(shpnum).Type) && atr.Automation_Rule__r.Sub_Type__c.split(';').contains(shipmentNoMap.get(shpnum).Sub_Type__c) && atr.Automation_Rule__r.Reason_for_case__c.split(';').contains(shipmentNoMap.get(shpnum).Reason_For_Case__c))){       
                                if(atr.Automation_Rule__r.API_Details__c=='Shipment Summary'){
                                    if(atr.Automation_Rule__r.is_Normal_Flow__c){
                                        uimapResult = isNormalFlow(sumRes,atr,shipmentNoMap.get(shpnum),getop,getbrand);
                                    }
                                }else if(atr.Automation_Rule__r.API_Details__c=='GCSS Tasks'){
                                    if(atr.Automation_Rule__r.is_Normal_Flow__c){
                                        uimapResult = isNormalFlow(taskRes,atr,shipmentNoMap.get(shpnum),getop,getbrand);
                                    }
                                }else if(atr.Automation_Rule__r.API_Details__c=='TP Doc'){        
                                    if(atr.Automation_Rule__r.Party_Data__c!=''){
                                        List<String> partylist=atr.Automation_Rule__r.Party_Data__c.split('==');
                                        String partyName = partylist[0].trim();
                                        String partyValue = partylist[1].trim();
                                        if(partyValue.contains('caseAccountName')){
                                            partyValue=shipmentNoMap.get(shpnum).account.SCV_Code__c;
                                        }
                                        If(partyDetailslist!=null && !partyDetailslist.isEmpty()){
                                            for(party__c pty:partyDetailslist){
                                                if(pty.Party_role_type_name__c == partyName && pty.Scv_Customer_Code__c ==partyValue){
                                                    uimapResult= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                                    break;
                                                }else{
                                                    uimapResult= atr.Automation_Rule__r.Rule_Name__c + ':false';
                                                }                                           
                                            }                                    
                                        }else{
                                            checkTpDocApi=true;
                                        }
                                    }
                                    if(atr.Automation_Rule__r.Party_Data__c=='' || checkTpDocApi==true){
                                        String xmlString= (String)TransportDocumentServiceController.getTransportDocumentDetailsRes(shpnum);
                                            if(xmlString.containsIgnoreCase('Read timed out')){      
                                                returnErrorMsg(shpnum);                   
                                            }
                                //Converting XML to JSON
                                Dom.Document xmlDoc = new Dom.Document();  // Parse the XML string using Dom.Document
                                xmlDoc.load(xmlString);                                
                                Dom.XmlNode root = xmlDoc.getRootElement();   // Get the root element of the XML                                
                                String jsonString = convertXmlToJson(root);   // Convert XML to JSON                                                
                                        
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
                                Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                                if(atr.Automation_Rule__r.is_Normal_Flow__c){
                                            uimapResult = isNormalFlow(jsonString,atr,shipmentNoMap.get(shpnum),getop,getbrand);
                                        }else{
                                            uimapResult = fetchTPDoc(jsonData,atr,shipmentNoMap.get(shpnum));
                                    }               
                                }               
                            }else if(atr.Automation_Rule__r.API_Details__c=='Invoice'){
                                if(atr.Automation_Rule__r.is_Normal_Flow__c){
                                        uimapResult = isNormalFlow(invoiceString,atr,shipmentNoMap.get(shpnum),getop,getbrand);
                                }
                            }                    
                            if(uimapResult!=''){
                                List<String> conditionParts = uimapResult.split(':');
                                String fieldName = conditionParts[0].trim();
                                String fieldValue = conditionParts[1].trim();
                                String fieldMsg = atr.Automation_Rule__r.Failure_Message__c;
                                    resultstr=resultstr+shpNum+'%'+fieldName+'%'+fieldValue+'%'+fieldMsg+'@';
                                    
                                    Map<String, String> caseMap = new Map<String, String>();

                                    // Populate the map with case field values
                                    caseMap.put('Rule Name', fieldName);
                                    caseMap.put('Rule Value', fieldValue);
                                    caseMap.put('Rule Message', fieldMsg);
                                    shipmentDetailsMap.get(shpNum).add(caseMap);
                                    Map<String, Object> resultMap = new Map<String, Object>();
                                    resultMap.put('ShipmentNo', shpNum);
                                    resultMap.put('RuleDetails', shipmentDetailsMap.get(shpNum));
                                    resultList.add(resultMap);
                                    shpnumResultMap.put(shpnum,shipmentNoMap.get(shpnum).id);
                                    caseResultMap.put(shpnum,resultstr);
                                    addRuleMap.put(fieldName,fieldValue);// addRuleMap contains the rules which are true
                                    if(fieldValue!= null && fieldValue == 'false'){ // If the rule fails, storing the value as NA
                                        for (String key : ruleMap.keySet()) {
                                            if (!addRuleMap.containsKey(key)) { //check the rules which are false and update them as NA.
                                                resultstr=resultstr+shpNum+'%'+key+'%'+'NA'+'%'+'NA'+'@';                                            
                                                caseResultMap.put(shpnum,resultstr);
                                            }
                                        }
                                        break; // Stop execution once the rule fails
                                }
                            }
                        }
                    }
                        // Create the outer object with key "Results"
                        finalResultMap.put('Results', resultList);

                        // Serialize the final result map to JSON
                        jsonData1 = JSON.serialize(finalResultMap);
                    }   
                }

                if(!shpnumResultMap.isEmpty()){
                        List<Case_Recommendation__c> existngCaseRecomndtn = [select id,Recommendation_Name__c,Recommendation_Id__c,Description__c,Priority__c,Case__c,Action_Status__c,Rejected_Reason__c,Result_Summary__c,Shipment_Status__c,Shipment_No__c from  Case_Recommendation__c where Shipment_No__c IN:shpnumResultMap.keySet() and case__c IN:shpnumResultMap.Values() WITH SECURITY_ENFORCED];
                    for(Case_Recommendation__c extrec:existngCaseRecomndtn){
                        extrec.Result_Summary__c=caseResultMap.get(extrec.Shipment_No__c).removeEnd('@');
                        extrec.Shipment_Status__c=!String.isEmpty(shipmentNum) ? 'Input': 'Default';
                        caseRecLstToUpdt.add(extrec);  //Update Logic
                        caseRecMap.put(extrec.Shipment_No__c,extrec.case__c);
                    }
                    
                    //Insert Logic
                    if(shpnumResultMap.size()!=caseRecMap.size()){ //Check the size to verify if any records are not updated, then it has to be inserted
                        String nbaRecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NBA Recommendation').getRecordTypeId();                      
                        for(string shp:shpnumResultMap.keySet()){
                            if (!caseRecMap.containsKey(shp)) {
                                Case_Recommendation__c resCaseRec = new Case_Recommendation__c();
                                resCaseRec.Description__c =  'Auto Resolution';
                                resCaseRec.Priority__c =  1;
                                resCaseRec.Case__c = shpnumResultMap.get(shp);  
                                resCaseRec.Result_Summary__c=caseResultMap.get(shp).removeEnd('@');
                                resCaseRec.Shipment_No__c=shp;
                                if(shp == shipmentNum){
                                    resCaseRec.Shipment_Status__c='Input';
                                }else{
                                    resCaseRec.Shipment_Status__c='Default';
                                }
                                resCaseRec.recordTypeId = nbaRecommRecTypeId; 
                                caseRecLstToInsrt.add(resCaseRec);
                            }
                        }
                    }
                    if(caseRecLstToUpdt.size() > 0 && Case_Recommendation__c.SObjectType.getDescribe().isAccessible()){
                        Database.update(caseRecLstToUpdt);   
                        wrapRuleName = returnRecomdn(caseRecLstToUpdt);                       
                    }
                    if(caseRecLstToInsrt.size() > 0 && Case_Recommendation__c.SObjectType.getDescribe().isAccessible()){
                        Database.insert(caseRecLstToInsrt);
                        wrapRuleName = returnRecomdn(caseRecLstToInsrt);
                    }
                }       
            }else{
                //To display existing recommendations on the UI
                wrapRuleName = returnRecomdn(cserecList);
            }
            }
        }catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'AutoResolutionNBA ' +recordId , new list<Exception>{ex});  
        }     
        return wrapRuleName;  
    } 
    
    /** 
    * @description | To fetch the brand and operator required to pass as a parameter to all the API's
    * @param shpnum accepts shipment number associated with the case
    */
    public static string fetchOperator(string shpnum){
        sumRes=ShipmentSummary.getShipmentSummary(shpnum);
        String fetchOp = 'shipmentSummary.header.operator'; //Remove hardcoding
        // map<String,String> operatorMap = new map<String,String>();
        string brand='';
        if(!sumRes.containsIgnoreCase('Read timed out')){            
            Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(sumRes);
            Object result = jsonMap;
            List<String> keys = fetchOp.split('\\.');
            for (String key : keys) {
                if (result instanceof Map<String, Object>) {
                    result = ((Map<String, Object>)result).get(key);
                    brand=String.valueOf(result);
                }
            }  
            //operator=BrandUtilities.getOperatorCodeBasedOnShortForm(brand).toUpperCase();
        }else{
            brand='API Issue';
        }
        // operatorMap.put(operator,brand);
        return brand;
    }

    /** 
    * @description | Creating a wrapper to store the rules and its status
    * @param cserecList accepts Case Recommendation list
    */
    public static List<FetchRuleName> returnRecomdn(list<Case_Recommendation__c> cserecList){
        list <FetchRuleName> wrapRuleName = new list <FetchRuleName> (); 
        String recSum;
        if(!cserecList.isEmpty()){
            for(Case_Recommendation__c cr: cserecList){
                recSum=cr.Result_Summary__c;
                if(recSum!=null){
                    List<String> rules = recSum.split('@');
                    for(string rule:rules){
                        FetchRuleName fetchrulewrap = new FetchRuleName();
                        List<String> rl = rule.split('%');
                        fetchrulewrap.shipmentNo= rl[0];
                        fetchrulewrap.rulename=rl[1];
                        fetchrulewrap.result=rl[2];
                        fetchrulewrap.message=rl[3];
                        wrapRuleName.add(fetchrulewrap);
                    }
                }
            }
        }
        return wrapRuleName;        
    } 

    /** 
    * @description | Creating a wrapper when API fails
    * @param cserecList accepts Case Recommendation list
    */
    public static list<FetchRuleName> returnErrorMsg(string shpNum){
        list < FetchRuleName > wrapRuleName = new list < FetchRuleName > (); 
        FetchRuleName fetchrulewrap = new FetchRuleName();
        fetchrulewrap.shipmentNo= shpNum;
        fetchrulewrap.errormessage='Oops! Something went wrong. Please try again later.';
        wrapRuleName.add(fetchrulewrap);
        return wrapRuleName;
    }
    
    /** 
    * @description | Helper method to convert XML to JSON
    * @param node accepts xml data
    */
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
    
    /** 
    * @description | Below method for fetching the TPDoc data
    * @param data accepts JSON with key value pair of String and object
    * @param atr accepts Automation Topic Rule record
    * @param cs accepts Case record
    */
    public static string fetchTPDoc(Map<String, Object> data, Automation_Topic_Rule__c atr, Case cs) {    
        string outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
        string accSCV=cs.account.SCV_Code__c;
        if (data.containsKey('TransportDocumentPartyRole')) {
            Map<String, Object> transportDocumentPartyRole = (Map<String, Object>) data.get('TransportDocumentPartyRole');
            Map<String, Object> partyRoleType = (Map<String, Object>) transportDocumentPartyRole.get('PartyRoleType');
            Map<String, Object> partyRole = (Map<String, Object>) transportDocumentPartyRole.get('PartyRole');
            Map<String, Object> partyCode = (Map<String, Object>) partyRole.get('PartyCode');  
            if((partyRoleType.get('PartyRoleTypeName')==atr.Automation_Rule__r.Rule_Response__c) && (partyCode.get('AlternativeCodeVal') == accSCV)){
                checkresult=true;
                outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';      
            }       
        } else {
            for (Object value : data.values()) {
                if (value instanceof Map<String, Object>) {
                    if(checkresult == true){
                        break;
                    }else{
                        fetchTPDoc((Map<String, Object>) value,atr,cs);    
                        }
                    }
                }
            }
        if(checkresult == true){
            return outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
        }
        return outcome;
    }
    
    /** 
    * @description | Generic Flow for all the rules computation
    * @param lstCases accepts case list
    */
    public static string isNormalFlow(String jsonString,Automation_Topic_Rule__c atr,Case cs,String operator,String brand) {
        string outcome='';
        string accName=cs.Account.Name;
        string accSCV=cs.account.SCV_Code__c;
        if(!jsonString.containsIgnoreCase('Read timed out')){            
            Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
            string fetchValue= atr.Automation_Rule__r.Response_mapping__c;
            //String fetchValue = 'tasks.taskName==Review Notification2 && tasks.statusId==5';
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
            if(fetchValue.contains('caseAccountScv')){
                if(accScv!=null){
                    fetchValue = fetchValue.replace('caseAccountScv', accScv);
                }else{
                    fetchValue = fetchValue.replace('caseAccountScv', '');
                }
            }
            List<String> andconditions = fetchValue.split('\\&&');  //If multiple conditions are present ex: 1 AND 2 AND 3
            List<String> conditions = new List<String>();
            conditions.add(andconditions[0].trim());
            List<String> laterconditions = new List<String>();

            integer totalInvoiceCount=0;
            integer invoicePresent=0;
            if(fetchValue.contains('&&')){ // This condition is when it involves multiple value checks
                laterconditions.add(andconditions[1].trim());
            }
            for (String condition : conditions) {
                List<String> conditionParts = condition.split('==');
                String fieldName = conditionParts[0].trim();
                String expectedValue = conditionParts[1].trim();  
                Object result = jsonMap;
                List<String> keys = fieldName.split('\\.');
                for (String key : keys) { //Map Instance
                    if (result instanceof Map<String, Object>) {
                        result = ((Map<String, Object>)result).get(key);
                        if(String.valueOf(result) == expectedValue){        
                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                            break;
                        }else{
                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                        }  
                    } 
                    else if (result instanceof List<Object>) { //List Instance
                        List<Object> currentList = (List<Object>) result;
                        result = null; 
                        If(currentList!=null && !currentList.isEmpty()){
                            for (Object item : currentList) {
                                if (item instanceof Map<String, Object>) {  //A. Here checking the logic if tasks.taskName==Send Prepaid Invoice Request. in the below 2 lines it will check if taskName=Send Prepaid Invoice Request. Segment value gives the current taskName the for loop is running and expectedvalue is the taskName mentioned on the rules field i.e., Send Prepaid Invoice Request      
                                    Object segmentValue = ((Map<String, Object>)item).get(key);      
                                    string seg=(string)segmentValue;
                                    if(expectedValue.contains('datetime.now()')){
                                        Datetime currentValue= (Datetime)jSON.deserialize('"'+segmentValue+'"',Datetime.class);                                   
                                        if((currentValue).date() != (datetime.now()).date() && (currentValue).date() != (datetime.now()).date()-1){
                                            if(expectedValue.contains('<datetime.now()')){
                                                if (currentValue <datetime.now()){
                                                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                                    //return false;
                                                }
                                            }else if(expectedValue.contains('>datetime.now()')){
                                                if (currentValue >datetime.now()){
                                                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                                    //return false;
                                                }
                                            }else if(expectedValue.contains('=datetime.now()')){
                                                if (currentValue ==datetime.now()){
                                                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                                                    //return false;
                                                }
                                            }
                                        }else{
                                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':' +currentValue;
                                        }
                                        break;
                                    }
                                    else if(expectedValue =='Invoice check'){
                                        totalInvoiceCount++;
                                        string invoice=InvoiceDetailsController.downloadInvoiceDetails(seg,accSCV,operator);
                                        if(invoice.containsIgnoreCase('Read timed out')){      
                                            returnErrorMsg('');
                                        }else if(invoice!=null){
                                            invoicePresent=invoicePresent+1;
                                        }                                   
                                    }
                                    else if (segmentValue != null && String.valueOf(segmentValue).equals(expectedValue)) { //If point A is satisfied then it comes here
                                        result = item;
                                        outcome = calculate(item,atr,cs,operator,brand,laterconditions,expectedValue);
                                        break; // Exit loop if condition is matched
                                    }else{
                                        outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                                    }
                                }
                            }
                        }else{
                            outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                        }
                    }else {
                        //Error handling scenarios
                    }
                }
                //For Invoice
                if(totalInvoiceCount>0 && totalInvoiceCount==invoicePresent){   //If all are downloadable
                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':true';
                }else if(totalInvoiceCount>=1 && invoicePresent > totalInvoiceCount){   //If atleast one is not downloadable (Partial)
                    outcome= atr.Automation_Rule__r.Rule_Name__c + 'partially:false';
                }else if(totalInvoiceCount>=1 && invoicePresent==0){    //If all are not downloadable
                    outcome= atr.Automation_Rule__r.Rule_Name__c + ':false';
                }
            }
        }
        return outcome;
    }
    
    /** 
    * @description | If multiple conditions exists(AND condition)
    * @param lstCases accepts case list
    */
    public static string calculate(object result,Automation_Topic_Rule__c atr,Case cs,String operator,String brand,List<String> laterconditions,String expectedValue){
        string outcomeval='';
        if(laterconditions!=null && !laterconditions.isEmpty()){
            for(string st:laterconditions){
                List<String> conditionPartsand = st.split('==');
                String fieldNameand = conditionPartsand[0].trim();
                String expectedValueand = conditionPartsand[1].trim();
                List<String> conditionPartskey = fieldNameand.split('\\.');
                String keyValueand = conditionPartskey[1].trim();
                Object segmentValueand = ((Map<String, Object>)result).get(keyValueand);
                if (segmentValueand != null && String.valueOf(segmentValueand).equals(expectedValueand)) {
                    outcomeval= atr.Automation_Rule__r.Rule_Name__c + ':true';
                }else{
                    outcomeval= atr.Automation_Rule__r.Rule_Name__c + ':false';
                    break;
                }
            }   
        }
        return outcomeval;
    }
    
    /** 
    * @description | Delete the existing recommendation on click of refresh button from the UI
    * @param recordId accepts current page recordId
    */
    @AuraEnabled    
    public static Boolean deleteAIRecommendation(String recordId){
        Boolean isdelete=false;
        List<Case_Recommendation__c> casRecList = new List<Case_Recommendation__c>();        
        casRecList = [SELECT Id from Case_Recommendation__c where Case__c  =: recordId and shipment_no__c!=null ]; 
        if(casRecList <> NULL && casRecList.size()>0
        ){            
            Database.DeleteResult[] resultsList = Database.delete(casRecList, false);
            isdelete = true;
            ErrorLogger.writeErrors('SFDC', 'Case', 'AutoResolutionNBA.deleteAIRecommendation', resultsList, casRecList);
        }
        
        return isdelete;
    }

    /** 
    * @description | Wrapper
    */
    public with sharing class FetchRuleName {
        @auraEnabled public string shipmentNo {get;set;}
        @auraEnabled public string rulename {get;set;}
        @auraEnabled public string result {get;set;}
        @auraEnabled public string message {get;set;}
        @auraEnabled public string errormessage {get;set;}
    }
}