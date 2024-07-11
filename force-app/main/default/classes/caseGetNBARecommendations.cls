/*
Description  : This Class is designed to Return Recommendation Records to the Generate tool of next best action strategy

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0           23/09/2021         sunil.bs@maersk.com                         Get Recommendations basis RFC being Container Status Enquiry
* V2.0           02/05/2022         sunil.bs@maersk.com                         Moved NBA Reporting code logic to a new class
* V3.0           16/05/2022         Richa@Maersk.com                            Added check to exculde Delivery Order recommendation for certain countries-brands
* V4.0           03/11/2022         Sunil.bs@Maersk.com                         Bypassed NBA for Hamburgsud
* V5.0           01/12/2022         Harmeet@Maersk.com                          Added a filter in the Query for Recommendation to query only isActive = TRUE Records 
* V6.0           08/02/2023         ramadevi@Maersk.com                         Present NBA to External Contacts Only
*-------------------------------------------------------------------------------------------------------------------
*/


public class caseGetNBARecommendations{
    
    public class recombasedonRFC{
        @InvocableVariable(label='Case ID')
        public String caseId;
    }
    
    
    @InvocableMethod(label='GetNextBestActionRecommendations')
    public static List<List<Recommendation>> GetNextBestActionRecommendations(list<recombasedonRFC> inputrequests){
        List<Recommendation> recomlist = new List<Recommendation>();
        List<List<Recommendation>> recomreclist = new List<List<Recommendation>>();
        List<Case> inputcase = new List<Case>();
        Integer noOfCases = Integer.valueOf(System.label.Case_NBA_Transport_Cases_Count);
        Integer noOfDays = Integer.valueOf(System.label.Case_NBA_Transport_Days);
        Boolean showTransportSubRecommendation = false;
        Boolean showDORecommendation = true;
        Set<String> setCountries = new Set<String>();
        Set<String> setBrands = new Set<String>();
        List<String> excludedEmailDomains = Label.ExcludedEmailDomains_for_NBA.toLowercase().Split(',');
        system.debug('excludedEmailDomains ##'+excludedEmailDomains );
        try{
            inputcase = [select Id, Subject,ContactId,SuppliedEmail,Contact.Email,Contact.Recordtype.DeveloperName,Case_Channel__c,Status,Product__c,type,Reason_For_Case__c,recordtypeId,Sub_Type__c, Recommendation_Presented__c,Case_Country__c,Liner_Brand__c from case where Id =: inputrequests[0].caseId and Contact.Recordtype.DeveloperName != 'Internal_Contact' ];   
            if(inputcase != null && !inputcase.isEmpty()){
                if((!BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(inputcase[0].Liner_Brand__c)) && ((inputcase[0].Contact <> NULL && !excludedEmailDomains.contains(inputcase[0].Contact.Email.split('@')[1])) || (inputcase[0].Contact == NULL && !excludedEmailDomains.contains(inputcase[0].SuppliedEmail.split('@')[1]))) ){
                if(!String.isEmpty(inputcase[0].ContactId) && !(inputcase[0].status.startswith('Closed'))){
                    Datetime startdt = system.now().addDays(-noOfDays);
                    List<Case> caseList = [Select Id From Case Where ContactId =: inputcase[0].ContactId AND CreatedDate >=: startdt AND Product__c = 'Ocean' AND Reason_For_Case__c = 'Container Maritime Tracking Request' ];
                    system.debug('****caseList.size()-->'+caseList.size());
                    if(!caseList.isEmpty() && caseList.size() >= noOfCases){
                        showTransportSubRecommendation = true;
                    }
                }
                if(inputcase[0].Case_Country__c != Null && inputcase[0].Liner_Brand__c != Null) {
                    List<General_Key_Value_Configurations__mdt> lstGenKeyValueMetaData = [SELECT Id, First_Field_Value__c,Second_Field_Value__c, Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'DONBAExclusion' ];
                    for(General_Key_Value_Configurations__mdt mdt : lstGenKeyValueMetaData)
                    { 
                        if(mdt.Key__c == 'DONBAExclusion' && mdt.First_Field_Value__c != Null){
                            setCountries.addAll(mdt.First_Field_Value__c.toLowerCase().split(','));
                        }
                        if(mdt.Key__c == 'DONBAExclusion' && mdt.Second_Field_Value__c != Null){
                            setBrands.addAll(mdt.Second_Field_Value__c.toLowerCase().split(','));
                        }
                    }
                    if(!setBrands.isEmpty() && setBrands.contains(inputcase[0].Liner_Brand__c.toLowerCase()) && !setCountries.isEmpty() && setCountries.contains(inputcase[0].Case_Country__c.toLowerCase())){
                        showDORecommendation = false;//SC-5126
                    }     
                }                         
                
                Map<ID, Recommendation> mapRecomm = new Map<ID, Recommendation>([select Name,Description,ActionReference,id,ImageId,AcceptanceLabel,RejectionLabel from Recommendation WHERE IsActive__c = TRUE]);                           
                
                //Priority 1 
                if(inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case',Label.External_Case) && inputcase[0].ContactId == Null && inputcase[0].Case_Channel__c=='E-mail'  && !(inputcase[0].status.startswith('Closed'))){
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Contact_Update_Recommendation_RecId));                           
                }
                //Priority 2
                if(inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && inputcase[0].Product__c == 'Ocean' && inputcase[0].type == 'cargo/container' && inputcase[0].Sub_Type__c == 'Container Status' && inputcase[0].Case_Channel__c=='E-mail' && !(inputcase[0].status.startswith('Closed'))){                          
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Container_Tracking_Recommendation_RecId));
                }
                
