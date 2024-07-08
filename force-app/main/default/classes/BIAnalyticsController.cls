/*
* version   Date         Owner             Description
*******************************************************************************************************
* V1.0      03/10/2018   Nitin More        Controller class created
*/
public with sharing class BIAnalyticsController {
	
	@Auraenabled
	public static String getMaerskUserId(){
		String strUserId = UserInfo.getUserId();

        User recUser = [SELECT Id, Name, Maersk_User_Id__c FROM User WHERE Id = :strUserId];
        String strMaerskUserId = (recUser != null) ? recUser.Maersk_User_Id__c: '';
        
        return strMaerskUserId;
	}
	
    @Auraenabled
	public static List<BI_Analytics_Mapping__mdt> getBIAnalyticsMappingDetails(){

		List<BI_Analytics_Mapping__mdt> lstBIMapping = [SELECT Label, MasterLabel, Active__c FROM BI_Analytics_Mapping__mdt
															WHERE Active__c = true];
															
		//System.debug('# lstBIMapping size: ' + lstBIMapping.size());
		//System.debug('# lstBIMapping: ' + lstBIMapping);	
											
		return lstBIMapping; 		 
	}
}