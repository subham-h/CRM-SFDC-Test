/*  
* Revision Ref Number  Date            Owner                                  Description
* -------- ----------  -----------     -------------------                    -----------
* 1.0      #RQ-008579  22-May-2018     meghana.gupta@ust-global.com            Code created
* 2.0      #RQ-009529  13-Dec-2018     Junaid.Khader@ust-global.com            Separated methods for handling invocation from batch as well.
* 3.0      SFSE-5268   03-Dec-2020  meghana.gupta@ust                       Add checks for Account/Brand/Role uniqueness for Portfolios
* 4.0      SFSE-5787   12-Apr-2021     Kiran@Maersk                            Removal code onAfterInsert & onAfterUpdate
* 5.0       SFSE-6978   10-Oct-2021     Kiran@Maersk                            SIP-2022 Area SOMs configure portfolio territory account assignments
* 6.0      SFSE-9627    26-Oct-2022     Meghana@UST                             Skip user brand check for TAA brand 'All'
* 6.1      SFSE-9317    07-Nov-2022     Meghana@UST                             New method to check TAA is single branded
* 6.2      SFSE-10464  28-Feb-2023      Vazid@UST                               Logic added to not duplicate TAA for a sales rep as an influencer for a combination of 
*                                                                               account/brand/business defined area/product responsibility and/or account/brand/country/product responsibility 
*           SFSE-10613 23-Mar-2023      Jay@UST                                 As a Sales Operations Manager, I can capture start date and end date when creating/editing TAA
* 6.3      SFSE-11889  28-Jul-2023      Shubham@Maersk                          Move Code from Territory Acc Association - Before Save Update flow to trigger
* 6.4      SFSE-11989  2-Aug-2023       Shubham@Maersk                          Can create TAA record for global account owner for LNS and Ocean when end date is null
* 6.5      SFSE-12093  14-Aug-2023      Shubham@Maersk                          Commenting portfolioOwnerBrandCheck method as removing brand check
* 6.6      SFSE-11477   01-Nov-2023     Vinay@Maersk                            Added Code to enqueue UpdateTargetItemMeasureQueueable
* 6.7      SFSE- 13491  14-12-2023       Bharti@Maersk                           Remove Hardcoding Of product Responsibility/Brands
*6.8       SFSE-14676    21-Mar-2024     Bharti@Maersk                           Bug Fix for influencer role TAA to consider start/End date 
*/

public class TerritoryAccountAssociationUtility {
    
    /*public static void portfolioOwnerBrandCheck (List<Territory_Account_Association__c> lstTerrAccAssociation){
        
        List<Id> lstTerritoryIds = new List<Id>();
        Map<Id,Id> mapPortfolioToUser = new Map<Id, Id>();
        
        Id portfolioRecTypeId =  (ID) Schema.SObjectType.Territory__c.getRecordTypeInfosByName().get('Portfolio').getRecordTypeId();
        
        for (Territory_Account_Association__c rec : lstTerrAccAssociation){
            if (rec.Brand__c != 'All'){
                lstTerritoryIds.add(rec.Territory__c);
            }
        }
        
        if (!lstTerritoryIds.isEmpty()){
            for (Territory__c recTerritory : [SELECT Id, Portfolio_Owner__c, RecordTypeId FROM Territory__c WHERE Id in :lstTerritoryIds]){
                if (recTerritory.RecordTypeId == portfolioRecTypeId){
                    mapPortfolioToUser.put(recTerritory.Id, recTerritory.Portfolio_Owner__c);
                }
            }
            Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, liner_brand__c FROM User WHERE Id in :mapPortfolioToUser.values() ]);
            
            for (Territory_Account_Association__c rec : lstTerrAccAssociation){
                if (mapPortfolioToUser.containsKey(rec.Territory__c)){
                    Id userId= mapPortfolioToUser.get(rec.Territory__c);
                    Set<String> setUserBrands = new Set<String>( mapUsers.get(userId).liner_brand__c.split(';') );
                    Set<String> setAssociationBrands = new Set<String>(rec.Brand__c.split(';'));
                    system.debug('setUserBrands'+ setUserBrands);
                    system.debug('setAssociationBrands'+ setAssociationBrands);
                    
                    for (String brand : setAssociationBrands){
                        if (setUserBrands.contains(brand) == false && brand != 'All'){
                            rec.addError(Label.PortfolioBrandMismatchError );
                        }
                    }
                } 
            }  
        }
    }*/
    
