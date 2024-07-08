/*
* Trigger Handler class called by the single Object trigger on Onboarding Plan.
* 
*Vesrion Date         Owner                                     Description
************************************************************************************************
                      
* 1.0    03/10/2014   Jagadeesan.Sakthivel@ust-global.com       Code created as part of #PR-0028.                     
*/
public class AssignmentContentTriggerHandler{
    
    
 
    /*
     * Methid called on Affter Insert event for Assignment Content. 
     */     
    public static void onAfterInsert( Map <Id,Assignmen_Content__c> newMap, List <Assignmen_Content__c> newList){
    
        addNewHireContent(newMap.keyset(),newList);
        
    }
    
   
    
    /*
     * When a new Assignment Content is added to a Module Assignment,
     * It has to be propagated to the program Content and the New Hire content.
     */    
    public static void addNewHireContent(Set <Id> idSet, List <Assignmen_Content__c> newList){      
       
        Set <Id> assignmentId = new Set <Id>();        
        Map<Id, List<Assignmen_Content__c>> mapOfAsgnConIdToLstAsgnCon = new Map<Id, List<Assignmen_Content__c>>();
        List <Id> allAssignmentId = new List<Id>(assignmentId);        
        Map<Id,Id> mapOfPrgAsgnIdToModAsgnId = new Map<Id,Id>();
        Map<Id,List<Program_Assignment__c>> mapOfPrgModIDToPrdAssLst = new Map<Id,List<Program_Assignment__c>>();
        
        //For creating Map of Module Assignemnt Id and List of Assignment Contents from the newly created contents.
        for(Assignmen_Content__c ac : newList){
        
            assignmentId.add(ac.Module_Assignment__c);            
            if( mapOfAsgnConIdToLstAsgnCon.get(ac.Module_Assignment__c) == null ){
            
                List<Assignmen_Content__c> asgnConList = new List<Assignmen_Content__c>();
                asgnConList.add(ac);
                mapOfAsgnConIdToLstAsgnCon.put(ac.Module_Assignment__c,asgnConList);
                
            }else{
            
                mapOfAsgnConIdToLstAsgnCon.get(ac.Module_Assignment__c).add(ac);                
            }
            
        }
        
       
        /*creating map of program module id and module assignemnt id.
         *This will help add Program Contents to the required Program Assignemnts.
         */
        for (Program_Assignment__c pgma : [SELECT Id, Module_Assignment__c, Onboarding_Program__c 
                                           FROM Program_Assignment__c 
                                           WHERE Module_Assignment__c IN : assignmentId]){
        
            allAssignmentId.add(pgma.Id);
            mapOfPrgAsgnIdToModAsgnId.put(pgma.Id,pgma.Module_Assignment__c);
            
            if( mapOfPrgModIDToPrdAssLst.get(pgma.Module_Assignment__c) == null ){
                
                List<Program_Assignment__c> prgAssLst = new List<Program_Assignment__c>();
                prgAssLst.add(pgma);
                mapOfPrgModIDToPrdAssLst.put( pgma.Module_Assignment__c,prgAssLst );
            
            }else{
                
                mapOfPrgModIDToPrdAssLst.get( pgma.Module_Assignment__c).add(pgma);
            
            }
           
        }
        
        
        /*
         * In New Hire Assignemnts we are storing either Assignment Id or program Assignemnt Id in a Text field.
         * So the id list needs to be converted to string list.
         */
        List <String> idStringList = new List <String>();        
        for(Id i : allAssignmentId){
            idStringList.add(String.valueOf(i));
        }        
        for(Id i : assignmentId){
            idStringList.add(String.valueOf(i));
        }        
        System.debug('##### allAssignmentId'+allAssignmentId);
        System.debug('##### idStringList'+idStringList);
        
        
        /*
         * Creating list of program content list and new hire contents list to be created. 
         */        
        List <New_Hire_Content__c> nhcListToCreate = new List <New_Hire_Content__c>();
        List<Program_Content__c> prgAssLstToCreate = new List<Program_Content__c>();
        Map<Id,List<New_Hire_Assignments__c>> mapOfModuleAssignIdToLstNewHireAssign = new Map<Id,List<New_Hire_Assignments__c>>();
        
        for(New_Hire_Assignments__c nha : [SELECT Id, Assignment_OR_Program_Assignment_Id__c, Onboarding_Plan__c
                                           FROM New_Hire_Assignments__c 
                                           WHERE Assignment_OR_Program_Assignment_Id__c IN : idStringList]){
            
            if( mapOfModuleAssignIdToLstNewHireAssign.get(nha.Assignment_OR_Program_Assignment_Id__c) == null ){
            
                List<New_Hire_Assignments__c> newHireAssnList = new List<New_Hire_Assignments__c>();
                newHireAssnList.add(nha);
                mapOfModuleAssignIdToLstNewHireAssign.put(nha.Assignment_OR_Program_Assignment_Id__c,newHireAssnList );
                
            }else{
            
                mapOfModuleAssignIdToLstNewHireAssign.get(nha.Assignment_OR_Program_Assignment_Id__c).add(nha);
                
            }
            
        }
        
        for(Id mdlAssnIdOrPgmaId : mapOfModuleAssignIdToLstNewHireAssign.KeySet()){
        
            List<New_Hire_Assignments__c> newHireAssnList = mapOfModuleAssignIdToLstNewHireAssign.get(mdlAssnIdOrPgmaId);
            List<Assignmen_Content__c> asgnConList = new List<Assignmen_Content__c>();
            
            for(New_Hire_Assignments__c nha: newHireAssnList){
            
                if( assignmentId.contains(mdlAssnIdOrPgmaId)){
                
                    asgnConList = mapOfAsgnConIdToLstAsgnCon.get(mdlAssnIdOrPgmaId);
                    
                }else{

                    asgnConList = mapOfAsgnConIdToLstAsgnCon.get(mapOfPrgAsgnIdToModAsgnId.get(mdlAssnIdOrPgmaId));
                }
                
                for(Assignmen_Content__c asgnConObj : asgnConList ){
                
                    New_Hire_Content__c nhc = new New_Hire_Content__c();
                    nhc.Onboarding_Plan__c = nha.Onboarding_Plan__c;
                    nhc.Assignment_Content__c = asgnConObj.Id;
                    //nhc.Name = asgnConObj.Name;
                    nhc.New_Hire_Assignment__c = nha.id;
                    nhcListToCreate.add(nhc);
                    
                }
            }   
        }
        
     
        if(nhcListToCreate.size()>0){
        
            Database.Insert(nhcListToCreate,false);
            
        }
        
        for( Id prgModId: mapOfPrgModIDToPrdAssLst.KeySet() ){
        
            List<Program_Assignment__c> prgModAssLst = mapOfPrgModIDToPrdAssLst.get(prgModId);
            
            for( Assignmen_Content__c asgnConObj : mapOfAsgnConIdToLstAsgnCon.get(prgModId)){
                
                for( Program_Assignment__c prgAssObj: prgModAssLst){
                    
                    Program_Content__c prgConObj = new Program_Content__c();
                    prgConObj.Assignment_Content__c = asgnConObj.id;
                    prgConObj.Program_Assignment__c = prgAssObj.Id;
                    prgConObj.Onboarding_Program__c = prgAssObj.Onboarding_Program__c;
                    prgAssLstToCreate.add(prgConObj);
                }
                
            }
            
        }
        
        if( prgAssLstToCreate.Size() > 0 ){
        
            Database.Insert(prgAssLstToCreate,false);
            
        }
        System.debug('##### nhcListToCreate'+nhcListToCreate);
        
    }    
    
}