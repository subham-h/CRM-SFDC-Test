/*
* Author   : sriram@Maersk
* Purpose  : Class for making external webservice callouts to get Deadline details.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010509   10-May-2019 sriram@Maersk           to get Deadline details and display data on serviceViewDeadlines.
* 2.0		
*/ 

public  class DeadlineServiceController {
    @AuraEnabled(continuation=true cacheable=true)
    public static Object getDeadlineDetails(string VesselCode,string VoyageNumber,string Etd,string ReceiptCode,string Eta,string Operator){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        string strObjectName = 'Case';
        string strModuleName = 'SFDC.DeadlineManagement.REQUEST';
        if(Etd == null || Etd == ''){
            Etd = '';
        }else{
            Etd= '<v21:ETD>'+Etd+'</v21:ETD>';
        }

       if(Eta == null || Eta == ''){
            Eta = '';
        }else{
            Eta= '<v21:ETA>'+Eta+'</v21:ETA>';
        }
    
        // Getting the Endpoint and Security details from ESB Service metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
        
        String SecurityHeader = getDeadlineSecurityHeader(esbServiceDetail);       
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);       
        String strHeader = SecurityHeader+commonHeader;
        
      /*  String strBody =   '  <soapenv:Body><v21:GetDeadlinesRequest>  <v21:VesselDetails><v21:VesselCode>'+VesselCode+'</v21:VesselCode> <v21:Operator><v21:OperatorCode>'+OperatorCode+'</v21:OperatorCode></v21:Operator> <v21:DatedVoyages><v21:VoyageNumber>'+VoyageNumber+'</v21:VoyageNumber>'
            +'<v21:ArrivalDatedSiteCalls> <v21:DateSiteCall></v21:DateSiteCall></v21:ArrivalDatedSiteCalls> <v21:DepartureDatedSiteCalls> <v21:DateSiteCall> <v21:ETD>'+ETD+'</v21:ETD> </v21:DateSiteCall> </v21:DepartureDatedSiteCalls>  </v21:DatedVoyages> </v21:VesselDetails>'
             +' <v21:Site> <v21:DefinedAreaCd>'+ReceiptCode+'</v21:DefinedAreaCd> </v21:Site> <v21:DeadlineOffset>  <v21:CardinalDirection>  </v21:CardinalDirection> <v21:Service> </v21:Service> <v21:Operator> </v21:Operator><v21:IMDGClassification> <v21:CommodityClassificationCode/>'
             +'</v21:IMDGClassification>  </v21:DeadlineOffset><v21:DeadlineGroups>  <v21:DeadlineGroups> <v21:DeadlineGroup> <v21:DeadlineGroupName>Documentation</v21:DeadlineGroupName>  <!--Optional:--> <v21:Deadlines>  <!--1 or more repetitions:--> <v21:Deadline> <v21:DeadlineName>Commercial Cargo Cutoff</v21:DeadlineName> '                   
             +'<v21:InternalFlag>false</v21:InternalFlag>  </v21:Deadline> <!--  <v21:Deadline> <v21:DeadlineName>Shipping Instructions Deadline for Advance Manifest Cargo</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>--> <v21:Deadline> <v21:DeadlineName>Cargo Cutoff</v21:DeadlineName> '                   
             +' <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline><v21:Deadline> <v21:DeadlineName>Verified Gross Mass Deadline</v21:DeadlineName> <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>  <v21:Deadline> <v21:DeadlineName>Shipping Instructions Deadline</v21:DeadlineName>  <v21:InternalFlag>false</v21:InternalFlag>  </v21:Deadline>'
             +' <!--  <v21:Deadline> <v21:DeadlineName>Commercial Verified Gross Mass Deadline</v21:DeadlineName>    <v21:InternalFlag>false</v21:InternalFlag>    </v21:Deadline>      -->     </v21:Deadlines> </v21:DeadlineGroup> <v21:DeadlineGroup> <v21:DeadlineGroupName>Marine Services</v21:DeadlineGroupName>  <!--Optional:-->'
            +' <v21:Deadlines>    <!--1 or more repetitions:--> <v21:Deadline> <v21:DeadlineName>Commercial Cargo Cutoff</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag>  </v21:Deadline> <!--   <v21:Deadline> <v21:DeadlineName>Shipping Instructions Deadline for Advance Manifest Cargo</v21:DeadlineName>      '               
            +'<v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>--><v21:Deadline>  <v21:DeadlineName>Cargo Cutoff Deadline - Latest</v21:DeadlineName>        <v21:InternalFlag>false</v21:InternalFlag>  </v21:Deadline> <v21:Deadline> <v21:DeadlineName>Verified Gross Mass Deadline</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag>'
             +'</v21:Deadline> <v21:Deadline> <v21:DeadlineName>Shipping Instructions Deadline</v21:DeadlineName>    <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>  <!--  <v21:Deadline>  <v21:DeadlineName>Commercial Verified Gross Mass Deadline</v21:DeadlineName>      <v21:InternalFlag>false</v21:InternalFlag>'
            +' </v21:Deadline>      -->  </v21:Deadlines> </v21:DeadlineGroup> </v21:DeadlineGroups>'
             +'</v21:GetDeadlinesRequest></soapenv:Body>';*/