    public static void portfolioUniqueResponsibilityCheck (List<Territory_Account_Association__c> lstTerrAccAssociation, String strResponsibility, String errorMessage){
        
        Set<Id> setAccountId = new Set<Id>();
        Map<String, Territory_Account_Association__c> mapIdToKey = new Map<String, Territory_Account_Association__c>();
        //SFSE:10464 : To map Account/Brand Responsibility 
        Map<String, Territory_Account_Association__c> mapIdToAccBrandKey = new Map<String, Territory_Account_Association__c>();
        
        
        for (Territory_Account_Association__c assocRec : lstTerrAccAssociation){
            setAccountId.add(assocRec.Account__c);
            
            List<String> lstBrand = assocRec.Brand__c.split(';');
            for (String strBrand : lstBrand){
                if (strResponsibility == TAASettingConstants.POR_Influencer_Only){
                    
                    if(assocRec.Business_Defined_Area__c != null)
                        mapIdToKey.put(assocRec.Account__c + '_' + strBrand+'_'+assocRec.Business_Defined_Area__c, assocRec);
                    if(assocRec.Country__c != null)
                        mapIdToKey.put(assocRec.Account__c + '_' + strBrand+'_'+assocRec.Country__c, assocRec);
                    mapIdToAccBrandKey.put(assocRec.Account__c + '_' + strBrand, assocRec );
                } else{ 
                    mapIdToKey.put(assocRec.Account__c + '_' + strBrand, assocRec );
                }
            }
        } 
        
        
        List<Territory_Account_Association__c> lstExistingAssoc = [SELECT Id, Account__c, Brand__c, Start_Date__c, End_Date__c, Portfolio_Owner_Responsibility__c, Business_Defined_Area__c,  Product_Responsibility__c, Country__c FROM Territory_Account_Association__c
                                                                   WHERE Account__c in :setAccountId AND Portfolio_Owner_Responsibility__c = :strResponsibility];
        
        set<Id> lstExistingCountries = new set<Id>();
        set<Id> lstExistingGeos = new set<Id>();
        Map<Id,List<string>> mapOfCountryToBDA = new Map<Id,List<string>>();
        Map<Id,List<string>> mapOfBDAToCountry = new Map<Id,List<string>>();
        //SFSE:10464 : To get existing BDAs and Countries from TAA
        if (strResponsibility == TAASettingConstants.POR_Influencer_Only){
            for (Territory_Account_Association__c assocRec : lstExistingAssoc){
                List<String> lstBrand = assocRec.Brand__c.split(';');
                for (String strBrand : lstBrand){
                    if(mapIdToAccBrandKey.containskey(assocRec.Account__c + '_' + strBrand) && mapIdToAccBrandKey.get(assocRec.Account__c + '_' + strBrand).Id != assocRec.Id){
                        lstExistingCountries.add(assocRec.Country__c);
                        lstExistingGeos.add(assocRec.Business_Defined_Area__c);
                    }
                    
                }
            }
           
            //SFSE:10464 : Map regions and their related countries
            Map<Id,BDA_Geography__c> mapOfExistingBGA = new Map<Id,BDA_Geography__c>([Select Id, Geography__c, BDA__c from BDA_Geography__c where  BDA__c IN: lstExistingGeos]);
            for(BDA_Geography__c BDArec : mapOfExistingBGA.values()){
                if(mapOfCountryToBDA.containskey(BDArec.BDA__c)){
                    List<string> lstOfgeo = mapOfCountryToBDA.get(BDArec.BDA__c);
                    lstOfgeo.add(BDArec.Geography__c);
                    mapOfCountryToBDA.put(BDArec.BDA__c, lstOfgeo);
                }else{
                    mapOfCountryToBDA.put(BDArec.BDA__c,new List<string>{BDArec.Geography__c});
                }
            }
           
            
            //SFSE:10464 : Map countries and their related BDAs
            Map<Id,BDA_Geography__c> mapOfExistingGeo = new Map<Id,BDA_Geography__c>([Select Id, Geography__c, BDA__c from BDA_Geography__c where Geography__c IN: lstExistingCountries]);
            for(BDA_Geography__c BDArec : mapOfExistingGeo.values()){
                if(mapOfBDAToCountry.containskey(BDArec.Geography__c)){
                    List<string> lstOfgeo = mapOfBDAToCountry.get(BDArec.Geography__c);
                    lstOfgeo.add(BDArec.BDA__c);
                    mapOfBDAToCountry.put(BDArec.Geography__c, lstOfgeo);
                }else{
                    mapOfBDAToCountry.put(BDArec.Geography__c,new List<string>{BDArec.BDA__c});
                }
            }
          
        }
       
        for (Territory_Account_Association__c rec : lstExistingAssoc){
            
            List<String> lstBrand = rec.Brand__c.split(';');
            for (String strBrand : lstBrand){
                
                String strKey = rec.Account__c + '_' + strBrand;
                String strKey2;
                //SFSE:10464 Using same string for the key based on BDA and Country value.
                if(rec.Business_Defined_Area__c != null)
                    strKey2= rec.Account__c + '_' + strBrand+'_'+rec.Business_Defined_Area__c;
                if(rec.Country__c != null)
                    strKey2= rec.Account__c + '_' + strBrand+'_'+rec.Country__c;
                
                
                //SFSE-6978 Added Product_Responsibility__c criteria
                //SFSE-10464 Added validation check for Country
                if (strResponsibility == TAASettingConstants.POR_Influencer_Only && mapIdToKey.containsKey(strKey2) && mapIdToKey.get(strKey2).Id != rec.Id && (mapIdToKey.get(strKey2).Product_Responsibility__c == TAASettingConstants.PR_All || mapIdToKey.get(strKey2).Product_Responsibility__c == rec.Product_Responsibility__c || rec.Product_Responsibility__c == TAASettingConstants.PR_All)){
                    
                    
                    //SFSE-10613 As a Sales Operations Manager, I can capture start date and end date when creating/editing TAA
                    String errorMsg = dateCheck(mapIdToKey.get(strKey2),rec);
                    if ( errorMsg == 'Existing Error Message'){
                        if(rec.Business_Defined_Area__c != null)
                            mapIdToKey.get(strKey2).addError(errorMessage);
                        if(rec.Country__c != null)
                            mapIdToKey.get(strKey2).addError(Label.PortfolioUniqueCheck_Error9);
                    } else if (errorMsg != 'No Error'){
                        mapIdToKey.get(strKey2).addError(errorMsg);
                    }
                    
                    
                                        
                } if (strResponsibility == TAASettingConstants.POR_Influencer_Only && mapIdToAccBrandKey.containsKey(strKey) && mapIdToAccBrandKey.get(strKey).Id != rec.Id && (mapIdToAccBrandKey.get(strKey).Product_Responsibility__c == TAASettingConstants.PR_All || mapIdToAccBrandKey.get(strKey).Product_Responsibility__c == rec.Product_Responsibility__c || rec.Product_Responsibility__c == TAASettingConstants.PR_All)){
                    //SFSE:10464 : Show error msg when influencer is already assigned to a country of the selected BDA.
                    if(mapIdToAccBrandKey.get(strKey).Business_Defined_Area__c != null && mapOfBDAToCountry.containskey(rec.Country__c)){
                        set<string> lstBDAs = new Set<String>(mapOfBDAToCountry.get(rec.Country__c));
                          
                        if(lstBDAs.contains(mapIdToAccBrandKey.get(strKey).Business_Defined_Area__c) && (mapIdToAccBrandKey.get(strKey).Start_Date__c <= rec.Start_Date__c || mapIdToAccBrandKey.get(strKey).Start_Date__c <= rec.End_Date__c)){
                            
                                  mapIdToAccBrandKey.get(strKey).addError(Label.PortfolioUniqueCheck_Error10);
                             
                          
                             
                        }
                    //SFSE:10464 : Show error msg when Influencer is already assigned to the associated country’s region.
                    }else if(mapIdToAccBrandKey.get(strKey).Country__c != null && mapOfCountryToBDA.containskey(rec.Business_Defined_Area__c)){
                        set<string> lstBDAs = new Set<String>(mapOfCountryToBDA.get(rec.Business_Defined_Area__c));
                        System.debug('region'+mapIdToAccBrandKey.get(strKey).Country__c );
                        if(lstBDAs.contains(mapIdToAccBrandKey.get(strKey).Country__c) && (mapIdToAccBrandKey.get(strKey).Start_Date__c <= rec.Start_Date__c || mapIdToAccBrandKey.get(strKey).Start_Date__c <= rec.End_Date__c)){
                            mapIdToAccBrandKey.get(strKey).addError(Label.PortfolioUniqueCheck_Error11);
                        }
                    }
                    
                }else if (mapIdToKey.containsKey(strKey) && mapIdToKey.get(strKey).Id != rec.Id && (strResponsibility == Label.Sales_Owner_Role || strResponsibility == TAASettingConstants.POR_Lead_Account_Owner_Only || strResponsibility == TAASettingConstants.POR_Global_Lead_Account_Owner_Only)  &&
                          (mapIdToKey.get(strKey).Product_Responsibility__c == TAASettingConstants.PR_All || mapIdToKey.get(strKey).Product_Responsibility__c == rec.Product_Responsibility__c || rec.Product_Responsibility__c == TAASettingConstants.PR_All)){
                              //SFSE-10613 As a Sales Operations Manager, I can capture start date and end date when creating/editing TAA
                              String errorMsg = dateCheck(mapIdToKey.get(strKey),rec);
                              if ( errorMsg == 'Existing Error Message'){
                                  
                                  mapIdToKey.get(strKey).addError(errorMessage);
                              } else if (errorMsg != 'No Error'){
                                  mapIdToKey.get(strKey).addError(errorMsg);
                              }
                          } else if (mapIdToKey.containsKey(strKey) && mapIdToKey.get(strKey).Id != rec.Id && strResponsibility != Label.Sales_Owner_Role && strResponsibility != TAASettingConstants.POR_Lead_Account_Owner_Only && strResponsibility !=  TAASettingConstants.POR_Global_Lead_Account_Owner_Only ){
                              
                              //SFSE-10613 As a Sales Operations Manager, I can capture start date and end date when creating/editing TAA
                              String errorMsg = dateCheck(mapIdToKey.get(strKey),rec);
                              if ( errorMsg == 'Existing Error Message'){
                                 
                                  mapIdToKey.get(strKey).addError(errorMessage);
                              } else  if (errorMsg != 'No Error'){
                                  mapIdToKey.get(strKey).addError(errorMsg);
                              }
                          }
            }
        }
    }
    
