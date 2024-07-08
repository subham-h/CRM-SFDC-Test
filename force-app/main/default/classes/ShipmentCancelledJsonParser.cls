/**
* @description
* Author   : Richa@Maersk
* Purpose  : To parse the Cancelled Shipment Platform event JSON

* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0      SC-9586     05-Feb-2024    Richa@Maersk            Added Shipment Cancelled event parsing logic
*/
public class ShipmentCancelledJsonParser {
    public HeaderEventType HeaderEventType;   
    public Brand Brand;
    public StandardReason StandardReason;    
    public String shipmentNumber;    
    public String shipmentStatus; 
    public String shipmentIdentifier;
    public String shipmentVersionIdentifier;
    public String shipmentVersionCreatedDatetime;
    public String shipmentVersionUpdatedDatetime;
    public String shipmentStructureUpdateDatetime;
    public Boolean isConfirmedOnce;
    public Boolean isPriceCompleted;
    public Boolean isShortShipped;
    
    
    public class HeaderEventType {
        public String headerEventTypeName;
    }
    
    public class Brand {
        public String brandCode;
        public String brandName;
    }
    
    public class StandardReason {
        public String StandardReasonType;
        public String standardReasonName;
        public String standardReasonDescription;
    }
    
    
    public static ShipmentCancelledJsonParser parse(String json) {
        return (ShipmentCancelledJsonParser) System.JSON.deserialize(json, ShipmentCancelledJsonParser.class);    
    }
    
}