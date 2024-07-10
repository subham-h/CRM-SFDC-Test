/**
* Author   : Ranjini@UST
* Purpose  : Create Emailwarpper List and send the list to EmailUtility class.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-006949   21-Sep-2017 Ranjini@UST             Created.
* 2.0      RQ-007488   7-Dec-2017  Ranjini@ust             Updated.
* 3.0      RQ-007602   19-Dec-2017 Ranjini@ust             Removed the contact auto notification opt out check.
* 4.0      RQ-007464   18-Jan-2018 Ranjini@UST             Adding seperate filter condition for Vendor cases.
* 5.0      RQ-007847   12-Feb-2018 Nisha@Ust               Removed the vendor Code check and  added the caseOrigin check for vendor cases.
* 6.0      RQ-007617   27-Feb-2018 Ranjini@ust             Indication that a survey was sent to a customer(Sent Case Closure)
* 5.1      RQ-007997   03-Mar-2018 Nisha@Ust               Fix Vendor Case Closure Email Logic for manual cases.
* 7.0      RQ-007994   05-Apr-2018 Alok@ibm                China Reply To address based on Case Origin.
* 8.0      RQ-007986   17-Apr-2018 Ranjini@UST             Branded case creation & Closure for Vendor cases
* 9.0      RQ-008343   5-June-2018 Ranjini@ust             Reply To address for Intermodel countries.
*10.0      RQ-008710   25-Jun-2018 Ranjini@ust             Added default email template logic to vendor email template selection.
*11.0      RQ-008582   7-Sep-2018  Nisha@Ust               Updated to send vendor closure email for  intermodal countries with slightly different case origin format. 
*12.0      RQ-008889   24-Sep-2018 Nisha@Ust               Prevent survey sent to internal contacts.
*13.0      RQ-009424   8-Nov-2018 Nisha@Ust                Sealand Apparel Team  reply to address is based on case origin. 
*14.0      RQ-009558   13-Nov-2018 Ranjini@ust             MCC Phillipines is excluded from brand changes.
*15.0      RQ-010617   03-jun-2019 Partha@maersk           added fix for china Intermodal values
*16.0      Rq-010623   13-Aug-2019 Partha@maersk           addded fix for Sealand intermodal
*17.0      RQ-012315   15-Nov-2019 Ranjini@ust             Twill changes.
*18.0      RQ-011816   21-11-2019  Sreya@Maersk            Enabling CSAT for Dispute Cases.
*19.0      RQ-010351   6-1-2019    ramadevi@ust-global.com Added condition to send email only when email field is not empty and IsEmailBounced is false
*20.0      SC-556      24-06-2020  Sreya@Maersk            Added logic for closure email for SCM Product
*21.0      SC-495      08-07-2020  ramadevi@ust            Changed the Condition to identify Twill Cases
*22.0      SC-606      05-08-2020  Sunil.bs@maersk         Added a map which is used to hold Linerbrand and country as key. This is used when direction is not defined in Linerbrandcountry and direction metadata.
*23.0      SC-912      17-08-2020  Avinash@ust             From Address For Tanzania Notifications
*24.0      SC-1160     14-10-2020  Sreya@Maersk            CSAT for LNS BA. As a temporary solution made the CSAT enabled only if case origin is not blank for all the business areas.
*25.0      SC-1124     28-10-2020  Sreya@Maersk            Update SCM Closure Template logic
*26.0      SC-1207     02-11-2020   Naved@maersk           CSAT Included  for MLL Chat & email-to-case
*27.0      SC-1332     05-11-2020   Sreya@Maersk           Bug Fix on wrong Reply to address for Chat Cases with LNS.
*28.0      SC-1249     10-11-2020   Sreya@Maersk           Introducing Maersk L&S as new Brand.
*29.0      SC-1234     25-11-2020   Sunil.bs@maersk        Removed condition to prevent CSAT when origin is blank and added a condition to check to identify vendor case for manual LNS cases      
*30.0      SC-2717     17-08-2021   Sunil.bs@maersk        Added condition to capture SEAGLOBALCCL Reply to Address from Metadata LBDC
*32.0      SC-4024     12-061-2021  ramadevi@ust           Added code to include condition for MSLNAMREL
*33.0      SC-4374     04-05-2022   Sandhya@Maersk         Added condition to include 4PL product
*34.0      SC-3706     08-03-2022   Richa@Maersk           Added condition to include Dispute Cases
*35.0      SC-5695     15-07-2022   Sunil.bs@maersk        Added conditions to pick up reply to address from corresponding SCM global BA address for SCM KC Accounts     
*36.0      SPI-100     14-07-2022   Ronnie@SF              Removed brand hardcoding
*37.0      SC-7438     05-04-2023   Sandhya@maersk         To set from address same as reply to address
*38.0      SC-8107     31-05-2023   Vivek@maersk           To set reply to address based on Case Owners Role for cashbox onboarding
*39.0      SC-7849     13-07-2023   Nayana@maersk          Added logic to handle ECL Reply-to and Template picking logic
*39.0      SC-9013     08-11-2023   Meghna@maersk          Update SCM KC Country BA as "Reply to" for CSAT emails. Part 1/2
*40.0      SC-9639     23-01-2024   Shahanawaz@maersk      Update CSAT logic for Landside Transportation product
*/
public class CaseEmailUtility {
    
