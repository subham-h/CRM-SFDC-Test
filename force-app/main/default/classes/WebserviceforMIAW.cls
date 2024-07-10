/*
* Purpose  : Generates the JWT Token from Certificate for Messaging and It is used in MIAW Channel with Enhanced Bot to show the Messaging History.
* 
* Revision Ref Number     Date        Owner                 Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9385     30-Nov-2023 ramadevi@maersk.com     Created.

*/
@RestResource(urlMapping='/getTokenforMessagingForWeb/*')
global with sharing class WebserviceforMIAW {      
    @HttpGet
    global static String doGet() {
        String jwtToken;
        String encodedClaimSet;
        String encodedHeader;
        String signature;
        //kid,iss is stored in metadata for the Messaging Channel
        //sub to get as input 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String emailid = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        system.debug('emailid ==='+emailid );        
        
        Messaging_for_Web_Service_Detail__mdt messagingMdt = [Select Environment__c,Certificate_Name__c,Issuer__c,Key_Id__c,Messaging_Channel_Developer_Name__c from Messaging_for_Web_Service_Detail__mdt where Active__c=true limit 1];
        system.debug('messagingMdt -- '+messagingMdt );
        
        if(messagingMdt <> NULL){
            // Create the JWT header
            Map<String, Object> header = new Map<String, Object>{
                'alg' => 'RS256',
                'typ' => 'JWT',
                'kid' => messagingMdt.Key_Id__c            
            }; 
            encodedHeader = EncodingUtil.base64Encode(Blob.valueOf((JSON.serialize(header))));       
            encodedHeader = encodedHeader.replace('+', '-').replace('/', '_').replaceAll('\\=+$', '');
     
            // Create the JWT claim set
            Map<String, Object> claimSet = new Map<String, Object>{
                'iss' => messagingMdt.Issuer__c,
                'sub' => emailid ,
                'exp' => DateTime.now().getTime()/1000 + 7200,
                'iat' => DateTime.now().getTime()/1000
            };
            encodedClaimSet = EncodingUtil.base64Encode(Blob.valueOf((JSON.serialize(claimSet))));
            encodedClaimSet = encodedClaimSet.replace('+', '-').replace('/', '_').replaceAll('\\=+$', '');
            // Create the signature
            String input = encodedHeader + '.' + encodedClaimSet;
            Blob signatureBlob = Crypto.signwithcertificate('RSA-SHA256', Blob.valueOf(input), messagingMdt.Certificate_Name__c);
            signature = EncodingUtil.base64Encode(signatureBlob);
            signature = signature.replace('+', '-').replace('/', '_').replaceAll('\\=+$', '');
     
            // Combine the header, claim set, and signature to create the JWT token
            jwtToken = encodedHeader + '.' + encodedClaimSet + '.' + signature;
            System.debug('jwtToken'+ jwtToken);
        }
        return JSON.serialize(new Map<String,Object> {'token' => jwtToken});
    }  
  
}