    public static void portfolioUniqueRespCheckCombo(List<Territory_Account_Association__c> lstTerrAccAssociation, String strResp, String errorMessage){
        Set<String> strResponsibility = new Set<String>();
        Set<Id> setAccountId = new Set<Id>();
        if(strResp == Label.Sales_Owner_Role){
            strResponsibility.add(TAASettingConstants.POR_SALES_CONTROL_ONLY);
            strResponsibility.add(TAASettingConstants.POR_SALES_NON_CONTROL_ONLY);
            
        }
        if(strResp == Label.Sales_Owner_Role || strResp == TAASettingConstants.POR_SALES_NON_CONTROL_ONLY){
            strResponsibility.add(Label.Sales_Owner_Role);    
        }
        if(strResp == Label.Sales_Owner_Role || strResp ==TAASettingConstants.POR_SALES_CONTROL_ONLY){
            strResponsibility.add(Label.Sales_Owner_Role);    
        }
       
        Map<String, Territory_Account_Association__c> mapIdToKey = new Map<String, Territory_Account_Association__c>();
       
        
        for (Territory_Account_Association__c assocRec : lstTerrAccAssociation){
            setAccountId.add(assocRec.Account__c);
            
            List<String> lstBrand = assocRec.Brand__c.split(';');
            for (String strBrand : lstBrand){
                mapIdToKey.put(assocRec.Account__c + '_' + strBrand, assocRec );
               
            }
        } 
       
        List<Territory_Account_Association__c> lstExistingAssoc = [SELECT Id, Account__c, Brand__c,Portfolio_Owner_Responsibility__c, Start_Date__c, End_Date__c, Business_Defined_Area__c,  Product_Responsibility__c FROM Territory_Account_Association__c
                                                                   WHERE Account__c in :setAccountId AND Portfolio_Owner_Responsibility__c IN :strResponsibility];
        
        for (Territory_Account_Association__c rec : lstExistingAssoc){
            
            List<String> lstBrand = rec.Brand__c.split(';');
            for (String strBrand : lstBrand){
                String strKey = rec.Account__c + '_' + strBrand;
                //SFSE-6978 Added Product_Responsibility__c criteria
                if (mapIdToKey.containsKey(strKey) && mapIdToKey.get(strKey).Id != rec.Id && !strResponsibility.contains(TAASettingConstants.POR_Influencer_Only)  &&
                    (mapIdToKey.get(strKey).Product_Responsibility__c == TAASettingConstants.PR_All || mapIdToKey.get(strKey).Product_Responsibility__c == rec.Product_Responsibility__c || rec.Product_Responsibility__c == TAASettingConstants.PR_All)){
                        //SFSE-10613 As a Sales Operations Manager, I can capture start date and end date when creating/editing TAA
                        String errorMsg = dateCheck(mapIdToKey.get(strKey),rec);
                        if ( errorMsg == 'Existing Error Message'){
                            System.debug('Sales owner: '+ strResponsibility);
                            mapIdToKey.get(strKey).addError(errorMessage);
                        } else  if (errorMsg != 'No Error'){
                            mapIdToKey.get(strKey).addError(errorMsg);
                        }
                    }
            }
        }
    }
    
