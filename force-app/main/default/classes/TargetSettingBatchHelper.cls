/*
* Author    : Arpitha J
* Description   : Helper class created for TargetSettingPipelineDataBatch,TargetSettingBaseDataBatch
*       : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                              Arpitha@maersk           Created. 
* 2.0       SFSE-11402  11-04-2024   Vinay					Added createBudgetGroups method to create Budget Groups if doesnt exist	
* 3.0       SFSE-14216  05-06-2024   Bharti                 Added conditions to change the unique identifier and to create TI & TM for non existing customer codes.
* 
*/
public inherited sharing class TargetSettingBatchHelper {
    // Method to check the exclusions of Brand,Family,Country,Area,Region
    public static List<Target_Setting_Staging__c> stagingRecordsByExclusions(String targetId,List<Target_Setting_Staging__c>stagingRecords){
        List<Target_Setting_Staging__c>returnStagingRecordsExcluded = new List<Target_Setting_Staging__c>();
        List<Target_Setting_Staging__c>updateStagingRecordMessage = new List<Target_Setting_Staging__c>();
        Map<String,List<Target_Product_Exclusion__c>> mapTargetProductExclusion = new Map<String,List<Target_Product_Exclusion__c>>();

        for (Target_Product_Exclusion__c eachExclusion : [SELECT Id,Brand__c,Product_Family__c,Country__c,Area__c,Region__c FROM Target_Product_Exclusion__c WHERE Target__c = :targetId AND RecordType.DeveloperName = :TargetSettingConstants.TARGET_EXCLUSION_RECORD_TYPE]) {
            if (!mapTargetProductExclusion.containsKey(eachExclusion.Product_Family__c)) {
                mapTargetProductExclusion.put(eachExclusion.Product_Family__c, new List<Target_Product_Exclusion__c>{eachExclusion});
            }else{
                mapTargetProductExclusion.get(eachExclusion.Product_Family__c).add(eachExclusion);
            } 
         }   
        for(Target_Setting_Staging__c stag:stagingRecords){
            Boolean excludeProd = false;
            if(stag.Product_Family__c!=null && mapTargetProductExclusion.containskey(stag.Product_Family__c) && mapTargetProductExclusion.get(stag.Product_Family__c)!=null){
                for(Target_Product_Exclusion__c exclusionRec:mapTargetProductExclusion.get(stag.Product_Family__c)){
                    excludeProd = true;
                    
                    if(exclusionRec.Brand__c!=null && !exclusionRec.Brand__c.contains(stag.Brand__c)){
                        excludeProd =  false;    
                        break;
                    }
                    if(exclusionRec.Country__c!=null && exclusionRec.Country__c!=stag.Country__c){
                        excludeProd =  false;    
                        break;        
                    }
                    if(exclusionRec.Area__c!=null && exclusionRec.Area__c!=stag.Area__c){
                        excludeProd =  false;    
                        break;   
                    }
                    if(exclusionRec.Region__c!=null && exclusionRec.Region__c!= stag.Area__r.Parent_BDA__c){
                        excludeProd =  false;    
                        break;     
                    } 
                }
            }
            
            if(!excludeProd){
                returnStagingRecordsExcluded.add(stag);    
            }
            else{
                stag.status__C = TargetSettingConstants.STAGING_STATUS_EXCLUDED;
                stag.Message__c = Label.stgExclusionMessage;
                updateStagingRecordMessage.add(stag);
            }
            
        }   
        if(updateStagingRecordMessage!=null && updateStagingRecordMessage.size()>0){
            update updateStagingRecordMessage;
        }
    return returnStagingRecordsExcluded;
    }
    
    //method to return existing budgetgroup & budgetmeasure
    public static Map<String,Budget_Group__c> getBudgetGroupRecordsByStaging(Id targetId,List<Target_Setting_Staging__c>stagingRecords,String measureDimension,set<String>setBrand,set<String>setCountryCode,set<String>setProductFamily){
        Map<String,Budget_Group__c>budgetGroupMap = new Map<String,Budget_Group__c>();
        List<Budget_Group__c>budgetGroupList = [Select id,Brand__c,Country_Code__c,Product_Family__c,Target__r.Applicable_Year__c,Staging_Reference__c,(SELECT Id, Measure_Type__c
                                              FROM Sales_Budget_Measures__r  WHERE Measure_Dimension__c = :measureDimension) from Budget_Group__c where Target__c=:targetId AND Brand__c=:setBrand AND Country_Code__c=:setCountryCode AND Product_Family__c=:setProductFamily];
                   
       for(Budget_Group__c bg:budgetGroupList){
            if(bg.Brand__c!=null && bg.Country_Code__c!=null && bg.Product_Family__c!=null){
                budgetGroupMap.put(bg.Brand__c+bg.Country_Code__c+bg.Product_Family__c,bg);   
            }
        }
        
        return budgetGroupMap;
    }
    
    //method to create & return budget measure record from staging record
    public static Budget_Measure__c createMeasureByStaging(Id budgetGroupId,Target_Setting_Staging__c stagingRecord){
        Budget_Measure__c bMeasureInsertRecord = new   Budget_Measure__c();
        
        if(budgetGroupId!=null){
            bMeasureInsertRecord.Budget_Group__c = budgetGroupId;
        }
        bMeasureInsertRecord.Measure_Dimension__c = stagingRecord.Measure_Dimension__c;
                        
        if (!stagingRecord.IsGrowthPercent__c ) {
            bMeasureInsertRecord.Measure_Type__c = stagingRecord.Measure_Type__c;
        } else {
            bMeasureInsertRecord.Measure_Type__c = stagingRecord.Measure_Type__c + ' ' + TargetSettingConstants.STAGING_GROWTH_PERCENT;
        }
                        
        if(stagingRecord.Jan__c!=null){
            bMeasureInsertRecord.Jan__c= stagingRecord.Jan__c;    
        }
                        
        if(stagingRecord.Feb__c!=null){
            bMeasureInsertRecord.Feb__c = stagingRecord.Feb__c;
        }
                        
        if(stagingRecord.Mar__c!=null){
            bMeasureInsertRecord.Mar__c = stagingRecord.Mar__c;
        }
                        
        if(stagingRecord.Apr__c!=null){
            bMeasureInsertRecord.Apr__c = stagingRecord.Apr__c;
        }
                        
        if(stagingRecord.May__c!=null){
            bMeasureInsertRecord.May__c = stagingRecord.May__c;
        }
                        
        if(stagingRecord.Jun__c!=null){
            bMeasureInsertRecord.Jun__c = stagingRecord.Jun__c;
        }
                        
        if(stagingRecord.Jul__c!=null){
            bMeasureInsertRecord.Jul__c = stagingRecord.Jul__c;
        }
                        
        if(stagingRecord.Aug__c!=null){
            bMeasureInsertRecord.Aug__c = stagingRecord.Aug__c;
        }
                        
        if(stagingRecord.Sep__c!=null){
            bMeasureInsertRecord.Sep__c = stagingRecord.Sep__c;
        }
                        
        if(stagingRecord.Oct__c!=null){
            bMeasureInsertRecord.Oct__c = stagingRecord.Oct__c;
         }
                        
        if(stagingRecord.Nov__c!=null){
            bMeasureInsertRecord.Nov__c = stagingRecord.Nov__c;
        }
                        
        if(stagingRecord.Dec__c!=null){
            bMeasureInsertRecord.Dec__c = stagingRecord.Dec__c;
        }
                       
          
    return bMeasureInsertRecord;
    }
    
    //method to create & return budget group from staging record
    public static Budget_Group__c createBudgetGroupRecord(Id targetId,Target_Setting_Staging__c stagingRecord){
        Budget_Group__c budgetGroupRecordInsert = new Budget_Group__c();
        
        if(stagingRecord.Id!=null){
            budgetGroupRecordInsert.Staging_Reference__c = stagingRecord.Id;
        }
        
        if(stagingRecord.Brand__c!=null){
            budgetGroupRecordInsert.Brand__c = stagingRecord.Brand__c;
        }
        if(stagingRecord.Country_Code__c!=null){
            budgetGroupRecordInsert.Country_Code__c=stagingRecord.Country_Code__c;
        }
        if(stagingRecord.Product_Family__c!=null){
            budgetGroupRecordInsert.Product_Family__c=stagingRecord.Product_Family__c;
        }
        if(targetId!=null){
            budgetGroupRecordInsert.Target__c = targetId;
        }
        
        if(stagingRecord.Area__c!=null){
            budgetGroupRecordInsert.Executing_Area__c = stagingRecord.Area__c;    
        }
        
        if(stagingRecord.Country__c!=null){
            budgetGroupRecordInsert.Executing_Country__c = stagingRecord.Country__c;
        }
        return budgetGroupRecordInsert;
    }
    
    //mapping legacy product family
    public static Map<String,Legacy_Product_Mapping__c> legacyProdMappingMethod(){
        Map<String,Legacy_Product_Mapping__c>legacyProdMapping = new Map<String,Legacy_Product_Mapping__c>();
        for(Legacy_Product_Mapping__c lpm:[Select id,Legacy_Product_Family__c,Is_Active__c,Product__c from Legacy_Product_Mapping__c where Is_Active__c=true]){
            legacyProdMapping.put(lpm.Legacy_Product_Family__c,lpm);    
        }
        
        return legacyProdMapping;
    }
    
    //brand mapping
    public static Map<String,String> targetBrandMappingMethod(){
        Map<String,String>mapTargetBrandMapping = new Map<String,String>();
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        for(Target_Brand_Mapping__c tbm:[Select id,Salesforce_Brand__c,BrandMnA__c,Active__c from Target_Brand_Mapping__c where Active__c =true AND Salesforce_Brand__c!=null AND RecordTypeId = :recordTypeId]){
            mapTargetBrandMapping.put(tbm.BrandMnA__c,tbm.Salesforce_Brand__c);    
        }
        return mapTargetBrandMapping;    
    }
    
    //method to return opportunity line item based on account,brand,country,family  
    public static Map<Id,List<Opportunity_Product__c>> getOpportunityLineItem(set<Id>accIds,set<String>brandName,set<String>countryCodeName,set<String>productFamilyName){
        List<String>prodValues = Label.LnS_Product.split(',');
        Map<Id,List<Opportunity_Product__c>>mapAccOppLineItem = new Map<Id,List<Opportunity_Product__c>>();
        
        for(Opportunity_Product__c oli:[Select Id,Product2ID__r.Portfolio__c,OpportunityId__r.accountId,OpportunityId__r.IsClosed,OpportunityId__r.IsWon,OpportunityId__r.Probability,OpportunityId__r.stagename,OpportunityId__r.Liner_Brand__c,Country__r.GEO_Code__c,Product2ID__r.Family FROM Opportunity_Product__c where Product2ID__r.Portfolio__c IN :prodValues AND OpportunityId__r.accountId=:accIds
        AND OpportunityId__r.Liner_Brand__c=:brandName AND Country__r.GEO_Code__c=:countryCodeName AND Product2ID__r.Family=:productFamilyName]){
            
            if(!mapAccOppLineItem.containskey(oli.OpportunityId__r.accountId)){
                mapAccOppLineItem.put(oli.OpportunityId__r.accountId,new list<Opportunity_Product__c>{oli});    
            }
            else{
                mapAccOppLineItem.get(oli.OpportunityId__r.accountId).add(oli);
            }
        }
        
        return mapAccOppLineItem;
    }
    
    //method to return opportunity product schedule records
    public static Map<Id,List<Opportunity_Product_Schedule__c>> getOpportunityProductSchedule(set<Id>oppLineItemIds,Integer currMonth){
    String recordtypeId = Schema.SObjectType.Opportunity_Product_Schedule__c.getRecordTypeInfosByName().get('Sales Schedule').getRecordTypeId();
        Map<Id,List<Opportunity_Product_Schedule__c>>mapAccProdSchedule = new Map<Id,List<Opportunity_Product_Schedule__c>>();
        for(Opportunity_Product_Schedule__c ops:[Select id,Opportunity_Product__c,Opportunity_Product__r.OpportunityId__r.accountid,Opportunity_Product__r.OpportunityId__r.IsClosed,Opportunity_Product__r.OpportunityId__r.IsWon,Opportunity_Product__r.OpportunityId__r.Probability,Opportunity_Product__r.OpportunityId__r.stagename,Quantity__c,Revenue__c,Schedule_Date__c from Opportunity_Product_Schedule__c where Opportunity_Product__c=:oppLineItemIds AND Recordtypeid=:recordtypeId AND (Schedule_Date__c = THIS_YEAR or Schedule_Date__c = Next_Year)]){
            //if(ops.Schedule_Date__c.month() >= currMonth){
                if(!mapAccProdSchedule.containskey(ops.Opportunity_Product__c)){
                    mapAccProdSchedule.put(ops.Opportunity_Product__c,new list<Opportunity_Product_Schedule__c>{ops});    
                }
                else{
                    mapAccProdSchedule.get(ops.Opportunity_Product__c).add(ops);
                }          
            //}
        }
        
        return mapAccProdSchedule;
    }
    
    //method to return target measure based on set of target item ids
    public static Map<String,List<Target_Measure__c>> getTargetMeasureRecords(set<Id>targetIds){
        Map<String,List<Target_Measure__c>>mapAccTargetMeasure = new Map<String,List<Target_Measure__c>>();
        for(Target_Measure__c tam:[Select id,Jan__c,Feb__c,Mar__c,Apr__c,May__c,Jun__c,Jul__c,Aug__c,Sep__c,Oct__c,Nov__c,Dec__c,Target_Item__c,Target_Item__r.Account__c,Measure_Dimension__c,Measure_Type__c from Target_Measure__c where Target_Item__c=:targetIds AND Measure_Dimension__c=:TargetSettingConstants.PIPELINE]){
            if(!mapAccTargetMeasure.containskey(tam.Target_Item__c+tam.Measure_Type__c)){
                mapAccTargetMeasure.put(tam.Target_Item__c+tam.Measure_Type__c,new list<Target_Measure__c>{tam});    
            }
            else{
                mapAccTargetMeasure.get(tam.Target_Item__c+tam.Measure_Type__c).add(tam);
            }
        }
        
        return mapAccTargetMeasure;
    }
    
    //method to return sales targetgroup & sales target item & sales target item measure
    public static Map<String,Target_Item_Group__c> getSalesTargetGroupRecordsByStaging(Id targetId,set<String>setBrand,set<String>setCountryCode,set<String>setProductFamily){
        Map<String,Target_Item_Group__c>mapSalesTargetGroupItem = new Map<String,Target_Item_Group__c>();
        
        List<Target_Item_Group__c>salesTargetItemGroupList = [Select id,BrandMnA__c,Product_Family__c,Country_Code__c,Target__c from Target_Item_Group__c where Target__c=:targetId AND BrandMnA__c=:setBrand AND Country_Code__c=:setCountryCode AND Product_Family__c=:setProductFamily]; 
        for(Target_Item_Group__c itemGroup:salesTargetItemGroupList){
            if(itemGroup.BrandMnA__c!=null && itemGroup.Product_Family__c!=null && itemGroup.Country_Code__c!=null){
                mapSalesTargetGroupItem.put(itemGroup.BrandMnA__c+itemGroup.Country_Code__c+itemGroup.Product_Family__c,itemGroup);    
            }
        }
        return mapSalesTargetGroupItem;    
    }
    
    //method to return target measure records based on target item record
    public static List<Target_Measure__c> getTargetMeasureRecordsByTargetItemId(Id targetItemId){
        List<Target_Measure__c> targetMeasureRecord = [Select id,Jan__c,Feb__c,Mar__c,Apr__c,May__c,Jun__c,Jul__c,Aug__c,Sep__c,Oct__c,Nov__c,Dec__c,Target_Item__c,Target_Item__r.Account__c,Measure_Dimension__c,Measure_Type__c from Target_Measure__c where Target_Item__c=:targetItemId];
        return targetMeasureRecord;
    }
    
    
    //Create Sales Target Item Record
    public static Target_Item__c createSalesTargetItemRecord(Id salesTargetItemGoupId,Id AccId,Id stagingId){//Id stagingId
        Target_Item__c salesTargetItemInsert = new Target_Item__c();
        if(AccId!=null){
            salesTargetItemInsert.Account__c = AccId;
        }
        if(stagingId!=null){
            salesTargetItemInsert.Staging_Reference__c = stagingId;
        }
        salesTargetItemInsert.Sales_Target_Item_Group__c = salesTargetItemGoupId;
        return salesTargetItemInsert;
    }
    
    //Create Sales Target Item Measure Record
    public static Target_Measure__c createSalesTargetItemMeasureRecord(Id salesTargetItemId, Target_Setting_Staging__c stagingRecord, String partyType, Boolean creditEligible) {
        Target_Measure__c salesTargetMeasureInsert = new Target_Measure__c();
        
        if(stagingRecord.Id!=null){
            salesTargetMeasureInsert.Staging_Reference__c = stagingRecord.Id;
        }
        
        if(salesTargetItemId!=null){
            salesTargetMeasureInsert.Target_Item__c = salesTargetItemId;
        }
        if(stagingRecord.Measure_Type__c!=null){
            salesTargetMeasureInsert.Measure_Type__c = stagingRecord.Measure_Type__c;    
        }
        
        if(partyType!=null){
            salesTargetMeasureInsert.Party_Type__c = partyType;     
        }
        
        salesTargetMeasureInsert.Credit_Eligible__c = creditEligible;
        
        if(stagingRecord.Jan__c!=null){
            salesTargetMeasureInsert.Jan__c= stagingRecord.Jan__c;    
        }
                        
        if(stagingRecord.Feb__c!=null){
            salesTargetMeasureInsert.Feb__c = stagingRecord.Feb__c;
        }
                        
        if(stagingRecord.Mar__c!=null){
            salesTargetMeasureInsert.Mar__c = stagingRecord.Mar__c;
        }
                        
        if(stagingRecord.Apr__c!=null){
            salesTargetMeasureInsert.Apr__c = stagingRecord.Apr__c;
        }
                        
        if(stagingRecord.May__c!=null){
            salesTargetMeasureInsert.May__c = stagingRecord.May__c;
        }
                        
        if(stagingRecord.Jun__c!=null){
            salesTargetMeasureInsert.Jun__c = stagingRecord.Jun__c;
        }
                        
        if(stagingRecord.Jul__c!=null){
            salesTargetMeasureInsert.Jul__c = stagingRecord.Jul__c;
        }
                        
        if(stagingRecord.Aug__c!=null){
            salesTargetMeasureInsert.Aug__c = stagingRecord.Aug__c;
        }
                        
        if(stagingRecord.Sep__c!=null){
            salesTargetMeasureInsert.Sep__c = stagingRecord.Sep__c;
        }
                        
        if(stagingRecord.Oct__c!=null){
            salesTargetMeasureInsert.Oct__c = stagingRecord.Oct__c;
         }
                        
        if(stagingRecord.Nov__c!=null){
            salesTargetMeasureInsert.Nov__c = stagingRecord.Nov__c;
        }
                        
        if(stagingRecord.Dec__c!=null){
            salesTargetMeasureInsert.Dec__c = stagingRecord.Dec__c;
        }

        salesTargetMeasureInsert.Measure_Dimension__c = stagingRecord.Measure_Dimension__c;
        salesTargetMeasureInsert.Unique_Identifier__c = salesTargetMeasureInsert.Measure_dimension__c 
            + salesTargetMeasureInsert.Measure_type__c + salesTargetMeasureInsert.Party_Type__c 
                + salesTargetMeasureInsert.Credit_Eligible__c + salesTargetMeasureInsert.Target_item__c;
    System.debug('create measure'+salesTargetMeasureInsert);
        return salesTargetMeasureInsert;    
    }
    
    public static Map<String,Id> getAccountByCustomerCode(set<String> setCustomerCode) {
        Map<String,Id>mapAccountByCustomerCode = new Map<String,Id>();
        List<Account> eachAccount = [SELECT Id,Customer_Code__c FROM Account WHERE Customer_Code__c=:setCustomerCode];
        if(eachAccount.size()>0){
            for(Account acc:eachAccount){
                mapAccountByCustomerCode.put(acc.Customer_Code__c,acc.Id);
            }
            return mapAccountByCustomerCode;
        }
        else{
            return null;
        }
    }
    
    public static Map<String,Target_Item__c> checkExistingItemForGroup(Id targetId,set<String>setBrand,set<String>setCountryCode,set<String>setProductFamily){
        Map<String,Target_Item__c>mapTargetItemRecords = new Map<String,Target_Item__c>();
        String key='';
        List<Target_Item__c> tarItemRecList = [Select id,Account__c,Sales_Target_Item_Group__c,Staging_Reference__c from Target_Item__c
                                              where Sales_Target_Item_Group__c!=null AND Sales_Target_Item_Group__r.Target__c =:targetId AND Account__c!=null AND Sales_Target_Item_Group__c!=null AND 
                                              Sales_Target_Item_Group__r.BrandMnA__c=:setBrand AND Sales_Target_Item_Group__r.Country_Code__c=:setCountryCode AND Sales_Target_Item_Group__r.Product_Family__c=:setProductFamily];
        if(tarItemRecList.size()>0){
            for(Target_Item__c item:tarItemRecList){
                if(item.Account__c != null){
                key = item.Sales_Target_Item_Group__c+'-'+item.Account__c; 
                mapTargetItemRecords.put(key,item);
            }
            }
            return mapTargetItemRecords; 
        }
        else{
            return null;
        }
        
    }
    
    public static Map<String,Target_Measure__c> checkExistingMeasureForItem(set<Id>existingTargetItemId){
        String key = '';
        Map<String,Target_Measure__c>existingSalesTargetItemMeasureMap = new Map<String,Target_Measure__c>();
        List<Target_Measure__c> targetMeasureRecordsList = [Select id,Target_Item__c,Measure_Dimension__c,Party_Type__c,Measure_Type__c,Credit_Eligible__c,Jan__c,Feb__c,Mar__c,Apr__c,
                                       May__c,Jun__c,Jul__c,Aug__c,Sep__c,Oct__c,Nov__c,Dec__c,Staging_Reference__c from Target_Measure__c where Target_Item__c=:existingTargetItemId];
        
        if(targetMeasureRecordsList!=null && targetMeasureRecordsList.size()>0){
            for(Target_Measure__c tarMeasure:targetMeasureRecordsList){
                key = tarMeasure.Target_Item__c+tarMeasure.Measure_Dimension__c+tarMeasure.Party_Type__c+tarMeasure.Measure_Type__c+tarMeasure.Credit_Eligible__c;
                existingSalesTargetItemMeasureMap.put(key,tarMeasure);
            } 
            return existingSalesTargetItemMeasureMap;
        } 
        else{
            return null;
        }
                                   
    
    }
    
    public static Target_Measure__c updateAggregateMeasureRecord(Target_Measure__c measureRecord,Target_Setting_Staging__c stagingRecord){
   
        Target_Measure__c measureRecToAggregate;
        if(measureRecord!=null){
            measureRecToAggregate = measureRecord;
        } 
        if(stagingRecord.Id!=null){
            measureRecToAggregate.Staging_Reference__c += ','+stagingRecord.Id;
        }
        if(stagingRecord.Jan__c!=null){
            measureRecToAggregate.Jan__c+= stagingRecord.Jan__c;    
        }
                        
        if(stagingRecord.Feb__c!=null){
            measureRecToAggregate.Feb__c+= stagingRecord.Feb__c;
        }
                        
        if(stagingRecord.Mar__c!=null){
            measureRecToAggregate.Mar__c+= stagingRecord.Mar__c;
        }
                        
        if(stagingRecord.Apr__c!=null){
            measureRecToAggregate.Apr__c+= stagingRecord.Apr__c;
        }
                        
        if(stagingRecord.May__c!=null){
            measureRecToAggregate.May__c+= stagingRecord.May__c;
        }
                        
        if(stagingRecord.Jun__c!=null){
            measureRecToAggregate.Jun__c+= stagingRecord.Jun__c;
        }
                        
        if(stagingRecord.Jul__c!=null){
            measureRecToAggregate.Jul__c+= stagingRecord.Jul__c;
        }
                        
        if(stagingRecord.Aug__c!=null){
            measureRecToAggregate.Aug__c+= stagingRecord.Aug__c;
        }
                        
        if(stagingRecord.Sep__c!=null){
            measureRecToAggregate.Sep__c+= stagingRecord.Sep__c;
        }
                        
        if(stagingRecord.Oct__c!=null){
            measureRecToAggregate.Oct__c+= stagingRecord.Oct__c;
         }
                        
        if(stagingRecord.Nov__c!=null){
            measureRecToAggregate.Nov__c+= stagingRecord.Nov__c;
        }
                        
        if(stagingRecord.Dec__c!=null){
            measureRecToAggregate.Dec__c+= stagingRecord.Dec__c;
        }
        
        return measureRecToAggregate;
    }
    
    public static void sendEmail(String status,String measureDimension,String ownerEmail){
        List<Messaging.SingleEmailMessage>emailList = new List<Messaging.SingleEmailMessage>();
        String[] toAddresses = new String[] {ownerEmail};
        //String body = '';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject('Sales Target Setting - Load '+measureDimension+' '+status);
        //body += 'Loading '+measureDimension+' '+status+' To view the details,please login to the Sales Target Setting Platform.\n\n'; 
        //body += 'Note: This is an auto-generated email. Replies to this email are not monitored. For any help required, please reach out to the support team by submitting a SNOW ticket.';
        String homeURL = URL.getOrgDomainURL().toExternalForm() + '/lightning/page/home';
        String body = '<html><body>Dear Sales Target User,<br/><br/>Loading '+measureDimension+' has been completed successfully. To view the details, please login to the <a href="' + homeURL + '">Sales Target Setting Platform.</a><br/><br/>';
        body += 'Note: This is an auto-generated email. Replies to this email are not monitored. For any help required, please reach out to the support team by submitting a SNOW ticket.</body></html>';
        mail.setHTMLBody(body);
        emailList.add(mail);
        Messaging.sendEmail(emailList); 
    }

    public static Decimal applyGrowthPercentage(Decimal pyValue, Decimal budgetGrowth, Decimal targetValue) {
        targetValue = targetValue != null ? targetValue : 0;
        budgetGrowth = budgetGrowth != null ? budgetGrowth : 0;
        pyValue = pyValue != null ? pyValue : 0;
        targetValue = budgetGrowth != null ? targetValue + pyValue + (Math.abs(pyValue) * budgetGrowth / 100) : targetValue;
        return targetValue > 0 ? targetValue : 0;
    }

    public static void calculateTargetFromBudgetGrowthPercent(Budget_Measure__c iBugetMeasure, Target_Measure__c pyMeasure, Target_Measure__c targetMeasure) {
        targetMeasure.Jan__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Jan__c, iBugetMeasure.Jan__c, targetMeasure.Jan__c);
        targetMeasure.Feb__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Feb__c, iBugetMeasure.Feb__c, targetMeasure.Feb__c);
        targetMeasure.Mar__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Mar__c, iBugetMeasure.Mar__c, targetMeasure.Mar__c);
        targetMeasure.Apr__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Apr__c, iBugetMeasure.Apr__c, targetMeasure.Apr__c);
        targetMeasure.May__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.May__c, iBugetMeasure.May__c, targetMeasure.May__c);
        targetMeasure.Jun__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Jun__c, iBugetMeasure.Jun__c, targetMeasure.Jun__c);
        targetMeasure.Jul__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Jul__c, iBugetMeasure.Jul__c, targetMeasure.Jul__c);
        targetMeasure.Aug__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Aug__c, iBugetMeasure.Aug__c, targetMeasure.Aug__c);
        targetMeasure.Sep__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Sep__c, iBugetMeasure.Sep__c, targetMeasure.Sep__c);
        targetMeasure.Oct__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Oct__c, iBugetMeasure.Oct__c, targetMeasure.Oct__c);
        targetMeasure.Nov__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Nov__c, iBugetMeasure.Nov__c, targetMeasure.Nov__c);
        targetMeasure.Dec__c = TargetSettingBatchHelper.applyGrowthPercentage(pyMeasure.Dec__c, iBugetMeasure.Dec__c, targetMeasure.Dec__c);
    }

    public static Map<Id, Target_Measure__c> getTargetByPyId(Set<Id> setTargetItemId, String measureType) {
        Map<Id, Target_Measure__c> retVal = new Map<Id, Target_Measure__c>();
        for (Target_Measure__c eachMeasure :[   SELECT Id 
                                                    , Jan__c
                                                    , Feb__c
                                                    , Mar__c
                                                    , Apr__c
                                                    , May__c
                                                    , Jun__c
                                                    , Jul__c
                                                    , Aug__c
                                                    , Sep__c
                                                    , Oct__c
                                                    , Nov__c
                                                    , Dec__c
                                                    , Target_Item__c
                                                    , Measure_Type__c
                                                    , Measure_Dimension__c
                                                    , Related_Measure_Id__c
                                                FROM Target_Measure__c
                                                WHERE Target_Item__c IN :setTargetItemId
                                                    AND Measure_Dimension__c = :measureType ]) {
            retVal.put(eachMeasure.Related_Measure_Id__c, eachMeasure);
        }

        return retVal;
    }

    public static void prepareMapByIdByMeasureType(Id mapKey, Target_Measure__c iMeasure, Map<Id, Map<String, Set<Target_Measure__c>>> mapByIdByType) {
        if (mapByIdByType.get(mapKey) != null) {
            if (mapByIdByType.get(mapKey).get(iMeasure.Measure_Type__c) != null) {
                mapByIdByType.get(mapKey).get(iMeasure.Measure_Type__c).add(iMeasure);
            } else {
                mapByIdByType.get(mapKey).put(iMeasure.Measure_Type__c, new Set<Target_Measure__c> { iMeasure });
            }
        } else {
            mapByIdByType.put(mapKey, new Map<String, Set<Target_Measure__c>>
                { iMeasure.Measure_Type__c => new Set<Target_Measure__c> { iMeasure } }
            );
        }
    }

    public static void prepareMapByUniqueIdByMeasureType(String uniqueIdentifier, Target_Setting_Staging__c iStaging, Map<String, Map<String, Set<Target_Setting_Staging__c>>> mapByIdByType) {
        if (mapByIdByType.get(uniqueIdentifier) != null) {
            if (mapByIdByType.get(uniqueIdentifier).get(iStaging.Measure_Type__c) != null) {
                mapByIdByType.get(uniqueIdentifier).get(iStaging.Measure_Type__c).add(iStaging);
            } else {
                mapByIdByType.get(uniqueIdentifier).put(iStaging.Measure_Type__c, new Set<Target_Setting_Staging__c> { iStaging });
            }
        } else {
            mapByIdByType.put(uniqueIdentifier, new Map<String, Set<Target_Setting_Staging__c>>
                { iStaging.Measure_Type__c => new Set<Target_Setting_Staging__c> { iStaging } }
            );
        }
    }

    public static List<Target_Measure__c> createTargetsFromPyActuals(Map<Id, Map<String, Set<Target_Measure__c>>> mapPyActualsByBudgetGrpId, Map<Id, Target_Measure__c> mapTargetByPyId, Boolean aggregateExistingTargets) {
        String targetType = '';
        Target_Measure__c newTargetMesure;
        Map<Id, Target_Measure__c> mapTargetByPyIdCurrentScope = new Map<Id, Target_Measure__c>();
        Target_Measure__c targetCorrespondingPy;
        for (Budget_Measure__c eachBudgetMeasure :[ SELECT Id
                                                        , Jan__c
                                                        , Feb__c
                                                        , Mar__c
                                                        , Apr__c
                                                        , May__c
                                                        , Jun__c
                                                        , Jul__c
                                                        , Aug__c
                                                        , Sep__c
                                                        , Oct__c
                                                        , Nov__c
                                                        , Dec__c
                                                        , Measure_Type__c
                                                        , Budget_Group__c
                                                    FROM Budget_Measure__c
                                                    WHERE Budget_Group__c IN :mapPyActualsByBudgetGrpId.keySet()
                                                        AND (Measure_Type__c = :TargetSettingConstants.VOLUME_GROWTH_PERCENT
                                                            OR Measure_Type__c = :TargetSettingConstants.REVENUE_GROWTH_PERCENT
                                                            OR Measure_Type__c = :TargetSettingConstants.GROSS_PROFIT_GROWTH_PERCENT) ]) {
            // GET MEASURE TYPE FROM MEASURE GROWTH PERCENTATE TYPE
            targetType = eachBudgetMeasure.Measure_Type__c.replace(TargetSettingConstants.STAGING_GROWTH_PERCENT, '').trim();
            // GET PREVIOUS YEAR ACTUAL FOR BUDGET GROUP AND MEASURE TYPE
            if (mapPyActualsByBudgetGrpId.get(eachBudgetMeasure.Budget_Group__c) != null 
            && mapPyActualsByBudgetGrpId.get(eachBudgetMeasure.Budget_Group__c).get(targetType) != null) {
                for (Target_Measure__c eachPyMeasure :mapPyActualsByBudgetGrpId.get(eachBudgetMeasure.Budget_Group__c).get(targetType)) {
                    // CHECK IF TARGET RECORD EXISTS IN DB - IF EXISTS ELSE NOT EXISTS
                    if (mapTargetByPyId.get(eachPyMeasure.Id) != null) {
                        // RUN FEASIBILTY OF THIS LOGIC IF THIS IS REQUIRED AS PY ACTUALS ALREAY EXISTS
                        if (!aggregateExistingTargets) {
                            continue;
                        } else {
                            if (mapTargetByPyIdCurrentScope.get(eachPyMeasure.Id) != null) {
                                targetCorrespondingPy = mapTargetByPyIdCurrentScope.get(eachPyMeasure.Id);
                            } else {
                                targetCorrespondingPy = mapTargetByPyId.get(eachPyMeasure.Id);
                            }
                            // UPDATE TARGET
                            TargetSettingBatchHelper.calculateTargetFromBudgetGrowthPercent(eachBudgetMeasure, eachPyMeasure, targetCorrespondingPy);
                            mapTargetByPyIdCurrentScope.put(eachPyMeasure.Id, targetCorrespondingPy);
                        }
                    } else {
                        // CREATE TARGET
                        newTargetMesure = new Target_Measure__c(
                                Target_Item__c = eachPyMeasure.Target_Item__c
                            ,   Measure_Type__c = eachPyMeasure.Measure_Type__c
                            ,   Measure_Dimension__c = TargetSettingConstants.TARGET
                            ,   Party_Type__c = eachPyMeasure.Party_Type__c
                            ,   Credit_Eligible__c = eachPyMeasure.Credit_Eligible__c
                            ,   Related_Measure_Id__c = eachPyMeasure.Id
                            ,   Unique_Identifier__c = TargetSettingConstants.TARGET + eachPyMeasure.Measure_Type__c 
                                + eachPyMeasure.Party_Type__c + eachPyMeasure.Credit_Eligible__c + eachPyMeasure.Target_Item__c
                        );
                        TargetSettingBatchHelper.calculateTargetFromBudgetGrowthPercent(eachBudgetMeasure, eachPyMeasure, newTargetMesure);
                        mapTargetByPyIdCurrentScope.put(eachPyMeasure.Id, newTargetMesure);
                    }
                }
            } else {
                // NO BUDGET GRWOTH PERCENTAGE FOUND FOR BUDGET
                System.debug(LoggingLevel.INFO, Label.msgBudgetGrowthNotFound);
            }
        }

        return mapTargetByPyIdCurrentScope.values();
    }
    // Creating targetItems for the Po,Shipper,Consignee's codes if account exist and if don't exist then else part will execute
    // Else part introduced as part of SFSE-14216
    public static Target_Item__c mapTargetItemFromStaging (Target_Setting_Staging__c iStaging, String partyType, String uniqueGrpIdentifier) {
        Target_Item__c newTargetItem;
       /* if ((iStaging.get(partyType + '_Account_Id__c')) != null && partyType != null && iStaging.get(partyType + '__c') != null) {
            newTargetItem = new Target_Item__c(Unique_Identifier__c = uniqueGrpIdentifier + iStaging.get(partyType + '_Account_Id__c'));
            newTargetItem.Sales_Target_Item_Group__r = new Target_Item_Group__c(Unique_Identifier__c = uniqueGrpIdentifier);
            newTargetItem.Target_Item_Type__c = 'Existing Business';
             System.debug('newly created target item' + newTargetItem.Unique_Identifier__c);
            if (iStaging.get(partyType + '_Account_Id__c') != null) {
                newTargetItem.Account__c = (Id) iStaging.get(partyType + '_Account_Id__c');
            }
        }*/

        if ((iStaging.get(partyType + '_Account_Id__c')) != null && partyType != null && iStaging.get(partyType + '__c') != null) {
            newTargetItem = new Target_Item__c(Unique_Identifier__c = uniqueGrpIdentifier + iStaging.get(partyType + '__c'));
            newTargetItem.Sales_Target_Item_Group__r = new Target_Item_Group__c(Unique_Identifier__c = uniqueGrpIdentifier);
            newTargetItem.Target_Item_Type__c = 'Existing Business';
            if (iStaging.get(partyType + '_Account_Id__c') != null) {
                newTargetItem.Account__c = (Id)iStaging.get(partyType + '_Account_Id__c');
            }
        }else{
         
            //scenerio when account Id field is null 
            newTargetItem = new Target_Item__c(Unique_Identifier__c = uniqueGrpIdentifier + iStaging.get(partyType + '__c'));
            newTargetItem.Sales_Target_Item_Group__r = new Target_Item_Group__c(Unique_Identifier__c = uniqueGrpIdentifier);
            newTargetItem.Target_Item_Type__c = 'Existing Business';
          
            if (iStaging.get(partyType + '_Account_Id__c') == null) {
                newTargetItem.Customer_Code_Override__c = (String)iStaging.get(partyType + '__c');
        }

        }

        System.debug('new TM'+newTargetItem);
        return newTargetItem;
    }

    public static void preapareSobjectCollectionByUniqueId (String uniqueIdentifier, SObject eachSobject,  Map<String, List<SObject>> mapSobjectCollectionIdentifier) {
        if (mapSobjectCollectionIdentifier.get(uniqueIdentifier) == null) {
            mapSobjectCollectionIdentifier.put(uniqueIdentifier, new List<SObject>());
        }
        mapSobjectCollectionIdentifier.get(uniqueIdentifier).add(eachSobject);
        System.debug('mapSobjectCollectionIdentifier--->'+mapSobjectCollectionIdentifier.keySet());
    }

    public static void preapareStringCollectionByUniqueId (String uniqueIdentifier, String eachStr,  Map<String, Set<String>> mapStrCollectionIdentifier) {
        if (mapStrCollectionIdentifier.get(uniqueIdentifier) == null) {
            mapStrCollectionIdentifier.put(uniqueIdentifier, new Set<String>());
        }

        mapStrCollectionIdentifier.get(uniqueIdentifier).add(eachStr);
    }

    public static void aggregateMeasureFromStaging(Target_Measure__c existingMeasure, Target_Setting_Staging__c iStaging) {
        existingMeasure.Jan__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Jan__c, iStaging.Jan__c);
        existingMeasure.Feb__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Feb__c, iStaging.Feb__c);
        existingMeasure.Mar__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Mar__c, iStaging.Mar__c);
        existingMeasure.Apr__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Apr__c, iStaging.Apr__c);
        existingMeasure.May__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.May__c, iStaging.May__c);
        existingMeasure.Jun__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Jun__c, iStaging.Jun__c);
        existingMeasure.Jul__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Jul__c, iStaging.Jul__c);
        existingMeasure.Aug__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Aug__c, iStaging.Aug__c);
        existingMeasure.Sep__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Sep__c, iStaging.Sep__c);
        existingMeasure.Oct__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Oct__c, iStaging.Oct__c);
        existingMeasure.Nov__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Nov__c, iStaging.Nov__c);
        existingMeasure.Dec__c = TargetSettingBatchHelper.aggregateValues(existingMeasure.Dec__c, iStaging.Dec__c);
    }

    public static Decimal aggregateValues(Decimal oneValue, Decimal secondValue) {
        return (oneValue != null ? onevalue : 0.0) + (secondValue != null ? secondValue : 0.0);
    }

    public static String createUniqueMeasureIdFromStg(String uniqueItemId, String partyType, Target_Setting_Staging__c eachStaging) {
       
        Boolean partyCreditEligibility = TargetSettingConstants.PARTY_PO.equals(partyType) 
            ? eachStaging.PO_Eligible__c : (TargetSettingConstants.PARTY_SHIPPER.equals(partyType) 
                ? eachStaging.Shipper_Eligible__c : eachStaging.Consignee_Eligible__c);
        return uniqueItemId + eachStaging.Measure_Dimension__c + eachStaging.Measure_Type__c + partyType + partyCreditEligibility;
    }

    public static void prepareMeasureData(String uniqueGroupId, String partyType
        , Target_Setting_Staging__c eachStaging, Map<String, Map<String, Target_Measure__c>> mapMeasureByMeasureIdByItemIdContext) {
        Target_Measure__c newTargetMeasure;   String uniqueItemId;
        Boolean partyCreditEligibility = TargetSettingConstants.PARTY_PO.equals(partyType) 
            ? eachStaging.PO_Eligible__c : (TargetSettingConstants.PARTY_SHIPPER.equals(partyType) 
                ? eachStaging.Shipper_Eligible__c : eachStaging.Consignee_Eligible__c);

                            uniqueItemId = uniqueGroupId + 
                            (TargetSettingConstants.PARTY_PO.equals(partyType) && eachStaging.Price_Owner__c != null 
                                ? eachStaging.Price_Owner__c 
                                : (TargetSettingConstants.PARTY_SHIPPER.equals(partyType) && eachStaging.Shipper__c != null 
                                    ? eachStaging.Shipper__c 
                                    :eachStaging.Consignee__c));
     
                    
            
        String uniqueMeasureId;
        // PARTY ITEM
        // IF ITEM ALREADY EXISTS
            uniqueMeasureId = TargetSettingBatchHelper.createUniqueMeasureIdFromStg(uniqueItemId, partyType, eachStaging);
            

        if (mapMeasureByMeasureIdByItemIdContext.get(uniqueItemId) != null) {
         
            // CHECK IF MEASURE EXISTS
            if (mapMeasureByMeasureIdByItemIdContext.get(uniqueItemId).get(uniqueMeasureId) != null) {
                // AGGREGATE MEASURE
             
                TargetSettingBatchHelper.aggregateMeasureFromStaging(mapMeasureByMeasureIdByItemIdContext.get(uniqueItemId).get(uniqueMeasureId), eachStaging);
            } else {
                // MEASURES
               
                newTargetMeasure = TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(null, eachStaging, partyType, partyCreditEligibility);
                newTargetMeasure.Target_Item__r = new Target_Item__c(Unique_Identifier__c = uniqueItemId);
                newTargetMeasure.Unique_Identifier__c = uniqueMeasureId;
               
                mapMeasureByMeasureIdByItemIdContext.get(uniqueItemId).put(uniqueMeasureId, newTargetMeasure);
            }
        } else {
            // MEASURES
            newTargetMeasure = TargetSettingBatchHelper.createSalesTargetItemMeasureRecord(null, eachStaging, partyType, partyCreditEligibility);
            newTargetMeasure.Target_Item__r = new Target_Item__c(Unique_Identifier__c = uniqueItemId);
            newTargetMeasure.Unique_Identifier__c = uniqueMeasureId;
           
            
            mapMeasureByMeasureIdByItemIdContext.put(uniqueItemId, new Map<String, Target_Measure__c>{
                TargetSettingBatchHelper.createUniqueMeasureIdFromStg(uniqueItemId, partyType, eachStaging) => newTargetMeasure
            });
           
        }
    }

    public static void getStagingByGroupUniqueId(List<Target_Setting_Staging__c> listIncomingStaging
        , String targetId, Map<String, List<Target_Setting_Staging__c>> mapStagingByGroupIdentifier
        , Set<String> setTargetItemId, Map<String, Set<String>> mapStagingIdByItemUId) {
        String uniqueGroupId;
          
        for (Target_Setting_Staging__c eachStaging :listIncomingStaging) {
            
           
            // PREPARE STAGING BY ITEM UNIQUE ID
            
            uniqueGroupId = TargetSettingUtil.generateUniqueIdFromString(
                eachStaging.Country_Code__c + eachStaging.Brand__c + eachStaging.Product_Family__c) + targetId;
            
            System.debug('uniqueGroupId--->'+uniqueGroupId);
           
            //CODE COMMENTED AS PART OF 14216
            /*if (String.isNotBlank(eachStaging.Price_Owner__c) && String.isNotBlank(eachStaging.Price_Owner_Account_Id__c)) {
                setTargetItemId.add(uniqueGroupId + eachStaging.Price_Owner_Account_Id__c);
                // PREPARE DS FOR ERROR HANDLING
                TargetSettingBatchHelper.preapareStringCollectionByUniqueId(
                    uniqueGroupId + eachStaging.Price_Owner_Account_Id__c, eachStaging.Id, mapStagingIdByItemUId);
            }*/
             // SFSE-14216  GET PRICE OWNER BY ITEM ID , 
            if(String.isNotBlank(eachStaging.Price_Owner__c)){
               
                setTargetItemId.add(uniqueGroupId + eachStaging.Price_Owner__c);
              
                TargetSettingBatchHelper.preapareStringCollectionByUniqueId(
                   uniqueGroupId + eachStaging.Price_Owner__c, eachStaging.Id, mapStagingIdByItemUId);
                
            }
            

            
            // GET SHIPPER OWNER BY ITEM ID
           /* if (String.isNotBlank(eachStaging.Shipper__c) && String.isNotBlank(eachStaging.Shipper_Account_Id__c)) {
                System.debug('Shipper--->');
                setTargetItemId.add(uniqueGroupId + eachStaging.Shipper_Account_Id__c);
                // PREPARE DS FOR ERROR HANDLING
                TargetSettingBatchHelper.preapareStringCollectionByUniqueId(
                    uniqueGroupId + eachStaging.Shipper_Account_Id__c, eachStaging.Id, mapStagingIdByItemUId);
            }

            // GET CONSIGNEE OWNER BY ITEM ID
            if (String.isNotBlank(eachStaging.Consignee__c) && String.isNotBlank(eachStaging.Consignee_Account_Id__c)) {
                System.debug('Consignee--->');
                setTargetItemId.add(uniqueGroupId + eachStaging.Consignee_Account_Id__c);
                // PREPARE DS FOR ERROR HANDLING
                TargetSettingBatchHelper.preapareStringCollectionByUniqueId(
                    uniqueGroupId + eachStaging.Consignee_Account_Id__c, eachStaging.Id, mapStagingIdByItemUId);
            }*/
               //SHIPPER
            if (String.isNotBlank(eachStaging.Shipper__c)) {
                System.debug('Shipper--->');
                setTargetItemId.add(uniqueGroupId + eachStaging.ShippeR__c);
                // PREPARE DS FOR ERROR HANDLING
                TargetSettingBatchHelper.preapareStringCollectionByUniqueId(
                    uniqueGroupId + eachStaging.Shipper__c, eachStaging.Id, mapStagingIdByItemUId);
            }
            //CONSIGNEE
            if (String.isNotBlank(eachStaging.Consignee__c)) {
                System.debug('Consignee--->');
                setTargetItemId.add(uniqueGroupId + eachStaging.Consignee__c);
                // PREPARE DS FOR ERROR HANDLING
                TargetSettingBatchHelper.preapareStringCollectionByUniqueId(
                    uniqueGroupId + eachStaging.Consignee__c, eachStaging.Id, mapStagingIdByItemUId);
            }

            
            TargetSettingBatchHelper.preapareSobjectCollectionByUniqueId(uniqueGroupId, eachStaging, mapStagingByGroupIdentifier);
           
        }
    }

    public static Map<String, Map<String, Target_Measure__c>> getExistingMeasures(Set<String> setTargetItemId) {
    
        Map<String, Map<String, Target_Measure__c>> mapMeasureByMeasureIdByItemIdContext = new Map<String, Map<String, Target_Measure__c>>();
       
        String uniqueMeasureId;
        // ADD EXISTING TARGET MEASURES TO CURRENT CONTEXT VARIABLE
        for (Target_Measure__c eachMeasure :[   SELECT Id 
                                                    , Jan__c
                                                    , Feb__c
                                                    , Mar__c
                                                    , Apr__c
                                                    , May__c
                                                    , Jun__c
                                                    , Jul__c
                                                    , Aug__c
                                                    , Sep__c
                                                    , Oct__c
                                                    , Nov__c
                                                    , Dec__c
                                                    , Measure_Dimension__c
                                                    , Measure_Type__c
                                                    , Party_Type__c
                                                    , Credit_Eligible__c
                                                    , Target_Item__r.Unique_Identifier__c
                                                FROM Target_Measure__c
                                                WHERE Target_Item__r.Unique_Identifier__c IN :setTargetItemId ]) {
            
            // IF PY MEASURES EXISTS FOR ITEM COLLECT THEM IN THE CURRENT CONTEXT TO PROCESS
            uniqueMeasureId = eachMeasure.Target_Item__r.Unique_Identifier__c + eachMeasure.Measure_Dimension__c
                + eachMeasure.Measure_Type__c + eachMeasure.Party_Type__c + eachMeasure.Credit_Eligible__c;
          
            if(mapMeasureByMeasureIdByItemIdContext.get(eachMeasure.Target_Item__r.Unique_Identifier__c) == null) {
              
                mapMeasureByMeasureIdByItemIdContext.put(eachMeasure.Target_Item__r.Unique_Identifier__c
                    , new Map<String, Target_Measure__c>{ uniqueMeasureId => eachMeasure });
               
            }
            // WE CANNOT HAVE 2 MEASURES WITH DIMENSION, TYPE, PARTY TYPE COMBINATION
            mapMeasureByMeasureIdByItemIdContext.get(eachMeasure.Target_Item__r.Unique_Identifier__c).put(uniqueMeasureId, eachMeasure);
        }

        return mapMeasureByMeasureIdByItemIdContext;
    }

    // TODO: REFACTOR
    public static Map<String, Target_Item__c> getItemsAndMeasuresForDml(Map<String, Map<String, Target_Measure__c>> mapMeasureByMeasureIdByItemIdContext
        , Map<String, List<Target_Setting_Staging__c>> mapStagingByGroupIdentifier) 
    {
        Map<String, Target_Item__c> mapUpsertTargetItem = new Map<String, Target_Item__c>();
        Target_Item__c newTargetItem;
           
        for (Target_Item_Group__c eachTig :[    SELECT Id
                                                    , Unique_Identifier__c
                                                FROM Target_Item_Group__c
                                                WHERE Unique_Identifier__c IN :mapStagingByGroupIdentifier.keySet() ]) {
            System.debug('eachTig---->'+eachTig);                                        
            // CREATE/UPDATE TARGET ITEMS
            //SFSE-14216 introducing ELSE part for the case when Price_Owner_Account_Id__c this will be null 
            for (Target_Setting_Staging__c eachStaging :mapStagingByGroupIdentifier.get(eachTig.Unique_Identifier__c)) {
               
                // FOR PRICE OWNER
                if (String.isNotBlank(eachStaging.Price_Owner__c)) {
                   
                    newTargetItem = TargetSettingBatchHelper.mapTargetItemFromStaging(
                            eachStaging, TargetSettingConstants.PARTY_PO_FIELD, eachTig.Unique_Identifier__c);
                    System.debug('TI---->'+newTargetItem);
                    TargetSettingBatchHelper.prepareMeasureData(eachTig.Unique_Identifier__c
                            , TargetSettingConstants.PARTY_PO, eachStaging, mapMeasureByMeasureIdByItemIdContext);
                    if (mapUpsertTargetItem.get(eachTig.Unique_Identifier__c + eachStaging.Price_Owner__c) == null) {
                        mapUpsertTargetItem.put(eachTig.Unique_Identifier__c + eachStaging.Price_Owner__c, newTargetItem);
                    }
                }
                
                // FOR SHIPPER
                if (String.isNotBlank(eachStaging.Shipper__c)) {
                    System.debug('Shipper---->'+eachStaging.Shipper__c);
                    System.debug('Shipper---->'+eachStaging.Shipper_Account_Id__c);
                    
                    newTargetItem = TargetSettingBatchHelper.mapTargetItemFromStaging(
                            eachStaging, TargetSettingConstants.PARTY_SHIPPER_FIELD, eachTig.Unique_Identifier__c);
                    System.debug('TI---->'+newTargetItem);
                    TargetSettingBatchHelper.prepareMeasureData(eachTig.Unique_Identifier__c
                            , TargetSettingConstants.PARTY_SHIPPER, eachStaging, mapMeasureByMeasureIdByItemIdContext);
                    if (mapUpsertTargetItem.get(eachTig.Unique_Identifier__c + eachStaging.Shipper__c) == null) {
                        mapUpsertTargetItem.put(eachTig.Unique_Identifier__c + eachStaging.Shipper__c, newTargetItem);
                    }
                }
                // FOR CONSIGNEE
                if (String.isNotBlank(eachStaging.Consignee__c)) {
                    System.debug('CONSIGNEE---->'+eachStaging.Consignee__c);
                    System.debug('CONSIGNEE---->'+eachStaging.Consignee_Account_Id__c);
                    
                    newTargetItem = TargetSettingBatchHelper.mapTargetItemFromStaging(
                            eachStaging, TargetSettingConstants.PARTY_CONSIGNEE_FIELD, eachTig.Unique_Identifier__c);
                    System.debug('TI---->'+newTargetItem);
                    TargetSettingBatchHelper.prepareMeasureData(eachTig.Unique_Identifier__c
                            , TargetSettingConstants.PARTY_CONSIGNEE, eachStaging, mapMeasureByMeasureIdByItemIdContext);
                    if (mapUpsertTargetItem.get(eachTig.Unique_Identifier__c + eachStaging.Consignee__c) == null) {
                        mapUpsertTargetItem.put(eachTig.Unique_Identifier__c + eachStaging.Consignee__c, newTargetItem);
                    }
                }
            }
        }

       return mapUpsertTargetItem;
    }


    // TODO: REFACTOR
    public static List<Target_Setting_Staging__c> upsertAndvalidateTargetItems(List<Target_Item__c> listTargetItem
        , Map<String, Set<String>> mapStagingIdByItemUId
        , Map<String, Map<String, Target_Measure__c>> mapMeasureByMeasureIdByItemIdContext) {
        Map<Id, Target_Setting_Staging__c> retVal = new Map<Id, Target_Setting_Staging__c>();
        Integer iterator = 0;
        String errorMessage;
        Database.Error errInstance;
        for (Database.UpsertResult eachResult :Database.upsert(listTargetItem, Target_Item__c.Unique_Identifier__c.getDescribe().getSObjectField(), false)) {
            if (!eachResult.isSuccess()) {
                if (eachResult.isCreated()) {
                    // IF INSERT FAILURE RECORD FAILURE
                    for (Id eachStagingId :mapStagingIdByItemUId.get(listTargetItem.get(iterator).Unique_Identifier__c)) {
                        errInstance = eachResult.getErrors().get(0);
                        errorMessage =  errInstance.getMessage() + errInstance.getStatusCode().name()
                            + (errInstance.getFields() != null && !errInstance.getFields().isEmpty() ? errInstance.getFields().get(0) : '');
                      
                        retVal.put(eachStagingId, new Target_Setting_Staging__c(
                                Id = eachStagingId
                            ,   Status__c = TargetSettingConstants.STAGING_STATUS_FAILED
                            ,   Message__c = errorMessage.length() > 255 ? errorMessage.substring(0, 255) : errorMessage
                        ));
                    }
                   
                    mapMeasureByMeasureIdByItemIdContext.remove(listTargetItem.get(iterator).Unique_Identifier__c);
                } else {
                    // IF UPDATE FAILURE RECORD SUCCESS AS ITEM ALREADY EXISTS IN SYSTEM
                    for (Id eachStagingId :mapStagingIdByItemUId.get(listTargetItem.get(iterator).Unique_Identifier__c)) {
                        if (retVal.get(eachStagingId) == null) {
                            retVal.put(eachStagingId, new Target_Setting_Staging__c(
                                    Id = eachStagingId
                                ,   Status__c = TargetSettingConstants.STAGING_STATUS_PROCESSED
                                ,   Message__c = ''
                            ));
                        }
                    }
                }
                // REMOVE THE ITEM FROM MAP AS ALL STAGING PROCESSED FOR THE ITEM
                mapStagingIdByItemUId.remove(listTargetItem.get(iterator).Unique_Identifier__c);
            } else {
                // RECORD SUCCESS IF DML SUCCESSFUL
                for (Id eachStagingId :mapStagingIdByItemUId.get(listTargetItem.get(iterator).Unique_Identifier__c)) {
                    if (retVal.get(eachStagingId) == null) {
                        retVal.put(eachStagingId, new Target_Setting_Staging__c(
                                Id = eachStagingId
                            ,   Status__c = TargetSettingConstants.STAGING_STATUS_PROCESSED
                            ,   Message__c = ''
                        ));
                    }
                }
            }

            iterator++;
        }

        return retVal.values();
    }
    //SFSE-11402 - Creates Budget Groups if doesnt exists for the given TargetId.
    public static void createBudgetGroups(List<Target_Setting_Staging__c> stagingRecords, Id targetId){
        
        List<Budget_Group__c> budgetGrps = new List<Budget_Group__c>();
        for(Target_Setting_Staging__c str: stagingRecords){
         	budgetGrps.add(new Budget_Group__c(Product_Family__c=str.Product_Family__c,Brand__c=str.Brand__c,Executing_Area__c =str.Area__c,Target__c=targetId,Executing_Country__c= str.Country__c, Country_Code__c= str.Country_Code__c));  
        }
        
        if(!budgetGrps.isEmpty()){
           Database.SaveResult[] results = Database.insert(budgetGrps, FALSE);
           ErrorLogger.writeErrors('SFDC', 'Sales Target', 'TargetSettingActualsLoadBatch.execute()', results, budgetGrps); 
        }
    }
}