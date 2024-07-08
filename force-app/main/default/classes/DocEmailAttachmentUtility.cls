/*
Description  : Generic class to get GCCS's archived data through docBrokerId

* version    Ref Number     Date               Owner                              Description
*******************************************************************************************************************
* 1.0        SC-6596       07/02/2023         sunil.bs@maersk.com                 Perform callouts to get GCCS's archived booking data 
																				  like booking confimation, verify copy, seaway bill and bill of lading
*-------------------------------------------------------------------------------------------------------------------
*/
public class DocEmailAttachmentUtility {
    
    public static General_Key_Value_Configurations__mdt menuName1 = General_Key_Value_Configurations__mdt.getInstance('ChatBotMenuName1');
    public static General_Key_Value_Configurations__mdt menuName2 = General_Key_Value_Configurations__mdt.getInstance('ChatBotMenuName2');
    
    //To get required inputs from bot
    public class bookingInput{
        @InvocableVariable(required=true)
        public string bookingNumber;
        @InvocableVariable(required=true)
        public string brand;
        @InvocableVariable(required=true)
        public string menuName;
        @InvocableVariable(required=true)
        public string caseNumber; 
        @InvocableVariable(required=true)
        public string externalContactId; 
        
    }
      
      //To send back required outputs to bot
      public class bookingoutput{
        @InvocableVariable(required=true)
        public string  Status;
        @InvocableVariable(required=true)
        public string botOutputMessage;  
    }


