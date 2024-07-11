public class contactLoaderUtility {
    public static List<Contact> insertContact(Map<string,Contact_Loader__c> contldMap, Map<string,Account> accMap){
        List<Contact> insertContactList = new List<Contact>();
        List<string> linerbrandlst = new List<string>();
        if(!contldMap.isEmpty()){ 
            for(string conld:contldMap.keyset()){
                 contact cont = new contact();
                 cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
                 cont.Unique_Email_Address__c=contldMap.get(conld).Email__c;
                 //cont.AccountId=contldMap.get(conld).Account__r.id;
                 if(contldMap.get(conld).customer_code__c!=null && accMap.containsKey(contldMap.get(conld).customer_code__c)){                        
                     cont.AccountId=accMap.get(contldMap.get(conld).customer_code__c).Id;                    
                 }
                 if(contldMap.get(conld).Liner_Brands__c!=null){
                    linerbrandlst=contldMap.get(conld).Liner_Brands__c.split(';');
                    for(string val:linerbrandlst){
                        if(cont.Liner_Brands__c!=null && !(cont.Liner_Brands__c.contains(val))){
                            cont.Liner_Brands__c += ';' + val;
                        }else{
                            cont.Liner_Brands__c= val;
                        }
                    }
                    //conEmailMap.get(contldMap.get(con).email__c).Liner_Brands__c=contldMap.get(con).Liner_Brands__c;                            
                 }
                 //cont.Liner_Brands__c=contldMap.get(conld).Liner_Brands__c;
                 cont.Contact_Status__c = contldMap.get(conld).Contact_Status__c;     
                 if(cont.Contact_Type__c!=null && (!(cont.contact_type__c).contains('Finance'))){
                     cont.Contact_Type__c=cont.Contact_Type__c+ ';' + 'Finance';
                 }else{
                     cont.Contact_Type__c='Finance';                 
                 }            
                 cont.Department=contldMap.get(conld).Department__c;
                 cont.Email=contldMap.get(conld).Email__c;
                 cont.Extension_Number__c=contldMap.get(conld).Extension_Number__c;
                 cont.External_ID__c=contldMap.get(conld).External_ID__c;
                 if(contldMap.get(conld).fax_dialing_code__c!=null){
                     cont.Fax='+' +contldMap.get(conld).fax_dialing_code__c + ' ' + contldMap.get(conld).fax_number__c;
                 }
                 cont.FirstName=contldMap.get(conld).First_Name__c;
                 cont.Job_Role__c=contldMap.get(conld).Job_Role__c;
                 cont.LastName=contldMap.get(conld).Last_Name__c;
                     if(contldMap.get(conld).mobile_dialing_code__c!=null){
                     cont.MobilePhone='+' +contldMap.get(conld).mobile_dialing_code__c + ' ' + contldMap.get(conld).mobile_number__c;
                 }
                 cont.Duplicate_Email__c=contldMap.get(conld).Duplicate_Email__c;
                 if(contldMap.get(conld).telephone_dialing_code__c!=null){
                     cont.Phone='+' +contldMap.get(conld).telephone_dialing_code__c + ' ' + contldMap.get(conld).telephone_number__c;
                 }
                 cont.Preferred_Language__c=PreferedLanguageMapCtrl.mapOfisoLanguageCode.get(contldMap.get(conld).Preferred_Language__c);
                 cont.Salutation=contldMap.get(conld).Salutation__c;
                 cont.Title=contldMap.get(conld).Title__c;
                 insertContactList.add(cont);
            }
        }
        return insertContactList;

    }
    
    public static void updatecontactloader(Map<string,Contact_Loader__c> contldMap,Map<string,string> emailextmap,map<string,string> ResultMap){
        List<contact_loader__c> contactldlst= new List<contact_loader__c>();
        for(String extid:ResultMap.keySet()){
            string[] splitleftField = new string[]{};
            splitleftField = ResultMap.get(extid).split('@@@');
            if(splitleftField[0] =='Inserted' && splitleftField[1] =='true'){
                contldMap.get(extid).Dataload_Status__c='Inserted';            
            }else if(splitleftField[0] =='Updated' && splitleftField[1] =='true'){
                contldMap.get(extid).Dataload_Status__c='Updated';                        
            }else if(splitleftField[0] =='Converted' && splitleftField[1] =='true'){
                contldMap.get(extid).Dataload_Status__c='Converted';                                    
            }else if(splitleftField[0] =='Conversion Error' && splitleftField[1] =='false'){
                contldMap.get(extid).Dataload_Status__c='Conversion Error';                                    
            }else if(splitleftField[1] =='false'){
                contldMap.get(extid).Dataload_Status__c='Failed';
            }
            contldMap.get(extid).Result__c='Record Id: '+splitleftField[2] + ' Reason: ' +splitleftField[3];
            contactldlst.add(contldMap.get(extid));
        }
        update contactldlst;  
    }
}