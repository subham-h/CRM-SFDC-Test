/**
 * Author   : Samarpreet Singh
 * Purpose  : 
 * 
 * Revision Ref Number      Date        Owner                             Description
 * -------- ----------   -----------  -------------------                 -----------
 * 1.0      SFSE-12549   11-Sept-2023 Samar@Maersk                       Used to move the Opportunity product event flow for config to trigger.
 * 2.0		SFSE-12889	 16-Oct-2023  Jothsana@maersk.com			     To make OLI event publish queable
 * 3.0      SFSE-11535   12-03-2024   Samar@maersk.com			         deactivate V3 and Adding V5 event logic
**/
public class OpptyProductEventQueueable implements Queueable {

    public List<Id> listOfIdtoProcess= new List<Id>();
    public Boolean isOppty;
    public Boolean eventV3check;
    public Boolean eventV2check;
    public Boolean eventisInsert;
    public Set<Opportunity_Product__c> listOfOpptyLineItem = new Set<Opportunity_Product__c>();
    public List<OLIEventResponseWrapper.Requests> listOfRequest= new List <OLIEventResponseWrapper.Requests>();

    public OpptyProductEventQueueable(List<Id> lstofproduct,Boolean isOpptyBoolean, Boolean eventV3, Boolean eventV2,Boolean isInsert) {
        listOfIdtoProcess = lstofproduct;
        isOppty = isOpptyBoolean;
		eventV3check = eventV3;
        eventV2check = eventV2;
        eventisInsert = isInsert;
    }

    public void execute(QueueableContext context) {
        OLIEventResponseHandler.fireOliEventAsync(listOfIdtoProcess, isOppty, eventV3check, eventV2check, eventisInsert);
    }
}