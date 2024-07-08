/*   
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      #RQ-008579  22-May-2018     meghana.gupta@ust-global.com      		Code created
 * 2.0.     SFSE-5268   03-Dec-2020 	meghana.gupta@ust						Add checks for Account/Brand/Role uniqueness for Portfolios
 * 3.0      SFSE-9317	07-Nov-2022		meghana.gupta@ust						Duplicate check for Lead Account Owner  
 * 4.0		SFSE-10464`	02-Mar-2023		Vazid									Added check for BDA and Country for Influencer
 * 5.0      SFSE-12093  11-Aug-2023     Shubham@Maersk                          Commenting code for brand list lstBrandCheck
 * 6.0 		SFSE-11477	01-Nov-2023		Vinay									Added Code for updating Customer Portfolio Assigned
 * 6.1		SFSE-13649	08-Dec-2023		Vinay									Added code to prevent TAA update due to CMD Update on Account
 * 6.2      SFSE- 13491 14-12-2023     Bharti                                   Remove Hardcoding Of product Responsibility/Brands
 * 6.3      SFSE- 13392  11-Jan-2024   Bharti/Aditi                             Added Code to delete target Customer Portfolio.
 * 7.0      SFSE-14113  06-Feb-2024    Aditi                                    Bug fix for SFSE-14066
 */

public class TerritoryAccAssociationRecordSelector implements RecordSelector  {

    public TriggerHandler TerritoryAccAssociationTriggerHandler;
    public Set<Id> setTerrAccAssociationIds = new Set<Id>();
    public list<Territory_Account_Association__c> lstDupCheck_GloablAccountOwner = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstDupCheck_SalesControl = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstDupCheck_Influencer = new list<Territory_Account_Association__c>();
    //public list<Territory_Account_Association__c> lstBrandCheck = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstDupCheck_SalesNonControlOnly = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstDupCheck_SalesControlOnly = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstDupCheck_Combination = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstDupCheck_LeadAccountOwner = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstDupCheck_GlobalLeadAccountOwner = new list<Territory_Account_Association__c>();
    public list<Territory_Account_Association__c> lstsingleBrandCheck = new list<Territory_Account_Association__c>();
    public List<Territory_Account_Association__c> lstTaaForCreditEligibility = new list<Territory_Account_Association__c>();
    public List<Territory_Account_Association__c> lstTAAForTCPDeletion = new List<Territory_Account_Association__c>();
    public List<Territory_Account_Association__c> lstTAABrandUpdate = new List<Territory_Account_Association__c>();
    
    
    
     public TerritoryAccAssociationRecordSelector ( list<Territory_Account_Association__c> lstNewRecords, map<Id, Territory_Account_Association__c> mapOldRecords, TriggerHandler assocTriggerHandler) {
        
        this.TerritoryAccAssociationTriggerHandler = assocTriggerHandler;
        this.selectRecords(lstNewRecords, mapOldRecords);
        
        if (Test.isRunningTest())
        	getRelatedRecords(lstNewRecords);
    }
    
