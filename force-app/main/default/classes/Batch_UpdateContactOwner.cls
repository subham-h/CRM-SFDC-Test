/*
* Purpose   : Batch class scheduled to update field 'Contact Owner' in contact object where recordtype.name='Internal Contact' and owner!='System Owner'.
*
* Revision  Ref Number    Date          Owner                   Description
* --------  ----------    -----------   -------------------     -----------
* 1.0       #RQ-011601    24-Oct-2019   Abhinav Ankit            Code created as part of #RQ-011601
* 
*/
global class Batch_UpdateContactOwner implements Database.Batchable<sObject>, Database.Stateful{
    
     global final String query;
     global Batch_UpdateContactOwner(String q) {
        if(q != null){
            query=q;
        }
        else {
				query = 'select id,ownerId,owner.name from contact where recordtype.name=\'Internal Contact\' and owner.name !=\'System Owner\' ';    
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext BC, List<Contact> scopeContactList){
        List<Contact> lstContatUpdate = new List<Contact>();
        IF(scopeContactList.size()>0){
			for(Contact con : scopeContactList){
				if(con.owner.name!=null){
					con.ownerId = '005D00000041R4YIAU';
				}
		lstContatUpdate.add(con);
		}
		if(lstContatUpdate.size()>0){
			update lstContatUpdate;
		}
        
       }
    }
	global void finish(Database.BatchableContext BC) {
        // Do Nothing Here
    }
}