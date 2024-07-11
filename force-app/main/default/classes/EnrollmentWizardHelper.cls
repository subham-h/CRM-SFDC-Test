/*
*
* 
*Vesrion Date         Owner                               Description
*************************************************************************************************
* 1.0    10/29/2014   Deepa.Raman@ust-global.com        #PR-0028 :Helper Class for EnrollemtWizard.
* 2.0    12/05/2014   Ranjini.Janardhanan@ust-global.com  #SP-0007 :Class updated.
* 3.0    02/01/2015   Ranjini.Janardhanan@ust-global.com    #SP-0013/#RQ-000851.
* 4.0    15/07/2014   jagadeesan.sakthivel@ust-global.com   #RQ-004021: Code Added
* 5.0    10/5/2017    ramadevi.palaniswamy@ust-global.com   #RQ-005073:Included Requires review field from Program module to new hire module for Program enrollment
* 6.0    26/11/2017   jagadeesan.sakthivel@ust-global    #RQ-009241 : Included Last Module field from Module to New Hire Module for Program enrollment
* 7.0    14/01/2019   Junaid.Khader@ust-global        #RQ-009682 : Setting module with highest order as the last module
*/

public class EnrollmentWizardHelper
{
    
    
    
    /**
    *Constructor
    **/
    public EnrollmentWizardHelper(){
        
    }
    
    
    
    /**
    *Method to create New Hire Modules For Adhoc Enrollment type
  *SP-0007 : method parametres updated to List of wrapper class.
    **/
    public static List<New_Hire_Module__c> createNewHireModuleFromModule(List<Onboarding_Plan__c> OnbPlanList, List<ModuleWrapper> moduleList){
        List<New_Hire_Module__c> newHireModulesToBeCreated=new List<New_Hire_Module__c>();
        Integer intCountOfModule;
        Integer intIndexOfLastModule;
        Decimal decHighestOrder;
        Map<Id, List<New_Hire_Module__c>> mapOnboardingPlanWithNewHireModules = new Map<Id, List<New_Hire_Module__c>>();
        
        for(Onboarding_Plan__c plan : OnbPlanList){                 
            intCountOfModule = 0;
            intIndexOfLastModule = 0;
            decHighestOrder = 0;
            for( ModuleWrapper mod : moduleList){
                New_Hire_Module__c newHireMod=new New_Hire_Module__c();
                newHireMod.Onboarding_Plan__c = plan.id;   //Onb plan                     
                newHireMod.Badge_Name__c = mod.Module.Badge_Name__c ;
                newHireMod.Category__c = mod.Module.Category__c;
                newHireMod.Description__c= mod.Module.Description__c; 
                newHireMod.Duration__c= mod.Module.Duration__c;
                newHireMod.Order__c = mod.Order;
                newHireMod.Name = mod.Module.Name;
                newHireMod.Module_OR_Program_Module_Id__c = mod.Module.id;
                newHireMod.Badge_Name__c = mod.Module.Badge_Name__c; 
                newHireMod.Badge_URL__c = mod.Module.Badge_URL__c;
                newHireMod.Badge_Content_Version_Id__c = mod.Module.Badge_Content_Version_Id__c;//#SP-0013/#RQ-000851
                //newHireMod.Last_Module__c = mod.Module.Last_Module__c; // #RQ-009241
                if(mapOnboardingPlanWithNewHireModules.containsKey(plan.id)){
                    mapOnboardingPlanWithNewHireModules.get(plan.id).add(newHireMod);
                } else {
                    mapOnboardingPlanWithNewHireModules.put(plan.id, new List<New_Hire_Module__c>{newHireMod});
                }
                //newHireModulesToBeCreated.add(newHireMod);
                if(mod.Order > decHighestOrder){
                    decHighestOrder = mod.Order;
                    intIndexOfLastModule = intCountOfModule;
                }
                intCountOfModule = intCountOfModule+1;
            }  
            if(intIndexOfLastModule != null && (mapOnboardingPlanWithNewHireModules.get(plan.id)[intIndexOfLastModule] != null))
                mapOnboardingPlanWithNewHireModules.get(plan.id)[intIndexOfLastModule].Last_Module__c = true;        
        }
        for(Id onboardingPlanId : mapOnboardingPlanWithNewHireModules.keySet()){
            newHireModulesToBeCreated.addAll(mapOnboardingPlanWithNewHireModules.get(onboardingPlanId));
        }
        return newHireModulesToBeCreated;
    }
    

