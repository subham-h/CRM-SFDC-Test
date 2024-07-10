/** 
* @description 
* Author   : Ragu
* Purpose  : Wrapper class to hold shipment summary response data. 
*        
* Revision 	Ref Number  Date        	Owner					Description
* -------- 	----------  ----------- 	-------------------		-----------
* 1.0     	SC-8506     05-08-2023   	sunil.bs@maersk			Wrapper class for shipment summary transit RQ
* 2.0		SC-8631		25-Apr-2024		Kiran@Maersk			Auto Case Assignment - Ocean - based on Cargo types - Reefer, OOG, Break Bulk
*/
global class ShipmentSummaryWrapper {
    
    public ShipmentSummary shipmentSummary;
    
    public class Header {
        public String isReefer;
		public String isDangerous;
		public String isOOG;
	}
	
	public class ShipmentSummary {
        public Header header;
		public List<TransportRoutePlan> transportRoutePlan;
	}
    
    public class TransportRoutePlan {
		public String service;
	}
        
}