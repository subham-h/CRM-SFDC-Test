/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
/*
 * 3.0			SFSE-12889		16-Oct-2023		Jothsana@maersk.com			To make OLI event publish queable
 * 4.0          SFSE-13638      30-Jan-2024     Samar@maersk.com	        Opportunity product revenue schedule
*/
public class GetSchedules {
    //Get Opportunity Product Schedules Avaialable 
    @AuraEnabled
    public static ScheduleWrapper getSchedules(Id recId) {   
        ScheduleWrapper schedulewrap = new ScheduleWrapper();

        List<Opportunity_Product_Schedule__c> oppProductSch = [SELECT Id,Opportunity_Product__r.Product2ID__r.Name,Schedule_Date__c,Revenue__c,Quantity__c,Description__c,Schedule_Revenue__c,Opportunity_Product__r.OpportunityID__r.StageName,Opportunity_Product__r.OpportunityId__r.Record_Locked__c,Opportunity_Product__r.OpportunityId__r.First_Shipment_Date__c
                                                               FROM Opportunity_Product_Schedule__c WHERE  Opportunity_Product__c =:recId order by Schedule_Date__c ];
        if(oppProductSch.size()>0){
            schedulewrap.isClosedOppty = oppProductSch[0].Opportunity_Product__r.OpportunityId__r.StageName == 'Closed Won' || oppProductSch[0].Opportunity_Product__r.OpportunityId__r.StageName == 'Closed Lost' ? true : false;
            schedulewrap.schedule = oppProductSch;
            schedulewrap.isOpptyLocked = oppProductSch[0].Opportunity_Product__r.OpportunityId__r.Record_Locked__c == true ? true : false;
            schedulewrap.isAgreementStartDateInPast =  oppProductSch[0].Opportunity_Product__r.OpportunityId__r.First_Shipment_Date__c < Date.Today() ? true : false;
        }else{
            Opportunity_Product__c opptyProd = [SELECT id, OpportunityID__r.StageName,OpportunityId__r.Record_Locked__c,OpportunityId__r.First_Shipment_Date__c FROM Opportunity_Product__c WHERE  Id =:recId ];
            schedulewrap.isClosedOppty = opptyProd.OpportunityId__r.StageName == 'Closed Won' || opptyProd.OpportunityId__r.StageName == 'Closed Lost' ? true : false;
            schedulewrap.schedule = null;
            schedulewrap.isOpptyLocked = opptyProd.OpportunityId__r.Record_Locked__c == true ? true : false;
            schedulewrap.isAgreementStartDateInPast = opptyProd.OpportunityId__r.First_Shipment_Date__c < Date.Today() ? true : false;
        }
        return schedulewrap;
    }
 
    @AuraEnabled
    public static string updateSchedules( string oppProdcutSch, Decimal totalQuantity,Id recId) {  
        string message = 'Success';
        System.debug('test'+totalQuantity);
        // SFSE - 13624 - Added bypass to skip the product revenue per unit validation on opportunity product update
        
        try{ 
            Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
            bt.Skip_Validation__c = true;
            insert bt;
            list<Opportunity_Product_Schedule__c> schList = (list<Opportunity_Product_Schedule__c>)JSON.deserialize(oppProdcutSch,list<Opportunity_Product_Schedule__c>.class);      
            
            Opportunity_Product__c oppProduct = [SELECT id,Quantity__c,UnitPrice__c,OpportunityId__c,Total_Price__c,OpportunityId__r.StageName,Product_Revenue_Per_Unit__c FROM Opportunity_Product__c WHERE id =:recId];
            
            Opportunity_Product__c oppProductToUpdate = new Opportunity_Product__c();
            oppProductToUpdate.id= oppProduct.id;
            oppProductToUpdate.Quantity__c = totalQuantity;
                
            for(Opportunity_Product_Schedule__c ps:schList){
                if(oppProduct.UnitPrice__c != null){
                Decimal  updatedRevenue = ps.Quantity__c * oppProduct.UnitPrice__c;
                ps.Revenue__c = updatedRevenue;
                }else{
                    message = 'Please enter Gross Profit Per unit on opportunity product';
                }
                if(oppProduct.Product_Revenue_Per_Unit__c != null){
                    ps.Schedule_Revenue__c = ps.Quantity__c * oppProduct.Product_Revenue_Per_Unit__c;//SFSE-13638 
                }
            }

            Update schList;
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete btt;
 
        }catch(DMLException e){ 
            message = '';
            for(Integer i=0; i < e.getNumDml(); i++) {
                if((e.getDmlMessage(i).unescapeHtml4().indexOf('first error:'))<>-1){
                    message = message + e.getDmlMessage(i).unescapeHtml4() + '; ';
                    Integer firstErrorIndex = e.getDmlMessage(i).unescapeHtml4().indexOf('first error:');
                    Integer firstColonIndex = e.getDmlMessage(i).unescapeHtml4().indexOf(',', firstErrorIndex );
                    Integer secondColonIndex = e.getDmlMessage(i).unescapeHtml4().indexOf(':', firstColonIndex );
                    String errorMessage = e.getDmlMessage(i).unescapeHtml4().substring(firstColonIndex+1, secondColonIndex);
                    message=errorMessage;
                }else{
                    message = message + e.getDmlMessage(i).unescapeHtml4() + '; ';
                }
            }
           Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
           delete btt;
        }
 		system.debug('error message: '+message);
       return message;
    }

