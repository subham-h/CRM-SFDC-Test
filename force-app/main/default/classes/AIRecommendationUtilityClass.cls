/*      
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0      SFSE-14324  20-03-2024     ramadevi.p@maersk.com        Utility class  for lwcRecommendation lwc component
* 2.0      SFSE-15070  30-05-2024     ramadevi.p@maersk.com        Check for the history of opportunities for same account
* 3.0      SFSE-15388  30-05-2024     ramadevi.p@maersk.com        Check for the history of opportunities for same Owner
*/
public class AIRecommendationUtilityClass {

    public static Map<ID, Recommendation_Definition__c> CheckPrerequisite(String recordId,String ObjectName){
        Map<ID, Recommendation_Definition__c> recomDefMap = new Map<ID, Recommendation_Definition__c>();
        List<Recommendation_Definition__c> recomDefList = [SELECT id, Insight__c, IsActive__c, Name, Prerequisite__c, Is_User_Action_Mandatory__c, Recommendation_Target__c, Recommended_Item__c, Recommended_Item_Reference__c, Entry_Criteria__c from Recommendation_Definition__c where Recommendation_Target__c =: ObjectName and IsActive__c = true];
        Map<String, List<Recommendation__c>> recommenationItemHistory = new Map<String,List <Recommendation__c>>();
        Boolean hasRecommDefWithPrereq = false;
        Set<String> productToRecommendSet = new Set<String>();
        Boolean openOppExists = false;

        for (Recommendation_Definition__c recomDef: recomDefList){
            if(recomDef.Prerequisite__c == 'Opportunity Prerequisite'){
                hasRecommDefWithPrereq = true;
                productToRecommendSet.add(recomDef.Recommended_Item_Reference__c);
            }
        }

        if(ObjectName == 'Opportunity' && hasRecommDefWithPrereq == true){
            Opportunity currentOpp = [select id, AccountId, ownerId from Opportunity where id =: recordId];
            Set<String> sameAccountOppIdList = new Set<String>();
            List<String> RejectionReasonToConsider = Label.Intermodal_Rejection_Reason_to_Skip.split(',');
            for(Opportunity_product__c oppProd: [select id, OpportunityId__c, OpportunityId__r.StageName, OIPC_Product_Code__c from Opportunity_product__c where OpportunityId__r.accountId =: currentOpp.AccountId and OpportunityId__r.ownerId =: currentOpp.OwnerId order by lastmodifieddate limit 100]){
                system.debug('pre opp stage name==>' + oppProd.OpportunityId__r.StageName);
                if(productToRecommendSet.contains(oppProd.OIPC_Product_Code__c) && !oppProd.OpportunityId__r.StageName.contains('Closed')){
                    openOppExists = true;
                }
                sameAccountOppIdList.add(String.valueof(oppProd.OpportunityId__c));
                //and (NOT OpportunityId__r.StageName like '%Closed%')
            }
            system.debug('openOppExists==>' + openOppExists);
            system.debug('sameAccountOppIdList==>' + sameAccountOppIdList);
            if(openOppExists == false){
                system.debug('Inside history check');
                for (Recommendation__c recom: [SELECT id, Rejection_Reason__c, Status__c, Recommendation_Item_Reference__c from Recommendation__c where Recommended_To__c in: sameAccountOppIdList and Rejection_Reason__c in: RejectionReasonToConsider and DAY_ONLY(convertTimezone(LastModifiedDate))>= LAST_90_DAYS]){
                    if(recommenationItemHistory.containsKey(recom.Recommendation_Item_Reference__c)){
                        recommenationItemHistory.get(recom.Recommendation_Item_Reference__c).add(recom);
                    } else {
                        recommenationItemHistory.put(recom.Recommendation_Item_Reference__c, new List <Recommendation__c>{
                            recom
                        });
                    }
                    system.debug('recom old==>' + recom);
                }
            }
            system.debug(' ==>recommenationItemHistory ==>' + recommenationItemHistory);
        }

        for (Recommendation_Definition__c recomDef: recomDefList){
            if(recomDef.Recommendation_Target__c == 'Opportunity' && recomDef.Prerequisite__c == 'Opportunity Prerequisite'){
                if(openOppExists == false && !(recommenationItemHistory.containsKey(recomDef.Recommended_Item_Reference__c) && recommenationItemHistory.get(recomDef.Recommended_Item_Reference__c) != NULL && recommenationItemHistory.get(recomDef.Recommended_Item_Reference__c).size()> 0)){
                    system.debug('pre check condition satisfied ==2');
                    recomDefMap.put(recomDef.id, recomDef);
                } else {

                }
            } else {
                recomDefMap.put(recomDef.id, recomDef);
            }
        }

        system.debug('recomDefMap==>' + recomDefMap);
        return recomDefMap;
    }

