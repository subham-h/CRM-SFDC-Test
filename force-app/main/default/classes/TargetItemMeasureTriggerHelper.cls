/*
*  User Story       Date        Developer       Functionality
*  SFSE-11420       30/08/2023  Anjali          Class Created
*  SFSE-13010                   Arpitha         Added updateTargetMeasurePercentage method to apply percentage on measure records
*/

public inherited sharing class TargetItemMeasureTriggerHelper {
    
    public static void generateUniqueKey(List<Target_measure__c> targetMeasureList) {    
        for (Target_measure__c targetMeasure : targetMeasureList) {
            targetMeasure.Unique_Identifier__c = targetMeasure.Measure_dimension__c + targetMeasure.Measure_type__c + targetMeasure.Party_Type__c 
                + targetMeasure.Credit_Eligible__c + targetMeasure.Target_item__c;    
        }
    }
    
    //method to apply percentage on measure records
    public static void updateTargetMeasurePercentage(List<Target_measure__c> newTargetMeasuresList,Map<Id,Target_measure__c>oldTargetMeasureMap){
        String uniqueKey='';
        set<String> setMeasureDimension = new set<String>();
        set<Id>setTargetItemId = new set<Id>();
        set<String>setPartyType = new set<String>();
        set<Boolean>setCreditEligibility = new set<Boolean>();
        set<String>setMeasureType = new set<String>();
        map<String,double>mapEachMonthPercentage = new map<String,double>();
        Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
            5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
                List<Target_measure__c>updateMeasureRecordsList = new List<Target_measure__c>();
        double monthValue=0.0;
        string monthName='';
        
        for(Target_measure__c eachMeasure:newTargetMeasuresList){
            if(eachMeasure.Measure_dimension__c == TargetSettingConstants.TARGET){
                uniqueKey = eachMeasure.Measure_dimension__c+'_'+eachMeasure.Party_Type__c+'_'+eachMeasure.Credit_Eligible__c+'_'+eachMeasure.Target_item__c;
                if(eachMeasure.Jan__c !=oldTargetMeasureMap.get(eachMeasure.Id).Jan__c && oldTargetMeasureMap.get(eachMeasure.Id).Jan__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Jan__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Jan__c',((eachMeasure.Jan__c-oldTargetMeasureMap.get(eachMeasure.Id).Jan__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Jan__c))*100);
                }
                if(eachMeasure.Feb__c !=oldTargetMeasureMap.get(eachMeasure.Id).Feb__c && oldTargetMeasureMap.get(eachMeasure.Id).Feb__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Feb__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Feb__c',((eachMeasure.Feb__c-oldTargetMeasureMap.get(eachMeasure.Id).Feb__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Feb__c))*100);
                }
                if(eachMeasure.Mar__c !=oldTargetMeasureMap.get(eachMeasure.Id).Mar__c && oldTargetMeasureMap.get(eachMeasure.Id).Mar__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Mar__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Mar__c',((eachMeasure.Mar__c-oldTargetMeasureMap.get(eachMeasure.Id).Mar__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Mar__c))*100);
                }
                if(eachMeasure.Apr__c !=oldTargetMeasureMap.get(eachMeasure.Id).Apr__c && oldTargetMeasureMap.get(eachMeasure.Id).Apr__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Apr__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Apr__c',((eachMeasure.Apr__c-oldTargetMeasureMap.get(eachMeasure.Id).Apr__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Apr__c))*100);
                }
                if(eachMeasure.May__c !=oldTargetMeasureMap.get(eachMeasure.Id).May__c && oldTargetMeasureMap.get(eachMeasure.Id).May__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).May__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_May__c',((eachMeasure.May__c-oldTargetMeasureMap.get(eachMeasure.Id).May__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).May__c))*100);
                }
                if(eachMeasure.Jun__c !=oldTargetMeasureMap.get(eachMeasure.Id).Jun__c && oldTargetMeasureMap.get(eachMeasure.Id).Jun__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Jun__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Jun__c',((eachMeasure.Jun__c-oldTargetMeasureMap.get(eachMeasure.Id).Jun__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Jun__c))*100);
                }
                if(eachMeasure.Jul__c !=oldTargetMeasureMap.get(eachMeasure.Id).Jul__c && oldTargetMeasureMap.get(eachMeasure.Id).Jul__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Jul__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Jul__c',((eachMeasure.Jul__c-oldTargetMeasureMap.get(eachMeasure.Id).Jul__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Jul__c))*100);
                }
                if(eachMeasure.Aug__c !=oldTargetMeasureMap.get(eachMeasure.Id).Aug__c && oldTargetMeasureMap.get(eachMeasure.Id).Aug__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Aug__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Aug__c',((eachMeasure.Aug__c-oldTargetMeasureMap.get(eachMeasure.Id).Aug__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Aug__c))*100);
                }
                if(eachMeasure.Sep__c !=oldTargetMeasureMap.get(eachMeasure.Id).Sep__c && oldTargetMeasureMap.get(eachMeasure.Id).Sep__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Sep__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Sep__c',((eachMeasure.Sep__c-oldTargetMeasureMap.get(eachMeasure.Id).Sep__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Sep__c))*100);
                }
                if(eachMeasure.Oct__c !=oldTargetMeasureMap.get(eachMeasure.Id).Oct__c && oldTargetMeasureMap.get(eachMeasure.Id).Oct__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Oct__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Oct__c',((eachMeasure.Oct__c-oldTargetMeasureMap.get(eachMeasure.Id).Oct__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Oct__c))*100);
                }
                if(eachMeasure.Nov__c !=oldTargetMeasureMap.get(eachMeasure.Id).Nov__c && oldTargetMeasureMap.get(eachMeasure.Id).Nov__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Nov__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Nov__c',((eachMeasure.Nov__c-oldTargetMeasureMap.get(eachMeasure.Id).Nov__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Nov__c))*100);
                }
                if(eachMeasure.Dec__c !=oldTargetMeasureMap.get(eachMeasure.Id).Dec__c && oldTargetMeasureMap.get(eachMeasure.Id).Dec__c!=null && oldTargetMeasureMap.get(eachMeasure.Id).Dec__c!=0){
                    mapEachMonthPercentage.put(uniqueKey+'_Dec__c',((eachMeasure.Dec__c-oldTargetMeasureMap.get(eachMeasure.Id).Dec__c)/Math.abs(oldTargetMeasureMap.get(eachMeasure.Id).Dec__c))*100);
                }
                
                if(mapEachMonthPercentage!=null && mapEachMonthPercentage.size()>0){
                    
                    setMeasureDimension.add(eachMeasure.Measure_dimension__c);
                    setTargetItemId.add(eachMeasure.Target_item__c);
                    setPartyType.add(eachMeasure.Party_Type__c);
                    setCreditEligibility.add(eachMeasure.Credit_Eligible__c); 
                    setMeasureType.add(eachMeasure.Measure_type__c);
                }
                
            }
        }
        
        List<Target_measure__c>taregtMeasureRecordsList = [Select id,Jan__c,Feb__c,Mar__c,Apr__c,May__c,Jun__c,Jul__c,Aug__c,Sep__c,Oct__c,Nov__c,Dec__c,Credit_Eligible__c,Measure_Dimension__c,Target_Item__c,
                                                           Measure_Type__c,Party_Type__c from Target_measure__c where Target_Item__c=:setTargetItemId AND Measure_Dimension__c=:setMeasureDimension AND Party_Type__c=:setPartyType AND Credit_Eligible__c=:setCreditEligibility AND Measure_type__c!=:setMeasureType];
        
        
        for(Target_measure__c eachMeasure:taregtMeasureRecordsList){
            if(mapEachMonthPercentage!=null && mapEachMonthPercentage.size()>0){
                uniqueKey = eachMeasure.Measure_dimension__c+'_'+eachMeasure.Party_Type__c+'_'+eachMeasure.Credit_Eligible__c+'_'+eachMeasure.Target_item__c;
                for(Integer i=1;i<=12;i++){
                    if(mapEachMonthPercentage.containskey(uniqueKey+'_'+mapMonth.get(i)) && mapEachMonthPercentage.get(uniqueKey+'_'+mapMonth.get(i))!=null){
                        monthName = mapMonth.get(i);
                        monthValue = Double.valueof(eachMeasure.get(mapMonth.get(i)))+(Math.abs(Double.valueof(eachMeasure.get(mapMonth.get(i))))*mapEachMonthPercentage.get(uniqueKey+'_'+mapMonth.get(i)))/100;
                        eachMeasure.put(mapMonth.get(i),monthValue);
                        
                    }
                }
                updateMeasureRecordsList.add(eachMeasure);
            }
        }
        
        if(updateMeasureRecordsList.size()>0){
            Database.SaveResult[] results = Database.update(updateMeasureRecordsList, false); 
        }
    }
}