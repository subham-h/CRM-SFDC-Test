public class BookingConfirmationController {
    
    public class botInput{
        @InvocableVariable(required=true)
        public string shipmentNumber;
        @InvocableVariable(required=true)        
        public string brand;
        @InvocableVariable(required=true)
        public string externalContactId;
    }
    public class BookingReceivers{
        @InvocableVariable(required=true)
        public string ResponseStatus; 
        @InvocableVariable(required=true)
        public string BookingError;  
        
    }
    /** 
    * @description | SC-4740 send email to contacts via bot  |
    * @param lstBotInput accepts the bot input
    * @return List<BookingReceivers> containing the status of the API callout
    */ 
    @InvocableMethod(label='sendBookingConfirmation')
    public static List<BookingReceivers> sendBookingConfirmation(List<botInput> lstBotInput){
    
        List<BookingReceivers> lstBookingReceivers = new List<BookingReceivers>();
        Boolean isException = false;
        String confirmBookingReceivers;
        String errorReceived;
  		try{
         
         	
         	String shipmentNumber = lstBotInput[0].shipmentNumber;
            String operator = BrandUtilities.getBrandOperatorCode(lstBotInput[0].brand);
            operator = operator.toUpperCase(); 
            String externalContactId = lstBotInput[0].externalContactId;
            String AccountId;
            List<BodyData> reclist = new List<BodyData>();
            String postConfirmBooking;
            Map<String,Object> mapBookingConfirmationResponse;
            String jsonS;
            List<Object> dataList=new List<Object>();
            try{
                confirmBookingReceivers = (String)BookingAmendmentWritebackController.getConfirmBookingReceivers(shipmentNumber,operator);
                if(confirmBookingReceivers == 'Read timed out'){
                    lstBookingReceivers = getBookingInfo(null,Label.ReadTimedOut);
                    isException = true;   
                }
            }
            catch(Exception ex)
            {
                system.debug('***exception error in confirm Booking Receivers'+ex.getMessage()+'**'+ex.getLineNumber());
                lstBookingReceivers = getBookingInfo(null,ex.getMessage());
                isException = true;
            }
            
            if(!isException){
                Map<String,Object> maprecipientResponse = (Map<String,Object>)JSON.deserializeUntyped(confirmBookingReceivers);
                 List<Object> lstrecipient = (List<Object>) maprecipientResponse.get('recipientList'); 
                if(lstrecipient!=null){
                    for(object obj:lstrecipient)
                    {	
                        Map<String,Object> resData = (Map<String,Object>)obj;
                        if(resData.get('shipmentPartyRoleTypeName')=='Booked By'){
                            AccountId = (string)resData.get('customerId');
                            break;
                        }
                        
                    }
                    system.debug('reclist is null here'+reclist+'reclist size'+reclist.size());
                    for(Object obj1: lstrecipient){
                        
                        
                        Map<String,Object> rData = (Map<String,Object>)obj1;
                        if(rData.get('customerId')== AccountId && rData.get('contactId')==lstBotInput[0].externalContactId && rData.get('deliveryMethodName')=='E-mail' )
                        {	
                            
                            JSONGenerator gen = JSON.createGenerator(true);    
                            gen.writeStartObject();
                            reclist.add(getData((string)rData.get('contactId'),(string)rData.get('customerId'),(string)rData.get('deliveryMethodId'),(string)rData.get('shipmentPartyRoleTypeId')));
                            gen.writeObjectField('recipientList', reclist);
                            gen.writeEndObject();
                            jsonS = gen.getAsString();
                            break;
                            
                        }
                        else
                        {
                            lstBookingReceivers = getBookingInfo(null,'Unauthorized Access');
                        }
                    }
                }
                
                else{
                    
                    errorReceived = (String)maprecipientResponse.get('debugMessage'); 
                    lstBookingReceivers = getBookingInfo(null,errorReceived);
                }
                
                if(reclist.size()>0){
                    
                    try{
                        postConfirmBooking=(String)BookingAmendmentWritebackController.postConfirmBooking(shipmentNumber,operator,jsonS); 
                        
                        if(postConfirmBooking== 'Read timed out')
                        {
                            lstBookingReceivers = getBookingInfo(null,Label.ReadTimedOut); 
                            isException=true;   
                        }
                    }
                    catch(Exception ex)
                    {
                        lstBookingReceivers = getBookingInfo(null,ex.getMessage()); 
                        isException=true;
                    }
                    if(!isException)
                    {	
                       
                        if(postConfirmBooking=='200')
                        {
                            lstBookingReceivers = getBookingInfo('Success',null);
                        }
                        else
                        {	
                            mapBookingConfirmationResponse = (Map<String,Object>)JSON.deserializeUntyped(postConfirmBooking);
                            errorReceived = (String)mapBookingConfirmationResponse.get('debugMessage'); 
                            lstBookingReceivers = getBookingInfo(null,errorReceived);
                        }
                    }
                }
            }
     }
        catch(Exception e){
            lstBookingReceivers = getBookingInfo(null,'System Error/Unhandled Error');
            isException = true;
        }
        return lstBookingReceivers;
        
    }
    
    
    public static List<BookingReceivers> getBookingInfo(string ResponseStatus, string BookingError){
        List<BookingReceivers> lstBookingReceivers = new List<BookingReceivers>();
        BookingReceivers Booking = new BookingReceivers();                  
        Booking.ResponseStatus = ResponseStatus;
        Booking.BookingError = BookingError;
        lstBookingReceivers.add(Booking);
        return lstBookingReceivers;
    }
    
    /** 
    * @description | SC-4740 send email to contacts via bot  |
    * @param contactId accepts contactId
    * @param deliveryMethodId accepts deliveryMethodId
    * @param deliveryMethodId accepts shipmentPartyRoleTypeId
    * @return BodyData containing BodyData
    */ 
    public static BodyData getData(String contactId,String customerId,String deliveryMethodId,String shipmentPartyRoleTypeId)
    {
        BodyData bd = new BodyData();
        bd.contactId=contactId;
        bd.customerId=customerId;
        bd.deliveryMethodId=deliveryMethodId;
        bd.shipmentPartyRoleTypeId=shipmentPartyRoleTypeId;
        return bd;
        
    }
    
    public class BodyData{
        public string contactId;
        public string customerId;
        public string deliveryMethodId;
        public string shipmentPartyRoleTypeId;
        
    }
    
    
}