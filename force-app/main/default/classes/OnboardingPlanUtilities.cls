/*
* Utilities class for Onboarding Plan.
* 
*Vesrion Date         Owner                                     Description
************************************************************************************************
Ranjini.Janardhanan@ust-global.com
* 1.0    20/10/2014   Madhava.Kotte@ust-global.com              Code created as part of #PR-0028.
* 2.0    12/02/2014   Ranjini.Janardhanan@ust-global.com        Updated as part of #SP-0007.
* 3.0    28/12/2016   Abby.Abraham@ust-global.com               RQ-004392-Introduced CBO Architecture
*/

public class OnboardingPlanUtilities{
    
/*
* #SP-0007/RQ-000573. 
* Method to lock Onboarding Plan and its corresponding New Hire Modules and Assignments 
* when Onboarding plan cancelled..... 
* Same method is been used in both before and after events.
*/
    
    public static void lockOnboardingPlan(List<Onboarding_Plan__c> oldList, List<Onboarding_Plan__c> newList, String triggerEvent){
        
        List <Id> nhmIdList = new List <Id>();
        List <New_Hire_Module__c> nhmList = new List <New_Hire_Module__c> ();
        List <New_Hire_Assignments__c> nhaList = new List <New_Hire_Assignments__c> ();
        List <Id> opIds =  new List <Id>() ;
        
        if(oldList!=null){
            
            for(Integer i=0; i<newList.size();i++){
                
                if(newList[i].status__c != oldList[i].status__c && newList[i].status__c == 'Cancelled'){
                    
                    opIds.add(newList[i].Id);
                    
                    if(triggerEvent == 'isBefore')// Onboarding plan Record type will be updated in the before event.
                        newList[i].RecordTypeId = Label.Onboarding_Plan_Read_Only_Record_Type;
                }
                
            }
            
        }
        
        
        //New Hire modules and New Hire assignemnets will be updated in the after event.
        if(triggerEvent == 'isAfter'){ 
            
            for(New_Hire_Module__c nhm : [SELECT Id, Name, Status__c, Is_Completed__c, Onboarding_Plan__c, RecordTypeId FROM New_Hire_Module__c WHERE Onboarding_Plan__c IN :opIds ]){
                
                if(nhm.Is_Completed__c == false)
                    nhm.status__c = 'Cancelled'; // Modules which are not in Completed status will be cancelled.
                nhm.RecordTypeId = Label.New_Hire_Module_Read_Only_Record_Type;
                nhmIdList.add(nhm.Id);
                nhmList.add(nhm);
            }
            
            if(nhmIdList.size()>0){
                
                for(New_Hire_Assignments__c nha : [SELECT Id, Name, Is_Completed__c, Status__c, New_Hire_Module__c, RecordTypeId FROM New_Hire_Assignments__c WHERE New_Hire_Module__c IN :nhmIdList] ){
                    
                    if(nha.Is_Completed__c == false)
                        nha.status__c = 'Cancelled';// Assignments which are not in Completed status will be cancelled.
                    nha.RecordTypeId = Label.New_Hire_Assignment_Read_Only_Record_Type;
                    nhaList.add(nha);
                    
                }
            }
            
            try{
                
                Database.update(nhaList, false);
                Database.update(nhmList, false);
            
            }Catch (Exception e){
                
                System.debug('##### Exception in lockOnboardingPlan method : '+e.getMessage());
            
            }
            
            
        }
        
        
    }
    
    
    
/*
*Method to update the NewHire as the owner of the onboarding plan  
*/         
    
    public static void updateOwner(List<Onboarding_Plan__c> oldList, List<Onboarding_Plan__c> newList){
        
        for(Integer i = 0; i < newList.size(); i++){
            
            if(oldList == null && newList[i].New_Hire__c != null){
                
                newList[i].ownerId = newList[i].New_Hire__c;//Assigns newhire as the owner during onboarding plan creation
                
            }else{
                
                //If newhire is updated the NEW newhire will be assigned as the owner of the onboarding plan. 
                newList[i].ownerId = newList[i].New_Hire__c; 
                
            }
            
        }
        
    }
    
    
    
/*
* method to add/remove sharing to the old/new onboarder.
* When onboarding plan is created, onboarder will get the access to the plan.
* When onboarder is updated in a plan, Old onboarder share will be deleted and New onboarder share will be created.
*/
    
