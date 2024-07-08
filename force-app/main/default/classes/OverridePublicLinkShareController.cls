/*
* version   Date         Owner             Description
*******************************************************************************************************
* v1.0      18/06/2019   Nitin More        Controller class created.
*/
public class OverridePublicLinkShareController {
    
    @AuraEnabled
    public static Boolean checkInternalDocument(String contentDocumentId){
        Boolean isInternal = false;
        for (ContentVersion cvRecord : [SELECT Internal_External__c FROM ContentVersion
                                       WHERE ContentDocumentId = :contentDocumentId
                                       LIMIT 1]){

            if (cvRecord.Internal_External__c == 'Internal'){
                isInternal = true;
            }
        }      
       
        return isInternal;
    }
    
    @AuraEnabled
    public static String checkForSharedUrl(String contentDocumentId){
        String strSharedUrl = null;
        for(ContentDistribution cdRecord : [SELECT DistributionPublicUrl FROM ContentDistribution
                                       		WHERE ContentDocumentId = :contentDocumentId
                                       		LIMIT 1]){
            strSharedUrl = cdRecord.DistributionPublicUrl;
        }
        //System.debug('##### contentDocumentId: ' + contentDocumentId );
        //System.debug('##### strSharedUrl: ' + strSharedUrl );
        return strSharedUrl;
    }
    
    @AuraEnabled
    public static String createSharedUrl(String contentDocumentId){
        ContentVersion conVer = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentVersion
                                WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
        
        ContentDistribution newContentDistribution = new ContentDistribution();
        newContentDistribution.ContentVersionId = conVer.Id;
        newContentDistribution.Name = conVer.ContentDocument.Title;
        insert newContentDistribution;
        
        String strSharedUrl = null;
        for (ContentDistribution cdRow : [SELECT DistributionPublicUrl FROM ContentDistribution
                                       		WHERE ContentDocumentId = :contentDocumentId
                                       		LIMIT 1]){

            strSharedUrl = cdRow.DistributionPublicUrl;
        }
        return strSharedUrl;
    }

    @AuraEnabled
    public static Boolean deleteSharedURL(String contentDocumentId){
        Boolean retValue = false;
        ContentDistribution cdRecordToDelete = [SELECT DistributionPublicUrl FROM ContentDistribution
                                       		WHERE ContentDocumentId = :contentDocumentId
                                       		LIMIT 1];
        
        try{
            delete cdRecordToDelete;
            retValue = true;
        } catch(Exception ex){
            retValue = false;
        }
        return retValue;
    }
}