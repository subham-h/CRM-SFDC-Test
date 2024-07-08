/*
* Created By   : Shahanawaz@Maersk
* Purpose  : Utility class to create feed items on parent record
*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9293    19-12-2023    Shahanawaz@maersk       Create feeditem on parent Case  
*/
public class FeedItemUtility {
    
    /** 
    * @description | create feed item
    * @param feedWrapList accepts list of FeedItemWrapper
    */
    public static void createFeedItem(List<FeedItemWrapper> feedWrapList){
        try{
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            
            for(FeedItemWrapper fWrap : feedWrapList){
                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
                textSegment1.text = fWrap.objName+' created.';
                messageInput.messageSegments.add(textSegment1);
                
                ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
                textSegment2.text = '\n'+fWrap.objName+(fWrap.objName == 'Case' ? ' Number ' : ' Name: ');
                messageInput.messageSegments.add(textSegment2);
                
                ConnectApi.EntityLinkSegmentInput entityLinkSegment = new ConnectApi.EntityLinkSegmentInput();
                entityLinkSegment.entityId = fWrap.recId;
                messageInput.messageSegments.add(entityLinkSegment);
                
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.body = messageInput;
                input.subjectId = fWrap.parentId;
                input.visibility = ConnectApi.FeedItemVisibilityType.InternalUsers;
                
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
            }
            
            if(!batchInputs.isEmpty() && !Test.isRunningTest()){
                TriggerExecutionController.skipAccountTrigger(true);
                ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
                TriggerExecutionController.skipAccountTrigger(false);
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Case', 'FeedItemUtility.createFeedItem', new List<Exception>{e});  
        }
    }
    
    /** 
    * @description | FeedItemWrapper
    */
    public class FeedItemWrapper{
        public String recId;
        public String parentId;
        public String objName;        
        public FeedItemWrapper(String recId, String parentId, String objName){
            this.recId = recId;
            this.parentId = parentId;
            this.objName = objName;
        }
    }
    
}