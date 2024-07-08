/*<!--  

Revision    Owner                                     Date                RQ#                 Comments                 

* 1.0      Abhinav@maersk                             21.11.2019          #SFSE-1128          Identify related opportunities, Test Class "opportunityHierarchyCls_Test" 

* 2.0      Seba@Maersk                                11.03.2024          SFSE-13935          Display at least 5 parents and 5 children from hierarchy 

-->*/ 

public with sharing class opportunityHierarchyCls {   
    
    @AuraEnabled  
    
    public static  List<OpportunityWrapper> getChildOpportunities(String opportunityId) {  
        
        List<OpportunityWrapper> finalWrapperList = new List<OpportunityWrapper>();   
        Map<Id,OpportunityWrapper> mapFinalOpportunityWrapper = new Map<Id,OpportunityWrapper>();  
        String topOppParentId =''; //Max till top 5th parent can be here     
        String topOppParentName =''; //Max till top 5th parent can be here 
        OpportunityWrapper oppParentWraper; //Holds the topmost parent wrapper  
        Set<Id> childOppsOfCurrentOpp = new Set<Id>();  
        List<Opportunity> lstMissedOpps = new List<Opportunity>();//Since we do not have guarantee in the order SOQL returns record  
        Set<Id> setOppIds = new Set<Id>(); //To ensure duplicate opportunities are skipped 
        
        try{
            //Get current opportunity's children and find the topmost parent in current opportunity's hierarchy   
            for(Opportunity childOrCurrentOpp : [SELECT Id, Name, Parent_Opportunity__c,Parent_Opportunity__r.Parent_Opportunity__c,  
                                                 
                                                 Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c, 
                                                 
                                                 Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c, 
                                                 
                                                 Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c, 
                                                 
                                                 Parent_Opportunity__r.Name, 
                                                 
                                                 Parent_Opportunity__r.Parent_Opportunity__r.Name,  
                                                 
                                                 Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Name, 
                                                 
                                                 Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Name, 
                                                 
                                                 Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Name  
                                                 
                                                 FROM Opportunity WHERE   
                                                 
                                                 (Parent_Opportunity__c = :opportunityId) OR   
                                                 
                                                 (Parent_Opportunity__r.Parent_Opportunity__c  = :opportunityId) OR   
                                                 
                                                 (Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c = :opportunityId) OR   
                                                 
                                                 (Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c = :opportunityId) OR 
                                                 
                                                 (Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c = :opportunityId) OR
                                                 
                                                 (Id = :opportunityId)]){ 
                                                     
                                                     //If it is child of current Opp, add it to list
                                                     if(childOrCurrentOpp.Id != opportunityId){
                                                         childOppsOfCurrentOpp.add(childOrCurrentOpp.Id);  
                                                     }else if(childOrCurrentOpp.Id == opportunityId){
                                                         //If it is the current opportunity, find the topmost parent in the hierarchy. There can be max 5 parents queried 
                                                         
                                                         //If top fifth parent is available for current opportunity
                                                         if(childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c != null){  
                                                             topOppParentId = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c; 
                                                             topOppParentName = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Name;
                                                         }else if(childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c != null){  
                                                             //If top fourth parent is available for current opportunity
                                                             topOppParentId = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c; 
                                                             topOppParentName = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Name;
                                                         }else if(childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c != null){  
                                                             //If top third parent is available for current opportunity
                                                             topOppParentId = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c; 
                                                             topOppParentName = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Name;
                                                         }else if(childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__c != null){  
                                                             //If top third parent is available for current opportunity
                                                             topOppParentId = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__c; 
                                                             topOppParentName = childOrCurrentOpp.Parent_Opportunity__r.Parent_Opportunity__r.Name;
                                                         }else if(childOrCurrentOpp.Parent_Opportunity__c != null){  
                                                             //If only one parent is available for current opportunity
                                                             topOppParentId = childOrCurrentOpp.Parent_Opportunity__c;
                                                             topOppParentName = childOrCurrentOpp.Parent_Opportunity__r.Name;
                                                         }else{//Current opportunity is the parent  
                                                             topOppParentId = childOrCurrentOpp.Id; 
                                                             topOppParentName = childOrCurrentOpp.Name;
                                                         }  
                                                     } 
                                                     
                                                 }
            
            oppParentWraper = new OpportunityWrapper(topOppParentId, topOppParentName, true, new List<OpportunityWrapper>(), opportunityId); 
            
            mapFinalOpportunityWrapper.put(topOppParentId,oppParentWraper);  
            
            
            //Get the opporturtunities down the hierarchy from top opp - till 5 levels below as allowed by SOQL 
            for(Opportunity opp : [SELECT Id, Name, Parent_Opportunity__c,Parent_Opportunity__r.Parent_Opportunity__c,  
                                   
                                   Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c, 
                                   
                                   Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c, 
                                   
                                   Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c, 
                                   
                                   Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c 
                                   
                                   FROM Opportunity WHERE 
                                   
                                   (Parent_Opportunity__c = :topOppParentId) OR   
                                   
                                   (Parent_Opportunity__r.Parent_Opportunity__c  = :topOppParentId) OR   
                                   
                                   (Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c = :topOppParentId) OR 
                                   
                                   (Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c = :topOppParentId) OR 
                                   
                                   (Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__r.Parent_Opportunity__c = :topOppParentId)  
                                   
                                   OR 
                                   
                                   Id IN :childOppsOfCurrentOpp]){    
                                       
                                       
                                       if(!setOppIds.contains(opp.Id)){
                                           
                                           List<OpportunityWrapper> childWrapperLst = new List<OpportunityWrapper>();   
                                           
                                           if(mapFinalOpportunityWrapper.containsKey(opp.Parent_Opportunity__c)){  
                                               
                                               mapFinalOpportunityWrapper.get(opp.Parent_Opportunity__c).items.add(new OpportunityWrapper(opp.Id, opp.Name, false, childWrapperLst , opportunityId)); 
                                               
                                           }else{
                                               
                                               //Since there is no guarantee in the order SOQL returns the records
                                               //If child opportunity comes before parent is added in the map
                                               lstMissedOpps.add(opp); 
                                           }  
                                           
                                           mapFinalOpportunityWrapper.put(opp.Id,new OpportunityWrapper(opp.Id, opp.Name, false, childWrapperLst, opportunityId)); 
                                           
                                       }
                                       
                                       
                                       setOppIds.add(opp.Id);
                                   }  
             
            for(Opportunity missedOpp: lstMissedOpps){  
                
                List<OpportunityWrapper> childWrapperLst = new List<OpportunityWrapper>(); 
                
                childWrapperLst = mapFinalOpportunityWrapper.get(missedOpp.Id).items; 
                
                if(mapFinalOpportunityWrapper.containsKey(missedOpp.Parent_Opportunity__c)){ 
                    
                    mapFinalOpportunityWrapper.get(missedOpp.Parent_Opportunity__c).items.add(new OpportunityWrapper(missedOpp.Id, missedOpp.Name, false, childWrapperLst , opportunityId)); 
                } 
                
            } 
            
            finalWrapperList.add(mapFinalOpportunityWrapper.get(topOppParentId));      
            
        }catch(Exception e){
            
            system.debug('Exception thrown: '+e);
            return null; 
        }
        return finalWrapperList;
    } 
    
    
    
    public Class OpportunityWrapper{ 
        
        @AuraEnabled 
        
        public String name{get;set;} 
        
        @AuraEnabled 
        
        public String label{get;set;} 
        
        @AuraEnabled 
        
        public Boolean expanded{get;set;} 
        
        @AuraEnabled 
        
        public List<OpportunityWrapper> items{get;set;} //children 
        
        
        
        public OpportunityWrapper(Id oppRecId, String oppName, Boolean isNodeExpanded, List<OpportunityWrapper> lstchildWrapper, Id currentOpportunityId){ 
            
            this.name =  oppRecId; 
            
            this.label = oppRecId !=  currentOpportunityId ? oppName : '(Current) '+ oppName; 
            
            this.expanded = isNodeExpanded; 
            
            this.items = lstchildWrapper; 
            
        }  
        
    }    
    
}