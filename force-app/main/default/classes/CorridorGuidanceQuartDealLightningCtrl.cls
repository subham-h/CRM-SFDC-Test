/*
Description  : Contoller class for Corridor Guidance Quarterly Deal lightning pages

* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          03/10/2017        john.christopher@ust-global.com           #PR-0152-Quarterly Deals
* v2.0          13/06/2018        manjunath.c.holekade@maersk.com           RQ-008665 - Mod-01 - Added "Special_Equipment__c" as part of the SOQL
* v3.0          21-Jun-2018       manjunath.c.holekade@maersk.com           RQ-008666 - Mod-01 & 02 - Added "Account Name" and "Named Account" fields as part of the queries
* v4.0          19-Nov-2018       jagadeesan.sakthivel@ust-global.com       RQ-008951 Added Account SCV Code and Named Account SCV Code fields as part of the Queries    - Mod-03 - New method, 'updateCG', to update "For Review By" field on CG object
* V4.1          26/11/2018         sidhartha mohapatra                      #RQ-009604: Added Method to get product family
* V5.0			27/04/2019		  rakesh.allam@maersk						#RQ-013390 : Deprecate CorridorGuidanceLightning page
*/

public class CorridorGuidanceQuartDealLightningCtrl {
    
    String corrGuidanceId , opptyId, prodId,recType;
    public static Id pricingMgmtQuartDealRecordTypeId;
    
    static{
        pricingMgmtQuartDealRecordTypeId=Schema.SObjectType.Pricing_Management__c.getRecordTypeInfosByName()
            .get(system.label.QuarterlyDealsRecordTypeName).getRecordTypeId();
    }     
    
    // constructor method to fetch Quarterly Deal Opportunity Id and Product Id based on selected corridor 
    public CorridorGuidanceQuartDealLightningCtrl( ApexPages.StandardController controller ){
        
        corrGuidanceId = (string) ApexPages.currentPage().getParameters().get('id'); // get corridor guidance id
        
        //fetch oppty id and product id for the selected corridor guidance
        List<Corridor_Guidance__c> corrGuidanceRec = [ SELECT id, Product__c, Opportunity__c,Opportunity__r.Recordtype.Name FROM Corridor_Guidance__c WHERE Id =: corrGuidanceId];        
        if (corrGuidanceRec.size() > 0 ){
            
            corrGuidanceId = corrGuidanceRec.get(0).id; //convert to 18 digit
            prodId = corrGuidanceRec.get(0).Product__c;
            opptyId = corrGuidanceRec.get(0).Opportunity__c;
            recType = corrGuidanceRec.get(0).Opportunity__r.Recordtype.Name;
        }        
    }
    
    // re-direction method used when user clicks Corridor Guidance View/Edit links from standard UI, user is reidrected to a VF page which is then redirected to the lightining page
    public PageReference redirectToLightning(){
        
        PageReference pgRef ;
        /*#RQ-013390
         * if(recType!=Label.QuarterlyDealRecordType){
            
            pgRef = Page.CorridorGuidanceLightning; //construct the PageReference for the page to which we are redirecting
            pgRef.getParameters().put( 'id', corrGuidanceId ); //set the Id of the corridor guid record      
            pgRef.getParameters().put( 'optyId', opptyId ); 
            pgRef.getParameters().put( 'prodId', prodId );        
            pgRef.setRedirect(true); 
            
            
        }
        
        else {

		#RQ-013390*/
            
            pgRef = Page.CorridorGuidanceQuartDealsLightning; //construct the PageReference for the page to which we are redirecting
            pgRef.getParameters().put( 'id', corrGuidanceId ); //set the Id of the corridor guid record      
            pgRef.getParameters().put( 'optyId', opptyId ); 
            pgRef.getParameters().put( 'prodId', prodId );        
            pgRef.setRedirect(true);
        //}
        return pgRef;
    }
    
    @AuraEnabled
    public static Product2 getProductFamily (Id prodId) {
        
        Product2 pFamily = [select Family from Product2 where Id =:prodId];
        return pFamily;
    }
    
    @Auraenabled
    public static Boolean checkCentrUser(){
        
        if(userinfo.getProfileId() == Label.CenterTNM_profileId){
            return true;
        }
        
        return false;
    } 
    
