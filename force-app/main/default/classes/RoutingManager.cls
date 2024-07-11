/*
* Author   : Urvish@UST
* Purpose  : Rest resource class used for finding primary agent is out of office for routing record.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-2149    27-07-2021    Urvish@UST               Created.
* 2.0      SC-4822    07-04-2022    Sriram@maersk            Updated
*/


@RestResource(urlMapping='/routing/*')
global with sharing class RoutingManager {

    @HttpGet
    global static RoutingWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        map<String,String> allParams = RestContext.request.params;
        String routingId;
        String dnis;
        String pin;
        String ani;
        RoutingWrapper objWrap = new RoutingWrapper();
        if(allParams.keyset().size() == 2)
        {
            dnis = RestContext.request.params.get('dnis');
            if(allParams.containsKey('pin'))
            {
                pin = RestContext.request.params.get('pin');
                routingId = pin+'-'+dnis;
            }
            if(allParams.containsKey('ani'))
            {
        		ani = RestContext.request.params.get('ani');
                routingId = ani+'-'+dnis;
            }
        }
        
        //String routingId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(String.isBlank(dnis) || (String.isBlank(pin) && String.isBlank(ani) ))
        {
            objWrap.isError = true;
            objWrap.errorMessage = 'Please enter valid parameters.';
            return objWrap;
        }
        
        
        
        List<OutOfOffice> objOOO = new List<OutOfOffice>();
        
        try{
        //Querying Routing record based on searchstring
        List<Routing_Maersk__c> objRouting = [SELECT Id,Primary_Target__r.Email,Primary_Target__r.Telephony_Agent_ID__c,Backup_Target__r.Email, Backup_Target__r.Telephony_Agent_ID__c,Primary_Target__r.Name,
        Primary_Skill_Group__c, Backup_Skill_Group__c, Additional_Backup_Skill_Group__c, Supervisor__r.Email, Supervisor__r.Telephony_Agent_ID__c,Account__r.Name,Account__r.Customer_Status_Reason__c,Account__r.SCV_Status__c 
        FROM Routing_Maersk__c WHERE Voice_Routing_Unique_ID__c = :routingId and RecordType.name = 'Voice' limit 1];
        if(objRouting.size() > 0)
        {
            objWrap.isError = false;
            if(objRouting[0].Primary_Target__c != null)
            {
                objWrap.primaryTargetAgentId = objRouting[0].Primary_Target__r.Telephony_Agent_ID__c;
                objWrap.primaryTargetName = objRouting[0].Primary_Target__r.Name;
                objWrap.primaryTargetEmail = objRouting[0].Primary_Target__r.Email;
                
                //Querying OOO record based on Primary Target's email
                objOOO = [SELECT Id,StartDate, EndDate, Message, IsEnabled,User.TimeZoneSidKey from OutOfOffice where User.email = :objRouting[0].Primary_Target__r.Email];
            }
            
            objWrap.primarySkillGroup = objRouting[0].Primary_Skill_Group__c;
            if(objRouting[0].Backup_Target__c != null)
            {
                objWrap.backupTargetAgentId = objRouting[0].Backup_Target__r.Telephony_Agent_ID__c;
                objWrap.backupTargetEmail = objRouting[0].Backup_Target__r.Email;
            }
            objWrap.backupSkillGroup = objRouting[0].Backup_Skill_Group__c;
            objWrap.additionalBackupSkillGroup = objRouting[0].Additional_Backup_Skill_Group__c;
            if(objRouting[0].Supervisor__c != null)
            {
                objWrap.supervisorAgentId = objRouting[0].Supervisor__r.Telephony_Agent_ID__c;
                objWrap.supervisorEmail = objRouting[0].Supervisor__r.Email;
            }
            
            objWrap.isSuspended = 'False';
            if(objRouting[0].Account__c != null)
            {
                objWrap.accountName = objRouting[0].Account__r.Name;
                if(objRouting[0].Account__r.SCV_Status__c == 'Suspended' && objRouting[0].Account__r.Customer_Status_Reason__c == 'Unethical Behaviour'){
                    objWrap.isSuspended = 'True';
                }               
            }
            objWrap.outOfOffice = false;
            objWrap.publicHoliday = false;
            
            if(objOOO.size() > 0)
            {
                String strtdt = objOOO[0].StartDate.format('yyyy-MM-dd HH:mm:ss',objOOO[0].User.TimeZoneSidKey);
                Datetime strtdate = Datetime.valueOf(strtdt);
                Date startDate = Date.newInstance(strtdate.year(), strtdate.month(), strtdate.day());
                Date endDate = Date.newInstance(objOOO[0].EndDate.year(), objOOO[0].EndDate.month(), objOOO[0].EndDate.day());
                
                if(objOOO[0].IsEnabled = true && system.today() >= startdate && system.today() <= endDate)
                {
                    
                    //checking for Public holiday in Out of office records
                    if(objOOO[0].Message.toUpperCase().Contains(System.Label.Routing_Public_Holiday))
                    {
                        objWrap.publicHoliday = true;
                    }
                    else
                    {
                        objWrap.outOfOffice = true;
                    }
                }
            }
        }
        else
        {
            objWrap.isError = true;
            objWrap.errorMessage = System.Label.Routing_Record_Error;
            
            
        }
        }
        catch (Exception e)
        {
            system.debug('exception' + e.getMessage());
            objWrap.isError = true;
            objWrap.errorMessage = System.Label.Routing_Error_Msg;
            return objWrap;
        }
        return objWrap;
    }
    
    global class RoutingWrapper{
        public boolean outOfOffice {get; set;}
        public boolean publicHoliday {get; set;}
        public String primaryTargetAgentId {get; set;}
        public String primaryTargetName {get; set;}        
        public String primarySkillGroup {get; set;}
        public String backupTargetAgentId {get; set;}
        public String backupSkillGroup {get; set;}
        public String additionalBackupSkillGroup {get; set;}
        public String supervisorAgentId {get; set;}
        public String accountName {get; set;}
        public String isSuspended {get; set;}
        public boolean isError {get; set;}
        public String errorMessage {get; set;}
        public String primaryTargetEmail {get; set;}
        public String backupTargetEmail {get; set;}
        public String supervisorEmail {get; set;}
        
    }
}