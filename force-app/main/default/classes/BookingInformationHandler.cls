/*
 * Author   : Shahanawaz@Maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Booking Information trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class BookingInformationHandler extends TriggerHandler{
    
    public map<Id, Booking_Information__c> newMap;
    public map<Id, Booking_Information__c> oldMap;
    public BookingInformationHandler() {
        this.newMap = (map<Id, Booking_Information__c>)Trigger.newMap;
        this.oldMap = (map<Id, Booking_Information__c>)Trigger.oldMap; 
    }
    
    public BookingInformationRecordSelector bookingInfoRecordSelector;
    
    public override void getRecordSelector() {
        bookingInfoRecordSelector = new BookingInformationRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onAfterInsert() {
        if(!bookingInfoRecordSelector.bookingInfoCaseList.isEmpty()){
            BookingInformationHelper.createFeedItem(bookingInfoRecordSelector.bookingInfoCaseList);
        }
    }

}