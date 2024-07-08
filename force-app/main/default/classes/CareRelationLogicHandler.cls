public without sharing class CareRelationLogicHandler {
    public static String setCareRelationship(Case newCase, list<Care_Relationship__c> lstCareRelationship) {
        String careId=null;
        List<Care_Relationship__c> oneDirectionalCare=new List<Care_Relationship__c>();
        List<Care_Relationship__c> biDirectionalCare=new List<Care_Relationship__c>();
        for(Care_Relationship__c care : lstCareRelationship) 
        {           
            if(care.Direction__c == Label.DirectionBoth && 
                (newCase.Country__c == care.Country__c) && 
                (newCase.Liner_Brand__c == care.Liner_Brand__c))
            {
                biDirectionalCare.add(care);
            }else if((newCase.Country__c == care.Country__c) && 
                    (newCase.Liner_Brand__c == care.Liner_Brand__c))
            {
                oneDirectionalCare.add(care);
            }
        }
        careId = getMatchingCare(oneDirectionalCare,newCase,true);
        if(careId!=null){return careId;}
        careId = getMatchingCare(biDirectionalCare,newCase,true);
        if(careId!=null){return careId;}
        careId = getMatchingCare(oneDirectionalCare,newCase,false);
        if(careId!=null){return careId;}
        careId = getMatchingCare(biDirectionalCare,newCase,false);
        if(careId!=null){return careId;}
        return null;
    }
    private static String getMatchingCare(List<Care_Relationship__c> careList,
                                            Case newCase,
                                            Boolean isCityCheckValid){
        String careId=null;
        for(Care_Relationship__c care : careList) 
        {
            if(!isCityCheckValid &&
                (care.Direction__c == newCase.Direction__c||care.Direction__c == Label.DirectionBoth)&&
                (newCase.Cluster__c != null) && 
                (newCase.Cluster__c == care.Cluster__c))
            {
                careId = care.Id;
                return careId;
            }else if( isCityCheckValid &&
                      (care.Direction__c == newCase.Direction__c ||care.Direction__c == Label.DirectionBoth) && 
                      (newCase.City__c != null) && 
                      (newCase.City__c == care.Location__c)) 
            {
                careId = care.Id;
                return careId;
            }
        }  
        return null;
    }
}