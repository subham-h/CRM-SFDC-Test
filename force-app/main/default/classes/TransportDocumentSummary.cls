/*
Description  : Display tpdoc details from the Party Object based on tp doc number

* version       Date                Owner                                       Description
*******************************************************************************************************************
* v1.0          13/06/2023          ramadevi@maersk.com         Show Booked by Person details
*-------------------------------------------------------------------------------------------------------------------
*/
Public Class TransportDocumentSummary{
    @AuraEnabled
    public static List<partyDetails> getPartyDetails(String tpDocNumber){
    list<Party__c> partyList = new List<Party__c>();
    list<String> contactPersonList = new list<String>();
    //Map<String,Party__c>  extIdPartyMap = new Map<String,Party__c>();
    Map<String,Contact>  extIdContactMap = new Map<String,Contact>();
    partyList = [SELECT id,Customer_Name__c,Contact_Person__c,Scv_Customer_Code__c,Party_Role_Type_Name__c from Party__c where Tp_Doc_Number__c =: tpDocNumber order by Party_Role_Type_Name__c ASC];
    for(Party__c pty : partyList ){
        contactPersonList.add(pty.Contact_Person__c);
        //extIdPartyMap.put(pty.Contact_Person__c,pty);
    }
    if(!contactPersonList.isEmpty() && contactPersonList <> null){
        for(Contact con : [SELECT id,Name,External_ID__c from contact where External_ID__c in :contactPersonList]){
            extIdContactMap.put(con.External_ID__c ,con);
        }
    }
    List<partyDetails> partyDetailsList = new List<partyDetails>();
    for(Party__c pty : partyList ){
        partyDetails pd = new partyDetails();
        pd.id = pty.id;
        pd.customerName = pty.Customer_Name__c;
        pd.scvCustomerCode = pty.Scv_Customer_Code__c;
        pd.partyRoleTypeName = pty.Party_Role_Type_Name__c;
        pd.contactPerson = pty.Contact_Person__c;
        if(extIdContactMap.containsKey(pty.Contact_Person__c )) {
            pd.contactId = String.valueof(extIdContactMap.get(pty.Contact_Person__c).Id);
        } 
        partyDetailsList.add(pd);
    }
    
    system.debug('partyDetailsList ---'+partyDetailsList.size());
    return partyDetailsList;    
    }
    public class partyDetails{
         @AuraEnabled
        public String Id;
         @AuraEnabled
        public String customerName;
         @AuraEnabled
        public String contactId;
         @AuraEnabled
        public String scvCustomerCode;
         @AuraEnabled
        public String partyRoleTypeName ;
         @AuraEnabled
        public String contactPerson ;
        
    }
}