global class Batch_ContactLoader implements Database.Batchable<sObject>{
     global Database.QueryLocator start(Database.BatchableContext BC) { 
     String query = 'SELECT id,customer_code__c,Unique_Email_Address__c,Preferred_Language__c,Liner_Brands__c,Contact_Status__c,Contact_Type__c,Dataload_Status__c,Department__c,Email__c,Extension_Number__c,External_ID__c,First_Name__c,Job_Role__c,Last_Name__c,Duplicate_Email__c,Salutation__c,Title__c,telephone_dialing_code__c ,telephone_number__c,mobile_dialing_code__c ,mobile_number__c,fax_dialing_code__c,fax_number__c from Contact_Loader__c where Dataload_Status__c = \'New\'';     
         return Database.getQueryLocator(query);
     }
     
     global void execute(Database.BatchableContext BC, List<Contact_Loader__c> contactloaderList) {
         Map<string,Contact_Loader__c> contloadMap= new Map<string,Contact_Loader__c>(); 
         Map<string,Contact> contactMap = new Map<string,Contact>();
         Map<string,Contact> contactEmailMap = new Map<string,Contact>();
         Map<string,string> cust_codeMap = new Map<string,string>();
         Map<string,account> accountMap = new Map<string,account>();
         List<string> ResultList= new List<string>();
         Map<string,string> contactLoadEmailMap = new Map<string,string>();
         map<string,string> emailExtIdMap = new map<string,string>();
         set<string>contactLoadEmailSet = new set<string>();
         for(Contact_Loader__c cl : contactloaderList){
             contloadMap.put(cl.external_id__c,cl); 
             cust_codeMap.put(cl.customer_code__c,cl.external_id__c);
             if(cl.email__c!=null){
                 contactLoadEmailSet.add(cl.email__c);  
             }       
         }
         List<Account> accList = new List<Account>([select id,customer_code__c from Account where customer_code__c IN:cust_codeMap.KeySet()]);         
         for(Account acc : accList ){
             accountMap.put(acc.customer_code__c,acc);
         }
         
         List<Contact> conlist = new List<Contact>([select id,external_id__c,contact_type__c,Email from contact where external_id__c IN:contloadMap.KeySet()]);         
         for(Contact conlst : conlist ){
             contactMap.put(conlst.external_id__c,conlst);
         }
         
     if(contactLoadEmailSet!=null && !contactLoadEmailSet.isEmpty()){ 
         List<Contact> conEmaillist = new List<Contact>([select id,external_id__c,contact_type__c,Email,Liner_Brands__c from contact where Email IN:contactLoadEmailSet]);         
         for(Contact conEmaillst : conEmaillist ){
             contactEmailMap.put(conEmaillst.Email,conEmaillst);
         }
     }
        list<contact> contListUpd = new list<contact>();
        list<contact> contListcnvrt = new list<contact>();
        List<Contact> contListInst = new List<Contact>();
        map<string,string> ResultMap= new map<string,string>();
        List<string> linerbrandlst = new List<string>();
        if(!contloadMap.isEmpty()){ 
            for(string con:contloadMap.KeySet()){ //Check based on External id
                if(contactMap.containsKey(con) && (contactMap.get(con).external_id__c!=null)){
                    if(con == contactMap.get(con).external_id__c){
                         //update                      
                         if(contactMap.get(con).contact_type__c!=null && (!(contactMap.get(con).contact_type__c).contains('Finance'))){
                             contactMap.get(con).contact_type__c= contactMap.get(con).contact_type__c + ';' + 'Finance';
                             
                         }else{
                             contactMap.get(con).Contact_Type__c='Finance';                 
                         }
                         contListUpd.add(contactMap.get(con));
                     }
                }else if(contactEmailMap.containsKey(contloadMap.get(con).email__c)){ //conversion                   
                        if(contloadMap.get(con).email__c == contactEmailMap.get(contloadMap.get(con).email__c).email && contactEmailMap.get(contloadMap.get(con).email__c).External_Id__c==null){
                            if(!(contactEmailMap.get(contloadMap.get(con).email__c).contact_type__c).contains('Finance')){
                                contactEmailMap.get(contloadMap.get(con).email__c).contact_type__c= contactEmailMap.get(contloadMap.get(con).email__c).contact_type__c + ';' + 'Finance';                        
                            }
                            
                            contactEmailMap.get(contloadMap.get(con).email__c).RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
                            contactEmailMap.get(contloadMap.get(con).email__c).Unique_Email_Address__c=contloadMap.get(con).Email__c;
                            //cont.AccountId=contloadMap.get(con).Account__r.id;
                            if(contloadMap.get(con).customer_code__c!=null && accountMap.containsKey(contloadMap.get(con).customer_code__c)){                        
                                contactEmailMap.get(contloadMap.get(con).email__c).AccountId=accountMap.get(contloadMap.get(con).customer_code__c).Id;                    
                            }
                            if(contloadMap.get(con).Liner_Brands__c!=null){
                                linerbrandlst=contloadMap.get(con).Liner_Brands__c.split(';');
                                for(string lb:linerbrandlst){
                                    if(contactEmailMap.get(contloadMap.get(con).email__c).Liner_Brands__c!=null && !(contactEmailMap.get(contloadMap.get(con).email__c)).Liner_Brands__c.contains(lb)){
                                        contactEmailMap.get(contloadMap.get(con).email__c).Liner_Brands__c += ';' + lb;
                                    }else{
                                        contactEmailMap.get(contloadMap.get(con).email__c).Liner_Brands__c = lb;                                    
                                    }
                                }                        
                            }
                             contactEmailMap.get(contloadMap.get(con).email__c).Contact_Status__c = contloadMap.get(con).Contact_Status__c;                            
                             contactEmailMap.get(contloadMap.get(con).email__c).Department=contloadMap.get(con).Department__c;
                             contactEmailMap.get(contloadMap.get(con).email__c).Email=contloadMap.get(con).Email__c;
                             contactEmailMap.get(contloadMap.get(con).email__c).Extension_Number__c=contloadMap.get(con).Extension_Number__c;
                             //contactEmailMap.get(contloadMap.get(con).email__c).External_ID__c=contloadMap.get(con).External_ID__c;
                             if(contloadMap.get(con).fax_dialing_code__c!=null){
                                 contactEmailMap.get(contloadMap.get(con).email__c).Fax='+' +contloadMap.get(con).fax_dialing_code__c + ' ' + contloadMap.get(con).fax_number__c;
                             }
                             contactEmailMap.get(contloadMap.get(con).email__c).FirstName=contloadMap.get(con).First_Name__c;
                             contactEmailMap.get(contloadMap.get(con).email__c).Job_Role__c=contloadMap.get(con).Job_Role__c;
                             contactEmailMap.get(contloadMap.get(con).email__c).LastName=contloadMap.get(con).Last_Name__c;
                             if(contloadMap.get(con).mobile_dialing_code__c!=null){
                                 contactEmailMap.get(contloadMap.get(con).email__c).MobilePhone='+' +contloadMap.get(con).mobile_dialing_code__c + ' ' + contloadMap.get(con).mobile_number__c;
                             }
                             contactEmailMap.get(contloadMap.get(con).email__c).Duplicate_Email__c=contloadMap.get(con).Duplicate_Email__c;
                             if(contloadMap.get(con).telephone_dialing_code__c!=null){
                                 contactEmailMap.get(contloadMap.get(con).email__c).Phone='+' +contloadMap.get(con).telephone_dialing_code__c + ' ' + contloadMap.get(con).telephone_number__c;
                             }
                             contactEmailMap.get(contloadMap.get(con).email__c).Preferred_Language__c=PreferedLanguageMapCtrl.mapOfisoLanguageCode.get(contloadMap.get(con).Preferred_Language__c);
                             contactEmailMap.get(contloadMap.get(con).email__c).Salutation=contloadMap.get(con).Salutation__c;
                             contactEmailMap.get(contloadMap.get(con).email__c).Title=contloadMap.get(con).Title__c;
                 
                            contListcnvrt.add(contactEmailMap.get(contloadMap.get(con).email__c));
                            emailExtIdMap.put(contloadMap.get(con).Email__c,contloadMap.get(con).External_Id__c);
                        }   else{
                                ResultMap.put(contloadMap.get(con).External_Id__c,'Conversion Error' + '@@@' +'false' + '@@@' + contactEmailMap.get(contloadMap.get(con).email__c).Id +'@@@'+ 'Contact with the Email exists with an External Id');
                        }                                                                 
                } else{
                    //insert
                    contListInst=contactLoaderUtility.insertContact(contloadMap,accountMap);                       
                }
            }
        }

        //Insert Contacts
        if(!contListInst.isEmpty()){  
             Integer ins=0;
            Database.SaveResult[] srList = Database.insert(contListInst, false);
            for(Contact conInt: contListInst)
            {   
                ResultMap.put(contListInst[ins].External_ID__c,'Inserted' + '@@@' +srList[ins].isSuccess() + '@@@' +  srList[ins].getId() +'@@@'+ srList[ins].getErrors());
                ins++;
            }
        }
        
        //Update Contacts
        if(!contListUpd.isEmpty()){  
             Integer updte=0;
            Database.SaveResult[] updateList = Database.update(contListUpd, false);
            for(Contact conUp: contListUpd )
            {   
                ResultMap.put(contListUpd[updte].External_Id__c,'Updated' + '@@@' +updateList[updte].isSuccess() + '@@@' + updateList[updte].getId() +'@@@'+ updateList[updte].getErrors());
                updte++;
            }
        }  
        
        //Converted Contacts
        if(!contListcnvrt.isEmpty()){  
             Integer conv=0;
            Database.SaveResult[] contListUpdvList = Database.update(contListcnvrt, false);
            for(Contact conUp: contListcnvrt )
            {   
                ResultMap.put(emailExtIdMap.get(contListcnvrt[conv].Email),'Converted' + '@@@' +contListUpdvList[conv].isSuccess() + '@@@' + contListUpdvList[conv].getId() +'@@@'+ contListUpdvList[conv].getErrors());
                conv++;
            }
        }          
        contactLoaderUtility.updatecontactloader(contloadMap,emailExtIdMap,ResultMap);         
     }
     
     global void finish(Database.BatchableContext BC) {
      
     }
}