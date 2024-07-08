/*
Description  : Queueable class to Perform callout to Azure to get Text Translations 

* version       Ref Number    Date                Owner                                       Description
*******************************************************************************************************************
* V1.0                        27/11/2023          ranjan.kumar.1@maersk.com                   Queueable class Perform callout to get Translations
*-------------------------------------------------------------------------------------------------------------------
*/

public with sharing class CaseTranslatorQueuable implements Queueable , Database.AllowsCallouts {

        public Map<Id,Case> caseMap;
        
        public CaseTranslatorQueuable (Map<Id,Case> caseMap) {
           this.caseMap= caseMap;
        }
        
        public void execute(QueueableContext context) {
            List<String> strtoTransList=new List<String>();
            for(Case csObj:caseMap.values()){
                strtoTransList.add(csObj.Description);
            }
            List<TranslateWrapper> translatedStringList=CaseTranslator.translate(strtoTransList, 'en');
            if(translatedStringList==null){
                return;
            }
            Integer counter=0;
            List<FeedItem> feedList=new  List<FeedItem>();
            for(Case csObj:caseMap.values()){
                if(translatedStringList.get(counter)==null ||
                    translatedStringList.get(counter).translations[0]==null ||
                    'en'.equalsIgnoreCase( translatedStringList.get(counter).detectedLanguage?.language))
                {
                    continue;
                }
                FeedItem feed = new FeedItem();
                feed.ParentId = csObj.Id;
                String feedBody='AUTOMATIC TRANSLATION\n '+translatedStringList.get(counter).translations[0].text;
                feedBody=(feedBody.length()>10000?feedBody.substring(0,9900):feedBody);
                feed.Body =feedBody;
                feedList.add(feed);
                counter++;
            }
            if(!feedList.isEmpty()){
                Database.insert(feedList, false);
            }
        }
}