    public static void singleBrandCheck (List<Territory_Account_Association__c> lstTerrAccAssociation, String strResponsibility, String errorMessage){
        
        for (Territory_Account_Association__c rec : lstTerrAccAssociation){
            List<String> lstBrands = rec.Brand__c.split(';');
            if (lstBrands.size() > 1 ){
                rec.addError(errorMessage );
            }
        }
    }
    
    //SFSE-10613 As a Sales Operations Manager, I can capture start date and end date when creating/editing TAA
    public static String dateCheck(Territory_Account_Association__c newRec, Territory_Account_Association__c existingRec){
        
        
        String errorMessage = 'No Error';
        
        // if either 1 record has start date as null then new record is not valid
       
        if ( newRec.Start_Date__c == null || existingRec.Start_Date__c == null){
            
            errorMessage ='Existing Error Message';
        
        
        // if both records has End date as null then new record is not valid
        
        }else if ( newRec.End_Date__c == null && existingRec.End_Date__c == null){
            
            if (!(newRec.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER && 
                  newRec.Product_Responsibility__c != existingRec.Product_Responsibility__c && newRec.Product_Responsibility__c != TAASettingConstants.PR_All && 
                  existingRec.Product_Responsibility__c != TAASettingConstants.PR_All))
            
            errorMessage = Label.PortfolioUniqueCheck_Error12;
        
        
        // Existing record does not have End Date, then existing record's Start Date can not be less than New record's start/end date
        
        }else if ( newRec.End_Date__c != null && existingRec.End_Date__c == null && ( existingRec.Start_Date__c <= newRec.Start_Date__c || existingRec.Start_Date__c <= newRec.End_Date__c)){
            
            errorMessage = Label.PortfolioUniqueCheck_Error12;
            
        
        
      
        // new record does not have End Date, then new record's Start Date can not be less than Existing record's start/end date
        
        }else if ( newRec.End_Date__c == null && existingRec.End_Date__c != null && ( newRec.Start_Date__c <= existingRec.Start_Date__c || newRec.Start_Date__c <= existingRec.End_Date__c)){
            
            errorMessage = Label.PortfolioUniqueCheck_Error12;
          
            
        
        
        // if both records have Start & End dates
       
        
        }else if (( newRec.Start_Date__c >= existingRec.Start_Date__c && newRec.Start_Date__c <= existingRec.End_Date__c) ||
                  
                  (newRec.End_Date__c >= existingRec.Start_Date__c && newRec.End_Date__c <= existingRec.End_Date__c) ||
                 
                 ( existingRec.Start_Date__c >= newRec.Start_Date__c && existingRec.Start_Date__c <= newRec.End_Date__c) ||
                 
                 ( existingRec.End_Date__c >= newRec.Start_Date__c && existingRec.End_Date__c <= newRec.End_Date__c)){
                    
                    errorMessage = Label.PortfolioUniqueCheck_Error12;
                    
                }
        
        
        return errorMessage; // no Error coz of dates
        
    }
    
