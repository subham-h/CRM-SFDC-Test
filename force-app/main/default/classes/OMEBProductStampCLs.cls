/*              
* Revision Ref Number       Owner                   Description
* -------- ----------  -----------------       -----------
* 1.0      SFSE-10929    Rama@maersk           Code created for OliId stamping on Approval History records 
*/

public class OMEBProductStampCLs {
    
    
    public Static String getProductInfo(String productForApproval,String opptyId,Approval_Process_Escalation_Matrix__c appmtrxRec){
        
        String productStamp;
        Map<Id,String> mapofmatrixNProduct = new Map<Id,String>();
        Map<String,String> mapProdApprovalMD = new Map<String, String>();
        Map<String,set<String>> mapofProductNOlis = new Map<String,set<String>>();//map of all ProductNames and associated set of Ids
        Map<String,Products_For_Approval__mdt> MapofProductcodenFamily = new Map<String,Products_For_Approval__mdt>();
        List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
        
        for(Products_For_Approval__mdt mdtRec : productsForApprovalList){
            MapofProductcodenFamily.put(mdtRec.Product_Approval_Code__c,mdtRec);
        }
        
        
        String ProductCode;
        Boolean isProduct;
        for(String str:appmtrxRec.Product_for_approval__c.split(',')){
            for(String prodstr : productForApproval.split(';')){
                if(prodstr.contains(str)){
                    isProduct = true;
                    ProductCode = prodstr;
                    break;        
                } 
                else{
                    isProduct=false;
                } 
            }  
        }
        
        System.debug('ProductCode'+ProductCode);
        String COuntryId = appmtrxRec.Country__c;
        String COuntryName = appmtrxRec.Country__r.Name;
        System.debug('COuntryId'+COuntryId+'--'+COuntryName);
        List<Opportunity_Product__c> olilist = new List<Opportunity_Product__c>();
        if(ProductCode.contains('CS') || ProductCode.contains('WD')){
            olilist =[select Id,Name ,Product2ID__c,Product2ID__r.OIPC_Code__c,Product2ID__r.Name,Product2ID__r.Family_Code__c,Product_Family__c,OpportunityId__r.id,
                      Country__r.Name,OpportunityId__r.Products_for_Approval__c from Opportunity_Product__c  
                      where OpportunityId__r.id =:opptyId and Country__c =:COuntryId and Product2ID__r.Family_Code__c =:MapofProductcodenFamily.get(ProductCode).Family_Code__c];
        }else{
            olilist =[select Id,Name ,Product2ID__c,Product2ID__r.Name,Product2ID__r.OIPC_Code__c,Product2ID__r.Family_Code__c,Product_Family__c,OpportunityId__r.id,
                      Country__r.Name,OpportunityId__r.Products_for_Approval__c from Opportunity_Product__c  
                      where OpportunityId__r.id =:opptyId and OpportunityId__r.Opportunity_Owner_Country__c =:COuntryName and Product2ID__r.Family_Code__c =:MapofProductcodenFamily.get(ProductCode).Family_Code__c and Product2ID__r.OIPC_Code__c =:MapofProductcodenFamily.get(ProductCode).OIPC_Code__c];
        }
        
        System.debug('olilist'+olilist);
        
        for(Opportunity_Product__c oliRec : olilist){
            if(!String.isBlank(productStamp)){
                productStamp += ';'+oliRec.Id;
            }else{
                productStamp = oliRec.Id;
            }
        }
        System.debug('productStamp'+productStamp);
        return productStamp;
        
        
    }
    
    
}