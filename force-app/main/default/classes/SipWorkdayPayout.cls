@RestResource(urlMapping='/getsipdata/*')
global with sharing class SipWorkdayPayout {
    @HttpGet
    global static List<SIP_Participant__c> getdata() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string yr = RestContext.request.params.get('yr');
        system.debug('@@@ ' + yr);
        string quarter = RestContext.request.params.get('q'); 
        system.debug('@@@ ' + quarter);
        List<SIP_Participant__c> lstSipData = new List<SIP_Participant__c>();
        for(SIP_Participant__c sp: [SELECT Id,SIP_Participant_Id__c,Paymix__c,SIP_Eligible_Date__c,SIP_Ineligible_Date__c,Area__c,Area__r.Name,
                                    (SELECT Id, SIP_Participant__c, Comments__c,Full_Quarter_OTE__c, OTE_End_Date__c, OTE_Start_Date__c, PrimaryKey__c,
                                     Quarter_End_Date__c, Quarter_Start_Date__c, Quarter__c, Reason__c FROM SIP_Special_Circumstances__r WHERE Quarter__c =: quarter), 
                                    (SELECT Id, SIP_Participant__c, Applicable_Period__c, Weight__c, Payout_Frequency__c, Performance_Percent__c, 
                                     Payout_Percent__c, SIP_KPI__r.Name, SIP_KPI__r.KPI_Code__c, Status__c,Target__c,Actual__c 
                                     FROM SIP_Measures__r WHERE Applicable_Period__c =: quarter and Status__c  = 'Ready for Payout' 
                                     and Payout_Frequency__c = 'Quarterly') FROM SIP_Participant__c WHERE Year__c =: yr]) {
                                         if(sp.SIP_Measures__r.size() > 0) {
                                             lstSipData.add(sp);
                                         }
                                     }   
        system.debug('lstSipData ' + lstSipData.size());
        return lstSipData;
    }
    
    @AuraEnabled
    public static string chkjobststatus(){
        String resp = '';
        String auth = herokuAuthentication();
        if(auth == 'logged in successfully') {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:IncentiveDynamo'+'/api/auth/chkjobststatus');
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            HttpResponse res = h.send(req); 
            resp = res.getBody();
            system.debug('@@@@@ ' + res.getBody());   
        }  
        return resp;  
    }
    
    @AuraEnabled
    public static string firejob(String input){
        String resp = '';
        String auth = herokuAuthentication();
        if(auth == 'logged in successfully') {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:IncentiveDynamo'+'/api/auth/firejob');
            req.setMethod('POST');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(input);
            HttpResponse res = h.send(req); 
            resp = res.getBody();
            system.debug('@@@@@ ' + res.getBody());   
        }  
         return resp;
    }
    
    @AuraEnabled
    public static string checkifFilePresentInFTP(){
        String resp = '';
        String auth = herokuAuthentication();
        if(auth == 'logged in successfully') {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:IncentiveDynamo'+'/api/auth/');
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            HttpResponse res = h.send(req);  
            resp = res.getBody();
            system.debug('@@@@@ ' + res.getBody());
        }
        return resp;
    }
    @AuraEnabled 
    public static string herokuAuthentication(){ 
        String filestatus = '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:IncentiveDynamo'+'/api/auth/login');
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = h.send(req); 
		system.debug('@@@@@ ' + res.getBody());
        return res.getBody();
    }
}