                //Priority 3
                if(showDORecommendation && inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && inputcase[0].Product__c == 'Ocean' && inputcase[0].Sub_Type__c == 'Delivery Order/Container Release' && inputcase[0].Case_Channel__c=='E-mail' && !(inputcase[0].status.startswith('Closed'))){                          
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Delivery_Order_Recommendation_RecId));
                }
                
                //Priority 4
                if(inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && inputcase[0].Product__c == 'Ocean' && inputcase[0].type == 'Charges, Invoice & Payment' && inputcase[0].Sub_Type__c == 'Invoice / Payer Party' && inputcase[0].Case_Channel__c=='E-mail'  && !(inputcase[0].status.startswith('Closed'))){
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Email_Update_Recommendation_RecId));                                                       
                } 
                //Priority 5
                if(inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && inputcase[0].Product__c == 'Ocean' && inputcase[0].type == 'Charges, Invoice & Payment' && inputcase[0].Sub_Type__c == 'Invoice / Payer Party' && inputcase[0].Case_Channel__c=='E-mail'  && !(inputcase[0].status.startswith('Closed'))){
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Invoice_Enquiry_Recommendation_RecId));                                                       
                }
                //Priority 6
                if(inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && inputcase[0].Product__c == 'Ocean' && inputcase[0].Case_Channel__c=='E-mail'  && !(inputcase[0].status.startswith('Closed')) && (inputcase[0].Sub_Type__c == 'Submit SI/BL/VC' || inputcase[0].Sub_Type__c == 'Request SI/BL/VC')){
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Bill_Of_Lading_Self_Service_Recommendation_RecId));                                                       
                }
                //Priority 7
                if(inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && inputcase[0].Product__c == 'Ocean' && inputcase[0].Sub_Type__c == 'Amend SI/BL/VC' && inputcase[0].Case_Channel__c=='E-mail' && !(inputcase[0].status.startswith('Closed'))){
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Amend_Bill_Of_Lading_Recommendation_RecId));                                                       
                }
                
                //Priority 8//Added by Sandeep for SC-3495
                if(inputcase[0].recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && inputcase[0].Product__c == 'Ocean' && inputcase[0].Sub_Type__c == 'Booking Confirmation Request' && inputcase[0].Case_Channel__c=='E-mail' && !(inputcase[0].status.startswith('Closed'))){                          
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Booking_Confirmation_Recommendation_RecId));
                }
                
                //Priority 9
                if(showTransportSubRecommendation){                          
                    recomlist.add(mapRecomm.get(Label.Case_NBA_Transport_Subscription_Recommendation_RecId));
                }
                }
            }//end
            
            
           /*  for (NBA_Recommendation_Trigger__mdt NBA_recom : [select id,Channel__c,Product__c,Recommendation_Id__c,Record_Type__c,Status__c,Sub_Type__c,Type__c,Priority__c from NBA_Recommendation_Trigger__mdt where Channel__c =:'E-mail' order by Priority__c asc])
             {   
                 List<String> subtyp = NBA_recom.Sub_Type__c.split(',');
                 for(String value : subtyp){

                 if(NBA_recom.Record_Type__c!=NULL && NBA_recom.Product__c!=Null && NBA_recom.Channel__c!=NULL && NBA_recom.Status__c!=NUll && NBA_recom.Recommendation_Id__c!=NULL)
                 {
                     
                     
                     if(NBA_recom.Sub_Type__c!=NULL && NBA_recom.Type__c!=NULL)
                     {    
                          if(inputcase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case',NBA_recom.Record_Type__c) && inputcase.Product__c == NBA_recom.Product__c && inputcase.type == NBA_recom.Type__c && inputcase.Sub_Type__c == value && inputcase.Case_Channel__c == NBA_recom.Channel__c && !(inputcase.status.startswith(NBA_recom.Status__c))){                          
                                recomlist.add(mapRecomm.get(NBA_recom.Recommendation_Id__c));
                             
                          }
                     }
                     else if(NBA_recom.Sub_Type__c!=NULL && NBA_recom.Type__c==NULL)
                     {    
                        
                           if(inputcase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case',NBA_recom.Record_Type__c) && inputcase.Product__c == NBA_recom.Product__c && inputcase.Sub_Type__c == value && inputcase.Case_Channel__c == NBA_recom.Channel__c && !(inputcase.status.startswith(NBA_recom.Status__c))){                          
                                recomlist.add(mapRecomm.get(NBA_recom.Recommendation_Id__c));
                           }
                     }
                     else
                     {
                          if(inputcase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case',NBA_recom.Record_Type__c) && inputcase.Product__c == NBA_recom.Product__c  && inputcase.Case_Channel__c == NBA_recom.Channel__c && !(inputcase.status.startswith(NBA_recom.Status__c))){                          
                                recomlist.add(mapRecomm.get(NBA_recom.Recommendation_Id__c));
                            }
                     }
                    
       }
                 }
             }*/
            
            
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'GetNextBestActionRecommendations', new list<Exception>{ex});
        }
        recomreclist.add(recomlist);
        return recomreclist;
    }
    
}