/*
* Author   : Manohar@Maersk
* Purpose  : wrapper class to return serialized data (attachments and contentversion list and error responses)
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-2774   29-Jun-2021  Manohar@Maersk          wrapper class to return serialized data
*/
public class CaseAttachmentResponseWrapper {
    private static String API_STATUS_NORMAL = '200';
    //Error Status Code
    private static String API_STATUS_ERROR  = '400';
    
   public static String normalJson( Object respData ) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('status', API_STATUS_NORMAL);
        if( respData != null ) response.put('data', respData);
       	return JSON.serialize( response );  
       
        
    }
    
  
    public static String errorJson( String message ) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('status', API_STATUS_ERROR);
        if( message != null ) response.put('error', message);
        return JSON.serialize( response );
    }
}