/*      
 * Revision Ref Number  Date             Owner                                Description
 * -------- ----------  -----------    -------------------                 -------------------------
 * 1.0      #RQ-012405   11-Nov-2019     meghana.gupta@ust-global.com        code created 
 * 1.1      #RQ-012348   11-Nov-2019     amritesh.sahu@maersk.com            add logic to split profit to sales contributors based on executing country  
 * 2.0      #RQ-012406   21-Nov-2019     meghana.gupta@ust-global.com        add logic to create split schedules    
 */

public without sharing class opportunitySplitCntrl {
    
    //wrapper class to pass response to LWC
    public class responseWrapper {
        @AuraEnabled public boolean isSuccess {get;set;} 
        @AuraEnabled public List<String> lstMessages {get;set;} 
        @AuraEnabled public Opportunity recOpportunity {get;set;} 
        
        public responseWrapper(){
            lstMessages = new List<String>();
            isSuccess = false;
        }        
    }
    
    @AuraEnabled 
    public static responseWrapper createOpportunitySplits(Id opptyId){
         
        List<String> lstTeamRoles = Label.OpptyTeamMemberRoleAllowedforSplit.split(';');       
        responseWrapper response = new responseWrapper();
        
        //get Opportunity details
        response.recOpportunity = [SELECT Id, Name, StageName, OwnerId, Estimated_L_S_Product_Gross_Profit1__c, Estimated_Ocean_FFE__c,  First_Shipment_Date__c, Last_Shipment_Date__c
                                   FROM Opportunity WHERE Id = :opptyId];
        
        // get opportunity product details to check if opportunity has ocean or L&S products
        List<OpportunityLineItem> lstOpptyProducts = [SELECT Id, L_S_Product__c,Product_Family__c, Country__r.Name,TotalPrice
                                                      FROM OpportunityLineItem 
                                                      WHERE OpportunityId = :opptyId AND (L_S_Product__c = true OR Product_Family__c = 'Ocean')];
        
        // get opportunity team list for owner and sales contributors
        List<OpportunityTeamMember> lstTeam = [SELECT Id, TeamMemberRole, UserId, User.Country FROM OpportunityTeamMember 
                                               WHERE OpportunityId = :opptyId AND TeamMemberRole in :lstTeamRoles];
                   
        // validate different pre-requisties before creating splits        
        response.lstMessages = OpportunitySplitUtilities.validateOpportunitySplitCreation(response.recOpportunity, lstOpptyProducts);
        
         // get split type id
        OpportunitySplitType recSplitType = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
      
        // if no errros as of now in creating splits then proceed
        if (response.lstMessages.isEmpty()){
            response.lstMessages.addAll(createSplits(response.recOpportunity, lstOpptyProducts, lstTeam, recSplitType.Id));           
        }
                
        // if no error in creating splits, continue with creation of split schedules
        if (response.lstMessages.isEmpty()){            
            response.lstMessages.addAll(createSplitSchedules(response.recOpportunity, recSplitType.Id));
        }
        
        // if splits and split schedules created succesfully then show success message
        if (response.lstMessages.isEmpty()){
            response.lstMessages.add(Label.opptySplit_SuccessMessage);            
            response.isSuccess = true;
        }
        return response;
    }
    
    // method to create opportunity splits
    public static List<String> createSplits(Opportunity recOppty, List<OpportunityLineItem> lstOpptyProducts, List<OpportunityTeamMember> lstTeam, Id splitTypeId){
        
        boolean hasLnSProduct = false; // set to true if opportunity has L&S products added
        boolean hasOceanProduct = false; // set to true if opportunity has ocean products added
        Map<Id, OpportunitySplit> mapUserToSplit = new Map<Id, OpportunitySplit>();
        List<OpportunitySplit> lstSplits = new List<OpportunitySplit>();
        OpportunitySplit recSplit;
    
        List<String> lstErrorMessages = new List<String>(); // list to store error messages
        Map<String, Decimal> mapCountry2GrossProfit = new Map<String, Decimal>(); // map of Country to L&S gross profit mapping
        
         // form a map of user's country to gross profit 
        for (OpportunityTeamMember recOTM : lstTeam){
            if(String.isNotBlank(recOTM.User.Country)) 
                mapCountry2GrossProfit.put(recOTM.User.Country.toLowerCase(), 0);
        }        
        
        // for each L&S product get the gross profit for each team member's country
        for (OpportunityLineItem recProd : lstOpptyProducts){
            
            if (recProd.L_S_Product__c) {
                hasLnSProduct = true;
                String strCountryName = recProd.Country__r.Name;
                if (String.isNotBlank(strCountryName)) {
                    strCountryName = strCountryName.toLowerCase();                    
                    if(mapCountry2GrossProfit.containsKey(strCountryName))                      
                        mapCountry2GrossProfit.put(strCountryName, mapCountry2GrossProfit.get(strCountryName) + recProd.TotalPrice);
                }
            }                
            else if( recProd.Product_Family__c == 'Ocean')
                hasOceanProduct = true;
        }
       
        //get existing split records to refresh, do not over-write Ocean split and uplift amount
        List<OpportunitySplit> lstExistinSplits = [SELECT Id, SplitOwnerId, SplitPercentage, Ocean_FFE_Split__c FROM OpportunitySplit 
                                                       WHERE OpportunityId  = :recOppty.Id and SplitTypeId = :splitTypeId];
                        
        for (OpportunitySplit recExistingSplit : lstExistinSplits){
            mapUserToSplit.put(recExistingSplit.SplitOwnerId, recExistingSplit);
        }
        
        // add sales contributors to splits
        for (OpportunityTeamMember recTeamMember : lstTeam) {
            
            // if splits already exists then get split record and reset amount and percent else create new records
            if (mapUserToSplit.containsKey( recTeamMember.UserId)){               
                recSplit = mapUserToSplit.remove( recTeamMember.UserId);  //remove sales contributors from map, any split record still in map after this loop needs to be deleted
            }
            else {
                recSplit = new OpportunitySplit();                
                recSplit.OpportunityId = recOppty.Id;
                recSplit.SplitTypeId = splitTypeId;                
                recSplit.SplitOwnerId = recTeamMember.UserId;   
                recSplit.Ocean_FFE_Split__c = 0;
            }

            if ( recTeamMember.TeamMemberRole == 'Opportunity Owner'){                   
                if (hasOceanProduct){
                    recSplit.Ocean_FFE_Split__c = recOppty.Estimated_Ocean_FFE__c;
                } 
                
                if (hasLnSProduct){
                    recSplit.SplitPercentage = 100;                            
                }
            } else {
                String userCountry = recTeamMember.User.Country;
                if (userCountry != '' && userCountry != null)
                    userCountry = userCountry.toLowerCase();
                
                // if we have L&S products in Opportunity then calcualte SPlitPercent for sales contributors
                if(hasLnSProduct && mapCountry2GrossProfit.containsKey(userCountry)) {
                    recSplit.SplitPercentage = (mapCountry2GrossProfit.get(userCountry) * 100)/recOppty.Estimated_L_S_Product_Gross_Profit1__c;
                }
                else
                    recSplit.SplitPercentage = 0; 
            }
            lstSplits.add(recSplit);
        }
        
        // upsert split list
        try{
            upsert lstSplits;                
        }catch(DmlException ex){
            lstErrorMessages.add(ex.getDmlMessage(0));
        }       
        
        // delete split records for users who are no longer owner or sales contributor
        if (lstErrorMessages.isEmpty() && ! mapUserToSplit.isEmpty()){
            try{
                delete mapUserToSplit.values();
            }catch(DmlException ex){
                lstErrorMessages.add(ex.getDmlMessage(0));
            }                  
        }
        
        return lstErrorMessages;
    }
    
    // method to create split schedules
    public static List<String> createSplitSchedules(Opportunity recOppty, Id splitTypeId){
        
        List<String> lstErrorMessages = new List<String>(); // list of error messages
        List<Opportunity_Splits_Schedule__c> lstSplitSchedules = new List<Opportunity_Splits_Schedule__c>(); //list of split schedules to insert       
        
        if (recOppty.First_Shipment_Date__c != null && recOppty.Last_Shipment_Date__c != null){
            
            // get duration between agreement start and end date and form list of dates for schedule months 
            List<Date> lstScheduleDates = OpportunitySplitUtilities.calculateScheduleDates(recOppty.First_Shipment_Date__c, recOppty.Last_Shipment_Date__c);
            integer intScheduleDuration = lstScheduleDates.size(); // agreement duraiton in months
            
            // get split records , in roder to create schedule for each split
            List<OpportunitySplit> lstExistinSplits = [SELECT Id, SplitOwnerId, SplitPercentage,SplitAmount, Ocean_FFE_Split__c, Uplift_Amount__c FROM OpportunitySplit 
                                                       WHERE OpportunityId  = :recOppty.Id and SplitTypeId = :splitTypeId];
            
            for (OpportunitySplit recExistingSplit : lstExistinSplits){
                
                integer intOceanSplit = 0;
                integer intPendingOceanSplit = 0;
                integer intLnSSplit = 0;
                Decimal intPendingLnSSplit = 0;
                Decimal intTotalLnSSplit = 0;
                
                // calculate ocean split per month
                if (recExistingSplit.Ocean_FFE_Split__c != null && recExistingSplit.Ocean_FFE_Split__c > 0){
                    
                    intOceanSplit = Integer.valueOf(recExistingSplit.Ocean_FFE_Split__c) / intScheduleDuration;  
                    intPendingOceanSplit = math.mod(Integer.valueOf(recExistingSplit.Ocean_FFE_Split__c), intScheduleDuration); // remainder FFE to be added to last month
                }
                
                if (recExistingSplit.SplitAmount != null)
                    intTotalLnSSplit = recExistingSplit.SplitAmount;
                
                if (recExistingSplit.Uplift_Amount__c != null)
                    intTotalLnSSplit = intTotalLnSSplit + recExistingSplit.Uplift_Amount__c;
                
                // calculate L&S split per month
                if ( intTotalLnSSplit > 0 ){
                    
                    intLnSSplit = Integer.valueOf(intTotalLnSSplit) / intScheduleDuration;  
                    intPendingLnSSplit = intTotalLnSSplit - (intLnSSplit * intScheduleDuration) ; // remainder amount to be added to last month
                }
                              
                if ( intOceanSplit > 0 || intLnSSplit > 0){
                    integer intLoopCounter = 0;
                    for (date dtScheduleDate : lstScheduleDates){
                        
                        intLoopCounter++;
                        Opportunity_Splits_Schedule__c recSplitSchedule = new Opportunity_Splits_Schedule__c();
                        recSplitSchedule.Opportunity__c = recOppty.Id;
                        recSplitSchedule.User__c = recExistingSplit.SplitOwnerId;
                        recSplitSchedule.Schedule_Date__c = dtScheduleDate;
                        
                        // for last month add remainder FFE/amount
                        if (intLoopCounter == intScheduleDuration){
                            
                            recSplitSchedule.Ocean_Split__c = intOceanSplit + intPendingOceanSplit;
                            recSplitSchedule.L_S_Split_Amount__c = intLnSSplit + intPendingLnSSplit;
                            
                        } else {
                            recSplitSchedule.Ocean_Split__c = intOceanSplit;
                            recSplitSchedule.L_S_Split_Amount__c = intLnSSplit;
                        }
                        
                        lstSplitSchedules.add(recSplitSchedule);
                    }        
                }
            }
            
            try{
                // delete existing split schedules
                List<Opportunity_Splits_Schedule__c> lstExistingSplitSchedules = [ SELECT Id FROM Opportunity_Splits_Schedule__c WHERE Opportunity__c = :recOppty.Id];
                delete lstExistingSplitSchedules;
                
                // create new split scheudle records
                insert lstSplitSchedules;
                
            } catch(DmlException ex){
                
                lstErrorMessages.add(ex.getDmlMessage(0));
            }   
        }
        return lstErrorMessages;
    }
  

}