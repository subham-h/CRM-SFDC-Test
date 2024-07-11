/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-10712  18-08-2023     Seba & Bharti     Created Code for assigning the target to Territories.
*  2.0      SFSE-13429  24-11-2023     Bharti           Modified the code to create TAA field in target customer Portfolio
*3.0        SFSE-13392   11-jan-2024   Bharti & Aditi   Added Method deleteTcpRecords to delete TCP records 
*4.0        SFSE-13392   18- jan -2024   bharti          Bug Fix 
* 5.0      SFSE-14113  06-Feb-2024    Aditi             Bug fix for SFSE-14066
* */



public class TargetAssignmentUtility {
    
    //This method accept the set of combination of Measure id and Territory Id and TAA RecordID in format (measureID - TerrID - TAARecID) from TargetsAssignToSalesRep 
    public static void insertTargetCustomerPortfolioRecord( Set<String> setMeasureId_TerrId){
        Set<Id> terrIds = new Set<Id>(); 
        Set<String> setExistingRecordsUniqueKey = new Set<String>();
        Set<String> newTerrIds = new Set<String>();
        Set<String> newMeasureIds = new Set<String>();
        Set<String> taaRecordId = new Set<string>();
        Set<string> holdMeasureIdTerrId = new Set<String>();
        // setMeasureId_TerrId contains data like Measureid - TerritoryId- TAARecordID and we are splitting it and storing seprately.
      
        for(String newMeasureTerrKey: setMeasureId_TerrId){
            String remainingDataAfterMeasureId;
            newMeasureIds.add(newMeasureTerrKey.subStringBefore('-').trim());
            remainingDataAfterMeasureId = newMeasureTerrKey.substringAfter('-').trim();
            newTerrIds.add(remainingDataAfterMeasureId.substringBefore('-').trim());
            taaRecordId.add(remainingDataAfterMeasureId.substringAfter('-').trim());
           
        }
       
        // checking if we have any existed record with measure id and same territory user and do not insert same record
        for(Target_Customer_Portfolio__c existingRecords : [ SELECT Id,Assigned_Target__c,Assigned_Sales_Rep__c,Territory_Account_Association__c FROM Target_Customer_Portfolio__c 
                                                            WHERE Assigned_Target__c IN :newMeasureIds 
                                                            AND Assigned_Sales_Rep__c IN :newTerrIds AND Territory_Account_Association__c IN :taaRecordId]){
                                                               
                                                                setExistingRecordsUniqueKey.add(existingRecords.Assigned_Target__c + '-' + existingRecords.Assigned_Sales_Rep__c+ '-'+ existingRecords.Territory_Account_Association__c);
                                                                
                                                            } 
        insertRec(setMeasureId_TerrId,setExistingRecordsUniqueKey);
        
    }
    
    //Method inserting TCP Records 
    public static void insertRec(Set<String> setMeasureToTerrId, Set<String> existingRecordUniqueKeys){
        String remainingDataAfterMeasureId;
        String measureId;
        String territoryId; 
        String recId; 
        List<Target_Customer_Portfolio__c> lstTargetCustomerPortfolio = new List<Target_Customer_Portfolio__c>();
         Set<string> holdMeasureIdTerrId = new Set<String>();
        
        for(String key: setMeasureToTerrId){
            remainingDataAfterMeasureId = '';
            measureId = '';
            territoryId = ''; 
            recId = '';
            
            measureId= key.subStringBefore('-').trim();
            
            remainingDataAfterMeasureId = key.substringAfter('-').trim();
            territoryId = remainingDataAfterMeasureId.substringBefore('-').trim();
            recId = remainingDataAfterMeasureId.substringAfter('-').trim();
         if(!(existingRecordUniqueKeys.contains(measureId+ '-' + territoryId+'-'+recId)) && (recId != Null && territoryId != Null && measureId != Null))
              {
                 
                Target_Customer_Portfolio__c targetCustPortfolio = new Target_Customer_Portfolio__c(Assigned_Target__c  = measureId, Assigned_Sales_Rep__c = territoryId,Territory_Account_Association__c = recId);
                lstTargetCustomerPortfolio.add(targetCustPortfolio);
                 existingRecordUniqueKeys.add(measureId+ '-' + territoryId+ '-'+ recId);
            } 
        }
        
        try{
            if(lstTargetCustomerPortfolio.size() > 0 ){
                System.debug('inserted');
                Database.insert(lstTargetCustomerPortfolio, false); 
            } 
        }catch (Exception e) {
            ErrorLogger.writeErrors( 'SFDC', 'Target_Customer_Portfolio', 'TargetAssignmentUtility', new list<Exception>{e});
        }
    }

