/*
Description  : Contoller class for Rate Sheet2 Request Route Edit lightning page
/
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          19/02/2018        john.christopher@ust-global.com           #RQ-007724-Rate Sheet3
* V1.1          26/02/2018        meghana.gupta@ust-global.com              #RQ-007834- added methods for override
* v1.2          05/04/2018        Nitin More                                #RQ-008300 and RQ-008306 - updated requested by cluster code  
* v1.3          16/Jul/2018       manjunath.c.holekade@maersk.com           #RQ-008482 - Mod-01 - Included new param, 'deviationVal'
                                                                                         Mod-02 - Added 2 fields in the SOQL to fetch the appropriate Pricing Management record(which includes a fix to an existing issue related to deactivated PM records)
                                                                                         Mod-03 - Included Deviation__c field as part of the SOQL
                                                                                         Mod-04 - Include Deviation__c value to the commodity value
* v1.4          20/Jul/2018       sidhartha.mohapatra@maersk.com            #RQ-008918 - 1. Added Rate_Sheet_Additions__c in SOQL.
                                                                                         2. Added lstRateSheetAddition in RequestViewEditResponse and assign to fetch details for Custom Metadata.

* v1.5          20/Jun/2019       meghana.gupta@ust-global.com              #RQ-011086 - Status is made editable for sales at FLS level, so need to check for permission sets to decide if field should be editable on lightning component
* v2.0      05/Nov/2019   manjunath.c.holekade@maersk.com       #RQ-012369 Removed references of B1S__c and First_Output_Date__c fields
*/ 

