/*
* Controller class for adding musltiple modules to a program (ProgramBuilderWizard)
* 
*Vesrion Date         Owner                                      Description
**************************************************************************************************
* 1.0    11/12/2014   ranjini.janardhanan@ust-global.com         Code created as part of #SP-0007.
* 2.0    05/01/2014   ranjini.janardhanan@ust-global.com         Updated as part of #SP-0013/#RQ-000844.
* 3.0    01/09/2017   meghana.gupta@ust-global.com               #RQ-005127 - Convert custom controller to Extension controller
*/
public class ProgramBuilderWizardController {
    
    //Variable declaraion.
    public List<moduleWrapper> moduleWrapperList {get;set;}
    public List<Module__c> selectedModules {get;set;}
    public List <Program_Module__c> newPgmModuleList {get;set;}
    public List <Program_Module__c> updatePgmModuleList {get;set;}
    public List<moduleOrderWrapper > moduleOrderWrapperList{get;set;}
    public List<moduleOrderWrapper > existingModuleOrderWrapperList{get;set;}
    public List<moduleOrderWrapper> allModuleOrderWrapperList{get;set;}
    public Map<Id,Program_Module__c> pmMap {get;set;}
    public Set <Id> existingModuleIds {get;set;}    
    public String programId {get;set;}
    public List <Module__c> moduleList;    
    public boolean isReady {get;set;}
    public String searchText {get;set;}
    public String queryString {get;set;}
    public boolean queryTrue = true;
    
    
    /*
     *Constructor 
     */
    public ProgramBuilderWizardController (ApexPages.StandardController controller){       
       
        programId = controller.getId(); // (string) ApexPages.currentPage().getParameters().get('id');  //ApexPages.currentPage().getParameters().get('pgmId');        
        this.moduleWrapperList  = new List<moduleWrapper>();       
        
        //If the program status is ready no more modules can be added.
        if([SELECT Id, is_ready__c FROM Onboarding_Program__c WHERE Id =: programId ].is_ready__c ==true){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Label.No_Modules_Can_Be_Added));
            isReady = false;
           
        }else{
        
            isReady = true;
            pmMap = new Map<Id,Program_Module__c> ();
            existingModuleIds = new Set <Id>();
            
            for(Program_Module__c op : [SELECT Id, Module__c, Onboarding_Program__c, Order__c, Duration__c 
                                        FROM Program_Module__c 
                                        WHERE Onboarding_Program__c =:programId ]){
                
                pmMap.put(op.Module__c,op);
                existingModuleIds.add(op.Module__c);// To get the existing Program modules if any.
                
            }
            
            queryString = 'SELECT Id, Name, Category__c, Duration__c, Order__c, Is_Ready__c FROM Module__c WHERE  Id NOT IN : existingModuleIds AND Is_Ready__c =:queryTrue ORDER BY Category__c';        
            setcon = null; 
            loadModuleWrapperList();
        }
        
       
    }
    
    
    
    /*
    *Wrapper class definition for displaying and  selecting the modules.
    */   
    public class moduleWrapper {

        public Module__c mod {get; set;}
        public Boolean selected {get; set;}
    
        //Constructor
        public moduleWrapper(Module__c m) {    
            mod = m;
            selected = false;   
        }

    }
    
    
    
    /*
    *Wrapper class for selected modules to enter order.
    *#RQ-000844. Added duration to the warpper class.
    */    
    public class moduleOrderWrapper {

        public Module__c mod {get; set;}
        public Decimal order {get; set;}
        public Decimal duration {get; set;}
    
        //Constructor
        public moduleOrderWrapper (Module__c m,Decimal o, Decimal d) {   
            mod = m;
            order = o;
            duration = d;
        }

    }
    
    
    
    /*
     * Module search action method
     */ 
    public PageReference processSearch() {
        queryString = 'SELECT Id, Name, Category__c, Duration__c, Order__c, Is_Ready__c FROM Module__c WHERE  Id NOT IN : existingModuleIds AND Is_Ready__c =:queryTrue'+' AND Name like  \'%'+searchText.trim() + '%\''+' ORDER BY Category__c';       
        setcon = null;
        loadModuleWrapperList();
        return null;
    }
    
    
    
    /*
    *Method to redirect to Step 2 for the selected modules.
    *Step 2 will dispaly all the existing modules with order and 
    *Newly selected modules with suggested order.
    */
    public PageReference processSelectedModules() {
        
        selectedModules  = new List<Module__c>();
     
        for(moduleWrapper  modWrapObj : moduleWrapperList) {
            if(modWrapObj.selected == true) {
                selectedModules.add(modWrapObj.mod);
            }
        }
        
        if(selectedModules.size()>0){
        
            moduleOrderWrapperList = new List <moduleOrderWrapper > ();
            existingModuleOrderWrapperList = new List <moduleOrderWrapper > ();
            allModuleOrderWrapperList = new List <moduleOrderWrapper > ();
            
            for(Module__c md : selectedModules){
                
                moduleOrderWrapperList.add(new moduleOrderWrapper (md, md.Order__c, md.Duration__c));
                allModuleOrderWrapperList.add(new moduleOrderWrapper (md, md.Order__c, md.Duration__c));
                
            }
            
            for(Module__c md : [SELECT Id, Name, Category__c, Duration__c, Order__c 
                                FROM Module__c 
                                where Id IN :existingModuleIds ]){
                
                existingModuleOrderWrapperList.add(new moduleOrderWrapper (md, pmMap.get(md.Id).Order__c, pmMap.get(md.Id).Duration__c));
                allModuleOrderWrapperList.add(new moduleOrderWrapper (md, pmMap.get(md.Id).Order__c, pmMap.get(md.Id).Duration__c));
                
            }
            
            String urlString = '/apex/ProgramBuilderWizardStep2';    
            PageReference pageRef = new PageReference(urlString);
            return pageRef;
        }
        
        else
            return null;
    }
    
    
   
    /*
     * Save Program Modules.
     * Existing modules will be updated if any.
     * New Modules will be created.
     */
    public PageReference createProgramModules() {
    
        newPgmModuleList = new List <Program_Module__c> ();
        updatePgmModuleList = new List <Program_Module__c> ();
        
        for(moduleOrderWrapper mo : allModuleOrderWrapperList ){
        
            if(existingModuleIds.contains(mo.mod.Id)){
                
                Program_Module__c pm = pmMap.get(mo.mod.Id);
                pm.Order__c = mo.order;
                updatePgmModuleList.add(pm);
                
            }
            else{
                
                Program_Module__c pm = new Program_Module__c ();
                pm.Module__c = mo.mod.Id;
                pm.Onboarding_Program__c = programId ;
                pm.Order__c = mo.order;
                newPgmModuleList.add(pm);
            }
            
        
        }      
            
        try{
            
            if(updatePgmModuleList.size()>0)
                update updatePgmModuleList;
            if(newPgmModuleList.size()>0 )
                insert newPgmModuleList;
            
             String urlString = '/'+programId ;    
             PageReference pageRef = new PageReference(urlString);
             return pageRef;
            
        }catch (Exception e){
            if(e.getMessage().contains ('DUPLICATE_VALUE'))
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Label.Order_Should_Be_Unique));// If there are any dupliacte order entered.
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Label.EnrollmentNotCompleted));
            return null;                    
        }
        
        return null;
    }
    
    
    
    /*
     * Pagination code
     */     
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                 system.debug('###8954 queryString: '+queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                
                System.debug('##### setCon.getRecords()'+setCon.getRecords());
                setCon.setpagesize(200);
            }
            return setCon;
        }
        set;
    }
    
    
    
    /*
     * To get values into the wrapper list
     */    
     public void loadModuleWrapperList () {
        
        moduleWrapperList  = new List<moduleWrapper>();
        List <Module__c> mdList = (List<Module__c>) setCon.getRecords();
          System.debug('##### mdList :'+mdList);
        for(Module__c m  : mdList){
            moduleWrapperList .add(new moduleWrapper(m));
        }         
         
    }
    
    
   
    /*
     *Back/Cancel button function 
     */ 
    public PageReference backToProgram(){
        
        String urlString = '/'+programId ;    
        PageReference pageRef = new PageReference(urlString);
        return pageRef;
    
    }
    
   
    
    /*
     *Back button function on step2
     */
    public PageReference backToStep1(){
        
        String urlString = '/apex/ProgramBuilderWizardStep1?pgmId='+programId ;    
        PageReference pageRef = new PageReference(urlString);
        return pageRef;
    
    }
    
    
    

}