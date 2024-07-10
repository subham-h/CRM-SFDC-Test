/*
* version       Date                Owner                                       Description
******************************************************************************************************************
* V1.0          03/10/2017         meghana.gupta@ust-global.com         RQ-007147 - Attachments to Files AppExchange product code          

*/
public with sharing class  AttachmentConversionStatus {
    /**
    * @param objectName
    */
    public static void changeToCompletedByObjectNameDeletion(String objectName){
        AttachmentConversionStatus__c status = findByObjectNameDeletion(objectName);
        if (AttachmentConversionStatus__c.sObjectType.getDescribe().isDeletable()) {            
            if(status != null){
                List<Id> statusId= new List<Id>();
                statusId.add(status.Id);
                delete status;
                if(statusId != null){
                    Database.emptyRecycleBin(statusId);
                }
                
            }
        }else{
            system.debug('AttachmentConversionStatus__c - changeToCompletedByObjectNameDeletion access');
            throw new ForbiddenException('AttachmentConversionStatus__c - changeToCompletedByObjectNameDeletion access ERROR: isDeletable() for AttachmentConversionStatus__c');
            
        }
    }   
    
     /**
    * @param recordIds
    */
    public static void changeToCompletedByRecordIds(List<String> recordIds){
        List<AttachmentConversionStatus__c> statusList = new List<AttachmentConversionStatus__c>();
        if (AttachmentConversionStatus__c.sObjectType.getDescribe().isDeletable()) {            
            List<Id> statusIds= new List<Id>();
            for(String recordId : recordIds){
                AttachmentConversionStatus__c status = findByRecordId(recordId);
                if(status != null){
                    statusList.add(status);
                    statusIds.add(status.Id);
                }
            }
            
            delete statusList;
            if(statusIds != null && statusIds.size() > 0){
                Database.emptyRecycleBin(statusIds);
            }
            
        }  else{
            system.debug('AttachmentConversionStatus__c - changeToCompletedByRecordIds access');
            throw new ForbiddenException('AttachmentConversionStatus__c - changeToCompletedByRecordIds access ERROR: isDeletable() for AttachmentConversionStatus__c');
            
        }
    }
    /**
    * @param objectName
    */
    public static void changeToInProgressByObjectNameDeletion(String objectName){
        changeStatusByObjectNameDeletion(objectName);
    }   
    
    /**
    * @param objectName
    */
    private static void changeStatusByObjectNameDeletion(String objectName){        
        if (Schema.sObjectType.AttachmentConversionStatus__c.fields.ObjectName__c.isCreateable()
            && Schema.sObjectType.AttachmentConversionStatus__c.fields.Type__c.isCreateable()
            && Schema.sObjectType.AttachmentConversionStatus__c.fields.Type__c.isUpdateable()
            && Schema.sObjectType.AttachmentConversionStatus__c.fields.ObjectName__c.isUpdateable()) {
                AttachmentConversionStatus__c status = findByObjectNameDeletion(objectName);
                if(status == null){
                    status = new AttachmentConversionStatus__c();
                    status.ObjectName__c = objectName;
                    status.Type__c = 'Deletion';
                }
                upsert status;
            }  else{
                system.debug('AttachmentConversionStatus__c - changeStatusByObjectNameDeletion access');
                throw new ForbiddenException('AttachmentConversionStatus__c - changeStatusByObjectNameDeletion access ERROR: isCreateable() or isUpdateable() for status.ObjectName__c or status.Type__c');
                
            }
    }   
    
     public static AttachmentConversionStatus__c findByObjectNameDeletion(String objectName){
        //We ask for RecordId__c = null because we are in a bulk context
        List<AttachmentConversionStatus__c> result = [SELECT Id 
                                           FROM AttachmentConversionStatus__c 
                                           WHERE ObjectName__c = :objectName
                                           AND RecordId__c = null
                                           AND Type__c = 'Deletion'
                                           LIMIT 1];
        if(result.size()>0){
            return result.get(0);
        }else{
            return null;
        }
    }
    
    public static AttachmentConversionStatus__c findByRecordId(String recordId){
        List<AttachmentConversionStatus__c> result = [SELECT Id 
                                           FROM AttachmentConversionStatus__c 
                                           WHERE RecordId__c = :recordId
                                           AND Type__c = 'MigrationAttachment'
                                           LIMIT 1];
        if(result.size()>0){
            return result.get(0);
        }else{
            return null;
        }
    }
    
     public static void changeToCompletedByObjectName(String objectName){
        AttachmentConversionStatus__c status = findByObjectName(objectName);
        if (AttachmentConversionStatus__c.sObjectType.getDescribe().isDeletable()) {            
            if(status != null){
                List<Id> statusId= new List<Id>();
                statusId.add(status.Id);
                delete status;
                if(statusId != null){
                    Database.emptyRecycleBin(statusId);
                }
                
            }
        }else{
            system.debug('AttachmentConversionStatus__c - changeToCompletedByObjectNameDeletion access');
            throw new ForbiddenException('AttachmentConversionStatus__c - changeToCompletedByObjectNameDeletion access ERROR: isDeletable() for AttachmentConversionStatus__c');
            
        }
    }
    
    public static AttachmentConversionStatus__c findByObjectName(String objectName){
        //We ask for RecordId__c = null because we are in a bulk context
        List<AttachmentConversionStatus__c> result = [SELECT Id 
                                           FROM AttachmentConversionStatus__c 
                                           WHERE ObjectName__c = :objectName
                                           AND RecordId__c = null
                                           AND Type__c = 'MigrationAttachment'
                                           LIMIT 1];
        if(result.size()>0){
            return result.get(0);
        }else{
            return null;
        }
    }
}