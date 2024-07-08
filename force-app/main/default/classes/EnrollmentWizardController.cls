/*
*
* 
*Vesrion Date         Owner                                 Description
*************************************************************************************************
* 1.0    10/14/2014   madhava.kotte@ust-global.com          #PR-0028 :Code created.
                      Deepa.Raman@ust-global.com
* 2.0    11/26/2014   Ranjini.janardhanan@ust-global.com    #SP-0007 :Code Updated.
* 3.0    12/23/2014   Ranjini.janardhanan@ust-global.com    #SP-0013/#RQ-000640,#RQ-000851.Code updated.
* 4.0    15/07/2014   jagadeesan.sakthivel@ust-global.com   #RQ-004021: Code Added
* 5.0    10/5/2017    ramadevi.palaniswamy@ust-global.com   #RQ-005073:Included Requires review field from Program module to new hire module for Program enrollment
* 6.0    26/11/2018   jagadeesan.sakthivel@ust-global.com   #RQ-009241 : Included Last Module field in the Module query to copy over the last module info to New Hire Modules
*/
public class EnrollmentWizardController{


        public String selectedEnrollment{ get; set; }                        //Type of enrollment process selected    
        public List<SelectOption> enrollOptions = new List<SelectOption>();  //List to store enrollment options 
        public Integer startIndex {get;set;}
        public Integer endIndex {get;set;}
        public string option{get;set;}
        public boolean isSelectedOnbprm{get;set;}
        public String onbProgram { get; set; }
        public String isOnboardOrAdhoc{get;set;}
        public List<Onboarding_Program__c> onbProgramsList  =  new List<Onboarding_Program__c>();
        public List<SelectOption> programsPicklist  =  new List<SelectOption>();
        public boolean isProgramPanel{get;set;}
        public boolean isMyOwnPlans{get;set;} 
        public boolean isOnbPlanComplted{get;set;}
        public boolean isOnbPlanPanel{get;set;}
        public Map<Id,EnrollmentWizardHelper.OnboardingPlanWrapper> selectedPlanWrapperList;                       
        List<EnrollmentWizardHelper.OnboardingPlanWrapper> OnboardingPlanWrapperList = new List<EnrollmentWizardHelper.OnboardingPlanWrapper>();
        List<Onboarding_Plan__c> planSearchList = new List<Onboarding_Plan__c>();
        
        //variable for storing the default page size
        public Integer PAGE_SIZE {get;set;}
        
        
        
        /**Adhoc variables **/ 
        public boolean isModuleAvailable { get; set; }
        public List<Module__c> moduleSearchList {get;set;} 
        public List<string> selectedObPlansIdSet =new List<string>();  //Hold ids of selected OBplans passed from plan selection page
        List<EnrollmentWizardHelper.ModuleWrapper> ModuleWrapperList {get;set;} 
        Map<Id,EnrollmentWizardHelper.ModuleWrapper> selectedModuleWrapperMap;
        //Map <Id,Module__c> selectedModulesMap {get;set;}  
    
        //#SP-0007/#RQ-000834
        Map <Id,Module__c> selectedModulesMap {get;set;}      
        
        
        /**
        * Constructor...
        */
        public EnrollmentWizardController(){
            
            //Default page size
            PAGE_SIZE = 200;            
            selectedEnrollment = 'op';  //To set default selection as Onboarding Program enrollment type            
            selectedPlanWrapperList  =  new Map<Id,EnrollmentWizardHelper.OnboardingPlanWrapper>(); 
            isSelectedOnbprm = false;
            isProgramPanel = false;
            isOnbPlanComplted = false; 
            isOnbPlanPanel = false;                           
            isMyOwnPlans=false;
            isModuleAvailable=false;
            selectedModuleWrapperMap = new Map<Id,EnrollmentWizardHelper.ModuleWrapper>();

        }
        
        
              
        /**
        * Setup a list of enrollment select options.
        **/
        public List<SelectOption> getEnrollOptions() {
            
            enrollOptions.clear();            
            enrollOptions.add( new SelectOption( 'op', Label.OnboardingProgram ) );
            enrollOptions.add( new SelectOption( 'ah', Label.AdhocProgram ) );           
            return enrollOptions;
        
        }
    
    
    
        /**
        *Code for Next button in Step 1 [Enrollment type selection page]
        * Redirect to corrsponding pages based on type of enrollment selected 
        */
        public PageReference NextProcess () {
            
            searchText = '';
            return page.EnrollmentWizardStep2;

        }
        
