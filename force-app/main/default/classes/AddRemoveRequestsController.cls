/*
Description  : Contoller class for adding/removing Request Contacts
/
* version       Date                Owner                                       Description
******************************************************************************************************* 
* v1.0          31/Jul/2018       manjunath.c.holekade@maersk.com           RQ-008471 - Created 2 methods, 'getRequests' and 'addReqInfo'
* v2.0          06/Aug/2018       manjunath.c.holekade@maersk.com           RQ-009123 - Mod-01 to Mod-04 -> Included "Account Name" and "SCV Code"
                                                                                        Mod-05 -> Get all contacts in case of 'Remove'
                                                                                        Mod-06 to Mod-11 -> To check whether user/contact exists and SCVCode is valid

*/

public class AddRemoveRequestsController{
    
    // Wrapper class for Request and Request Info object
    public class ReqConWrapper{
        @AuraEnabled public String strUniqId { get; set; }
        @AuraEnabled public String strReqNo { get; set; }
        @AuraEnabled public String strRouteCode { get; set; }
        @AuraEnabled public String strCommodity { get; set; }
        @AuraEnabled public String strEqType { get; set; }
        @AuraEnabled public String strContractId {get; set; }
        @AuraEnabled public String strReqStatus { get; set; }
        @AuraEnabled public String strReqChangeStaus { get; set; }
        @AuraEnabled public String strReqLinerBrand { get; set; }
        @AuraEnabled public String strReqConEmail { get; set; }
        @AuraEnabled public String strReqConName { get; set; }
        @AuraEnabled public String strReqConChangeStaus {get; set; }        
        @AuraEnabled public String strReqConLastModifiedDate {get; set; }
        @AuraEnabled public String strReqConAccountName {get; set; }         // RQ-009123 - Mod-01 - Start - Included "Account Name" and "SCV Code"
        @AuraEnabled public String strReqConSCV {get; set; }                 // RQ-009123 - Mod-01 - End
        @AuraEnabled public Boolean blnValidConUser {get; set; }             // RQ-009123 - Mod-06 - To check whether user/contact exists
        @AuraEnabled public Boolean blnValidSCVCode {get; set; }             // RQ-009123 - Mod-07 - To check whether Account with SCVCode exists
        
        public ReqConWrapper(){
            this.strReqConEmail = '-';
            this.strReqConName = '-';
            this.strReqConChangeStaus = '-';
            this.strReqConLastModifiedDate = '-';
            this.strReqConAccountName = '-';                                // RQ-009123 - Mod-02 - Start - Included "Account Name" and "SCV Code"
            this.strReqConSCV = '-';                                        // RQ-009123 - Mod-02 - End
            this.blnValidConUser = true;                                    // RQ-009123 - Mod-08 - Start
            this.blnValidSCVCode = true;                                    // RQ-009123 - Mod-08 - End
        }
    }
    