    public void selectRecords(list<Territory_Account_Association__c> lstNewRecords, map<Id, sObject> mapOldRecords){
        Territory_Account_Association__c oldRec;
              
        /*if( Trigger.isAfter && ( Trigger.isInsert || Trigger.isUpdate )){
            
            for(Territory_Account_Association__c rec : lstNewRecords) {
                if (Trigger.isUpdate )
            		oldRec = (Territory_Account_Association__c) mapOldRecords.get(rec.Id);
        
                if (Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Territory__c != oldRec.Territory__c){
                    setTerrAccAssociationIds.add(rec.Id); 
                }
                
            }
        } else */ 
        if( Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate )){

        	for(Territory_Account_Association__c rec : lstNewRecords) {
                if (Trigger.isUpdate )
            		oldRec = (Territory_Account_Association__c) mapOldRecords.get(rec.Id);
        
                if ((Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c)
                	&& rec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER){
                            lstDupCheck_GloablAccountOwner.add(rec);
                }
                
                if ((Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c || rec.Product_Responsibility__c != oldrec.Product_Responsibility__c)
                	&& rec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL){
                            lstDupCheck_SalesControl.add(rec);
                }
                
				
                //SFSE-10464 : Added check for BDA and Country
                if ((Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c || rec.Product_Responsibility__c != oldrec.Product_Responsibility__c || rec.Business_Defined_Area__c != oldrec.Business_Defined_Area__c || rec.Country__c != oldrec.Country__c)
                	&& rec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Influencer_Only){
                            lstDupCheck_Influencer.add(rec);
                }
                
                if ((Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c || rec.Product_Responsibility__c != oldrec.Product_Responsibility__c)
                	&& rec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL_ONLY){
                            lstDupCheck_SalesControlOnly.add(rec);
                }
                
                if ((Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c || rec.Product_Responsibility__c != oldrec.Product_Responsibility__c)
                	&& rec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_NON_CONTROL_ONLY){
                            lstDupCheck_SalesNonControlOnly.add(rec);
                }
                
                if ((Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c || rec.Product_Responsibility__c != oldrec.Product_Responsibility__c)
                	&& rec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Lead_Account_Owner_Only){
                            lstDupCheck_LeadAccountOwner.add(rec);
                }
                    
                 if ((Trigger.isInsert || rec.Account__c != oldRec.Account__c || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c || rec.Product_Responsibility__c != oldrec.Product_Responsibility__c)
                	&& rec.Portfolio_Owner_Responsibility__c ==  TAASettingConstants.POR_Global_Lead_Account_Owner_Only){
                            lstDupCheck_GlobalLeadAccountOwner.add(rec);
                }   
                
                if ((Trigger.isInsert || rec.Brand__c != oldRec.Brand__c || rec.Portfolio_Owner_Responsibility__c != oldrec.Portfolio_Owner_Responsibility__c)
                	&& (rec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Lead_Account_Owner_Only || rec.Portfolio_Owner_Responsibility__c ==  TAASettingConstants.POR_Global_Lead_Account_Owner_Only)){
                            lstsingleBrandCheck.add(rec);
                }             
            }
        }
        //SFSE-13392- Selecting TAA records to purge their corresponding Target Customer Portfolio records
        if(Trigger.isAfter && Trigger.isUpdate){
            for(Territory_Account_Association__c rec : lstNewRecords) {
                oldRec = (Territory_Account_Association__c) mapOldRecords.get(rec.Id);
                if(((rec.Territory__c != oldRec.Territory__c) || 
                   (rec.Product_Responsibility__c != oldRec.Product_Responsibility__c && rec.Product_Responsibility__c == 'Ocean' && oldRec.Product_Responsibility__c != 'Ocean') ||
                   (rec.Country__c != oldRec.Country__c ) || (rec.Business_Defined_Area__c != oldRec.Business_Defined_Area__c)))
                    lstTAAForTCPDeletion.add(rec);
                else if((rec.Brand__c != null && ( oldRec.Brand__c == null || (!rec.Brand__c.contains(oldRec.Brand__c) && rec.Brand__c != 'All'))) || 
                (oldRec.Brand__c != null && rec.Brand__c == null )){
                    lstTAABrandUpdate.add(rec);
                }
            } 
        }

        if(Trigger.isBefore && trigger.isDelete){            
            lstTAAForTCPDeletion.addAll((List<Territory_Account_Association__c>)(mapOldRecords.Values()));
        }
        


        // SFSE-11477
        // SFSE-13649 - Added isFuture Check to skip TAA updates when CMD updates an Account which in turn updating its TAAs.
        if(!System.isFuture() && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            for(Territory_Account_Association__c taa : lstNewRecords) {  
                if(Trigger.isUpdate){
                   oldRec = (Territory_Account_Association__c) mapOldRecords.get(taa.Id);                    
                }
                //SFSE-13649 - Added this logic to run the Credit Eligibility for TAA insertion and When their is a change in the values either of 
                //Brand, Country, Area, Territory,Start Date, End Date and Product Responsibility.
                if(Trigger.isInsert || taa.Brand__c!=oldRec.Brand__c || taa.Product_Responsibility__c!=oldRec.Product_Responsibility__c ||
                   taa.Country__c!=oldRec.Country__c || taa.Business_Defined_Area__c!=oldRec.Business_Defined_Area__c ||
                   taa.Territory__c!=oldRec.Territory__c || taa.Start_Date__c!=oldRec.Start_Date__c || taa.End_Date__c!=oldRec.End_Date__c){ 
                       
                // if the start Date is in past or Today and End Date is NUll or future then run Credit Eligib Logic for that TAA.        
                // if the start Date is in Future and End Date is NUll or future then run Credit Eligib Logic for that TAA.
                   if(taa.Product_Responsibility__c != TAASettingConstants.PR_Ocean &&
                     (taa.Start_Date__c <= system.today() || taa.Start_Date__c>system.today()) && 
                     (taa.End_Date__c==NULL || taa.End_Date__c >= system.today())){
                        lstTaaForCreditEligibility.add(taa);}
            }}}
        
      
        
        
    }
     
    public void getRelatedRecords( list<Territory_Account_Association__c> lstNewRecords){
        
    }     
}