    //SFSE-13392 : Method to delete Target Customer Portfolio Records corresponding to the TAAs recieved in the argument list.
    public static void deleteTcpRecords(List<Territory_Account_Association__c> lstTAA, List<Territory_Account_Association__c> lstTAABrandUpdate){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setTaaIds = new Set<Id>();
        Set<Id> setTaaBrandUpdateIds = new Set<Id>();
        Set<String> statusSet = new Set<String>{TargetSettingConstants.STATUS_IN_PROGRESS,TargetSettingConstants.STATUS_ACTIVE,TargetSettingConstants.STATUS_NEW};
        
        List<Target_Customer_Portfolio__c> lstOfTcp = new List<Target_Customer_Portfolio__c>();
        List<Territory_Account_Association__c> lstCombinedTAA = new List<Territory_Account_Association__c>();

        Map<Id, Target_Customer_Portfolio__c> mapTCP = new Map<Id, Target_Customer_Portfolio__c>();
        setTaaBrandUpdateIds = new Map<Id,Territory_Account_Association__c>(lstTAABrandUpdate).keySet();
        lstCombinedTAA.addAll(lstTAA);
        lstCombinedTAA.addAll(lstTAABrandUpdate);
        for(Territory_Account_Association__c taa : lstCombinedTAA){
            setTaaIds.add(taa.id);
            setAccountIds.add(taa.Account__c);
        }        
        /*@param lstOfTCP is the list that contains all corresponding TCP's whose Taa gets modified.
         */
        mapTCP.putAll(new Map<Id, Target_Customer_Portfolio__c>(
            [SELECT ID, Territory_Account_Association__r.Brand__c, Assigned_Target__r.Target_Item__r.Brand__c FROM Target_Customer_Portfolio__c 
             WHERE (Assigned_Target__r.Target_Item__r.Account__c IN :setAccountIds OR 
                    (Territory_Account_Association__r.Represents_Concern__c = true AND 
                     Assigned_Target__r.Target_Item__r.Represent_Concern_Account__c IN :setAccountIds))
             AND Territory_Account_Association__c IN :setTaaIds 
             AND Assigned_Target__r.Target_Item__r.Target__r.Status__c IN :statusSet]));
        
        lstOfTCP.addAll(mapTCP.values());
        //Extra check if the field changed on TAA is 'Brand'
        if(!lstOfTcp.isEmpty() && lstOfTcp != null){
            for (Integer i = 0; i < lstOfTcp.size(); i++) {
                Target_Customer_Portfolio__c tcp = lstOfTcp[i]; 
                if (setTaaBrandUpdateIds.contains(tcp.Territory_Account_Association__c) && tcp.Territory_Account_Association__r.Brand__c != null && tcp.Territory_Account_Association__r.Brand__c.contains(tcp.Assigned_Target__r.Target_Item__r.Brand__c))
                    lstOfTcp.remove(i);
            }
        }

        //Code to delete TCPs in lstOfTCP
       if(!lstOfTcp.IsEmpty()){
          try{
            delete lstOfTcp;
          }catch(Exception e ){
            System.debug('Exception ' + e.getCause() + ' '+ e.getMessage());
            throw e;
          }
       }
    }
}