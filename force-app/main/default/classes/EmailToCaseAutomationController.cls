/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Controller of Email to case automation
 *              
 * Revision Ref Number  Date         Owner                   Description
 * -------- ----------  -----------  -------------------     -----------
 * 1.0      #SC-9165    29-Jul-2023  Shahanawaz@Maersk       Controller of Email to case automation
 * 
*/
/**
 * @description Controller of Email to case automation
 */
public class EmailToCaseAutomationController {
    
    /** 
    * @description | upload zip file
    * @param base64 accepts base64
    * @param type accepts type
    * @param contenttype accepts contenttype
    * @return ResponseWrapper
    */
    @AuraEnabled
    public static ResponseWrapper uploadFile(String base64, String type, String contenttype) {
        ResponseWrapper res = new ResponseWrapper();
        try{
            Document doc = [Select Id, Body, Name, ContentType, type From Document Where Name = 'Email2CaseAutomation' LIMIT 1];
            doc.Id = doc.Id;
            doc.Body = EncodingUtil.base64Decode(base64);
            doc.Type = type;
            doc.ContentType = contenttype;
            update doc;
            res.status = true;
            res.message = '';
        }catch(Exception e){
            res.status = false;
            res.message = e.getMessage();
        }
        return res;
    }
    
    /** 
    * @description | deploy metadata
    * @param buttonName accepts buttonName
    * @return ResponseWrapper
    */
    @AuraEnabled
    public static ResponseWrapper deployMetadata(String buttonName){
        ResponseWrapper res = new ResponseWrapper();
        try{
            String docName = '';
            if(!Test.isRunningTest()){
                docName = 'Email2CaseAutomation';
            }
            else{
                docName = 'Email2CaseAutomationTest';
            }
            Document doc = [Select Id, Body, DeveloperName From Document Where DeveloperName =: docName];
            Zippex zp = new Zippex(doc.Body);
            Boolean filePresent = checkFilePresent(buttonName, zp);
            Boolean validateHeader = false;
            if(!filePresent){
                res.status = false;
                res.message = buttonName.remove('Deploy').trim()+' file not present in zip folder.';
                return res;
            }
            Blob blobContent = getBody(buttonName, zp);
            if(blobContent == null){
                res.status = false;
                res.message = 'There is no content in the '+buttonName.remove('Deploy').trim()+' file.';
                return res;
            }
            String body = getBody(buttonName, zp).toString().trim();
            List<String> strList = body.split('\n');
            if(!strList.isEmpty()){
                validateHeader = validateHeaders(buttonName, strList[0].trim());
            }
            if(!validateHeader){
                res.status = false;
                res.message = 'Headers are not matching with the provided format.';
                return res;
            }
            String msg = deploy(buttonName, strList);
            if(String.isEmpty(msg.trim())){
                res.status = true;
                res.message = buttonName.remove('Deploy').trim()+' Deployment is successful.';
            }
            else{
                res.status = false;
                res.message = msg.trim();
            }
        }catch(Exception e){
            if(e.getMessage() != 'IO Exception: Read timed out'){
                res.status = false;
                res.message = e.getMessage()+' '+e.getLineNumber();
            }
            else{
                res.status = true;
                res.message = buttonName.remove('Deploy').trim()+' Deployment is successful.';
            }
        }
        return res;
    }
    
