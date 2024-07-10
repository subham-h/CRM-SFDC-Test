public class ChatCaseCreation{
    public static Map<Id,Case> maplctcaseid = new Map<Id,Case>();
     public class flowInput{
        @InvocableVariable(required=true)
        public string msgId;
     }

    @InvocableMethod(label='Messaging Session - createcase')
    public static void createcase(List<flowInput> newMsglist)
    {
        system.debug('Inside invocable');
        List<Case> lstnewcase= new List<Case>();
        Integer index=0;
        String msgid = newMsglist[0].msgid ;
              Case cs = new Case();
              cs.RecordTypeId='012D0000000QoomIAC';
              cs.Status='New';
              cs.Case_Channel__c='Chat';
              cs.Liner_Brand__c='Maersk Line';
              cs.Direction__c='Not Known';
              cs.SuppliedEmail = 'ramadevi.p@maersk.com';
              cs.Description = 'created from invocable apex';              
              cs.Case_Visibility__c = 'All Users';// added to avoid validation error
              maplctcaseid.put(msgId,cs);
              
        system.debug('maplctcaseid'+maplctcaseid);
        TriggerExecutionController.skipCaseTrigger(true);  
            insert maplctcaseid.values();
        TriggerExecutionController.skipCaseTrigger(false);
        system.debug('maplctcaseid'+maplctcaseid);
       ChatCaseCreation.updatecaseidonlct(maplctcaseid);
        
    }
    
        public static void updatecaseidonlct(Map<Id,Case> mapMsgcaseid){
        system.debug('maplctcaseid in second method'+maplctcaseid);
        List<MessagingSession> lstmsg =[Select id,caseid from MessagingSession where id in:mapMsgcaseid.keyset()];
        List<MessagingSession> msgupdate= new List<MessagingSession>();
        for(MessagingSession msg:lstmsg)
        {
            msg.caseid = maplctcaseid.get(msg.id).Id;
            system.debug('second method caseid'+mapMsgcaseid.get(msg.id).Id);
            msgupdate.add(msg);
        }
        
        update msgupdate;         

}
}