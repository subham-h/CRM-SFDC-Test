/*
Description  : Queueable class to Perform callout to Azure to get Text Translations 

* version       Ref Number    Date                Owner                                       Description
*******************************************************************************************************************
* V1.0                        27/11/2023          ranjan.kumar.1@maersk.com                   Queueable class Perform callout to get Translations
*-------------------------------------------------------------------------------------------------------------------
*/

public with sharing class FeedTranslatorQueueable implements Queueable , Database.AllowsCallouts {

    public List<FeedItem> feedList;
    
    public FeedTranslatorQueueable (List<FeedItem> feedList) {
       this.feedList= feedList;
    }
    
    public void execute(QueueableContext context) {
        List<String> strtoTransList=new List<String>();
        for(FeedItem feedObj:feedList){
            strtoTransList.add(feedObj.Body);
        }
        List<TranslateWrapper> translatedStringList=CaseTranslator.translate(strtoTransList, 'ja');
        if(translatedStringList==null){
            return;
        }
        Integer counter=0;
        List<FeedComment> feedCommentList=new  List<FeedComment>();
        for(FeedItem feedObj:feedList){
            if(translatedStringList.get(counter)==null ||
                translatedStringList.get(counter).translations[0]==null ||
                'ja'.equalsIgnoreCase( translatedStringList.get(counter).detectedLanguage?.language)){
                continue;
            }
            FeedComment feedCommentObj = new FeedComment();
            feedCommentObj.FeedItemId = feedObj.Id;
            feedCommentObj.IsRichText=false;
            String commentBody='AUTOMATIC TRANSLATION:\n '+translatedStringList.get(counter).translations[0].text;
            commentBody=(commentBody.length()>10000?commentBody.substring(0,9900):commentBody);
            feedCommentObj.CommentBody =commentBody;
            feedCommentList.add(feedCommentObj);
            counter++;
        }
        if(!feedCommentList.isEmpty()){
            Database.SaveResult[] resList= Database.insert(feedCommentList, false);
        }
    }
}