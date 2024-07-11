/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11961  18-08-2023     Seba,Bharti and Vinay     Created.
* 2.0     SFSE-13491  14-dec-2023     Bharti                  Remove hardcoding of Portfolio owner Responsibility
* */
public class CreditEligibilityUtility {
    
    public class AccountTAAWrapper{
        public String portfolio {get;set;}
        public Id BDAId {get;set;}
        public Id geographyId {get;set;}        
        public String brand {get;set;}
        public AccountTAAWrapper(String responsibility, Id BDA_Id, Id countryId, String brand){
            this.portfolio = responsibility;
            this.BDAId = BDA_Id;
            this.geographyId = countryId;            
            this.brand = brand;
        }
    }
    
    public class EligibilityWrapper{
        public Boolean poCreditEligible {get;set;}
        public Boolean shipperCreditEligible {get;set;}
        public Boolean consigneeCreditEligible {get;set;}
        
        public EligibilityWrapper(Boolean po, Boolean ship, Boolean consignee){
            this.poCreditEligible = po;
            this.shipperCreditEligible = ship;
            this.consigneeCreditEligible = consignee;  
        }
    }
    
    public static Map<String, List<CreditEligibilityUtility.AccountTAAWrapper>> getPortfolioOwnershipData(Set<String> setAllAccountCodes) {
        Map<String, List<CreditEligibilityUtility.AccountTAAWrapper>> mapAccountTAARecords = new Map<String, List<CreditEligibilityUtility.AccountTAAWrapper>>();
        if(!setAllAccountCodes.isEmpty()){
            list<Territory_Account_Association__c> listTAA =[SELECT Id,Account__r.Customer_Code__c,Customer_Status__c,Product_Responsibility__c,Start_Date__c,End_Date__c FROM Territory_Account_Association__c WHERE Account__r.Customer_Code__c IN : setAllAccountCodes];
           
            
            for(Territory_Account_Association__c TAA : [SELECT Id,Account__r.Customer_Code__c,Portfolio_Owner_Responsibility__c,Country__c,
                                                        Business_Defined_Area__c, Brand__c FROM Territory_Account_Association__c 
                                                        WHERE Account__r.Customer_Code__c IN : setAllAccountCodes AND 
                                                        Customer_Status__c='Active' AND Product_Responsibility__c != :TAASettingConstants.PR_Ocean
                                                        AND Start_Date__c <= TODAY  AND (End_Date__c = null OR End_Date__c >= TODAY)]){
                if(mapAccountTAARecords.containsKey(TAA.Account__r.Customer_Code__c)){
                    mapAccountTAARecords.get(TAA.Account__r.Customer_Code__c).add(new CreditEligibilityUtility.AccountTAAWrapper(TAA.Portfolio_Owner_Responsibility__c, TAA.Business_Defined_Area__c, TAA.Country__c, TAA.Brand__c)); 
                } else{
                    mapAccountTAARecords.put(TAA.Account__r.Customer_Code__c, new List<CreditEligibilityUtility.AccountTAAWrapper>{new CreditEligibilityUtility.AccountTAAWrapper(TAA.Portfolio_Owner_Responsibility__c, TAA.Business_Defined_Area__c, TAA.Country__c, TAA.Brand__c)}); 
                }
            }
        }
        
        return mapAccountTAARecords;
    }
}