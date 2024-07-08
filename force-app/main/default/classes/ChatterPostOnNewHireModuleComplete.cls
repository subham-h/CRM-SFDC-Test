/*
 * Purpose  : To Post Chatter on OnBoarding Plan whenever a module on this is completed. 
 *        
 * Revision Ref Number  Date          Owner                                Description
 * -------- ----------   -----------    -------------------                -----------
 * 1.0    #RQ-004533   11/24/2016    ramadevi.palaniswamy@ust-global.com   To Post Chatter on OnBoarding Plan whenever a module on this is completed.
                                                                           This method will be called by Process Builder
 * 2.0    #RQ-004727   1/30/2017     ramadevi.palaniswamy@ust-global.com   To post a chatter with badge 
 * 3.0    #RQ-004635   05/04/2017    abby.abraham@ust-global.com           Moved the logic to a generic class.
 * 4.0    #RQ-005073   10/10/2017    ramadevi.palaniswamy@ust-global.com   Changes to Sales New Hire Onboarding Program 
 * 5.0    #RQ-007902   21/03/2017    jagadeesan.sakthivel@ust-global.com   Added setting of Confirm_Declaration__c field to true while this code changes the new hire module status as completed 
 * 5.0    #RQ-007902    23/03/2017    Junaid.Khader@ust-global.com         Removed querying using category to new hire module id
 */

Public class ChatterPostOnNewHireModuleComplete{
    @InvocableMethod(label='Do post On New Hire Module Complete ' description='Post a chatter when a new hire module is completed')
    Public static void doPost(list<String> listNewHireModuleId){
        List<FeedItem> listChatterUpdates = new List<FeedItem>();
        List<New_Hire_Module__c> listNewHireToUpdateStatus = new List<New_Hire_Module__c>();
        FeedItem postObj;
        string url;
        integer index;
        string urlId;
        
        for(New_Hire_Module__c newMod : [SELECT id, Name, Onboarding_Plan__r.New_hire__c, Badge_Content_Version_Id__c,
                                                Badge_Name__c, Onboarding_Plan__r.Chatter_Group_URL__c
                                         FROM New_Hire_Module__c
                                         WHERE Id IN :listNewHireModuleId]) {
            postObj = new FeedItem();
            postObj.createdById = newMod.Onboarding_Plan__r.New_hire__c;
            // To get the group id of the onboarding plan chatter group
            url= newMod.Onboarding_Plan__r.Chatter_Group_URL__c;
            if(url != null){
                index = url.indexOf('?g=');
                if(index > -1){
                    urlId = url.right(url.length()-index-3);
                    if(urlId != null && urlId != ''){
                        postObj.parentId = Id.valueof(urlId);
                    }
                }
            }
            if(newMod.Badge_Content_Version_Id__c != null)
                postObj.relatedRecordId = newMod.Badge_Content_Version_Id__c;
            
            postObj.body ='I have completed module '+newMod.Name;
            if(newMod.Badge_Name__c != null)
                postObj.body += ' and obtained my '+newMod.Badge_Name__c+' badge!';
            
            listChatterUpdates.add(postObj);
            newMod.Status__c='Completed';
            listNewHireToUpdateStatus.add(newMod);
        }
        if(listNewHireToUpdateStatus.size() > 0)
            update listNewHireToUpdateStatus;
        //Generic method for creating chatter post and logging errors in global error logger in case of failures in feed creation
        ChatterPostUtilities.doChatterPost(listChatterUpdates,'ChatterPostOnNewHireModuleComplete');
    }
}