public without sharing class RequestViewEditController {
    
    public RequestViewEditController(ApexPages.StandardController ctrl ){}    
    public class ReqException extends Exception {}    
    
    // method call from RequestNewOverride page (when New Request is clicked) to check record type and redirect to standard SFDC or custom page accordingly
    public pagereference redirectNew(){
        
        system.debug('$$$ params: ' + ApexPages.currentPage().getParameters());
        
        for (String p : ApexPages.currentPage().getParameters().keyset()){
            
            system.debug(ApexPages.currentPage().getParameters().get(p));
        } 
        String recTypeId = (ID) ApexPages.currentPage().getParameters().get('RecordType') ;
        
        // get account id and name in case New Request is clicked from 'Request' related list on Account page layout
        String strAccName =  ApexPages.currentPage().getParameters().get('CF00N5700000354UV') ;
        String strAccId =  ApexPages.currentPage().getParameters().get('CF00N5700000354UV_lkid') ;
        String strOppId = ApexPages.currentPage().getParameters().get('CF00N57000006FHFx_lkid') ;
        String strOppName = ApexPages.currentPage().getParameters().get('CF00N57000006FHFx') ;
        String retURL = ApexPages.currentPage().getParameters().get('retURL') ;
        
        system.debug('strOppId' + strOppId);
        system.debug('strAccId' + strAccId);
        system.debug('strAccName' + strAccName);
        system.debug('strOppName' + strOppName);
        system.debug('retURL' + retURL);
        
        Pagereference pgRef ; 
        Id rateSheetRecTypeId =  (ID) Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        system.debug('$$$ rateSheetRecTypeId: '+ rateSheetRecTypeId);
        
        If(recTypeId != rateSheetRecTypeId && recTypeId != null && recTypeId != '' ) {
            
            // redirect to standard sfdc page
            String hostname = ApexPages.currentPage().getHeaders().get('Host'); 
            String strURL = 'https://'+hostname+'/'+'/a2Q/e?nooverride=1&RecordType=' + recTypeId;
            system.debug('strURL' + strURL);
            
            // if New clicked from Request related list On Opportuntiy PL then pass oppty id and name to standard page to auto-populate lookup
            if (strOppId != null && strOppId != ''){
                strURL += '&CF00N57000006FHFx_lkid=' + strOppId + '&CF00N57000006FHFx=' + strOppName; 
                system.debug('strURL' + strURL);
            }

            
            if(retURL != null && retURL != '')
                strURL += '&retURL=' + retURL;
            
            pgRef = new pagereference(strURL);            
        }
        else{
            // redirect to lightning component 
            pgRef = Page.RequestNew; 
            pgRef.getParameters().put( 'accId', strAccId );
            pgRef.getParameters().put( 'accName', strAccName );
            if ( strAccId != '' &&  strAccId != null)
                pgRef.getParameters().put( 'returnURL', strAccId );
            else if ( strOppId != '' &&  strOppId != null)
                pgRef.getParameters().put( 'returnURL', strOppId );
           
        }
        pgRef.setredirect(true);
        return pgRef;
    }
     
    // method call from RequestEditOverride page to check record type and redirect to standard SFDC or custom page accordingly
    public pagereference redirectEdit(){
        
        String retURL = ApexPages.currentPage().getParameters().get('retURL') ;
               
        Id paramId = (Id) ApexPages.currentPage().getParameters().get('id');
        Request__c recRequest = [SELECT id, RecordTypeId FROM Request__c WHERE id = :paramId ];// get record type id of selected Request record
        
        Pagereference pgRef ;        
        Id rateSheetRecTypeId =  (ID)Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();
        
        If(recRequest.RecordTypeId != rateSheetRecTypeId ) {
            // if selected request is other than 'Rate Sheet' then redirect to standard SFDC page
            String hostname = ApexPages.currentPage().getHeaders().get('Host'); 
            String strURL = 'https://'+hostname+'/'+'/' +paramId + '/e?nooverride=1';
            if (retURL != null && retURL != '')
                strURL += '&retURL=' + retURL;
           
            pgRef = new pagereference(strURL);
            
        } else{
            // if selected request is 'Rate Sheet' then redirect to custom lightning page
            pgRef = Page.RequestViewEdit; 
            pgRef.getParameters().put( 'id', paramId );
            pgRef.getParameters().put( 'editMode', 'true' );            
            pgRef.getParameters().put( 'returnURL', paramId );
          
        }
        pgRef.setredirect(true);
        return pgRef;
    }
    
    @Auraenabled
    public static RequestViewEditResponse getRequestDetails ( String strRequestId, String mode ){
        
        system.debug('$$$ in getRequestRecords, requestRouteIdString: ' + strRequestId);
        
        RequestViewEditResponse requestViewEditResponse = new RequestViewEditResponse();
        list<Request__c> lstRequest = new list<Request__c>();
        
        try{            
            
            if (mode == 'New'){
                
                requestViewEditResponse.request = new Request__c(); 
                requestViewEditResponse.strPricingName = '';
                requestViewEditResponse.request.Status__c = 'New';
                
            } else {
                lstRequest = [SELECT Id,Exceptional_Validity__c,Rate_Sheet_Additions__c,Account__c,Account__r.Name,Liner_Brand__c,Name,Special_Deals__c,
                              Type_of_Special_Deal__c,Output__c,BCO_FWD__c,Shipper_Owner_Container__c,OD_Pairs__c,
                              SAC_Code__c,Status__c,Route_Direction__c,Route_Direction_Code__c,Existing_Contract_ID__c,
                              FMC_NON_FMC__c,Commodity_Rate_Sheet__c,Rate_Sheet_Type__c,Equipment_Types__c,
                              Validity__c,Pricing_Management__c,Pricing_Management__r.Name,Change_Request_Status__c,
                              Change_Type__c,Description_of_Changes_Required__c,OwnerId,Governance_Assignee_Site__c,Owner.Name,
                              Reason_for_Rejection__c,Additional_Notes__c,Team__c,RecordType.Name,CreatedById,LastModifiedById,
                              CreatedBy.Name,CreatedDate,LastModifiedBy.Name,LastModifiedDate,
                              Additional_Group_Internal_Email__c,Migrated_Emails__c,Mail_Send_To__c, Requested_By__c,
                              Requested_By__r.Name, Pricing_Manager_Cluster_TNM_Discussion__c, Sales_Business_Case__c,  
                              Customer_Group__c,New_Comment_From__c, Requested_By_Cluster_Code__c, Change_Team__c
                              FROM Request__c WHERE Id =:strRequestId];
                if(mode == 'Clone'){
                    lstRequest = [SELECT Id,Rate_Sheet_Additions__c,Account__c,Account__r.Name,Liner_Brand__c,Name,Special_Deals__c,
                                  Type_of_Special_Deal__c,Output__c,BCO_FWD__c,Shipper_Owner_Container__c,OD_Pairs__c,
                                  SAC_Code__c,Status__c,Route_Direction__c,Route_Direction_Code__c,Existing_Contract_ID__c,
                                  FMC_NON_FMC__c,Commodity_Rate_Sheet__c,Rate_Sheet_Type__c,Equipment_Types__c,
                                  Validity__c,Pricing_Management__c,Pricing_Management__r.Name,Change_Request_Status__c,
                                  Change_Type__c,Description_of_Changes_Required__c,OwnerId,Governance_Assignee_Site__c,Owner.Name,
                                  Reason_for_Rejection__c,Additional_Notes__c,Team__c,RecordType.Name,CreatedById,LastModifiedById,
                                  CreatedBy.Name,CreatedDate,LastModifiedBy.Name,LastModifiedDate,
                                  Additional_Group_Internal_Email__c,Migrated_Emails__c,Mail_Send_To__c, Requested_By__c,
                                  Requested_By__r.Name, Pricing_Manager_Cluster_TNM_Discussion__c, Sales_Business_Case__c,  
                                  Customer_Group__c,New_Comment_From__c, Requested_By_Cluster_Code__c, Change_Team__c
                                  FROM Request__c WHERE Id =:strRequestId];
                }
                requestViewEditResponse.request = lstRequest[0];
                requestViewEditResponse.strPricingName = lstRequest[0].Pricing_Management__r.Name;
                
                List<Product2> lstProduct = [SELECT Id FROM Product2 WHERE NAME =:lstRequest[0].Route_Direction__c LIMIT 1];
                if (!lstProduct.isEmpty())
                    requestViewEditResponse.strRouteDirId = lstProduct[0].Id;
                
                System.debug('$$$ lstRequest[0]: '+ lstRequest[0]);
                
                requestViewEditResponse.lstChangeType = getDependentFields('Change_Type__c', lstRequest[0].Commodity_Rate_Sheet__c);
                requestViewEditResponse.lstRateSheetAddition = getDependentFields('Rate_Sheet_Additions__c', lstRequest[0].Commodity_Rate_Sheet__c);
                requestViewEditResponse.lstOutput = getDependentFields('Output__c', lstRequest[0].Commodity_Rate_Sheet__c);
                
              
            }
            requestViewEditResponse.lstStatus = getDependentFields('Status__c', 'Rate_Sheet');
            System.debug('$$$ requestViewEditResponse: ' + requestViewEditResponse);
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType requestSchema = schemaMap.get('Request__c');
            Map<String, Schema.SObjectField> fieldMap = requestSchema.getDescribe().fields.getMap();
            
            for (String fieldName: fieldMap.keySet()) {    
                
                requestViewEditResponse.requestfieldMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
                system.debug('@@@@' + requestViewEditResponse.requestfieldMap);
                
                // #RQ-011086 - Status field should be editable only if users have any one permission set assgiend
                if (fieldName == 'Status__c'){
                    
                    if (FeatureManagement.checkPermission('Request_GSC') || FeatureManagement.checkPermission('Request_Pricing_Manager') || FeatureManagement.checkPermission('Request_Cluster_TNM') || UserInfo.getProfileId() == Label.System_Admin_Id)
                        requestViewEditResponse.fieldEditAccessMap.put(fieldName, fieldMap.get(fieldName).getDescribe().isUpdateable());
                    else 
                        requestViewEditResponse.fieldEditAccessMap.put(fieldName, false);
                        
                    } else 
                    requestViewEditResponse.fieldEditAccessMap.put(fieldName, fieldMap.get(fieldName).getDescribe().isUpdateable());
                
                requestViewEditResponse.mapFieldViewAccess.put(fieldName, fieldMap.get(fieldName).getDescribe().isAccessible());
                requestViewEditResponse.mapHelpText.put(fieldName, fieldMap.get(fieldName).getDescribe().getInlineHelpText());
                
            }
            
            if(mode == 'New'){
                
                requestViewEditResponse.strLoggedInUserName=Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
                System.debug('$$$ strLoggedInUserName: '+ requestViewEditResponse.strLoggedInUserName);
                requestViewEditResponse.request.Requested_By__c = Userinfo.getUserId();
                
                List<User> lstUser = [SELECT Cluster_Code__c FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1];
                if (lstUser.size() > 0)
                    requestViewEditResponse.request.Requested_By_Cluster_Code__c = lstUser[0].Cluster_Code__c;
            } 
         } catch (Exception ex){
            
            System.debug('$$$ Exception : ' + ex);
            requestViewEditResponse.blnIsSuccess = false;            
            requestViewEditResponse.strMessage = ex.getMessage(); 
            ErrorLogger.writeError( 'SFDC', 'Request__c', 'RequestViewEditController.getRequestDetails', String.valueOf(ex.getCause()),'Request :  ' + strRequestId + '. ' + ex.getMessage(), ex.getStackTraceString()); 
            
        }
        system.debug('requestViewEditResponse'+requestViewEditResponse);
        return requestViewEditResponse;
    }
    
    @AuraEnabled
    public static RequestViewEditResponse getCommodities (String selectedRouteDirection , String bcoFwd) {
        
        System.debug('$$$ Inside getCommodities, Fetching Commodity for RouteDirection: '+ selectedRouteDirection);
        
        RequestViewEditResponse requestViewEditResponse = new RequestViewEditResponse();
        List<string> commodityList = new List<string> ();
        try{
            if ( bcoFwd != null){
                String strQuery = ' SELECT Commodity__c, Deviation__c FROM Pricing_Management__c '; // RQ-008482 - Mod-03 - Included Deviation__c field
                strQuery += ' WHERE Trade_Route__r.Name = :selectedRouteDirection';
                if (bcoFwd == 'BCO')
                    strQuery += ' AND Active_BCO__c = true ';
                else if ( bcoFwd == 'FWD' )
                    strQuery += ' AND Active_FWD__c = true ';
                List<Pricing_Management__c> pricingMgmt = database.query(strQuery);
                System.debug('$$$ SUCCESS: pricingMgmt : ' + pricingMgmt);
                for (Pricing_Management__C pgmtRec : pricingMgmt){                    
                    if( pgmtRec.Commodity__c != null && pgmtRec.Commodity__c != ''){                 
                        if(pgmtRec.Deviation__c != null && pgmtRec.Deviation__c != '')              // RQ-008482 - Mod-04 - Include Deviation__c value to the commodity value
                            commodityList.add(String.valueOf(pgmtRec.Commodity__c) + '(' + pgmtRec.Deviation__c + ')');
                        else
                            commodityList.add(String.valueOf(pgmtRec.Commodity__c)); 
                    } 
                }
            }
            requestViewEditResponse.listCommodity.addAll(commodityList);
            System.debug('$$$ SUCCESS: commodityList: ' + commodityList);
            
        } catch (Exception ex){
            
            System.debug('$$$ Exception : ' + ex);
            requestViewEditResponse.blnIsSuccess = false;
            requestViewEditResponse.strMessage = ex.getMessage(); 
            ErrorLogger.writeError( 'SFDC', 'Request__c', 'RequestViewEditController.getCommodities', String.valueOf(ex.getCause()),'Route : ' + selectedRouteDirection + '. ' + ex.getMessage(), ex.getStackTraceString()); 
            
        }
        return requestViewEditResponse;
    }
    
    @AuraEnabled
    public static RequestViewEditResponse getEquipmentTypes( String selectedCommodity, String bcoFwd, String selectedRouteDirection ,String mode, String deviationVal){ //RQ-008482 - Mod-01 - Included new param, 'deviationVal'
        
        System.debug('$$$ Fetching Equipment Types for Commodity: '+ selectedCommodity + ':' + selectedRouteDirection );
        
        RequestViewEditResponse requestViewEditResponse= new RequestViewEditResponse();
        List<String> equipmentTypes = null;
        
        try{
            if ( bcoFwd != null){
                String strQuery = ' SELECT Id, Name, Rate_Sheet_Type_Default__c, Equipment_Types_BCO__c, Equipment_Types_FWD__c FROM Pricing_Management__c ';
                strQuery += ' WHERE Trade_Route__r.Name = :selectedRouteDirection and Deviation__c =:deviationVal and Commodity__c =:selectedCommodity' ; //RQ-008482 - Mod-02 - Included 'Deviation__c' field and also 'Commodity__c'(for an existing issue fix)
                
                if (bcoFwd == 'BCO')
                    strQuery += ' AND Active_BCO__c = true ';
                else if ( bcoFwd == 'FWD' )
                    strQuery += ' AND Active_FWD__c = true ';
                
                List<Pricing_Management__c> pricingMgmt = database.query(strQuery);
                if( pricingMgmt.size() > 0 ){
                    
                    system.debug('$$$ Pricing_Management__c: ' + pricingMgmt );
                    
                    String strEquipTypes = '';
                    if (bcoFwd == 'BCO'){
                        strEquipTypes = pricingMgmt[0].Equipment_Types_BCO__c;
                    }
                    else if ( bcoFwd == 'FWD' ){
                        strEquipTypes = pricingMgmt[0].Equipment_Types_FWD__c;
                    }
                    
                    if (strEquipTypes != null && strEquipTypes != '')
                        equipmentTypes = strEquipTypes.split(';');
                    
                    if (equipmentTypes != null)
                        requestViewEditResponse.listEquipmentTypes.addAll(equipmentTypes);
                    
                    requestViewEditResponse.strPricingName = pricingMgmt[0].Name;
                    requestViewEditResponse.pricingMgmt = pricingMgmt[0];
                    if(mode != 'Edit'){
                        requestViewEditResponse.strRateSheetType = pricingMgmt[0].Rate_Sheet_Type_Default__c;
                    }
                    
                    requestViewEditResponse.lstChangeType = getDependentFields('Change_Type__c', selectedCommodity);
                    requestViewEditResponse.lstRateSheetAddition = getDependentFields('Rate_Sheet_Additions__c', selectedCommodity);
                    requestViewEditResponse.lstOutput = getDependentFields( 'Output__c', selectedCommodity);
                    
                } else {
                    if (bcoFwd == 'BCO')
                        throw new ReqException( System.Label.requestErrorMsg3);
                    else if ( bcoFwd == 'FWD' )
                        throw new ReqException( System.Label.requestErrorMsg4);
                }                
            }            
            
            if ( equipmentTypes == null ){
                
                System.debug('$$$ inside not permitted by the Pricing Policy');  
                throw new ReqException(System.Label.requestErrorMsg5);
            }            
        } catch ( ReqException reqEx){
            
            System.debug('$$$ ReqException : ' + reqEx);            
            requestViewEditResponse.blnIsSuccess = false;           
            requestViewEditResponse.strMessage = reqEx.getMessage();
            ErrorLogger.writeError( 'SFDC', 'Request__c', 'RequestViewEditController.getEquipmentTypes', String.valueOf(reqEx.getCause()),'Route : ' + selectedRouteDirection + '. ' + reqEx.getMessage(), reqEx.getStackTraceString()); 
            
        } catch(Exception ex){
            
            System.debug('$$$ Exception : ' + ex);
            requestViewEditResponse.blnIsSuccess = false;
            requestViewEditResponse.strMessage = ex.getMessage(); 
            ErrorLogger.writeError( 'SFDC', 'Request__c', 'RequestViewEditController.getEquipmentTypes', String.valueOf(ex.getCause()),'Route : ' + selectedRouteDirection + '. ' + ex.getMessage(), ex.getStackTraceString()); 
            
        }
        return requestViewEditResponse;    
    }
    
    @AuraEnabled
    public static RequestViewEditResponse saveRequestDetails(Request__c request, String mode){
        
        System.debug('$$$Inside Save: '+ request);
                
        RequestViewEditResponse requestViewEditResponse= new RequestViewEditResponse(); 
        
        Id userId= request.Requested_By__c;
        System.debug('$$$$$$$userId: '+ userId);
        String strClusterCode= null;
        String queueName = null;
        String strOwnerId = null;
        
        try{   
                       
            if (mode == 'Edit'){
                
                if (request.Commodity_Rate_Sheet__c != 'FAK' && request.Pricing_Management__c != null){
                    
                    List<Pricing_Management__c> lstPM = [SELECT id, Equipment_Types_BCO__c, Equipment_Types_FWD__c FROM Pricing_Management__c
                                                        WHERE Id = :request.Pricing_Management__c ];
                  
                    if (!lstPM.isEmpty() ){
                         if (request.BCO_FWD__c == 'BCO' && lstPM[0].Equipment_Types_BCO__c != null)
                            request.Equipment_Types__c = lstPM[0].Equipment_Types_BCO__c;
                        else if (request.BCO_FWD__c == 'FWD' && lstPM[0].Equipment_Types_FWD__c != null)
                            request.Equipment_Types__c = lstPM[0].Equipment_Types_FWD__c;
                    }
                }
                
                update request;
                requestViewEditResponse.request = request;
            }
            
            else if (mode == 'Clone' || mode == 'New'){
                
                System.debug('$$$ userId : '+ userId);
                List<User> listUser = [SELECT Cluster_Code__c FROM User WHERE Id =: userId LIMIT 1];
                strClusterCode = listUser[0].Cluster_Code__c;
               
                Id rateSheetRecTypeId =  (ID)Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();
                Request__c newOrClonedRequest = new Request__c();
                newOrClonedRequest.Account__c = request.Account__c;
                newOrClonedRequest.Liner_Brand__c = request.Liner_Brand__c;
                newOrClonedRequest.Special_Deals__c = request.Special_Deals__c;
                newOrClonedRequest.Type_of_Special_Deal__c = request.Type_of_Special_Deal__c;
                newOrClonedRequest.Output__c = request.Output__c;
                newOrClonedRequest.BCO_FWD__c = request.BCO_FWD__c;
                newOrClonedRequest.Shipper_Owner_Container__c = request.Shipper_Owner_Container__c;
                newOrClonedRequest.OD_Pairs__c = request.OD_Pairs__c;
                newOrClonedRequest.SAC_Code__c = request.SAC_Code__c;
                newOrClonedRequest.FMC_NON_FMC__c = request.FMC_NON_FMC__c;
                newOrClonedRequest.Existing_Contract_ID__c = request.Existing_Contract_ID__c;
                newOrClonedRequest.Commodity_Rate_Sheet__c = request.Commodity_Rate_Sheet__c;
                newOrClonedRequest.Equipment_Types__c = request.Equipment_Types__c;
                newOrClonedRequest.Pricing_Management__c = request.Pricing_Management__c;
                newOrClonedRequest.Rate_Sheet_Type__c = request.Rate_Sheet_Type__c;
                newOrClonedRequest.Additional_Group_Internal_Email__c = request.Additional_Group_Internal_Email__c;
                newOrClonedRequest.Migrated_Emails__c = request.Migrated_Emails__c;
                newOrClonedRequest.Mail_Send_To__c = request.Mail_Send_To__c;
                newOrClonedRequest.Change_Request_Status__c = request.Change_Request_Status__c;
                newOrClonedRequest.Change_Type__c = request.Change_Type__c;
                newOrClonedRequest.Change_Team__c = request.Change_Team__c;
                newOrClonedRequest.Description_of_Changes_Required__c = request.Description_of_Changes_Required__c;
                newOrClonedRequest.Governance_Assignee_Site__c = request.Governance_Assignee_Site__c;
                newOrClonedRequest.Status__c = request.Status__c;
                newOrClonedRequest.Reason_for_Rejection__c = request.Reason_for_Rejection__c;
                newOrClonedRequest.Team__c = request.Team__c;
                newOrClonedRequest.Additional_Notes__c = request.Additional_Notes__c;
                newOrClonedRequest.Requested_By__c = request.Requested_By__c;
                newOrClonedRequest.Requested_By_Cluster_Code__c = request.Requested_By_Cluster_Code__c;
                newOrClonedRequest.Pricing_Manager_Cluster_TNM_Discussion__c = request.Pricing_Manager_Cluster_TNM_Discussion__c;
                newOrClonedRequest.Sales_Business_Case__c = request.Sales_Business_Case__c;
              //  newOrClonedRequest.TnM_Business_Case__c = request.TnM_Business_Case__c;
                newOrClonedRequest.Customer_Group__c = request.Customer_Group__c;
                newOrClonedRequest.New_Comment_From__c = request.New_Comment_From__c;
                newOrClonedRequest.Rate_Sheet_Additions__c = request.Rate_Sheet_Additions__c;
                newOrClonedRequest.Exceptional_Validity__c = request.Exceptional_Validity__c;
                newOrClonedRequest.RecordTypeId = rateSheetRecTypeId;
                newOrClonedRequest.Legacy_Request_Change_Description__c = '';
                newOrClonedRequest.Legacy_Request_Change_Status__c = '';
                newOrClonedRequest.Legacy_Request_Change_Type__c = '';
                newOrClonedRequest.Legacy_Request_Route_Change_Description__c = '';
                newOrClonedRequest.Legacy_Request_Route_Change_Status__c = '';
                newOrClonedRequest.Legacy_Request_Status__c = '';
               
                if (request.Requested_By__c != null && request.Requested_By_Cluster_Code__c == null)
                    newOrClonedRequest.Requested_By_Cluster_Code__c = strClusterCode;
                
                insert newOrClonedRequest;
                requestViewEditResponse.request = newOrClonedRequest;
                
                if (mode == 'Clone' ){
                    
                    String recTypeId = Schema.SObjectType.Request_Information__c.getRecordTypeInfosByName().get( Label.RequestDetail_ContactRecordType).getRecordTypeId();
                    List<Request_Information__c> reqInfoList = [SELECT Id, Change_Status__c, Contact__c, User__c
                                                                FROM Request_Information__c
                                                                WHERE Request__c = :request.id AND recordtypeid = :recTypeId];
                    
                    List<Request_Information__c> insertReqInfoList = new List<Request_Information__c>();
                    
                    for (Request_Information__c rec : reqInfoList){
                        
                        Request_Information__c newRec = new Request_Information__c();
                        newRec.RecordTypeId = recTypeId;
                        newRec.Request__c = newOrClonedRequest.id;
                        newRec.Contact__c = rec.Contact__c;
                        newRec.User__c = rec.User__c;
                        
                        insertReqInfoList.add(newRec);
                    }
                    
                    if (! insertReqInfoList.isEmpty()){
                        insert insertReqInfoList;
                    }
                }
            }
        } catch( DmlException dmEx){
            
            System.debug('$$$ DmlException : ' + dmEx);
            requestViewEditResponse.blnIsSuccess = false;
            requestViewEditResponse.strMessage =  dmEx.getDMLMessage(0);  
            ErrorLogger.writeError( 'SFDC', 'Request__c', 'RequestViewEditController.saveRequestDetails',  String.valueOf(dmEx.getDmlType(0)) ,'Request : ' + request.id + ', Mode : ' + mode + '. ' + dmEx.getDMLMessage(0) , dmEx.getStackTraceString()); 
            
        } catch( Exception ex){
            
            System.debug('$$$ Exception : ' + ex);
            requestViewEditResponse.blnIsSuccess = false;
            requestViewEditResponse.strMessage = ex.getMessage(); 
            ErrorLogger.writeError( 'SFDC', 'Request__c', 'RequestViewEditController.saveRequestDetails', String.valueOf(ex.getCause()),'Request : ' + request.id + ', Mode : ' + mode + '. ' + ex.getMessage(), ex.getStackTraceString()); 
            
        }
        return requestViewEditResponse;  
    }   
    
    // @AuraEnabled
    public static List<String> getDependentFields (String fieldName, String selectedCommodity) {
        
        System.debug('$$$ Inside getChangeType : '+ selectedCommodity);
        List<String> lstPicklistValues = new List<string> ();
        
        try{
            if (selectedCommodity != 'FAK' && selectedCommodity != 'Rate_Sheet') {
                selectedCommodity = 'Traded Commodity';
            }
            
             List<Rate_Sheet_Field_Dependency__mdt> lstPicklist = [SELECT Picklist_Value__c FROM Rate_Sheet_Field_Dependency__mdt 
                                                                   WHERE Dependent_Field__c = :fieldName
                                                                  AND Controlling_Text__c = :selectedCommodity];
            system.debug('lstPicklist' + lstPicklist);
            
            for (Rate_Sheet_Field_Dependency__mdt rec : lstPicklist){
                    
                lstPicklistValues.addAll(rec.Picklist_Value__c.split(';'));             
            }
            System.debug('$$$ SUCCESS: lstPicklistValues: ' + lstPicklistValues);            
        
        }  catch( Exception ex){
            
            System.debug('$$$ Exception : ' + ex);
        }
        return lstPicklistValues;
    }
   
}