    public static void onboarderShare(List<Onboarding_Plan__c> oldList, List<Onboarding_Plan__c> newList){
        
        List <Onboarding_Plan__Share> oPShareListToCreate = new List <Onboarding_Plan__Share> ();//new share list to be created.
        List <Onboarding_Plan__Share> oPShareListToDelete = new List <Onboarding_Plan__Share> ();//old share list to be deleted.       
        Map <Id,Id> obPlanOnboarderMap = new Map <Id,Id>();       
        
        for(Integer i = 0; i<newList.size(); i++){
            
            if( (oldList == null && newList[i].Onboarder__c != null) 
               || (oldList != null && newList[i].Onboarder__c != oldList[i].Onboarder__c))
            {                   
                
                Onboarding_Plan__Share opShare = new Onboarding_Plan__Share ();
                opShare.ParentId = newList[i].Id;
                opShare.UserOrGroupId = newList[i].Onboarder__c;
                opShare.RowCause = Schema.Onboarding_Plan__Share.RowCause.Onboarder_Access__c;
                opShare.AccessLevel = 'Edit';
                oPShareListToCreate.add(opShare);  
                
                if(oldList != null && newList[i].Onboarder__c != oldList[i].Onboarder__c){   
                    
                    obPlanOnboarderMap.put(newList[i].Id, newList[i].Onboarder__c );
                    
                }
                
            }
            
        }
        
        if(obPlanOnboarderMap.size() > 0){
            
            oPShareListToDelete =  [SELECT Id, ParentId, UserOrGroupId, RowCause
                                    FROM Onboarding_Plan__Share
                                    WHERE ParentId IN: obPlanOnboarderMap.keySet() AND RowCause =: Schema.Onboarding_Plan__Share.RowCause.Onboarder_Access__c];
            
        }
        
        System.debug('##### oPShareListToDelete :'+oPShareListToDelete);
        System.debug('##### oPShareListToCreate :'+oPShareListToCreate);
        
        try{
            
            if(oPShareListToDelete.size()>0)
                
                Database.delete(oPShareListToDelete,false); //delete apex share
            
            if(oPShareListToCreate.size()>0)
                
                Database.insert(oPShareListToCreate); //create apex share
            
        }Catch (Exception e){
            
            System.debug('##### Exception in onboarderShare method :'+e);
            
        }
        
        if(obPlanOnboarderMap.size()>0)
            
            updateOnboarderEmail(obPlanOnboarderMap);
        
    }
    
    
    
/*
* This method updates the onboarder email in new hire modules 
* when onboarder in onboarding plan is updated.
* Onboarder Email field is used in WF - Notify Onboarder When New Hire Module is due
*/        
    
    public static void updateOnboarderEmail (Map <Id,Id> obPlanOnboarderMap){
        
        list <User> userList = [SELECT Id, Name, email from User WHERE Id IN : obPlanOnboarderMap.values()];
        Map <Id,User> userIdMap = new Map <Id,User> (userList);
        List <New_Hire_Module__c> nhmList = new List <New_Hire_Module__c>();
        
        for(New_Hire_Module__c nhm : [SELECT Id, Name, Onboarder_Email__c, Onboarding_Plan__c from New_Hire_Module__c WHERE Onboarding_Plan__c IN : obPlanOnboarderMap.keySet()]){
            
            nhm.Onboarder_Email__c = userIdMap.get(obPlanOnboarderMap.get(nhm.Onboarding_Plan__c)).email;
            nhmList.add(nhm);
            
        }
        
        try{
            
            if(nhmList.size()>0)
                
                Database.update(nhmList,false);
            
        }catch (Exception e){
            
            System.debug('##### Exception in updateOnboarderEmail :'+e);
            
        }
        
    }
    
    
    
/**
*Method to set the status of onboarding plan as 'Onboarded' when all the new hire modules are completed
*/    
    
