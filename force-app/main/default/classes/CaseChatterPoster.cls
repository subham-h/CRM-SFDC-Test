/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      21/03/2018   meenakshi.rajasekaran@ust-global.com        #RQ-008020     RQ-008020 Notification on Closed ISR
* 2.0      14/06/2018   meenakshi.rajasekaran@ust-global.com        #RQ-008547      Case Assignment Notification
* 3.0      1/08/2018    Ranjini@ust                                 #RQ-009034      Added Dispute record type.
* 4.0      02-04-2020   Ramadevi@ust                                SC-160          Implemented Trigger recurrsion for few methods.
* 5.0      19/10/2022   Sriram@maersk                               SC-6294         ISR Resolution Summary - Shipment Number
* 6.0  	   10/01/2023	Vaishali@maersk								SC-6896			Chatter post to Parent case when cloned case is updated with Parent
*/
public class CaseChatterPoster {
    
    public static final String LOGMARK = '##### CaseChatterPoster : ';
    
     public static Boolean isFirstTime = true;
    
     private  Map<Id,id> mapFeedIdCaseRequestorId = new Map<Id,id>();
     private  Map<Id,id> mapFeedIdCaseownerId = new Map<Id,id>();
    
     Public string strPostPrefix {
         get{
             if(strPostPrefix == null){
                strPostPrefix = 'Case Number :'  ;
             }
             return strPostPrefix;
         }         
         set;
     }
    
     Public string strPostSuffix {
         get{
             if(strPostSuffix == null){
                 strPostSuffix = 'has been closed.';
             }             
             return strPostSuffix;
         }                  
         set;
     }
    
    Public string strPostMentionText{
        get{
            if(strPostMentionText == null){
                strPostMentionText = 'FYI';
            }
            return strPostMentionText;
        }
        set;
    } 
    
    Public string strownerchangesuffix {
         get{
             if(strownerchangesuffix == null){
                 strownerchangesuffix = 'This case is now assigned to you.';
             }             
             return strownerchangesuffix;
         }                  
         set;
     }
    
     Public string strcasePrefix {
         get{
             if(strcasePrefix == null){
                 strcasePrefix = 'CASE';
             }             
             return strcasePrefix;
         }                  
         set;
     }
    
