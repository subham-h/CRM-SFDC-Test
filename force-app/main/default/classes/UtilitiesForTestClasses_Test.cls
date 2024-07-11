/**
* @author Andres Canavesi
* @date 2016-12
* @description 
*/
public class UtilitiesForTestClasses_Test {
    
    public static final Integer MAX_COUNT = 9999;
    
    public static Integer randomInteger(){
        return integer.ValueOf(Math.rint(Math.random() * 100000));
    }
    
   
    public static List<Attachment> createAttachmentForObject(Integer count, Id parentId, Boolean createPrivateAttachments){
        List<Attachment> attachments = new List<Attachment>();
        if (Schema.sObjectType.Attachment.fields.Name.isCreateable()
            && Schema.sObjectType.Attachment.fields.Description.isCreateable()
            && Schema.sObjectType.Attachment.fields.body.isCreateable()
            && Schema.sObjectType.Attachment.fields.parentId.isCreateable()
            && Schema.sObjectType.Attachment.fields.IsPrivate.isCreateable()) {
                System.debug('Creating '+count+' attachments');
                
                for(Integer i = 0; i<count ; i++){
                    String attachmentName = 'att_'+randomInteger();
                    Attachment attachment=new Attachment(); 
                    attachment.Name=attachmentName;
                    attachment.Description = attachmentName;
                    String body = '';
                    for(Integer j=0; j<100; j++){
                        body+='random body '+randomInteger();
                    }
                    Blob bodyBlob=Blob.valueOf(body);
                    attachment.body=bodyBlob;
                    attachment.parentId=parentId; 
                    attachment.IsPrivate = createPrivateAttachments;
                    attachments.add(attachment);
                }
                
                insert attachments;
            }
        
        return attachments;
    }
    
   
    
    public static List<ContentVersion> getLastFiles(){
        return [SELECT Id, ContentDocumentId, Description FROM ContentVersion LIMIT 10];
    }
    
    
    
    public static Integer countAllFiles(){
        return [SELECT count() FROM ContentVersion LIMIT :MAX_COUNT];
    }
    
    public static Integer countAllAttachments(){
        return [SELECT count() FROM Attachment LIMIT :MAX_COUNT];
    }
    
    public static Integer countPrivateAttachments(){
        return [SELECT count() FROM Attachment WHERE isPrivate = true LIMIT :MAX_COUNT];
    }
    
    //sleeps the main thread for X seconds
    public static void sleep(Integer seconds){
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000 * seconds) {
            finishTime = DateTime.now().getTime();
        }
    } 
    
    
    public static Event createEvent(){
        Event event = new Event();
        if (Schema.sObjectType.Event.fields.Description.isCreateable()
            && Schema.sObjectType.Event.fields.DurationInMinutes.isCreateable()
            && Schema.sObjectType.Event.fields.ActivityDateTime.isCreateable()) {
                
                event.Description = 'Event '+randomInteger();
                event.DurationInMinutes = 1;
                event.ActivityDateTime = Date.today();
                insert event;
            }
        return event;
    }
    
      
    
    public static Task createTask(){
        Task task = new Task();
        if (Schema.sObjectType.Task.fields.Description.isCreateable()) {
            task.Description = 'Task '+randomInteger(); 
            insert task;
        }
        return task;
    }
       
}