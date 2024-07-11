/*
 Utility class for all the SOQL statements from Single Trigger Framework.
** Version    Date            Owner                                               RQ#                 Description
*********************************************************************************************************************************  
* 1.0        27/11/2015       Prashanth D S                                     Code created
* 2.0        14/01/2015       Ranjini.Janardhanan@ust-global.com                #RQ-002309 - Added 'Active' Column in 'getCountryClusterGeoList' SOQL. 
* 3.0        04/05/2016       vivek.kvp@in.ibm.com                              #RQ-003719 - Account name is required when contact is added to case
* 4.0        20/07/2016       Jiji@UST                                          #RQ-002879 - Use Liner_Brands__c field in contact instead of Liner_Brand__c field
* 5.0        28/02/2017       Hitha@UST                                         #RQ-004653 - Removed references to Account.City_Name__C
* 6.0        05/04/2017       Govindaraj.sundaram@ust-global.com                #RQ-004639 - Updated BDA_Code__c with GEO_ID__c
* 7.0        03/08/2017       Uvais.Komath@ust-global.com                       #RQ-005677 - Removed Account Cluster reference from queries
* 8.0        11/09/2018       Nisha.arjunan@ust-global.com                      #RQ-009192 - Milestone for ISR Cases.
* 9.0        12-Nov-2019      manjunath.c.holekade@maersk.com                   #RQ-012362 - Removed missed references of Account.City_Name__c/City_Name__r
*10.0        26-02-2020       ramadevi@ust.com                                  #RQ-011549: Decommission Resolve Milestone
*11.0        27-03-2020       Avinash@ust.com                                   #SC - 245 - Chat BOT Dashboard Enhancements 2
*/
public class CaseTrigger_DataSetUtilities
{
   public static User loggedInUser;
   public static User getloggedInUser(ID loggedInUserID)
    {
        if (loggedInUser == null){
            loggedInUser = [SELECT id, Liner_Brand__c,MLL__c,Liner_Brand_Logic__c   FROM User WHERE id =: loggedInUserID LIMIT 1];
        }
        return loggedInUser;    
    }
    
    public static List<Contact> contactlist; 
    public static List<Contact> getContactlist(Set<Id> ContactIds, Set<String> contactEmails)
    {
       if (contactlist == null || contactlist.isEmpty()){

       
            //Ver 4.0: Start
            //contactlist = [SELECT id, AccountId, Liner_Brand__c, Email, Account.City_Name__c, Account.City_Name__r.Name, Account.Country__c, Account.Country__r.Name, Account.Cluster_Name__c, Account.Cluster_Name__r.Parent_BDA__r.Parent_BDA__c,IsDuplicate__c,RecordType.Name FROM Contact WHERE Email IN :contactEmails OR Id IN :contactIds];
            contactlist = [SELECT id, AccountId, Deduped_Contact__c, Liner_Brands__c, Email, Account.Country__c, Account.Country__r.Name,IsDuplicate__c,RecordType.Name FROM Contact WHERE Email IN :contactEmails OR Id IN :contactIds ORDER By Email, Deduped_Contact__c Desc];
       }

       //ver 4.0: End
       return contactlist;
    
    }
    
    //#RQ-001774 - static Method to get Custom Metadata(LinerBrand_Direction_and_Country__mdt) record values based on Case Origin list
    public static List<LinerBrand_Direction_and_Country__mdt> customMetadataList; 
    public static List<LinerBrand_Direction_and_Country__mdt> getCustomMetadataList(Set<String> Originset)
    {
        if(customMetadataList == null ||customMetadataList.isEmpty())
           customMetadataList = [Select MasterLabel,Cluster__c,Country__c,Direction__c,Liner_Brand__c,Business_Hours__c from LinerBrand_Direction_and_Country__mdt where MasterLabel IN:Originset];
    
         return customMetadataList;
    }
  
    //#RQ-001774 - static Method to get Custom Metadata(LinerBrand_Direction_and_Country__mdt) record valueswith out any filtters(used in SetBusinessHours method)
    public static map<string,LinerBrand_Direction_and_Country__mdt> allCustomMetadataList = new map<string,LinerBrand_Direction_and_Country__mdt>(); 
    public static map<string,LinerBrand_Direction_and_Country__mdt> getAllCustomMetadataList()
    {
        if(allCustomMetadataList == null || allCustomMetadataList.isEmpty()){
       		allCustomMetadataList = LinerBrand_Direction_and_Country__mdt.getAll();
        }

         return allCustomMetadataList;
    }
    
    public static List<Geography__c> allCountrylist; 
    public static List<Geography__c> getAllCountrylist()
    {
       if (allCountrylist == null || allCountrylist.isEmpty()){
        allCountrylist = [SELECT Id, GEO_ID__c FROM Geography__c WHERE 
                                      Type_Of_Location__c = 'Country' ];
       }
                
        
        return allCountrylist;
        
    }
    
