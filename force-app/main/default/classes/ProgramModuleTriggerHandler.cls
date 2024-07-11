/*
* Trigger Handler class for ProgramModuleTrigger.
* 
*Vesrion Date         Owner                                      Description
**************************************************************************************************
* 1.0    27/10/2014   ranjini.janardhanan@ust-global.com         Code created as part of #PR-0028.
* 2.0    11/12/2104   ranjini.janardhanan@ust-global.com         updated as part of #SP-0007.
*/
public Class ProgramModuleTriggerHandler {
    
    
    /*
     * Method called on after insert event
     */
    public static void onInsertAfter(List<Program_Module__c> newList){
        
        //Varible declaration.......
        List <Id> moduleIdList = new List <Id> ();        
        list <Id> programList = new List <Id> ();
        
        //Get the module Ids from the newly added program modules.
        for(Program_Module__c pm : newList){
           
            moduleIdList.add(pm.Module__c); //moduleId List from the Program Modules.
            programList.add(pm.Onboarding_Program__c); //ProgramId List from the Program Modules.         
                       
        }
        
        //calling method to insert Module Assignments and Assignment Content to the Program
        //#SP-0007. Method call made outside the for loop.
            addAssignmentsAndContents (moduleIdList , programList , newList);
    } 
    
    
    
    /*
    * This method will insert Module Assignments and Assignment contents to the program.
    */
    public static void addAssignmentsAndContents (List <Id> moduleIdList ,List <Id> programList , List<Program_Module__c> newList){ 
        
        //Variable Declarion...
        List <Module_Assignment__c> assignmentList = new List <Module_Assignment__c> ();
        Map <Id,Id> assignmentModuleMap = new Map <Id,Id>();
        List <assignmen_Content__c> contentList = new List <assignmen_Content__c> ();       
        Map <Id, List<Id>> moduleAssignmentMap = new Map <Id, List<Id>> ();              
        
            
        //Get the associated Assignments into moduleAssignmentMap.      
        if(moduleIdList.size()>0){
            
            //System.debug('##### moduleList: '+moduleList);
            for(Module_Assignment__c asmnt : [SELECT Id, Name, Module__c 
                                              FROM Module_Assignment__c
                                              WHERE Module__c IN :moduleIdList]){
                  assignmentList.add(asmnt);
                  assignmentModuleMap.put(asmnt.Id,asmnt.Module__c);
                  if(moduleAssignmentMap.containsKey(asmnt.Module__c))
                        moduleAssignmentMap.get(asmnt.Module__c).add(asmnt.Id);
                  else
                        moduleAssignmentMap.put(asmnt.Module__c,new  List <Id> { asmnt.Id });
                                           
            }
        }        
        System.debug('##### moduleAssignmentMap: '+moduleAssignmentMap);
         
        //creating list of Program Assignemnts to be created.
        List <Program_Assignment__c> pgmAssignmentList = new List <Program_Assignment__c> ();
        for(Program_Module__c pm : newList){
            
            if(moduleAssignmentMap.containsKey(pm.module__c)){
                
                Program_Assignment__c pa ;
                for(Id asnmntId : moduleAssignmentMap.get(pm.module__c)){
                    
                    pa =  new Program_Assignment__c ();
                    pa.Onboarding_Program__c = pm.Onboarding_Program__c;
                    pa.Module_Assignment__c = asnmntId;
                    pa.Program_Module__c = pm.Id;
                    pgmAssignmentList.add(pa);
                    
                }
            }            
            
        }
        System.debug('##### pgmAssignmentList: '+pgmAssignmentList);    
        
        try{
            if(pgmAssignmentList.size()>0)
            
                Database.insert(pgmAssignmentList,false);
            
         }catch(Exception e){
            System.debug('##### Exception in addAssignmentsAndContents method : '+e);
         }
         
         
        //Get the associated Content List for the Program Assignemnts/Modules into assgnmntContentMap.
        Map<Id,List<Id>> assgnmntContentMap = new Map<Id,List<Id>> ();
        if(assignmentList.size()>0){
            
            contentList = [SELECT Id,Name, Module_Assignment__c
                           FROM Assignmen_Content__c 
                           WHERE Module_Assignment__c IN :assignmentList];
            
            for(Assignmen_Content__c cnt : contentList){
                
                if(assgnmntContentMap.containsKey(cnt.Module_Assignment__c))
                    assgnmntContentMap.get(cnt.Module_Assignment__c).add(cnt.Id);
                else
                    assgnmntContentMap.put(cnt.Module_Assignment__c,new  List <Id> { cnt.Id });

            }
            
            
            //Creating the list of Program Contents to be inserted into the program.
            List <Program_Content__c> pgmContentList = new List <Program_Content__c> ();                            
            for(Program_Assignment__c pa : [Select Id, Onboarding_Program__c, Module_Assignment__c
                                            FROM Program_Assignment__c 
                                            WHERE Onboarding_Program__c IN :programList]){
                    
                    Program_Content__c pc;                    
                    if(assgnmntContentMap.get(pa.Module_Assignment__c) != null){
                        
                        for(Id cntId : assgnmntContentMap.get(pa.Module_Assignment__c)){
                            
                            pc =  new Program_Content__c ();
                            pc.Onboarding_Program__c = pa.Onboarding_Program__c;
                            pc.Assignment_Content__c = cntId;
                            pc.Program_Assignment__c = pa.Id;
                            pgmContentList.add(pc);
                            
                            
                        }
                    }
           
            }            
            System.debug('##### pgmContentList: '+pgmContentList);   
            
            try{
            
                if(pgmContentList.size()>0){  
                              
                    Database.insert(pgmContentList,false);
                
                }
            }catch(Exception e){
                System.debug('##### Exception in addAssignmentsAndContents method : '+e);
            }                         
                  
        }
       
    }
    
    
}