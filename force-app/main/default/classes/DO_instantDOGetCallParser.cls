public class DO_instantDOGetCallParser {
    public class InstantDeliveryOrder {
        public String status;
        public String mapRTPStatus;
        public String createHaulageOrderStatus;
        public String sendHaulageOrderStatus;
        public String shipmentReferencesStatus;
    }

    public String deliveryOrderId;
    public String importServiceMode;
    public List<HaulageInstructions> haulageInstructions;
    public String deliveryOrderStatus;
    public InstantDeliveryOrder instantDeliveryOrder;

    public class HaulageInstructions {
        public String containerId;
    }

    
    public static DO_instantDOGetCallParser parse(String json) {
        return (DO_instantDOGetCallParser) System.JSON.deserialize(json, DO_instantDOGetCallParser.class);
    }

}