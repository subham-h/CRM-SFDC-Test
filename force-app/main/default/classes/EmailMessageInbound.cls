@isTest
global Class EmailMessageInbound implements Messaging.InboundEmailHandler {

    public string nameOfFunctionality;
	// Instantiate variables that we will need for handling this email
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env)
    {
		
		String BA = env.toAddress;        
		contact ConInstance =TestDataFactoryHelper.createContactRecord();
		List<case> lstCases;
        List<Survey__c> lstSurvey;
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try
        {
            if(BA == 'testba@test.com')
            {
             	lstCases =TestDataFactoryHelper.createEmailtoCase();       
          		  
            }
           	else if(BA == 'testbaclaimlns@.com')
            {
                lstCases =TestDataFactoryHelper.createClaimCaseRecordForBAuser(BA, ConInstance);          
          	 	insert lstCases[0];   
            }
            
        }catch(System.dmlException e)
        {
                    System.debug('Error: Unable to create new Case: ' + e);
        }

        
        
        return result;
        
	} // Close handleInboundEmail ()
      
}