    /** 
    * @description | checks whether file present in zip folder
    * @param buttonName accepts buttonName
    * @param zp accepts zp
    * @return Boolean
    */
    public static Boolean checkFilePresent(String buttonName, Zippex zp){
        if(buttonName == 'Deploy Groups'){
            return zp.containsFile('E2C Package/Groups.csv');
        }
        else if(buttonName == 'Deploy Queues'){
            return zp.containsFile('E2C Package/Queues.csv');
        }
        else if(buttonName == 'Deploy Roles'){
            return zp.containsFile('E2C Package/Roles.csv');
        }
        else if(buttonName == 'Deploy Origins'){
            return zp.containsFile('E2C Package/Origins.csv');
        }
        else if(buttonName == 'Deploy List Views'){
            return zp.containsFile('E2C Package/ListViews.csv');
        }
        else if(buttonName == 'Deploy LinerBrand Direction and Country'){
            return zp.containsFile('E2C Package/LinerBrand.csv');
        }
        else if(buttonName == 'Deploy SCM Key Client Country Mapping'){
            return zp.containsFile('E2C Package/SCMKeyClient.csv');
        }
        else if(buttonName == 'Deploy Case Autoresponse Rules'){
            return zp.containsFile('E2C Package/CaseAutoResponseRules.csv');
        }
        else if(buttonName == 'Deploy BAs'){
            return zp.containsFile('E2C Package/BA.csv');
        }
        else if(buttonName == 'Deploy Org Wide Addresses'){
            return zp.containsFile('E2C Package/OrgWideAddress.csv');
        }
        else if(buttonName == 'Deploy BAs (Custom)'){
            return zp.containsFile('E2C Package/CustomBA.csv');
        }
        else if(buttonName == 'Deploy Custom Email Services'){
            return zp.containsFile('E2C Package/CustomEmailServices.csv');
        }
        return false;
    }
    
    /** 
    * @description | return body of file
    * @param buttonName accepts buttonName
    * @param zp accepts zp
    * @return Blob
    */
    public static Blob getBody(String buttonName, Zippex zp){
        if(buttonName == 'Deploy Groups'){
            return zp.getFile('E2C Package/Groups.csv');
        }
        else if(buttonName == 'Deploy Queues'){
            return zp.getFile('E2C Package/Queues.csv');
        }
        else if(buttonName == 'Deploy Roles'){
            return zp.getFile('E2C Package/Roles.csv');
        }
        else if(buttonName == 'Deploy Origins'){
            return zp.getFile('E2C Package/Origins.csv');
        }
        else if(buttonName == 'Deploy List Views'){
            return zp.getFile('E2C Package/ListViews.csv');
        }
        else if(buttonName == 'Deploy LinerBrand Direction and Country'){
            return zp.getFile('E2C Package/LinerBrand.csv');
        }
        else if(buttonName == 'Deploy SCM Key Client Country Mapping'){
            return zp.getFile('E2C Package/SCMKeyClient.csv');
        }
        else if(buttonName == 'Deploy Case Autoresponse Rules'){
            return zp.getFile('E2C Package/CaseAutoResponseRules.csv');
        }
        else if(buttonName == 'Deploy BAs'){
            return zp.getFile('E2C Package/BA.csv');
        }
        else if(buttonName == 'Deploy Org Wide Addresses'){
            return zp.getFile('E2C Package/OrgWideAddress.csv');
        }
        else if(buttonName == 'Deploy BAs (Custom)'){
            return zp.getFile('E2C Package/CustomBA.csv');
        }
        else if(buttonName == 'Deploy Custom Email Services'){
            return zp.getFile('E2C Package/CustomEmailServices.csv');
        }
        return null;
    }
    
