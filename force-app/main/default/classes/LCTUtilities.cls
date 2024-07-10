public class LCTUtilities {
    
    	// Method to generate Liner Brand Logic for case- sherin
	public static String getLinerBrandLogic(LiveChatTranscript lctInstance) {
        
        if (lctInstance.MLL__c == true && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(lctInstance.Liner_Brand__c)) {
            return BrandUtilities.USFLAG;
        } else if (lctInstance.MLL__c == false) {
            return lctInstance.Liner_Brand__c;
        }
        return null;
	}

}