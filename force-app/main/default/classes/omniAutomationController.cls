/** 
* @description 
* Author   : Sunil.bs@maersk.com
* Purpose  : Controller class to hold simple and reusable functionalities for Omni Automation 
*        
* Revision Ref Number  Date        Owner                   		Description
* -------- ----------  ----------- -------------------     		-----------
* 1.0      SC-7996   15-Jun-2023   Sunil.bs@maersk.com          Created for automating Omni Onboarding of countries
*/
public class omniAutomationController{
    @AuraEnabled
    public static ResponseWrapper uploadFile(String base64, String type, String contenttype) {
        ResponseWrapper res = new ResponseWrapper();
        try{
            Document doc = [Select Id, Body, Name, ContentType, type From Document Where Name = 'OmniOnboardingAutomation' LIMIT 1];
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
    
    @AuraEnabled
    public static ResponseWrapper deployMetadata(String buttonName){
        ResponseWrapper res = new ResponseWrapper();
        try{
            String docName = '';	
            if(!Test.isRunningTest()){
                docName = 'OmniOnboardingAutomation';
            }
            else{
                docName = 'OmniOnboardingAutomation1';
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
                System.debug('validate header');
                validateHeader = validateHeaders(buttonName, strList[0].trim());
            }
            if(!validateHeader){
                res.status = false;
                res.message = 'Headers are not matching with the provided format.';
                system.debug('Messagecame here.. '+res.message);
                return res;
            }
            String msg = deploy(buttonName, strList);
            if(String.isEmpty(msg.trim())){
                res.status = true;
                res.message = msg;
            }
            else{
                res.status = false;
                res.message = msg.trim();
                system.debug('Message2 '+res.message);
            }
        }catch(Exception e){
            system.debug('****e-->***'+e.getMessage()+' '+e.getLineNumber());
            if(e.getMessage() != 'IO Exception: Read timed out'){
                res.status = false;
                res.message = e.getMessage()+' '+e.getLineNumber();
            }
            else{
                res.status = true;
                res.message = buttonName.remove('Deploy').trim()+' Deployment is successful.';
                system.debug('Message3 '+res.message);
            }
        }
        return res;
    }
    
    public static Boolean checkFilePresent(String buttonName, Zippex zp){
        
        if(buttonName == 'Deploy Skills'){
            return zp.containsFile('OmniOnboardingAutomation Package/Skills.csv');
        }
        
        else if(buttonName == 'Deploy userServiceResourceAndSkills'){
            return zp.containsFile('OmniOnboardingAutomation Package/userServiceResourceAndSkills.csv');
        }     
        
        else if(buttonName == 'Deploy UserToPSUsingMaerskUserId'){
            return zp.containsFile('OmniOnboardingAutomation Package/UserToPSUsingMaerskUserId.csv');
        }
        
        else if(buttonName == 'Deploy UserToPSUsingSCVcode'){
            return zp.containsFile('OmniOnboardingAutomation Package/UserToPSUsingSCVcode.csv');
        }
        
        else if(buttonName == 'Deploy PresenceConfigUsingMaerskUserid'){
            return zp.containsFile('OmniOnboardingAutomation Package/PresenceConfigUsingMaerskUserid.csv');
        }
        
        else if(buttonName == 'Deploy PresenceConfigUsingSCVcode'){
            return zp.containsFile('OmniOnboardingAutomation Package/PresenceConfigUsingSCVcode.csv');
        }
        
        else if(buttonName == 'Deploy UserToOmniSupervisorConfig'){
            return zp.containsFile('OmniOnboardingAutomation Package/OmniSupervisorConfigUserAddition.csv');
        }
        
        else if(buttonName == 'Deploy GroupToOmniSupervisorConfig'){
            return zp.containsFile('OmniOnboardingAutomation Package/OmniSupervisorConfiGroupAddition.csv');
        }
        
        else if(buttonName == 'Deploy CaseOmniMappingsRecords'){
            return zp.containsFile('OmniOnboardingAutomation Package/CaseOmniMappingsRecords.csv');
        }
        
        else if(buttonName == 'Deploy OmniServiceRelationshipmappings'){
            return zp.containsFile('OmniOnboardingAutomation Package/OmniServiceRelationshipmappings.csv');
        }
        else if(buttonName == 'Deploy OmniClientCaseAssignments'){
            return zp.containsFile('OmniOnboardingAutomation Package/OmniClientCaseAssignments.csv');
        }
        
        else if(buttonName == 'Deploy LBDCMetadataRecords'){
            return zp.containsFile('OmniOnboardingAutomation Package/LBDCMetadataRecords.csv');
        }
        return false;
    }
    
    public static Blob getBody(String buttonName, Zippex zp){
        
        if(buttonName == 'Deploy Skills'){
            return zp.getFile('OmniOnboardingAutomation Package/Skills.csv');
        }
        
        else if(buttonName == 'Deploy userServiceResourceAndSkills'){
            return zp.getFile('OmniOnboardingAutomation Package/userServiceResourceAndSkills.csv');
        }     
        
        else if(buttonName == 'Deploy UserToPSUsingMaerskUserId'){
            return zp.getFile('OmniOnboardingAutomation Package/UserToPSUsingMaerskUserId.csv');
        }
        
        else if(buttonName == 'Deploy UserToPSUsingSCVcode'){
            return zp.getFile('OmniOnboardingAutomation Package/UserToPSUsingSCVcode.csv');
        }
        
        else if(buttonName == 'Deploy PresenceConfigUsingMaerskUserid'){
            return zp.getFile('OmniOnboardingAutomation Package/PresenceConfigUsingMaerskUserid.csv');
        }
        
        else if(buttonName == 'Deploy PresenceConfigUsingSCVcode'){
            return zp.getFile('OmniOnboardingAutomation Package/PresenceConfigUsingSCVcode.csv');
        }
        
        else if(buttonName == 'Deploy UserToOmniSupervisorConfig'){
            return zp.getFile('OmniOnboardingAutomation Package/OmniSupervisorConfigUserAddition.csv');
        }
        
        else if(buttonName == 'Deploy GroupToOmniSupervisorConfig'){
            return zp.getFile('OmniOnboardingAutomation Package/OmniSupervisorConfiGroupAddition.csv');
        }
        
        else if(buttonName == 'Deploy CaseOmniMappingsRecords'){
            return zp.getFile('OmniOnboardingAutomation Package/CaseOmniMappingsRecords.csv');
        }
        
        else if(buttonName == 'Deploy OmniServiceRelationshipmappings'){
            return zp.getFile('OmniOnboardingAutomation Package/OmniServiceRelationshipmappings.csv');
        }
        else if(buttonName == 'Deploy OmniClientCaseAssignments'){
            return zp.getFile('OmniOnboardingAutomation Package/OmniClientCaseAssignments.csv');
        }
       
        else if(buttonName == 'Deploy LBDCMetadataRecords'){
            return zp.getFile('OmniOnboardingAutomation Package/LBDCMetadataRecords.csv');
        }
        
        return null;
    }
    
    public static Boolean validateHeaders(String buttonName, String header){
        String genKey;
        
        if(buttonName == 'Deploy Skills'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('Skills_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy userServiceResourceAndSkills'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('userServiceResourceAndSkills_Headers').First_Field_Value__c;
        }     
        
        else if(buttonName == 'Deploy UserToPSUsingMaerskUserId'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('UserToPSUsingMaerskUserId_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy UserToPSUsingSCVcode'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('UserToPSUsingSCVcode_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy PresenceConfigUsingMaerskUserid'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('PresenceConfigUsingMaerskUserid_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy PresenceConfigUsingSCVcode'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('PresenceConfigUsingSCVcode_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy UserToOmniSupervisorConfig'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('OmniSupervisorConfigUserAddition_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy GroupToOmniSupervisorConfig'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('OmniSupervisorConfiGroupAddition_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy CaseOmniMappingsRecords'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('CaseOmniMappingsRecords_Headers').First_Field_Value__c;
        }
        
        else if(buttonName == 'Deploy OmniServiceRelationshipmappings'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('OmniServiceRelationshipmappings_Headers').First_Field_Value__c;
            System.debug('test1'+genKey);
        }
        
        else if(buttonName == 'Deploy OmniClientCaseAssignments'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('OmniClientCaseAssignments_Headers').First_Field_Value__c;
            System.debug('test'+genKey);
        }
        
        else if(buttonName == 'Deploy LBDCMetadataRecords'){
            genKey = General_Key_Value_Configurations__mdt.getInstance('LBDCMetadataRecords_Headers').First_Field_Value__c;
        }
        
        if(!String.isEmpty(genKey) && genKey.trim().toLowerCase() == header.toLowerCase()){
            return true;
        }
        
        return false;
    }
    
    public static String deploy(String buttonName, List<String> strList){
        
        if(buttonName == 'Deploy Skills'){
            return omniMetadataUtility.createSkills(strList);
        }
        
        else if(buttonName == 'Deploy userServiceResourceAndSkills'){
            return omniMetadataUtility.userServiceResourceAndSkillsUpsert(strList);
        }     
        
        else if(buttonName == 'Deploy UserToPSUsingMaerskUserId'){
            return omniMetadataUtility.addPermissionsetToUsers(strList,'MaerskUserIdBased');
        }
        
        else if(buttonName == 'Deploy UserToPSUsingSCVcode'){
            return omniMetadataUtility.addPermissionsetToUsers(strList,'SCVcodeBased');
        } 
        
        else if(buttonName == 'Deploy PresenceConfigUsingMaerskUserid'){
            return omniMetadataUtility.presenceUserConfigUserUpsert(strList,'MaerskUserIdBased');
        }
        
        else if(buttonName == 'Deploy PresenceConfigUsingSCVcode'){
            return omniMetadataUtility.presenceUserConfigUserUpsert(strList,'SCVcodeBased');
        }
        
        else if(buttonName == 'Deploy UserToOmniSupervisorConfig'){
            return omniMetadataUtility.addUserOrGroupToOmniSupervisorConfig(strList, 'userBased');
        }
        
        else if(buttonName == 'Deploy GroupToOmniSupervisorConfig'){
            return omniMetadataUtility.addUserOrGroupToOmniSupervisorConfig(strList, 'groupBased');
        }
        
        else if(buttonName == 'Deploy CaseOmniMappingsRecords'){
            return omniMetadataUtility.addCaseOmniMappingsRecords(strList);
        }
        
        else if(buttonName == 'Deploy OmniServiceRelationshipmappings'){
            return omniMetadataUtility.createOmniServiceRelationshipmappings(strList);
        }
        
        else if(buttonName == 'Deploy OmniClientCaseAssignments'){
            return omniMetadataUtility.createOmniClientCaseAssignments(strList);
        }
        
        else if(buttonName == 'Deploy LBDCMetadataRecords'){
            return omniMetadataUtility.updateLBDCMetadataRecords(strList);
        }
        
        return '';
    }
    
    
    public class ResponseWrapper{
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public String message; 
    }
}