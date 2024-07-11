/*
* Author    : Nayana
* Purpose   : Controller class to show CX Package on Case and Account. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9354     04-Dec-2023 Nayana@Maersk            Created as part of Static service package implementation.
*            
*/

/**
* 
* @author Nayana@Maersk
* @description Controller class to show CX package 
*/
public class CaseServiceOfferingsController {    
/** 
* @description | Get the Contract line items wrapper list|
* @param recId accepts recordid
* @param sobjectName accepts objectname
* @return list of ContractLineItemWrapper
*/	
    @AuraEnabled(cacheable=true)
    public static List<ContractLineItemWrapper> getContractLineItemsWrapper(Id recId, String sobjectName) {        
        List<Contract_Line_Item__c> listContractLineItems = new List<Contract_Line_Item__c>();
        List<ContractLineItemWrapper> conLineItemWrapList = new List<ContractLineItemWrapper>();
        Map<String, ContractLineItemWrapper> conLineWrapMap = new Map<String, ContractLineItemWrapper>();
        Id packageAccountId = null;
        //Check if there are any service contract directly
        packageAccountId = getPackageAccountId(recId,sobjectName);
        //Form the contractlineitems wrapper using the AccountId
        if(packageAccountId != null){
            listContractLineItems = [Select Id,Name,Feature_Name__c,Specification_Parameter__c,Specification_Option_Name__c,Specification_Parameter_Name__c,Specification_Parameter__r.Name,
                                     Specification_Option__c,Specification_Option__r.Name,Specification_Option__r.Description__c,Standard_package__c 
                                     from Contract_Line_Item__c where Service_Contract__r.AccountId =:packageAccountId ORDER BY Name, Feature_Name__c, Specification_Parameter_Name__c];
        }
        
        if(!listContractLineItems.isEmpty()){
            Map<String, List<String>> featureNameToSpecParamMap = new Map<String, List<String>>();
            Map<String, List<Contract_Line_Item__c>> specsParamToConLineMap = new Map<String, List<Contract_Line_Item__c>>();
            Map<String, List<Contract_Line_Item__c>> featureNameSpecsParamToConLineMap = new Map<String, List<Contract_Line_Item__c>>();
            for(Contract_Line_Item__c con : listContractLineItems){  
                //Get Specification paramters to contract line items map
                if(specsParamToConLineMap.isEmpty() || !specsParamToConLineMap.containsKey(con.Specification_Parameter_Name__c)){
                    specsParamToConLineMap.put(con.Specification_Parameter_Name__c, new List<Contract_Line_Item__c>{con});
                }
                else{
                    specsParamToConLineMap.get(con.Specification_Parameter_Name__c).add(con);
                }
                //Get Feature to List of Specification Paramters map
                if(featureNameToSpecParamMap.isEmpty() || !featureNameToSpecParamMap.containsKey(con.Feature_Name__c)){
                    featureNameToSpecParamMap.put(con.Feature_Name__c, new List<String>{con.Specification_Parameter_Name__c});
                }
                else{
                    featureNameToSpecParamMap.get(con.Feature_Name__c).add(con.Specification_Parameter_Name__c);
                }
                //Get Feature+Specification paramters to List of CLI map
                if(featureNameSpecsParamToConLineMap.isEmpty() || !featureNameSpecsParamToConLineMap.containsKey(con.Feature_Name__c+';'+con.Specification_Parameter_Name__c)){
                    featureNameSpecsParamToConLineMap.put(con.Feature_Name__c+';'+con.Specification_Parameter_Name__c, new List<Contract_Line_Item__c>{con});
                }
                else{
                    featureNameSpecsParamToConLineMap.get(con.Feature_Name__c+';'+con.Specification_Parameter_Name__c).add(con);
                }
            }
            
            for(String featureName : featureNameToSpecParamMap.keySet()){
                for(String specsParam : featureNameToSpecParamMap.get(featureName)){
                    for(Contract_Line_Item__c con : specsParamToConLineMap.get(specsParam)){
                        if(!conLineWrapMap.containsKey(con.Feature_Name__c +';'+ con.Specification_Parameter_Name__c +';'+ con.Name) && 
                           con.Feature_Name__c==featureName){
                            ContractLineItemWrapper conLineWrap = new ContractLineItemWrapper();
                            conLineWrap.conLineItemId = con.Id;
                            conLineWrap.conLineItemName = con.Name;
                            conLineWrap.featureName = con.Feature_Name__c;
                            conLineWrap.specificationParamId = con.Specification_Parameter__c;
                            conLineWrap.specificationParamName = con.Specification_Parameter_Name__c;
                            conLineWrap.specificationOptionId = con.Specification_Option__c;
                            conLineWrap.specificationOptionName = con.Specification_Option_Name__c;
                            conLineWrap.specificationOptionDesc = con.Specification_Option__r.Description__c;                            
                            conLineWrap.featureRowspan = featureNameToSpecParamMap.get(featureName).size();
                            conLineWrap.specificationParamRowspan = featureNameSpecsParamToConLineMap.get(featureName+';'+specsParam).size();
                            conLineWrapMap.put(con.Feature_Name__c +';'+ con.Specification_Parameter_Name__c +';'+ con.Name, conLineWrap); 
                        }
                    }
                }
            }
            /*for(ContractLineItemWrapper conwrap : conLineWrapMap.values()){
                system.debug('****conwrap-->'+conwrap+'\n');
            }*/
            
            String oldFeatureName = '';
            String oldSpecParam = '';
            for(String key : conLineWrapMap.keyset()){
                //system.debug('key++'+key);
                List<String> strList = key.split(';');
                //system.debug('strList++'+strList);
                ContractLineItemWrapper con = new ContractLineItemWrapper();
                if(oldFeatureName != strList[0]){
                    con.featureName = strList[0];
                    con.specificationParamName = strList[1];
                    oldSpecParam = strList[1];
                    oldFeatureName = strList[0];
                    con.specificationParamId = conLineWrapMap.get(key).specificationParamId;
                    con.featureRowspan = conLineWrapMap.get(key).featureRowspan;
                    con.specificationParamRowspan = conLineWrapMap.get(key).specificationParamRowspan;
                }
                else{
                    con.featureName = null;
                    con.featureRowspan = null;
                    if(strList[1] == oldSpecParam){
                        con.specificationParamName = null;
                        con.specificationParamRowspan = null;
                    }
                    else{
                        oldSpecParam = strList[1];
                        con.specificationParamName = strList[1];
                        con.specificationParamId = conLineWrapMap.get(key).specificationParamId;
                        con.specificationParamRowspan = conLineWrapMap.get(key).specificationParamRowspan;
                    }
                }
                con.conLineItemName = conLineWrapMap.get(key).conLineItemName;
                con.conLineItemId = conLineWrapMap.get(key).conLineItemId;
                con.specificationOptionId = conLineWrapMap.get(key).specificationOptionId;
                con.specificationOptionName = conLineWrapMap.get(key).specificationOptionName;
                con.specificationOptionDesc = conLineWrapMap.get(key).specificationOptionDesc;
                conLineItemWrapList.add(con);
            }
            
            /*for(ContractLineItemWrapper con : conLineItemWrapList){
                system.debug('****con-->'+con+'\n');
            }*/
        }
        return conLineItemWrapList;
    }
/** 
* @description | Get the applicable accountId to get the relevant contract line items|
* @param recId accepts recordid
* @param sobjectName accepts objectname
* @return AccountId
*/    
    @AuraEnabled(cacheable=true)
    public static String getPackageAccountId(Id recId, String sobjectName) {
        List<Case> currentCase = new List<Case>();
        List<Account> currentAccount = new List<Account>();
        List<ServiceContract> listServiceContract = new List<ServiceContract>();
        string packageAccountId = null;
        String accountId = null;
        String onbehalfProducts = null;
        onbehalfProducts = General_Key_Value_Configurations__mdt.getInstance('Service_Package_OnBehalf_Products').First_Field_Value__c;
        if(sobjectName!=null && recId!=null && sobjectName=='Case'){
            //Get Account id or Concern Account Id or On behalf account Id
            currentCase = [SELECT AccountId,Account.ParentId,On_Behalf_Account__c,On_Behalf_Account__r.Parentid,Product__c FROM Case WHERE Id =: recId limit 1];
            //Get Service Contract for the account, if present no need to check parent account
            if(!currentCase.isEmpty() && onbehalfProducts.containsignorecase(currentCase[0].Product__c) && currentCase[0].On_Behalf_Account__c!=null){  
                accountId = currentCase[0].On_Behalf_Account__c;
            }
            else{
                accountId = currentCase[0].AccountId;
            }
            if(accountId!=null){
                listServiceContract = [select id,AccountId from ServiceContract where AccountId=:accountId];
                if(!listServiceContract.isEmpty()){
                    packageAccountId = accountId;
                }
            }
            
            //If there is no Service contract for the account then enter Parent logic
            if(packageAccountId==null){
                //If product is SCM consider package from On behalf account
                if(!currentCase.isEmpty() && onbehalfProducts.containsignorecase(currentCase[0].Product__c) && currentCase[0].On_Behalf_Account__c!=null){
                    if(currentCase[0].On_Behalf_Account__r.Parentid!=null){
                        packageAccountId = currentCase[0].On_Behalf_Account__r.Parentid;
                    }
                    else{
                        packageAccountId = currentCase[0].On_Behalf_Account__c;
                    }                
                }
                //If Account has Concern Account then consider the Concern accountid
                else if(!currentCase.isEmpty() && currentCase[0].Account.ParentId!=null){
                    packageAccountId = currentCase[0].Account.ParentId;
                }
                //If no Concern account then consider the AccountId
                else if(!currentCase.isEmpty() && currentCase[0].AccountId!=null){
                    packageAccountId = currentCase[0].AccountId;
                }             
            }
        }
            //If object is Account            
            if(sobjectName!=null && recId!=null && sobjectName=='Account'){
                //Get Service Contract for the account, if present no need to check parent account
                listServiceContract = [select id,AccountId from ServiceContract where AccountId=:recId];
                if(!listServiceContract.isEmpty()){
                    packageAccountId = recId;
                }
                //If there is no Service contract for the account then enter Parent logic
                if(packageAccountId==null){
                    currentAccount = [SELECT Id,ParentId FROM Account WHERE Id =: recId limit 1];
                    if(!currentAccount.isEmpty() && currentAccount[0].ParentId!=null){
                        packageAccountId = currentAccount[0].ParentId;
                    }
                    else{
                        packageAccountId = currentAccount[0].Id;
                    }      
                }
            }      
        
        return packageAccountId;
    }

/**
* 
* @author Nayana.k@Maersk
* @description Inner class to store Contract line item details
*/    
    public class ContractLineItemWrapper{
        @AuraEnabled
        public String conLineItemId;
        @AuraEnabled
        public String conLineItemName;
        @AuraEnabled
        public String featureName;
        @AuraEnabled
        public String specificationParamId;
        @AuraEnabled
        public String specificationParamName;
        @AuraEnabled
        public String specificationOptionId;
        @AuraEnabled
        public String specificationOptionName;
        @AuraEnabled
        public String specificationOptionDesc;
        @AuraEnabled
        public Integer featureRowspan;
        @AuraEnabled
        public Integer specificationParamRowspan;        
    }
}