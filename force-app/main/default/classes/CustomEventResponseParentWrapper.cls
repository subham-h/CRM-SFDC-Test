/*              
* Revision   Ref Number       Date        Owner                       Description
* --------  ------------   ------------  ---------------------       ----------------------
* 1.0        SC-9978       16-May-2024    Richa@maersk.com           Generic Wrapper interface for publishing Custom events
*/

public interface CustomEventResponseParentWrapper {
    String getKafkakey();
    String getTransactionType();
    String getPublishingRecordId();
    String getEventType();
    DateTime getPublisherLastModifiedDate();
    String getSerializedJSON1();
    String getSerializedJSON2();
    String getSerializedJSON3();
    String getSerializedJSON4();
    String getSerializedJSON5();
    String getSerializedJSON6();       
}