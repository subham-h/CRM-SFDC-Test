/* Revision Ref Number  Date        Owner					Description
* -------- ----------  ----------- -----------------		-----------
* 1.0      	SFSE-5197	26-Sep-2022		Shilpa@maersk		Code created
*/
public class consentPointCntrl {
    @AuraEnabled(cacheable=true)
    public static List<ContactPointTypeConsent> getConsent (Id recordId){ 
        List <ContactPointTypeConsent> lstConsentPointType;
                
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
            lstConsentPointType = [Select id,name,BusinessBrand.Name,ContactPointType,PrivacyConsentStatus from ContactPointTypeConsent Where partyId In:setOfPartyId];
        }
        return lstConsentPointType;  
        
    }  
    
   
}