    /**
    *Method to create New Hire Assignmments for Adhoc Enrollment type
    **/    
    public static List<New_Hire_Assignments__c> createNewHireAssignmentFromAssignment(List<New_Hire_Module__c> NewHireModList, Map<ID,List<Module_Assignment__c>> mAssignmentMap){
        List <New_Hire_Assignments__c> newHireAssgnToBeCreated = new List<New_Hire_Assignments__c>();
        
        for(New_Hire_Module__c nhm: NewHireModList){            
            
            ID parentId = ID.Valueof(nhm.Module_OR_Program_Module_Id__c);
            system.debug('#####Construct New Hire Assgn for Module-'+ parentId);
            if(!mAssignmentMap.isEmpty() && mAssignmentMap != null && parentId != null){
            
                if(mAssignmentMap.containsKey(parentId)){
             
                    //get list of assignments for each module
                    for(Module_Assignment__c a : mAssignmentMap.get(parentId)){
                        
                        New_Hire_Assignments__c newHireAssignment = new New_Hire_Assignments__c();
                        
                        newHireAssignment.name = a.name;
                        newHireAssignment.Onboarding_Plan__c = nhm.Onboarding_Plan__c;   
                        newHireAssignment.Description__c = a.Description__c; 
                        newHireAssignment.Order__c = a.Order__c;
                        newHireAssignment.Module_Name__c=a.Module__r.Name ;
                        newHireAssignment.Assignment_OR_Program_Assignment_Id__c =a.id;
                        newHireAssignment.New_Hire_Module__c = nhm.id;
                        newHireAssgnToBeCreated.add(newHireAssignment);
                        
                    }   
                
                }
            
            }
       
        } 
        
        return newHireAssgnToBeCreated; 
    
    }
    

    /**
    *Method to create New Hire Contents for Adhoc Enrollment type
    **/    
    public static List<New_Hire_Content__c> createNewHireContentFromContent(List <New_Hire_Assignments__c> newHireAssgnList, Map<Id,List<Assignmen_Content__c>> assigmentContentMap){
        List<New_Hire_Content__c> newHireContentToBeCreated = new List<New_Hire_Content__c>();

        for(New_Hire_Assignments__c a: newHireAssgnList){       
             
            ID parentId = ID.Valueof(a.Assignment_OR_Program_Assignment_Id__c);
            system.debug('#####Construct New Hire Content for Assgn-'+ parentId);
            
            system.debug('#####assigmentContentMap'+assigmentContentMap.values());
            if(!assigmentContentMap.isEmpty() && assigmentContentMap != null && parentId != null){
            
                if(assigmentContentMap.containsKey(parentId)){
            
                    //get list of assignments for each module
                    for(Assignmen_Content__c c : assigmentContentMap.get(parentId)){
                    
                        New_Hire_Content__c newHireContent = new New_Hire_Content__c();
                        //newHireContent.name = c.name;
                        newHireContent.Assignment_Content__c =  c.ID;       
                        newHireContent.Onboarding_Plan__c =  a.Onboarding_Plan__c;  
                        newHireContent.New_Hire_Assignment__c =  a.id ;
                        newHireContentToBeCreated.add(newHireContent);
                        
                        
                    }
                    
                }
                
            }
        }      
        system.debug('#####newHireContentToBeCreated'+newHireContentToBeCreated); 
        return newHireContentToBeCreated;
    }   
        