    @AuraEnabled
    public static list<Opportunity_Product__c> getProductDetails(Id recId) {   
       List<Opportunity_Product__c> OppProduct = [SELECT Id,Quantity__c ,OpportunityId__r.First_Shipment_Date__c,OpportunityId__r.Last_Shipment_Date__c  FROM Opportunity_Product__c WHERE  id =:recId ];
       return OppProduct;
    }

    

    @AuraEnabled
    public static string ReEstablishSchedule(  decimal totalQuantity,Id recId ,string scheduleTypeValue) {  
        string message = 'Success';
        Opportunity_Product__c oppProduct = [SELECT id,Quantity__c,UnitPrice__c,OpportunityId__c,Total_Price__c,OpportunityId__r.IsClosed,OpportunityId__r.IsWon ,OpportunityId__r.StageName,Product_Revenue_Per_Unit__c FROM Opportunity_Product__c WHERE id =:recId];
        Opportunity opp = [SELECT id,First_Shipment_Date__c,Last_Shipment_Date__c FROM Opportunity WHERE id =: oppProduct.OpportunityId__c];
        
        

        try{  
            // SFSE - 13624 - Added bypass to skip the product revenue per unit validation on opportunity product update
            Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
            bt.Skip_Validation__c = true;
            insert bt;
            List<Date> datelist = calculatedates(opp.First_Shipment_Date__c,opp.Last_Shipment_Date__c);
            if (scheduleTypeValue == 'Repeat'){
                oppProduct.Quantity__c = totalQuantity * datelist.size();
            }else{
                oppProduct.Quantity__c = totalQuantity;       
            }
            List<Opportunity_Product_Schedule__c> lineItemSchedule = new List<Opportunity_Product_Schedule__c>();
            if( opp != null && opp.First_Shipment_Date__c != null ){
                Decimal productQuantity = totalQuantity ;
                if( datelist != null && datelist.size()>0 ){  
                    lineItemSchedule.addAll(createScheduleRecords(oppProduct,datelist,productQuantity,scheduleTypeValue));
                }
            }   
       
            List<Opportunity_Product_Schedule__c> schedulesToDelete = [
                SELECT Id, Quantity__c
                FROM Opportunity_Product_Schedule__c
                WHERE Opportunity_Product__c =:recId
            ];
            Opportunity_Product__c OppProductQty = [SELECT id,Quantity__c,OpportunityId__r.IsClosed,OpportunityId__r.IsWon,OpportunityId__r.Record_Locked__c  FROM Opportunity_Product__c WHERE id =:recId];
            Boolean IsQuantityMismatchForWonOpp=false;
                
            /*if (OppProductQty.OpportunityId__r.IsClosed == true && OppProductQty.OpportunityId__r.Record_Locked__c == true && OppProductQty.OpportunityId__r.IsWon==true && OppProductQty.Quantity__c <>totalQuantity){
                IsQuantityMismatchForWonOpp=true;
            }*/

            if(IsQuantityMismatchForWonOpp ==false){
                Update oppProduct;
                delete schedulesToDelete;
                insert(lineItemSchedule);
              
                // fire OLIEvent on the re-establish Schedule
                if(!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled()){
                    OLIEventResponseHandler.fireQueableOliEventsAsync(new List<Id>{recId}, false, true, true,false);
                }else if(System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled()){
                    OLIEventResponseHandler.fireOliEventAsync(new List<Id>{recId}, false, true, true,false);
                }
            }/*else{
                message='Revised seasonality is not matching with closed won quantity/revenue - please ensure total quantity remains the same';
            }*/
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete btt;
        }catch(DMLException e){ 
            message = '';
            for(Integer i=0; i < e.getNumDml(); i++) {
                message = message + e.getDmlMessage(i).unescapeHtml4() + '; ';
            }
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete btt;
        }
        
       return message;
    } 