    /** 
    * @description | validate headers of file
    * @param buttonName accepts buttonName
    * @param header accepts header
    * @return Boolean
    */
    public static Boolean validateHeaders(String buttonName, String header){
        String genKey;
        String baWithoutQueue;
        if(buttonName == 'Deploy Groups'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('Group_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy Queues'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('Queue_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy Roles'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('Roles_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy Origins'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('CaseOrigin_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy List Views'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('ListView_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy LinerBrand Direction and Country'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('LinearBrand_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy SCM Key Client Country Mapping'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('SCMKC_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy Case Autoresponse Rules'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('Auto_Response_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy BAs'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('BA_Headers_With_Queue').First_Field_Value__c;
            baWithoutQueue = General_Key_Value_Configurations__mdt.getInstance('BA_Headers_Without_Queue').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy Org Wide Addresses'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('Orgwide_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy BAs (Custom)'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('CustomBA_Headers').First_Field_Value__c;
        }
        else if(buttonName == 'Deploy Custom Email Services'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('CustomEmailService_Headers').First_Field_Value__c;
        }
        if(buttonName != 'Deploy BAs' && !String.isEmpty(genKey) && genKey.trim().toLowerCase() == header.toLowerCase()){
            return true;
        }
        else if(buttonName == 'Deploy BAs'){
            if(!String.isEmpty(genKey) && genKey.trim().toLowerCase() == header.toLowerCase()){
                return true;
            }
            else if(!String.isEmpty(baWithoutQueue) && baWithoutQueue.trim().toLowerCase() == header.toLowerCase()){
                return true;
            }
        }
        return false;
    }
    
    /** 
    * @description | deploy the data of files
    * @param buttonName accepts buttonName
    * @param strList accepts strList
    * @return String
    */
    public static String deploy(String buttonName, List<String> strList){
        if(buttonName == 'Deploy Groups'){
            return MetadataUtility.createPublicGroup(strList);
        }
        else if(buttonName == 'Deploy Queues'){
            return MetadataUtility.createQueue(strList);
        }
        else if(buttonName == 'Deploy Roles'){
            return MetadataUtility.createRoles(strList);
        }
        else if(buttonName == 'Deploy Origins'){
            return MetadataUtility.createCaseOrigin(strList);
        }
        else if(buttonName == 'Deploy List Views'){
            return MetadataUtility.createListViews(strList);
        }
        else if(buttonName == 'Deploy LinerBrand Direction and Country'){
             MetadataUtility.createMetadataRecords('LinerBrand_Direction_and_Country__mdt', strList);
            return '';
        }
        else if(buttonName == 'Deploy SCM Key Client Country Mapping'){
             MetadataUtility.createMetadataRecords('SCM_Key_Client_Country_Mapping__mdt', strList);
            return '';

        }
        else if(buttonName == 'Deploy BAs'){
            return MetadataUtility.createBA(strList);
        }
        else if(buttonName == 'Deploy Org Wide Addresses'){
            return MetadataUtility.createOrgWideAddresses(strList);
        }
        else if(buttonName == 'Deploy BAs (Custom)'){
            return MetadataUtility.createCustomBA(strList);
        }
        else if(buttonName == 'Deploy Custom Email Services'){
            return MetadataUtility.createCustomEmailServices(strList);
        }
        return '';
    }
    
    /** 
    * @description | Autoresponse rules wrapper class
    */
    public class AutoResponseWrapper{
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<MetadataUtility.fetchXmldata> responseResult;
    }

    /** 
    * @description | Autoresponse rules wrapper class
    * @param buttonName accepts buttonName
    * @return AutoResponseWrapper
    */
    @AuraEnabled
    public static AutoResponseWrapper deployAutoResponse(String buttonName){
        AutoResponseWrapper res = new AutoResponseWrapper();
        String docName = '';
        if(!Test.isRunningTest()){
            docName = 'Email2CaseAutomation';
        }
        else{
            docName = 'Email2CaseAutomationTest';
        }
        Document doc = [Select Id, Body, DeveloperName From Document Where DeveloperName =: docName];
        Zippex zp = new Zippex(doc.Body);
        Boolean filePresent = checkFilePresent(buttonName, zp);
        Boolean validateHeader = false;
        if(!filePresent){
            res.status = false;
            res.message = buttonName.remove('Deploy').trim()+' File not present in zip folder.';
            return res;
        }
        Blob blobContent = getBody(buttonName, zp);
        if(blobContent == null){
            res.status = false;
            res.message = 'There is no content in the '+buttonName.remove('Deploy').trim()+' file.';
            return res;
        }
        String body = getBody(buttonName, zp).toString().trim();
        List<String> strList = body.split('\n');
        if(!strList.isEmpty()){
            validateHeader = validateHeaders(buttonName, strList[0].trim());
        }
        if(!validateHeader){
            res.status = false;
            res.message = 'Headers are not matching with the provided format.';
            return res;
        }
        res.status = true;
        res.responseResult= MetadataUtility.createAutoResponseRule(strList); 
        return res;
    }

    /** 
    * @description | response wrapper class
    */
    public class ResponseWrapper{
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public String message; 
    }
}