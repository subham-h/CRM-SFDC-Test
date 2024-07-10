/**
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      SC-7083     18-03-2023  ramadevi.p@maersk.com     Auramethods called from Custom NBA Component to return Case Recommendations
 * 2.0      SC-7804     19-04-2023  ramadevi.p@maersk.com     Removed the condition Only Case Owner should view Recommendations
 * 3.0      SC-8488    13-07-2023  vivek.agrawal@maersk.com  adding recordtype while inserting NBA recommendations
 * 4.0      SC-9056     19-10-2023  raksha.n@maersk.com       Adding View Details button logic on the NBA recommendation
*/
public class CustomNBARecommendation {    
    @AuraEnabled
    public static NBAWrapper getRecommendations(String recId,String ObjName){
        NBAWrapper returnNBAWarapper;
        if(ObjName == 'Case'){
            returnNBAWarapper = CustomNBARecommendation.getCaseRecommendations(recId,ObjName);
        }
        return returnNBAWarapper;
    }
    
    public static NBAWrapper getCaseRecommendations(String recId,String ObjName){
        List<Case_Recommendation__c> returnRecomList =  new List<Case_Recommendation__c>();
        Case cseDetail = [SELECT Id,Subject,CaseNumber,ContactId,SuppliedEmail,Contact.Email,Contact.Recordtype.DeveloperName,Case_Channel__c,Status,Product__c,type,Reason_For_Case__c,recordtypeId, RecordType.DeveloperName,Sub_Type__c,Case_Country__c,Liner_Brand__c,isRecommendationAvaialble__c,OwnerId from Case where Id=:Id.valueof(recId)]; 
         //SC-8488
        String nbaRecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NBA Recommendation').getRecordTypeId();
        Map<String, NBA_Settings__mdt> NBAmdt = NBA_Settings__mdt.getAll();
        
        NBAWrapper nbaWrpr = new NBAWrapper();
        if(cseDetail <> null && cseDetail.Product__c == 'Ocean' && cseDetail.Contact.Recordtype.DeveloperName != 'Internal_Contact'){
            Map<String,Boolean> visibility = CustomNBARecommendation.NBAVisibility(new List<Case>{cseDetail});
            system.debug('cseDetail ##'+cseDetail);
            system.debug('visibility##'+visibility);
            List<String> recomId = new List<String>();
            try{
              if(visibility.get('InternalContact') && cseDetail.recordtypeId == StaticFactory.getRecordTypeIdByName('Case',Label.External_Case) && cseDetail.Case_Channel__c=='E-mail'  && !(cseDetail.status.startswith('Closed'))&& ((cseDetail.Sub_Type__c<> 'Delivery Order/Container Release')||(( cseDetail.Sub_Type__c == 'Delivery Order/Container Release' && visibility.get('DORecommendation'))))){
                  // Condition for Container Maritime Tracking Request
                  //((cseDetail.Reason_For_Case__c <> 'Container Maritime Tracking Request' && cseDetail.Sub_Type__c<> 'Delivery Order/Container Release')||(cseDetail.Reason_For_Case__c == 'Container Maritime Tracking Request'  && visibility.get('TransportRecommendation')) || ( cseDetail.Sub_Type__c == 'Delivery Order/Container Release' && visibility.get('DORecommendation')))
                    if(cseDetail.isRecommendationAvaialble__c) {
                        //SC-8488 adding recordtypeid to filter only for NBA recommendation records.
                        returnRecomList = [SELECT Id,Action_Status__c,View_Details_Status__c,Case__c,Description__c,Priority__c,Recommendation_Id__c,Recommendation_Name__c,Rejected_Reason__c from Case_Recommendation__c where recordtypeId =:nbaRecommRecTypeId and (Action_Status__c =null OR (View_Details_Status__c =null AND Show_View_Details_button__c=true )) and case__c=:cseDetail.Id order by Priority__c ASC] ;
                    for(Case_Recommendation__c cseRecomObj:returnRecomList){
                        recomId.add(cseRecomObj.Recommendation_Id__c);
                    }
                    nbaWrpr.returnRecomList =  JSON.serialize(returnRecomList);
                    nbaWrpr.nbaActionMap = CustomNBARecommendation.getNBAActionMapping(recomId);
                }else{
                    String requestBody = Recommendations.constructRequestBodyForNBA(new List<Case>{cseDetail},NBAmdt.get(ObjName));
                    String  responseBody = Recommendations.getRecommendations(requestBody,cseDetail.Id,NBAmdt.get(ObjName).Service_Name__c,NBAmdt.get(ObjName).Service_Module_Name__c);
                        system.debug('responseBody##'+responseBody);
                    List<Case_Recommendation__c> cseRecomList = new List<Case_Recommendation__c>();
                    List<String> rIdList = new List<String>();
                    List<Case_Recommendation__c> caseRecList = new List<Case_Recommendation__c>();
                    List<Case_Recommendation__c> caseRecLstToUpdt  = new List<Case_Recommendation__c>();
                    List<Case_Recommendation__c> caseRecLstToInsrt  = new List<Case_Recommendation__c>();
                        if(!String.isBlank(responseBody)){
                    List<Object> recomList= (List<Object>) JSON.deserializeUntyped(responseBody);
                    for (Object obj : recomList) {
                        Map<String, Object> recom= (Map<String, Object>)obj;
                        Case_Recommendation__c caseRec = new Case_Recommendation__c();
                        caseRec.Recommendation_Name__c =  (String)recom.get('Name');
                        caseRec.Recommendation_Id__c =  (String)recom.get('RID');
                        //String.valueof((Integer)recom.get('RID'))
                        caseRec.Description__c =  (String)recom.get('Description');
                        caseRec.Priority__c =  (Integer)recom.get('Priority');
                        caseRec.Case__c = Id.Valueof(cseDetail.Id);
                        caseRec.recordTypeId = nbaRecommRecTypeId;//SC-8488
                                system.debug('caseRec ---'+caseRec);
                        rIdList.add((String)recom.get('RID'));
                        caseRecList.add(caseRec);
                    }
                            system.debug('caseRecList###---'+caseRecList);
                            List<Case_Recommendation__c> existngCaseRecomndtn = [select id,Recommendation_Name__c,Recommendation_Id__c,Description__c,Priority__c,Case__c,Action_Status__c,View_Details_Status__c,Rejected_Reason__c from  Case_Recommendation__c where case__c=:Id.Valueof(cseDetail.Id) and Recommendation_Id__c != null AND Recommendation_Id__c in:rIdList];
                    Set<String> extrnlAndCaseIdsUnq = new Set<String>();
                    Map<String,Id> recIdMap = new Map<String,Id>();
                    for(Case_Recommendation__c cseRecExst : existngCaseRecomndtn){
                        extrnlAndCaseIdsUnq.add(cseRecExst.Recommendation_Id__c+'#'+cseRecExst.case__c);
                        recIdMap.put(cseRecExst.Recommendation_Id__c+'#'+cseRecExst.case__c,cseRecExst.Id);
                    }
                    for(Case_Recommendation__c  cseRecRes: caseRecList){
                        if(extrnlAndCaseIdsUnq.contains(cseRecRes.Recommendation_Id__c+'#'+cseRecRes.case__c)){
                            cseRecRes.Id = recIdMap.get(cseRecRes.Recommendation_Id__c+'#'+cseRecRes.case__c);
                            cseRecRes.Is_Valid__c = false;
                            caseRecLstToUpdt.add(cseRecRes);
                        }else{
                            caseRecLstToInsrt.add(cseRecRes);
                        }
                    }
                    Case caseToUpdate = new Case();
                    caseToUpdate.Id = cseDetail.Id;
                            system.debug('Update isRecommendationAvaialble__c');
                    caseToUpdate.isRecommendationAvaialble__c = true;
                    TriggerExecutionController.skipCaseTrigger(true);                            
                    update caseToUpdate;
                    TriggerExecutionController.skipCaseTrigger(false); 
                    
                    if(!caseRecList.IsEmpty()){
                                system.debug('Before Update records ##'); 
                        if(caseRecLstToUpdt.size() > 0){
                            Database.update(caseRecLstToUpdt);                          
                        }
                        if(caseRecLstToInsrt.size() > 0){
                            Database.insert(caseRecLstToInsrt);
                        }
                        //upsert caseRecList Recommendation_Id__c; 
                                cseRecomList = [SELECT Id,Recommendation_Name__c,Recommendation_Id__c,Description__c,Priority__c,Case__c,Action_Status__c,View_Details_Status__c,Show_View_Details_button__c,Rejected_Reason__c from Case_Recommendation__c where Recommendation_Id__c != null AND Recommendation_Id__c in: rIdList and case__C=:Id.Valueof(cseDetail.Id)];
                                system.debug('after update cr'+cseRecomList ); 
                    }
                    
                    //List<Case_Recommendation__c> cseRecomList = Recommendations.constructRequestBodyForNBA(new List<Case>{cseDetail});
                            system.debug('cseRecomList ##'+cseRecomList);
                    List<Decimal> prList = new List<Decimal>();
                    
                    Map<Decimal,Case_Recommendation__c> prCaserecom = new Map<Decimal,Case_Recommendation__c>();
                    Map<String,NBA_Action_Map__c> nbaActionMap = new Map<String,NBA_Action_Map__c>();
                    if(cseRecomList <> null && cseRecomList.size()>0) { 
                        for(Case_Recommendation__c cseRecom:cseRecomList){
                            if(cseRecom.Action_Status__c == null|| (cseRecom.View_Details_Status__c == null && cseRecom.Show_View_Details_button__c==true)){
                                prCaserecom.put(cseRecom.Priority__c,cseRecom);
                                prList.add(cseRecom.Priority__c);
                                recomId.add(cseRecom.Recommendation_Id__c);
                            }
                        }
                        prList.sort();
                        
                        for(Decimal i : prList){
                            returnRecomList.add(prCaserecom.get(i));
                            //break;
                        }
                        
                        nbaWrpr.returnRecomList = JSON.serialize(returnRecomList);
                        nbaWrpr.nbaActionMap = CustomNBARecommendation.getNBAActionMapping(recomId);
                        system.debug('@@nbaWrpr'+nbaWrpr);   
                    }
                }
            }  
                }  
            }catch(Exception e){
                if(!String.isBlank(e.getMessage()) && !e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'CustomNBARecommendation.getRecommendations', new list<Exception>{e});
            }
            }
            return nbaWrpr;
        }
        
