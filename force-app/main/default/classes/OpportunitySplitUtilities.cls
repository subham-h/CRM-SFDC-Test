/*              
* Revision Ref Number      Date          Owner                           Description
* -------- ----------    -----------     -----------------             ----------------------------------------
* 1.0        RQ-012405     13-Nov-2019   Neha-TCS                       Utilities class validation for OpportunitySplitTrigger
* 1.1        RQ-012405     11-Nov-2019   meghana.gupta@ust-global.com   Method added to validate split creation/refresh
*/

public class OpportunitySplitUtilities {   
    
    public static void validateSplitrecordforOpportunities(list<OpportunitySplit> lstOpportunitySplit,List<Id> oppid, Set<Id> splitOwneridSet){
        
       
        Set<Id> setOpportunitiesIDs = new Set<id>();
        Set<Id> invalidOwnerIDSet = new Set<id>();
        for(OpportunitySplit oppSplit :[select id,OpportunityId,Opportunity.isClosed,SplitOwnerId, Opportunity.OwnerId,Opportunity.StageName from OpportunitySplit where Opportunityid in :oppid]){
                     
            if(Label.opptySplit_StageNotAllowed.containsIgnoreCase(oppSplit.Opportunity.StageName)){
                setOpportunitiesIDs.add(oppSplit.Opportunityid);
            }         
        }
       // Get the Opportunity Team Member with Sales Controbutor Role and Owner Role
        Map<id,OpportunityTeamMember> opportunityTeamMemberMap= new Map<ID, OpportunityTeamMember>([SELECT Id,Name,OpportunityId,UserId,TeamMemberRole FROM OpportunityTeamMember where  OpportunityId in : oppid and userId = : splitOwneridSet]);
        
        for(OpportunitySplit oppSplitObj : lstopportunitySplit ){
            boolean validTeamMeberfound = false;            
            if(opportunityTeamMemberMap.isEmpty()){
                validTeamMeberfound = true;
            }else{
                for(Id oppMemberId : opportunityTeamMemberMap.keySet()){                    
                    String TeamMemberRoleStr = opportunityTeamMemberMap.get(oppMemberId).TeamMemberRole;
                    Set<String> OpptyTeamMemberRoleAllowedforSplitSet = new Set<String> (Label.OpptyTeamMemberRoleAllowedforSplit.split(';'));
                                      
                    if(OpptyTeamMemberRoleAllowedforSplitSet.contains(TeamMemberRoleStr) && oppSplitObj.OpportunityId == opportunityTeamMemberMap.get(oppMemberId).OpportunityId &&  String.valueOf(oppSplitObj.SplitOwnerId).equalsIgnoreCase(String.valueOf(opportunityTeamMemberMap.get(oppMemberId).userId))){                      
                        validTeamMeberfound = true;
                        break;
                    }
                }
            }
            // Invalid User Role which is not Sales Contributors
            if(!validTeamMeberfound){
                invalidOwnerIDSet.add(oppSplitObj.SplitOwnerId);
            }
            
            if(invalidOwnerIDSet.contains(oppSplitObj.SplitOwnerId)){                
                oppSplitObj.addError(Label.opportunitySplitTeamMemberRoleError);
            }           
            if(setOpportunitiesIDs.contains(oppSplitObj.Opportunityid)){                
                oppSplitObj.addError(Label.OpportunitySPlitStageError);
            }
            
        }   
    }
    
    // method to do validations before actual split creation
    public static List<String> validateOpportunitySplitCreation(Opportunity recOppty, List<OpportunityLineItem> lstOpptyProducts){
        
        List<String> lstErrorMessages = new List<String>();
        
        // if opportunity is still in Identifying stage Or Closed  then do not allow splits
        Set<String> setStagesNotAllowed = new Set<String>(Label.opptySplit_StageNotAllowed.split(';')); // Identifying or Closed       
        if (setStagesNotAllowed.contains(recOppty.StageName)){            
            lstErrorMessages.add(Label.OpportunitySPlitStageError);            
        } 
                
        // check if there is no L&S profit or Esitmated OCean FFE
        if (recOppty.Estimated_L_S_Product_Gross_Profit1__c == 0 && recOppty.Estimated_Ocean_FFE__c == 0){            
            lstErrorMessages.add(Label.opptySplit_ErrorNoProfitsToSplit);
        }
        
        // if there no ocean or L&S products
        if  (lstOpptyProducts.isEmpty()){
           lstErrorMessages.add(Label.opptySplit_ErrorNoOceanOrLSProducts);
        }  
        
        return lstErrorMessages;
    }
    
    // Calculate the dates based on Opportunity shipment dates.
    public static List<Date> calculateScheduleDates ( Date FirstDate, Date LastDate)  {
        
        List<Date> lstDates = New List<Date>();
        
        Date scheduleDate = FirstDate;        
        if( scheduleDate.day() != 1 )
            scheduleDate = Date.NewInstance(scheduleDate.year(), scheduleDate.month(), 1);
        
        if( LastDate !=null ) {
            
            for ( Integer count = 1; count <= FirstDate.monthsBetween(LastDate); count++){                
                lstDates.add(scheduleDate);
                scheduleDate = scheduleDate.addMonths(1);                
            }
            
            lstDates.add(LastDate);
        }            
        return lstDates;            
    }
}