public class ApprovalHistoryUtilities {
    public static void ApprovalHistoryOLIStamping(list<Approval_History__c> lstaphRec,set<Id> opptyId, List<Opportunity> opptyMap,List<Approval_Process_Escalation_Matrix__c> matrixMap){
        Map<Id,List<String>> aphidCodeMap = New Map<Id, List<String>>();
        Map<Id, Set<Id>> optyProductMap = New Map<Id, Set<Id>>();
        Map<Id,String> optyCodeMap = New Map<Id, String>();
        Map<String,List<Id>> codeOptyProductIdMap = New Map<String, List<Id>>();
        try{
            for(Opportunity opty : opptyMap){
                optyCodeMap.put(opty.Id, opty.Products_for_Approval__c);
            }
            for(Approval_History__c ah : lstaphRec){
                for(Approval_Process_Escalation_Matrix__c apMatrix : matrixMap){
                    if(ah.Approval_Step__c == apMatrix.Id){
                        if(aphidCodeMap.containsKey(ah.Approval_Step__c)){
                            aphidCodeMap.get(ah.Approval_Step__c).addAll(apMatrix.Product_for_approval__c.split(','));
                        }else{
                            List<String> prodApprovalList = apMatrix.Product_for_approval__c.split(',');
                            aphidCodeMap.put(ah.Approval_Step__c,prodApprovalList);
                        }
                    }
                }
            }
            Map<String,Products_For_Approval__mdt> MapofProductcodenFamily = new Map<String,Products_For_Approval__mdt>();
            List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
            if(!productsForApprovalList.isEmpty()){
                for(Products_For_Approval__mdt mdtRec : productsForApprovalList){
                    if(mdtRec.Active__c == true){
                        MapofProductcodenFamily.put(mdtRec.Product_Approval_Code__c,mdtRec);
                    }
                }
            }
            List<Opportunity_Product__c> optyProductList = [select Id,Name ,Product2ID__c,Product2ID__r.OIPC_Code__c,Product2ID__r.Name,Product2ID__r.Family_Code__c,Product_Family__c,OpportunityId__r.id,
                                                            Country__r.Name,OpportunityId__r.Products_for_Approval__c from Opportunity_Product__c  
                                                            where OpportunityId__c IN : opptyId];
            for(Opportunity_Product__c prod : optyProductList){
                List<string> codeList = new List<String>();
                System.debug('Oppty Id >> '+prod.OpportunityId__c);
                if(optyCodeMap.get(prod.OpportunityId__c) != null){
                    if(optyCodeMap.get(prod.OpportunityId__c).contains(';')){
                        codeList.addAll(optyCodeMap.get(prod.OpportunityId__c).split(';'));
                    }else{
                        codeList.add(optyCodeMap.get(prod.OpportunityId__c));
                    }
                }
                
                for(String code : codeList){
                    if(code.contains('CL') && !code.contains('CCL')){
                        code = code.replace('CL','WD');
                    }
                    if(code.contains('GL')){
                        code = code.replace('GL','GH');
                    }
                    if(MapofProductcodenFamily.containsKey(code)){
                        Products_For_Approval__mdt paRec = MapofProductcodenFamily.get(code);
                        //if(prod.Product2ID__r.Name.contains(paRec.Product_Name__c) && paRec.Family_Code__c == prod.Product2ID__r.Family_Code__c ){
                        if(paRec.OIPC_Code__c != null && paRec.OIPC_Code__c == prod.Product2ID__r.OIPC_Code__c){
                            if(codeOptyProductIdMap.containsKey(code)){
                                codeOptyProductIdMap.get(code).add(prod.Id);
                            }else{
                                codeOptyProductIdMap.put(code,New List<Id>{ prod.Id});
                            }
                        }else if(paRec.Product_Name__c == prod.Product2ID__r.Name){
                            if(codeOptyProductIdMap.containsKey(code)){
                                codeOptyProductIdMap.get(code).add(prod.Id);
                            }else{
                                codeOptyProductIdMap.put(code,New List<Id>{ prod.Id});
                            }
                        }
                        //}
                    }
                }
            }
            for(Approval_History__c ah : lstaphRec){
                if(aphidCodeMap.containsKey(ah.Approval_Step__c)){
                    List<String> approvalCodeList = aphidCodeMap.get(ah.Approval_Step__c);
                    for(String str : approvalCodeList){
                        Set<String> codeList = codeOptyProductIdMap.keySet();
                        for(String code : codeList){
                            if(code.contains(str)){
                                List<Id> optyProductIds = codeOptyProductIdMap.get(code);
                                System.debug('optyProductIds >> '+optyProductIds);
                                for(Id optyProductId : optyProductIds){
                                    if(ah.Opportunity_Product__c == null){
                                        ah.Opportunity_Product__c = optyProductId;
                                    }else if(!ah.Opportunity_Product__c.contains(optyProductId)){
                                        ah.Opportunity_Product__c += ',' + optyProductId;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Approval_History__c', 'ApprovalHistoryUtilities.ApprovalHistoryOLIStamping', new list<Exception>{e});
        }
    }
    public static void ApprovalHistorySubmissionOrder(list<Approval_History__c> lstaphRec,set<Id> opptyId){
        Map<String, List<Decimal>> keyOrderListMap = New Map<String, List<Decimal>>();
        Map<String, Decimal> keyOrderMap = New Map<String, Decimal>();
        List<Approval_History__c> aphList = [SELECT Id, Name, Key__c, Step_Name__c,Status__c, TargetObjectId__c, Submission_Order__c FROM Approval_History__c WHERE  TargetObjectId__c IN : opptyId];
        try{
            for(Approval_History__c aphRec : aphList){
                String key = aphRec.TargetObjectId__c+'-'+aphRec.Step_Name__c;
                string tempkey = '';
                if(keyOrderListMap.containsKey(key)){
                    if(aphRec.Status__c != 'Reassigned'){
                        keyOrderListMap.get(key).add(aphRec.Submission_Order__c);
                    }else{
                        Decimal temporder = aphRec.Submission_Order__c - 1;
                        keyOrderListMap.put(aphRec.TargetObjectId__c+'-'+aphRec.Step_Name__c, New List<Decimal>{temporder});
                    }
                }else{
                    keyOrderListMap.put(aphRec.TargetObjectId__c+'-'+aphRec.Step_Name__c,New List<Decimal>{aphRec.Submission_Order__c});
                }
            }
            for(String key : keyOrderListMap.keySet()){
                Decimal maxValue = 0;
                for(Decimal order : keyOrderListMap.get(key)){
                    if(order > maxValue){
                        maxValue = order;
                    }
                }
                keyOrderMap.put(key, maxValue);
            } 
            for(Approval_History__c ah : lstaphRec){
                if(keyOrderMap.containsKey(ah.TargetObjectId__c+'-'+ah.Step_Name__c)){
                    Decimal OrderNum = keyOrderMap.get(ah.TargetObjectId__c+'-'+ah.Step_Name__c);
                    if(ah.Type__c == 'Escalation'){
                       ah.Submission_Order__c = OrderNum;
                    }else{
                        ah.Submission_Order__c = OrderNum + 1;
                    }
                }else{
                    ah.Submission_Order__c = 1; 
                }}
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Approval_History__c', 'ApprovalHistoryUtilities.ApprovalHistorySubmissionOrder', new list<Exception>{e});
        }
    }
}