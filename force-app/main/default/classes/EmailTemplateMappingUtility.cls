/*
 * Author   : Ranjini@UST
 * Purpose  : Class for forming email template id map from custom metadata.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-006949   21-Sep-2017 Ranjini@UST             Created.
 * 2.0      RQ-007464   18-Jan-2018 Ranjini@UST             Added more filer map values.
 * 3.0      RQ-007986   17-Apr-2018 Ranjini@UST             Branded case creation & Closure for Vendor cases
 */
public class EmailTemplateMappingUtility {
    
    public static Map<String, Email_Template_Mapping__mdt> getEmailTemplateMapping(String strObjectName, String strType){
        
        Email_Rule__mdt emailRule = [Select Id, Object__c, Type__c, Filters__c From Email_Rule__mdt Where Object__c =:strObjectName and Type__c =:strType]; 
        
        List<Email_Template_Mapping__mdt> EmailTemplateMappingList = [Select Id, Label, Default__c, Email_Rule__c, Email_Template__c, Email_Template_Id__c, Filter_1__c, Filter_2__c, Liner_Brand__c
                                                                      From Email_Template_Mapping__mdt Where Email_Rule__c =: emailRule.Id];
        System.debug('#### InsideEmailTemplateMappingUtility :EmailTemplateMappingList '+EmailTemplateMappingList);
        Map<String, Email_Template_Mapping__mdt> filterIdMap = new Map<String, Email_Template_Mapping__mdt>();
        
        for(Email_Template_Mapping__mdt emdt : EmailTemplateMappingList){
            String mapKey;
            if((emdt.Filter_1__c == null || emdt.Filter_1__c == '') && emdt.Filter_2__c == false)
             mapKey = emdt.Liner_Brand__c ;
            
            else if((emdt.Filter_1__c == null || emdt.Filter_1__c == '') && emdt.Filter_2__c == true)
                mapKey = emdt.Liner_Brand__c + emdt.Filter_2__c; 
                        
            else if(emdt.Liner_Brand__c != null && emdt.Filter_1__c != '')
             mapKey = emdt.Liner_Brand__c + emdt.Filter_1__c + emdt.Filter_2__c; //	#RQ-007986
           
            System.debug('##### mapKey : '+mapKey);
            
            filterIdMap.put(mapKey, emdt);
            System.debug('InsideEmailTemplateMappingUtility filterIdMap'+filterIdMap);
        }
        return filterIdMap;
    }

}