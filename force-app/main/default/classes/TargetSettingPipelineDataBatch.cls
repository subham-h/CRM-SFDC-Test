/*
* Author    : Arpitha J
* Description   : Function to capture Gross Profit & Volume of measures
*       : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   4-07-23    Arpitha@maersk           Created. 
* 2.0                   4-08-23    Arpitha@maersk           Logic Implemented to retrieve brand from legacy brand.
* 
*/
public class TargetSettingPipelineDataBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public String targetId;
    public Boolean isError = false;
    public String targetOwnerEmailId;
    
    public TargetSettingPipelineDataBatch(){
    }
    public TargetSettingPipelineDataBatch(String targetId){
        this.targetId = targetId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String currYear = string.valueof(Date.today().year());
        String nextYear = String.valueof(Date.today().year()+1);
        if(!String.isEmpty(targetId)){
            Target__c target = [Select id,Applicable_Year__c,Status__c,owner.email, Stage_Status__c from Target__c where id=:targetId limit 1];   
            if(target.owner.email!=null){
                targetOwnerEmailId = target.owner.email;    
            }  
            target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_IN_PROGRESS; 
            update target;
        }
        return Database.getQueryLocator([select id,Account__c,Sales_Target_Item_Group__c,Sales_Target_Item_Group__r.Target__r.Applicable_Year__c,Sales_Target_Item_Group__r.BrandMnA__c,Sales_Target_Item_Group__r.Country_Code__c,Sales_Target_Item_Group__r.Product_Family__c from Target_Item__c where Sales_Target_Item_Group__r.Target__r.Status__c!=null AND Sales_Target_Item_Group__r.Target__r.Status__c!='Closed' AND Sales_Target_Item_Group__r.Target__r.Status__c!='Cancelled' AND (Sales_Target_Item_Group__r.Target__r.Applicable_Year__c=:currYear OR Sales_Target_Item_Group__r.Target__r.Applicable_Year__c=:nextYear)]);
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Item__c> targetItemRecords){
        Integer currMonth = Date.today().month();
        set<Id>accIds = new set<Id>();
        set<Id>targetIds = new set<Id>();
        set<String>brandName = new set<String>();
        set<String>productFamilyName = new set<String>();
        set<String>countryCodeName = new set<STring>();
        Map<Id,List<Opportunity_Product__c>>mapAccOppLineItem = new Map<Id,List<Opportunity_Product__c>>();
        Map<Id,Product2>prodMap = new Map<Id,Product2>([Select id,Family from product2 where IsActive = True]);
        Map<String,Legacy_Product_Mapping__c>legacyProdMapping = new Map<String,Legacy_Product_Mapping__c>();
        Map<String,String>mapTargetBrandMapping = new Map<String,String>();
        Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
            5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
                Map<String,Id>mappingTarget = new Map<String,Id>();
        Map<String,List<Target_Measure__c>>mapAccTargetMeasureType = new Map<String,List<Target_Measure__c>>();
        List<Target_Measure__c>targetMeasureInsertList = new List<Target_Measure__c>();
        List<Target_Measure__c>targetMeasureUpdateList = new List<Target_Measure__c>();
        Map<Id,List<Opportunity_Product_Schedule__c>>mapAccProdSchedule = new Map<Id,List<Opportunity_Product_Schedule__c>>();
        Map<String,Double>mapScheduleGrossProfitMonthlyData = new Map<String,Double>();
        Map<String,Double>mapScheduleVloumeMonthlyData = new Map<String,Double>();
        Target_Measure__c measureRecGP;
        Target_Measure__c measureRecVol;
        set<Id>setOppLineItemId = new set<Id>();
        Map<Id,Boolean>mapCreateMeasureGrossProfit = new Map<Id,Boolean>();
        Map<Id,Boolean>mapCreateMeasureVolume = new Map<Id,Boolean>();
        
        
        
        //legacy product family mapping
        legacyProdMapping = TargetSettingBatchHelper.legacyProdMappingMethod();
        
        //legacy brand mapping
        mapTargetBrandMapping = TargetSettingBatchHelper.targetBrandMappingMethod();
        
        
        for(Target_Item__c tarRec:targetItemRecords){
            targetIds.add(tarRec.Id);
            if(tarRec.Account__c!=null){
                accIds.add(tarRec.Account__c);
            }
            if(tarRec.Sales_Target_Item_Group__r.BrandMnA__c!=null && mapTargetBrandMapping!=null && mapTargetBrandMapping.containskey(tarRec.Sales_Target_Item_Group__r.BrandMnA__c) && mapTargetBrandMapping.get(tarRec.Sales_Target_Item_Group__r.BrandMnA__c)!=null){
                brandName.add(mapTargetBrandMapping.get(tarRec.Sales_Target_Item_Group__r.BrandMnA__c));
            }
            if(tarRec.Sales_Target_Item_Group__r.Country_Code__c!=null){
                countryCodeName.add(tarRec.Sales_Target_Item_Group__r.Country_Code__c);    
            }
            if(tarRec.Sales_Target_Item_Group__r.Product_Family__c!=null){
                if(legacyProdMapping.containskey(tarRec.Sales_Target_Item_Group__r.Product_Family__c) 
                   && legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c!=null
                   && prodMap.containskey(legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c)
                   && prodMap.get(legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c).Family!=null){
                       productFamilyName.add(prodMap.get(legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c).Family);
                   }
            } 
            if(tarRec.Account__c!=null && tarRec.Sales_Target_Item_Group__r.BrandMnA__c!=null && tarRec.Sales_Target_Item_Group__r.Country_Code__c!=null && 
               legacyProdMapping.containskey(tarRec.Sales_Target_Item_Group__r.Product_Family__c) 
               && legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c!=null
               && prodMap.containskey(legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c)
               && prodMap.get(legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c).Family!=null){
                   mappingTarget.put(tarRec.Account__c+tarRec.Sales_Target_Item_Group__r.BrandMnA__c+tarRec.Sales_Target_Item_Group__r.Country_Code__c+prodMap.get(legacyProdMapping.get(tarRec.Sales_Target_Item_Group__r.Product_Family__c).Product__c).Family,tarRec.Id);
               }
               
               system.debug('==productFamilyName=='+productFamilyName);
               
        }
        
        //get opportunity line item records
        mapAccOppLineItem = TargetSettingBatchHelper.getOpportunityLineItem(accIds,brandName,countryCodeName,productFamilyName);
        
        if(mapAccOppLineItem.values().size()>0){
            for(Id accId:mapAccOppLineItem.keyset()){
                for(Opportunity_Product__c oli:mapAccOppLineItem.get(accId)){
                   setOppLineItemId.add(oli.Id); 
                }
            }
        }
        
        //get opportunity product schedule
        mapAccProdSchedule = TargetSettingBatchHelper.getOpportunityProductSchedule(setOppLineItemId,currMonth);
        
        for(Id accId:mapAccOppLineItem.keyset()){
            if(mapAccOppLineItem!=null && mapAccOppLineItem.containskey(accId) && mapAccOppLineItem.get(accId)!=null){
                for(Opportunity_Product__c oli:mapAccOppLineItem.get(accId)){
                    String mappingTargetItemId;
                    String monthName;
                    if(mappingTarget!=null && mappingTarget.containskey(oli.OpportunityId__r.AccountId+oli.OpportunityId__r.Liner_Brand__c+oli.Country__r.GEO_Code__c+oli.Product2ID__r.Family) && mappingTarget.get(oli.OpportunityId__r.AccountId+oli.OpportunityId__r.Liner_Brand__c+oli.Country__r.GEO_Code__c+oli.Product2ID__r.Family)!=null){
                        mappingTargetItemId = mappingTarget.get(oli.OpportunityId__r.AccountId+oli.OpportunityId__r.Liner_Brand__c+oli.Country__r.GEO_Code__c+oli.Product2ID__r.Family);
                    }
                    
                    if(mapAccProdSchedule!=null && mapAccProdSchedule.containskey(oli.id) && mapAccProdSchedule.get(oli.id)!=null){
                        for(Opportunity_Product_Schedule__c prodSch:mapAccProdSchedule.get(oli.id)){
                            if(mapMonth.containskey(prodSch.Schedule_Date__c.month()) && mapMonth.get(prodSch.Schedule_Date__c.month())!=null){   
                                monthName = mapMonth.get(prodSch.Schedule_Date__c.month());
                            }
                            String key = accId+mappingTargetItemId+monthName+prodSch.Schedule_Date__c.year();
                            
                            if(oli.OpportunityId__r.IsClosed == True && oli.OpportunityId__r.IsWon){ //Closed Won Opportunities
                                if(!mapScheduleGrossProfitMonthlyData.containskey(key) && mapScheduleGrossProfitMonthlyData.get(key)==null){
                                    if(prodSch.Revenue__c!=null){
                                        mapScheduleGrossProfitMonthlyData.put(key,prodSch.Revenue__c); 
                                        if(!mapCreateMeasureGrossProfit.containskey(mappingTargetItemId)){
                                            mapCreateMeasureGrossProfit.put(mappingTargetItemId,true);      
                                        }
                                    }                                    
                                }
                                else{
                                    if(prodSch.Revenue__c!=null){
                                        mapScheduleGrossProfitMonthlyData.put(key,mapScheduleGrossProfitMonthlyData.get(key)+prodSch.Revenue__c);
                                        if(!mapCreateMeasureGrossProfit.containskey(mappingTargetItemId)){
                                            mapCreateMeasureGrossProfit.put(mappingTargetItemId,true); 
                                        }
                                    }
                                }
                                
                                if(!mapScheduleVloumeMonthlyData.containskey(key) && mapScheduleVloumeMonthlyData.get(key)==null){
                                    if(prodSch.Quantity__c!=null){
                                        mapScheduleVloumeMonthlyData.put(key,prodSch.Quantity__c); 
                                        if(!mapCreateMeasureVolume.containskey(mappingTargetItemId)){
                                            mapCreateMeasureVolume.put(mappingTargetItemId,true);    
                                        }
                                    }                                      
                                }
                                else{
                                    if(prodSch.Quantity__c!=null){
                                        mapScheduleVloumeMonthlyData.put(key,mapScheduleVloumeMonthlyData.get(key)+prodSch.Quantity__c);
                                        if(!mapCreateMeasureVolume.containskey(mappingTargetItemId)){
                                            mapCreateMeasureVolume.put(mappingTargetItemId,true);
                                        }
                                    }
                                }  
                            }
                            if(oli.OpportunityId__r.IsClosed==false){//Open opportunpities
                                Double gpValue = 0.0;
                                Double volValue = 0.0;
                                if(prodSch.Revenue__c!=null){
                                    gpValue = (prodSch.Revenue__c/100)*oli.OpportunityId__r.Probability;
                                }
                                if(prodSch.Quantity__c!=null){
                                    volValue = (prodSch.Quantity__c/100)*oli.OpportunityId__r.Probability; 
                                }
                                
                                if(!mapScheduleGrossProfitMonthlyData.containskey(key) && mapScheduleGrossProfitMonthlyData.get(key)==null){
                                    if(gpValue>0.0){
                                        mapScheduleGrossProfitMonthlyData.put(key,gpValue);  
                                        if(!mapCreateMeasureGrossProfit.containskey(mappingTargetItemId)){
                                            mapCreateMeasureGrossProfit.put(mappingTargetItemId,true);  
                                        }                  
                                    }                         
                                }
                                
                                else{
                                    if(gpValue>0.0){
                                        mapScheduleGrossProfitMonthlyData.put(key,mapScheduleGrossProfitMonthlyData.get(key)+gpValue);
                                        if(!mapCreateMeasureGrossProfit.containskey(mappingTargetItemId)){
                                            mapCreateMeasureGrossProfit.put(mappingTargetItemId,true); 
                                        }
                                    }
                                }
                                
                                if(!mapScheduleVloumeMonthlyData.containskey(key) && mapScheduleVloumeMonthlyData.get(key)==null){
                                    if(volValue>0.0){
                                        mapScheduleVloumeMonthlyData.put(key,volValue); 
                                        if(!mapCreateMeasureVolume.containskey(mappingTargetItemId)){   
                                            mapCreateMeasureVolume.put(mappingTargetItemId,true);
                                        }    
                                    }                                       
                                }
                                else{
                                    if(volValue>0.0){
                                        mapScheduleVloumeMonthlyData.put(key,mapScheduleVloumeMonthlyData.get(key)+volValue);
                                        if(!mapCreateMeasureVolume.containskey(mappingTargetItemId)){
                                            mapCreateMeasureVolume.put(mappingTargetItemId,true);
                                        }
                                    }
                                }  
                                
                            } 
                        }
                    }
                    
                } 
            }   
        }
        
        //get target measure records
        mapAccTargetMeasureType = TargetSettingBatchHelper.getTargetMeasureRecords(targetIds);
        
        for(Target_Item__c targetItem : targetItemRecords){
        //Gross Profit
        if(mapAccTargetMeasureType!=null && mapAccTargetMeasureType.containskey(targetItem.Id+TargetSettingConstants.GROSS_PROFIT) && mapAccTargetMeasureType.get(targetItem.Id+TargetSettingConstants.GROSS_PROFIT)!=null){
            for(Target_Measure__c measureRec:mapAccTargetMeasureType.get(targetItem.Id+TargetSettingConstants.GROSS_PROFIT)){
                for(Integer i=1;i<=12;i++){
                    String keyGP = String.valueof(targetItem.Account__C)+String.valueof(targetItem.Id)+mapMonth.get(i)+targetItem.Sales_Target_Item_Group__r.Target__r.Applicable_Year__c;//targetItem.Account__C+targetItem.Id+mapMonth.get(i)+targetItem.Target__r.Applicable_Year__c;
                    if(mapScheduleGrossProfitMonthlyData!=null && mapScheduleGrossProfitMonthlyData.containskey(keyGP) && mapScheduleGrossProfitMonthlyData.get(keyGP)!=null){
                        measureRec.put(mapMonth.get(i),mapScheduleGrossProfitMonthlyData.get(keyGP)); 
                    }
                    else{
                        measureRec.put(mapMonth.get(i),0.0);     
                    }
                 } 
                 targetMeasureUpdateList.add(measureRec);   
            }
        }else{
            if(mapCreateMeasureGrossProfit!=null && mapCreateMeasureGrossProfit.containskey(targetItem.Id) && mapCreateMeasureGrossProfit.get(targetItem.Id) == true){
                measureRecGP = new Target_Measure__c();
                measureRecGP.Target_Item__c = targetItem.Id;
                measureRecGP.Measure_Type__c = TargetSettingConstants.GROSS_PROFIT;
                measureRecGP.Measure_Dimension__c = TargetSettingConstants.PIPELINE;
                for(Integer i=1;i<=12;i++){
                    String keyGP = String.valueof(targetItem.Account__C)+String.valueof(targetItem.Id)+mapMonth.get(i)+targetItem.Sales_Target_Item_Group__r.Target__r.Applicable_Year__c;//targetItem.Account__C+targetItem.Id+mapMonth.get(i)+targetItem.Target__r.Applicable_Year__c;
                    if(mapScheduleGrossProfitMonthlyData.containskey(keyGP) && mapScheduleGrossProfitMonthlyData.get(keyGP)!=null){
                        measureRecGP.put(mapMonth.get(i),mapScheduleGrossProfitMonthlyData.get(keyGP)); 
                    }
                }
                
                targetMeasureInsertList.add(measureRecGP);
                
             } 
        }
        //Volume
        if(mapAccTargetMeasureType!=null && mapAccTargetMeasureType.containskey(targetItem.Id+TargetSettingConstants.VOLUME) && mapAccTargetMeasureType.get(targetItem.Id+TargetSettingConstants.VOLUME)!=null){
            for(Target_Measure__c measureRec:mapAccTargetMeasureType.get(targetItem.Id+TargetSettingConstants.VOLUME)){
                for(Integer i=1;i<=12;i++){
                String keyVol = String.valueof(targetItem.Account__C)+String.valueof(targetItem.Id)+mapMonth.get(i)+targetItem.Sales_Target_Item_Group__r.Target__r.Applicable_Year__c;
                if(mapScheduleVloumeMonthlyData!=null && mapScheduleVloumeMonthlyData.containskey(keyVol) && mapScheduleVloumeMonthlyData.get(keyVol)!=null){
                    measureRec.put(mapMonth.get(i),mapScheduleVloumeMonthlyData.get(keyVol)); 
                }
                else{
                    measureRec.put(mapMonth.get(i),0.0);
                }
                                
                }
            targetMeasureUpdateList.add(measureRec); 
           } 
        }else{
            if(mapCreateMeasureVolume!=null && mapCreateMeasureVolume.containskey(targetItem.Id) && mapCreateMeasureVolume.get(targetItem.Id) == true){
                measureRecVol = new Target_Measure__c();
                measureRecVol.Target_Item__c = targetItem.Id;
                measureRecVol.Measure_Type__c = TargetSettingConstants.VOLUME;
                measureRecVol.Measure_Dimension__c = TargetSettingConstants.PIPELINE;
                
                for(Integer i=1;i<=12;i++){
                    String keyVol = String.valueof(targetItem.Account__C)+String.valueof(targetItem.Id)+mapMonth.get(i)+targetItem.Sales_Target_Item_Group__r.Target__r.Applicable_Year__c;
                    if(mapScheduleVloumeMonthlyData.containskey(keyVol) && mapScheduleVloumeMonthlyData.get(keyVol)!=null){
                        measureRecVol.put(mapMonth.get(i),mapScheduleVloumeMonthlyData.get(keyVol)); 
                    }
                }
                targetMeasureInsertList.add(measureRecVol);
            }
        }
            
        }
        
        TriggerExecutionController.isMeasureTriggerSkip = false;
        if(targetMeasureInsertList.size()>0){
            Database.SaveResult[] lstSaveResults = Database.Insert(targetMeasureInsertList, false);
            if(String.isNotBlank(targetId)){
                for(Integer i=0; i< lstSaveResults.size();i++){
                    if(!lstSaveResults[i].isSuccess()) {
                        isError = true;
                        break;
                    }
                }    
            }
            ErrorLogger.writeErrors('SFDC', 'Measure Insert', 'TargetSettingPipelineDataBatch', lstSaveResults, targetMeasureInsertList);
        }  
        
        TriggerExecutionController.isMeasureTriggerSkip = false;
        if(targetMeasureUpdateList.size()>0){
            Database.SaveResult[] lstUpdateResults = Database.Update(targetMeasureUpdateList, false);
            if(String.isNotBlank(targetId)){
                for(Integer i=0; i< lstUpdateResults.size();i++){
                    if(!lstUpdateResults[i].isSuccess()) {
                        isError = true;
                        break;
                    }
                }    
            }
            ErrorLogger.writeErrors('SFDC', 'Measure Update', 'TargetSettingPipelineDataBatch', lstUpdateResults, targetMeasureUpdateList);
            
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email  from AsyncApexJob where Id =:BC.getJobId()];
        if (String.isNotBlank(targetId)) {
            Target__c target = new Target__c();
            target.Id = targetId;
            if (isError || a.NumberOfErrors>0) {
                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_FAILED;
            } else {
                target.Stage_Status__c = TargetSettingConstants.STAGE_STATUS_COMPLETED;
            }
            Database.SaveResult[] lstUpdateResults = Database.update(new List<Target__c>{target}, false);
            ErrorLogger.writeErrors('SFDC', 'Target Update', 'TargetSettingPipelineDataBatch', lstUpdateResults, new List<Target__c>{target});
            if(isError || a.NumberOfErrors>0){
                TargetSettingBatchHelper.sendEmail(TargetSettingConstants.STAGE_STATUS_FAILED,TargetSettingConstants.PIPELINE,targetOwnerEmailId);
            }
            else{
                TargetSettingBatchHelper.sendEmail(TargetSettingConstants.STAGE_STATUS_COMPLETED,TargetSettingConstants.PIPELINE,targetOwnerEmailId);
            }
        }
    }
}