@isTest
global class GcssTasksControllerMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String sampleBody = '';
        String endpoint = request.getEndpoint();
        
        if(endpoint.containsIgnoreCase('confirmBookingReceivers')){
            if(endpoint.contains('507333571') ||endpoint.contains('507333572') ||endpoint.contains('507333573')){
            	sampleBody ='{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","recipientList": [{"contactId": "DK00083821","customerId":"DK00007951","deliveryMethodData": "richa.singh@maersk.com","deliveryMethodName":"E-mail","shipmentPartyRoleTypeId": "1","shipmentPartyRoleTypeName": "Booked By"}]}';       
            }
            else{
                sampleBody ='{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","recipientList": [{"contactId": "CN01705924","customerId":"DK00007951","deliveryMethodData": "richa.singh@maersk.com","deliveryMethodName":"E-mail","shipmentPartyRoleTypeId": "1","shipmentPartyRoleTypeName": "Booked By"}]}';       
            }
        }
        else if(endpoint.containsIgnoreCase('docBrokerId')){
            if(endpoint.contains('507333572')){
               sampleBody = '{"docBrokerId": [{"tpdoc_no": "585473503","instanceId": "5V8OZLH4011SB","fk_transport_doc_version": "GIDDB9G401CLB","docbroker_unique_id": "0A732E77B7B863FF2693417CCD7D","fk_documentType": "XMYM9L3DDSAAA","documentType": "Shipped on Board","documentGroup": "GCSS Seaway Bill","doc_broker_framework_name": "GCSS_MSL_TDOC_N_SB","fk_operatorOwner": "1","scv_custno_recipient": "DK00007951","is_verify_copy": "Y","createTime": "2023-02-01T10:19:01.681353000Z","createUser": "DEFAULT","updateTime": "2023-03-01T10:19:01.681353000Z","updateUser": "DEFAULT"},{"tpdoc_no": "585473503","instanceId": "5V8OZLH4011SB","fk_transport_doc_version": "GIDDB9G401CLB","docbroker_unique_id": "0A732E77B7B863FF2693417CCD7D","fk_documentType": "XMYM9L3DDSAAA","documentType": "Shipped on Board","documentGroup": "MSL Booking Confirmation Release Order","doc_broker_framework_name": "GCSS_MSL_TDOC_N_SB","fk_operatorOwner": "1","scv_custno_recipient": "DK00007951","is_verify_copy": "Y","createTime": "2023-03-01T10:19:01.681353000Z","createUser": "DEFAULT","updateTime": "2023-03-01T10:19:01.681353000Z","updateUser": "DEFAULT"}]}';  
            }else if(endpoint.contains('507333571')){
            	sampleBody = 'debugmessage';
            }else{
                sampleBody = '';
            }
        }
            
        else if(endpoint.containsIgnoreCase('documentArchive'))
            sampleBody = '{"pdfContent":""}';
        else 
        if(endpoint.containsIgnoreCase('equipmentDetails') || endpoint.containsIgnoreCase('hsCommodityCodes') || endpoint.containsIgnoreCase('utmInformation') || 
          endpoint.containsIgnoreCase('confirmBooking') || endpoint.containsIgnoreCase('rePrice') || endpoint.containsIgnoreCase('shipmentNotes') || endpoint.containsIgnoreCase('equipment')){
            sampleBody = '200';
        }
        else{
            sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W"}';
        }
        response.setBody(sampleBody);
        response.setStatusCode(200);
        return response; 
    }
}