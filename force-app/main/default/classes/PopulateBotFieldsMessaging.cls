/*
* Author   : ramadevi@Maersk
* Purpose  : This method checks for the Prechat values and Other fields and returns the Output values to Bot, These values are used in Rules in Bots.           
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9385   21-11-2023  ramadevi@Maersk           This method checks for the Prechat values and Other fields and returns the Output values to Bot, These values are used in Rules in Bots. This class also contains the method to update the Case Owner as 01 Chat Bot for Messaging Sessions which are still with Bot.
*
*/
public class PopulateBotFieldsMessaging {
    public class botInput{
        @InvocableVariable(required=true)
        public string msgSessionid;
        @InvocableVariable
        public string Proactive;
    }
    
    public class chatInfo{
        @InvocableVariable(required=true)
        public string Brand;
        @InvocableVariable(required=true)
        public string Brandlink;
        @InvocableVariable(required=true)
        public string BotIntercept;
        @InvocableVariable(required=true)
        public string ContactFirstName;
        @InvocableVariable(required=true)
        public string botdetails;
        @InvocableVariable(required=true)
        public string Error;
        @InvocableVariable(required=true)
        public string IsTwill;
    }
     
    /**
    * @description: Invocable method called from bot to update the Case Owner as 01 Chat Bot and to retrieve details to use in bot.
    * @return  : List of wrapper class chatInfo
    */
    @InvocableMethod(label='GetWelcomechatInfoMessaging')
    public static List<chatInfo> getChatInfo(List<botInput> lstBotInput){
        List<chatInfo> lstchatInfo = new List<chatInfo>();
        List<MessagingSession> msgSessionToUpdate =new List<MessagingSession>();
        String Brand;  
        String BrandLink;
        String BotIntercept;
        String ChatButtonId;
        String ContactFirstName;
        String botdetails;
        String liveChatButtonDevName;       
        String isTwillUser='False';
        
        try{
            system.debug('lstBotInput --- populate ---'+lstBotInput);
            String msgSessionId=lstBotInput[0].msgSessionid;
            String Proactive=lstBotInput[0].Proactive;            
            MessagingSession msgSession = [Select id,Brand__c,Bot_Intercept__c,EndUserContactId,Proactive__c,caseid from MessagingSession where id=:msgSessionId];
            
            List<Case> lstcase = [Select id,ownerid,Delivery_Channel__c,Country__c,Country__r.Name from case where id=:msgSession.caseid limit 1];
            if(lstcase!=null)
            {
                updateowner(lstcase[0].id);
                 //Twill Changes for Brand Unification
                if(lstcase[0].Delivery_Channel__c == 'MaerskGo'){
                    //to be changed as Maersk-Go
                    isTwillUser = 'True';
                    if(lstcase[0].Country__c<> NULL){
                        if(lstcase[0].Country__r.Name == 'China'){
                            botdetails = 'TwillChina';
                        }
                    }
                }
            }            
            
            if(msgSession!=null){
                Brand=msgSession.Brand__c;                
                if(Brand=='Maersk Line'){                    
                    Brand='Maersk';
                }
                List<Brand__mdt> lstbrandmdt = [Select id,website__c from Brand__mdt where masterlabel=:Brand limit 1];
                BrandLink=lstbrandmdt[0].website__c;                
                
                if(msgSession.EndUserContactId!=null){
                    List<Contact> lstcontact = [Select id ,FirstName from Contact where id=:msgSession.EndUserContactId limit 1];
                    ContactFirstName=lstcontact[0].FirstName;
                }
                
                if(msgSession.Bot_Intercept__c!=null && msgSession.Bot_Intercept__c.contains('.maersk.com/book/')){
                    BotIntercept='Book';
                }
                else{
                    BotIntercept=null;  
                }       
            }
            
            //Update the Proactive Field value
            if(Proactive!=null)
            {
                if(Proactive=='Proactive'){
                    Proactive='Proactive - Main Menu';
                }                
                msgSession.Proactive__c=Proactive;
                msgSessionToUpdate.add(msgSession);
            }
            if(!msgSessionToUpdate.isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                Update msgSessionToUpdate;
                TriggerExecutionController.skipCaseTrigger(false);
            }
                       
            lstchatInfo=getChatInfo(Brand,BrandLink,BotIntercept,ContactFirstName,botdetails,null,isTwillUser);
            
        }
        catch(Exception e){
            String error=e.getMessage();
            lstchatInfo=getChatInfo(null,null,null,null,null,error,isTwillUser);
            ErrorLogger.writeErrors( 'SFDC', 'MessagingSession', 'PopulateBotFieldsMessaging.getChatInfo', new list<Exception>{e});
            
        }
        system.debug('lstchatInfo'+lstchatInfo);
        return lstchatInfo;
        
    }
    
    /**
    * @description: Assigns the values in wrapper class.
    * @return  : List of wrapper class chatInfo
    */
    public static List<chatInfo> getChatInfo(string Brand,string BrandLink, string BotIntercept,String ContactFirstName,String botdetails, String Err,String isTwill){
        List<chatInfo> lstchatInfo = new List<chatInfo>();
        chatInfo info = new chatInfo();                  
        info.Brand = Brand;
        info.BrandLink = BrandLink;
        info.BotIntercept = BotIntercept;
        info.ContactFirstName = ContactFirstName;
        info.botdetails = botdetails;
        info.Error= Err;
        info.IsTwill = IsTwill;
        lstchatInfo.add(info);
        return lstchatInfo;
    }
    
    /**
    * @description: This method updates the Case Owner as ChatBot user when the Messaging Session is with Chat Bot
    * @return  : void
    */
    @future
    public static void updateowner(Id caseid)
        {  
            TriggerExecutionController.skipCaseTrigger(true);
            List<Case> casestoupdate =new List<case>();
            for(Case c:[Select id,ownerid from case where id=:caseid] ){
                    c.ownerid=Label.ChatBotUserId;
                    casestoupdate.add(c);
                }            
            if(!casestoupdate.isEmpty()){
                update casestoupdate;
             }
         TriggerExecutionController.skipCaseTrigger(false);
        }
}