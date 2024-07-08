/*   
 * Purpose : Mock response for InsuranceAPICallouts 
 * 
 * Revision 	Ref Number  	Date          Owner                          Description
 * -------- 	----------  	-----------   -------------------            -----------
 * 1.0      	RQ-012787   	27/12/2019    Amritesh         			     Class created
 * 
 */

@isTest
global class InsuranceAPIMockCallout implements HttpCalloutMock {
    
    global enum request_mode {idtoken, agreements}
    request_mode mode;
    
    global InsuranceAPIMockCallout(request_mode mode) {
        this.mode = mode;
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(mode==request_mode.idtoken) {
            response.setStatusCode(200);
            response.setBody('{"idToken":"123456789"}');
        } else if(mode==request_mode.agreements) {
            response.setStatusCode(201);
            response.setStatus('Created');
        } else {
            response.setStatusCode(200);
        }
        return response; 
    }
}