    /** 
      * @description | SC-6596  Method is invoked from chatbot |
      * @param bookingInput accepts the bookingNumber,operatorCode & menuName as a list
      */
    @invocableMethod(label = 'getDocBrokerIdEmailAttachments')
    public static list<bookingoutput> getDocBrokerIdEmailAttachments(list<bookingInput> bookingInput){
            string caseNumber = bookingInput[0].caseNumber;
        system.debug('myvalue'+bookingInput);
       	    string error;
        	list<bookingoutput> bookingoutputResult = new list<bookingoutput>();
      	    try{string bookingNumber = bookingInput[0].bookingNumber;
                string brand = bookingInput[0].brand;
                string menuName = bookingInput[0].menuName;
                string externalContactId = bookingInput[0].externalContactId;
                string docbrokeruniqueid;
                string documentGroupInstance;
                //List<String> SeawayandverifydocgroupList =  System.label.Seawayandverifydocgroup.split(',');

                //validate if customer is valid
                bookingoutputResult= DocEmailAttachmentController.validateIsCustomer(brand,externalContactId,menuName,bookingNumber,caseNumber);
                
                if(bookingoutputResult[0].botOutputMessage != 'Valid Customer'){
                        ErrorLogger.writeError('SFDC', 'User', 'getDocBrokerIdEmailAttachments',bookingoutputResult[0].botOutputMessage+' '+caseNumber,'','');  
                        return bookingoutputResult;
                }else{
                    bookingoutputResult[0].botOutputMessage = Null;
                }
                                
                //callout to get docbroker id that would be used in second callout to get the document requested
			    string res = DocEmailAttachmentController.DocBrokerIdIdentifier(brand,menuName,bookingNumber,caseNumber);
			    
				if(!String.isblank(res) && !res.containsIgnoreCase('Read timed out') && !res.containsIgnoreCase('debugMessage')){
                                   
						 DocEmailAttachmentWrapper sn = (DocEmailAttachmentWrapper)JSON.deserialize(res,DocEmailAttachmentWrapper.class);
                 		 //Sort by createddate in descending order and get the latest docbrokerid. Sorting logic is handled in wrapper class.
                 		 if(sn.DocBrokerId.isempty()){
                           bookingoutputResult[0].botOutputMessage = 'No Document Broker Id found for the Booking Number';
                           ErrorLogger.writeError('SFDC', 'User', 'getDocBrokerIdEmailAttachments ',bookingoutputResult[0].botOutputMessage+' '+caseNumber,'','');  
                           return bookingoutputResult;
                         }
                        sn.DocBrokerId.sort();
                        // Get the docbrokeruniqueid which will be used in next callout
              
                        for (DocEmailAttachmentWrapper.DocBrokerId sp: sn.DocBrokerId){
                            if(Menuname == menuName2.First_Field_Name__c){
                                if(string.isnotblank(sp.documentGroup)){
                               //documentGroupInstance = sp.documentGroup.substring(4); 
							   documentGroupInstance = documentGroupInstance.toLowerCase(); 
                               documentGroupInstance = documentGroupInstance.deleteWhitespace();
							   if(documentGroupInstance.contains(menuName2.First_Field_Value__c)){
                      	         docbrokeruniqueid = sp.docbroker_unique_id;
                                 break;
                               } 
                              /* if(SeawayandverifydocgroupList.contains(documentGroupInstance)){
							     docbrokeruniqueid = sp.docbroker_unique_id; 
								 break;
                               }*/
                            }
                            }

							   if(Menuname == menuName1.Second_Field_Name__c){
                               if(string.isnotblank(sp.is_verify_copy)){
                                 if(sp.is_verify_copy == menuName1.Second_Field_Value__c){
                                   docbrokeruniqueid = sp.docbroker_unique_id; 
                                   break;
                                 }      
                               }
                               }
                                
                                if(Menuname == menuName1.First_Field_Name__c){
                                    if(string.isnotblank(sp.documentGroup)){
                              	   documentGroupInstance =  sp.documentGroup.toLowerCase(); 
                              	   documentGroupInstance = documentGroupInstance.deleteWhitespace();
                                  if(documentGroupInstance.contains(menuName1.First_Field_Value__c)){
                                     docbrokeruniqueid = sp.docbroker_unique_id;
                                     break;
                                  }     
                                    } 
                                }

                                if(Menuname == menuName2.Second_Field_Name__c){
                                    if(string.isnotblank(sp.documentGroup)){
                                documentGroupInstance =  sp.documentGroup.toLowerCase(); 
                                documentGroupInstance = documentGroupInstance.deleteWhitespace();
                                  if(documentGroupInstance.contains(menuName2.Second_Field_Value__c)){
                                    docbrokeruniqueid = sp.docbroker_unique_id;
                                    break;
                                  } }
                                }
                              
                            }
						
               if(string.isblank(docbrokeruniqueid)){
                  bookingoutputResult[0].botOutputMessage =  'No Document Broker Id found for the Booking Number';
                  ErrorLogger.writeError('SFDC', 'User', 'getDocBrokerIdEmailAttachments ',bookingoutputResult[0].botOutputMessage+' '+caseNumber,'','');  
                  return bookingoutputResult;
                }
                    
                bookingoutputResult[0].status =  'Success';
                system.debug('docbrokeruniqueid here'+docbrokeruniqueid);
                    
                //Callout to send the document requested by customer/contact
                DocEmailAttachmentController.sendDocBrokerIdEmailAttachments(bookingNumber,brand,menuName,caseNumber,docbrokeruniqueid,externalContactId);
                }      
                else{
                     if(String.isblank(res)){
                        bookingoutputResult[0].botOutputMessage =  'Empty Response';
                        ErrorLogger.writeError('SFDC', 'User', 'getDocBrokerIdEmailAttachments ',bookingoutputResult[0].botOutputMessage+' '+caseNumber,'','');  
                        return bookingoutputResult;
                      }
                    
                     else if(res.containsIgnoreCase('debugMessage')){
                                Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res);
                                error = (String) mapResponse.get('debugMessage');
                                ErrorLogger.writeError('SFDC', 'User', 'sendDocBrokerIdEmailAttachments '+caseNumber, error,'','');  

                            }
                    
					 else{
                          bookingoutputResult[0].botOutputMessage =  'Read timed out';
                          ErrorLogger.writeError('SFDC', 'User', 'getDocBrokerIdEmailAttachments ','Read timed out'+' '+caseNumber,'','');  
                          return bookingoutputResult; 
                     }
                }
             }catch(Exception ex){
                    system.debug(+ex+' at '+ex.getLineNumber());
                    bookingoutputResult[0].botOutputMessage =  'System Error/Unhandled Error';                 
                    ErrorLogger.writeErrors('SFDC', 'User', 'getDocBrokerIdEmailAttachments '+caseNumber, new list<Exception>{ex});  
             } 
            return bookingoutputResult;
    }
}