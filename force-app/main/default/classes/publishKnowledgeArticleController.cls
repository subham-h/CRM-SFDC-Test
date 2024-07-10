/*
Description  : Customize Knowledge publish action

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          01/01/2020         sreya.v@maersk.com                    Customize Knowledge publish action
* V2.0			01/06/2020		   sreya.v@maersk.com					 Mandate one entry for each data category group.

*-------------------------------------------------------------------------------------------------------------------
*/

public with sharing class publishKnowledgeArticleController {
    
    @AuraEnabled
    public static messageWrap publishArticle(string knowId){
        system.debug('knowledgeId'+knowId);
        
        Boolean hasGlobalPermission = FeatureManagement.checkPermission('Publish_Global_Articles'); 
        Boolean hasNonGlobalPermission = FeatureManagement.checkPermission('Publish_Non_Global_Articles'); 
        List<String> geoCat = new List<String>();
        List<String> allCat = new List<String>();
        
        // Query the article data based on the knowledge Id
        Knowledge__kav articleData = [select Id,KnowledgeArticleId,Title,publishstatus,MasterVersionId,IsMasterLanguage,TranslationCompletedDate from Knowledge__kav where id =: knowId];
        system.debug('articledata'+articleData);
        messageWrap msg = new messageWrap();
        
        if(articleData.publishstatus == 'Draft'){
            
            String artId = articleData.IsMasterLanguage ? knowId : articleData.MasterVersionId;
            
            // getting the data category list for the article with article id of master version.       
            for(Knowledge__DataCategorySelection dataCat : [SELECT ParentId,DataCategoryName,DataCategoryGroupName FROM Knowledge__DataCategorySelection where ParentId =: artId]){             
                allCat.add(dataCat.DataCategoryGroupName);
                if(dataCat.DataCategoryGroupName == 'Geography'){
                    geoCat.add(dataCat.DataCategoryName);
                }   
            } 
   
            // checking if 1 entry is there for all the data category group.
            if(allCat.contains('Geography') && allCat.contains('Type') && allCat.contains('Liner_Brand')){
                
                if(geoCat.size()>0 && geoCat != null && !geoCat.isEmpty()){
                    //Check the user has "publish global article" custom permission if the article contain global category. 
                    if(geoCat.contains('Global') || geoCat.contains('All') ){
                        if(hasGlobalPermission){
                            msg = publishKnowledgeArticle(articleData);
                            
                        }
                        else{
                            msg.message = Label.GlobalPublishError;
                            msg.messageType = 'error';
                        }              
                    }
                    //Check the user has "publish non-global article" custom permission if the article doesn't contain global category. 
                    else if(!geoCat.contains('Global')){
                        if(hasNonGlobalPermission){
                            msg = publishKnowledgeArticle(articleData);
                        }
                        else{
                            msg.message = Label.GeneralPublishError;
                            msg.messageType = 'error';
                        }
                    }           
                }
            }
            // throwing error to make sure 1 entry is there for each data category.
            else{
                
                msg.message = Label.MandateDataCategory;
                msg.messageType = 'error';
            }
            
        }
        //Prevent publishing of the article if it's already published.
        else if(articleData.publishstatus == 'Online'){
            msg.message = Label.PublishedAlert;
            msg.messageType = 'info';
        }
        //Prevent publishing of the article if it's archived.
        else if(articleData.publishstatus == 'Archived'){
            msg.message = Label.ArchivedAlert;
            msg.messageType = 'info';
        }
        
        
        return msg;     
        
    }
    @AuraEnabled
    public static messageWrap publishKnowledgeArticle(Knowledge__kav articleData){
        
        messageWrap msg = new messageWrap();  
        List<Knowledge__kav> translateVersions = new List<Knowledge__kav>();
        //Check if the article is master article. Added the logic considering translated versions.
        if(articleData.IsMasterLanguage){
            KbManagement.PublishingService.publishArticle(articleData.KnowledgeArticleId, true);
            translateVersions = [select Id,KnowledgeArticleId,Title,MasterVersionId,IsMasterLanguage 
                                 from Knowledge__kav 
                                 where MasterVersionId =: articleData.id];       
            system.debug('translateVersions'+translateVersions);
            if(translateVersions.size()>1){
                msg.message = Label.SentForPublication;
                msg.message = msg.message+ '\n\n' + 'Success! '+ articleData.Title +' has been published.';
                msg.messageType = 'success';
                
            }
            else{
                msg.message = 'Success! '+ articleData.Title +' has been published.';
                msg.messageType = 'success';
            }
            
        }
        else{
            //Get the source article if it's not master article.
            Knowledge__kav sourceArticle = [select Id,KnowledgeArticleId,Title,publishstatus,MasterVersionId 
                                            from Knowledge__kav 
                                            where id =: articleData.MasterVersionId]; 
            // Allows publication of translated article if source article is published.
            if(sourceArticle.publishstatus == 'Online'){
                KbManagement.PublishingService.completeTranslation(articleData.Id);
                msg.message = 'Success! '+ articleData.Title +' has been published.';
                msg.messageType = 'success';
            }  
            // Translated article will be send for publication if the source article is not published.
            else if(sourceArticle.publishstatus == 'Draft'){
                if(articleData.TranslationCompletedDate == null && articleData.PublishStatus == 'Draft'){
                    KbManagement.PublishingService.completeTranslation(articleData.Id);
                    
                    msg.message = Label.PublishTranslation;
                    msg.message = msg.message +'\n\n'+ articleData.Title + ' has been sent for publication';
                    msg.messageType = 'Info';
                } 
                else{
                    msg.message = Label.CompletedTranslation;
                    msg.messageType = 'Info';
                }
                
            } 
            
        }
        
        return msg;
    }
    public class messageWrap{
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String messageType{get;set;}
    }
    
}