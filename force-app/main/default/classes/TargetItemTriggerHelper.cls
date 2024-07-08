/*
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
*                                
* 1.0       SFSE-14216  05-06-2024   Bharti					Added query on account and add customer code in unique identifier .	
* 
*/


public inherited sharing class TargetItemTriggerHelper {
    
    public static void generateUniqueIdentifier(List<Target_Item__c> listNewTargetItem) {
        Set<Id> setTargetGrpId = new Set<Id>();
        Set<ID> setAccountId = new Set<Id>();
        for (Target_Item__c eachTargetItem :listNewTargetItem) {
            setTargetGrpId.add(eachTargetItem.Sales_Target_Item_Group__c);
            setAccountId.add(eachTargetItem.Account__c);
        }

      // SFSE-14216 Map to store Account IDs and their respective Customer Codes
         Map<Id, String> mapCustomerCode = new Map<Id, String>();
                  for (Account acc : [SELECT Id, Customer_Code__c FROM Account WHERE Id IN :setAccountId])
            {
                    mapCustomerCode.put(acc.Id, acc.Customer_Code__c);
            }
       
               
        Map<Id, Target_Item_Group__c> mapTargetItem 
            = new Map<Id, Target_Item_Group__c>([	SELECT Id
                                                 		, Unique_Identifier__c 
                                                 	FROM Target_Item_Group__c
                                                 	WHERE Id IN :setTargetGrpId ]);

        for (Target_Item__c eachTargetItem :listNewTargetItem) {
            eachTargetItem.Unique_Identifier__c = mapTargetItem.get(eachTargetItem.Sales_Target_Item_Group__c).Unique_Identifier__c 
                + (eachTargetItem.Account__c == null ? (eachTargetItem.Customer_Code_Override__c != null ? eachTargetItem.Customer_Code_Override__c : 'NOACC') : mapCustomerCode.get(eachTargetItem.Account__c));
        }
    }
    
    public static void uniqueIdentifierOnAccountChange(List<Target_Item__c> listNewTargetItem, Map<Id,Target_Item__c> oldMap) {
        List<Target_Item__c> listUpdatedTargetItem = new List<Target_Item__c>();
        for (Target_Item__c eachTargetItem :listNewTargetItem) {
            if (eachTargetItem.Account__c != oldMap.get(eachTargetItem.Id).Account__c) {
				listUpdatedTargetItem.add(eachTargetItem);
            }
        }

		TargetItemTriggerHelper.generateUniqueIdentifier(listUpdatedTargetItem);
    }
    
    public static void populateSalesTarget(List<Target_Item__c> newList) {
        Set<Id> targetGroupIdSet = new Set<Id>();
        for (Target_Item__c eachTargetItem :newList) {
            targetGroupIdSet.add(eachTargetItem.Sales_Target_Item_Group__c);
        }
        
        Map<Id,Target_Item_Group__c> targetItemGroupMap = new Map<Id,Target_Item_Group__c>([SELECT Id, Target__c FROM Target_Item_Group__c WHERE Id IN :targetGroupIdSet]);
        
        for (Target_Item__c item : newList) {
            if (targetItemGroupMap.containskey(item.Sales_Target_Item_Group__c)) {
                item.Target__c = targetItemGroupMap.get(item.Sales_Target_Item_Group__c).Target__c;
            }
        }
    }
    
    public static void targetCannotBeRemoved(List<Target_Item__c> newList, Map<Id,Target_Item__c> oldMap) {
        for (Target_Item__c eachTargetItem :newList) {
            if (eachTargetItem.Target__c != oldMap.get(eachTargetItem.Id).Target__c) {
                eachTargetItem.addError(Label.targetCannotBeEmpty);
            }
        }
    }
    
    public static void accountDetails(List<Target_Item__c> newList, Map<Id,Target_Item__c> oldMap) {
        if (newList != null) {
            Set<Id> accountIdSet = new Set<Id>();
            List<Target_Item__c> targetList = new List<Target_Item__c>();
            List<Target_Item__c> targetWithoutAccountList = new List<Target_Item__c>();
            Set<String> controllingCountryItemSet = new Set<String>();
            for (Target_Item__c item : newList) {
                if (item.Account__c != null) {
                    if (oldMap == null || oldMap.get(item.Id).Account__c != item.Account__c) {
                        accountIdSet.add(item.Account__c);
                        targetList.add(item);    
                    }
                } else if (item.Controlling_Country_Item__c != null) {
                    if (oldMap == null || oldMap.get(item.Id).Controlling_Country_Item__c != item.Controlling_Country_Item__c) {
                        targetWithoutAccountList.add(item);
                        controllingCountryItemSet.add(item.Controlling_Country_Item__c);    
                    }
                }
            }
            if (accountIdSet.size() > 0) {
                Map<Id,Account> accountMap = new Map<Id,Account>([ SELECT Id, Represents_Concern__c, ParentId, Parent.RecordType.DeveloperName, Account_Address_Area__c 
                                                                  FROM Account WHERE Id IN :accountIdSet]);
                Map<String,String> accIdToParentIdMap = new Map<String,String>();
                List<Target_Item__c> filterItems = new List<Target_Item__c>();
                for (Target_Item__c item : targetList) {
                    if (accountMap.containsKey(item.Account__c)) {
                        if (accountMap.get(item.Account__c).Represents_Concern__c) {
                            item.Represent_Concern_Account__c = item.Account__c;
                            item.Controlling_Area__c = accountMap.get(item.Account__c).Account_Address_Area__c;
                        } else if (accountMap.get(item.Account__c).ParentId != null) {
                            if (accountMap.get(item.Account__c).Parent.RecordType.DeveloperName == TargetSettingConstants.CONCERN_ACCOUNT_RECORD_TYPE) {
                                accIdToParentIdMap.put(item.Account__c,accountMap.get(item.Account__c).ParentId);
                                filterItems.add(item);    
                            } 
                        } else {
                            item.Controlling_Area__c = accountMap.get(item.Account__c).Account_Address_Area__c;
                        }
                    }
                }
                if (accIdToParentIdMap.size() > 0) {
                    Map<Id,Account> accountParentMap = new Map<Id,Account>([SELECT Id,(SELECT Id, Account_Address_Area__c FROM ChildAccounts WHERE Represents_Concern__c = TRUE LIMIT 1)
                                                                            FROM Account WHERE Id IN : accIdToParentIdMap.values()]);
                    if (accountParentMap.size() > 0) {
                        for (Target_Item__c item : filterItems) {
                            if (accIdToParentIdMap.containsKey(item.Account__c) && 
                                accountParentMap.containsKey(accIdToParentIdMap.get(item.Account__c)) &&
                                accountParentMap.get(accIdToParentIdMap.get(item.Account__c)).ChildAccounts.size() > 0) {
                                    item.Represent_Concern_Account__c = accountParentMap.get(accIdToParentIdMap.get(item.Account__c)).ChildAccounts[0].Id;
                                    item.Controlling_Area__c = accountParentMap.get(accIdToParentIdMap.get(item.Account__c)).ChildAccounts[0].Account_Address_Area__c;
                                }
                        }
                    }
                }
            }
            
            if (controllingCountryItemSet.size() > 0) {
                List<BDA_Geography__c> bdaGeographyList = [SELECT Id, BDA__c, Geography__c FROM BDA_Geography__c WHERE 
                                                           Geography__c = :controllingCountryItemSet AND Geography__r.Type_Of_Location__c = 'Country' 
                                                           AND Geography__r.Active__c = true AND BDA__r.Type__c = 'Cluster'];
                if (bdaGeographyList.size() > 0) {
                    Map<String,String> geographyToBDAMap = new Map<String,String>();
                    for (BDA_Geography__c bdaGeo : bdaGeographyList) {
                        geographyToBDAMap.put(bdaGeo.Geography__c,bdaGeo.BDA__c);
                    }
                    for (Target_Item__c item : targetWithoutAccountList) {
                        if (geographyToBDAMap.containsKey(item.Controlling_Country_Item__c)) {
                            item.Controlling_Area__c = geographyToBDAMap.get(item.Controlling_Country_Item__c);    
                        }
                    }    
                } 
            }
        }
    }
}