    //check whether the logged in user has GscPermSet access
    @Auraenabled
    public static Boolean checkIsUserInGscPermSet(){
        Boolean user_has_permission = false;
        List<PermissionSetAssignment> lstcurrentUserPerSet =  [ SELECT Id, PermissionSet.Name,AssigneeId
                                                               FROM PermissionSetAssignment
                                                               WHERE AssigneeId = :userinfo.getUserId() ];
        system.debug('##lstcurrentUserPerSet' + lstcurrentUserPerSet);
        for ( PermissionSetAssignment psa : lstcurrentUserPerSet ) {
            System.debug('##psa.PermissionSet.Name' + psa.PermissionSet.Name);
            if ( psa.PermissionSet.Name.equals('GSC_QUartlerly_deals') ) {
                user_has_permission = true;
            }
        }
        return user_has_permission;
    } 
    
    
    @Auraenabled
    public static CorridorGuidanceQuartDealResponse getCorridorResponse ( String  corrGuidanceId, Id opptyId, Id prodId){
        system.debug('$$$ getCorridorResponse');
        system.debug('String corrGuidanceId, Id opptyId, Id prodId'+'-'+ corrGuidanceId +',' +opptyId+','+prodId);
        //system.debug('String corrGuidanceId Size' + corrGuidanceId.length()) ;
        list<Corridor_Guidance__c> corrRec =new list<Corridor_Guidance__c>();
        CorridorGuidanceQuartDealResponse cgResponse = new CorridorGuidanceQuartDealResponse();
        
        try{
            if(corrGuidanceId.trim() == null || corrGuidanceId.trim() == ''){
                
                Corridor_Guidance__c corObj = new  Corridor_Guidance__c();                                
                corObj.Opportunity__c = opptyId;
                corObj.Product__c = prodId;
                insert corObj;
                System.debug('#####corrGuidanceId'+corObj.id);
                corrGuidanceId = corObj.Id;
            }
            //String a = corrGuidanceId.trim();
            //system.debug(a.length());
            System.debug('#####corrGuidanceId1'+corrGuidanceId);
            Id corrId =  Id.valueOf(corrGuidanceId.trim());
            System.debug('#####corrGuidanceId111'+corrId) ;              
            corrRec= [ SELECT Id, Name,Opportunity__c, Opportunity__r.Name, 
                      Product__c, Product__r.Name,
                      Pricing_Manager_Approval__c,Pricing_Approval_By__c,  
                      Cluster_TNM_Approval__c,Cluster_TNM_Approval_By__c,
                      Description__c,First_Round_Offer_Status__c,GSC_Filing_Status__c,For_Review_by__c,Opportunity__r.Type,
                      Opportunity__r.Account.Name, Opportunity__r.Named_Account__r.Name,        //RQ-008666 - Mod-01
                      Opportunity__r.Account.SCV_Code__c, Opportunity__r.Named_Account__r.SCV_Code__c, //RQ-008951 
                      Opportunity__r.AccountId, Opportunity__r.Named_Account__c                  
                      FROM Corridor_Guidance__c 
                      WHERE Id =:corrId];
            
            System.debug('#####Corr Record'+corrRec);
            cgResponse.cgRec = corrRec[0];
            
            
            String sSoql= 'SELECT Name,id,Origin_Micromarket__c,Destination_Micromarket__c, ';
            sSoql +='Special_Equipment__c, ';                   //RQ-008665 - Mod-01 - Include "Special_Equipment__c" field    
            sSoql +='Existing_Agreed_Rate_20__c,Existing_Agreed_Rate_40__c,Existing_Agreed_Rate_40h__c, ';
            sSoql +='New_Rate_Sales_Targeting_20__c,New_Rate_Sales_Targeting_40__c,New_Rate_Sales_Targeting_40h__c,';   
            sSoql +='CEN_Final_Agreed_Rate_20__c,CEN_Final_Agreed_Rate_40__c,CEN_Final_Agreed_Rate_40h__c,'; 
            sSoql +='Target_20__c,Target_40__c,Target_40h__c,Micro_Markets_Description__c FROM Corridor_Guidance_Detail__c';
            sSoql +=' WHERE Corridor_Guidance__c = \'';
            sSoql += corrId+'\'';
            sSoql += ' ORDER BY NAME desc';
            system.debug('sSoql' + sSoql);
            List<Corridor_Guidance_Detail__c> cgQuartDealDetailList;
            cgQuartDealDetailList = Database.query(sSoql);
            
            System.debug('$$$$$$$$$$ cgQuartDealDetailList : ' + cgQuartDealDetailList);
            // need to set fields to 0 in case of nulls in order to avoid NAN errors on lighting pages
            // and calculation for discount fields
            
            for(Corridor_Guidance_Detail__c cg : cgQuartDealDetailList){
                
                
                
                //Setting values for Existing Agreed rate fields
                if(cg.Existing_Agreed_Rate_20__c==null)
                    cg.Existing_Agreed_Rate_20__c=0;
                if(cg.Existing_Agreed_Rate_40__c==null) 
                    cg.Existing_Agreed_Rate_40__c=0;
                if(cg.Existing_Agreed_Rate_40h__c==null)
                    cg.Existing_Agreed_Rate_40h__c=0;
                
                //Setting values for New rate fields
                if(cg.New_Rate_Sales_Targeting_20__c==null)
                    cg.New_Rate_Sales_Targeting_20__c=0;
                if(cg.New_Rate_Sales_Targeting_40__c==null) 
                    cg.New_Rate_Sales_Targeting_40__c=0;
                if(cg.New_Rate_Sales_Targeting_40h__c==null)
                    cg.New_Rate_Sales_Targeting_40h__c=0;
                
                //Setting values for Cen final Agreed rate fields
                if(cg.CEN_Final_Agreed_Rate_20__c==null)
                    cg.CEN_Final_Agreed_Rate_20__c=0;
                if(cg.CEN_Final_Agreed_Rate_40__c==null)    
                    cg.CEN_Final_Agreed_Rate_40__c=0;
                if(cg.CEN_Final_Agreed_Rate_40h__c==null)
                    cg.CEN_Final_Agreed_Rate_40h__c=0;
                
                
                //Setting values for Target rate fields
                if(cg.Target_20__c==null)
                    cg.Target_20__c=0;
                if(cg.Target_40__c==null)   
                    cg.Target_40__c=0;
                if(cg.Target_40h__c==null)
                    cg.Target_40h__c=0;
                
            } 
            
            update cgQuartDealDetailList;
            System.debug('$$$$$$$$$$ cgQuartDealDetailList After update: ' + cgQuartDealDetailList);
            cgResponse.cgQuartDealDetailList=cgQuartDealDetailList;
            
            System.debug('$$$$$$$$$$ cgResponse: ' + cgResponse);
        }catch(DmlException dmEx){
            System.debug('$$$$$$$$$$$$$$$DmlException : ' + dmEx);
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add( dmEx.getDMLMessage(0));   
        }catch(Exception ex){
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add(ex.getMessage()); 
        }
        return cgResponse;  
    }
    
