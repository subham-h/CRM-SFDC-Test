public class GetOppFilesContentLink {
    public class contentDocWrapper{
        @AuraEnabled public  string fileName  		{get;set;}		
        @AuraEnabled public  string fileContent		{get;set;}	
        @AuraEnabled public  string filesData		{get;set;}	
        @AuraEnabled public  string fileType 		{get;set;}	
        @AuraEnabled public  string fileContentId 	{get;set;}
    }
     @AuraEnabled
    public static contentLinkResponse createDocument(string oppRecId, contentDocWrapper cdWrapper){
        contentLinkResponse response = new contentLinkResponse();        

        string strMessage;
        string base64Data = EncodingUtil.urlDecode(cdWrapper.fileContent, 'UTF-8');
        system.debug('==cdWrapper=='+cdWrapper);
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = cdWrapper.fileName,
            PathOnClient   = cdWrapper.fileName,
            VersionData    = Blob.valueOf(cdWrapper.fileContent),//EncodingUtil.base64Decode(base64Data),
            //Blob.valueOf(cdWrapper.fileContent),
            IsMajorVersion = true);
        insert contentVersion;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        String fileUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ContentDocumentId;
       
        strMessage = 'success';
        
        response.contentLink = fileUrl;  
        return response;
    }
    public class contentLinkResponse{
        @AuraEnabled public String contentLink;
        public contentLinkResponse(){
            contentLink = '';
        }
    }
}