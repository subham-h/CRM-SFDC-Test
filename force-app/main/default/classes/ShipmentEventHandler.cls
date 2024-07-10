/**
* @description
* Author   : Vivek.agrawal@Maersk
* Purpose  : Handle the Insert of the Platform event Shipment 
records and Convert them to respective SObjects in SFDC 

* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0      SC-5462     28-July-2022 Vivek.agrawal@Maersk     Handler class to convert events into Shipment related records
ShipmentEventHandlerTest() handles code coverage for this method.
* 2.0      SC-9586     05-Feb-2024  Richa@Maersk             Added Shipment Cancelled event consumption method                                                              

*/
public with sharing class ShipmentEventHandler  {
    
    /** 
* @description | SC-5462  Create Shipment Records |
* @param eventList accept the events list 
*/
    public static void CreateShipments(List<Shipment_Event__e> eventList){
        
        List<ShipmentJsonParser> shipmentParserList = new List<ShipmentJsonParser>();
        List<TpDocJsonParser> tpDocParserList = new List<TpDocJsonParser>();
        List<ShipmentCancelledJsonParser> lstCancelledParser = new List<ShipmentCancelledJsonParser>();
        
        for(Shipment_Event__e thisEvent : eventList){
            system.debug('--thisEvent'+thisEvent);
            
            String JsonStr;
            //If conditions to check if Coming Json contains Data in Json 2 , Json 3 and Json 4 fields as well
            if(thisEvent.JSON_1__c != null)
                JsonStr = thisEvent.Json_1__c;
            if(thisEvent.Json_2__c != '' || thisEvent.Json_2__c != null)
                JsonStr = JsonStr + thisEvent.Json_2__c;
            if(thisEvent.Json_3__c != '' || thisEvent.Json_3__c != null)
                JsonStr = JsonStr + thisEvent.Json_3__c;
            if(thisEvent.Json_4__c != '' || thisEvent.Json_4__c != null)
                JsonStr = JsonStr + thisEvent.Json_4__c;
            if(thisEvent.Json_5__c != '' || thisEvent.Json_5__c != null)
                JsonStr = JsonStr + thisEvent.Json_5__c;
            if(thisEvent.Json_6__c != '' || thisEvent.Json_6__c != null)
                JsonStr = JsonStr + thisEvent.Json_6__c;
            if(thisEvent.Json_7__c != '' || thisEvent.Json_7__c != null)
                JsonStr = JsonStr + thisEvent.Json_7__c;
            if(thisEvent.Json_8__c != '' || thisEvent.Json_8__c != null)
                JsonStr = JsonStr + thisEvent.Json_8__c;
            if(thisEvent.Json_9__c != '' || thisEvent.Json_9__c != null)
                JsonStr = JsonStr + thisEvent.Json_9__c;
            if(thisEvent.Json_10__c != '' || thisEvent.Json_10__c != null)
                JsonStr = JsonStr + thisEvent.Json_10__c;
            
            system.debug('***JsonStr'+JsonStr);
            // put a check for eventName
            if(!String.isBlank(jsonStr) && jsonStr.containsIgnoreCase('eventName') && jsonStr.containsIgnoreCase('Confirm_Shipment_Closed') && !jsonStr.containsIgnoreCase('Confirm_Shipment_Closed_TPDOC')){
                ShipmentJsonParser shipment = ShipmentJsonParser.parse(jsonStr);
                if(shipment.eventName == 'Confirm_Shipment_Closed'){                    
                    shipmentParserList.add(shipment);
                }
            }
            // put a check for eventName
            if(!String.isBlank(jsonStr) && jsonStr.containsIgnoreCase('eventName') && jsonStr.containsIgnoreCase('Confirm_Shipment_Closed_TPDOC')){
                TpDocJsonParser tpDocEvent = TpDocJsonParser.parse(jsonStr);
                if(tpDocEvent.eventName == 'Confirm_Shipment_Closed_TPDOC'){                    
                    tpDocParserList.add(tpDocEvent);
                }
            }
            
            //SC-9586
            if(!String.isBlank(jsonStr) && jsonStr.containsIgnoreCase('HeaderEventType') && jsonStr.containsIgnoreCase('ShipmentCancelled')){
                ShipmentCancelledJsonParser cancelledEvent = ShipmentCancelledJsonParser.parse(jsonStr);
                if(cancelledEvent.HeaderEventType.headerEventTypeName == 'ShipmentCancelled'){                
                    lstCancelledParser.add(cancelledEvent);
                }
            }
        }
        if(!shipmentParserList.isEmpty()){
            System.debug('getCpuTime before ProcessShipmentCall--'+Limits.getCpuTime());
            
            EMPConsumerHandler.ProcessShipmentData(shipmentParserList);
            
            System.debug('getCpuTime after ProcessShipmentCall--'+Limits.getCpuTime());
            
        }
        if(!tpDocParserList.isEmpty()){
            
            EMPConsumerHandler.processTPDocEventData(tpDocParserList);
            
        }
        
        if(lstCancelledParser != null && lstCancelledParser.size() > 0){            
            EMPConsumerHandler.processShipmentCancelledEventData(lstCancelledParser);    //SC-9586         
        }
    }
}