    // Method to get the list of Requests with/without Request Info details
    @AuraEnabled
    public static List<ReqConWrapper> getRequests(String scvCode, String emailID, String userType, String activityType){
        system.debug('a1a:'+scvCode +':' +emailID +':'+ userType +':'+ activityType);
        Set<Id> setTobeRemovedReqIds = new Set<Id>();
        List<Id> lstAccIds = new List<Id>();
        List<ReqConWrapper> lstReqConWrapper = new List<ReqConWrapper>();
        String conuserId = '';
        List<Request_Information__c> lstReqInfos = new List<Request_Information__c>();
        List<Request__c> lstReqs = new List<Request__c>();
        List<String> lstReqStatus = new List<String>{'Active', 'Active Due to Policy Change'}; // List of allowed Request statuses
        List<String> lstRemoveStatus = new List<String>{'Remove', 'Rejected', 'Inactive'};
        List<Account> lstAcc = new List<Account>();                                     // RQ-009123 - Mod-09 - Start - To check whether SCVCode is valid
        if(scvCode != '')
            lstAcc = [select Id from Account where SCV_Code__c =: scvCode];  // RQ-009123 - Mod-09 - End
        if(userType == 'Contact'){
            for(Contact conObj:[select Id, AccountId from Contact where Email =: emailID limit 1]){
                lstAccIds.add(conObj.AccountId);
                conuserId = conObj.Id;
            }
        }else if(userType == 'User'){
            for(User userObj:[select Id from User where Email =: emailID limit 1]){
                conuserId = userObj.Id;
            }
        }
        if(conuserId != '' && ((((scvCode != '' && lstAcc.size() != 0) ||(scvCode == '' && activityType == 'Remove')) && userType == 'User') || userType == 'Contact' )){                   // RQ-009123 - Mod-10 - To check whether user/contact exists and SCV code is valid
            String strReqInfoQuery = 'select ';     
            strReqInfoQuery += 'Request__c, Request__r.Name, Request__r.Route_Direction_Code__c, Request__r.Commodity_Rate_Sheet__c,Request__r.Liner_Brand__c,'; //Req fields
            strReqInfoQuery += 'Request__r.Equipment_Types__c,Request__r.Existing_Contract_ID__c,Request__r.Status__c,Request__r.Change_Request_Status__c,';
            strReqInfoQuery += 'Request__r.Account__r.Name,Request__r.Account_SCV_Code__c,';  // RQ-009123 - Mod-03 - Included "Account Name" and "SCV Code" fields
            strReqInfoQuery += 'Request_Status__c, Contact__r.AccountId, Account_Name__c, Change_Status__c, Name, Email__c, Lastmodifieddate,'; // ReqInfo fields
            strReqInfoQuery += 'Id from Request_Information__c where ';     
            
            if(userType == 'Contact')
                strReqInfoQuery += 'Contact__r.Email =:emailID';
            else if(userType == 'User'){
                strReqInfoQuery += 'User__r.Email =:emailID';
                if(scvCode != '')
                    strReqInfoQuery += ' and Request__r.Account__r.SCV_Code__c =:scvCode';
            }
            if(activityType == 'Remove')
                strReqInfoQuery += ' and Change_Status__c NOT IN:lstRemoveStatus';          
            system.debug('strReqInfoQuery:'+strReqInfoQuery);
            lstReqInfos = Database.query(strReqInfoQuery);  // Query to get existing Request Info records(if any)
            system.debug('lstReqInfos:'+lstReqInfos);
            for(Request_Information__c lstReqInfosVar:lstReqInfos){
                if((userType == 'Contact' && lstReqInfosVar.Contact__r.AccountId == lstReqInfosVar.Account_Name__c)
                   || (userType == 'User')
                   || (userType == 'Contact' && activityType == 'Remove')){  // RQ-009123 - Mod-05 - Get all contacts in case of 'Remove'
                       String strReqInfoStatus = lstReqInfosVar.Change_Status__c;
                       if(activityType == 'Remove' || 
                          (activityType == 'Add' && 
                           (lstReqInfosVar.Request_Status__c == 'Active' || lstReqInfosVar.Request_Status__c == 'Active Due to Policy Change') &&
                           (strReqInfoStatus == 'Remove' || strReqInfoStatus == 'Rejected' || strReqInfoStatus == 'Inactive'))){
                               lstAccIds.add(lstReqInfosVar.Account_Name__c);
                               ReqConWrapper varReqConWrap = new ReqConWrapper();
                               varReqConWrap.strUniqId = '' + ';' + lstReqInfosVar.Id + ';' + '' + ';' + '' + ';' + activityType;
                               varReqConWrap.strReqNo = lstReqInfosVar.Request__r.Name;
                               varReqConWrap.strRouteCode = lstReqInfosVar.Request__r.Route_Direction_Code__c;
                               varReqConWrap.strCommodity = lstReqInfosVar.Request__r.Commodity_Rate_Sheet__c;
                               varReqConWrap.strEqType = lstReqInfosVar.Request__r.Equipment_Types__c;
                               varReqConWrap.strContractId = lstReqInfosVar.Request__r.Existing_Contract_ID__c;
                               varReqConWrap.strReqStatus = lstReqInfosVar.Request__r.Status__c;
                               varReqConWrap.strReqChangeStaus = lstReqInfosVar.Request__r.Change_Request_Status__c;
                               varReqConWrap.strReqLinerBrand = lstReqInfosVar.Request__r.Liner_Brand__c;
                               varReqConWrap.strReqConEmail = lstReqInfosVar.Email__c;
                               varReqConWrap.strReqConName = lstReqInfosVar.Name;
                               varReqConWrap.strReqConChangeStaus = lstReqInfosVar.Change_Status__c;
                               Date lModDate = Date.valueOf(string.valueOf(lstReqInfosVar.Lastmodifieddate));
                               varReqConWrap.strReqConLastModifiedDate = lModDate.format();
                               varReqConWrap.strReqConAccountName = lstReqInfosVar.Request__r.Account__r.Name; // RQ-009123 - Mod-04 - Start - Included "Account Name" and "SCV Code"
                               varReqConWrap.strReqConSCV = lstReqInfosVar.Request__r.Account_SCV_Code__c;     // RQ-009123 - Mod-04 - End
                               lstReqConWrapper.add(varReqConWrap);
                           }
                       if(activityType == 'Add')
                           setTobeRemovedReqIds.add(lstReqInfosVar.Request__c);
                   }
            }
            system.debug('lstAccIds:'+lstAccIds);
            system.debug('setTobeRemovedReqIds:'+setTobeRemovedReqIds);
            if(activityType == 'Add'){
                String strReqQuery = 'select Id,Name,Route_Direction_Code__c,Commodity_Rate_Sheet__c,Equipment_Types__c,Existing_Contract_ID__c,';
                strReqQuery += 'Status__c, Change_Request_Status__c,Liner_Brand__c from Request__c where Status__c IN:lstReqStatus';
                if(userType == 'Contact')
                    strReqQuery += ' and Account__c IN:lstAccIds';              
                else if(userType == 'User')
                    strReqQuery += ' and Account__r.SCV_Code__c =:scvCode';
                system.debug('strReqQuery:'+strReqQuery);
                lstReqs = Database.query(strReqQuery);  // Query to get the list of Requests
                system.debug('lstReqs:'+lstReqs);
                for(Request__c lstReqsVar:lstReqs){
                    if(!setTobeRemovedReqIds.contains(lstReqsVar.Id)){
                        ReqConWrapper varReqConWrap = new ReqConWrapper();
                        varReqConWrap.strUniqId = lstReqsVar.Id + ';' + '' + ';' + conuserId + ';' + userType + ';' + activityType;
                        varReqConWrap.strReqNo = lstReqsVar.Name;
                        varReqConWrap.strRouteCode = lstReqsVar.Route_Direction_Code__c;
                        varReqConWrap.strCommodity = lstReqsVar.Commodity_Rate_Sheet__c;
                        varReqConWrap.strEqType = lstReqsVar.Equipment_Types__c;
                        varReqConWrap.strContractId = lstReqsVar.Existing_Contract_ID__c;
                        varReqConWrap.strReqStatus = lstReqsVar.Status__c;
                        varReqConWrap.strReqChangeStaus = lstReqsVar.Change_Request_Status__c;
                        varReqConWrap.strReqLinerBrand = lstReqsVar.Liner_Brand__c;
                        lstReqConWrapper.add(varReqConWrap);
                    }
                }
            }
        }else{                                          // RQ-009123 - Mod-11 - Start
            ReqConWrapper varReqConWrap = new ReqConWrapper();
            if(conuserId == '')
                varReqConWrap.blnValidConUser = false;
            if(scvCode != '' && lstAcc.size() == 0 && userType == 'User')
                varReqConWrap.blnValidSCVCode = false;
            lstReqConWrapper.add(varReqConWrap);
        }                                               // RQ-009123 - Mod-11 - End
        system.debug('lstReqConWrapper:'+lstReqConWrapper);
        return lstReqConWrapper;
    }
    
