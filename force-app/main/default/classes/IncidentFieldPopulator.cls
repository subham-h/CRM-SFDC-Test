/*
* Author   : Jiji
* Purpose  : Field populator class for Incident rigger
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002716   29-Mar-2016 Jiji@UST                Code created
* 2.0      RQ-005636   22-Sep-2017 Nisha@UST               Update references of GlobalErrorLogger
*/  
public class IncidentFieldPopulator {
    
    /*
* Method to link incident with vessel policy associated to the vessel record as defined on the incident 
* Trigger will be fired if the incident is associated to a vessel and an incident date.
* The first vessel policy associated to vessel will be associated to the incident, eventhough there are multiple
* vessel policies to the vessel.
*/
    public static void linkVesselPolicyToIncident(list<Incident__c> lstNewIncidents, map<Id, Vessel__c> mapRelatedVessels) {
        // Associate vesselpolicy to the incidents
        try {
            for(Incident__c incidentRecord : lstNewIncidents) {
                incidentRecord.P_I_Policy__c = null;
                
                // Iterate over the vessel policies linked to the selected vessels from incidents
                Vessel__c vessel = mapRelatedVessels.get(incidentRecord.Insured_Vessel__c);
                if(vessel != null && vessel.Vessel_Policies__r != null) {
                    for(Vessel_Policy__c vesselPolicy : vessel.Vessel_Policies__r) {
                        // Vessel policies with start date and end date covering the date of incident will be assigned to the incident record
                        if(vesselPolicy.Vessel_Policy_Start_Date__c <= incidentRecord.Date_of_Incident__c && vesselPolicy.Vessel_Policy_End_Date__c >= incidentRecord.Date_of_Incident__c) {
                            incidentRecord.P_I_Policy__c = vesselPolicy.Id;
                            break;
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            ErrorLogger.writeErrors( 'SFDC', 'Incident', 'IncidentTriggerHandler.linkVesselPolicyToIncident', new List<Exception>{e}); //  #RQ-005636 
        }
    }
    
}