    /**
    * Method to create New Hire Modules For Onboarding Program Enrollment type
    **/
    public static List<New_Hire_Module__c> createNewHireModuleFromPModule(List<Onboarding_Plan__c> OnbPlanList, List<Program_Module__c> pmoduleList){
        List<New_Hire_Module__c> newHireModulesToBeCreated=new List<New_Hire_Module__c>();
        Integer intCountOfModule;
        Integer intIndexOfLastModule;
        Decimal decHighestOrder;
        Map<Id, List<New_Hire_Module__c>> mapOnboardingPlanWithNewHireModules = new Map<Id, List<New_Hire_Module__c>>();
        
        for(Onboarding_Plan__c plan : OnbPlanList){              
            intCountOfModule = 0;
            intIndexOfLastModule = 0;
            decHighestOrder = 0;
            for( Program_Module__c  mod : pmoduleList){
                if( mod.module__c != null){
                    New_Hire_Module__c newHireMod=new New_Hire_Module__c();
                    newHireMod.Onboarding_Plan__c = plan.id;   //Onb plan                     
                    newHireMod.Badge_Name__c = mod.Module__r.Badge_Name__c ;
                    newHireMod.Category__c = mod.Module__r.Category__c;
                    newHireMod.Description__c=mod.Module__r.Description__c; 
                    newHireMod.Duration__c=mod.Module__r.Duration__c;
                    newHireMod.Order__c =mod.Order__c;
                    newHireMod.Name=mod.Module__r.Name;                   
                    newHireMod.Module_OR_Program_Module_Id__c=mod.id;
                    newHireMod.Badge_Name__c = mod.Module__r.Badge_Name__c;
                    newHireMod.Badge_URL__c= mod.Module__r.Badge_URL__c;
                    newHireMod.Badge_Content_Version_Id__c= mod.Module__r.Badge_Content_Version_Id__c;//#SP-0013/#RQ-000851
                    //newHireMod.Last_Module__c = mod.Module__r.Last_Module__c; // #RQ-009241
                    //newHireMod.Requires_Review__c=mod.Requires_Review__c;
                    if(mapOnboardingPlanWithNewHireModules.containsKey(plan.id)){
                        mapOnboardingPlanWithNewHireModules.get(plan.id).add(newHireMod);
                    } else {
                        mapOnboardingPlanWithNewHireModules.put(plan.id, new List<New_Hire_Module__c>{newHireMod});
                    }
                    if(mod.Order__c > decHighestOrder){
                        decHighestOrder = mod.Order__c;
                        intIndexOfLastModule = intCountOfModule;
                    }
                    intCountOfModule = intCountOfModule+1;
                }
            }
            if(intIndexOfLastModule != null && (mapOnboardingPlanWithNewHireModules.get(plan.id)[intIndexOfLastModule] != null))
                mapOnboardingPlanWithNewHireModules.get(plan.id)[intIndexOfLastModule].Last_Module__c = true;  
        }
        for(Id onboardingPlanId : mapOnboardingPlanWithNewHireModules.keySet()){
            newHireModulesToBeCreated.addAll(mapOnboardingPlanWithNewHireModules.get(onboardingPlanId));
        }
        return newHireModulesToBeCreated;
    }
    

    /**
    * Method to create New Hire Assignments for Onboarding Program Enrollment type
    **/    
    public static List<New_Hire_Assignments__c> createNewHireAssignmentFromPAssignment(List<New_Hire_Module__c> iNewHireModuleList, Map<id,List<Program_Assignment__c>> pAssignmentMap){
        
        List <New_Hire_Assignments__c> newHireAssgnToBeCreated = new List<New_Hire_Assignments__c>();
        
        for(New_Hire_Module__c m : iNewHireModuleList){            
            
            ID parentId = ID.Valueof(m.Module_OR_Program_Module_Id__c);
            
            system.debug('#####Construct New Hire Assgn for module-'+ parentId);
            if( !pAssignmentMap.isEmpty() && pAssignmentMap != null &&  parentId != null){

                if( pAssignmentMap.containsKey(m.Module_OR_Program_Module_Id__c )){
                
                    //get list of assignments for each module
                    for(Program_Assignment__c a : pAssignmentMap.get(m.Module_OR_Program_Module_Id__c )){
                        
                        if(a.Module_Assignment__c != null){
                        
                            New_Hire_Assignments__c newHireAssignment = new New_Hire_Assignments__c();
                            
                            newHireAssignment.name = a.Module_Assignment__r.name;
                            newHireAssignment.Onboarding_Plan__c =  m.Onboarding_Plan__c;     //plan id copied from new hire module
                            newHireAssignment.Description__c = a.Module_Assignment__r.Description__c; 
                            newHireAssignment.Order__c = a.Module_Assignment__r.Order__c;
                            //newHireAssignment.Program_Assignment__c=a.id ;       //id of program assignment 
                            newHireAssignment.Module_Name__c=a.Module_Assignment__r.Module__c;
                            newHireAssignment.New_Hire_Module__c = m.id ;        //New hire module id (parent)
                            newHireAssignment.Assignment_OR_Program_Assignment_Id__c =a.id ;
                            newHireAssgnToBeCreated.add(newHireAssignment);
                            
                        }
                    }
                }
            }
        }
        return newHireAssgnToBeCreated; 
    }
    