    // Method to create/update Request Info records
    @AuraEnabled
    public static void addReqInfo(List<String> lstUniqId){
        String activityType = '';
        List<String> lstFailedReqInfoNames = new List<String>();
        List<Id> lstReqInfoId = new List<Id>();
        List<Request_Information__c> lstToBeUpsertedReqInfo = new List<Request_Information__c>();
        for(String lstUniqIdVar:lstUniqId){
            List<String> lstUniqIdSplit = lstUniqIdVar.split(';');
            if(lstUniqIdSplit[4] == 'Remove'){
                activityType = lstUniqIdSplit[4];
                lstReqInfoId.add(lstUniqIdSplit[1]);
            }else if(lstUniqIdSplit[4] == 'Add'){
                activityType = lstUniqIdSplit[4];
                if(lstUniqIdSplit[1] != '')
                    lstReqInfoId.add(lstUniqIdSplit[1]);
                else{
                    Request_Information__c tempReqInfo = new Request_Information__c();
                    tempReqInfo.Request__c = lstUniqIdSplit[0];
                    tempReqInfo.Change_Status__c = 'New'; 
                    if(lstUniqIdSplit[3] == 'Contact')
                        tempReqInfo.Contact__c = lstUniqIdSplit[2];
                    else if(lstUniqIdSplit[3] == 'User')
                        tempReqInfo.User__c = lstUniqIdSplit[2];
                    lstToBeUpsertedReqInfo.add(tempReqInfo);
                }               
            }    
        }
        for(Request_Information__c regInfoObj:[select Id, Change_Status__c from Request_Information__c where Id IN:lstReqInfoId])
        {
            if(activityType == 'Remove'){
                regInfoObj.Change_Status__c = 'Remove';
                lstToBeUpsertedReqInfo.add(regInfoObj);
            }else if(activityType == 'Add'){
                regInfoObj.Change_Status__c = 'New';
                lstToBeUpsertedReqInfo.add(regInfoObj);             
            }
        }
        if(lstToBeUpsertedReqInfo.size() > 0){
            List<Database.UpsertResult> lstReqInfoUpsertResult = database.upsert(lstToBeUpsertedReqInfo, true);
            ErrorLogger.writeErrors('SFDC', 'AddRemoveRequestsController', 'addReqInfo', lstReqInfoUpsertResult, lstToBeUpsertedReqInfo);
            for(Database.UpsertResult sr :lstReqInfoUpsertResult){
                system.debug('a1b:' + sr.isSuccess());
                system.debug('a1c:' + sr.getId());
                if(!sr.isSuccess()){
                    system.debug('a1d:' + sr.getErrors());
                }
            } 
        }    
    }    
}