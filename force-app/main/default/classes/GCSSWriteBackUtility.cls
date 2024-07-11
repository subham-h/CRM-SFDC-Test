public class GCSSWriteBackUtility{

@AuraEnabled(cacheable=true)
public static String getSizeTypeHeight(){
    List<Equipment_Size_Type_Height__mdt> EqSTHList = [SELECT SizeTypeId__c,Size__c,Type__c,Height__c,ActiveReefer__c,HasRkemProfile__c from Equipment_Size_Type_Height__mdt ORDER BY Size__c ASC,type__c ASC];
    Map<String,List<String>> sizeToType = new Map<String,List<String>>();
    Map<String,List<String>> sizeTypeToHeight = new Map<String,List<String>>();
    for(Equipment_Size_Type_Height__mdt eq : EqSTHList){
        if(sizeToType.containsKey(eq.Size__c)){
            sizeToType.get(eq.Size__c).add(eq.Type__c);
        } else {
            sizeToType.put(eq.Size__c,new List<String>{eq.Type__c});
        }
        
        sizeTypeToHeight.put(eq.Size__c+'-'+eq.Type__c,new List<String>());
        if(eq.Height__c <> NULL) {
            List<String> hght = eq.Height__c.split(',');
            sizeTypeToHeight.get(eq.Size__c+'-'+eq.Type__c).addAll(hght);
        }
        //new List<String>{eq.Height__c}
    }
    
    Map<String,Map<String,List<String>>> eqDimensionList = new Map<String,Map<String,List<String>>>();
    eqDimensionList.put('SizeToType',sizeToType);
    eqDimensionList.put('SizeTypeHeight',sizeTypeToHeight);    
    
    return JSON.serialize(eqDimensionList);
}

}