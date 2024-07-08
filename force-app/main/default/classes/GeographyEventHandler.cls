/**
* @description
* Author   : Vivek.agrawal@Maersk
* Purpose  : Handle the Insert of the Platform event Geography 
             records and Convert them to respective SObjects in SFDC 
  
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0      SC-5462     17-Jan-2023 Vivek.agrawal@Maersk     Handler class to convert events into Geography related records
                                                             GeographyEventHandlerTest() handles code coverage for this Class.
                                                              
   
*/
public class GeographyEventHandler  {

    public static void createGeographies(List<Geography_Event__e> eventList){
         
        List<GeographyEventParser> geoParserList = new List<GeographyEventParser>();

        for(Geography_Event__e thisEvent : eventList){
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
           
            system.debug('JsonStr'+JsonStr);

            GeographyEventParser geography = GeographyEventParser.parse(jsonStr);
            system.debug('--geography'+geography);
            geoParserList.add(geography);
        }
        
        if(!geoParserList.isEmpty()){
                
            System.debug('getCpuTime before ProcessGeographyData--'+Limits.getCpuTime());

			 //EMPConsumerHandler.ProcessGeographyData(geoParserList);
            
            System.debug('getCpuTime after ProcessGeographyData--'+Limits.getCpuTime());

        }
    }  
}