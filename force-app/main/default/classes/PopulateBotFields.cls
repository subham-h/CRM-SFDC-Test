/**
* Description  : Invocable class for making external webservice callout to GCSS for getting party and task details through Bot. 
* 
* Version    Ref Number     Date                Owner                               Description
*******************************************************************************************************************
* 1.0        SC-7382       23-03-2023          Meghna@maersk.com                    Created getChatInfo Invocable method which is called from Einstein Chatbot to get values on chat load instead of flow in fisrt dialogs. 
* 2.0        SC-8903       29-09-2023          ramadevi.p@maersk.com                Check if chat is for Twill User and for China Twill User it should be routed to Technical China 
* 3.0        SC-9951       22-05-20234         Shahanawaz@maersk.com                Sealand & HSUD Overall decommissioning

*-------------------------------------------------------------------------------------------------------------------
*/
public class PopulateBotFields {
    public class botInput{
        @InvocableVariable(required=true)
        public string lctid;
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
* @description | SC-7382 get values for welcome and main menu dialog  |
* @param lstBotInput accepts the bot input
* @return List<chatInfo> containing the values like Brand,BrandLink etc.
*/ 
    @InvocableMethod(label='GetWelcomechatInfo')
    public static List<chatInfo> getChatInfo(List<botInput> lstBotInput){
        List<chatInfo> lstchatInfo = new List<chatInfo>();
        List<LiveChatTranscript> LctToUpdate =new List<LiveChatTranscript>();
        String Brand;   
        String BrandLink;
        String BotIntercept;
        String ChatButtonId;
        String ContactFirstName;
        String botdetails;
        String liveChatButtonDevName;
        String isTwillUser='False';
        
        try{
            String LctId=lstBotInput[0].lctid;
            String Proactive=lstBotInput[0].Proactive;
            List<General_Key_Value_Configurations__mdt> metadataRecords = [SELECT First_Field_Value__c, MasterLabel FROM General_Key_Value_Configurations__mdt WHERE MasterLabel IN ('ChinaButton', 'SpanishButton', 'SpanishButton1')];
            Map<String, General_Key_Value_Configurations__mdt> metadataMap = new Map<String, General_Key_Value_Configurations__mdt>();
            for (General_Key_Value_Configurations__mdt metadataRecord : metadataRecords) {
                if (String.isNotBlank(metadataRecord.First_Field_Value__c)) {
                    List<String> values = metadataRecord.First_Field_Value__c.split(',');
                    for (String value : values) {
                        metadataMap.put(value, metadataRecord);
                    }
                }
            }
            
            LiveChatTranscript lct = [Select id,Bot_Intercept__c,ContactId,Proactive__c,Liner_Brand__c,caseid, LiveChatButton.DeveloperName from LiveChatTranscript where id=:LctId];
            
            List<Case> lstcase = [Select id,ownerid,Delivery_Channel__c,Country__c,Country__r.Name, Country__r.GEO_Code__c from case where id=:lct.caseid limit 1];
            if(lstcase!=null){
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
            
            if(lct!=null){
                Brand=lct.Liner_Brand__c;
                //SC-9951
                if(lstcase != null && !lstcase.isEmpty() && (Brand == 'MCC' || Brand == 'Sealand' || Brand == 'Seago')  && lstcase[0].Country__r.GEO_Code__c != 'ID' && lstcase[0].Country__r.GEO_Code__c != 'PH'){
                    Brand = 'Maersk';
                    lct.Liner_Brand__c = 'Maersk Line';
                }
                else if(Brand=='Maersk Line'){                    
                    Brand='Maersk';
                }
                List<Brand__mdt> lstbrandmdt = new List<Brand__mdt>([Select id,website__c from Brand__mdt where masterlabel=:Brand limit 1]);
                BrandLink = !lstbrandmdt.isEmpty() ? lstbrandmdt[0].website__c : null;
                
                if(lct.contactid!=null){
                    List<Contact> lstcontact = [Select Id, FirstName from Contact where id=:lct.contactid limit 1];
                    ContactFirstName=lstcontact[0].FirstName;
                }
                
                if(lct.Bot_Intercept__c!=null && lct.Bot_Intercept__c.contains('.maersk.com/book/')){
                    BotIntercept='Book';
                }
                else{
                    BotIntercept=null;  
                }       
            }
            
            if(Proactive != null){
                if(Proactive == 'Proactive'){
                    Proactive = 'Proactive - Main Menu';
                }                
                lct.Proactive__c = Proactive;                
            }
            LctToUpdate.add(lct);
            if(lct != null) {
                Id liveChatButtonId = lct.LiveChatButtonId;
                LiveChatButton liveChatButton = [SELECT DeveloperName FROM LiveChatButton WHERE Id = :liveChatButtonId LIMIT 1];
                liveChatButtonDevName = liveChatButton.DeveloperName;
            }
            
            if(botdetails == NULL || botdetails == ''){   // Added to check if botdetails is set for China if not then we check the MDT
                if (metadataMap.containsKey(liveChatButtonDevName)) {
                    General_Key_Value_Configurations__mdt metadataRecord = metadataMap.get(liveChatButtonDevName);
                    botdetails = metadataRecord.MasterLabel;
                }
                else
                {
                    botdetails = null;
                }
            }
            
            if(!LctToUpdate.isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                update LctToUpdate;
                TriggerExecutionController.skipCaseTrigger(false);
            }
            lstchatInfo=getChatInfo(Brand,BrandLink,BotIntercept,ContactFirstName,botdetails,null,isTwillUser);            
        }
        catch(Exception e){
            String error=e.getMessage();
            lstchatInfo=getChatInfo(null,null,null,null,null,error,isTwillUser);
            ErrorLogger.writeErrors( 'SFDC', 'LiveChatTranscript', 'PopulateBotFields.getChatInfo', new list<Exception>{e});            
        }
        return lstchatInfo;        
    }
    
    public static List<chatInfo> getChatInfo(string Brand,string BrandLink, string BotIntercept,String ContactFirstName,String botdetails, String Error,String isTwill){
        List<chatInfo> lstchatInfo = new List<chatInfo>();
        chatInfo info = new chatInfo();                  
        info.Brand = Brand;
        info.BrandLink = BrandLink;
        info.BotIntercept = BotIntercept;
        info.ContactFirstName = ContactFirstName;
        info.botdetails = botdetails;
        info.Error= Error;
        info.IsTwill = IsTwill;
        lstchatInfo.add(info);
        return lstchatInfo;
    }
    
    @future
    public static void updateowner(Id caseid){ 
        List<Case> casestoupdate =new List<case>();
        for(Case c:[Select id,ownerid from case where id=:caseid] ){
            c.ownerid=Label.ChatBotUserId;
            casestoupdate.add(c);
        }
        
        if(!casestoupdate.isEmpty()){
            update casestoupdate;
        }
    }
    
}