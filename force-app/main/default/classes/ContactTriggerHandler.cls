/* 
 * Author   : Ragu
 * Purpose  : Single trigger for Contact object as per CBO architecture
 * 
 * Revision     Ref Number      Date            Owner                         Description
 * --------     ----------      -----------     -------------------           -----------
 * 1.0          RQ-003245       12-Apr-2016     Sunu.Paul@ust-global.com      Code created
 * 2.0                                          Madhava.kotte@ust-global.com
 * 3.0          RQ-004156       25-Jul-2016     Jiji@UST                      Populate Liner Brand in contacts.
 * 4.0          RQ-004319       19-Aug-2016     Jiji@UST                      Remove reference to PrimRY_Contact__c field
 * 5.0          RQ-004366       13-Dec-2016     Ranjini@UST                   Added logic to update community user based on Contact updates.
 * 6.0          RQ-004708       2-Feb-2016      Hitha@UST                     Added logic for not allowing customer contact to be deleted
 * 7.0          RQ-010026       28-Mar-2019     Sidhartha@Maersk              Added call to Validate Phone/Email after insert/update
 * 8.0	   		RQ-012372		24-02-2020		Sidhartha@maersk			  Added Customer Group validation
 * 8.1          SFSE-5757       26-May-2021     nitin@maersk                  Added call to link individual Id if email is populated after insert
 * 9.0          SFMC-7285       09-Jan-2024     Ranjan@maersk                 Added logic to check when individual id is preset on contact insertion and Updation
 */
 
 public class ContactTriggerHandler extends TriggerHandler {
    
    public map<Id, Contact> newMap;
    public map<Id, Contact> oldMap;
    public ContactTriggerHandler() {
        this.newMap = (map<Id, Contact>)Trigger.newMap;
        this.oldMap = (map<Id, Contact>)Trigger.oldMap; 
    }
    
    // Get valid records based on criteria
    public ContactRecordSelector conRecordSelector;
    public static Boolean trigger_afterUpdate = true;
    public static Boolean trigger_afterInsert = true;
    public static Boolean inRecursiveUpdate = false;
    public override void getRecordSelector() {
        conRecordSelector = new ContactRecordSelector(Trigger.new, this.oldMap,this);
    }
    
    public override void onBeforeInsert() {
        
        
        // Validate and update the Record Type of the Contact based on the related Account
        ContactFieldPopulator.updateRecordType(Trigger.new, conRecordSelector.mapRelatedAccounts);
        
        // Populate the Liner Brand of the Contact based on the Owner(For Contacts not created via Lead Conversion)
        ContactFieldPopulator.updateLinerBrand(Trigger.new, conRecordSelector.setCreatorIdForLBUpdate, this); //ver 3.0
        //When individual id is preset on contact insertion
        SyncToSFMCUpdator.updateConSyncToSFMC(Trigger.new,this.oldMap,true);
        //ET logic
        if(!conRecordSelector.emailIdConListMap.IsEmpty()){
            SoftRegistrationUtility.searchConRelETs(conRecordSelector.emailIdConListMap);
        }
    }

    public override void onBeforeUpdate() {
        
        if(!conRecordSelector.lstNewContactForValidation.isEmpty()) {
            ContactFieldPopulator.validateCustomerGroup(conRecordSelector.lstNewContactForValidation, conRecordSelector.lstOldContactForValidation);  
        }
        
        if(!conRecordSelector.lstContactForRTUpdate.isEmpty()) { 
            // Validate and update the Record Type of the Contact based on the related Account
            ContactFieldPopulator.updateRecordType(conRecordSelector.lstContactForRTUpdate, conRecordSelector.mapRelatedAccounts);
        }
        
        if(!conRecordSelector.lstContactForLBUpdate.isEmpty()) {
            // Populate the Liner Brand of the Contact based on the Owner
            ContactFieldPopulator.updateLinerBrand(conRecordSelector.lstContactForLBUpdate, conRecordSelector.setCreatorIdForLBUpdate, this); //Ver 3.0
        }
        SyncToSFMCUpdator.updateIndividualIds(this.newMap,this.oldMap);
        //When individual id is present on contact updation
        SyncToSFMCUpdator.updateConSyncToSFMC(Trigger.New,this.oldMap,false);
    }    
     public override void onAfterInsert() {
        //ET logic
        if(!SoftRegistrationUtility.etConMap.isEmpty()){
            SoftRegistrationUtility.updateConETs(conRecordSelector.emailIdConListMap);
        }
        if (!conRecordSelector.lstContactToSycnWithCMD.isEmpty()){
            SyncContactToCMDUtility.publishContactsEvents(conRecordSelector.lstContactToSycnWithCMD);
        }
         
        if (!conRecordSelector.setContactIdsToAssignIndividualId.isEmpty()){
            ConsentMgmtUtility.populateIndividualIdContact(conRecordSelector.setContactIdsToAssignIndividualId);
        }
        if(!conRecordSelector.conCustomerCode.isEmpty()){
             ContactFieldPopulator.assignContactToAccount(conRecordSelector.conCustomerCode);
         }
        
        //system.debug('@@@@@ conRecordSelector.contPhoneInformaticaWebserviceDetails :' + conRecordSelector.contPhoneInformaticaWebserviceDetails);
         //system.debug('@@@@@ conRecordSelector.contEmailInformaticaWebserviceDetails :' + conRecordSelector.contEmailInformaticaWebserviceDetails);
         if(trigger_afterInsert && (conRecordSelector.contPhoneInformaticaWebserviceDetails.Active__c || conRecordSelector.contEmailInformaticaWebserviceDetails.Active__c || Test.isRunningTest())  && !conRecordSelector.skipInformaticaWebservices) {
             trigger_afterInsert = false;
             
             if((!conRecordSelector.mapEmailIdsToFieldNameForInformatica.IsEmpty() && conRecordSelector.mapEmailIdsToFieldNameForInformatica !=null) 
                || (!conRecordSelector.mapPhoneNumbersToFieldNameForInformatica.IsEmpty() && conRecordSelector.mapPhoneNumbersToFieldNameForInformatica !=null)) {
                    If( Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() && !Test.isRunningTest()) {
                        System.enqueueJob(new ContactPhoneEmailValidate(this.oldMap, conRecordSelector.contactIdForInformatica, conRecordSelector.mapPhoneNumbersToFieldNameForInformatica, conRecordSelector.mapPhoneNumbersWithoutCountryCodeToFieldName, conRecordSelector.mapEmailIdsToFieldNameForInformatica, conRecordSelector.contPhoneInformaticaWebserviceDetails, conRecordSelector.contEmailInformaticaWebserviceDetails));
                    } else {
                        // result need to be updates as Service Unavailable
                        ContactPhoneEmailValidateUtility.updateContactVerificationResult(conRecordSelector.contactIdForInformatica, conRecordSelector.mapEmailIdsToFieldNameForInformatica, conRecordSelector.mapPhoneNumbersToFieldNameForInformatica);

                        String strExDetails = 'Unable to validate phone/email for contactId: ' + conRecordSelector.contactIdForInformatica;
                        strExDetails += ' Queueable Job Limit reached. Total Jobs in queue are ' +  Limits.getQueueableJobs(); 
                        ErrorLogger.writeError('SFDC', 'Contact', 'ContactTriggerHandler', 'Queueable Job Limit Exceeded', 'Queueable Job Limit Exceeded', strExDetails);
                    }
                }
         }

     }
     
    public override void onAfterUpdate() {
        
        if(trigger_afterUpdate && (conRecordSelector.contPhoneInformaticaWebserviceDetails.Active__c || conRecordSelector.contEmailInformaticaWebserviceDetails.Active__c || Test.isRunningTest()) && !conRecordSelector.skipInformaticaWebservices){ 
            trigger_afterUpdate = false;

        if (inRecursiveUpdate) return;
            if((!conRecordSelector.mapEmailIdsToFieldNameForInformatica.IsEmpty() && conRecordSelector.mapEmailIdsToFieldNameForInformatica !=null) || (!conRecordSelector.mapPhoneNumbersToFieldNameForInformatica.IsEmpty() && conRecordSelector.mapPhoneNumbersToFieldNameForInformatica !=null)) {
                If( Limits.getQueueableJobs() != Limits.getLimitQueueableJobs() && !Test.isRunningTest()) {
                    system.debug('this.oldMap>>>> ' + this.oldMap);
                    System.enqueueJob(new ContactPhoneEmailValidate(this.oldMap, conRecordSelector.contactIdForInformatica, conRecordSelector.mapPhoneNumbersToFieldNameForInformatica, conRecordSelector.mapPhoneNumbersWithoutCountryCodeToFieldName, conRecordSelector.mapEmailIdsToFieldNameForInformatica, conRecordSelector.contPhoneInformaticaWebserviceDetails, conRecordSelector.contEmailInformaticaWebserviceDetails));
                } else {
                    // result need to be updates as Service Unavailable
                    ContactPhoneEmailValidateUtility.updateContactVerificationResult(conRecordSelector.contactIdForInformatica, conRecordSelector.mapEmailIdsToFieldNameForInformatica, conRecordSelector.mapPhoneNumbersToFieldNameForInformatica); 
                    
                    String strExDetails = 'Unable to validate phone/email for contactId: ' + conRecordSelector.contactIdForInformatica;
                    strExDetails += ' Queueable Job Limit reached. Total Jobs in queue are ' +  Limits.getQueueableJobs(); 
                    ErrorLogger.writeError('SFDC', 'Contact', 'ContactTriggerHandler', 'Queueable Job Limit Exceeded', 'Queueable Job Limit Exceeded', strExDetails);
                }
            }
        }

        // #RQ-004366. If Contact Status is inactive Inactivate the community user.
        if(!conRecordSelector.setContactIdsToSync.isEmpty()) {
            CommunityUserUtility.syncWithContact(conRecordSelector.setContactIdsToSync);
        }
      /*  if(!conRecordSelector.lstContactForValidation.isEmpty()) {
            system.debug('conRecordSelector.lstContactForValidation' + conRecordSelector.lstContactForValidation.size());
            ContactFieldPopulator.validateCustomerGroup(conRecordSelector.lstContactForValidation);  
        }*/
    }
    
    public override void onBeforeDelete(){
    // #RQ-004708. Do not allow customer contact to be deleted
        if(!conRecordSelector.lstCustomerContact.isEmpty()) {
            ContactValidator.DisplayErrorOnContact(conRecordSelector.lstCustomerContact);
        }
    }
}