    /** 
* @description | send case closure email
* @param mapCases accepts case map
* @param casRecordSelector accepts CaseRecordSelector instance
*/
    public static void sendCaseClosureEmail(Map<Id,Case> mapCases,  CaseRecordSelector casRecordSelector ) {
        
        try{
            if(Generic_TriggerHandler.validateRunForMethod('CaseEmailUtility.sendCaseClosureEmail()', 1)) {
                
                Email_Rule__mdt rule = EmailUtility.getEmailRule('Case', 'Case Closure');
                List<Case> lstCasesToUpdate = new List<Case>();//To update the out bound email count in case if the emails are sent successfully.
                Id disputeRTId = StaticFactory.getRecordTypeIdByName('Case', Label.Dispute); //RQ-011816 - CSAT for Dispute cases.
                
                //RQ-012315.As now CaseRecordSelector is passing through the function, we can get the below maps directly from CaseRecordSelector.
                map<Id, Contact> mapRelatedContacts =  casRecordSelector.mapRelatedContacts;
                map<Id, Geography__c> mapRelatedGeography =  casRecordSelector.mapRelatedGeography;
                map<Id, Account> mapRelatedAccounts =  casRecordSelector.mapRelatedAccounts;
                
                if(rule != null && rule.Is_Active__c) {
                    EmailWrapper mailWrapper = new EmailWrapper('Case', 'Case Closure');
                    
                    Map<String, Id> linerBrandOrgIdMap = BrandUtilities.getBrandAndOrgWideEmailAddressIdMap();
                    
                    // Read from LinerBrand_Direction_and_Country__mdt and store reply to email addresses in a map
                    map<String, String> mapReplyTo = new map<String, String>();
                    map<String, String> mapOriginReplyTo = new map<String, String>();
                    map<String, String> mapIMDReplyTo = new map<String, String>();//#RQ-008710.New map to store IMP Reply address.
                    map<String, String> mapIMDAddressReplyTo = new map<String, String>();//#RQ-008582
                    map<String, String> mapSCMCountryReplyTo = new map<String, String>();//SC-556
                    map<String, String> mapLNSCountryReplyTo = new map<String, String>();//SC-1249
                    map<String, String> mapSCMAccountReplyTo = new map<String, String>();//SC-556
                    map<String, String> mapBrandCountryReplyTo = new  map<String, String>();//SC-606 Added map which holds Liner Brand and country as key. This for storing "reply to email" which does does not have direction defined in linerbrand direction and country metadata
                    map<String, String> map4plReplyTo = new  map<String, String>();
                    map<String, String> map4plReplyTodefault = new  map<String, String>();
                    map<String, String> mapSCMKCAccountReplyTo = new map<String, String>();
                    map<String, SCM_Key_Client_Country_Mapping__mdt> mapSCMKCAccount = new map<String, SCM_Key_Client_Country_Mapping__mdt>();
                    map<String, String> mapRoleBasedReplyTo = new map<String, String>();//SC-8107
                    List<OrgWideEmailAddress> owaList = new list<OrgWideEmailAddress>();
                    map<String, String> mapECLReplyTo = new  map<String, String>(); //SC-7849
                    Map<String, String> landSideOBAReplyToMap = new Map<String, String>();//SC-9639
                    
                    Map<string, LinerBrand_Direction_and_Country__mdt> LBDCs = caseRecordselector.mapLBDCs;
                    for(LinerBrand_Direction_and_Country__mdt lbdc : LBDCs.values()){                        
                        if(lbdc!=null){
                            // RQ-010617 for China intermodal added exclusion rules
                            if(lbdc.MasterLabel.right(3) == 'IMD'){
                                if(lbdc.MasterLabel.mid(3,2) == 'CN' && lbdc.MasterLabel.mid(3,5)!='CNIMD'){
                                    mapIMDReplyTo.put(lbdc.MasterLabel, lbdc.Reply_To_Email__c);
                                }
                                mapIMDReplyTo.put(lbdc.Liner_Brand__c + '-' + lbdc.Country_Name__c, lbdc.Reply_To_Email__c); //#RQ-008710
                                
                            }
                            //#RQ-008582. Added condition for intermodal countries with separate BA for Import and Export Direction.   
                            else if(lbdc.MasterLabel.mid(5,3) == 'IMD'){
                                mapIMDAddressReplyTo.put(lbdc.Liner_Brand__c + '-' + lbdc.Direction__c + '-' + lbdc.Country_Name__c, lbdc.Reply_To_Email__c);   
                            }                       
                            else{
                                mapReplyTo.put(lbdc.Liner_Brand__c + '-' + lbdc.Direction__c + '-' + lbdc.Country_Name__c, lbdc.Reply_To_Email__c); 
                                mapBrandCountryReplyTo.put(lbdc.Liner_Brand__c + '-' + lbdc.Country_Name__c, lbdc.Reply_To_Email__c);//SC-606 Map with only Linerbrand and country as key                          
                                mapOriginReplyTo.put(lbdc.MasterLabel, lbdc.Reply_To_Email__c);//#RQ-007994. Created a new map of master label and replyto address.
                                System.debug('mapOriginReplyTo'+mapOriginReplyTo);
                                
                                // SC -556 : Creating 2 maps only for SCM BAs based on Country and on behalf of account.
                                if(lbdc.MasterLabel.left(3) == 'SCM'){  
                                    if(String.isNotBlank(lbdc.Country_Name__c)){
                                        mapSCMCountryReplyTo.put(lbdc.Country_Name__c,lbdc.Reply_To_Email__c);
                                    }
                                    if(String.isNotBlank(lbdc.On_Behalf_of_Account_ID__c)){
                                        mapSCMAccountReplyTo.put(lbdc.On_Behalf_of_Account_ID__c,lbdc.Reply_To_Email__c);                               
                                    }
                                    //SC-8107 Creating map for storing SCM LBDC records based on Role and Reply to for Cashbox RateMngmt onboarding
                                    if(!String.isEmpty(Lbdc.Role__c)){
                                        mapRoleBasedReplyTo.put(Lbdc.Role__c, lbdc.Reply_To_Email__c);
                                        
                                    }
                                }
                                //SC-1249 : Creating the Map for LNS BA based on Country
                                if(lbdc.MasterLabel.left(3) == 'LNS'){  
                                    if(String.isNotBlank(lbdc.Country_Name__c)){
                                        mapLNSCountryReplyTo.put(lbdc.Country_Name__c+lbdc.MasterLabel.right(3),lbdc.Reply_To_Email__c);
                                    }else{
                                        //SC-1963 for creating map for LNS NAM region BA
                                        mapOriginReplyTo.put(lbdc.MasterLabel, lbdc.Reply_To_Email__c);
                                    }
                                    
                                }                           
                                //Sc-4374 for creating map for FPL
                                if(lbdc.MasterLabel.left(3) == 'FPL'){
                                    if(!String.isEmpty(Lbdc.Role__c)){
                                        for(String rl : Lbdc.Role__c.split(',')){
                                            map4plReplyTo.put(lbdc.SF_4PL_Account__c + '-' + rl, lbdc.Reply_To_Email__c);
                                        }                        
                                    }
                                    map4plReplyTodefault.put(lbdc.SF_4PL_Account__c,lbdc.Reply_To_Email__c);
                                }
                                
                                //SC-7849 for creating map for ECL
                                if(lbdc.MasterLabel.left(2) == 'ED' || lbdc.MasterLabel.left(2) == 'EF'){
                                    if(!String.isEmpty(Lbdc.Role__c)){
                                        for(String rl : Lbdc.Role__c.split(',')){
                                            mapECLReplyTo.put(lbdc.Product__c + '-' + rl, lbdc.Reply_To_Email__c);
                                        }
                                    }
                                }
                                
                                //SC-9639
                                if(lbdc.Product__c == 'Landside Transportation'){
                                    if(!String.isBlank(lbdc.On_Behalf_of_Account_ID__c)){
                                        landSideOBAReplyToMap.put(lbdc.On_Behalf_of_Account_ID__c, lbdc.Reply_To_Email__c);
                                    }
                                }
                            }
                        }                        
                    }
                    
                    //SC-5695 
                    for(SCM_Key_Client_Country_Mapping__mdt SKCC : [Select  On_Behalf_of_Account_ID__c,Relation_to_LBDC_metadata__r.MasterLabel,Relation_to_LBDC_metadata__r.Reply_To_Email__c,Reply_To_Email__c,SCM_KC_Indicator__c,country__c From SCM_Key_Client_Country_Mapping__mdt ]) {
                        if(String.isNotBlank(SKCC.SCM_KC_Indicator__c)){
                            //SC-9013 : Taking reply to address from SCM Key client metadata
                            mapSCMKCAccountReplyTo.put(SKCC.SCM_KC_Indicator__c,SKCC.Reply_To_Email__c);
                            mapSCMKCAccount.put(SKCC.On_Behalf_of_Account_ID__c,SKCC);
                        }
                    }
                    // Prepare list of EmailWrapper.EmailDetail for sending email alert
                    // SC-1160 : CSAT Email will be triggered only if case origin is not blank.Temporary solution until LNS Brand is onboarded.
                    
                    for(Case caseIterator : mapCases.values()) {
                        Boolean isECL = false;
                        Contact relatedContact = mapRelatedContacts.get(caseIterator.ContactId);
                        Geography__c relatedcountry = mapRelatedGeography.get(caseIterator.Country__c);
                        //#RQ-007488. Added internal email address condition.
                        //RQ-007602. Removed the contact auto notification opt out check.
                        //RQ-008889. Removed the internal email address condition.
                        // RQ-010351 - Added condition to send email only when email field is not empty and IsEmailBounced is false
                        if(relatedContact != null && relatedContact.Email != NULL && relatedContact.IsEmailBounced == FALSE){ 
                            EmailWrapper.EmailDetail mailDetail = new EmailWrapper.EmailDetail();
                            mailDetail.sObj = caseIterator;
                            
                            //#RQ-009558. MCC PH Domestic will continue using the old MCC Org wide address.
                            //SC - 556 : Added the condition for SCM product
                            //SC-912 : From Address For Tanzania Notifications
                            //SC-1160 : Added condition for L&S Origin
                            //SC-1249 : Modified the criteria for L&S Brand
                            
                            Account relatedAccount = mapRelatedAccounts.get(caseIterator.AccountId);          
                            
                            //RQ-012315.Twill Reply To Address.
                            //Sc-495 - Changing the contion to identify Twill cases
                            if(caseIterator.Delivery_Channel__c == Label.Twill && caseIterator.RecordTypeId != disputeRTId){
                                mailDetail.strReplyToAddress = mapOriginReplyTo.get('MSLGLOBALMAERSKGO');        
                            } 
                            //SC-3706 : Added condition for Dispute Cases Reply To Address
                            //else if (caseIterator.Sub_Type__c == 'Dispute' && caseIterator.RecordTypeId == disputeRTId) {
                            //mailDetail.strReplyToAddress = BrandUtilities.getDisputeEmailAddress(caseIterator.Liner_Brand__c);
                            //}
                            
                            
                            //SC-1160 : Added condition to set reply to address for L&S Origin
                            //SC-1249 : Modified the criteria for L&S Brand
                            else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(caseIterator.Liner_Brand__c)) {
                                if(String.isNotBlank(caseIterator.Origin) && caseIterator.Origin.right(9) != 'AutoReply'){
                                    if(String.isNotBlank(caseIterator.SCM_KC_Indicator__c) && String.isNotBlank(mapSCMKCAccountReplyTo.get(caseIterator.SCM_KC_Indicator__c)) && mapSCMKCAccountReplyTo.containskey(caseIterator.SCM_KC_Indicator__c)){
                                        mailDetail.strReplyToAddress = mapSCMKCAccountReplyTo.get(caseIterator.SCM_KC_Indicator__c); 
                                    }
                                    else
                                    {
                                        mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin);
                                    }
                                }                               
                                else{
                                    //Sc-4374  Modified the criteria for 4PL product
                                    if(caseIterator.Product__c =='4PL'){
                                        if(map4plReplyTo.containsKey(caseIterator.SF_4PL_Account__c + '-' + casRecordSelector.mapOwnerandRole1.get(caseIterator.OwnerId)))
                                        {   
                                            mailDetail.strReplyToAddress=map4plReplyTo.get(caseIterator.SF_4PL_Account__c + '-' + casRecordSelector.mapOwnerandRole1.get(caseIterator.OwnerId));
                                        }
                                        else if(map4plReplyTodefault.containsKey(caseIterator.SF_4PL_Account__c))
                                        {
                                            mailDetail.strReplyToAddress=map4plReplyTodefault.get(caseIterator.SF_4PL_Account__c);
                                            
                                        }
                                    }
                                    else if(caseIterator.Product__c == 'SCM'){
                                        //SC-8107 adding condition to update reply to based on Role name
                                        if(mapRoleBasedReplyTo.containsKey(casRecordSelector.mapOwnerandRole1.get(caseIterator.OwnerId))){ 
                                            mailDetail.strReplyToAddress = mapRoleBasedReplyTo.get(casRecordSelector.mapOwnerandRole1.get(caseIterator.OwnerId));
                                        }
                                        //SC-5695 
                                        
                                        else if(!String.isBlank(caseIterator.On_Behalf_Account__c) && mapSCMKCAccount.containsKey(caseIterator.On_Behalf_Account__c)){
                                            if(mapSCMKCAccount.get(caseIterator.On_Behalf_Account__c).country__c==relatedcountry.GEO_ID__c)
                                            {
                                                mailDetail.strReplyToAddress = mapSCMKCAccount.get(caseIterator.On_Behalf_Account__c).Reply_To_Email__c;   
                                            }
                                            else
                                            {
                                                mailDetail.strReplyToAddress = mapSCMKCAccount.get(caseIterator.On_Behalf_Account__c).Relation_to_LBDC_metadata__r.Reply_To_Email__c;
                                            }
                                        }
                                        else if(!String.isBlank(caseIterator.On_Behalf_Account__c) && mapSCMAccountReplyTo.containsKey(caseIterator.On_Behalf_Account__c)){
                                            mailDetail.strReplyToAddress = mapSCMAccountReplyTo.get(caseIterator.On_Behalf_Account__c);
                                        }
                                        else if(mapSCMCountryReplyTo.containsKey(caseIterator.Case_Country__c)){ 
                                            mailDetail.strReplyToAddress = mapSCMCountryReplyTo.get(caseIterator.Case_Country__c);
                                        }
                                    }
                                    else if(caseIterator.Direction__c=='Domestic' && (caseIterator.Case_Country__c=='United States' || caseIterator.Case_Country__c=='Canada')){
                                        mailDetail.strReplyToAddress = mapOriginReplyTo.get('LNSNAMDOM');
                                    }
                                    else{
                                        //SC-1234 Modified condition to check vendor case
                                        if(String.isNotBlank(relatedAccount.Vendor_Type__c)){
                                            if(caseIterator.Case_Country__c=='United States' || caseIterator.Case_Country__c=='Canada'){
                                                mailDetail.strReplyToAddress = mapOriginReplyTo.get('LNSNAMEXE');
                                                
                                            }else{
                                                mailDetail.strReplyToAddress = mapLNSCountryReplyTo.get(caseIterator.Case_Country__c+'EXE');
                                            }
                                        }
                                        else{  
                                            if(caseIterator.Case_Country__c=='United States' || caseIterator.Case_Country__c=='Canada'){
                                                mailDetail.strReplyToAddress = mapOriginReplyTo.get('LNSNAMLOG');
                                                
                                            }else{
                                                mailDetail.strReplyToAddress = mapLNSCountryReplyTo.get(caseIterator.Case_Country__c+'LOG');
                                            }                                        
                                        }                                                                           
                                    } 
                                }                              
                            }
                            //SC-9639
                            else if(caseIterator.Product__c == 'Landside Transportation'){
                                if(!String.isBlank(caseIterator.Origin)){
                                    mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin);
                                }
                                else if(!String.isBlank(caseIterator.On_Behalf_Account__c) && !landSideOBAReplyToMap.isEmpty() && landSideOBAReplyToMap.containsKey(caseIterator.On_Behalf_Account__c)){
                                    mailDetail.strReplyToAddress = landSideOBAReplyToMap.get(caseIterator.On_Behalf_Account__c);
                                }
                            }
                            //SC-1207 - CSAT for MLL.
                            else if(caseIterator.Origin == 'MLLUSFLG'){
                                mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin);                                                               
                            }                            
                            //#RQ-009424 : For Seland Apparael Team separate BA exist.
                            //RQ-012315. Added Twill Case origin. If more Twill specific origins come, then this will need to be updated.
                            else if (BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(caseIterator.Liner_Brand__c) 
                                     && caseIterator.Origin != null && Label.Sealand_Apparel_Team_Case_Origin.contains(caseIterator.Origin)) {
                                         mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin); 
                                     }
                            //#RQ-007986.For Sealand and USFlag a single BA exist.
                            //Rq-010623 added fix for sealand only non vendor account or non intermodal ba to enter this condition
                            //SC-2717 added condition to capture SEAGLOBALCCL Reply to Address from Metadata
                            else if ((BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(caseIterator.Liner_Brand__c) && 
                                      !((Label.IMD_Vendor_Countries.Contains(caseIterator.Case_Country__c) && relatedAccount.Vendor_Type__c != null 
                                         && (caseIterator.Origin== null || caseIterator.Origin=='')) 
                                        || (caseIterator.Origin!= null && caseIterator.Origin!='' && caseIterator.Origin.contains('IMD')))) 
                                     || BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.USFLAG).contains(caseIterator.Liner_Brand_Logic__c)) {
                                         if ((String.isNotBlank(caseIterator.Origin) && caseIterator.Origin.left(9) == 'SEAGLOBAL') &&  String.isNotBlank(mapOriginReplyTo.get(caseIterator.Origin))){
                                             mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin);  
                                         }
                                         else if (mapReplyTo.Containskey(caseIterator.Liner_Brand_Logic__c + '-' + null + '-' + caseIterator.Case_Country__c)){
                                             mailDetail.strReplyToAddress = mapReplyTo.get(caseIterator.Liner_Brand_Logic__c + '-' + null + '-' + caseIterator.Case_Country__c);                            
                                         }
                                     }
                            //#RQ-008582. Populate the ReplyTo address from mapIMDAddressReplyTo for intermodal Countries having separate BA for Import and Export Direction.
                            else if((Label.IMD_Countries_with_Separate_BA_for_Directions.Contains(caseIterator.Case_Country__c) && relatedAccount.Vendor_Type__c != null) ||(caseIterator.Origin != null && caseIterator.Origin.mid(5,3) == 'IMD' && caseIterator.Origin.right(3) != 'IMD')){
                                mailDetail.strReplyToAddress =  mapIMDAddressReplyTo.get(caseIterator.Liner_Brand__c + '-' + caseIterator.Direction__c + '-' + caseIterator.Case_Country__c);                             
                            }
                            
                            //#RQ-008343. ReplyTo for Intermodel countries.
                            //#RQ-008710. Logic updated to use the mapIMDReplyTo map.
                            else if((Label.IMD_Vendor_Countries.Contains(caseIterator.Case_Country__c) && relatedAccount.Vendor_Type__c != null) ||(caseIterator.Origin != null && caseIterator.Origin.right(3) == 'IMD')){
                                if(mapIMDReplyTo.containsKey(caseIterator.Origin)){
                                    mailDetail.strReplyToAddress = mapIMDReplyTo.get(caseIterator.Origin);
                                }else{
                                    mailDetail.strReplyToAddress = mapIMDReplyTo.get(caseIterator.Liner_Brand__c + '-' + caseIterator.Case_Country__c);
                                }
                            }
                            //SC-7849 Added logic for ECL
                            else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(caseIterator.Liner_Brand__c)){
                                if(caseIterator.Origin != null && (caseIterator.Origin.startsWithIgnoreCase('ED') || caseIterator.Origin.startsWithIgnoreCase('EF'))){ //if E-mail channel
                                    mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin);
                                    isECL = true;                                       
                                }
                                //if manual case then use Product and user role
                                else if(caseIterator.Origin == null && caseIterator.Product__c!=null && (caseIterator.Product__c.startsWithIgnoreCase('E-') || Label.EFR_Products.containsIgnoreCase(caseIterator.Product__c)) ){                                       
                                    mailDetail.strReplyToAddress= mapECLReplyTo.containsKey(caseIterator.Product__c + '-' + casRecordSelector.mapOwnerandRole1.get(caseIterator.OwnerId)) ? 
                                        mapECLReplyTo.get(caseIterator.Product__c + '-' + casRecordSelector.mapOwnerandRole1.get(caseIterator.OwnerId)) : '';
                                    isECL = true;
                                }
                            }
                            
                            //#RQ-007994.For country china Email To Cases, ReplyTo address is taken from mapOriginReplyTo. This will not be applicable for manual cases as they do not have origin.
                            else if(caseIterator.Origin != '' && caseIterator.Case_Country__c == 'China' && mapOriginReplyTo.ContainsKey(caseIterator.Origin)){
                                mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin); 
                            }
                            
                            // SC-4024 : for NAM reply should BA address.                            
                            else if(caseIterator.Origin != '' && caseIterator.Origin == Label.MSLNAMREL){
                                mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin); 
                            }
                            if(caseIterator.Origin != '' && mapOriginReplyTo.containsKey(caseIterator.Origin)){
                                mailDetail.strReplyToAddress = mapOriginReplyTo.get(caseIterator.Origin); 
                            }
                            
                            // SC-606 Modified below code to have "reply to email" updated to actual BA when direction is not defined in Linerbrandcountry and direction metadata.
                            //SC-12345 modified final catch for setting reply to address to skip for Maersk L&S
                            if ((mailDetail.strReplyToAddress == null || mailDetail.strReplyToAddress == '') && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(caseIterator.Liner_Brand__c)) {
                                if(mapReplyTo.ContainsKey(caseIterator.Liner_Brand__c + '-' + caseIterator.Direction__c + '-' + caseIterator.Case_Country__c)){
                                    mailDetail.strReplyToAddress = mapReplyTo.get(caseIterator.Liner_Brand__c + '-' + caseIterator.Direction__c + '-' + caseIterator.Case_Country__c); 
                                }
                                else if (mapBrandCountryReplyTo.Containskey(caseIterator.Liner_Brand__c  + '-' + caseIterator.Case_Country__c)){
                                    mailDetail.strReplyToAddress = mapBrandCountryReplyTo.get(caseIterator.Liner_Brand__c + '-' + caseIterator.Case_Country__c);
                                }
                            }
                            //SC-7438 To set from address same as reply to address
                            if (mailDetail.idOrgWideEmailAddress == null) {
                                if (mailDetail.strReplyToAddress != null) {
                                    owaList = new List<OrgWideEmailAddress>([SELECT Address FROM OrgWideEmailAddress WHERE Address = :mailDetail.strReplyToAddress LIMIT 1]);
                                    if (!owaList.isEmpty()) {
                                        mailDetail.idOrgWideEmailAddress = owaList[0].Id;
                                    }
                                } 
                                if (mailDetail.idOrgWideEmailAddress == null && linerBrandOrgIdMap.containsKey(caseIterator.Liner_Brand__c)){
                                    mailDetail.idOrgWideEmailAddress = linerBrandOrgIdMap.get(caseIterator.Liner_Brand__c);
                                }
                            }
                            mailDetail.strChatterContent = 'Case closure email sent using {Email Template Name}.'+ '\n' + 'Case Resolution Summary' + '\n' + caseIterator.Resolution_Summary__c; 
                            
                            //SC-495 : Based on the delivery Channel the Twill cases are identified hence updated the condition
                            if( caseIterator.Delivery_Channel__c == Label.Twill && caseIterator.RecordTypeId != disputeRTId){
                                mailDetail.lstFilterValues.add(Label.Twill);         
                            }
                            //SC-3706 : To identify Dispute templates
                            //else if(caseIterator.Sub_Type__c == 'Dispute' && caseIterator.RecordTypeId == disputeRTId){
                            //mailDetail.lstFilterValues.add(Label.Dispute);         
                            //}
                            
                            //SC-1160 : Added the condition for LNS origin. Template mapping based on country. 
                            //SC-1249 : Modified the criteria for L&S Brand including SCM
                            else if (BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(caseIterator.Liner_Brand__c)) {
                                if (String.isNotBlank(relatedAccount.Vendor_Type__c)||String.isNotBlank(relatedAccount.Vendor_Code__c)) {
                                    mailDetail.lstFilterValues.add(BrandUtilities.MAERSKLS + caseIterator.Case_Country__c + true);
                                    mailDetail.lstFilterValues.add(BrandUtilities.MAERSKLS + true);
                                } else {
                                    mailDetail.lstFilterValues.add(BrandUtilities.MAERSKLS + caseIterator.Case_Country__c + false);
                                    mailDetail.lstFilterValues.add(BrandUtilities.MAERSKLS);
                                }
                            }
                            //SC-1207 - Set it for  MLLUSFlag
                            else if(caseIterator.Origin == 'MLLUSFLG'){       
                                mailDetail.lstFilterValues.add('USFlag');          
                            }
                            // Closure email for vendor cases                                            
                            //#RQ-008582 : Added condition for intermodal caseorgin with slightly different format.
                            else if(((relatedAccount != null && Label.IMD_Vendor_Countries.Contains(caseIterator.Case_Country__c) && relatedAccount.Vendor_Type__c != null) ||(caseIterator.Origin != null && (caseIterator.Origin.right(3) == 'IMD' || caseIterator.Origin.mid(5,3) == 'IMD')) 
                                     || (!BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(caseIterator.Liner_Brand__c) &&(String.isNotBlank(relatedAccount.Vendor_Type__c)||String.isNotBlank(relatedAccount.Vendor_Code__c))))&&casRecordSelector.mapEmdts.containsKey(caseIterator.Liner_Brand_Logic__c + caseIterator.Case_Country__c+true)) {
                                         
                                         mailDetail.lstFilterValues.add(caseIterator.Liner_Brand_Logic__c + caseIterator.Case_Country__c+true);//#RQ-007986
                                         
                                         //#RQ-008710. If no countries are specified in the custom metadata record and filter 2 is checked , the default engliash email template is selected.
                                         mailDetail.lstFilterValues.add(caseIterator.Liner_Brand_Logic__c +true);
                                         
                                     }                                                               
                            mailDetail.lstFilterValues.add(caseIterator.Liner_Brand_Logic__c + caseIterator.Case_Country__c+false);//#RQ-007986
                            mailDetail.lstFilterValues.add(caseIterator.Liner_Brand_Logic__c); 
                            //SC-7849 - This will remove brand value and add ECL to ensure right ECL template is picked
                            if(isECL){
                                mailDetail.lstFilterValues.clear();
                                mailDetail.lstFilterValues.add('ECL' + caseIterator.Case_Country__c+false);
                                mailDetail.lstFilterValues.add('ECL');
                            }                            
                            mailWrapper.lstEmailDetails.add(mailDetail);
                        }                   
                    }
                    
                    if(!mailWrapper.lstEmailDetails.isEmpty()) {
                        EmailUtility.sendEmails(mailWrapper);                        
                    }
                    
                    //Get the list of Cases for which emails are sent successfully and increment the outbound email counts.                    
                    for(EmailWrapper.EmailDetail mailDetail : mailWrapper.lstEmailDetails) {
                        if(mailDetail.mailStatus == EmailWrapper.EmailStatus.SUCCESS){
                            
                            //As this is an after update context we can not directly update the cases, instead we need to create new instances.
                            Case caseToUpdate = new Case(Id = ((case)mailDetail.sObj).Id, Count_Case_Outbound_Email__c = ((case)mailDetail.sObj).Count_Case_Outbound_Email__c, Count_Emails_To_Contact__c = ((case)mailDetail.sObj).Count_Emails_To_Contact__c);
                            caseToUpdate.Count_Case_Outbound_Email__c = caseToUpdate.Count_Case_Outbound_Email__c +1;
                            caseToUpdate.Count_Emails_To_Contact__c = caseToUpdate.Count_Emails_To_Contact__c +1;
                            //#RQ-007617
                            if(!caseToUpdate.Case_Closure_Sent__c){
                                caseToUpdate.Case_Closure_Sent__c = true;
                            }
                            lstCasesToUpdate.add(caseToUpdate);
                        }
                    }
                    
                    if(lstCasesToUpdate.size()>0 && Schema.sObjectType.Case.isUpdateable()){
                        
                        TriggerExecutionController.skipCaseTrigger(true);                    
                        Database.update(lstCasesToUpdate, false);
                        TriggerExecutionController.skipCaseTrigger(false);
                    }
                }
            }
        } catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'sendCaseClosureEmail(Map<Id,Case> mapCases, map<Id, Contact> mapRelatedContacts)', new list<Exception>{ex});
        }
    }
}