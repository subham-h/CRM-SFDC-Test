/*
Description  : Controller used for Trade Tender Target Updates page.

* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          3/11/2017          ramadevi.palaniswamy@ust-global.com          #RE-4898:Code created in replacement for TenderTarget Page
* V2.0         05/13/2017          uvais.komath@ust-global.com                  #RQ-004923:Opportunity.Named_Account__c from Querystr changed to Opportunity.Named_Account__r.Name
* V2.1         08/05/2017          meghana.gupta@ust-global.com                 #RQ-004742: CluAP link added on Tender Page
* V3.0         11/16/2017          ramadevi.palaniswamy@ust-global.com          #RQ-007290: Modified the field values for Customner Group and Value Proposition
* V4.0         11/29/2017          sandhya.sambasivan@ust-global.com            #RQ-007297: Added Toggle button for Next 100 Tender
* V5.0         14-Aug-2019         manjunath.c.holekade@maersk.com              #RQ-011436 - Remove references/logic related to "Customer_Rating__c"
* V6.0         16-Aug-2019         Junaid.Khader@maersk.com                     #RQ-011435 - Removed references of field Linked_to_Cluster_Action_Plan__c
* V7.0         23-Dec-2019         manjunath.c.holekade@maersk.com              #RQ-012367 - Remove references/logic related to "Previous_Tender_Rate__c", "Rate__c", "Delta_Rate__c" and "Rate_Guidance__c" of OpptyLineItem
*/
Public Class TNMTenderController extends AuraResponse{

    // Method to retrieve the OLI for the selected Route Directions
    @AuraEnabled
    public static List<TenderOLIResponse.wrapperOLI_Rating> getOLIExtracts1( List<String> routeCodeList, String startDate, String endDate,String nextSteps, String clientGrp, String scvCode, String concernCode,Integer lowerFfe, Integer upperFfe, Boolean next100IsEnabled){
        
        Set<Id> accIds = new Set<Id>();
        Set<Id> corrIds = new Set<Id>();
        Set<Id> selectedRouteIds = new Set<Id>();        
        list<TenderOLIResponse.wrapperOLI_Rating> oliList = new list<TenderOLIResponse.wrapperOLI_Rating>();
        Set<String> routeCodes = new Set<String>();
        Id recordTypeId = System.Label.OppTenderRecordTypeId;
        Id QrtDealsRecTypeId = System.Label.QuarterlyDealsRecordTypeId; //#RQ-007297
        Date startdate1;
        Date endDate1 ;
        Integer rowNum = 0;
        
        for(string rtcodeName : routeCodeList)
            routeCodes.add(rtCodeName);            
        
        Map<Id, Product2> productMap = new Map<Id, Product2> (  [ Select Id, Name, Route_Direction_Code__c from Product2 where isActive = true and Route_Direction_Code__c in :routeCodes order by Route_Direction_Code__c]  );
        
        for( Product2 prod: productMap.Values()){
            
            if( routeCodes.contains(prod.Route_Direction_Code__c) )
                selectedRouteIds.add(prod.Id);
        }
        
        system.debug(lowerFfe + '===='+ upperFfe);
    
        String queryStr = 'SELECT Id,Opportunity.RecordTypeId,Quantity, Product2Id, Product2.Name, Product2.Route_Direction_Code__c, Opportunity.Account.Name,Opportunity.Named_Account__c, Opportunity.Named_Account__r.Name, ';
        queryStr += ' Opportunity.Account.SCV_Code__c, Opportunity.Account.Attractiveness__c, Opportunity.Owner.Cluster__c, Opportunity.Liner_Brand__c, Opportunity.Name, ';
        queryStr += ' OpportunityId,Trade_Guidance_Id__c, Opportunity.StageName,Opportunity.Next_Steps__c,Opportunity.CloseDate, ';
        queryStr += ' Opportunity.First_Shipment_Date__c, Opportunity.Last_Shipment_Date__c, Opportunity.Expected_Tender_Receipt_Date__c, Opportunity.Commodity__c, Tender_Target__c, ';
        queryStr += ' Comments__c, Previous_Tender_Target__c, Commitment__c,Opportunity.Days_Until_Tender_Received__c ';
        queryStr += ' FROM OpportunityLineItem WHERE Product2Id in :selectedRouteIds AND Opportunity.IsClosed = false';
        //#RQ-007297 - Added filter
        if (next100IsEnabled == FALSE){
        
            queryStr += ' AND Opportunity.recordTypeId = :recordTypeId ';
        }
        else{
            queryStr += ' AND (Opportunity.recordTypeId = :recordTypeId OR Opportunity.recordTypeId = :QrtDealsRecTypeId)'; 
        }
        
        if(next100IsEnabled == FALSE){
            if (startDate.length() != 0){
            
                startdate1 = Date.valueof(startDate); 
                queryStr += ' AND Opportunity.Expected_Tender_Receipt_Date__c >=: startdate1  ';
            }
            
            if (endDate.length() != 0){
            
                endDate1 = Date.valueof(endDate); 
                queryStr += ' AND Opportunity.Expected_Tender_Receipt_Date__c <=: enddate1  ';
            }
        }
        else if(next100IsEnabled == TRUE){
            if (startDate.length() != 0){
            
                startdate1 = Date.valueof(startDate); 
                queryStr += ' AND Opportunity.CloseDate >=: startdate1  ';
            }
            
            if (endDate.length() != 0){
            
                endDate1 = Date.valueof(endDate); 
                queryStr += ' AND Opportunity.CloseDate <=: enddate1  ';
            }
        }
        if ( NextSteps != '' && NextSteps != null ){            
            queryStr += ' AND Opportunity.Next_Steps__c = :NextSteps ';     
        }
        
        if ( lowerFfe!= null ){            
            queryStr += ' AND OpportunityLineItem.Quantity >= :lowerFfe';    
        }
        
        if ( upperFfe!= null ){           
            queryStr += ' AND OpportunityLineItem.Quantity <= :upperFfe';    
        }
        
        if ( scvCode != '' && scvCode != null ){            
            queryStr += ' AND Opportunity.Account.scv_code__c  = :scvCode ';    
        }
        
        if ( concernCode != '' && concernCode != null ){            
            queryStr += ' AND Opportunity.Account.Concern_Code__c = :concernCode ';     
        }
        
        //#RQ-007290: Modified the field values for Customner Group and Value Proposition
        if(next100IsEnabled == FALSE){
            if( clientGrp != '' && clientGrp != null && clientGrp != 'Non Key Client'){
                String clientGroup='(\''+clientGrp+'-MSL\',\''+clientGrp+'-MCC\',\''+clientGrp+'-SGL\',\''+clientGrp+'-SEA\')';
                queryStr += 'AND Opportunity.Account.Attractiveness__c includes '+ clientGroup;
            } else if( clientGrp != '' && clientGrp != null) {           
                String clientGroup='(\''+Label.KC_MSL+'\',\''+Label.KC_SGL+'\',\''+Label.KC_MCC+'\',\''+Label.KC_SEA+'\')';
                queryStr += ' AND Opportunity.Account.Attractiveness__c excludes '+ clientGroup;
            }
        }
        else{
            List<String>customerGrpList = Label.Next100CustomerGrp.split(';');
            if(customerGrpList.size() > 0){
                String clientGroup = '(';
                for(String grpStr : customerGrpList){
                    clientGroup = clientGroup+'\''+grpStr+'\',';
                }
                clientGroup = clientGroup.removeEnd(',');
                clientGroup= clientGroup+')';
                system.debug('###### Cust Grp'+clientGroup);
                queryStr += ' AND Opportunity.Account.Attractiveness__c INCLUDES '+ clientGroup;
            }
        }              
        queryStr += ' LIMIT 500';
        
        system.debug(queryStr);
    
        List<OpportunityLineItem> optyListItem = Database.query( queryStr );
        system.debug('optyListItem '+optyListItem );
        for ( OpportunityLineItem recOLI : optyListItem ) {
            
            accIds.add ( recOLI.Opportunity.AccountId );
            
            if ( recOLI.Trade_Guidance_Id__c != null )
                corrIds.add( recOLI.Trade_Guidance_Id__c );
                        
        }
        
        Map<Id, Corridor_guidance__c> corrGuidanceMap = new Map<Id, Corridor_guidance__c> ([ SELECT id, Corridor_Guidance_Detail_Count__c FROM Corridor_guidance__c 
                                                                                                WHERE Corridor_Guidance_Detail_Count__c > 0 ]);
        
        // soql to get count for all corr guidance -- in a map

        
        for ( OpportunityLineItem recOLI : optyListItem ) {
            Boolean isTender = FALSE;
            String oppName='';
            
            // Replacing the Null of the fields with 0 or empty string - to avoid error while saving data from lightning controller  
            if(recOLi.Tender_Target__c == Null) {
                recOLi.Tender_Target__c = 0;
            }

            if(recOLi.Comments__c == Null) {
                recOLi.Comments__c = '';
            }

            //#RQ-007297 - Appended record type indication to opportunity name
            if(recOLI.Opportunity.recordTypeId == Label.OppTenderRecordTypeId) {
                system.debug(' ####[T]');
                oppName = recOLI.Opportunity.Name+' [T]';
                isTender =  TRUE;
            }
            else{
                oppName = recOLI.Opportunity.Name+'[QB]';
            }
            
            
            boolean corrGuidanceExists = false;
            if ( recOLI.Trade_Guidance_Id__c != null && corrGuidanceMap.containsKey(recOLI.Trade_Guidance_Id__c)) {
                corrGuidanceExists = true;
            }
            
            //#RQ-007297 - Added Opp name and isTender as parameters
            oliList.add( new 
            TenderOLIResponse.wrapperOLI_Rating ( recOLI, corrGuidanceExists, rowNum++ ,oppName, isTender));//wrapper list is used to display the oli and customer rating
        }   

        system.debug('OLI list to be returned'+oliList);
        return oliList;
    }
    
    // Method to save the records edited from Tender Target Page
    @AuraEnabled
    Public Static Boolean saveResults(List<OpportunityLineItem> updatedItems){       
        Boolean res = false;
        
        list<OpportunityLineItem> updateOLI = new list<OpportunityLineItem>();        
        for (OpportunityLineItem extOLI: updatedItems) {
            updateOLI.add(extOLI);
        }
       
        Schema.SObjectField f = OpportunityLineItem.Fields.Id;
           Database.SaveResult[] srList  = database.update(updateOLI,false); 
           for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully updated');
                res = true;
            }
            else {          
                for(Database.Error err : sr.getErrors()) {
                    System.debug('An error has occurred.'+ err);                    
                    res = false;
                } 
            }  
          } 
          // Return the result to Tender Target page
          return res;    
    }
}