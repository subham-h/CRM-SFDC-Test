/*
 * Created By   : Aleena@Maersk
 * Purpose      : To handle all logic associated with the Opportunity Event queable.
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   10-Oct-2023     Aleena@Maersk      to improve the way salesOpportunity event (v3.1 and v4) is published from flow to Apex trigger
 * 2.0      SFSE-11535   12-Mar-2024     Samar@maersk.com	deactivate V3 and Adding V5 event logic
 */


public class QueableOpptyEventAsync implements Queueable{
       Public List<Id> listOfId = new List<Id>();
       Public Boolean isOpptycheck;
       Public Boolean eventV3check;
       Public Boolean eventV4check;
    public QueableOpptyEventAsync(List<Id> listOfIdtoProcess,Boolean isOppty,Boolean eventV3 , Boolean eventV4) {
        listOfId = listOfIdtoProcess;
        isOpptycheck = isOppty;
        eventV3check = eventV3;
        eventV4check = eventV4;

    }

    public void execute(QueueableContext context) {
      OpportunityEventUtilities.toFireOpptyEvent(listOfId,isOpptycheck,eventV3check,eventV4check);   
    }
   
}