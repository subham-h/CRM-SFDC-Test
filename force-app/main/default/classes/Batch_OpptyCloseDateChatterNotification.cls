/*
* Purpose   : Send Chatter Notification to Opportunity Owner for opportunity close Date due in 15 days using the batch. 
*        
* Revision Ref Number  Date           Owner                         Description
* -------- ----------  -----------    -------------------           -----------
* 1.0      SFSE-8515   13/12/2022     Jothsana Devi                 Generic Class to send Chatter Notification
* 2.0      SFSE-11001  02/08/2022     Ramya                         P2 New End Date Passed Logic-post the chatter on Opportunity on  83rd day after close date
*
*/
global class Batch_OpptyCloseDateChatterNotification implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //SOQL query to fetch all opportunity records with due date in next 7 days
        String Query;
        // Calculate the target date by adding 83 days to today's date
        Date dt = system.today()-Integer.valueOf(83);
        String ApprovalRequired = 'No';
        if(Test.isRunningTest())
        {
            Query = 'SELECT Name,Id,Opportunity_Owner__c,OwnerId,CloseDate From Opportunity WHERE isClosed = False  AND Approval_Required__c = \'' +  ApprovalRequired + '\' Limit 50';
            
        }else
        {
            Query = 'SELECT Name,Id,Opportunity_Owner__c,OwnerId,CloseDate From Opportunity WHERE CloseDate=:dt AND isClosed = False  AND Approval_Required__c = \'' +  ApprovalRequired + '\' ';
            
        }
        //String opportunityId = '0060Q00000O9sRZQAZ';   
        //Query = 'SELECT Name,Id,Opportunity_Owner__c,OwnerId,CloseDate From Opportunity WHERE  Id = \'' + opportunityId + '\' LIMIT 1';
        return Database.getquerylocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List < Opportunity > opplist) {
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (Opportunity opp: opplist) {
            
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
            Date newCloseDate = opp.CloseDate.addDays(90);

            //to add text message to the chatter
           /* textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = ' will automatically close on ( ' +
            newCloseDate.format() +') 7 days from now as 90 days will have elapsed since the expected close date. To avoid automatic closure you should edit the opportunity to close it with a legitimate reason or extend the close date.  If you would like to keep your opportunity open, please click here ';
            messageBodyInput.messageSegments.add(textSegmentInput);*/
            textSegmentInput = new ConnectApi.TextSegmentInput();
            Date closeDate = opp.CloseDate.addDays(90); // Assuming newCloseDate is 7 days from now
            String day = String.valueOf(closeDate.day());
            // Create a mapping of month numbers to month abbreviations
            Map<Integer, String> monthAbbreviations = new Map<Integer, String>{ 1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',6 => 'June',7 => 'July',8 => 'August',9 => 'September', 10 => 'October', 11 => 'November',12 => 'December'};

            Integer monthNumber = closeDate.month();
            String month = monthAbbreviations.get(monthNumber);

            String year = String.valueOf(closeDate.year());

            String formattedCloseDate = day+ ' '+ month + ',' +' '+ year;
            textSegmentInput.text = ' will automatically close 7 days from now on ('+ formattedCloseDate +') as 90 days will have elapsed since the expected close date. To avoid automatic closure you should edit the opportunity to close it with a legitimate reason or extend the close date.  If you would like to keep your opportunity open, please click here ';
            messageBodyInput.messageSegments.add(textSegmentInput);

            
            //to add opportunity link in the chatter feed
            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunity = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputOpportunity.entityId = opp.Id;  
            messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunity);
            
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = ' and take the appropriate action, including reviewing the current closing date. \n Thank you!';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            //to add whole chatter message to the FeedItem
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = opp.OwnerId;
            //feedItemInputList.add(feedItemInput);
            //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);

            batchInputs.add(batchInput);
            
        }
        // update opplist;

        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
    }
    
    global void finish(database.BatchableContext bc) {}
}