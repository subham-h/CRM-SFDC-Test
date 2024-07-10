public inherited sharing class TargetSettingUtil {
	public static String generateUniqueIdFromString(String strInput) {
		return EncodingUtil.base64Encode(Blob.valueOf(strInput));
    }
    
    public static String getMeasureFromRofoVersion(String rofoVersion) {
        String qtrName = rofoVersion.substring(4,6);
        if(qtrName == TargetSettingConstants.QUARTER_ONE 
        || qtrName == TargetSettingConstants.QUARTER_TWO 
        || qtrName == TargetSettingConstants.QUARTER_THREE){
            return TargetSettingConstants.ROLLING_FORECAST;
        } else if (qtrName == TargetSettingConstants.QUARTER_FOUR) {
            return TargetSettingConstants.BUDGET;
        } else {
            return null;
        }
    }
    
    public static String getYearRofoVersion(String rofoVersion) {
        return rofoVersion.substring(6,10);
    }
    
    public static Set<String> getPicklistValues(String objectName, String fieldName) {
        Set<String> retVal = new Set<String>();
        List<Schema.PicklistEntry> listPicklistEntry = 
            Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for (Schema.PicklistEntry eachPl : listPicklistEntry) {
            retVal.add(eachPl.getValue());
        }

        return retVal;
    }
}