public inherited sharing class TargetSettingController {    
    @AuraEnabled
    public static List<SObject> getTargetMeasure(String targetItemGrpId, String type) {
        List<Target_Item_Group__c> targetItemGroupList = [  SELECT Id
                                                          , Product_Family__c
                                                          , BrandMnA__c
                                                          , Country_Code__c
                                                          , Target__c
                                                          FROM Target_Item_Group__c
                                                          WHERE Id = :targetItemGrpId 
                                                          WITH SECURITY_ENFORCED ];
        
        if (targetItemGroupList != null && !targetItemGroupList.isEmpty()) {
            if (!'Target'.equals(type)) {
                Set<String> setMeasureType;
                if ('Budget Growth'.equals(type)) {
                    setMeasureType = new Set<String> {'Revenue Growth Percent','Gross Profit Growth Percent','Volume Growth Percent'};
                        type = 'Budget';
                } else {
                    setMeasureType = new Set<String> {'Revenue','Gross Profit','Volume'};
                        }
                if (type.contains('Budget') || type.contains('Rolling Forecast')) {
                    List<Budget_Measure__c> budgetMeasure = [   SELECT Id
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
                                                             , Total__c
                                                             , Measure_Dimension__c
                                                             , Measure_Type__c
                                                             FROM Budget_Measure__c
                                                             WHERE Measure_Dimension__c = :type
                                                             AND Measure_Type__c IN :setMeasureType
                                                             AND Budget_Group__r.Brand__c = :targetItemGroupList[0].BrandMnA__c
                                                             AND Budget_Group__r.Country_Code__c = :targetItemGroupList[0].Country_Code__c
                                                             AND Budget_Group__r.Product_Family__c = :targetItemGroupList[0].Product_Family__c
                                                             AND Budget_Group__r.Target__c = :targetItemGroupList[0].Target__c
                                                             WITH SECURITY_ENFORCED ];
                    return budgetMeasure;
                } else {
                    List<Target_Measure__c> targetMeasure = [ SELECT Id
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
                                                             , Total__c
                                                             , Measure_Dimension__c
                                                             , Measure_Type__c
                                                             FROM Target_Measure__c
                                                             WHERE Measure_Dimension__c = :type
                                                             AND Target_Item__r.Sales_Target_Item_Group__c = :targetItemGrpId
                                                             WITH SECURITY_ENFORCED
                                                            ];
                    return targetMeasure;
                }
            } else {
                return [ SELECT sum(Jan__c) Jan__c
                        , sum(Feb__c) Feb__c
                        , sum(Mar__c) Mar__c
                        , sum(Apr__c) Apr__c
                        , sum(May__c) May__c
                        , sum(Jun__c) Jun__c
                        , sum(Jul__c) Jul__c
                        , sum(Aug__c) Aug__c
                        , sum(Sep__c) Sep__c
                        , sum(Oct__c) Oct__c
                        , sum(Nov__c) Nov__c
                        , sum(Dec__c) Dec__c
                        , sum(Total__c) Total__c
                        , Measure_Type__c
                        FROM Target_Measure__c 
                        WHERE Measure_Dimension__c = :type
                        AND Party_Type__c = 'Price Owner'
                        AND Target_Item__r.Sales_Target_Item_Group__c = :targetItemGrpId
                        GROUP BY Target_Item__r.Sales_Target_Item_Group__c, Measure_Type__c ];
            }
        }
        
        return null;
    } 
}