    private Set<Id> recordTypeIdSet {
        get {
            if (recordTypeIdSet == null) {
                recordTypeIdSet = new Set<Id>();
                for (String s: Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().keySet()) {
                    if (!'Master'.equalsIgnoreCase(s)) {
                        recordTypeIdSet.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(s).getRecordTypeId());
                    }
                }
            }
            return recordTypeIdSet;
        }
        set;
    }
    
    public void postToRequestorForRT(Map<Id, Case> mapClosedCases) {
 //SC-160 : Trigger Recurrsion controller
        //if(Generic_TriggerHandler.validateRunForMethod('CaseChatterPoster.postToRequestorForRT()', 1)){
            System.debug(Logginglevel.DEBUG, LOGMARK + 'postToRequestorForRT - mapClosedCases=' + mapClosedCases);
    
            List<FeedItem> lstFeedItem = new List<FeedItem>();
            List<Id> lstCaseCreatorId = new List<Id>();
            List<String> lstCaseRes = new List<String>();
            Map<Id,String> mapCaseResolution = new Map<Id,String>();
             List<String> lstShomentNumbers = new List<String>();
             Map<Id,String> mapShipments = new Map<Id,String>();
            
            if(isFirstTime) {
                
                if(!mapClosedCases.isEmpty()) {                    
                    isFirstTime = false;               
                    for (Id cId : mapClosedCases.keyset()) {                        
                        Case c = mapClosedCases.get(cId);                        
                        List<FeedItem> lstISRFeedItem = new List<FeedItem>();                        
                        if (recordTypeIdSet.contains(c.RecordTypeId)) {
                            lstCaseCreatorId.add(c.CreatedById);
                            lstCaseRes.add(c.Resolution_Summary__c);
                            lstShomentNumbers.add(c.Shipment_Number__c);
                            FeedItem postObj = new FeedItem();
                            postObj.Body = strPostPrefix + ' ' + c.CaseNumber + ' ' + strPostSuffix;
                            postObj.ParentId = c.Id;                           
                            lstFeedItem.add(postObj);
                       }
                    }
                    
                 }
                
               
           
                Integer index = 0;
                for (Database.SaveResult sr: ChatterPostUtilities.doChatterPost(lstFeedItem, 'closedCaseChatterPostUtility')) {
                    if (sr.isSuccess()) {
                        mapFeedIdCaseRequestorId.put(sr.getId(), (Id)lstCaseCreatorId[index]); 
                        mapCaseResolution.put(sr.getId(),(String)lstCaseRes[index]);
                        mapShipments.put(sr.getId(),(String)lstShomentNumbers[index]);
                    }
                    index++;
                }               
                               
            
               if (!System.Test.isRunningTest()) {   
                     
                    ChatterPostUtilities.doChatterMentionFuture(mapFeedIdCaseRequestorId, strPostMentionText,mapCaseResolution,mapShipments);
               } 
            }
        //}

    }
        
     //#RQ-008547 Case Assignment Notification
      public void PostToNotifyCaseowner(Map<Id, Case> mapcaseownerchanges) {
        //SC-160 : Trigger Recurrsion controller
        if(Generic_TriggerHandler.validateRunForMethod('CaseChatterPoster.PostToNotifyCaseowner()', 1)){
            System.debug(Logginglevel.DEBUG, LOGMARK + 'PostToNotifyCaseowner - mapcaseownerchanges=' + mapcaseownerchanges);
    
            List<FeedItem> lstFeedItem = new List<FeedItem>();
            List<Id> lstcaseownerId = new List<Id>();
            
            if(isFirstTime) {
                
                if(!mapcaseownerchanges.isEmpty()) {
                    
                    isFirstTime = false;               
                    for (Id cId : mapcaseownerchanges.keyset()) {
                        
                        Case c = mapcaseownerchanges.get(cId);
                        
                        // if (recordTypeIdSet.contains(c.RecordTypeId)){
                            lstcaseownerId.add(c.OwnerId);
                            FeedItem postObj = new FeedItem();                        
                            postObj.Body =  strcasePrefix + ' ' + c.CaseNumber;
                            postObj.ParentId = c.Id;
                            System.debug(Logginglevel.DEBUG, LOGMARK + 'postToRequestorForRT - postObj=' + postObj);
                            lstFeedItem.add(postObj);
                       //}
                    }
                    
                 }
                
                System.debug(Logginglevel.DEBUG, LOGMARK + 'PostToNotifyCaseowner - lstcaseownerId=' + lstcaseownerId);
                System.debug(Logginglevel.DEBUG, LOGMARK + 'PostToNotifyCaseowner - lstFeedItem=' + lstFeedItem);
           
                Integer index = 0;
                for (Database.SaveResult sr: ChatterPostUtilities.doChatterPost(lstFeedItem, 'CaseOwnerChatterPostUtility')) {
                    if (sr.isSuccess()) {
                        mapFeedIdCaseownerId.put(sr.getId(), (Id)lstcaseownerId[index]);       
                    }
                    index++;
                }
                
                System.debug(Logginglevel.DEBUG, LOGMARK + 'PostToNotifyCaseowner - mapFeedIdCaseownerId=' + mapFeedIdCaseownerId);
            
               if (!System.Test.isRunningTest()) {
                    ChatterPostUtilities.doChatterMentionFuture(mapFeedIdCaseownerId, strownerchangesuffix, null,null);
               } 
            }
        }
    
    }

	@InvocableMethod(label='postChildDetailsToParentFeed ' description='Post a chatter on Parent when Parent case is updated for cloned case')
    public static void postChildDetailsToParentFeed( List < Case > listCloneCase ) {
 			//MetadataService.MetadataPort service = MetadataUtility.createService();
        futurePostChildDetailsToParentFeed( listCloneCase[0].Id,listCloneCase[0].RecordTypeId );
 
    }
    
    @future(callout=true)
    public static void futurePostChildDetailsToParentFeed(Id cloneCaseId, Id recordTypeId){
        
            String recordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            
            List<FeedItem> post = new List<FeedItem>();
            FeedItem postObj = new FeedItem(); 
            //string compactLayout;
            //Get Compact layout name using recordtype name
            List<General_Key_Value_Configurations__mdt> mdtlist = [SELECT Id,First_Field_Name__c,First_Field_Value__c,Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c LiKE 'Compact_Layout%' AND First_Field_Name__c =:recordTypeName];
            //compactLayout =  mdt.First_Field_Value__c;
        	Case cloneCase;
        	 
            
                
           
        List<String> fields = new List<String>();
        if(mdtList.size()>0){
        for(General_Key_Value_Configurations__mdt mdt:mdtlist){
    fields.add(mdt.First_Field_Value__c);
               
}
            string compFields = string.join(fields,',');
            String casequery='Select id,ParentId,'+compFields+' from Case where id=\''+cloneCaseId+'\'';
            system.debug('casequery'+casequery);
            Clonecase=Database.query(casequery);
            system.debug('fields>>'+fields);
             
            System.debug('Cloned Case=='+Clonecase);
            }
         
            //Get fields from Case object
            Map<String, Schema.SObjectField> caseFieldMap = Schema.SObjectType.Case.fields.getMap();
            //Assign required fields for the FeedItem
            System.debug('Cloned Case Number>>'+cloneCase.CaseNumber);
            System.debug('cloneCase Parent>>'+cloneCase.ParentId );
            postObj.ParentId = cloneCase.ParentId;           
            postObj.Title = Clonecase.CaseNumber;
            postObj.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Case/'+cloneCase.Id +'/view' ;
        	
            String feedItemBody=null;             
            for(String str:fields){
                if(caseFieldMap.containsKey(str)){
                    
                    //Get field Label and datatype from Map of case fields
                    Schema.SObjectField field = caseFieldMap.get(str);
                    String fieldLabel= field.getDescribe().getLabel();
                    Schema.DisplayType FldType = field.getDescribe().getType();                    
                    
                    
                    if(feedItemBody==null){
                        if(FldType == Schema.DisplayType.Reference && str=='RecordTypeId'){                            
                            fieldLabel=fieldLabel.substring(0,fieldLabel.length()-2)+'Name';
                            feedItemBody =   fieldLabel+':'+ ' ' + recordTypeName +'\n';                            
                        }      
                         
                        else{
                            feedItemBody = fieldLabel+':'+(String) cloneCase.get(str)+'\n'; 
                        }
                        
                             
                    }
                    else{
                        if(FldType == Schema.DisplayType.Reference && str=='RecordTypeId'){                            
                            fieldLabel=fieldLabel.substring(0,fieldLabel.length()-2)+'Name';
                            feedItemBody =feedItemBody + fieldLabel+':'+ ' ' + recordTypeName +'\n';                            
                        }            
                        else{
                            feedItemBody =feedItemBody + fieldLabel+':'+ ' ' + (String) cloneCase.get(str) +'\n';
                        }
                               
                         
                    }
                    
                }
            }
            //Assign the Body of the FeedItem
            postObj.Body = feedItemBody;            
            post.add(postObj);
            
           //Post the feeditem
            if(post.size() > 0){
                if (!System.Test.isRunningTest()) {
               		ChatterPostUtilities.doChatterPost(post,'CaseCloneAttachmentController');
                }
            }
    }

}