    //SFSE-11889 -- Moving Code From Flow to Trigger
    public static void populateTAAFields(List<Territory_Account_Association__c> lstTerrAccAssociation) {
        
        Set<Id> taaAccountIdSet = new Set<Id>();
        Set<Id> territoryIdSet = new Set<Id>();
        
        for (Territory_Account_Association__c taa : lstTerrAccAssociation) {
            if (taa.Account__c != null) taaAccountIdSet.add(taa.Account__c);    
            if (taa.Territory__c != null) territoryIdSet.add(taa.Territory__c);
        }
        
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Parent.SCV_Code__c, Represents_Concern__c, Attractiveness__c, Sales_Channel__c FROM Account WHERE Id IN :taaAccountIdSet]);
        Map<Id,Territory__c> territoryMap = new Map<Id,Territory__c>([SELECT Id, Portfolio_Owner__r.Sales_Job_Function__c FROM Territory__c WHERE Id IN :territoryIdSet]);
        
        for (Territory_Account_Association__c taa : lstTerrAccAssociation) {
            
            if (taa.Account__c != null && accountMap.containsKey(taa.Account__c)) {
                taa.Account_Concern_Code__c = accountMap.get(taa.Account__c).Parent.SCV_Code__c;
                taa.Represents_Concern__c = accountMap.get(taa.Account__c).Represents_Concern__c;
                if ((accountMap.get(taa.Account__c).Attractiveness__c != null && accountMap.get(taa.Account__c).Attractiveness__c == 'Key Client') ||
                    accountMap.get(taa.Account__c).Sales_Channel__c != null && accountMap.get(taa.Account__c).Sales_Channel__c.contains('Key Client')) {
                        
                        if (taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER) taa.Brand__c = TAASettingConstants.PR_All;
                        
                        taa.Key_Client__c = true;
                    }
            }
            if (taa.Territory__c != null && territoryMap.containsKey(taa.Territory__c)) {
                taa.Portfolio_Owner_Sales_Job_Function__c = territoryMap.get(taa.Territory__c).Portfolio_Owner__r.Sales_Job_Function__c;
            }
        }
    }
    
    public static void accountCheck(List<Territory_Account_Association__c> lstTerrAccAssociation) {
        for (Territory_Account_Association__c taa : lstTerrAccAssociation) {
            if (taa.Account__c == null) {
                taa.addError('Required fields are missing: [Account__c]');
            }
        }
    }    
    
    // SFSE-11477
    public static void updateCreditEligibility(List<Territory_Account_Association__c> listTAA){
        if(!listTAA.isEmpty()){
            System.enqueueJob(new UpdateTargetItemMeasureQueueable(listTAA));
        }
    }
}