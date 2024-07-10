/*
* Author   : Meghna@Maersk
* Purpose  : To clone the case along with attachments and contentversions linked to a case
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5408   08-July-2022  Meghna@Maersk       Clone Attachment during Cloning Cases.
* 2.0      SC-5970   23-08-2022    Sreya@Maersk        Hnadling exception
* 3.0      SC-6919   13-02-2023    ramadevi@maersk     Case Owner should be updated as cloning user.
* 4.0      SC-9272   01-01-2024    ranjan@maersk       When Cloning cases, emails & contacts will also need to be cloned MI-2023-00453
* 5.0      SC-10137  11-06-2024    Shahanawaz@maersk   Automate Response Received Flag
*/
public With Sharing class CaseCloneAttachmentController {
    
    public static List<Attachment> attachmentlist = new List<Attachment>();
    public static List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    
    /** 
* @description | SC-5408 Clone the case record  |
* @param recordId accepts the case record Id
* @return string containing id of cloned case
*/  
    @AuraEnabled
    public static string cloneCaseRecord(String recordId){   
        String clonedCaseid;
        Case cloneCase;
        List<Case> caseListToUpdate = new List<Case>();
        try{            
            //SC-6307
            String layoutReadOnlyFields;
            for(General_Key_Value_Configurations__mdt mdt : [SELECT Id,First_Field_Name__c,First_Field_Value__c,Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c ='CaseReadOnly']){
                if(layoutReadOnlyFields==null){
                    layoutReadOnlyFields = mdt.First_Field_Value__c;
                }
                else{
                    layoutReadOnlyFields += ','+mdt.First_Field_Value__c;
                }                
            }
            //SC-6307
            String layoutEditfields = CaseCloneAttachmentController.getLayoutfields(recordId);
            String casequery='Select id,'+layoutEditfields + layoutReadOnlyFields +' from Case where id=\''+recordId+'\'';
            List<Case> caseRec=Database.query(casequery);
            //SC-10137
            if(!caseRec.isEmpty() && caseRec[0].New_Mail__c){
                Case cs = new Case();
                cs.Id = caseRec[0].Id;
                cs.New_Mail__c = false;
                caseListToUpdate.add(cs);
            }
            SObjectAccessDecision decisionCreate = Security.stripInaccessible( AccessType.CREATABLE, caseRec);
            
            Case strippedCase = (Case)decisionCreate.getRecords()[0];
            cloneCase = strippedCase.clone(false, true, false, false);
            cloneCase.IsCloned__c = true;
            cloneCase.OwnerId = UserInfo.getUserId();
            
            if(cloneCase.RecordTypeId == StaticFactory.getRecordTypeIdByName('Case', Label.ISR) && cloneCase.Compound_Index_for_BoL_Number__c!=null){
                cloneCase.Compound_Index_for_BoL_Number__c = cloneCase.Compound_Index_for_BoL_Number__c+ ' '+DateTime.now();
            }
        }
        catch(Exception e){
            throw new AuraHandledException(Label.System_Error+e.getMessage()+e.getLineNumber());
        }
        Database.SaveResult result = Database.insert(cloneCase, false);        
        if(result.isSuccess()) {
            if(!caseListToUpdate.isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                update caseListToUpdate;
                TriggerExecutionController.skipCaseTrigger(false);
            }
            return cloneCase.id;                 
        }
        else{
            throw new AuraHandledException(result.getErrors()[0].getMessage());             
        } 
    }
    
    /** 
* @description | SC-5408 Clone the contendocumentlink record  |
* @param contentDocumentIdList accepts contentDocumentID
* @param clonecaseid accepts id of cloned case
*/ 
    @AuraEnabled
    public static void cloneContentDocumentRecord(String contentDocumentIdList,String clonecaseid)
    {
        try{
            List<ID> contentDocumentIds = (List<Id>)JSON.deserialize(contentDocumentIdList ,List<Id>.class) ;
            cdlList = new List<ContentDocumentLink>();
            for(Id cdIds:contentDocumentIds)
            {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = clonecaseid;
                cdl.contentDocumentId= cdIds;
                cdlList.add(cdl);
            }
            
        }
        
        catch(Exception e)
        { 
            throw new AuraHandledException(Label.System_Error);            
        }
        
        Database.SaveResult[] results = Database.insert(cdlList, false);        
        for(Database.SaveResult result: results) {
            if(!result.isSuccess()) {
                throw new AuraHandledException(result.getErrors()[0].getMessage());
            }
        }
    }
    /** 
* @description | SC-9272 Clone the Email record  |
* @param emailIdStrList accepts Email ids
* @param clonecaseid accepts id of cloned case
*/ 
@AuraEnabled
public static void cloneEmailRecords(String emailIdStrList,String clonecaseid)
{    
    Map<Id,EmailMessage> oldIdNewEmailMap=New Map<Id,EmailMessage>();
    try{
        List<ID> emailIdList = (List<Id>)JSON.deserialize(emailIdStrList ,List<Id>.class) ;
        Map<Id,EmailMessage> emailMap=new Map<Id,EmailMessage>([SELECT BccAddress, BccIds, CcAddress, CcIds,
                                                                FromAddress, FromName, Headers, HtmlBody, 
                                                                MessageDate, MessageIdentifier, ParentId, 
                                                                ReplyToEmailMessageId, Status, Subject, TextBody,incoming, 
                                                                 ToAddress
                                                                FROM EmailMessage WHERE Id in:emailIdList]);
        for(EmailMessage emailObj:emailMap.values())
        {
            EmailMessage emailCloneObj=emailObj.clone();
            emailCloneObj.parentId=clonecaseid;
            oldIdNewEmailMap.put(emailObj.Id,emailCloneObj);
        }
            
        
    }
    
    catch(Exception e)
    { 
        throw new AuraHandledException(Label.System_Error);            
    }
    EmailRecordSelector.stopSCMCollaborationFlow = true;
    Database.SaveResult[] results = Database.insert(oldIdNewEmailMap.values(), false);
    for(Database.SaveResult result: results) {
        if(!result.isSuccess()) {
            throw new AuraHandledException(result.getErrors()[0].getMessage());
        }
    }
    //search any content document
    cdlList = new List<ContentDocumentLink>();
    for(ContentDocumentLink contentDocumentLinks:[Select ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :oldIdNewEmailMap.keyset()]){
        ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = oldIdNewEmailMap.get(contentDocumentLinks.LinkedEntityId).Id;
            cdl.contentDocumentId= contentDocumentLinks.ContentDocumentId;
            cdlList.add(cdl);
            ContentDocumentLink cdlCaseObj = new ContentDocumentLink();
            cdlCaseObj.LinkedEntityId = clonecaseid;
            cdlCaseObj.contentDocumentId= contentDocumentLinks.ContentDocumentId;
            cdlList.add(cdlCaseObj);
    }
    if(!cdlList.isEmpty()){
        Database.SaveResult[] cdResults = Database.insert(cdlList, false);
    }
    attachmentlist=new List<Attachment>();
    for(Attachment at: [select id,name,body,parentid from attachment where parentid in:oldIdNewEmailMap.keyset()])
    {
        if(Limits.getHeapSize()>limits.getLimitHeapSize()){
            throw new AuraHandledException(System.Label.Attachment_size_exceeded);
        }
        Attachment newat= new Attachment();
        newat.name = at.name;
        newat.body = at.body;
        newat.ParentId = oldIdNewEmailMap.get(at.parentid).Id;
        attachmentlist.add(newat);
    }
    if(!attachmentlist.isEmpty()){
        Database.SaveResult[] resultAttchs = Database.insert(attachmentlist, false);        
    }
}
    
    /** 
* @description | SC-5408 Clone the attachment record the case |
* @param attachmentIdList accepts attachment record ids
* @param clonecaseid accepts id of cloned case
*/ 
    @AuraEnabled
    public static void cloneAttachmentRecord(String attachmentIdList,String clonecaseid)
    {
        try{
            List<Id> attachmentIds = (List<Id>)JSON.deserialize(attachmentIdList ,List<Id>.class) ;
            //List<Attachment> attachmentlist = new List<Attachment>();
            for(Attachment at: [select id,name,body from attachment where id in:attachmentIds])
            {
                if(Limits.getHeapSize()>limits.getLimitHeapSize()){
                    throw new AuraHandledException(System.Label.Attachment_size_exceeded);
                }
                Attachment newat= new Attachment();
                newat.name = at.name;
                newat.body = at.body;
                newat.ParentId = clonecaseid;
                attachmentlist.add(newat);
            } 
        }
        
        catch(Exception e)
        {
            throw new AuraHandledException(Label.System_Error);
        } 
        Database.SaveResult[] results = Database.insert(attachmentlist, false);        
        for(Database.SaveResult result: results) {
            if(!result.isSuccess()) {
                throw new AuraHandledException(result.getErrors()[0].getMessage());
            }
        }
        
    }
    
    /** 
* @description | SC-5408 To get all the fields on page layout  |
* @param recordId accepts id of the case record
* @return string containing editable fields on page layout
*/ 
    
    public static string getLayoutFields(String recordId){
        
        String layoutfields='';
        String externalPageLayout;
        String iSRPageLayout;
        List<Metadata.Metadata> layouts;
        Case caserec = [Select id, RecordTypeId from case where id=:recordId];
        List<General_Key_Value_Configurations__mdt> lstGenKeyValueMetaData = [SELECT Id, label,First_Field_Value__c, Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'CasePageLayout' ];
        for(General_Key_Value_Configurations__mdt mdt:lstGenKeyValueMetaData)
        {
            if(mdt.label.contains('External'))
            {
                externalPageLayout= mdt.First_Field_Value__c;
            }
            if(mdt.label.contains('ISR'))
            {
                iSRPageLayout = mdt.First_Field_Value__c;
            }
            
        }
        if(CaseRec.RecordTypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case)){
            layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                                                   new List<String> {externalPageLayout});
        }
        if(CaseRec.RecordTypeId == StaticFactory.getRecordTypeIdByName('Case', Label.ISR))
        {
            layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                                                   new List<String> {iSRPageLayout});
        }
        Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
        
        for (Metadata.LayoutSection section : layoutMd.layoutSections) 
        {
            for (Metadata.LayoutColumn column : section.layoutColumns) 
            {
                if (column.layoutItems != null) 
                {
                    for (Metadata.LayoutItem item : column.layoutItems) 
                    {   
                        
                        if(!JSON.serialize(item.behavior).contains('Readonly')){
                            
                            
                            layoutfields=layoutfields+item.field+',';
                            
                        }
                    }
                }
            }
        }
        
        return layoutfields;
    }
}