    public static List<Date> calculatedates(Date FirstDate, Date LastDate){
        List<Date> datelist = New List<Date>();
        Date d = FirstDate;
        if( d.day() != 1 )
            d = Date.NewInstance(d.year(),d.month(),1);
        
        if(LastDate !=null) {
            Integer count = 1;
            while( count <= FirstDate.monthsBetween(LastDate) )
            {
                datelist.add(d);
                d=d.addMonths(1);
                count++;
            }
            datelist.add(LastDate);   
        } else {
            Integer count = 1;
            while( count <= FirstDate.monthsBetween(FirstDate) )
            {
                datelist.add(d);
                d=d.addMonths(1);
                count++;
            }
            datelist.add(FirstDate);   
        }
        return datelist;            
    }

    public static List<Opportunity_Product_Schedule__c> createScheduleRecords( Opportunity_Product__c oli, List<Date> dateList, Decimal productQuantity,string scheduleTypeValue ){
        
        List<Opportunity_Product_Schedule__c> lineItemSchedule = new List<Opportunity_Product_Schedule__c>();
        Integer EfectiveDuration = datelist.size();
        Integer newQuantity ;
        Decimal lastQuantity;

        if(scheduleTypeValue == 'Repeat'){
            newQuantity = Integer.ValueOf(productQuantity);          
            lastQuantity = 0;
        }
        else{
            newQuantity = Integer.ValueOf(productQuantity)/EfectiveDuration;          
            lastQuantity = math.mod(Integer.ValueOf(productQuantity),EfectiveDuration);
        }
        
        // Prepare list of product scheduled based on datelist.
        for(Integer count=1; count<=EfectiveDuration; count++){
            //system.debug('entered for loop' );
            Opportunity_Product_Schedule__c lNewOpportunityLISchedule = new Opportunity_Product_Schedule__c();
            if (count == EfectiveDuration){
                lNewOpportunityLISchedule.Quantity__c = newQuantity + lastQuantity;
                lNewOpportunityLISchedule.Revenue__c = oli.UnitPrice__c != null ? oli.UnitPrice__c * (newQuantity + lastQuantity): null; //RQ-010441 - Mod-04 - Revenue calculation
                //system.debug('lNewOpportunityLISchedule.Quantity' + lNewOpportunityLISchedule.Quantity__c);
                lNewOpportunityLISchedule.Schedule_Revenue__c = oli.Product_Revenue_Per_Unit__c != null ? oli.Product_Revenue_Per_Unit__c * (newQuantity + lastQuantity): null;//SFSE-13638 
            } else {
                lNewOpportunityLISchedule.Quantity__c = newQuantity;
                lNewOpportunityLISchedule.Revenue__c =  oli.UnitPrice__c != null ? oli.UnitPrice__c * newQuantity : null; //RQ-010441 - Mod-05 - Revenue calculation
                //system.debug('lNewOpportunityLISchedule.Quantity' + lNewOpportunityLISchedule.Quantity__c);
                lNewOpportunityLISchedule.Schedule_Revenue__c = oli.Product_Revenue_Per_Unit__c != null ? oli.Product_Revenue_Per_Unit__c * newQuantity: null;//SFSE-13638 
            }
            //System.debug('datelist.get(count)'+count+'  '+datelist.get(count -1));
            lNewOpportunityLISchedule.Opportunity_Product__c = oli.Id;
            //System.debug('datelist.get(count)-->>'+count+'  '+datelist.get(count -1));
            lNewOpportunityLISchedule.Schedule_Date__c = datelist.get(count -1);
            lNewOpportunityLISchedule.Type__c = 'Both'; //RQ-010441 - Mod-06 - Changed type FROM 'Quantity' to 'Both' to accomodate Quantity and Revenue scheduling
            if( lNewOpportunityLISchedule.Quantity__c != 0 ){
                lineItemSchedule.add(lNewOpportunityLISchedule);
            }      
        }

        System.debug('lineItemSchedule '+lineItemSchedule.size());
        return lineItemSchedule; 
    }

    public class scheduleWrapper{
        @AuraEnabled
        public Boolean isClosedOppty {get;set;}
        @AuraEnabled
        public Boolean isOpptyLocked {get;set;}
        @AuraEnabled
        public List<Opportunity_Product_Schedule__c> schedule {get;set;}
        @AuraEnabled
        public Boolean isAgreementStartDateInPast {get;set;}  
    }
 
 }