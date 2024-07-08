/*
* Revision  Ref Number    Date          Owner                   Description
* 3.0       #RQ-11001     20-july-2023  Ramya.s@maersk.com   P2 New End Date Passed Logic-chatter post when opportunity reaches the close date
*/

global class Batch_CloseDateOpptyNotification implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global final String query;
    global final String reasonForClose;
    global final String stageNameClosedLost;
    Date dt;
    /**
    * Parameterized Constructor.
     */
    global Batch_CloseDateOpptyNotification() {
        this(null); // Call the parameterized constructor with null parameter to use the default query
    }
    global Batch_CloseDateOpptyNotification(String q) {
    
        if (q != null) {
            query = q;
        } else {
            //String ApprovalRequired = 'Yes';
            dt = System.today(); 
            if(Test.isRunningTest())
            {
                query = 'SELECT CloseDate, Id, StageName, Reason_For_Close__c, OwnerId FROM Opportunity WHERE  isClosed = False  limit 50';
            }else
            {
                query = 'SELECT CloseDate, Id, StageName, Reason_For_Close__c, OwnerId FROM Opportunity WHERE  isClosed = False AND CloseDate = :dt';
            }
            //String opportunityId1 = '0060Q00000O9GXQQA3';
            //query = 'SELECT CloseDate, Id, StageName, Reason_For_Close__c, OwnerId FROM Opportunity WHERE  isClosed = False AND Id = \'' + opportunityId1 + '\'  AND CloseDate = :dt LIMIT 1';
            }
        reasonForClose = Label.End_Date_Passed_After_90_Days;
        stageNameClosedLost = Label.Closed_Lost;
    }
    
    
    /**
* Start method.
*/
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator(query);    
    }
    
    /**
* Execute method.
*/
    global void execute(Database.BatchableContext BC, List<Opportunity> scopeOpportunityList){
       if(scopeOpportunityList != null && scopeOpportunityList.size() > 0 ) {  
        //send chatter message to user for closed opportunity 

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for (Opportunity opp: scopeOpportunityList) {
            
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

            textSegmentInput = new ConnectApi.TextSegmentInput();
            // textSegmentInput.text = ', \n Within the next ' + days + ' days ' + opp.Name + ' is going to be auto-closed (end date passed) unless you take action.  If you would like to keep your opportunity open, please click here ';
              textSegmentInput.text = ', \n This opportunity  ' ;
              messageBodyInput.messageSegments.add(textSegmentInput);
  
              //to add opportunity link in the chatter feed
              ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunitys = new ConnectApi.EntityLinkSegmentInput();
              entityLinkSegmentInputOpportunitys.entityId = opp.Id;  
              messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunitys);
            
            //to add text message to the chatter
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = ', is now overdue as the close date has been reached. It has not been automatically closed. You should: \n - Close the opportunity immediately OR \n - Update to a future close date. \n If no approvals are required the opportunity will close automatically in 90 days.  If approvals are required then there will be no automatic closure, but the opportunity will be repeatedly flagged and reported as overdue until the close date is changed or the opportunity is closed. ' ;
            messageBodyInput.messageSegments.add(textSegmentInput);

            //to add whole chatter message to the FeedItem
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = opp.OwnerId;
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);

            batchInputs.add(batchInput);

    }
    
    ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
}
}
    
    /**
* Finish method.
*/
    global void finish(Database.BatchableContext BC) {
        // Do Nothing Here
    }
    
}