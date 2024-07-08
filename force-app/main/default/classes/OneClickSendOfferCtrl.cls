/*
Date			Story			Developer 	Description
10-May-2023		SFSE-10894		Aditi		Code Created; Controller class to show validation errors for 'Send Offer on Email'
18-Dec-2023     SFSE-13467      Aditi       Added message to dsiplay if opportunity products are not Included In Email Agreement
*/

public class OneClickSendOfferCtrl {

    //Custom class to store all validations and if they pass/fail for this opportunity
    public class validationError{
        @AuraEnabled public String errorCode{ get; set; }
        @AuraEnabled public String errorMessage{ get; set;}
        @AuraEnabled public Boolean bool{ get; set; }      
    }
    
    public static Map<String, String> oneClickErrorCode_mtdt;
    public static List<validationError> identifiedErrors;
    
    @AuraEnabled(cacheable = false)
    public static List<validationError> fetchErrorCodes(Id opptyId) {

        retrieveMetadata(); // Call the function to retrieve metadata
        System.debug('Printing metadata: ' +oneClickErrorCode_mtdt);

        identifiedErrors = new List<validationError>();
        
        Map<Id, String> mapOppToErr = OneClickValidationHelper.checkAllValidation(new Set<Id>{opptyId},'lwc');        
        String oneClickErrorCode = mapOppToErr.get(opptyId);
        System.debug('oneClickErrorCode' + oneClickErrorCode);
        
        // Checking which validations are satisfied by this opportunity
        for (String eCode : oneClickErrorCode_mtdt.keySet()) {
            validationError ve = new validationError();
            if (oneClickErrorCode.contains(eCode)) {
                ve.errorCode = eCode;
                ve.errorMessage = oneClickErrorCode_mtdt.get(eCode);
                ve.bool = false;
                if(eCode == 'notQualified'){
                    ve.errorMessage += ' '+OneClickValidationHelper.disqualifiedProducts.replaceFirst(', ', '');
                }
            } else {
                ve.errorCode = eCode.replace('Error', '');
                ve.errorMessage = oneClickErrorCode_mtdt.get(eCode);
                ve.bool = true;
            }
            identifiedErrors.add(ve);
        }
        
        System.debug('Identified Errors:' + identifiedErrors);
        return identifiedErrors;
    }
    
    @AuraEnabled(cacheable = false)
    public static Map<String, String> retrieveMetadata() {
        oneClickErrorCode_mtdt = new Map<String, String>();
        
        // Collecting the metadata
        for (One_Click_Error_Code__mdt item : One_Click_Error_Code__mdt.getAll().values()) {
            oneClickErrorCode_mtdt.put(item.Error_Code__c, item.Error_Message__c);
        }

        return oneClickErrorCode_mtdt;
    }

    
    
}