public class InvocablecasecreationTest {
    /*public static Map<Id,Case> maplctcaseid = new Map<Id,Case>();
     public class botInput{
        @InvocableVariable(required=true)
        public string lctid;
     }

    @InvocableMethod(label='createcase')
    public static void createcase(List<botInput> newlctlist)
    {
        system.debug('Inside invocable');
        List<Case> lstnewcase= new List<Case>();
        Integer index=0;
        String lctid = newlctlist[0].lctid;
              Case cs = new Case();
              cs.RecordTypeId='012D0000000Qoom';
              cs.Status='New';
              cs.Case_Channel__c='Chat';
              cs.Liner_Brand__c='Maersk Line';
              cs.Direction__c='Not Known';
              cs.Description = 'created from invocable apex';
              maplctcaseid.put(lctid,cs);
              
        system.debug('maplctcaseid'+maplctcaseid);
        insert maplctcaseid.values();
        system.debug('maplctcaseid'+maplctcaseid);
       LiveChatTranscriptFieldPopulator.updatecaseidonlct(maplctcaseid);
        
    }
    
        public static void updatecaseidonlct(Map<Id,Case> maplctcaseid){
        system.debug('maplctcaseid in second method'+maplctcaseid);
        List<LiveChatTranscript> lstlct =[Select id,caseid from LiveChatTranscript where id in:maplctcaseid.keyset()];
        List<LiveChatTranscript> lctupdate= new List<LivechatTranscript>();
        for(LiveChatTranscript lct:lstlct)
        {
            lct.caseid = maplctcaseid.get(lct.id).Id;
            system.debug('second method caseid'+maplctcaseid.get(lct.id).Id);
            lctupdate.add(lct);
        }
        
        update lctupdate;  
        system.debug('lct update meghna'+lctupdate);
    }*/

}