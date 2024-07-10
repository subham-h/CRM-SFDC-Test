/*
* Author   : Sunil.bs@maersk.com
* Purpose  : ServiceNow Integration with Salesforce for Automation of Access Approval 
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-6348    17-11-2022   Sunil BS                Created.
*/

@restresource(urlmapping = '/servicenowuserapproval')
global without sharing class userServiceUtility {

    
    @httppost
    global static string dopost(){
        string reponsebody;
        JSONGenerator jsn = JSON.createGenerator(false);
        try{
        restrequest req = restcontext.request;
        blob body = req.requestBody;
        string requestbody =  body.toString();   
        restresponse res = restcontext.response;
        list<user> matchedApprovers = new  list<user>();
        list<string> emailids = new  list<string>(); 
        string responsetoSnow;
        list<BDA__c> BDACluster = new list<BDA__c>();
        list<string> snowBrand = new list<string>();
   
        servicenowuserapprovalwrapper sn = (servicenowuserapprovalwrapper)JSON.deserialize(requestbody,servicenowuserapprovalwrapper.class);
        snowbrand.add(sn.brand);
        
        matchedApprovers = [select id,isactive from user where username =:sn.username limit 1];
            
        if (!matchedApprovers.isempty()){
            
            if(matchedApprovers[0].isactive == true){
            	responsetoSnow = 'User already exists in the system'; 
            }
            else {
           	    responsetoSnow = 'User already exists in the system but is inactive'; 
            }
           JSONGenerator jsn1 = JSON.createGenerator(false);
           jsn1.writeStartObject();
           jsn1.writeStringField('responsetoSnow',responsetoSnow);
           jsn1.writeFieldName('EmailIds');
           jsn1.writeObject(emailids);
           jsn1.writeEndObject();
           jsn = jsn1;
           
        }
        else {
			//Try to recognize pattern 'MC - APA'
            if(sn.Role.startsWith('MC') && sn.Role.length() == 8){
           		 matchedApprovers = [select id,email from user where userrole.name =: sn.Role and isactive = true ];

            }
            else if (sn.Role.startsWith('Multi-Carrier')){
                 matchedApprovers = [select id,email from user where userrole.name like 'Multi-Carrier%' and isactive = true];
            }
            else if (sn.Role.startsWith('Centre')){
                 matchedApprovers = [select id,email from user where userrole.name like 'Centre%' and profile.name like '%centre%'and GEO_Code__c =:sn.Country and isactive = true];
                if (matchedApprovers.isEmpty()){
                    
                    list<Geography__c> geoid = [select GEO_ID__c from Geography__c where GEO_Code__c =:sn.Country and Active__c = true LIMIT 1];
                   
                    if (!geoid.isEmpty()){
                        BDACluster = [select Name from BDA__c where GEO_ID__c=:geoid[0].GEO_ID__c and Type__c = 'Cluster' and Active__c = true LIMIT 1];
					}
                    
                    if (!BDACluster.isEmpty()){
                        matchedApprovers = [select email from user where Cluster__c =:BDACluster[0].Name and userrole.name like 'Centre%' and profile.name like '%centre%' and isactive = true ];
					}
                    
                }
            }

            else if(sn.UserType == 'Service'){
            	matchedApprovers = [select id,SenderEmail,email from user where Core_Expert__c = true and (profile.name = '101 - Customer Service & Sales (Pilot)' OR profile.name = '102 - Customer Service') and liner_brand__c in: snowbrand and Access_Approver_CM_Visibility__c=:sn.CMVisibility and Geo_Code__c=:sn.Country and isactive = true ];
           
                 //If user does not exist for matched country try with matched cluster
               	 if (matchedApprovers.isEmpty()){
              		//matchedApprovers = [select id,SenderEmail,email from user where Core_Expert__c = true and (profile.name = '101 - Customer Service & Sales (Pilot)' OR profile.name = '102 - Customer Service') and liner_brand__c in: snowbrand and Geo_Code__c=:sn.Country and isactive = true ];
                    list<Geography__c> geoid = [select GEO_ID__c from Geography__c where GEO_Code__c =:sn.Country and Active__c = true LIMIT 1];
                   
                    if (!geoid.isEmpty()){
                        BDACluster = [select Name from BDA__c where GEO_ID__c=:geoid[0].GEO_ID__c and Type__c = 'Cluster' and Active__c = true LIMIT 1];
					}
                    
                    if (!BDACluster.isEmpty()){
                        matchedApprovers = [select email from user where Cluster__c =:BDACluster[0].Name and Core_Expert__c = true and (profile.name = '101 - Customer Service & Sales (Pilot)' OR profile.name = '102 - Customer Service') and liner_brand__c in: snowbrand and  isactive = true ];
					}
                }
            }
            
            else if(sn.UserType == 'Sales'){
            	matchedApprovers = [select id,SenderEmail,email from user where profileid=:Label.Super_User_Profile_Id and liner_brand__c in: snowbrand and Geo_Code__c=:sn.Country and isactive = true ];
  				if (matchedApprovers.isEmpty()){
              	//matchedApprovers = [select id,SenderEmail,email from user where profileid=:Label.Super_User_Profile_Id and liner_brand__c in: snowbrand and Geo_Code__c=:sn.Country and isactive = true ];
                    list<Geography__c> geoid = [select GEO_ID__c from Geography__c where GEO_Code__c =:sn.Country and Active__c = true LIMIT 1];
                   
                    if (!geoid.isEmpty()){
                        BDACluster = [select Name from BDA__c where GEO_ID__c=:geoid[0].GEO_ID__c and Type__c = 'Cluster' and Active__c = true LIMIT 1];
					}
                    
                    if (!BDACluster.isEmpty()){
                        matchedApprovers = [select email from user where Cluster__c =:BDACluster[0].Name and profileid=:Label.Super_User_Profile_Id and liner_brand__c in: snowbrand and  isactive = true ];
					}
                }
            }
            else{}
            
            if (!matchedApprovers.isempty()){
                responsetoSnow = 'Matching Approvers found';
                                
                  for (user u3:matchedapprovers){
                      emailids.add(u3.email);
                  }

                  JSONGenerator jsn2 = JSON.createGenerator(false);
                  jsn2.writeStartObject();
                  jsn2.writeStringField('responsetoSnow',responsetoSnow);
                  jsn2.writeFieldName('EmailIds');
    			  jsn2.writeObject(emailids);
                  jsn2.writeEndObject();
                  jsn = jsn2;
            }
                  
        }
            if (matchedApprovers.isEmpty()){
                responsetoSnow = 'No Matching Approvers found';
                  JSONGenerator jsn3 = JSON.createGenerator(false);
                  jsn3.writeStartObject();
                  jsn3.writeStringField('responsetoSnow',responsetoSnow);
                  jsn3.writeFieldName('EmailIds');
    			  jsn3.writeObject(emailids);
                  jsn3.writeEndObject();
                  jsn = jsn3;
            }

        
        }catch(Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'User', 'userServiceUtility.dopost', new list<Exception>{ex});  
        }
        
		String jsonData = jsn.getAsString();
        return jsonData;
    }
    
    global class servicenowuserapprovalwrapper{

        public String Username;
        public String UserType;
        public String Brand;
        public String Country;
        public String CMVisibility;
        public String Role;

	
	global servicenowuserapprovalwrapper parse(String json) {
		return (servicenowuserapprovalwrapper) System.JSON.deserialize(json, servicenowuserapprovalwrapper.class);
	}
}
    
}