    @Auraenabled
    public static CorridorGuidanceQuartDealResponse editCorridorResponse ( Id  corrGuidanceId, String clusterTNMApproval, String pricingApproval , String firstRoundOfferStatus , string description,String gscFilingStatus, String forreviewby){
        system.debug('$$$ editCorridorResponse');
        system.debug('Id  corrGuidanceId, String clusterTNMApproval, String pricingApproval,String firstRoundOfferStatus,String forreviewby'+ corrGuidanceId +',' +clusterTNMApproval+','+pricingApproval+','+firstRoundOfferStatus+','+forreviewby);
        
        list<Corridor_Guidance__c> corrRec =new list<Corridor_Guidance__c>();
        CorridorGuidanceQuartDealResponse cgResponse = new CorridorGuidanceQuartDealResponse();
        try{
            
            
            System.debug('#####corrGuidanceId1'+corrGuidanceId);
            //Id corrId =  Id.valueOf(corrGuidanceId.trim());
            //System.debug('#####corrGuidanceId111'+corrId) ;              
            corrRec= [ SELECT Id, Name,Opportunity__c, Opportunity__r.Name, 
                      Product__c, Product__r.Name,
                      Pricing_Manager_Approval__c,Pricing_Approval_By__c,  
                      Cluster_TNM_Approval__c,Cluster_TNM_Approval_By__c,
                      First_Round_Offer_Status__c,Description__c,GSC_Filing_Status__c,For_Review_by__c,
                      Opportunity__r.Account.Name, Opportunity__r.Named_Account__r.Name,Opportunity__r.AccountId, //RQ-008666 - Mod-02
                      Opportunity__r.Named_Account__c                  
                      FROM Corridor_Guidance__c 
                      WHERE Id =:corrGuidanceId];
            
            corrRec[0].Pricing_Manager_Approval__c = pricingApproval;
            corrRec[0].Cluster_TNM_Approval__c = clusterTNMApproval;
            corrRec[0].First_Round_Offer_Status__c = firstRoundOfferStatus;
            corrRec[0].GSC_Filing_Status__c=gscFilingStatus;
            corrRec[0].For_Review_by__c=forreviewby;
            corrRec[0].Description__c = description;
            update corrRec;
            
            
            System.debug('#####Corr Record'+corrRec);
            
            cgResponse.cgRec = corrRec[0];
        }catch( dmlException dmlEx ){
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add( dmlEx.getDMLMessage(0));  
        }catch( exception ex ){
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add(ex.getMessage());
        }
        return cgResponse;  
    }
    
