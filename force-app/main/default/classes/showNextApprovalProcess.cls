/*
 * Test class : showNextApprovalProcess_test
* Revision 	Ref Number	Date			Owner					Description
* -------- 	----------	-----------		-----------------		-----------
* 1.0      				28/04/2023		Rama@maersk				Code created for show next approver
* 2.0		SFSE-11583	06-Jul-2023		Kiran@Maersk			OMEB 3.1 Full Approval Process
* 3.0		SFSE-11132	26-Jul-2023		Jothsana@Maersk			New Global Hub Product added
* 4.0       SFSE-11131	03-Aug-2023		Jaya@UST				Removal of Pursuit Gate
* 5.0       SFSE-12126  28-Aug-2023     Aleena@Maersk           New Last Miles Product added
* 6.1       SFSE-12089  01-Sep-2023     Shilpa@maersk           CL product added in implementation step
* 7.0       SFSE-12427  15-sep-2023     Aleena@maersk           New Revised Last Miles Product added  
* 8.0       SFSE-12662  08-sep-2023     Aleena@maersk           Removal of CCL3 from plaform sub gate.
* 9.0       SFSE-13042  12-dec-2023     Aleena@maersk           Addition of Reneweal logic to remove platform for certain products
* 10.0      SFSE-13562  19-jan-2023     Aleena@maersk           New OMEB Product Middle Mile Logic addition for tree
* 11.0		SFSE-14118	11-Mar-2024		Jothsana@Maersk			Removing Maersk Flow(MF1) from OMEB
* 12.0      SFSE-13089  18-Mar-2024     Aleena@Maersk           Adding CS for implementation sub-gate
* 13.0		SFSE-14873	28-05-2024		Jothsana@Maersk			Addition of logic to remove platform steps for certain products for Renewal,Addition Business opportunities
*/
public class showNextApprovalProcess {
    private static Opportunity opportunityRecord;
    private static List<Opportunity_Product__c> opptyProducts;
    public static String oppId;
    private static Map<String, List<String>> mapGateToProcessNames;
    private static List<String> processNameList;
    private static final String pursuitGate = 'Pursuit Gate';
    private static final String qualificationGate = 'Qualification Gate';
    private static final String solutionGate = 'Solution Gate';
    private static final String prewinGate = 'Pre-Win Gate';
    private static final String pursuit = System.Label.Pursuit_Gate;
    private static final String qualification = System.Label.Feasibility_Gate;
    private static final String solution = System.Label.Solution_Gate;
    private static final String prewin = System.Label.Pre_Win_Gate;
    public static List<Approval_Process_Escalation_Matrix__c> approvalMatrixForShowNextApprover;
    private static Map<String, List<ApproverWrapper>> appWrapMap;
    private static Set<String> setApprovedProcessNames;
    private static Map<String, Integer> mapGateNameToOrder = new Map<String, Integer>{pursuit => 1, qualification => 2, solution => 3, prewin => 4};
    private static String opptyCurrentGateName;
    private static List<String> previousApprovedGates;
    private static String productForApproval;
    private static String duedays = '-';
    private static String opptyType;
    
