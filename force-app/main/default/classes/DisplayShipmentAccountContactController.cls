/**
* Author   : Shahanawaz@Maersk
* Purpose  : Used in DisplayShipmentAccountContact LWC for Account & Contact information
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8258   15-06-2022   Shahanawaz@Maersk      Used in DisplayShipmentAccountContact LWC for Account & Contact information
*/
public class DisplayShipmentAccountContactController {
    
    /*
* @description | SC-8258  Get Account & Contact Information
* @param recId accepts the recId
*/
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getAccountContactDetails(Id recId){
        ResponseWrapper res = new ResponseWrapper();
        List<AccountContactWrapper> accWrapList = new List<AccountContactWrapper>();
        List<String> errMsgList = new List<String>();
        try{
            String objApiName = recId.getSObjectType().getDescribe().getName();
            if(objApiName == 'Shipment__c'){
                res.title = 'Shipment Information';
                List<Shipment__c> shipmentList = [Select Id, Booked_By_Customer_SCV_Code__c, Price_Owner_SCV_Code__c From Shipment__c Where Id =: recId LIMIT 1];
                if(!shipmentList.isEmpty()){
                    if(!String.isEmpty(shipmentList[0].Booked_By_Customer_SCV_Code__c)){
                        List<Account> accList = [Select Id, Name From Account Where SCV_Code__c =: shipmentList[0].Booked_By_Customer_SCV_Code__c LIMIT 1];
                        if(!accList.isEmpty()){
                            accWrapList.add(new AccountContactWrapper('Booked by Customer Id', accList[0].Name, accList[0].Id));
                        }
                        else{
                            errMsgList.add('There is no account available with the mentioned booked by customer SCV code.');
                        }
                    }
                    else{
                        errMsgList.add('Booked by Customer SCV code is blank.');
                    }
                    if(!String.isEmpty(shipmentList[0].Price_Owner_SCV_Code__c)){
                        List<Account> accList = [Select Id, Name From Account Where SCV_Code__c =: shipmentList[0].Price_Owner_SCV_Code__c LIMIT 1];
                        if(!accList.isEmpty()){
                            accWrapList.add(new AccountContactWrapper('Price Owner Id', accList[0].Name, accList[0].Id));
                        }
                        else{
                            errMsgList.add('There is no account available with the mentioned price owner SCV code.');
                        }
                    }
                    else{
                        errMsgList.add('Price Owner SCV code is blank.');
                    }
                }
            }
            else if(objApiName == 'Party__c'){
                res.title = 'Party Information';
                List<Party__c> partyList = [Select Id, Scv_Customer_Code__c, Contact_Person__c From Party__c Where Id =: recId LIMIT 1];
                if(!partyList.isEmpty()){
                    if(!String.isEmpty(partyList[0].Scv_Customer_Code__c)){
                        List<Account> accList = [Select Id, Name From Account Where SCV_Code__c =: partyList[0].Scv_Customer_Code__c LIMIT 1];
                        if(!accList.isEmpty()){
                            accWrapList.add(new AccountContactWrapper('Account', accList[0].Name, accList[0].Id));
                        }
                        else{
                            errMsgList.add('There is no account available with the mentioned SCV code.');
                        }
                    }
                    else{
                        errMsgList.add('SCV code is blank.');
                    }
                    if(!String.isEmpty(partyList[0].Contact_Person__c)){
                        List<Contact> conList = [Select Id, Name From Contact Where External_ID__c =: partyList[0].Contact_Person__c LIMIT 1];
                        if(!conList.isEmpty()){
                            accWrapList.add(new AccountContactWrapper('Contact', conList[0].Name, conList[0].Id));
                        }
                        else{
                            errMsgList.add('There is no contact available with the mentioned contact person.');
                        }
                    }
                    else{
                        errMsgList.add('Contact Person is blank.');
                    }
                }
            }
            if(!accWrapList.isEmpty()){
                res.accWrapList = accWrapList;
            }
            if(!errMsgList.isEmpty()){
                res.errMsgList = errMsgList;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '. Please contact System administrator.'); 
        }
        system.debug('****res-->'+res);
        return res;
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public List<AccountContactWrapper> accWrapList;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public List<String> errMsgList;
    }
    
    public class AccountContactWrapper{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String recrdId;
        public AccountContactWrapper(String name, String value, String recrdId){
            this.name = name;
            this.value = value;
            this.recrdId = recrdId;
        }
    }
    
}