/*              
* Version Ref Number  	Date        	Owner                   Description
* -------- ----------  ----------- 	-----------------       -----------------
* 1.0     SFSE-11111   04-Jul-2023		Vazid       		create and update Region and Area fields based on selected Country code
*/

public class EmployeeHRDataTriggerHelper {
    
    public static void mapCountryBdaDetails(List<Employee_HR_Data__c> listEMPdataItem, Map<Id, Employee_HR_Data__c> mapOldEMPData) {
        // GET ALL BDA GEOGRAPHY BY COUNTRY CODE
        Map<String, BDA_Geography__c> mapCountryCode = GeographyHelper.getBdaGeographyByCountryCode();
        
        for (Employee_HR_Data__c eachEmpRec :listEMPdataItem) {
            if(eachEmpRec.Country_Code__c != null){
                if (mapCountryCode.containsKey(eachEmpRec.Country_Code__c) && mapCountryCode.get(eachEmpRec.Country_Code__c) != null) {
                    if (mapOldEMPData != null) {
                        if (mapOldEMPData.get(eachEmpRec.Id) != null 
                            && eachEmpRec.Country_Code__c != mapOldEMPData.get(eachEmpRec.Id).Country_Code__c) {
                                eachEmpRec.Area__c = mapCountryCode.get(eachEmpRec.Country_Code__c).BDA__r.Name;
                                eachEmpRec.Region__c = mapCountryCode.get(eachEmpRec.Country_Code__c).BDA__r.Parent_BDA__r.Name;
                            }
                    } else {
                        eachEmpRec.Area__c = mapCountryCode.get(eachEmpRec.Country_Code__c).BDA__r.Name;
                        eachEmpRec.Region__c = mapCountryCode.get(eachEmpRec.Country_Code__c).BDA__r.Parent_BDA__r.Name;
                    }
                } else {
                    eachEmpRec.addError(Label.countryCodeNotFound);
                }
            }else{
                eachEmpRec.Area__c = null;
                eachEmpRec.Region__c = null;
            }
        }   
    }
}