        //Instantiate the StandardSetController  
        public ApexPages.StandardSetController con{get; set;} 
    
    
    
        /**
        * Setup a list of Select Options to be used in Picklists in the VF page.
        */
        public List<SelectOption> getProgramsPicklist() {
            
            programsPicklist.clear();            
            onbProgramsList  =  [SELECT Id, Name 
                                 FROM Onboarding_Program__c 
                                 WHERE Is_Ready__c =: True  ORDER BY Name ASC];

            programsPicklist.add( new SelectOption( '', Label.SelectProgram ) );
            
            for ( Integer i  =  0; i < onbProgramsList.size(); i++ ){
                
                programsPicklist.add( new SelectOption( onbProgramsList[i].Id, onbProgramsList[i].Name ) );
                
            }
        
            return programsPicklist;
        
        }
        
    
    
        /**
        *For rendering the onboarding plan selection page
        * Next button in Program selection page
        */
        public pagereference nextStep(){
          
            if(onbProgram != Null)
            {  
                
                if( selectedEnrollment == 'op'){
                
            
                    try{
                        
                        setSelectedPlanWrapperList();
                        List<Onboarding_Plan__c> ObPlanUpdLst = new List<Onboarding_Plan__c>();
                        
                        // #SP-0007/RQ-000644 : Added program chatter url to the plan.
                        Onboarding_Program__c opgm = [Select Id, Chatter_Group__c,Description__c FROM Onboarding_Program__c WHERE Id =:onbProgram];
                                                
                        // add the selected plans to a new List
                        for (EnrollmentWizardHelper.OnboardingPlanWrapper ow : SelectedPlanWrapperList.values()) {
                            
                            ow.onbPlan.Status__c  =  'Enrolled';
                            ow.onbPlan.Onboarding_Program__c = onbProgram;
                            ow.onbPlan.Enrolled_Or_Onboarded__c = 1;
                            
                            if(opgm.Chatter_Group__c != null) 
                                ow.onbPlan.Chatter_Group_URL__c = opgm.Chatter_Group__c;// #SP-0007/RQ-000644 : Added program chatter url to the plan.
                            
                            //#SP-0013/#RQ-000640. To Copy the Program Description to the plan.
                            if(opgm.Description__c != null)
                                ow.onbPlan.Description__c = opgm.Description__c;
                            
                            ObPlanUpdLst.add(ow.onbPlan);  //selected plans
                            system.debug('#####Inside IF--ObPlanUpdLst -'+ObPlanUpdLst);   
                                
                        }

                        //Get list of modules for that program
                        List<New_Hire_Module__c> newHireModulesForInsert = new List<New_Hire_Module__c>();                        
                        List<New_Hire_Assignments__c> newHireAssinmentsForInsert = new List<New_Hire_Assignments__c>();                        
                        
                        //#SP-0013/#RQ-000851: Added Badge_Content_Version_Id__c in the query. 
                        //#RQ-005073:Included Requires review field from Program module to new hire module for Program enrollment
                        //#RQ-009241: Inculded Last Module field from Module to new hire module for Program enrollment
                        Map<id,Program_Module__c> programModuleMap  =  new Map<id,Program_Module__c>([SELECT Id, Module__c, Module__r.name, Module__r.Badge_Name__c,Module__r.Badge_URL__c, Module__r.Badge_Content_Version_Id__c, Module__r.Category__c, Module__r.Description__c, Module__r.Duration__c, Module__r.Order__c, Module__r.Last_Module__c, Duration__c, Order__c 
                                                                                                      FROM Program_Module__c 
                                                                                                      WHERE Onboarding_Program__c =: onbProgram]); 
                                               
                        
                        if(programModuleMap.size() > 0 && ObPlanUpdLst.size() > 0){
                        
                            newHireModulesForInsert = EnrollmentWizardHelper.createNewHireModuleFromPModule(ObPlanUpdLst,programModuleMap.values()) ;   

                        }
                        
                        system.debug('#####newHireModulesForInsert -'+newHireModulesForInsert);
                        
                        //Insert list of modules for OnbPlan
                        if(!newHireModulesForInsert.IsEmpty())
                        {
                            
                            isOnbPlanComplted = true;
                            
                            Database.insert(newHireModulesForInsert,false);
                            
                        } 

                        Map<id,List<Program_Assignment__c>> moduleIdProgramAssgn = new Map<id,List<Program_Assignment__c>>();                      
                        List<New_Hire_Assignments__c> newHireAssignmentsForInsert = new List<New_Hire_Assignments__c>();
                        
                        for( Program_Assignment__c pa : [SELECT Program_Module__c, id, Name, Module_Assignment__r.name, Module_Assignment__c, Module_Assignment__r.Description__c, Module_Assignment__r.Order__c, Module_Assignment__r.Module__c 
                                                         FROM Program_Assignment__c 
                                                         WHERE Onboarding_Program__c =: onbProgram AND Program_Module__c =: programModuleMap.Keyset()]){
                                                    
                            if(moduleIdProgramAssgn.containsKey(pa.Program_Module__c)){
                            
                                moduleIdProgramAssgn.get(pa.Program_Module__c).add(pa);
                                                         
                            }else{
                            
                                moduleIdProgramAssgn.Put(pa.Program_Module__c, new List<Program_Assignment__c>{pa}); 
                                     
                            } 
                            
                        }

                        if(moduleIdProgramAssgn.size() > 0){
                        
                            newHireAssignmentsForInsert = EnrollmentWizardHelper.createNewHireAssignmentFromPAssignment( newHireModulesForInsert, moduleIdProgramAssgn) ;   
                        
                        }
                        
                        system.debug('#####newHireAssignmentsForInsert -'+newHireAssignmentsForInsert);
                        
                        if(newHireAssignmentsForInsert.size()>0){
                        
                            List<Database.SaveResult> insertNHAssignmentResult = New List<Database.SaveResult>();             
                            isOnbPlanComplted=true;                              
                            insertNHAssignmentResult=Database.insert(newHireAssignmentsForInsert,false);//partial update 
                            system.debug('#####insertNHAssignmentResult--'+insertNHAssignmentResult);                        
                        
                        }
                        
                        Map<id,List<Program_Content__c>> programContentMap = new Map<id,List<Program_Content__c>>();
                        
                        List<New_Hire_Content__c> newHireContentForInsert = new List<New_Hire_Content__c>();                    
                        
                        for( Program_Content__c pc : [SELECT Program_Assignment__c, id, Name, Assignment_Content__r.name, Onboarding_Program__c, Assignment_Content__c, Assignment_Content__r.Description__c, Assignment_Content__r.Link_To_Document__c FROM Program_Content__c WHERE Onboarding_Program__c =: onbProgram]){
                            
                            if(programContentMap.containsKey(pc.Program_Assignment__c)){
                            
                                programContentMap.get(pc.Program_Assignment__c).add(pc);
                                                          
                            }else{
                            
                                programContentMap.Put(pc.Program_Assignment__c, new List<Program_Content__c>{pc}); 
                                     
                            }                   
                        
                        }                   
                        
                        if(programContentMap.size() > 0)
                        {                    
                            newHireContentForInsert = EnrollmentWizardHelper.createNewHireContentFromPContent(newHireAssignmentsForInsert,programContentMap) ;

                        } 
                        

                        if(newHireContentForInsert.size()>0){
                            
                            isOnbPlanComplted = true;                            
                            List<Database.SaveResult> insertcontentresult = New List<Database.SaveResult>();                            
                            insertcontentresult = Database.insert(newHireContentForInsert,false);                            
                            system.debug('#####insertcontentresult-'+newHireContentForInsert);                        
                        
                        }
                    
                        if(ObPlanUpdLst.size()>0)
                        {
                        
                            isOnbPlanComplted = true;                             
                            update ObPlanUpdLst;
                            
                            List<CollaborationGroupMember> chatterGrpMemList = new List<CollaborationGroupMember>();
                                                        
                            // #RQ-004021 : Added below code for adding New Hires as chatter group members based on onboarding plan chatter group for Onboarding Program based enrollments
                            if( opgm.Chatter_Group__c != null ){
                                
                                chatterGrpMemList = EnrollmentWizardHelper.addNewHireToChatterGrp(ObPlanUpdLst,opgm.Chatter_Group__c);
                                
                                if( chatterGrpMemList.Size()>0 ){
                                    
                                    List<Database.SaveResult> insertchatterGrpMemsresult = New List<Database.SaveResult>();                            
                                    insertchatterGrpMemsresult = Database.insert(chatterGrpMemList,false); 
                                    system.debug('#####insertchatterGrpMemsresult-'+insertchatterGrpMemsresult);  
                                }
                                
                            }
                                
                        }
                        if(isOnbPlanComplted){
                    
                            return Page.EnrollmentWizardFinish;
                        
                        }
                        
                    }catch(Exception e){
                        
                        system.debug('#####Exception --'+e);                        
                        isOnbPlanComplted = false;                        
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.EnrollmentNotCompleted ));
                        
                    }
                    return null;
                    
                }else if( selectedEnrollment == 'ah'){
                
                    PageReference pageRef = Page.EnrollmentWizardStep4;                    
                    return PageRef;
                
                }
                  
            }else{
            
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Label.ProgramNotSelected));            
            }
            
            return null;
            
        }
        
        
        /**
        *For redirecting the Onboarding Plan selection
        */
        public pageReference BackToPlan(){    

           searchText = '';
           searchOnbPlan();
           if(planSearchList != null && planSearchList.size()>0){
                
                con = new ApexPages.StandardSetController(planSearchList);  
       
                // sets the number of records in each page set  
                con.setPageSize(PAGE_SIZE); 
                
            }
            
            return Page.EnrollmentWizardStep2;
            
        }
        
        
        
        /**
        * Search available Onboarding Plans 
        */
        public Pagereference searchOnbPlan(){     
            

            if(searchText != null && searchText != ''){
            
                //Verfiy if entered search text has any special characters
                if( !searchText.isAlphanumericSpace()){
                    
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.EnterValidCharacters));
                    return Null;                
                } 

                if(searchText.length() < 2){
                
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.SearchText ));
                    return Null;

                }
                
            }
            
            // #RQ-004012 : Added Chatter_Group_URL__c field to queries below in order to add new hire to chatter group when enrolled for Ad-hoc Programs
            string loggedInUser = UserInfo.getUserId();                                    
            
            if(isMyOwnPlans && (searchText != '' || searchText != null)){

                planSearchList = [SELECT Id, Name, New_Hire__c, Onboarding_Program__c, Onboarder__c, Coordinator__c, Start_Date__c, Is_Ready__c, Chatter_Group_URL__c FROM Onboarding_Plan__c WHERE Is_Ready__c =: True AND Onboarding_Program__c = Null AND Coordinator__c =: loggedInUser AND Name LIKE : '%'+ searchText +'%' ORDER BY Name ASC];

            }else if(isMyOwnPlans){
               
               planSearchList = [SELECT Id, Name, New_Hire__c, Onboarding_Program__c, Onboarder__c, Coordinator__c, Start_Date__c, Is_Ready__c, Chatter_Group_URL__c FROM Onboarding_Plan__c WHERE Is_Ready__c =: True AND Onboarding_Program__c = Null AND Coordinator__c =: loggedInUser ORDER BY Name ASC];

            }else if(searchText != '' || searchText != null){

                planSearchList = [SELECT Id, Name, New_Hire__c, Onboarding_Program__c, Onboarder__c, Coordinator__c, Start_Date__c, Is_Ready__c, Chatter_Group_URL__c FROM Onboarding_Plan__c WHERE Is_Ready__c =: True AND Onboarding_Program__c = Null AND (Name LIKE : '%'+ searchText +'%') ORDER BY Name ASC ];

            }else{
            
                planSearchList = [SELECT Id, Name, New_Hire__c, Onboarding_Program__c, Onboarder__c, Coordinator__c, Start_Date__c, Chatter_Group_URL__c FROM Onboarding_Plan__c WHERE Is_Ready__c =: True AND Onboarding_Program__c = Null ORDER BY Name ASC ];
            }
            
            if(planSearchList.size() > 0){
                
                isOnbPlanPanel = true;                
                con = new ApexPages.StandardSetController(planSearchList);  
       
                // sets the number of records in each page set  
                con.setPageSize(PAGE_SIZE);

            }else{
                
                isOnbPlanPanel = false;                
                con = null;
                OnboardingPlanWrapperList.Clear();
                System.debug('##### OnboardingPlanWrapperList---'+OnboardingPlanWrapperList);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.info,Label.NoDataFound));                  
                return Null;
                
            }

            return null ; 
            
        }
      
      
        
        /**
        *returns a list of wrapper objects for the sObjects in the current page set
        */
        public List<EnrollmentWizardHelper.OnboardingPlanWrapper> getOnboardingPlanWrapperList() {
             
            OnboardingPlanWrapperList  =  new List<EnrollmentWizardHelper.OnboardingPlanWrapper>();
            
            if(con !=  null){

                for (Onboarding_Plan__c onboardPln : (List<Onboarding_Plan__c>)con.getRecords())
                {

                    if( selectedPlanWrapperList.get(onboardPln.id)  ==  null)
                    
                        OnboardingPlanWrapperList.add(new EnrollmentWizardHelper.OnboardingPlanWrapper(onboardPln,false));
                        
                    else
                    
                        OnboardingPlanWrapperList.add(new EnrollmentWizardHelper.OnboardingPlanWrapper(onboardPln,true));
        
                }
                return OnboardingPlanWrapperList;
            
            }else{
                
                return null;
    
            }
                
        }
      
        
        
        /**
        *For getting the selected plans
        */
        public void setSelectedPlanWrapperList()
        {

            for (EnrollmentWizardHelper.OnboardingPlanWrapper selectedOnbPlan: OnboardingPlanWrapperList) {
                
                if(selectedPlanWrapperList.containsKey(selectedOnbPlan.onbPlan.Id))
                {
                    
                    if (!selectedOnbPlan.isSelected ) 
                        selectedPlanWrapperList.remove(selectedOnbPlan.onbPlan.Id);
                        
                }else if (selectedOnbPlan.isSelected ){ 
                   
                    selectedPlanWrapperList.put(selectedOnbPlan.onbPlan.Id,selectedOnbPlan);
                        
                }
 
            }   

        }
    
    
    
        /**
        * For showing the Modules
        */
        public pageReference ProcessSelectedPlans()
        {
            
            system.debug('#####moduleSearchList in ProcessSelectedPlans- '+ moduleSearchList );
            system.debug('#####selectedEnrollment  in ProcessSelectedPlans- '+ selectedEnrollment  );            
                      
            setSelectedPlanWrapperList();
            
            if( !SelectedPlanWrapperList.isEmpty() && SelectedPlanWrapperList != null )
            {
                if( selectedEnrollment == 'op' ){
                        
                    PageReference pageRef  =  new PageReference('/apex/EnrollmentWizardStep3');
                        
                    return pageRef;
                                       
                }else if( selectedEnrollment == 'ah'){
                             
                    PageReference pageRef  =  new PageReference('/apex/EnrollmentWizardStep4');
                        
                    return pageRef;
                                    
                }
                
            }else{
                    
                //ensure user selected at least one Onboarding Plan or show an error message.
                ApexPages.Message msg  =  new ApexPages.message(ApexPages.severity.ERROR,Label.IsSelectPlan);
                ApexPages.addMessage(msg);   
                    
            }
            return null;
            
        }
    
    
        /**
        * the text in the search box
        */
        public string searchText {
        
            get {
            
                if (searchText  ==  null) searchText  =  ''; // prefill the serach box for ease of use
                return searchText;
                
            }
            set;
            
        }

        
        /**
        Pagination code         
        **/
        /**
        *returns the page number of the current page set
        */
        public Integer pageNumber {
        
            get {
            
               if(con != null){               
                    return con.getPageNumber();                
                }else{               
                    return null;                
                }
                
            }
            set;
            
        }
        
        
        
        /**
        * for new enrollment process
        */
        public pagereference gotoEnrollMntProcess(){
          
            String urlString = '/apex/EnrollmentWizardStep1';   
            PageReference pageRef = new PageReference(urlString);
            pageRef.setRedirect(true);
            return pageRef;
            
        }
        
        
        
        /**
        *Indicates whether there are more records after the current page set.
        */
        public Boolean hasNext {
        
            get {
            
                    if(con != null){
                    
                        updateRecordIndex();                         
                        return con.getHasNext();
                        
                    }else{
                    
                        return null;
                        
                    }
                    
                }
            set;
            
        }
        
        
        
        /**
        *Indicates whether there are more records before the current page set.
        */
        public Boolean hasPrevious {
        
            get {
                   
                    if(con != null){
                   
                        updateRecordIndex();                         
                        return con.getHasPrevious();
                        
                    }else{
                    
                        return null;
                        
                    }
                    
                }
            set;
            
        }
        
        
        
        /**
        *Returns the number of Records in Set
        */
        public Integer totalPages {
            
            get { 
                    if(con != null){    
                        Decimal totalSize = this.Con.getResultSize();
                        Decimal pageSize = this.Con.getPageSize();                
                        Decimal pages = totalSize/pageSize;
                 
                        return (Integer)pages.round(System.RoundingMode.CEILING);
                    }else{
                    
                        return null;

                    }
                }
            set;
            
        }

        
        
        /**
        *for calculating the number of records per page
        */
        public void updateRecordIndex()
        {
            
            startIndex  =  ((con.getPageNumber()-1)*(con.getPageSize()))+1;            
            endIndex  =  (con.getPageNumber())*(con.getPageSize());
            
            if(endIndex>con.getResultSize())
                endIndex = con.getResultSize();
                
        }
        
        
        
        /**
        *returns the first page of records
        */
        public void dofirst() {
        
            if(con != null){
                
                if(isModuleAvailable)
                {
                    
                    selectedModule();
                    
                }else{
                
                    setSelectedPlanWrapperList();
                    
                }
                
                this.con.first();
            }
             
        }

        
        
        /**
        *returns the last page of records
        */
        public void dolast() {
        
            if(isModuleAvailable)
            {
                
                selectedModule();
                
            }else{
            
                setSelectedPlanWrapperList();
                
            }        
            
            this.con.last();
             
        }

        
        
        /**
        *returns the previous page of records
        */
        public void doprevious() {
        
            if(isModuleAvailable)
            {
                
                selectedModule();
                
            }else{
            
                setSelectedPlanWrapperList();
                
            }       

            this.con.previous();
            
        }

        
        
        /**
        *returns the next page of records
        */
        public void donext() {
        
            if(isModuleAvailable)
            {
                
                selectedModule();
                
            }else{
            
                setSelectedPlanWrapperList();
                
            }            

            this.con.next();
            
        }  



        /**
        * For displaying the all the Modules 
        */
        public void allModules(){
        
            //SOQL Query for returning the plans which have the ready status //#SP-0013/#RQ-000851 : Added Badge_Content_Version_Id__c in the query. /#RQ-009241 - Added Last_Module__c in query
            moduleSearchList = [SELECT id, name, Duration__c, Category__c , Is_Ready__c, Badge_Name__c, Badge_URL__c, Badge_Content_Version_Id__c, Description__c, Order__c, Last_Module__c 
                                FROM Module__c 
                                WHERE Is_Ready__c = TRUE ORDER BY Name ASC LIMIT 1000 ];
            
            if(moduleSearchList.size() > 0){
                
                isModuleAvailable = true;
                con = new ApexPages.StandardSetController(moduleSearchList);  
           
                // sets the number of records in each page set  
                con.setPageSize(PAGE_SIZE);
                
            }else{
                
                con = null;                
                isModuleAvailable = false ;                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.info,Label.NoModulesFound));
                
            }              
        
        }
        
        
        
        /**
        *returns a list of wrapper objects for the sObjects in the current page set
        */
        public List<EnrollmentWizardHelper.ModuleWrapper> getModuleWrapperList() {
            
            ModuleWrapperList = new List<EnrollmentWizardHelper.ModuleWrapper>();
            
            if(con != null){
            
                isModuleAvailable= True;
                
                for (Module__c mdlObj : (List<Module__c>)con.getRecords())
                {
                    
                    if( selectedModuleWrapperMap.get(mdlObj.id) == null)
                    
                        ModuleWrapperList.add(new EnrollmentWizardHelper.ModuleWrapper(mdlObj,false,0));
                        
                    else
                    
                        ModuleWrapperList.add(new EnrollmentWizardHelper.ModuleWrapper(mdlObj,true,0));
        
                }
                
                return ModuleWrapperList;
            
            }else{
            
                isModuleAvailable= False;
                return null;

            }
        }
        
        
        
        /**
        * Storing all the records into wrapper.
        */
        public List<EnrollmentWizardHelper.ModuleWrapper> selectedModulesLst {
        
            get {
            
                if (selectedModulesLst == null) selectedModulesLst = new List<EnrollmentWizardHelper.ModuleWrapper>();
                    return selectedModulesLst;                
            }
            set;
            
        } 
        
        
        
        /**
        * for getting the selected modules
        */
        public void selectedModule()
        {
            
            for (EnrollmentWizardHelper.ModuleWrapper moduleobj : ModuleWrapperList) {
            
                if(selectedModuleWrapperMap.containsKey(moduleobj.Module.Id))
                {
                    if (!moduleobj.isSelected)
                        selectedModuleWrapperMap.remove(moduleobj.Module.Id);
                }
                else
                {
                    if (moduleobj.isSelected)
                        selectedModuleWrapperMap.put(moduleobj.Module.Id,moduleobj);
                }   
                
            }   
            
        }
        
        
            
        /**
        * For enrolling the Onboarding plans.
        * #SP-0007. Method updated. This method will redirect to a new page where need to order the modules.
        */
        public pagereference EnrollModulesToPlan() {
            
            Savepoint sp = Database.setSavepoint();
            
            try{
                
                    selectedModulesMap = new Map <Id,Module__c> ();                                    
                    selectedModule();                   
                    List<Module__C> mdlUpdLst=new List<Module__c>();
                    set<id> obProgramSet = new set<id>();
                    selectedModulesLst = new List <EnrollmentWizardHelper.ModuleWrapper>();
                    
                    // add the selected Modules to a new List
                    for (EnrollmentWizardHelper.ModuleWrapper m : selectedModuleWrapperMap.values()) {
                    
                        selectedModulesMap.put(m.Module.id,m.Module);
                        selectedModulesLst.add(new EnrollmentWizardHelper.ModuleWrapper(m.Module,true,m.Module.Order__c));
                            
                    }
                    
                    if(selectedModulesMap.isEmpty()){
       
                        //ensure they selected at least one module or show an error message. 
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.SelectModule));
                        return null;
                       
                    }else{
                       
                        String urlString = '/apex/enrollmentwizardstep5';    
                        PageReference pageRef = new PageReference(urlString);
                        return pageRef;
                        
                    }
                 
             }catch(Exception e){
            
                // Roll the database back to before we saved ANYTHING
                system.debug('#####Exception -'+e);                
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.EnrollmentNotCompleted ));                
                
            }     
            return null;
        }
    
       
       
        /*
         * #SP-0007. New method added.
         * Incase od Ad-hoc modules, once the modules are slected , they need to be ordered.
         */ 
        public pageReference enrollOrderedModules() {
            
            Map <Id,Module__c> orderedModulesMap = new Map <Id,Module__c> ();
            List<New_Hire_Module__c> newHireModulesForInsert = new List<New_Hire_Module__c>();   //to be created
            List<Onboarding_Plan__c> selectedObPlansIds = new List<Onboarding_Plan__c>();
            Map<Id,Onboarding_Plan__c> selectedOnbPlanMap = new Map<Id,Onboarding_Plan__c>();
            
            try{
                setSelectedPlanWrapperList();
                for (EnrollmentWizardHelper.OnboardingPlanWrapper ow : SelectedPlanWrapperList.values()) {                        
                        selectedObPlansIds.add(ow.onbPlan);  //selected plans                             
                }
            
            
                if(selectedObPlansIds.size()>0){
                    selectedOnbPlanMap = new Map<Id,Onboarding_Plan__c>([SELECT Id, New_Hire__c, Status__c, Chatter_Group_URL__c
                                                                         FROM Onboarding_Plan__c 
                                                                         WHERE ID IN : selectedObPlansIds]);
                    
                    //Call method to create new hire modules
                    newHireModulesForInsert=EnrollmentWizardHelper.createNewHireModuleFromModule(selectedOnbPlanMap.values(),selectedModulesLst) ;        
                    system.debug('##### newHireModulesForInsert -'+newHireModulesForInsert);
                 }
                
                //Insert list of modules for OnbPlan
                if(!newHireModulesForInsert.IsEmpty()){
                
                    isOnbPlanComplted=true;
                    system.debug('##### Inserting newHireModulesForInsert - selectedModulesMap-'+selectedModulesMap);
                    Database.insert(newHireModulesForInsert,true); // Here partial insert should not be done. This is to capture the Duplicate order validation.
                
                }               
            
                //New Hire Assignment Insertion
                Map<Id,List<Module_Assignment__c>> moduleIdAssignmentMap = new Map<Id,List<Module_Assignment__c>>();                   
                List<New_Hire_Assignments__c> newHireAssignmentsForInsert = new List<New_Hire_Assignments__c>();
                Set<ID> moduleAssgnId= new Set<ID>();
                
                
                for(Module_Assignment__c a : [SELECT Module__r.id, id, Name, Description__c, Order__c, Module__r.Name 
                                              FROM Module_Assignment__c 
                                              WHERE Module__r.id IN: selectedModulesMap.KeySet()]){
                                                                  
                        if(moduleIdAssignmentMap.containsKey(a.Module__r.id)){               
                            moduleIdAssignmentMap.get(a.Module__r.id).add(a);                                              
                        }else{                
                            moduleIdAssignmentMap.Put(a.Module__r.id, new List<Module_Assignment__c>{a});                          
                        }
                            
                        moduleAssgnId.add(a.id);                          
                }
                
                if(moduleIdAssignmentMap.size() > 0){                
                    newHireAssignmentsForInsert = EnrollmentWizardHelper.createNewHireAssignmentFromAssignment(newHireModulesForInsert,moduleIdAssignmentMap) ;            
                }           
                
                system.debug('##### newHireAssignmentsForInsert -'+newHireAssignmentsForInsert);
                
                //Insert list of modules for OnbPlan
                if(!newHireAssignmentsForInsert.IsEmpty()){
                
                    List<Database.SaveResult> insertNHAssignmentResult= New List<Database.SaveResult>();                
                    isOnbPlanComplted=true;                 
                    insertNHAssignmentResult=Database.insert(newHireAssignmentsForInsert,false);//partial update             
                    system.debug('##### insertNHAssignmentResult--'+insertNHAssignmentResult);
                    
                }              
                
                //New hire content assignment   
                Map<Id,List<Assignmen_Content__c>> assgnIdAssgnContentMap = new Map<Id,List<Assignmen_Content__c>>();            
                List<New_Hire_Content__c> newHireContentsForInsert = new List<New_Hire_Content__c>();
                
                for(Assignmen_Content__c a : [SELECT id, Name ,Module_Assignment__r.id 
                                              FROM Assignmen_Content__c 
                                              WHERE Module_Assignment__c IN : moduleAssgnId]){
                    
                    if(assgnIdAssgnContentMap.containsKey(a.Module_Assignment__r.id)){                
                        assgnIdAssgnContentMap.get(a.Module_Assignment__r.id).add(a);                                              
                    }else{                
                        assgnIdAssgnContentMap.Put(a.Module_Assignment__r.id, new List<Assignmen_Content__c>{a}); 
                            
                    }  
                    
                }                    
                
                if(assgnIdAssgnContentMap.size()>0){           
                    newHireContentsForInsert = EnrollmentWizardHelper.createNewHireContentFromContent(newHireAssignmentsForInsert,assgnIdAssgnContentMap) ;            
                }           
                
                if(newHireContentsForInsert.size()>0){
                
                    isOnbPlanComplted = true;
                    List<Database.SaveResult> insertcontentresult = New List<Database.SaveResult>();
                    insertcontentresult = Database.insert(newHireContentsForInsert,false);
                    system.debug('##### insertcontentresult-'+insertcontentresult);
                    
                }
                
                for(Onboarding_Plan__c plan : selectedOnbPlanMap.values()){ 
                
                    plan.Status__c = 'Enrolled';
                    plan.Enrolled_Or_Onboarded__c = 1;
                    selectedOnbPlanMap.put(plan.id,plan) ; //updated map with status of Onb plan set as enroll 
                    
                }       
                
                if(selectedOnbPlanMap.size()>0){
                    
                    update selectedOnbPlanMap.values();
                    isOnbPlanComplted=true;   
                    
                    // #RQ-004021 : Added below code for adding New Hires as chatter group members based on onboarding plan chatter group for Adhoc Programs based enrollments

                    List<CollaborationGroupMember> chatterGrpMemList = new List<CollaborationGroupMember>();
                    System.debug('###### selectedOnbPlanMap.values()'+ selectedOnbPlanMap.values());
                    chatterGrpMemList = EnrollmentWizardHelper.addNewHireToChrGrpForAdhocPrg(selectedOnbPlanMap.values());
                    System.debug('#########'+chatterGrpMemList);
                    if( chatterGrpMemList.Size()>0 ){
                        
                        List<Database.SaveResult> insertchatterGrpMemsresult = New List<Database.SaveResult>();                            
                        insertchatterGrpMemsresult = Database.insert(chatterGrpMemList,false); 
                        system.debug('#####insertchatterGrpMemsresult-'+insertchatterGrpMemsresult); 
                        
                    }
                }  
                
                if(isOnbPlanComplted)                       
                    return Page.EnrollmentWizardFinish;           
                else return null;
                           
            }
            Catch(Exception e){
                
               if(e.getMessage().contains ('DUPLICATE_VALUE'))
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Label.Order_Should_Be_Unique));// If there are any dupliacte order entered.
               else
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Label.EnrollmentNotCompleted));
               return null;                    

            }
            
        }   
        
    
        //#SP-0007/#RQ-000645. Method to direct users to Onboarding plan tab once Enrollment is done.
        public pageReference backToOnboardingPlanTab() {
        
            String keyPrefix = Onboarding_Plan__c.sObjectType.getDescribe().getKeyPrefix();           
            String urlString = '/'+keyPrefix+'/'+'o';    
            PageReference pageRef = new PageReference(urlString);
            return pageRef;
            
        }
        
        //#SP-0007.For back button in the Step 5 page.
        public pageReference backToModuleSelect() {
        
            return page.EnrollmentWizardStep4;
            
        }
        
    }