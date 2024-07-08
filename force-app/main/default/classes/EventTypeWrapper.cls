/*              
* Revision   Ref Number       Date        Owner                       Description
* --------  ------------   ------------  ---------------------       ----------------------
* 1.0        SC-9978       22-May-2024    Richa@maersk.com           Wrapper class for preparing event type details of Custom events
*/

public without sharing class EventTypeWrapper {
    public String transactionType { get; set; }
    public String eventType { get; set; }

    public EventTypeWrapper(String transactionType, String eventType) {
        this.transactionType = transactionType;
        this.eventType = eventType;
    }
}