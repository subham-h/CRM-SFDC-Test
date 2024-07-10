/*
* Author   : Manohar@Maersk
* Purpose  : To fetch all attachments and contentversions linked to a case
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-2774   29-Jun-2021  Manohar@Maersk       Created for fetching attachment and contentversions linked to a case.
* 2.0      SC-4047   8-Dec-2021   Ramadevi@UST          Bug fix for Email attachments not displayed
* 3.0      SC-6130   19-Sept-2022 Meghna@Maersk        Created method to rename files
*/
public without sharing class CaseAttachmentsController {
    @AuraEnabled
    public static string loadAllAttachments(String sfdcId){
        List<Object> dataList=new List<Object>();
        List<Object> emailList=new List<Object>();
        if(!string.isBlank(sfdcId)){
            Set<Id> parentIds=new Set<Id>();
            Case caseRec=[select id,casenumber,recordtype.Name,Parent.RecordType.name , (select id,parentid,Subject,FromAddress,ToAddress,MessageDate,Status,CreatedDate from emailmessages) from case where id=:sfdcId];
            for(EmailMessage msg:caseRec.emailmessages){
                Map<String,Object> emailMap=new Map<String,Object>();
                emailMap.put('Subject',msg.Subject);
                emailMap.put('FromAddress',msg.FromAddress);
                emailMap.put('ToAddress',msg.ToAddress);
                emailMap.put('MessageDate',msg.MessageDate);
                emailMap.put('Status',msg.Status);
                emailMap.put('Id',msg.Id);
                emailMap.put('CreatedDate',msg.CreatedDate);
                emailList.add(emailMap);
                parentIds.add(msg.Id);
            }
            parentIds.add(sfdcId);
            List<Id> contentDocumentLinkIds = new List<Id>();
            //query for contentversion(files)           
            //Added condition to query ContentDocumentILink related to Email and Case
            Map<Id,Id> conDocIdParentIdMap=new Map<Id,Id> ();
            for(ContentDocumentLink contentDocumentLinks:[Select ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :parentIds]){
                
                contentDocumentLinkIds.add(contentDocumentLinks.ContentDocumentId);  
                conDocIdParentIdMap.put(contentDocumentLinks.ContentDocumentId, contentDocumentLinks.LinkedEntityId);       
            }
            for(ContentVersion cv:[SELECT Id,ContentDocumentId,Title,VersionData,isLatest,FileExtension,createdDate,createdById,createdBy.Name,ContentSize FROM ContentVersion WHERE ContentDocumentId in :contentDocumentLinkIds and  IsLatest = true]){
                Map<String,Object> atMap=new Map<String,Object>();
                atMap.put('Id',cv.Id);
                atMap.put('Title',cv.Title+'.'+cv.FileExtension);
                atMap.put('CreatedDate',cv.createdDate);
                atMap.put('isContentVersion',true);
                atMap.put('Source',caseRec.caseNumber);
                atMap.put('parentId',conDocIdParentIdMap.get(cv.ContentDocumentId));
                atMap.put('userName',cv.CreatedBy.Name);
                atMap.put('userId',cv.CreatedById);
                atMap.put('ContentDocumentId',cv.ContentDocumentId);
                Decimal fileSize=Decimal.valueOf(cv.ContentSize).divide(1000,3);
                if(fileSize<1000){
                    atMap.put('Size',fileSize+' KB');   
                }else{
                    fileSize=fileSize.divide(1000, 3);
                    atMap.put('Size',fileSize+' MB'); 
                }
                dataList.add(atMap);
            }
            for(Attachment attachments:[SELECT Id, Name, Body, ContentType,createdDate,Parent.Name,ParentId,createdById,createdBy.Name,BodyLength FROM Attachment WHERE ParentId = :parentIds]){
                Map<String,Object> atMap=new Map<String,Object>();
                atMap.put('Id',attachments.Id);
                atMap.put('Title',attachments.Name);
                atMap.put('CreatedDate',attachments.createdDate);
                atMap.put('isContentVersion',false);
                atMap.put('Source',attachments.Parent.Name);
                atMap.put('parentId',attachments.ParentId);
                atMap.put('userName',attachments.CreatedBy.Name);
                atMap.put('userId',attachments.CreatedById);
                Decimal fileSize=Decimal.valueOf(attachments.BodyLength).divide(1000,3);
                if(fileSize<1000){
                    atMap.put('Size',fileSize+' KB');   
                }else{
                    fileSize=fileSize.divide(1000, 3);
                    atMap.put('Size',fileSize+' MB'); 
                }
                dataList.add(atMap);
            }
            
            return JSON.serialize(new RelatedAttachmentWrapper(caseRec.caseNumber,caseRec.recordtype.Name,caseRec.Parent.RecordType.name,dataList,emailList));
            
        }
        return null;
    }
    //fetch the blob data of file
    @AuraEnabled
    public static string getAttachmentBody(String attachmentIdList){
        List<Id> attachmentIds=(List<Id>)JSON.deserialize(attachmentIdList,  List<Id>.class);
        List<Object> dataList=new List<Object>();
        for(Attachment at:[select id,name,body from attachment where id in:attachmentIds]){
            if(Limits.getHeapSize()>limits.getLimitHeapSize()){
                throw new AuraHandledException(System.Label.Attachment_size_exceeded);
            }
            Map<String, String> atMap = new Map<String, String>();
            atMap.put( 'Name', at.Name );
            atMap.put('Id',at.Id);
            atMap.put( 'Body', EncodingUtil.base64Encode( at.Body ) );
            dataList.add( atMap );
        }
        return JSON.serialize(dataList);
    }
    @AuraEnabled(cacheable=true)
    public static String getLoginURL(){
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        return baseUrl;
    }
        /** 
* @description | SC-6130 Rename Attached Files (Claims)  |
* @param saveFilesDraftValues accepts draft file id and name
*/ 
    @AuraEnabled
    public static void renameFiles(String saveFilesDraftValues){
        System.debug('savefilesdraftvalues'+saveFilesDraftValues);
        List<ContentVersion> cvlist = new List<ContentVersion>();
        try{
        
       List<renamedFilesWrapper> lstdraftValues = (List<renamedFilesWrapper>)JSON.deserialize(saveFilesDraftValues ,List<renamedFilesWrapper>.class) ;
        for(renamedFilesWrapper rfw: lstdraftValues)
        {
            ContentVersion cv = new ContentVersion();
            cv.id = rfw.Id;
            cv.Title = rfw.Title;
            cvlist.add(cv);
        }
        }
        catch(Exception e)
        {
            throw new AuraHandledException(Label.System_Error);
        }
        
         Database.SaveResult[] results = Database.update(cvlist, false);   
            for(Database.SaveResult result: results) {
            if(!result.isSuccess()) {
                throw new AuraHandledException(result.getErrors()[0].getMessage());
            }
        }
    
        
    }
    
    
    @AuraEnabled
    public static string deleteSelectedAttachments(List<Id> recordIds)
    {
        integer count = 0;

        try {
        
            if(!recordIds.isEmpty())
            {
                Database.DeleteResult[] results = Database.delete(recordIds);
                System.debug(results);
                for(Database.DeleteResult result : results){
                    if(result.isSuccess()){
                        count++;
                    }
                }
            }
            if(count > 0){
                return 'Deleted Successfully';
            }
        } catch (Exception err) {
            return err.getMessage();
        }
        return null;
    }
    
    public class RelatedAttachmentWrapper{
        @AuraEnabled
        public string caseNumber;
        @AuraEnabled
        public string recordtypeName;
        @AuraEnabled
        public string parentRecordTypeName;
        @AuraEnabled
        public List<Object> attachments;
        @AuraEnabled
        public List<Object> columns;
        @AuraEnabled
        public List<Object> emails;
        public RelatedAttachmentWrapper(string caseNumber,String recordtypeName,String parentRecordTypeName,List<Object> attachments,List<Object> emails){
            this.caseNumber=caseNumber;
            this.attachments=attachments;
            this.recordtypeName=recordtypeName;
            this.parentRecordTypeName = parentRecordTypeName;
            this.emails=emails;
        }
        
    }
    
    public class renamedFilesWrapper{
        
        @auraenabled
        public string Id{get;set;}
        @auraenabled
        public string Title{get;set;}
        
    }
}