/*
* Purpose   : Batch class scheduled to update field 'StageName' and 'Reason_For_Close__c' to 'Closed Lost' and 'End Date Passed' respectively 
*           for those opportunities whose Close Date has passed and still are not in either 'Closed Lost' or 'Closed Won' stage.
*
* Revision  Ref Number    Date          Owner                   Description
* --------  ----------    -----------   -------------------     -----------
* 1.0       #RQ-003238    16-Jun-2016   Anisa Bhatnagar      Code created as part of #RQ-003238
* 2.0       #RQ-005636    26-Sep-2017   Nisha@UST            Update references of GlobalErrorLogger
* 3.0       #RQ-11001     20-july-2023  Ramya.s@maersk.com   P2 New End Date Passed Logic-mark the Opportunity as Closed Lost post the grace period is over and trigger chatter message where we doont need any approval 
* 4.0       SFSE-13391    30-Apr-2024   Shashi@Maersk        Lock the opportunities on closure by batch.
*/

global class Batch_ClosePastOpps implements Database.Batchable<sObject>, Database.Stateful {
    
    global final String query;
    global final String reasonForClose;
    global final String stageNameClosedLost;
    
    /**
    * Parameterized Constructor.
     */
     global Batch_ClosePastOpps() {
        this(null); // Call the parameterized constructor with null parameter to use the default query
    }
    global Batch_ClosePastOpps(String q) {
        String ApprovalRequired = 'No';
        if(q != null){
            query=q;
        }
        else
         { 
            if(Test.isRunningTest())
            {
                query = 'SELECT CloseDate, Id,isClosed, StageName, Reason_For_Close__c, OwnerId, Record_Locked__c FROM Opportunity WHERE CloseDate < NEXT_90_DAYS and  isClosed = False AND Approval_Required__c = \'' +  ApprovalRequired + '\' order by CloseDate asc limit 50 ';
            }else
            {
                query = 'SELECT CloseDate, Id,isClosed, StageName, Reason_For_Close__c, OwnerId, Record_Locked__c FROM Opportunity WHERE CloseDate < NEXT_90_DAYS AND isClosed = False AND Approval_Required__c = \'' +  ApprovalRequired + '\'';
                 //String opportunityId = '0065700000u4d4kAAA';
                //query = 'SELECT CloseDate,Name,isClosed, Id, StageName, Reason_For_Close__c,OwnerId FROM Opportunity WHERE  Id = \'' + opportunityId + '\' LIMIT 1';
            }
        }
        
        reasonForClose = Label.End_Date_Passed_After_90_Days;
        stageNameClosedLost = Label.Closed_Lost;
    }
    
    /**
* Start method.
*/
    global Database.QueryLocator start(Database.BatchableContext BC) 
    { 
        return Database.getQueryLocator(query);    
            

    }
    
    /**
* Execute method.
*/
    global void execute(Database.BatchableContext BC, List<Opportunity> scopeOpportunityList){
       if(scopeOpportunityList != null && scopeOpportunityList.size() > 0 ) {  
            // Create a new list to store modified opportunities
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            
            for(Opportunity opp : scopeOpportunityList) {
                if (opp.CloseDate.addDays(90) <= Date.today()) {
                    // Modify the opportunity fields
                    opp.StageName = stageNameClosedLost;
                    opp.Reason_For_Close__c = reasonForClose;
                    opp.Record_Locked__c = true; //SFSE-13391
                    // Add the modified opportunity to the new list
                    opportunitiesToUpdate.add(opp);
                }
            }
            
            // Skip opportunity Trigger
            TriggerExecutionController.skipOpportunityTrigger(true);
            
            Database.SaveResult[] updateResults = Database.Update(opportunitiesToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'Batch_ClosePastOpps.execute()', updateResults, opportunitiesToUpdate) ; // #RQ-005636  

            
            TriggerExecutionController.skipOpportunityTrigger(false);
            for(Opportunity opp : [SELECT CloseDate, Id,isClosed, StageName, Reason_For_Close__c, OwnerId FROM Opportunity WHERE id in: opportunitiesToUpdate])
            {
                //send chatter message to user for closed opportunity 
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            if (opp.isClosed) {
                
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            textSegmentInput.text = 'Hi ';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            //to mention the opportunity owner in chatter message
            mentionSegmentInput.id = opp.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            //to add text message to the chatter
            textSegmentInput = new ConnectApi.TextSegmentInput();
                     textSegmentInput.text = ', \n This opportunity  ' ;
            messageBodyInput.messageSegments.add(textSegmentInput);
            //to add opportunity link in the chatter feed
            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunitys = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputOpportunitys.entityId = opp.Id;  
            messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunitys);
            //to add text message to the chatter
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = ', has been closed lost as 90 days have elapsed since the close date.' ;
            messageBodyInput.messageSegments.add(textSegmentInput);
            //to add whole chatter message to the FeedItem
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = opp.OwnerId;
            //feedItemInputList.add(feedItemInput);
            //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);

            batchInputs.add(batchInput);
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }

        }

}
}
    
    /**
* Finish method.
*/
    global void finish(Database.BatchableContext BC) {
        // Do Nothing Here
    }
    
}