             String strBody =      ' <soapenv:Body>  <v21:GetDeadlinesRequest>  <v21:VesselDetails>  <v21:VesselCode>'+VesselCode+'</v21:VesselCode>  <v21:DatedVoyages><v21:VoyageNumber>'+VoyageNumber+'</v21:VoyageNumber>  <v21:ArrivalDatedSiteCalls>  <!--1 or more repetitions:-->  <v21:DateSiteCall>'+Eta+'</v21:DateSiteCall></v21:ArrivalDatedSiteCalls><v21:DepartureDatedSiteCalls>  <v21:DateSiteCall>  '+Etd+'  </v21:DateSiteCall> </v21:DepartureDatedSiteCalls> </v21:DatedVoyages> </v21:VesselDetails>'
             +'<v21:Site>  <v21:DefinedAreaCd>'+ReceiptCode+'</v21:DefinedAreaCd>   </v21:Site> <v21:DeadlineOffset>  <v21:CardinalDirection>   </v21:CardinalDirection> <v21:Service> </v21:Service>'
             +'<v21:Operator>  <v21:OperatorCode>'+Operator+'</v21:OperatorCode> </v21:Operator>'
             +'   <v21:IMDGClassification>  <v21:CommodityClassificationCode/>   </v21:IMDGClassification> '
             +'  </v21:DeadlineOffset> <v21:DeadlineGroups> <v21:DeadlineGroup> <v21:DeadlineGroupName>Documentation</v21:DeadlineGroupName>   <!--Optional:--> <v21:Deadlines> <v21:Deadline>'
               +' <v21:DeadlineName>Commercial Cargo Cutoff</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
               +'<v21:Deadline> <v21:DeadlineName>Advanced Manifest Submission Deadline</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
                +'<v21:Deadline> <v21:DeadlineName>Arrival Notice Issuance Deadline</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
                 +'<v21:Deadline> <v21:DeadlineName>Import Manifest Submission Deadline</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
                  +'<v21:Deadline> <v21:DeadlineName>Shipping Instructions Deadline for Advance Manifest Cargo</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
                   +'<v21:Deadline> <v21:DeadlineName>Export Manifest Submission Deadline</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
                         +'<v21:Deadline> <v21:DeadlineName>Empty Container Pickup Deadline - Earliest</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
                    +'<v21:Deadline> <v21:DeadlineName>Empty Container Pickup Deadline - Latest</v21:DeadlineName>   <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>'
               +'<v21:Deadline>   <v21:DeadlineName>Shipping Instructions Deadline</v21:DeadlineName> '                    
                +' <v21:InternalFlag>false</v21:InternalFlag> </v21:Deadline>  <v21:Deadline>  <v21:DeadlineName>Commercial Verified Gross Mass Deadline</v21:DeadlineName>     <v21:InternalFlag>false</v21:InternalFlag>  </v21:Deadline>  '                                              
              +' </v21:Deadlines> </v21:DeadlineGroup> <v21:DeadlineGroup> <v21:DeadlineGroupName>Marine Services</v21:DeadlineGroupName> <v21:Deadlines>     <v21:Deadline>  <v21:DeadlineName>Cargo Cutoff Deadline - Latest</v21:DeadlineName>  '                   
                 +'    <v21:InternalFlag>false</v21:InternalFlag>   </v21:Deadline>   </v21:Deadlines>  </v21:DeadlineGroup>  </v21:DeadlineGroups> </v21:GetDeadlinesRequest> </soapenv:Body>';
        
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setBody(strXMLRequest);
        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);
        req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai

        // Creating continuation object for making the callout.
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(req);        
        con.continuationMethod='processDeadlineDetails';
        return con;
    }
    
    @AuraEnabled(cacheable=true)
    public static Object processDeadlineDetails(Object state) {
        //getting the service response for getDeadlineDetails service.
        HttpResponse response = Continuation.getResponse((String)state); 
        system.debug('response-->'+response.getBody());
        return response.getBody();        
    }
    
    //Preparing the security header for the request which is common for all the shipment management operations.
    public static String getDeadlineSecurityHeader(ESB_Webservice__mdt esbServiceDetail){
        String securityHeader =' <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v2="http://services.apmoller.net/ManagementFramework/CommonIdentifier/v2" xmlns:v21="http://services.apmoller.net/AMM/DeadlineManagement/v2">'
            +'<soapenv:Header>'
            +'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
            +'<wsse:UsernameToken wsu:Id="UsernameToken-5">'
            +'<wsse:Username>'+ esbServiceDetail.OSB_Username__c +'</wsse:Username>'
            +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+ esbServiceDetail.Password__c +'</wsse:Password>'
            +'</wsse:UsernameToken>'
            +'</wsse:Security>'; 
        return securityHeader;  
        
        
    }    
}