    @AuraEnabled
    public static Map<String, List<ApproverWrapper>> getNextApprover(String recordId){
        setApprovedProcessNames = new Set<String>();
        appWrapMap = new Map<String, List<ApproverWrapper>>();
        appWrapMap.put(pursuit, new List<ApproverWrapper>());
        appWrapMap.put(qualification, new List<ApproverWrapper>());
        appWrapMap.put(solution, new List<ApproverWrapper>());
        appWrapMap.put(prewin, new List<ApproverWrapper>());
        processNameList = new List<String>();
        approvalMatrixForShowNextApprover = new List<Approval_Process_Escalation_Matrix__c>();
        productForApproval = '';
        try{
            opportunityRecord = [Select Id, Owner.Region__c, Owner_Area_Code__c, OwnerId, Type,Liner_Brand__c, Opportunity_Owner_Country__c, Total_GP_of_OMEB_Products__c, 
                                 StageName, Account.Vertical__c,Account.Attractiveness__c, Products_for_Approval__c, Approval_Status__c, Requires_IT_Integration__c 
                                 FROM Opportunity WHERE id =:recordId];
            if(opportunityRecord.Products_for_Approval__c != null && opportunityRecord.Products_for_Approval__c != ''){
                productForApproval = opportunityRecord.Products_for_Approval__c;
            }
            oppId=opportunityRecord.id;
             if(opportunityRecord.Type != null){
                    opptyType = opportunityRecord.Type;
                }   
            

            getProcessNameList();
            
            addApprovedHistory();
            
            for(String gateName : mapGateToProcessNames.keySet()){
                if(!previousApprovedGates.contains(gateName.split(' ')[0])){
                    processNameList.addAll(mapGateToProcessNames.get(gateName));
                }
            }
            
            System.debug('processNameList @@ ' +processNameList.size());
            
            List<CustomApprovalProcessHandler.ApprovalWrapper> wrapList = new List<CustomApprovalProcessHandler.ApprovalWrapper>();
            CustomApprovalProcessHandler.ApprovalWrapper wrap = new CustomApprovalProcessHandler.ApprovalWrapper();
            wrap.recordId = opportunityRecord.Id;
            wrap.processNameList = processNameList;
            wrap.reqFromShowNextApprover = true;
            wrapList.add(wrap);
            
            CustomApprovalProcessHandler.submitForApprovalInstanceInvocable(wrapList);
         
            system.debug('approvalMatrixForShowNextApprover@@'+approvalMatrixForShowNextApprover);
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixForShowNextApprover){
                if(!setApprovedProcessNames.contains(matrix.Approval_Process_Name__r.Name)){
                    if(matrix.Approval_Process_Name__r.Name == Label.OMEB_Pursuit_Gate_Products && opportunityRecord.Opportunity_Owner_Country__c != matrix.Country__r.Name){
                        appWrapMap.get(matrix.Approval_Process_Name__r.Gate__c).add(new ApproverWrapper(matrix.Approval_Process_Name__r.name, matrix.Current_owner__r.Name, 'NA', '-', opportunityRecord.Approval_Status__c, matrix.Current_owner__c, ''));   
                    }else if(matrix.Approval_Process_Name__r.Name != Label.OMEB_Pursuit_Gate_Products){ 
                 
                        appWrapMap.get(matrix.Approval_Process_Name__r.Gate__c).add(new ApproverWrapper(matrix.Approval_Process_Name__r.name, matrix.Current_owner__r.Name, 'NA', '-', opportunityRecord.Approval_Status__c, matrix.Current_owner__c, '')); 
                    }                                                                  // public ApproverWrapper(String processName, String approverName,string approvalStatus,String dueDays,String opptapprovalStatus,string assignedToId,String ahtype){
                }
            }
        }catch(exception ex){
            System.debug('Exception line number @@'+ ex.getLineNumber() +'Exception message @@@ '+ex.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'OMEB 3.0', 'ShowNextApprovalProcessNew.getNextApprover', new list<Exception>{ex});
        }
        return appWrapMap;
    }
    
    private static void addApprovedHistory(){
        previousApprovedGates = new List<String>();
        
        List<Approval_History__c> oppApprovalHist = [SELECT TargetObjectId__c, Submitter_Comments__c,Type__c,
                                                     Step_Name__c, Status__c, Name, IsDeleted, Id,CreatedDate, 
                                                     Approver_Comments__c, Approval_Step__r.Current_owner__r.name,Approval_Step__r.Approval_Process_Name__r.name,Approved_By__r.Name,
                                                     Approval_Step__r.Approval_Process_Name__r.Gate__c, Action_Date__c, Approval_Step__r.Auto_Approved__c
                                                     FROM Approval_History__c 
                                                     WHERE TargetObjectId__c =:opportunityRecord.Id ORDER By CreatedDate ASC ];
        
        Integer gateOrder;
        for(String gateName : mapGateNameToOrder.keySet()){
            if(opportunityRecord.Approval_Status__c == '' || opportunityRecord.Approval_Status__c == null){
                opptyCurrentGateName = pursuit;
            }
            
            if(opportunityRecord.Approval_Status__c != null && opportunityRecord.Approval_Status__c.containsIgnoreCase(gateName)){
                opptyCurrentGateName = gateName;
            }
            
            if(opptyCurrentGateName != null){
                gateOrder = mapGateNameToOrder.get(opptyCurrentGateName);
            }
            
        }
        
        if(opportunityRecord.Approval_Status__c != null && opportunityRecord.Approval_Status__c.containsIgnoreCase('Approved')){
            gateOrder = gateOrder + 1;
        }
     
        for(String gateName : mapGateNameToOrder.keySet()){
            if(mapGateNameToOrder.get(gateName) < gateOrder){
                previousApprovedGates.add(gateName);
            }
        }
       
        for(Approval_History__c history : oppApprovalHist){
            if(history.Status__c != 'No response'){
                
                if(history.Status__c == 'Pending' || 
                   (history.Approval_Step__r.Auto_Approved__c && opportunityRecord.Approval_Status__c != null && (opportunityRecord.Approval_Status__c.containsIgnoreCase('Submitted') || opportunityRecord.Approval_Status__c.containsIgnoreCase('Approved'))) ||
                   (history.Status__c == 'Approved' && !history.Step_Name__c.containsIgnoreCase(opptyCurrentGateName)) || 
                  (history.Status__c == 'Approved' && opportunityRecord.Approval_Status__c != null && opportunityRecord.Approval_Status__c.containsIgnoreCase('Submitted') && history.Step_Name__c.containsIgnoreCase(opptyCurrentGateName))){
                       setApprovedProcessNames.add(history.Approval_Step__r.Approval_Process_Name__r.name);
                   }
                
                if(history.Approval_Step__c != null && history.Approval_Step__r.Approval_Process_Name__c != null && history.Approval_Step__r.Approval_Process_Name__r.Gate__c != null && 
                   
                   appWrapMap.containsKey(history.Approval_Step__r.Approval_Process_Name__r.Gate__c)){
                       duedays = '-';
                       if(history.Status__c == 'Pending'){
                           duedays = String.ValueOf(getdueDays(history.CreatedDate));
                           if(history.Type__c == 'Escalation'){
                               history.Status__c = 'Escalation';
                           }
                           if(!String.isBlank(duedays)){
                               if(duedays=='1'){
                                   duedays= duedays + ' Day';
                               }else if(Integer.valueof(duedays)>1){
                                   duedays= duedays + ' Days';   
                               }
                           }else{
                               duedays = '-';
                           }
                       }
                       appWrapMap.get(history.Approval_Step__r.Approval_Process_Name__r.Gate__c).add(new ApproverWrapper(history.Approval_Step__r.Approval_Process_Name__r.name, history.Approved_By__r.Name , history.Status__c , duedays, opportunityRecord.Approval_Status__c, history.Approved_By__c, history.Type__c));
                   }
            }
        }
    }
    
    private static void getProcessNameList(){
        mapGateToProcessNames = new map<String, List<String>>();
        mapGateToProcessNames.put(pursuitGate, new List<String>());
        mapGateToProcessNames.put(qualificationGate, new List<String>());
        mapGateToProcessNames.put(solutionGate, new List<String>());
        mapGateToProcessNames.put(prewinGate, new List<String>());
        
        addPursuitProcessNames();
        addQualificationProcessNames();
        addSolutionProcessNames();
        addPrewinProcessNames();
        
        
    }
    
    private static void addPursuitProcessNames(){
        String attractiveness = opportunityRecord.Account != null ? opportunityRecord.Account.Attractiveness__c : null;
      /*  if( ((productForApproval.containsIgnoreCase('MF1') || productForApproval.containsIgnoreCase('CL') || productForApproval.containsIgnoreCase('GL')) ) &&
          !(productForApproval.containsIgnoreCase('4PL') || productForApproval.containsIgnoreCase('SCM') || productForApproval.containsIgnoreCase('CCL') || productForApproval.containsIgnoreCase('ECM') || productForApproval.containsIgnoreCase('CS') || productForApproval.containsIgnoreCase('WD') || productForApproval.containsIgnoreCase('GH'))){
            mapGateToProcessNames.get(pursuitGate).add('Pursuit Gate Auto Approval MF/CL');
        }else */if(attractiveness != null && (attractiveness.containsIgnoreCase('Key Client') || attractiveness.containsIgnoreCase('Runway') || attractiveness.containsIgnoreCase('Booster'))){
            mapGateToProcessNames.get(pursuitGate).add('Pursuit gate-auto pass KC/Booster/RC');
        }else{
           /* if(opportunityRecord.Owner_Area_Code__c == 'NOA'){
                mapGateToProcessNames.get(pursuitGate).add('Pursuit Gate Sales -Auto Approve-NAM');
            }else if(opportunityRecord.Liner_Brand__c == BrandUtilities.MAERSKLINE){
                mapGateToProcessNames.get(pursuitGate).add('Pursuit Gate Sales Maersk');
            }else if(opportunityRecord.Liner_Brand__c == BrandUtilities.HAMBURGSUD){
                mapGateToProcessNames.get(pursuitGate).add('Pursuit Gate Sales Hamburg Sud');
            }else if(opportunityRecord.Liner_Brand__c == BrandUtilities.SEAGO || opportunityRecord.Liner_Brand__c == BrandUtilities.SEALAND || opportunityRecord.Liner_Brand__c == BrandUtilities.MCC){
                mapGateToProcessNames.get(pursuitGate).add('Pursuit Gate Sales Sealand');
            } */
            if(productForApproval.containsIgnoreCase('WD')){
                mapGateToProcessNames.get(pursuitGate).add('Pursuit Gate Products');
            }
        }
    }
    
    private static void addQualificationProcessNames(){
        
        if( ((productForApproval.containsIgnoreCase('CL') || productForApproval.containsIgnoreCase('GL') || productForApproval.containsIgnoreCase('AL') || productForApproval.containsIgnoreCase('MC') || productForApproval.containsIgnoreCase('LM') || productForApproval.containsIgnoreCase('MM') )) &&
          !(productForApproval.containsIgnoreCase('4PL') || productForApproval.containsIgnoreCase('SCM') || productForApproval.containsIgnoreCase('CCL') || productForApproval.containsIgnoreCase('ECM') || productForApproval.containsIgnoreCase('CS') || productForApproval.containsIgnoreCase('WD') || productForApproval.containsIgnoreCase('GH') || productForApproval.containsIgnoreCase('SMD'))){
            mapGateToProcessNames.get(qualificationGate).add('Qualification Gate Auto Approval');
        }else{
            
            mapGateToProcessNames.get(qualificationGate).add('Qualification Gate Products');
            if((productForApproval.containsIgnoreCase('WD') && opptyType!='Renewal')||productForApproval.containsIgnoreCase('CS')||productForApproval.containsIgnoreCase('GH')){
                mapGateToProcessNames.get(qualificationGate).add('Qualification Gate Platform');}
            if(productForApproval.contains('ECM')){
                mapGateToProcessNames.get(qualificationGate).add('Qualification Gate Platform Auto-Approve');
            }
        }
    }
    
    private static void addSolutionProcessNames(){
            if(productForApproval.contains('ECM')){
                mapGateToProcessNames.get(solutionGate).add('Solution Gate Platform Auto-Approve ECM');
            }
            
            mapGateToProcessNames.get(solutionGate).add('Solution Gate Products');
            //Solution Gate Platfom
            if((productForApproval.containsIgnoreCase('AL') && !(opportunityRecord.Requires_IT_Integration__c == 'No, this is not required. Customer system will not connect with Maersk in any way'))
              || (productForApproval.containsIgnoreCase('CL01') && opptyType!='Renewal')|| (productForApproval.containsIgnoreCase('CL02') && opptyType!='Renewal')||(productForApproval.containsIgnoreCase('CL03') && opptyType!='Renewal' )|| productForApproval.containsIgnoreCase('GL') || productForApproval.containsIgnoreCase('MC') ||
              ((opptyType!='Additional Business' && opptyType!='Renewal') && ( productForApproval.containsIgnoreCase('4PL') || productForApproval.containsIgnoreCase('SCM') || productForApproval.containsIgnoreCase('CCL')))
              || productForApproval.containsIgnoreCase('CS') || (productForApproval.containsIgnoreCase('WD') && opptyType!='Renewal') || productForApproval.containsIgnoreCase('GH') || productForApproval.containsIgnoreCase('LM') || productForApproval.containsIgnoreCase('MM')){
            mapGateToProcessNames.get(solutionGate).add('Solution Gate Platform');
               }
            mapGateToProcessNames.get(solutionGate).add('Solution Gate Finance');
            
            if(productForApproval.contains('4PL') || productForApproval.contains('SCM') || productForApproval.contains('WD') || productForApproval.contains('GH') || productForApproval.contains('SMD') || productForApproval.contains('CS') || productForApproval.contains('CCL2')){
                mapGateToProcessNames.get(solutionGate).add('Solution Gate Implement'); 
            }
            
            if(opportunityRecord.Requires_IT_Integration__c == 'Yes, I am sure this is required basis my discussion with customer' || 
               opportunityRecord.Requires_IT_Integration__c == 'I am not sure as customer hasn’t informed me about this'){
                   mapGateToProcessNames.get(solutionGate).add('Solution Gate EDI/API');
               }
    }
    
    private static void addPrewinProcessNames(){
            if(productForApproval.contains('ECM')){
                mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate Platform Auto- Approve ECM');
            }
            if(productForApproval.contains('LM')){
              mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate Auto Approval Last Mile');  
            }
            if(productForApproval.contains('AL')){
            mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate Auto Approval Air_LCL');
          }
            // Pre-Win Product
            mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate Products');
            //Pre-Win gate platform
            if((opptyType !='Additional Business' && opptyType!='Renewal' && (productForApproval.containsIgnoreCase('4PL') || productForApproval.containsIgnoreCase('SCM') || productForApproval.containsIgnoreCase('CCL')))
               ||productForApproval.containsIgnoreCase('MM')|| productForApproval.containsIgnoreCase('CS') || (productForApproval.containsIgnoreCase('WD') && opptyType!='Renewal') ||productForApproval.containsIgnoreCase('GH') || productForApproval.containsIgnoreCase('GL') || productForApproval.containsIgnoreCase('MC') 
               || (productForApproval.containsIgnoreCase('CL01') && opptyType!='Renewal')||(productForApproval.containsIgnoreCase('CL02') && opptyType!='Renewal')||(productForApproval.containsIgnoreCase('CL02') && opptyType!='Renewal')){
                mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate Platform');}
            mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate Finance');
            
            if(productForApproval.contains('4PL') || productForApproval.contains('SCM') || productForApproval.contains('WD') || productForApproval.contains('GH') || productForApproval.contains('SMD') || productForApproval.contains('CS') || productForApproval.contains('CCL2')){
                mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate Implement');
            }
            
            if(opportunityRecord.Requires_IT_Integration__c == 'Yes, I am sure this is required basis my discussion with customer' || 
               opportunityRecord.Requires_IT_Integration__c == 'I am not sure as customer hasn’t informed me about this'){
                   mapGateToProcessNames.get(prewinGate).add('Pre-Win Gate EDI/API');
               }
    }
    private static Integer getdueDays(Datetime SubmiitedDate) {
        Date piDate =date.newInstance(SubmiitedDate.year(),SubmiitedDate.month(),SubmiitedDate.day());
        Integer noOfDaysElapsed = piDate.daysBetween(Date.today());
        return noOfDaysElapsed;
    }
    
    public class ApproverWrapper{
        @AuraEnabled public String opptapprovalStatus;
        @AuraEnabled public String processName;
        @AuraEnabled public String approverName;
        @AuraEnabled public String approvalStatus;
        @AuraEnabled public String dueDays;
        @AuraEnabled public String assignedToId;
        @AuraEnabled public String assignedToUrl;
        @AuraEnabled public String ahtype;
        public ApproverWrapper(String processName, String approverName,string approvalStatus,String dueDays,String opptapprovalStatus,string assignedToId,String ahtype){
            this.processName = processName;
            this.approverName = approverName;
            this.approvalStatus = approvalStatus;
            this.dueDays = dueDays;
            this.opptapprovalStatus = opptapprovalStatus;
            this.assignedToId = assignedToId;
            if(assignedToId!=null){
                this.assignedToUrl = '/'+assignedToId;
            }
            this.ahtype = ahtype;
        }
    }
}