    public static List <Recommendation_Definition__c> getRecommendation(String recordId, String ObjectName){
        List <Opportunity> OppRec = new List <Opportunity>();
        List <Opportunity_Product__c> oppProductList = new List <Opportunity_Product__c>();
        Map <ID, Recommendation_Definition__c> recomDefMap = new Map <ID, Recommendation_Definition__c>();
        //SFSE-15388 : created a new method to check the prerequisites
        recomDefMap = AIRecommendationUtilityClass.CheckPrerequisite(recordId,ObjectName);
        //Map<ID, Recommendation_Definition__c> recomDefMap = new Map<ID, Recommendation_Definition__c>([SELECT id, Is_User_Action_Mandatory__c,Insight__c, IsActive__c, Name, Recommendation_Target__c, Recommended_Item__c, Recommended_Item_Reference__c, Entry_Criteria__c from Recommendation_Definition__c where Recommendation_Target__c =:ObjectName and IsActive__c=true]);
        //Add if condition to check if recommendation exists
        List < Recommendation_Condition__c > recomRules = [SELECT id, Object_Name__c, Field_Name__c, Condition__c, Expected_Value__c, IsActive__c, Rule_Type__c, Rule_Number__c, Number_of_Related_Records__c, Recommendation_Definition__c, Recommendation_Definition__r.Recommendation_Target__c, Recommendation_Definition__r.Entry_Criteria__c, Related_Field_Name__c, Is_Related_To_Target_Object__c from Recommendation_Condition__c where Recommendation_Definition__c in: recomDefMap.keyset() Order By Rule_Number__c asc];
        List < Recommendation_Action__c > recomActions = [SELECT id, Action__c, Action_Component__c, Action_Type__c, Recommendation_Definition__c, Rejection_Reason__c from Recommendation_Action__c where Recommendation_Definition__c in: recomDefMap.keyset()];
        Map < String, List < Recommendation_Condition__c >> objAndRules = new Map < String, List < Recommendation_Condition__c >> ();
        Map < Id, List < Recommendation_Condition__c >> recomDefAndRules = new Map < Id, List < Recommendation_Condition__c >> ();
        Map < Id, Map < String, List < Recommendation_Condition__c >>> recomDefByObjRules = new Map < Id, Map < String, List < Recommendation_Condition__c >>> ();
        Map < Integer, Boolean > ruleWithResults = new Map < Integer, Boolean > ();
        Map < Id, Boolean > recomWithResults = new Map < Id, Boolean > ();
        Map < Id, String > recomWithEntryCriteria = new Map < Id, String > ();
        List<Recommendation_Definition__c> retunRecomDef = new List<Recommendation_Definition__c>();
        Map <String, List <Recommendation_Condition__c>> objWithRuleMap = new Map <String, List <Recommendation_Condition__c>>();
        Map < String, Schema.SObjectType > gd = Schema.getGlobalDescribe();
        system.debug('recomDefMap size' + recomDefMap.size());
        for (Recommendation_Condition__c rule: recomRules) {
            if(rule.Is_Related_To_Target_Object__c){
                if (objAndRules.containsKey(rule.Object_Name__c + + ' - Child')) {
                    objAndRules.get(rule.Object_Name__c + + ' - Child').add(rule);
                } else {
                    objAndRules.put(rule.Object_Name__c + ' - Child', new List < Recommendation_Condition__c > {
                        rule
                    });
                }
            } else {
                if (objAndRules.containsKey(rule.Object_Name__c)) {
                    objAndRules.get(rule.Object_Name__c).add(rule);
                } else {
                    objAndRules.put(rule.Object_Name__c, new List < Recommendation_Condition__c > {
                        rule
                    });
                }

            }
            if (recomDefAndRules.containsKey(rule.Recommendation_Definition__c)) {
                recomDefAndRules.get(rule.Recommendation_Definition__c).add(rule);
            } else {
                recomDefAndRules.put(rule.Recommendation_Definition__c, new List < Recommendation_Condition__c > {
                    rule
                });
            }

            if (!recomWithEntryCriteria.containsKey(rule.Recommendation_Definition__c)) {
                recomWithEntryCriteria.put(rule.Recommendation_Definition__c, rule.Recommendation_Definition__r.Entry_Criteria__c);
            }

            if (recomDefByObjRules.containsKey(rule.Recommendation_Definition__c)) {
                if(rule.Is_Related_To_Target_Object__c == false){
                    if(objWithRuleMap.containsKey(rule.Object_Name__c)){
                        objWithRuleMap.get(rule.Object_Name__c).add(rule);
                    } else {
                        objWithRuleMap.put(rule.Object_Name__c, new List <Recommendation_Condition__c>{
                            rule
                        });
                    }
                    
                    if (recomDefByObjRules.get(rule.Recommendation_Definition__c).containsKey(rule.Object_Name__c)) {                    
                            recomDefByObjRules.get(rule.Recommendation_Definition__c).get(rule.Object_Name__c).add(rule);
                        //objWithRuleMap.get(rule.Object_Name__c).add(rule);
                    } else {
                        recomDefByObjRules.get(rule.Recommendation_Definition__c).put(rule.Object_Name__c, new List < Recommendation_Condition__c > {
                            rule
                        });
                        /*objWithRuleMap.put(rule.Object_Name__c, new List <Recommendation_Condition__c>{
                            rule
                        });*/
                    }
                    
                } else {
                    if(objWithRuleMap.containsKey(rule.Object_Name__c + ' - Child')){
						objWithRuleMap.get(rule.Object_Name__c + ' - Child').add(rule);
					} else {
						objWithRuleMap.put(rule.Object_Name__c + ' - Child', new List <Recommendation_Condition__c>{
							rule
						});
					}
                    
                    if(recomDefByObjRules.get(rule.Recommendation_Definition__c).containsKey(rule.Object_Name__c + ' - Child')){
                        recomDefByObjRules.get(rule.Recommendation_Definition__c).get(rule.Object_Name__c + ' - Child').add(rule);
                        //objWithRuleMap.get(rule.Object_Name__c + ' - Child').add(rule);
                    } else {
                        recomDefByObjRules.get(rule.Recommendation_Definition__c).put(rule.Object_Name__c + ' - Child', new List < Recommendation_Condition__c > {
                            rule
                        });
                    }
                }
            } else {
                Map < String, List < Recommendation_Condition__c >> tempMap = new Map < String, List < Recommendation_Condition__c >> ();
                if(rule.Is_Related_To_Target_Object__c){
                    tempMap.put(rule.Object_Name__c  + ' - Child', new List < Recommendation_Condition__c > {
                        rule
                    });  
					
                    if(objWithRuleMap.containsKey(rule.Object_Name__c + ' - Child')){
                        objWithRuleMap.get(rule.Object_Name__c + ' - Child').add(rule);
                    } else {
                        objWithRuleMap.put(rule.Object_Name__c + ' - Child', new List <Recommendation_Condition__c>{
                            rule
                        });
                    }  
                } else {
                    tempMap.put(rule.Object_Name__c, new List < Recommendation_Condition__c > {
                        rule
                    });                    
					
                    if(objWithRuleMap.containsKey(rule.Object_Name__c)){
                        objWithRuleMap.get(rule.Object_Name__c).add(rule);
                    } else {
                       objWithRuleMap.put(rule.Object_Name__c, new List <Recommendation_Condition__c>{
							rule
						}); 
                    } 
                }
                recomDefByObjRules.put(rule.Recommendation_Definition__c, tempMap);
            }            
        }
        
        //Query the record
        String targetObjQuery = 'SELECT id, ';

        for (String objectToBuild: objWithRuleMap.keyset()){ //considering there are multiple recommendations definitions for Target Obj ex:Opportunity
            String appendTargetObjQuery = BuildDynamicQuery(ObjectName, objectToBuild, objWithRuleMap.get(objectToBuild), gd, targetObjQuery);
            system.debug(appendTargetObjQuery + '==appendTargetObjQuery');
            targetObjQuery = targetObjQuery + appendTargetObjQuery + ', ';

        }

        // ', ' from query and add ObjectName  
        targetObjQuery = targetObjQuery.removeEnd(', ');
        targetObjQuery = targetObjQuery + ' from ' + ObjectName + ' where id=:recordId';
        system.debug('targetObjQuery==>'+targetObjQuery);
        List < SObject > sobjList = Database.query(targetObjQuery);
        system.debug('queried result==>'+sobjList);

        //Get the Schema Details to check for the field values dynamically        
        Map < String, SObjectField > fieldsMap = gd.get(ObjectName).getDescribe().fields.getMap();
        Map<id,Map < Integer, Boolean >> recomWithRuleResults= new Map<id,Map < Integer, Boolean >>();
        for (sObject sObj: sobjList) {
            for (Id recomDefId: recomDefByObjRules.keyset()) { //considering there are multiple recommendations definitions for Target Obj ex:Opportunity
                ruleWithResults = new Map < Integer, Boolean > ();
                for (String obj: recomDefByObjRules.get(recomDefId).keyset()) {
                    for (Recommendation_Condition__c recomRule: recomDefByObjRules.get(recomDefId).get(obj)) {
                        Boolean ruleResult = false;
                        String fieldName = recomRule.Field_Name__c.deleteWhitespace();
                        system.debug('fieldName==>' + fieldName);
                        //Resolve the conditions for Related Child Object Records
                        if (recomRule.Is_Related_To_Target_Object__c == true && recomRule.Related_Field_Name__c <> NULL) {
                            //for related objects
                            String ChildRelationName = '';
                            Schema.SObjectType ChildObjectName;
                            ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__C), false); // initially will be set as false, if teh condition satisfies then will mark as true
                            for (Schema.ChildRelationship rel: gd.get(ObjectName).getDescribe().getChildRelationships()) {
                                if (String.valueof(rel.getField()) == recomRule.Related_Field_Name__c){
                                    ChildRelationName = rel.getRelationshipName();
                                    ChildObjectName = rel.getChildSObject();
                                }
                            }
                            system.debug('ChildRelationName==>'+ChildRelationName+' ChildObjectName==> '+ChildObjectName);
                            List<sobject> childRecords = sObj.getSObjects(ChildRelationName);
                            system.debug('childRecords==>'+childRecords);
                            if(childRecords == NULL){
                                system.debug('Inside child records processing');
                                //no child records present, if the expected value = null or condition is <>, considering that child record may not be present which satisfies the condition automatically
                                if (recomRule.Number_of_Related_Records__c == 'ANY' && ((recomRule.Condition__c == '=' && recomRule.Expected_Value__c == 'null') || recomRule.Condition__c == '<>')) {
                                   ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c), true);
                                    system.debug('No records present and matching the criteria hence marking as ==>true'+Integer.Valueof(recomRule.Rule_Number__c)+'<==>'+ruleWithResults);
                                    //break;
                                } else {
                                    ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c), false);
                                    system.debug('No records present matching the criteria hence marking as false ==>'+Integer.Valueof(recomRule.Rule_Number__c)+'<==>'+ruleWithResults);
                                    //break;
                                }
                            } else {
                                //if child records present then it should satisfy the condition
                                for (sobject childRecord: childRecords) {                                
                                if (recomRule.Number_of_Related_Records__c == 'ANY') {                                    
                                    if(recomRule.Condition__c.deleteWhitespace() == 'in'){                                        
											system.debug('childRecord in any condition ==>'+childRecord);
                                            List <String> expectedValues = recomRule.Expected_Value__c.contains(',') ? recomRule.Expected_Value__c.split('\\,') : new List <String>{
                                                recomRule.Expected_Value__c
                                            };
											system.debug('expectedValues==>'+expectedValues);
											system.debug('childRecord.get(fieldName))==>'+childRecord.get(fieldName));
                                        if (expectedValues.contains(String.valueof(childRecord.get(fieldName)))) {
												system.debug('in any condition==> true');
                                            ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c), true);   
                                            break;
                                        }
                                    } else if(recomRule.Condition__c.deleteWhitespace() == '<>'){                                        
                                        Map < String, Schema.SObjectField > MapofChildField = ChildObjectName.getDescribe().fields.getMap(); 
                                        Boolean tempResult =  ResolveCondition((Object)childRecord.get(fieldName), (Object) recomRule.Expected_Value__c, MapofChildField.get(fieldName).getDescribe().getType(), recomRule.Condition__c);                                        
                                        ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c),tempResult); 
                                        if(tempResult){ //considering that one record which satisfy the condition is found hence break the loop
                                            break;
                                        }
                                    } else if (recomRule.Condition__c.deleteWhitespace() == '='){                                       
                                        Map < String, Schema.SObjectField > MapofChildField = ChildObjectName.getDescribe().fields.getMap();  
                                        Boolean tempResult =  ResolveCondition((Object)childRecord.get(fieldName), (Object) recomRule.Expected_Value__c, MapofChildField.get(fieldName).getDescribe().getType(), recomRule.Condition__c);
                                        ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c),tempResult );                                        
                                    	if(tempResult){//considering that one record which satisfy the condition is found hence break the loop
                                            break;
                                        }
                                    } 
                                    
                                } else if(recomRule.Number_of_Related_Records__c == 'All'){
                                    if(recomRule.Condition__c.deleteWhitespace() == 'in'){                                        
                                            List <String> expectedValues = recomRule.Expected_Value__c.contains(',') ? recomRule.Expected_Value__c.split('\\,') : new List <String>{
                                                recomRule.Expected_Value__c
                                            };
                                        if (expectedValues.contains(String.valueof(childRecord.get(fieldName)))) {
                                            ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c), true); 
                                        } else {
                                            break;
                                        }
                                    } else if(recomRule.Condition__c.deleteWhitespace() == '<>'){                                        
                                        Map < String, Schema.SObjectField > MapofChildField = ChildObjectName.getDescribe().fields.getMap(); 
                                        Boolean tempResult =  ResolveCondition((Object)childRecord.get(fieldName), (Object) recomRule.Expected_Value__c, MapofChildField.get(fieldName).getDescribe().getType(), recomRule.Condition__c);                                        
                                        ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c),tempResult); 
                                        if(!tempResult){ //considering that one record which does not satisfy the condition is found hence break the loop
                                            break;
                                        }
                                    } else if (recomRule.Condition__c.deleteWhitespace() == '='){                                       
                                        Map < String, Schema.SObjectField > MapofChildField = ChildObjectName.getDescribe().fields.getMap();  
                                        Boolean tempResult =  ResolveCondition((Object)childRecord.get(fieldName), (Object) recomRule.Expected_Value__c, MapofChildField.get(fieldName).getDescribe().getType(), recomRule.Condition__c);
                                        ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c),tempResult );                                        
                                    	if(!tempResult){//considering that one record which does not satisfy the condition is found hence break the loop
                                            break;
                                        }
                                    } 
                                }
                            }
                            }
                            

                        } else if (fieldName.contains('.')) {
                            Map < String, Schema.SObjectField > MapofField = gd.get(fieldName.split('\\.')[0]).getDescribe().fields.getMap();
                            if (fieldName.split('\\.').size() == 2) { //gets the Parent field ex: Opportunity Account.value_proposition__c
                                ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__C), ResolveCondition(sObj.getSobject(fieldName.split('\\.')[0]).get(fieldName.split('\\.')[1]), (Object) recomRule.Expected_Value__c, MapofField.get(fieldName.split('\\.')[1]).getDescribe().getType(), recomRule.Condition__c));
                            } else if (fieldName.split('\\.').size() == 3) { //gets the parent.parent field ex: Opportunity Account.country__c.Name
                                ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__C), ResolveCondition(sObj.getSobject(fieldName.split('\\.')[0]).getSobject(fieldName.split('\\.')[1]).get(fieldName.split('\\.')[2]), (Object) recomRule.Expected_Value__c, MapofField.get(fieldName.split('\\.')[2]).getDescribe().getType(), recomRule.Condition__c));
                            }

                        } else {
                            //Converting the expected values to Type of Target Object mentioned
                            String jsonStr = '{';
                            if (ObjectName == recomRule.Recommendation_Definition__r.Recommendation_Target__c) {
                                jsonStr = jsonStr + '"' + recomRule.Field_Name__c + '":"' + recomRule.Expected_Value__c + '",';
                            } else if (recomRule.Is_Related_To_Target_Object__c == false) {
                                jsonStr = jsonStr + '"' + recomRule.Field_Name__c + '":"' + recomRule.Expected_Value__c + '",';
                            } else {

                            }
                            jsonStr = jsonStr.removeEnd(',') + '}';
                            Type t = Type.forName(ObjectName);
                            SObject record = (SObject) JSON.deserialize(jsonStr, t);
                            system.debug('record==>' + record);
                            DescribeFieldResult fieldInfo = fieldsMap.get(fieldName).getDescribe();
                            //ResolveCondition(sObj.get(fieldName), record.get(fieldName), fieldInfo.getType(), recomRule.Condition__c);
                            ruleWithResults.put(Integer.Valueof(recomRule.Rule_Number__c), ResolveCondition(sObj.get(fieldName), record.get(fieldName), fieldInfo.getType(), recomRule.Condition__c));
                            
                        }
                    }
                recomWithRuleResults.put(recomDefId,ruleWithResults);                
                    system.debug('recomWithRuleResults==>1==>'+recomWithRuleResults);
                }
                //recomWithRuleResults.put(recomDefId, ruleWithResults);
            }
        }
		system.debug('recomWithRuleResults==>'+recomWithRuleResults);
        for (Id recomId: recomWithEntryCriteria.Keyset()) {
            String criteriaString = recomWithEntryCriteria.get(recomId).replace('( ', '(').replace(' )', ')');
            system.debug('recomWithRuleResults.get(recomId)==>'+recomWithRuleResults.get(recomId));
            for (Integer dec: recomWithRuleResults.get(recomId).Keyset()) {                
                criteriaString = criteriaString.replace(String.valueof(dec), String.valueof(recomWithRuleResults.get(recomId).get(dec))).toUppercase();
            }
            system.debug('criteriaString==>'+criteriaString);
            if(BooleanExpression.eval(criteriaString)){
                retunRecomDef.add(recomDefMap.get(recomId));
            }
            recomWithResults.put(recomId, BooleanExpression.eval(criteriaString));
        }
        return retunRecomDef;
    }

    public static String BuildDynamicQuery(String ObjectName, String queryObj, List <Recommendation_Condition__c> recomRuleConditionList, Map <String, Schema.SObjectType> gd, String currQryString){
        String targetObjQuery = '';
        String obj = '';
        Boolean hasChild = false;
        for (Recommendation_Condition__c rCondition: recomRuleConditionList) { // building query based on the Objects
            for (Schema.ChildRelationship rel: gd.get(ObjectName).getDescribe().getChildRelationships()) {                
                if (String.valueof(rel.getField()) == rCondition.Related_Field_Name__c) {
                    obj = rel.getRelationshipName();                    
                }
            }
            if(!(targetObjQuery.contains(rCondition.Field_Name__c.deleteWhitespace() + ',') || currQryString.contains(rCondition.Field_Name__c.deleteWhitespace() + ','))){
                targetObjQuery = targetObjQuery + rCondition.Field_Name__c.deleteWhitespace() + ', ';
            }
            
        }
        targetObjQuery = targetObjQuery.removeEnd(', ') + ' ';
        if (!(ObjectName == queryObj)) {
            targetObjQuery = '( SELECT id,' + targetObjQuery + 'from ' + obj + ' )';
        }
        return targetObjQuery;
    }

    public static Boolean ResolveCondition(Object actualVal, Object ExpectedVal, Schema.DisplayType fieldTypeInfo, String ruleCondition) {
        Boolean result = false;
        switch on(fieldTypeInfo) {
            when id, address, combobox, email, encryptedstring, multipicklist, phone, picklist, reference, string, textarea, url {
                //system.debug('String');
                if (ruleCondition == '=') {
                    result = String.valueof(actualVal) == String.valueof(ExpectedVal) ? true : false;
                    
                } else if (ruleCondition == 'in') {                    
                    String[] expectedValList = String.valueof(ExpectedVal).split(',');                    
                    result = expectedValList.contains(String.valueof(actualVal)) ? true : false;
                } else if (ruleCondition == '<>') {
                    result = String.valueof(actualVal) == String.valueof(ExpectedVal) ? false : true;
                }else {
                    //system.debug('String Others Test');
                }
            }
            when Boolean {
                //system.debug('Boolean');
            }
            when Date {
                //system.debug('Date');
                if (ruleCondition == '>') {
                    result = Date.valueof(actualVal) > Date.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '>=') {
                    result = Date.valueof(actualVal) >= Date.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<') {
                    result = Date.valueof(actualVal) < Date.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<=') {
                    result = Date.valueof(actualVal) <= Date.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '=') {
                    result = Date.valueof(actualVal) == Date.valueof(ExpectedVal) ? true : false;
                } else {
                    //system.debug('Date Others Test');
                }
            }
            when DateTime {
                //system.debug('DateTime');
                if (ruleCondition == '>') {                    
                    result = DateTime.valueof(actualVal) > DateTime.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '>=') {
                    result = DateTime.valueof(actualVal) >= DateTime.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<') {
                    result = DateTime.valueof(actualVal) < DateTime.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<=') {
                    result = DateTime.valueof(actualVal) <= DateTime.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '=') {
                    result = DateTime.valueof(actualVal) == DateTime.valueof(ExpectedVal) ? true : false;
                } else {
                    //system.debug('DateTime Others Test');
                }
            }

            when currency, double, percent {
                if (ruleCondition == '>') {
                    result = Double.valueof(actualVal) > Double.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '>=') {
                    result = Double.valueof(actualVal) >= Double.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<') {
                    result = Double.valueof(actualVal) < Double.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<=') {
                    result = Double.valueof(actualVal) <= Double.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '=') {
                    result = Double.valueof(actualVal) == Double.valueof(ExpectedVal) ? true : false;
                } else {
                    //system.debug('Double Others Test');
                }
            }
            when integer {
                if (ruleCondition == '>') {
                    result = Integer.valueof(actualVal) > Integer.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '>=') {
                    result = Integer.valueof(actualVal) >= Integer.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<') {
                    result = Integer.valueof(actualVal) < Integer.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '<=') {
                    result = Integer.valueof(actualVal) <= Integer.valueof(ExpectedVal) ? true : false;
                } else if (ruleCondition == '=') {
                    result = Integer.valueof(actualVal) == Integer.valueof(ExpectedVal) ? true : false;
                } else {
                    //system.debug('Integer Others Test');
                }
            }
            when long {
                //system.debug('long');
            }
        }
        system.debug('resolve condition result ===>' + result);
        return result;
    }
}