    public static List<BDA__c> bdaList; 
    public static List<BDA__c> getBDAList()
    {
       if (bdaList == null || bdaList.isEmpty())
                bdaList = [SELECT Id, Parent_BDA__c, Type__c, GEO_ID__c FROM BDA__c ];    //#RQ-004639 - Updated BDA_Code__c with GEO_ID__c
        
        return bdaList;
        
    }
    
    public static List<BDA_Geography__c> countryClusterGeoList; 
    public static List<BDA_Geography__c> getCountryClusterGeoList(Set<Id> ClusterIds, Set<Id> CountryIds)
    {
        system.debug('List Values are::'+ countryClusterGeoList);
       if (countryClusterGeoList == null || countryClusterGeoList.isEmpty())//#RQ-002309. Added 'BDA__r.Active__c' field in the SOQL.
                 countryClusterGeoList = [SELECT Id, Geography__c, BDA__c, BDA__r.Type__c, BDA__r.Active__c, BDA__r.Parent_BDA__c,Geography__r.Type_Of_Location__c FROM BDA_Geography__c WHERE (BDA__c IN :ClusterIds OR Geography__c IN :CountryIds)];
        
        return countryClusterGeoList;
        
    }
    
    public static List<Account> accountList; 
    public static List<Account> getAccountList(Set<Id> accountIds)
    {
       if (accountList == null || accountList.isEmpty())
                accountList = [SELECT Id, ParentId, Country__c, Country__r.Name FROM Account WHERE Id IN :accountIds ];
        
        return accountList;
        
    }

    public static List<Geography__c> bhCountryCitylist; 
    public static List<Geography__c> getBHCountryCitylist(Set<ID> citySet, Set<ID> countrySet)
    {
       if (bhCountryCitylist == null || bhCountryCitylist.isEmpty()){
            bhCountryCitylist = [SELECT Id, GEO_ID__c FROM Geography__c WHERE Id IN :citySet OR Id IN :countrySet ];
       }       
        
        return bhCountryCitylist;
        
    }
    
    public static List<BusinessHours> bhList; 
    public static List<BusinessHours> getBHList(Set<String> businessHourNames)
    {
       if (bhList == null || bhList.isEmpty()){
                bhList = [SELECT Id, Name, IsDefault,TimeZoneSidKey,MondayStartTime,MondayEndTime,TuesdayStartTime,TuesdayEndTime,
                          WednesdayStartTime,WednesdayEndTime,ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,
                          SaturdayStartTime,SaturdayEndTime,SundayStartTime,SundayEndTime
                          FROM BusinessHours WHERE (Name IN :businessHourNames AND isActive = TRUE) OR (isDefault = TRUE AND isActive = TRUE) ];
       }
        
        return bhList;
        
    }
    
    public static List<Entitlement> entList; 
    public static List<Entitlement> getEntList()
    {
       if (entList == null || entList.isEmpty()){
                entList = [SELECT id, 
                           assetId,Name,Liner_Brand_Logic__c
                           FROM Entitlement WHERE Status = :Label.ActiveStatus ];
       }
        
        return entList;
        
    }
      
    public static List<CaseMilestone> caseMilestoneList; 
    public static List<CaseMilestone> getCaseMilestoneList(Set<ID> CaseIds)
    {
       if (caseMilestoneList == null || caseMilestoneList.isEmpty()){
                caseMilestoneList = [SELECT Id, CompletionDate, MilestoneType.Name, CaseId FROM CaseMilestone WHERE CaseId in :CaseIds AND CompletionDate = null ];
       }
        
        return CaseMilestoneList;
        
    }
    
    public static List<Stop_Status__c> stopStatusList; 
    public static List<Stop_Status__c> getstopStatusList()
    {
       if (stopStatusList == null || stopStatusList.isEmpty()){
                stopStatusList = [SELECT Id, Name, Case_Status_Value__c, Pause_Milestone__c, Field_Name__c FROM Stop_Status__c ];
       }
        return stopStatusList;
        
    }
    
    public static List<CaseStatus> caseStatusList; 
    public static List<CaseStatus> getCaseStatusList()
    {
       if (caseStatusList == null || caseStatusList.isEmpty()){
        caseStatusList = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = true ];
       }
               
        
        return caseStatusList;
        
    }
        /*(RQ-003719)*/    
    public static Map<Id,Contact> getContactIdToContactMap(Set<Id> contactIds)
    {
        return new Map<Id,Contact>([Select Id, AccountId from Contact WHERE Id IN : contactIds]);                           
    } 
}