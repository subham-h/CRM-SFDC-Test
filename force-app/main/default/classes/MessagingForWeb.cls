/*
* Author   : ramadevi@Maersk
* Purpose  : Helper class which contains methods that is used in Omni Flows to get the Group id and to Create Case for Chat.          
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9385   21-11-2023  ramadevi@Maersk            This class contains methods that is used in Omni Flows to get the Group id and to Create Case for Chat. 
*
*/
Global Class MessagingForWeb{ 

    /**
    * @description: Invocable method called from flows, Based on the actionToBePerformed value, either the Queue id is retrieved or Case is updated with prechat values
    * @return  : List of wrapper class outputs
    */  
    @InvocableMethod(label='MessagingAction')
    public static List<outputs> MessagingAction(List<inputs> msgInputs){
        system.debug('serialised-----------'+JSON.serialize(msgInputs));
        if(msgInputs[0].actionToBePerformed == 'getQueuedetails'){
            return MessagingForWeb.getQueue(msgInputs);
        } else if(msgInputs[0].actionToBePerformed == 'CreateCaseAndUpdateMessaging'){
            Contact con;        
            if(msgInputs[0].custEmailId <> NULL && msgInputs[0].custEmailId <> '')  { 
                for (Contact c :[SELECT id,Country__c,Country__r.Name, Country__r.GEO_Code__c,AccountId,Name from Contact where email=:msgInputs[0].custEmailId limit 1]){
                    con = c;
                }            
            }
            //Update the Contact and Account on Messaging End User if it is not updated already
            MessagingSession msg = [SELECT Id,OwnerId,CaseId,Customer_Email__c,Bot_Intercept__c,Customer_Selected_Lang__c,Proactive__c,MessagingEndUserId,MessagingEndUser.ContactId, MessagingEndUser.AccountId from MessagingSession where id=:msgInputs[0].msgId];
            MessagingEndUser msgUser;
        
            if(con <> NULL){
                if(con<>NULL && msg.MessagingEndUser.ContactId == NULL){
                    msgUser = new MessagingEndUser();
                    msgUser.ContactId = con.Id;
                    msgUser.AccountId = con.AccountId;
                    msgUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
                    msgUser.Name = con.Name;
                    msgUser.Id= msg.MessagingEndUserId;
                    
                    msg.Country__c = con.Country__c;    
                }
                if(msgUser <> NULL){
                    update msgUser;
                }
            }
            
            //Update the Prechat values in Messaging Session record
            msg.Brand__c = msgInputs[0].brand;  
            msg.Customer_Selected_Lang__c = msgInputs[0].msgCustomerSelectedLang;
            msg.Bot_Intercept__c = msgInputs[0].msgBotIntercept;    
            msg.Country_Code__c =  msgInputs[0].countryCode;
            msg.Customer_Code__c=  msgInputs[0].caseCustomerCode;
            msg.Customer_Email__c=  msgInputs[0].custEmailId;      
            update msg;
            system.debug('msg updated---'+msg);
            MessagingForWeb.createCaseAndUpdateMessaging(JSON.serialize(msgInputs));
            return null;
        } else {
            system.debug('In else part');
            return null;
        }
        
    }
    
    /**
    * @description: This method creates a case with prechat values received from portal.
    * @return  : void
    */
    public static void createCaseAndUpdateMessaging(String ipStr){        
        //Get contact details and populate country
        Contact con;
        List<MessagingForWeb.caseAndMsgInputs> msgInputs = (List<MessagingForWeb.caseAndMsgInputs>)JSON.deserialize(ipStr, List<MessagingForWeb.caseAndMsgInputs>.class);
        system.debug('msgInputs --'+msgInputs );
        if(msgInputs[0].custEmailId <> NULL && msgInputs[0].custEmailId <> '') {  
            for (Contact c :[SELECT id,Country__c,Country__r.Name, Country__r.GEO_Code__c,AccountId,Name from Contact where email=:msgInputs[0].custEmailId limit 1]){
                con = c;
            }
        }
        MessagingSession msg = [SELECT Id,OwnerId,CaseId,Customer_Email__c,Bot_Intercept__c,Customer_Selected_Lang__c,Proactive__c,MessagingEndUserId,MessagingEndUser.ContactId, MessagingEndUser.AccountId from MessagingSession where id=:msgInputs[0].msgId];
        MessagingEndUser msgUser;
        //Create a new case based on Pre Chat Values
        Case newCase = new Case();   
        newCase.Liner_Brand__c = msgInputs[0].brand;    
        newCase.Subject = msgInputs[0].caseSubject; 
        newCase.Origin = msgInputs[0].caseOrigin; 
        newCase.Case_Channel__c = msgInputs[0].caseChannel; 
        newCase.Delivery_Channel__c = msgInputs[0].caseDeliveryChannel;
        newCase.Direction__c =  msgInputs[0].caseDirection;
        newCase.Portal_On_Behalf_Of__c = msgInputs[0].casePortalOnbehalf;   
        if(msgInputs[0].caseRecordType <> null){
            newCase.recordTypeId = Id.valueof(msgInputs[0].caseRecordType);
        }
        newCase.Send_Case_Closure__c = 'No';    
        newCase.ownerId = '0052o000009UFFIAA4';//01 chat bot - Bot User assigned on Bot
        newCase.status= 'New';
        if(con <> null) {
            newCase.contactId = con.Id;
            
        } else {
            newCase.SuppliedEmail = msgInputs[0].custEmailId;
        }       
        insert newCase;
        system.debug('newCase##'+newCase);

        //Update the Messaging Session with Case
        msg.CaseId = newCase.Id;        
        msg.Case_Id__c = String.valueof(newCase.Id);
        update msg;
        system.debug('new Msg updated'+msg);

        if(msgUser <> NULL){
            update msgUser;
            system.debug('msg user updated'+ msgUser);
        }
        
    }
    
    /**
    * @description: This method gets the queue id based on the Contact Country and Delivery Channel.
    * @return  : list of outputs wrapper
    */    
    public static List<outputs> getQueue(List<inputs> msgInputs){
        List<outputs> opList = new List<outputs>();
        if(msgInputs<>null){
            Contact custContact;
            List<Contact> conList = new List<Contact>();
            String conEmailId;
            String brand;
            Id msgId;
            String countryCode;
            String deliveryChannel;
            Message_Routing_Configuration__c routeConfig;
            Case cse;            
            
            for(inputs ips : msgInputs){
                conEmailId = ips.custEmailId;
                brand = ips.brand;
                msgId = ips.msgId;
                countryCode = ips.countryCode;
                deliveryChannel = ips.caseDeliveryChannel;
            }
            
            MessagingSession msgSession = [SELECT id,caseId from MessagingSession where id=:msgId][0];
            
            if(msgSession <> null && msgSession.caseId <> null && deliveryChannel == NULL){
                cse = [SELECT id,Delivery_Channel__c from Case where id=:msgSession.caseId];
                deliveryChannel = cse.Delivery_Channel__c;
            }
            
            if(conEmailId <> NULL && conEmailId <> '') {
                conList = [SELECT id,Country__c, Country__r.Name, Country__r.GEO_Code__c from Contact where email=:conEmailId limit 1];
            } 
            //Check for Delivery Channel, For non Twill Users based routing to queue will be based on Contact Country
            if(deliveryChannel <> 'MaerskGo') {
                if(conEmailId <> NULL && conEmailId <> '') {
                    conList = [SELECT id,Country__c, Country__r.Name, Country__r.GEO_Code__c from Contact where email=:conEmailId limit 1];
                    } 
                if(conList.size()>0){
                    custContact = conList[0];
                }
                //Message_Routing_Configuration__c routeConfig;
                system.debug('contact ---'+custContact+'--brand--'+brand );
                //If contact and contact country exist, Query Message Routing Configuration based on Contact Country
                if(custContact <> NULL && brand <> NULL && !String.isblank(brand)){ 
                    for(Message_Routing_Configuration__c  msgRoute:[SELECT id,Queue_Id__c,Queue_Name__c,Route_Type__c from Message_Routing_Configuration__c where Country_Name__c = :custContact.Country__r.Name and Liner_Brand__c=:brand limit 1]){
                        routeConfig = msgRoute;
                    }
                } else if(countryCode<> NULL && countryCode<>'' && !String.isblank(brand)){
                    //If Contact does not exist then based on the Country Code from the Prechat value query the Message Routing Configuration
                    for(Message_Routing_Configuration__c  msgRoute:[SELECT id,Queue_Id__c,Queue_Name__c,Route_Type__c from Message_Routing_Configuration__c where Country_Code__c =:countryCode and Liner_Brand__c=:brand limit 1]){
                        routeConfig = msgRoute;
                    }
                } else {
                    //fallback
                }
            }else {
                //For Twill Users Routing will be based on Area, Here returing the Global Queue if Area Queue is busy.
                routeConfig = [SELECT id,Queue_Id__c,Queue_Name__c,Route_Type__c from Message_Routing_Configuration__c where IsTwill__c = True and Twill_Area__c='Global'][0];
            }                
            
            if(routeConfig <> null){
                outputs res = new outputs();
                res.queueId = Id.valueof(routeConfig.Queue_Id__c);
                res.routeType = routeConfig.Route_Type__c;
                opList.add(res);
            } else {     
                //For fallback queue, If the Message Routing Configuration does not exist for contact 
                outputs res = new outputs();                
                Group defaultGroup = [SELECT id,DeveloperName, name from Group where type='queue' and DeveloperName='All_Messaging_User'];
                if(defaultGroup <> NULL){
                    res.queueId = defaultGroup.Id;
                    res.routeType = 'Queue';
                }
                opList.add(res);
            }
        }
        return opList;        
    }
    
    global class inputs{        
        @InvocableVariable
        global String actionToBePerformed;
        
        @InvocableVariable
        global String custEmailId;

        @InvocableVariable
        global String brand;

        @InvocableVariable
        global ID msgId;
        
        @InvocableVariable
        global String caseType;
        
        @InvocableVariable
        global String caseOrigin;
        
        @InvocableVariable
        global String caseDeliveryChannel;
        
        @InvocableVariable
        global String caseCustomerCode;
        
        @InvocableVariable
        global String caseChannel;
        
        @InvocableVariable
        global String caseSubject;
        
        @InvocableVariable
        global String caseRecordType;
        
        @InvocableVariable
        global String caseDirection;
        
        @InvocableVariable
        global String casePortalOnbehalf;
        
        @InvocableVariable
        global String msgCustomerSelectedLang;
        
        @InvocableVariable
        global String msgBotIntercept;
        
        @InvocableVariable
        global String msgProactive;
        
        @InvocableVariable
        global String countryCode;    
    }
    
    global class outputs{
        @InvocableVariable
        global Id queueId;
    
        @InvocableVariable
        global Id caseId;
        
        @InvocableVariable
        global String routeType;
    }
    
    public class caseAndMsgInputs{
        public String custEmailId;
        public String brand;
        public ID msgId;
        public String caseType;
        public String caseOrigin;
        public String caseDeliveryChannel;
        public String caseCustomerCode;
        public String caseChannel;
        public String caseSubject;
        public String caseRecordType;
        public String caseDirection;
        public String casePortalOnbehalf;
        public String msgCustomerSelectedLang;
        public String msgBotIntercept;
        public String msgProactive; 
        public String countryCode;     
    }
}