        return nbaWrpr;
    }
        
    public static Map<String,Boolean> NBAVisibility(List<Case>  inputcase){
        Map<String,Boolean> returnVal = new Map<String,Boolean>();
        Integer noOfCases = Integer.valueOf(System.label.Case_NBA_Transport_Cases_Count);
        Integer noOfDays = Integer.valueOf(System.label.Case_NBA_Transport_Days);
        Boolean showTransportSubRecommendation = false;
        Boolean showDORecommendation = true;
        Set<String> setCountries = new Set<String>();
        Set<String> setBrands = new Set<String>();
        List<String> excludedEmailDomains = Label.ExcludedEmailDomains_for_NBA.toLowercase().Split(',');
        try{   
            if(inputcase != null && !inputcase.isEmpty()){
                returnVal.put('InternalContact',false);
                returnVal.put('TransportRecommendation',false);
                returnVal.put('DORecommendation',true);
                
                if((!String.isBlank(inputcase[0].Liner_Brand__c) && !BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(inputcase[0].Liner_Brand__c)) && ((inputcase[0].Contact <> NULL && !String.isBlank(inputcase[0].Contact.Email) && !excludedEmailDomains.contains(inputcase[0].Contact.Email.split('@')[1])) || (inputcase[0].Contact == NULL && !String.isBlank(inputcase[0].SuppliedEmail)  && !excludedEmailDomains.contains(inputcase[0].SuppliedEmail.split('@')[1])))){
                    returnVal.remove('InternalContact');
                    returnVal.put('InternalContact',true);
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
                            returnVal.remove('DORecommendation');
                            returnVal.put('DORecommendation',showDORecommendation);
                        }     
                    } 
                    
                }
                return returnVal;
            }
        }catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CustomNBARecommendation.NBAVisibility', new list<Exception>{e}); 
        }
        return returnVal;
    }
    
    public class NBAWrapper{
        @auraEnabled
        public Map<String,NBA_Action_Map__c> nbaActionMap{get;set;}
        @auraEnabled
        public String returnRecomList{get;set;}
        
        public NBAWrapper(){
            nbaActionMap = new Map<String,NBA_Action_Map__c>();
            //returnRecomList = new String();
        }
    }
    public static Map<String,NBA_Action_Map__c> getNBAActionMapping(List<String> recomIds){
        try{
            Map<String,NBA_Action_Map__c> nbaActionMap = new Map<String,NBA_Action_Map__c>();
            if(recomIds != null && recomIds.size() > 0){
                List<NBA_Action_Map__c> actionMap = [SELECT Id,Recommendation_Id__c,Flow_Name__c,Url__c,Redirect_Url_Values__c from NBA_Action_Map__c where Recommendation_Id__c in:recomIds];
                for(NBA_Action_Map__c nbaActObj : actionMap){
                    nbaActionMap.put(nbaActObj.Recommendation_Id__c, nbaActObj);
                }   
            }
            return nbaActionMap;
        }catch(Exception e){
           ErrorLogger.writeErrors( 'SFDC', 'Case', 'CustomNBARecommendation.getNBAActionMapping', new list<Exception>{e}); 
           return NULL;
        }
    }
}