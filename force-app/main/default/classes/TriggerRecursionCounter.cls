/*
Change Log
--------------------------------------------------------------------------
Sr# Description                                                               Updated By            Updated On
1   Added variable to stop recursion of Target triger                         Deepa-UST             30/06/2014
2   Added method to prevent invoke of update trigger on Caseafter WFR update  Vivek-Accenture       02/07/2014
3  Added Trigger Recurssion logic using Counter varibale and to support more  Prashanth-Accenture   27/10/2015
   than one trigger recursion.(#RQ-002106)
4  #002171 - Added to reduce Query execution in bINS_bUpd_populateOpportunityOwnerTrigger   Dinesh -UST    05/11/2015
5  #RQ-002190 - Added flag for DuplicateCaseManagerExtension to identify if deletion 
   of emails in case has been initiated as part of merging dupicate cases                   Meghana.gupta@ust-global.com    1/1/2016
6  #RQ-007205 - Remove the Eloqua managed package now moved to SFMC             Madhubharathi.Gopalakrishnan@ust-global.com  30/01/2018
-------------------------------------------------------------------------- 
*/
public class TriggerRecursionCounter 
{
  public static Boolean IsInsideContactTrigger = false;
  public static Boolean IsInsideBeforeContactTrigger = false;
  //public static Boolean invokedFromSubscriptionCount = false; // #RQ-002098
  //public static Boolean invokedFromTradeCount = false; // #RQ-002098
  public static Boolean invokedFromMergeDeletion = false;
  public static Boolean invokedFromCampaginMember = false;
  public static Boolean invokedFromRecUpdate = false;
  public static Boolean isOpportunityClone = false;
    
  public static Boolean IsInvoked_PopulateCountryClusterOnLead = false; // Used in bIns_bUPD_PopulateCountryClusterOnLead Trigger to prevent recursive calls
  /** INC000005898469 - Code Fix Start **/
  public static Set<ID> idStaticLeadsWithCountryPopulated= New Set<ID>(); //Store Lead Ids where Country is not China & Country is changed and need to Re-Trigger assignment Rule
  /** INC000005898469 - Code Fix End **/
  public static Boolean IsInvoked_ChinaClusterQueueSet = false; // Used in bIns_bUPD_PopulateCountryClusterOnLead Trigger to prevent recursive calls from After Update

  public static Boolean isInvokedFromAccountTrigger = false;//Used in bINS_bUPD_Populate_Opportunity_Owner Trigger to check whether invoked from bINS_bUPD_InsertAccountOwner Acount Trigger
  
  public static Map<Id,List<Contact>> wonToLostContactMap = new Map<Id,List<Contact>>();
  public static Map<Id,List<Lead>> wonToLostLeadMap = new Map<Id,List<Lead>>();
   
  // Commented as part of #RQ-002098 
  //public static Map<Id,List<Trade_Interest__c>> lostContactToTradeMap = new Map<Id,List<Trade_Interest__c>>();
  //public static Map<Id,List<Trade_Interest__c>> lostLeadToTradeMap = new Map<Id,List<Trade_Interest__c>>();
 
  //public static Map<Id,List<Customer_Subscription__c>> lostContactToSubsMap= new Map<Id,List<Customer_Subscription__c>>();
  //public static Map<Id,List<Customer_Subscription__c>> lostLeadToSubsMap= new Map<Id,List<Customer_Subscription__c>>();
  
  //public static Map<Id,Lead> leadtoCustomerSubscriptionCount = new Map<Id,Lead>();
  //public static Map<Id,Lead> leadtoTradeIntrestsCount = new Map<Id,Lead>();
  //public static Map<Id,Contact> contacttoCustomerSubscriptionCount = new Map<Id,Contact>();
  //public static Map<Id,Contact> contacttoTradeIntrestsCount = new Map<Id,Contact>();
  
  public static Boolean leadConversionInProgress = false;
  public static Map<Id,Contact> winningContactMap = new Map<Id,Contact>();
  public static Map<Id,Lead> winningLeadMap = new Map<Id,Lead>();
  
  
  public static Map<Id,List<Account>> ClientAccountToDraftAccount = new Map<Id,List<Account>>();
  public static Map<Id,List<Id>> losingAccountToOpportunityMap = new Map<Id,List<Id>>();
  public static Boolean invokedFromEmailService = false;
  //#RQ-002098
  //public static Boolean byPassActiveSubscriptionCheck = false; // when user tries to make Subsciption active from Standard Screen, bypass check for inactive Subscription.
  public static Boolean invokedFromCustomSite = false; // to check whether request from Come from standard or custom Page.
  public static Boolean isInvokedForPnQRolledInSurcharges = false;// this flag is used in chatter_notification Trigger to check whether the trigger is involed for Mapping pnq rolled in surcharges with Mars surcharges 
  public static Boolean isSubsTradeInvoked=false;// this flag is used in leadUpdateSubsAndTradeTrigger trigger to check whether UpdateSubscriptionAndTradeOnToggle class is invoked 
  public static Boolean isUpdateForSlead=false;//this flag is used in EmailDupeUpdateTriggerForSLLead trigger to invoke once
  public static Boolean isEmailValidationOnLead=false;//this flag is used in bINS_bUPD_emailValidationLead trigger to stop the multiple runs
  public static Boolean isEmailDupUpdate=false;//This flag is used in EmailDupeUpdateTriggerForSL trigger to stop the multiple runs
  public static Boolean isUpdateAccTask=false;//This flag is used in aIns_aUpd_updateAccount_Task trigger to stop the multiple runs
  public static Boolean isInvokeAfterActls=true;//this flag is used in aINS_aUPD_aDEL_ActualsToAccount trigger for do not fire on account owner change
  public static Boolean isPopulateOpportunityOwner=false;//this flag is used in bINS_bUpd_populateOpportunityOwner trigger to stop the multiple runs
  public static Boolean isUpdTartgetOnBrandAccOwnerChange=True;//Flag used to prevent recurssive execution of aINS_aUPD_aDEL_target2Account. RQ#81
  public static Boolean isUpdOppFFEOnUpdOfRtCodeOfQtLine=false;// Flag is used to prevent the updation of Expected FFE on Opportunity, when OLI is deleted from Opp because of updation of route code in Qt_Lines__c object
//public static Boolean isupdateTskDueDt=false;//this flag is used in UpdateTaskDueDatetrigger to stop the multiple runs on after update  
  public static Boolean UpdateOnOpportunityByAFLS = false;//#RQ-002171 - Added to reduce Query execution in bINS_bUpd_populateOpportunityOwner Trigger
  public static Boolean isMergeFromDuplicateCaseManager = false; // #RQ-002190 - Added to allow merge functionaolity to delete child case emails
 
    
    //Prevent BeforeUpdate trigger method invoke after WFR update on insert operation called in CaseTrigger
    public static boolean run = true;
    public static boolean runOnce(){
    if(run)
    {
     run=false;
     return true;
    }
    else
    {
        return run;
    }
    }
   
    //Trigger Recurssion logic using Counter varibale and to support more than one trigger recursion.
    public static Integer TriggerCounter = 0;
    public static Integer TriggerCounterCheck()
    {
      TriggerCounter = TriggerCounter + 1;
      return TriggerCounter;

    }
  
  }