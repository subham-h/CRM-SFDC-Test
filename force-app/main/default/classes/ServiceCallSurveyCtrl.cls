/*
* Author   : Naved@Maersk
* Purpose  : Servise Call Survey Page Controller.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-1662     21-Sep-2017 Naved@Maersk            Created.
* 2.0      SPI-100     12-07-2022  Joris@SF                Brand logos and css are now dynamically referenced from the brands cmdt config
*/


public class ServiceCallSurveyCtrl {

    //Variable declaraion.
    public string LinerBrand{get;set;}
    public string linerBrandCSS{get;set;}
    public String encryptedId{get;set;}
    public String feedback{get;set;}
    public String securityCode{get;set;}
    public Survey__c surveyRec{get;set;}
    public String detailedFeedback {get;set;}
    public String suggestionFeedback {get;set;}
    public Boolean surveyComplete{get;set;}
    public string pageName{get;set;}
    public Boolean successMessage{get;set;}
    public Boolean twill{get;set;}//#RQ-012315
    public string language{get;set;}
    public Boolean exceptionCaught {get;set;} //#RQ-007849
    public String exceptionMsg {get;set;} //#RQ-007849
    public  Sales_Call__c surveyServiceCall;
    public string ServiceCallId ;
    private static final Map<String, String> mapLang_LangCode = new Map<String, String>{
        'English' => 'en-US', 
        'French' => 'FR',
        'Italian' => 'it',
        'Portuguese (Brazil)' => 'pt_BR',
        'Chinese (Simplified)' => 'zh_CN',
        'Chinese (Traditional)' => 'zh_TW',
        'Japanese' => 'ja',
        'Korean' => 'ko',
        'Thai' => 'th',
        'Russian' => 'ru',
        'Spanish' => 'es'
        };
    public ServiceCallSurveyCtrl() {
        try{
            surveyServiceCall = new Sales_Call__c();
            feedback = ApexPages.currentPage().getParameters().get('Fb');
            encryptedId = ApexPages.currentPage().getParameters().get('Id');
            twill = false;
            if(test.isRunningTest()){
                encryptedId=EncodingUtil.urlDecode(encryptedId, 'UTF-8');
            }
            Service_Call_Survey_Key__c[] key = [select Crypto_Key__c from Service_Call_Survey_Key__c limit 1];
            Blob cryptoKey = EncodingUtil.base64Decode(key[0].Crypto_Key__c);  
            Blob data = EncodingUtil.base64Decode(encryptedId);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey , data);
            ServiceCallId = decryptedData.toString();
            surveyServiceCall =[select id, EndDateTime__c, Survey_Sent_Date__c, Liner_Brand__c, language__c, OwnerId from Sales_Call__c where Id =: ServiceCallId];    
            if(mapLang_LangCode.containsKey(surveyServiceCall.language__c)){

                language =mapLang_LangCode.get(surveyServiceCall.language__c);
            }
            else {
                language = 'en-US';               

            }
           
            
            LinerBrand = surveyServiceCall.Liner_Brand__c;
            linerBrandCSS = LinerBrand.replaceAll('\\s+', '').toLowerCase();    
            surveyComplete = false;
            exceptionCaught = false;
            exceptionMsg = ''; 
        }
        catch(Exception ex){
            exceptionMsg = label.Incorrect_Url;
            exceptionCaught = true; 
            return ;

        }    

    }

    /**
     * @description Retrieves the location where the css can be found in the system
     * @return  `String`
     */
    public String getBrandCSSLocation() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileLocation(tempLinerBrand,'SurveyServiceCallCSS');
    }

    /**
     * @description Retrieves the filename if the css is part of an archive resource
     * @return  `String`
     */
    public String getBrandCSSFileName() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileName(tempLinerBrand,'SurveyServiceCallCSS');
    }

    /**
     * @description Retrieves the location where the logo can be found in the system
     * @return  `String`
     */
    public String getBrandLogoLocation() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileLocation(tempLinerBrand,'SurveyLogo');
    }

    /**
     * @description Retrieves the filename if the logo is part of an archive resource
     * @return  `String`
     */
    public String getBrandLogoFileName() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        return BrandUtilities.getBrandOrSubBrandFileName(tempLinerBrand,'SurveyLogo');
    }

    /**
     * @description Retrieves the inline CSS values for a brand. Default is none.
     * @return  `String`
     */
    public String getBrandLogoCSS() {
        String tempLinerBrand = LinerBrand.escapeHtml4();
        if (twill) { tempLinerBrand = BrandUtilities.TWILL; }
        String inlineCSS = '';
        if (new List<String>{BrandUtilities.MAERSKLINE, BrandUtilities.SEAGO, BrandUtilities.SEALAND, 
                BrandUtilities.MCC, BrandUtilities.TWILL,BrandUtilities.HAMBURGSUD}.contains(tempLinerBrand)) {
            inlineCSS = 'vertical-align: middle; height:48px;';
        } else if (new List<String>{BrandUtilities.SAFMARINE}.contains(tempLinerBrand)) {
            inlineCSS = 'vertical-align: middle; height:32px;';
        }
        return inlineCSS;
    }

    public void createSurvey(){
        try{
            if(surveyServiceCall.Survey_Sent_Date__c.addDays(7) < date.today()){
               
                exceptionMsg = label.CaseSurveyExpiryError;
                exceptionCaught = true; 
                return ;
            }
            exceptionCaught =false;
            List<Survey__c> svyList = [Select Id,Name, Onboarding_Usability__c,Suggestion_for_Improvement__c, Ease_to_Resolve_Issue__c  From Survey__c where Service_Call__c =: ServiceCallId  limit 1];    

            if(svyList.size()== 0){
                Survey__c svy = new Survey__c();
                svy.Service_Call__c = ServiceCallId;
                if (feedback == null || feedback==''){
                    throw new UserException('Please select How satisfied are you');
                }
                svy.Ease_to_Onboard__c = String.ValueOf(feedback);
                svy.Liner_Brand__c = surveyServiceCall.Liner_Brand__c;
                svy.OwnerId = surveyServiceCall.OwnerId;
                svy.survey_Channel__c= 'Email';
                svy.recordTypeid = label.surveyRecordTypeId;
                insert svy;
                surveyRec=svy;
                
            }
            else{
                surveyRec = svyList[0];
                svyList[0].Ease_to_Onboard__c = String.ValueOf(feedback);
                update svyList[0];
            }
        }
        catch(exception ex){
            exceptionCaught = true; 
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'ServiceCallSurveyCtrl.createSurvey'+ServiceCallId, new list<Exception>{ex});
        }

    }
    public void updateSurvey(){
         try{
            Datetime myDT = Datetime.now();
            String strConvertedDate = myDT.format('dd/MM/yyyy HH:mm', 'GMT')+' UTC';            
            if( String.isBlank(surveyRec.Onboarding_Usability__c )|| surveyRec.Onboarding_Usability__c == null) {
                surveyRec.Onboarding_Usability__c = strConvertedDate + '\n'+detailedFeedback; 
            }
            else {
                surveyRec.Onboarding_Usability__c = surveyRec.Onboarding_Usability__c+'\n\n'+strConvertedDate +'\n'+detailedFeedback;
            }
            if( String.isBlank(surveyRec.Suggestion_for_Improvement__c )|| surveyRec.Suggestion_for_Improvement__c == null) {
                surveyRec.Suggestion_for_Improvement__c = strConvertedDate + '\n'+suggestionFeedback; 
            }
            else {
                surveyRec.Suggestion_for_Improvement__c = surveyRec.Suggestion_for_Improvement__c+'\n\n'+strConvertedDate +'\n'+suggestionFeedback;
            }         
            update surveyRec;
            surveyComplete = true;          
                   
        } 
        catch(Exception ex) {            
            exceptionCaught = true;
            exceptionMsg = Label.Survey_Default_Error_Msg;
            //Added ServiceCall id to the errror logger to debug easily.
            ErrorLogger.writeErrors( 'SFDC', 'Survey', 'ServiceCallSurveyCtrl.createSurvey'+ServiceCallId, new list<Exception>{ex}); 
           // return null;
        }        
    
    }
    
   public class UserException extends Exception{}
}