    @AuraEnabled
    public static CorridorGuidanceQuartDealResponse updateCGDetails(List<Corridor_Guidance_Detail__c> corrGuidanceDetails){
        CorridorGuidanceQuartDealResponse cgResponse = new CorridorGuidanceQuartDealResponse();
        system.debug('$$$$$$$ in corrGuidanceDetails input' + corrGuidanceDetails);
        try{
            system.debug('$$$$$$$ in updateCgDetails');
            
            for(Corridor_Guidance_Detail__c cgDetail : corrGuidanceDetails){
                cgDetail.Manually_Amended__c = true;
            }
            update corrGuidanceDetails;
        }catch( exception ex ){
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add(ex.getMessage());
        }
        
        return cgResponse;
    }
    @AuraEnabled 
    public static CorridorGuidanceQuartDealResponse deleteCorridor (List<Id> corrGuidanceDetailId){
        
        CorridorGuidanceQuartDealResponse cgResponse = new CorridorGuidanceQuartDealResponse();
        
        try{
            List<Corridor_Guidance_Detail__c> recordList= [SELECT Id FROM Corridor_Guidance_Detail__c WHERE id in :corrGuidanceDetailId];
            delete recordList;
            
        }catch (dmlException ex1){
            
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add( ex1.getDMLMessage(0));
        }catch ( exception ex ){
            
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add(ex.getMessage());
            
        } 
        
        return cgResponse;
    }
    
    
    
    @AuraEnabled
    public static CorridorGuidanceResponse saveCorridor(Id corrGuidanceId,String description,String origin,string destination, Id prodId){
        CorridorGuidanceResponse cgResponse = new CorridorGuidanceResponse(); 
        
        try{
            List<Pricing_Management__c> pMgmtList = [SELECT id, Target_20__c, Target_40__c, Target_40h__c
                                                     FROM Pricing_Management__c
                                                     WHERE Product__c = :prodId
                                                     AND Origin__c = :origin
                                                     AND Destination__c = :destination
                                                     AND RecordTypeId= :pricingMgmtQuartDealRecordTypeId];
            System.debug('$$$$$$$$$$$$$$$$$$$pMgmtList: ' + pMgmtList);
            Corridor_Guidance_Detail__c cgDetail = new Corridor_Guidance_Detail__c();
            cgDetail.Corridor_Guidance__c = corrGuidanceId;
            
            cgDetail.Micro_Markets_Description__c=description;
            cgDetail.Origin_Micromarket__c = origin;
            cgDetail.Destination_Micromarket__c = destination;
            cgDetail.RecordTypeId=system.label.CG_Detail_Quarterly_Deal_Record_Type_Id;
            if (!pMgmtList.isEmpty()){
                cgDetail.Target_20__c = pMgmtList.get(0).Target_20__c;
                cgDetail.Target_40__c = pMgmtList.get(0).Target_40__c;
                cgDetail.Target_40h__c = pMgmtList.get(0).Target_40h__c;
                
            }
            
            insert (cgDetail);
            
        } catch ( dmlException ex1 ){
            
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add( ex1.getDMLMessage(0));
            
        } catch ( exception ex ){
            
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add(ex.getMessage());
            
        }
        
        return cgResponse;
    }
    
