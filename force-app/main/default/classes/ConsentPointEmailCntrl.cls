/* Revision Ref Number  Date        Owner					Description
* -------- ----------  ----------- -----------------		-----------
* 1.0      	SFMC-7438	29-Nov-2023		amrutha@maersk		Code created
*/
public class ConsentPointEmailCntrl {
    @AuraEnabled(cacheable=true)
    public static List<ContactPointEmail> getConsent1 (Id recordId){ 
        List <ContactPointEmail> lstConsentPointEmail;
                
        String ObjName = recordId.getSObjectType().getDescribe().getName();  
        set<id> setOfPartyId = new set<id>();
        if(ObjName == 'Lead'){
            for(Lead ld : [select id ,name,IndividualId from lead where Id =:recordId]){
                setOfPartyId.add(ld.IndividualId);               
                }
        }
        else if(ObjName == 'Contact'){
            for(Contact cnt : [select id, name,IndividualId from Contact where Id =:recordId])
                setOfPartyId.add(cnt.IndividualId);
        }    
       if(setOfPartyId !=null && setOfPartyId.size() > 0) {
            lstConsentPointEmail = [Select id,EmailAddress,ParentId from ContactPointEmail Where parentId In:setOfPartyId and EmailAddress In :setOfPartyId];
        }
        return lstConsentPointEmail; 
        
    }  
}