    public static void updateOnboardStatus(List<Onboarding_Plan__c>  newList, List<Onboarding_Plan__c> oldList){
        
        
        for(Integer i = 0; i < newList.size(); i++){
            
            if( newList[i].Enrolled_Or_Onboarded__c == 0 && (newList[i].Is_Enrolled__c == TRUE || newList[i].Is_Onboarded__c == TRUE) )
                
                newList[i].adderror(Label.StatusCannotSetToBeManually);
            
            if( newList[i].Enrolled_Or_Onboarded__c == 1 && (newList[i].Is_Ready__c == TRUE || newList[i].Is_Onboarded__c == TRUE ))
                
                newList[i].adderror(Label.EnrolledPlan);
            
            else if( newList[i].Enrolled_Or_Onboarded__c == 1 && (newList[i].Count_Of_Hire_Modules__c != newList[i].Count_Of_Completed_Modules__c) && newList[i].Is_Onboarded__c == TRUE )
                
                newList[i].adderror(Label.HireModulesNotCompleted);
            
            if(newList[i].Enrolled_Or_Onboarded__c != 2){
                
                if( newList[i].Count_Of_Hire_Modules__c == newList[i].Count_Of_Completed_Modules__c &&  newList[i].Count_Of_Hire_Modules__c > 0){
                    
                    newList[i].Enrolled_Or_Onboarded__c = 2;
                    newList[i].Status__c = 'Onboarded';
                    
                }
                
            }
            
            if( newList[i].Enrolled_Or_Onboarded__c == 2 && (newList[i].Is_Ready__c == TRUE || newList[i].Is_Cancelled__c == TRUE) )
                
                newList[i].adderror(Label.OnboardedPlan);
            
            
            if( newList[i].Enrolled_Or_Onboarded__c == 2 && (newList[i].Count_Of_Hire_Modules__c != newList[i].Count_Of_Completed_Modules__c )){
                
                newList[i].Enrolled_Or_Onboarded__c = 1;
                newList[i].Status__c = 'Enrolled';
            }
            
        }
        
    }
    
    
    
    
/**
*Method to update the end date of modules         
*/
    
    public static void updateModuleCompletionDate(List<Onboarding_Plan__c> oldList,List<Onboarding_Plan__c> newList){
        
        Set<Id> onbPlanid=new Set<Id>();
        Date onbPrgmStartDate;
        
        for(Integer i = 0;i < newList.size();i++){
            
            if( (newList[i].Status__c != oldList[i].Status__c) && newList[i].Status__c == 'Enrolled' || 
               (newList[i].Start_Date__c != oldList[i].Start_Date__c)) { // #SP-0007/#RQ-000587 . Start date can be updated even the Onb Plan is in Enrolled status
                   
                   onbPlanid.add(newList[i].id);
                   
               }
        }
        
        Map<Id,List<New_Hire_Module__c>> moduleIdPlanMap =  new Map<Id,List<New_Hire_Module__c>>();
        
        for(New_Hire_Module__c nh : [SELECT Id, name, Duration__c, Onboarding_Plan__c, Order__c, Start_Date__c, Target_Completion_Date__c 
                                     FROM New_Hire_Module__c 
                                     WHERE Onboarding_Plan__c IN: onbPlanid ORDER BY Order__c ASC]){
                                         
                                         if(moduleIdPlanMap.containsKey(nh.Onboarding_Plan__c)){
                                             
                                             moduleIdPlanMap.get(nh.Onboarding_Plan__c).add(nh);
                                             
                                         }else{
                                             
                                             moduleIdPlanMap.Put(nh.Onboarding_Plan__c, new List<New_Hire_Module__c>{nh}); 
                                             
                                         }
                                         
                                     }
        
        List<New_Hire_Module__c> updMdlLst = new List<New_Hire_Module__c >();
        
        for(Onboarding_Plan__c onbPln : newList){
            
            if(onbPln.Start_Date__c != null)
                onbPrgmStartDate = onbPln.Start_Date__c;
            
            system.debug('##### onbPrgmStartDate'+onbPrgmStartDate);
            
            if(moduleIdPlanMap.ContainsKey(onbPln.id) && onbPrgmStartDate !=Null ){
                
                for(New_Hire_Module__c nhm : moduleIdPlanMap.get(onbPln.id)){
                    
                    if(nhm.Duration__c != Null){
                        
                        nhm.Start_Date__c = onbPrgmStartDate;
                        nhm.Target_Completion_Date__c = (nhm.Start_Date__c + Integer.ValueOf(nhm.Duration__c)) - 1;
                        onbPrgmStartDate = nhm.Target_Completion_Date__c + 1;                    
                        updMdlLst.add(nhm);
                        
                    }
                    
                }
                
            }
            
        }
        system.debug('##### updMdlLst'+updMdlLst);
        
        try{
            
            if(updMdlLst.size()>0){
                
                Database.update(updMdlLst,false);
                
            }
            
        }catch(Exception e){
            
            
        }
        
    }
    
}