    @AuraEnabled
    public static CorridorGuidanceQtrDealGeographyResponse getOriginAndDestinationList(Id prodId){
        
        CorridorGuidanceQtrDealGeographyResponse response = new CorridorGuidanceQtrDealGeographyResponse();
        AggregateResult[] originGroupResult = [SELECT Origin__c, Destination__c FROM Pricing_Management__c
                                               WHERE Product__c = :prodId
                                               AND RecordTypeId= :pricingMgmtQuartDealRecordTypeId
                                               GROUP BY Origin__c, Destination__c];
        
        Set<String> originSet = new Set<String>();
        Set<String> destSet = new Set<String>();
        
        for (AggregateResult agg : originGroupResult){
            String origin = (String)agg.get('Origin__c');
            String dest = (String) agg.get('Destination__c');
            
            if (! originSet.contains(origin))
                originSet.add(origin);
            
            if (! destSet.contains(dest))
                destSet.add(dest);
            
            response.OriginDestPairList.add(origin + '_' + dest);
        }
        
        response.originList.addAll(originSet);
        response.originList.sort();
        
        response.destList.addAll(destSet);
        response.destList.sort();
        return response;
    }
    
    @AuraEnabled
    public static Pricing_Management__c getPricingMgmtRates(Id prodId, String origin, String destination){
        
        List<Pricing_Management__c> pMgmtList = [SELECT id, Target_20__c, Target_40__c, Target_40h__c
                                                 FROM Pricing_Management__c
                                                 WHERE Product__c = :prodId
                                                 AND Origin__c = :origin
                                                 AND Destination__c = :destination 
                                                 AND RecordTypeId= :pricingMgmtQuartDealRecordTypeId];
        if (pMgmtList == null || pMgmtList.isEmpty())
            return null;
        else
            return pMgmtList.get(0);
    }
    
    
    //check whether the logged in user has Trade_Manager_Pricing_Approval permission set access
    @Auraenabled
    public static Boolean checkTradeManagerPermSet(){
        Boolean user_has_access = false;
        List<PermissionSetAssignment> lstcurrentUserPerSet =  [ SELECT Id, PermissionSet.Name,AssigneeId
                                                               FROM PermissionSetAssignment
                                                               WHERE AssigneeId = :userinfo.getUserId() ];
        system.debug('##lstcurrentUserPerSet' + lstcurrentUserPerSet);
        for ( PermissionSetAssignment psa : lstcurrentUserPerSet ) {
            System.debug('##Tmp.PermissionSet.Name' + psa.PermissionSet.Name);
            if ( psa.PermissionSet.Name.equals('Trade_Manager_Pricing_Approval') ) {
                user_has_access = true;
            }
        }
        return user_has_access;
    } 
    // RQ-008666 - Mod-03 - Update CG "For Review By" field
    @Auraenabled
    public static CorridorGuidanceResponse updateCG(String reviewBy, String cgID){
        CorridorGuidanceResponse cgResponse = new CorridorGuidanceResponse();
        Corridor_Guidance__c cgRec = [select Id, For_Review_by__c,Cluster_TNM_Approval__c from Corridor_Guidance__c where ID =: cgID];
        try{
            system.debug('a1a:'+reviewBy);
            system.debug('a1b:'+cgID);
            if(reviewBy == 'Sales Rep'  && cgRec.Cluster_TNM_Approval__c == 'Approved')
                cgRec.For_Review_by__c = 'Sales Rep';
            else if(reviewBy == 'Pricing Mgr')
                cgRec.For_Review_by__c = 'Pricing Manager';
            update cgRec;
        }catch( exception ex ){
            cgResponse.isSuccess = false;
            cgResponse.Level = 'Error';
            cgResponse.listMessage.add(ex.getMessage());
        }
        return cgResponse;
    }
}