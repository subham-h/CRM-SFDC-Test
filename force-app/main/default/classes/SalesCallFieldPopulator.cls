/*
 * Author   : Nisha
 * Purpose  : Field populator for Sales Call trigger.
 *        
 * Revision Ref Number  Date        Owner                             		 	Description
 * -------- ----------  ----------- -------------------               			-----------
 * 1.0     RQ-000204   11/09/2014   Krishnamoorthi.murugesan@ust-global.com     Populate values in Sales Call "Length" and "Has" fields
 * 2.0     RQ-004292   03/08/2016   nisha.arjunan@UST                  			Created class for CBO Architecture
 * 3.0	   RQ-004108:  14/07/2016	Jiji@UST									Update Liner Brand References in Sales Call as part of Single Contact Model.Start
 * 4.0	   SC-1662	   05-01-2020   Sreya					                    CSAT onboarding for Service Call. 
 * 5.0     SC-1996     15-02-2021   Sreya                                       Bug:Fix CSAT email will be trigger only if contact email is not blank. 
 * 6.0	   SC-2061     09-03-2021	Manik@UST									Country Based List View for Service Calls
*/  

public class SalesCallFieldPopulator {
    
    public static void populateLenghtAndHasFields(List<Sales_Call__c> newSCList){    
        for(Integer i = 0; i < newSCList.size(); i++){ 
            newSCList[i].Agenda_Length__c = 0;
            newSCList[i].Confirmation_Letter_Length__c = 0;
            newSCList[i].Objective_Length__c = 0;
            newSCList[i].Persuasive_Selling_Pitch_Length__c = 0;
            newSCList[i].Post_Call_Notes_Length__c = 0;  
            
            newSCList[i].Has_Agenda__c = false;
            newSCList[i].Has_Confirmation_Letter__c = false;
            newSCList[i].Has_Objective__c = false;
            newSCList[i].Has_Persuasive_Selling_Pitch__c = false;
            newSCList[i].Has_Post_Call_Notes__c = false;
            
            if(newSCList[i].Event_Description__c != null && newSCList[i].Event_Description__c.length() > 0){             
                newSCList[i].Agenda_Length__c = newSCList[i].Event_Description__c.length();
                newSCList[i].Has_Agenda__c = true;            
            }         
            if(newSCList[i].Confirmation_Letter__c != null && newSCList[i].Confirmation_Letter__c.length() > 0){             
                newSCList[i].Confirmation_Letter_Length__c = newSCList[i].Confirmation_Letter__c.length();
                newSCList[i].Has_Confirmation_Letter__c = true;            
            }          
            if(newSCList[i].Objective__c != null && newSCList[i].Objective__c.length() > 0){            
                newSCList[i].Objective_Length__c = newSCList[i].Objective__c.length();
                newSCList[i].Has_Objective__c = true;            
            }          
            if(newSCList[i].Persuasive_Selling_Pitch__c != null && newSCList[i].Persuasive_Selling_Pitch__c.length() > 0){              
                newSCList[i].Persuasive_Selling_Pitch_Length__c = newSCList[i].Persuasive_Selling_Pitch__c.length();
                newSCList[i].Has_Persuasive_Selling_Pitch__c = true;             
            }          
            if(newSCList[i].Post_Call_Notes__c != null && newSCList[i].Post_Call_Notes__c.length() > 0){            
                newSCList[i].Post_Call_Notes_Length__c = newSCList[i].Post_Call_Notes__c.length();
                newSCList[i].Has_Post_Call_Notes__c = true;                
            }
        } 
    }
    //Ver 3.0: #RQ-004108: Update Liner Brand References in Sales Call as part of Single Contact Model.Start
    public static void updateLinerBrand(List<Sales_Call__c> newSCList){
        
        User currentUserRecord = [Select Id, Liner_Brand__c from User Where Id = :UserInfo.getUserId()];
        for(Sales_Call__c scRecords :newSCList){
            // if the user is a single branded user, assign the user liner brand to sales call.
            If(!currentUserRecord.Liner_Brand__c.Contains(';') && scRecords.Liner_Brand__c == NULL ){
                scRecords.Liner_Brand__c = currentUserRecord.Liner_Brand__c; 
            }
        }
    }
    //SC-1662 : Method for updating "Encrypted Service Call Id"
    public static void populateEncryptedId(List<Sales_Call__c> newSCList,SalesCallRecordSelector salCallRecordSelector){
        try{
            map<Id, Contact> mapRelatedContacts =  salCallRecordSelector.mapRelatedContacts;
            Service_Call_Survey_Key__c[] key = [select Crypto_Key__c from Service_Call_Survey_Key__c limit 1];
            Blob cryptoKey = EncodingUtil.base64Decode(key[0].Crypto_Key__c);
            
            for(Sales_Call__c scRecords :newSCList){
                //SC-1996 : Added the condition to check if contact email is not blank.
                if(mapRelatedContacts.get(scRecords.Contact__c) != null && String.isNotBlank(mapRelatedContacts.get(scRecords.Contact__c).Email)){
                    Blob data = Blob.valueOf(scRecords.Id); 
                    Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data ); 
                    string b64Data = EncodingUtil.base64Encode(encryptedData);
                    String encoded = EncodingUtil.urlEncode(b64Data, 'UTF-8');
                    scRecords.Encrypted_Service_Call_Id__c = encoded;
                    scRecords.Survey_sent__c = true;
                    scRecords.Survey_Sent_Date__c = system.today(); 
                }  
            }
        }
        catch(exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Sales_Call__c', 'SalesCallFieldPopulator.populateEncryptedId', new list<Exception>{ex});              
            
        }
    }
    //Ver 3.0: #RQ-004108: Update Liner Brand References in Sales Call as part of Single Contact Model.End
    //SC-2061 : Country Based List View for Service Calls
    public static void updateCountry(List<Sales_Call__c> newSCList){
        Set<String> accountIds = new Set<String>();
        for(Sales_Call__c scRecords :newSCList){
            if(scRecords.Service_Type__c == 'Onboarding'){
                accountIds.add(scRecords.Contact_s_Account__c.Split('/')[1].Split('_')[0]);
            }
        }
        
        Map<id,Account> accountrecordMap = new Map<id,Account>([select id,Country__c from Account where id in:accountIds]);
        if(!accountrecordMap.isEmpty()){
            for(Sales_Call__c scRecords :newSCList){
                if(scRecords.Service_Type__c == 'Onboarding'){
                    scRecords.Country__c = accountrecordMap.get(scRecords.Contact_s_Account__c.Split('/')[1].Split('_')[0]).Country__c;
                }
            }
        }
    }
    
}