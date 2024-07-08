global with sharing class MetadataCallOutMock implements WebServiceMock{
global void doInvoke(
    Object stub,
    Object request,
    Map<String, Object> response,
    String endpoint,
    String soapAction,
    String requestName,
    String responseNS,
    String responseName,
    String responseType) {
        user einteinUser = [select id,name,Email from user where name='Einstein User' LIMIT 1];
        MetadataService.upsertMetadataResponse_element metadataResponse = new MetadataService.upsertMetadataResponse_element();
        MetadataService.UpsertResult saveresult = new MetadataService.UpsertResult();
        saveresult.errors = new List<MetadataService.Error>();
        //saveresult.errors.add(null);        
        //saveresult.fullName = 'testmlluser@maersk.com';
        saveresult.fullName = einteinUser.Email.replaceAll('[^a-zA-Z0-9]','_');
        saveresult.success = true;
        metadataResponse.result = new List<MetadataService.UpsertResult>();
        metadataResponse.result.add(saveresult);
        response.put('response_x', metadataResponse); 
    }
}