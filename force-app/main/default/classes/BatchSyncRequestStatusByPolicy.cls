/*
*
* Batch job to sync the status of Request as per the Request's Pricing Management based policy settings.
* 
* Version  Date             Owner                                RQ#           Description
***********************************************************************************************************************************************
* 1.0    11/03/2018       meghana.gupta@ust-global.com        RQ-008054     Batch job to sync the status of Request based on pricing management based policy settings
*
*/
global class BatchSyncRequestStatusByPolicy implements Database.Batchable<SObject> {
    
    global Database.queryLocator start( Database.BatchableContext ctx ) {
        
        Id rateSheetRecTypeId =  (Id) Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();
        String strStatus = '\'Active\', \'' + System.Label.Request_Status_Active + '\', \'' + System.Label.Request_Status_Inactive + '\'';  
        
        //Query to fetch the requests to be processed.
        
        String strQuery = 'SELECT Id, BCO_FWD__c, Status__c, Commodity_Rate_Sheet__c, Pricing_Management__c, Pricing_Management__r.Product__c, ';
        strQuery += ' Route_Direction_Code__c, Equipment_Types__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Equipment_Types_BCO__c, ';
        strQuery += ' Pricing_Management__r.Equipment_Types_FWD__c, Pricing_Management__r.Active_BCO__c , Pricing_Management__r.Active_FWD__c  ';
        strQuery += ' FROM Request__c '; 
        strQuery += ' WHERE  RecordTypeId = \'' + rateSheetRecTypeId + '\' AND Pricing_Management__r.Pricing_Change__c = true AND Status__c IN (' + strStatus + ')' ;
         
        System.debug(' $$$ strQuery : ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute( Database.BatchableContext BC, List<sObject> scope ) {
        
        List<Request__c> lstRequest = ( List<Request__c> ) scope;
        System.debug('$$$ lstRequest: ' + lstRequest);
        
        List<Request__c> lstRequestsToUpdate = new List<Request__c>();        
        List<ContentDocumentLink> lstContentDocLinks = new List<ContentDocumentLink>();
        List<ContentNote> lstContentNote = new List<ContentNote>();
        
        Map<Id, String> mapReqIdToNotes = new Map<Id, String>();
        
        for ( Request__c req : lstRequest){
            
            System.debug('$$$ request: ' + req);
            Boolean blnModifyRequest = false;
            String strNewEquip = req.Equipment_Types__c; // initailly default to existing values, can change in If condition as needed
            String strNewStatus = req.Status__c;
            
            String strOldEquip = req.Equipment_Types__c; 
            String strOldStatus = req.Status__c;
            
            // Logic to check whether an active request should be changed to inactive or inactive request should be changed to active as per product policy
            
            if ( (req.BCO_FWD__c == System.Label.BCO && req.Pricing_Management__r.Active_BCO__c == false) || ( req.BCO_FWD__c == System.Label.FWD && req.Pricing_Management__r.Active_FWD__c == false) ){
                
                if(req.Status__c != System.Label.Request_Status_Inactive){
                    strNewStatus = System.Label.Request_Status_Inactive;
                    blnModifyRequest = true;
                }
                
            } else { 
                
                if ( ((req.BCO_FWD__c == System.Label.BCO && req.Pricing_Management__r.Active_BCO__c == true) || ( req.BCO_FWD__c == System.Label.FWD && req.Pricing_Management__r.Active_FWD__c == true)) && req.Status__c == System.Label.Request_Status_Inactive){
                    
                    if (req.Commodity_Rate_Sheet__c == 'FAK'){
                        strNewStatus = System.Label.Request_Status_Active;
                        blnModifyRequest = true;
                    }
                }
                
                // To sync the request equipment type with the pricing mgmt equipment
                if ((req.BCO_FWD__c == System.Label.BCO && req.Pricing_Management__r.Equipment_Types_BCO__c != null) || (req.BCO_FWD__c == System.Label.FWD && req.Pricing_Management__r.Equipment_Types_FWD__c != null)) {
                    
                    Set<String> setPMgmtEquipTypes = new Set<String>();
                    Set<String> setReqEquipTypes = new Set<String>();
                    
                    if (req.Equipment_Types__c != null)
                      setReqEquipTypes.addAll(req.Equipment_Types__c.split(';'));
                    
                     String strNewReqEquipType = '';
                    // based on BCO/FWD fetch corresponding Equipment types
                    if( req.BCO_FWD__c == System.Label.BCO){
                        
                        setPMgmtEquipTypes.addAll(req.Pricing_Management__r.Equipment_Types_BCO__c.split(';'));
                        strNewReqEquipType = req.Pricing_Management__r.Equipment_Types_BCO__c;
                        
                    } else if( req.BCO_FWD__c == System.Label.FWD ){
                        
                        setPMgmtEquipTypes.addAll(req.Pricing_Management__r.Equipment_Types_FWD__c.split(';'));
                        strNewReqEquipType = req.Pricing_Management__r.Equipment_Types_FWD__c;
                    }     
                                                           
                    if (req.Commodity_Rate_Sheet__c != 'FAK'){
                        strNewEquip = strNewReqEquipType;
                        
                        if (req.Equipment_Types__c != strNewReqEquipType){
                            req.Equipment_Types__c = strNewReqEquipType;
                            blnModifyRequest = true;
                        }
                        
                    } else {
                        
                        strNewReqEquipType = '';
                        for( String strPricingEquipType: setPMgmtEquipTypes ){
                            
                            // If Pricing Managment's Equipment Type is present in Request's Equipment Type then maintain it a string
                            if(setReqEquipTypes.contains(strPricingEquipType)){
                                
                                strNewReqEquipType += strPricingEquipType + ';' ;
                            }
                        }
                        if( strNewReqEquipType == '' ) { 
                            // No request equipment matches with pricing mgmt's equipments
                            
                            strNewEquip = 'null';
                            strNewStatus = System.Label.Request_Status_Inactive;
                            blnModifyRequest = true;
                            
                        } else { 
                            
                            // Some of the request equipments matches with pricing mgmt's equipments. 
                            // Then make the request equipments to be in sync with pricing mgmt's equipments
                            Set<String> setNewRequestEquipments = new Set<String>();
                            setNewRequestEquipments.addAll(strNewReqEquipType.split(';'));
                            
                            if( ! setNewRequestEquipments.equals(setReqEquipTypes) ){ 
                                
                                // if any of Request's equipment type is not valid as per policy, remove it from Request.
                                strNewEquip = strNewReqEquipType;
                                req.Equipment_Types__c = strNewReqEquipType;
                                blnModifyRequest = true;
                                
                                if( req.Status__c == System.Label.Request_Status_Inactive && req.Commodity_Rate_Sheet__c == 'FAK'){ 
                                    
                                    // if the request is already inactive, then make it active
                                    strNewStatus = System.Label.Request_Status_Active;
                                } 
                            } else if( setNewRequestEquipments.equals(setReqEquipTypes) && req.Status__c == System.Label.Request_Status_Inactive && req.Commodity_Rate_Sheet__c == 'FAK'){
                                // no change in Request's Equipment Type
                                
                                blnModifyRequest = true;
                                strNewStatus = System.Label.Request_Status_Active;
                            }
                        }
                    }
                } else { 
                    
                    // To inactivate the request if there is no macth between request equipments and pricing management equipments 
                    strNewEquip = 'null';
                    blnModifyRequest = true;
                    strNewStatus = System.Label.Request_Status_Inactive;                    
                }
            }
            
            System.debug('$$$ blnModifyRequest: '+ blnModifyRequest);
            if ( blnModifyRequest ){
                
                // change Request Status as per above conditions 
                req.Status__c = strNewStatus;
                req.Policy_Change_Batch_Update_Date__c = System.today();
                lstRequestsToUpdate.add(req);
                
                // Message for Note record to be created for this request status change
                String noteMsg = System.Label.Policy_Change + System.Label.Previous_Equipment_Types + strOldEquip + System.Label.New_Equipment + strNewEquip;
                noteMsg = noteMsg + System.Label.Previous_Request_Status + strOldStatus + System.Label.New_Request_Status + strNewStatus;
                mapReqIdToNotes.put(req.Id, noteMsg);
            }
        }
        
        
        if( lstRequestsToUpdate.size() > 0 ){   
                       
            List<ContentDocumentLink> lstInsertContentLink = new List<ContentDocumentLink>();
            List<ContentNote> lstInsertNotes = new List<ContentNote>();
            
            List<Database.SaveResult> lstSaveResult = Database.Update(lstRequestsToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Request__c', 'BatchSyncRequestStatusByPolicy', lstSaveResult, lstRequestsToUpdate);
          System.debug('$$$ lstSaveResult: ' + lstSaveResult);
            
            // Creation of notes based on the request route updates
            for( Integer i = 0; i < lstSaveResult.size(); i++) {
                
                Database.SaveResult sr = lstSaveResult[i];
                if( sr.isSuccess() ){
                    
                    ContentNote cnObj = new ContentNote();
                    cnObj.Title = System.Label.Request_Note_Name;
                    cnObj.content = Blob.valueOf( mapReqIdToNotes.get(sr.getId()).escapeHTML4());
                    lstInsertNotes.add(cnObj);
                    
                    ContentDocumentLink cdlObj = new ContentDocumentLink();                  
                    cdlObj.LinkedEntityId = String.valueOf(sr.getId());
                    cdlObj.ShareType = 'V';
                    cdlObj.Visibility = 'AllUsers';
                    lstInsertContentLink.add(cdlObj);
                }               
            }
            
            // insert note records
            List<Database.SaveResult> lstNotesSaveResult = Database.Insert(lstInsertNotes, false);
            
            // insert link between notes created and corresponding request
            for( Integer i = 0; i < lstInsertNotes.size(); i++ ){
                
                lstInsertContentLink[i].ContentDocumentId = lstInsertNotes[i].id;
            }
            
            List<Database.SaveResult> lstContentLinkSaveResult = Database.Insert(lstInsertContentLink, false);
            
            ErrorLogger.writeErrors('SFDC', 'ContentDocumentLink', 'BatchSyncRequestStatusByPolicy', lstContentLinkSaveResult, lstInsertContentLink);
            ErrorLogger.writeErrors('SFDC', 'ContentNote', 'BatchSyncRequestStatusByPolicy', lstNotesSaveResult, lstInsertNotes);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        // For making the Pricing Management -> Pricing Change to false after execution of this batch
        List<Pricing_Management__c> lstPricingMgmt = [ SELECT Id,  Pricing_Change__c FROM Pricing_Management__c WHERE Pricing_Change__c = true ];
        
        for( Pricing_Management__c pmRec: lstPricingMgmt ){
            pmRec.Pricing_Change__c = false;
        }                                               
        List<Database.SaveResult> lstPMgmtSaveResult = Database.update( lstPricingMgmt, false );
        ErrorLogger.writeErrors('SFDC', 'Pricing_Management__c', 'BatchSyncRequestStatusByPolicy', lstPMgmtSaveResult, lstPricingMgmt);

    }
    
}