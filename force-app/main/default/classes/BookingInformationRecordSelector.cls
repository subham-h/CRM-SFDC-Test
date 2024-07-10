/*
* Author   : Shahanawaz@Maersk
* Purpose  : Centralize the record selection process for Booking Information object.
*            Defines the methods which iterate and segregate the Booking Information records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class BookingInformationRecordSelector {
    
    private TriggerHandler bookingInfoTriggerHandler;
    
    public List<Booking_Information__c> bookingInfoCaseList = new List<Booking_Information__c>();
    
    public BookingInformationRecordSelector(list<Booking_Information__c> bookingInfoList, map<Id, Booking_Information__c> mapOldbookingInfo, TriggerHandler bookingInfoTriggerHandler) {
        this.bookingInfoTriggerHandler = bookingInfoTriggerHandler;
        
        this.selectRecords(bookingInfoList, mapOldbookingInfo);
        
        if(bookingInfoList != null) {
            this.getRelatedRecords(bookingInfoList);
        }
        
    }
    
    public void selectRecords(list<Booking_Information__c> bookingInfoList, map<Id, Booking_Information__c> mapOldbookingInfo) {
        for(Booking_Information__c bookInfo : bookingInfoList){
            if(bookingInfoTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                if(bookingInfoTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    //SC-9293
                    if(bookInfo.Related_Case__c != null){
                        bookingInfoCaseList.add(bookInfo);
                    }
                }
            }
        }
    }
    
    public void getRelatedRecords(list<Booking_Information__c> bookingInfoList) {
        
    }

}