    /**
    *  #RQ-004021 Method to create New Hire Contents for Onboarding Program Enrollment type
    **/    
    public static List<New_Hire_Content__c> createNewHireContentFromPContent(List<New_Hire_Assignments__c> iNewHireAssgnList,  Map<id,List<Program_Content__c>> pContentMap){
        List<New_Hire_Content__c> newHireContentToBeCreated = new List<New_Hire_Content__c>();
        
        for(New_Hire_Assignments__c a: iNewHireAssgnList){            
             
            ID parentId = ID.Valueof(a.Assignment_OR_Program_Assignment_Id__c);
            system.debug('#####Construct New Hire Content for Assgn-'+ parentId);
            
            if( !pContentMap.isEmpty() && pContentMap != null && parentId != null){
                
                if(pContentMap.containsKey(a.Assignment_OR_Program_Assignment_Id__c)){
                
                    //get list of assignments for each module
                    for(Program_Content__c c : pContentMap.get(a.Assignment_OR_Program_Assignment_Id__c)){
                        
                        if(c.Assignment_Content__c != null){
                        
                            New_Hire_Content__c newHireContent = new New_Hire_Content__c();
                            
                            //newHireContent.name = c.Assignment_Content__r.name;
                            newHireContent.Assignment_Content__c =  c.Assignment_Content__c;        
                            newHireContent.Onboarding_Plan__c = a.Onboarding_Plan__c;     //plan id
                            newHireContent.New_Hire_Assignment__c = a.id ;           //New hire Assignment id   (parent)
                            newHireContentToBeCreated.add(newHireContent);
                            
                        }
                    }
                    
                }
                    
            }
        }       
        return newHireContentToBeCreated;
    }   
    
    
    
    /**
    * #RQ-004021 Method to add New Hires as chatter group members based on onboarding plan chatter group for Onboarding Program based enrollments
    **/    
    public static List<CollaborationGroupMember> addNewHireToChatterGrp(List<Onboarding_Plan__c> obPlanUpdLst,  String url){
        
        List<CollaborationGroupMember> chatterGrpMemList = new List<CollaborationGroupMember>();
        Integer index = url.indexOf('?g=');
        if ( index > -1 ){
            string urlId = url.right(url.length()-index-3);
            if (urlId != null && urlId != ''){
                
                for( Onboarding_Plan__c onbPlan: obPlanUpdLst ){
                    
                    chatterGrpMemList.add( new CollaborationGroupMember( CollaborationGroupId = urlId, MemberId = onbPlan.New_Hire__c ));
                        
                }
                
            }
        }
        
        return chatterGrpMemList;    
    }
    
    
    /**
    * Method to add New Hires as chatter group members based on onboarding plan chatter group for Adhoc Program enrollements
    **/    
    public static List<CollaborationGroupMember> addNewHireToChrGrpForAdhocPrg(List<Onboarding_Plan__c> obPlanUpdLst){
        
        List<CollaborationGroupMember> chatterGrpMemList = new List<CollaborationGroupMember>();
        
        for( Onboarding_Plan__c onbPlan: obPlanUpdLst ){
        
            if( onbPlan.Chatter_Group_URL__c != null ){
                
                Integer index = onbPlan.Chatter_Group_URL__c.indexOf('?g=');
                if ( index > -1 ){
                    string urlId = onbPlan.Chatter_Group_URL__c.right(onbPlan.Chatter_Group_URL__c.length()-index-3);
                    if (urlId != null && urlId != ''){
                        chatterGrpMemList.add( new CollaborationGroupMember( CollaborationGroupId = urlId, MemberId = onbPlan.New_Hire__c ));
                    }
                }
                
            }
                        
        }
        
        return chatterGrpMemList;    
    }
    
    
    
    /**
    *Wrapper Class for Onboarding_Plan_c
    **/ 
    public class OnboardingPlanWrapper {

        public Boolean isSelected{ get; set; }
        public Onboarding_Plan__c onbPlan { get; set;}

        public OnboardingPlanWrapper(Onboarding_Plan__c p,boolean b){

            this.onbPlan = p;
            this.isSelected = b;
        }

    }   
    
    
    
    /**
    * Wrapper class formation for Module object.
    * #SP-0007. Added order to the wrapper class.
    */
    public class ModuleWrapper {

        public Boolean isSelected{ get; set; }
		public Module__c Module { get; set;}
        public Decimal Order {get; set;}

        public ModuleWrapper(Module__c m,boolean b, Decimal o){

            this.Module = m;
            this.isSelected = b;
            this.order = o;
        }

    }   
}