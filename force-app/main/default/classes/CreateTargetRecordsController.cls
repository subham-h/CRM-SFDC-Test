/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-12879  13-Oct-2023       Vinay               Controller for lwcCreateTargetRecords LWC component  
* 1.1	   SFSE-13384  22-Nov-2023		 Vinay				 Code added to create Measure when Missing.	
* 1.2	   SFSE-13783  12-Jan-2023	 	 Vinay				 Fixing the production issue to Evaluate Credit eligibility for New Client Business with ACC AND When only Measure is Creating	
*/ 
public class CreateTargetRecordsController {
    
    @AuraEnabled
    public static String createRecords(Target_Item_Group__c grp, Target_Item__c item, Target_Measure__c measure, String targetId){
        String returnStatus ='';
		Map<String, Boolean> accCredMap = new  Map<String, Boolean>();        
        Savepoint sp = Database.setSavepoint();
        try{            
            List<Target_Item_Group__c> targetGroupList = [SELECT Id,BrandMnA__c,Executing_Country__r.GEO_Code__c FROM Target_Item_Group__c WHERE Product_Family__c =: grp.Product_Family__c
                                                          AND Executing_Country__c=: grp.Executing_Country__c
                                                          AND BrandMnA__c=: grp.BrandMnA__c AND Target__c=: targetId];              
            
            // If their is a Target Item Group with User Provided Country, Brand and PF for the Selected Target
            if(targetGroupList.size()>0){                
            	List<Target_Item__c> itemsList =[SELECT Id,Sales_Target_Item_Group__c,Account__c,Account_Customer_Code__c,Brand__c,Sales_Target_Item_Group__r.Executing_Country__r.GEO_Code__c FROM Target_Item__c 
                                                 WHERE Sales_Target_Item_Group__c=:targetGroupList[0].Id 
                                                 AND Account__c=: item.Account__c];
                if(itemsList.size()>0){
                   List<Target_Measure__c> listMeasures = [SELECT Id, Party_Type__c FROM Target_Measure__c 
                                                           WHERE Target_Item__c=: itemsList[0].Id AND Party_Type__c =:measure.Party_Type__c 
                                                           AND Measure_Type__c=: measure.Measure_Type__c 
                                                           AND Measure_Dimension__c=: measure.Measure_Dimension__c];
                    if(listMeasures.size()==0){
                        measure.Target_Item__c = itemsList[0].Id;
                        // SFSE-13783 - Evaluating Credit Eligibility When Measure need to be created.
                        if(itemsList[0].Account__c!=NULL){
                           accCredMap = SalesCreditEligibilityHelper.getCreditEligibilityByPartyType(
                						new Map<String, String>{itemsList[0].Account_Customer_Code__c=> itemsList[0].Sales_Target_Item_Group__r.Executing_Country__r.GEO_Code__c}, 
                						new Map<String, String> {itemsList[0].Account_Customer_Code__c => itemsList[0].Brand__c}, measure.Party_Type__c); 
                            
            			   measure.Credit_Eligible__c = accCredMap.containsKey(itemsList[0].Account_Customer_Code__c)?accCredMap.get(itemsList[0].Account_Customer_Code__c):FALSE; 
                        }
        				insert measure;
                        returnStatus =label.Records_Created_Successfully;
                    }
                    else
                       returnStatus= label.Target_Item_exist; 
                }
                else{
                    createItemAndMeasure(item, measure, targetGroupList[0]);
                    returnStatus =label.Records_Created_Successfully;
                }
            }
            else{
                // If their is a Budget Group with user provided PF, COUNTRY and Brand, then Create Target Item Group,Item and Measure.               
                List<Budget_Group__c> budgetGroupList = [SELECT Id FROM Budget_Group__c WHERE Product_Family__c =: grp.Product_Family__c
                                                         AND Executing_Country__c=: grp.Executing_Country__c
                                                         AND Brand__c=: grp.BrandMnA__c AND Target__c=: targetId];
                if(budgetGroupList.size()>0){
                    grp.Target__c = targetId;            
                    insert grp;
                    List<Target_Item_Group__c> lstTIG = [SELECT Id,BrandMnA__c,Country_Code__c,Executing_Country__r.GEO_Code__c FROM Target_Item_Group__c WHERE Id =: grp.Id];
                    createItemAndMeasure(item, measure, lstTIG[0]);
                    returnStatus =label.Records_Created_Successfully;
                }
                // If their is no Budget Group with user provided PF, COUNTRY and Brand Show Error to User.               
                else{
                    returnStatus =label.No_Budget_Found;
                }
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        } 
        return returnStatus;
    }
    
    private static void createItemAndMeasure(Target_Item__c item, Target_Measure__c measure, Target_Item_Group__c grp){
                
        item.Sales_Target_Item_Group__c = grp.Id;
        insert item;
        
        // SFSE-13783 - Removed New Client Business Check.
        if(item.Account__c!=NULL){              
            Map<String, Boolean> accCredMap = new  Map<String, Boolean>();     
            String accCustomerCode = [SELECT Id,Customer_Code__c FROM Account WHERE Id =:item.Account__c LIMIT 1]?.Customer_Code__c; 
            accCredMap = SalesCreditEligibilityHelper.getCreditEligibilityByPartyType(
                new Map<String, String>{accCustomerCode=> grp.Executing_Country__r.GEO_Code__c}, 
                new Map<String, String> {accCustomerCode => grp.BrandMnA__c}, 
                measure.Party_Type__c);                          
            measure.Credit_Eligible__c = accCredMap.containsKey(accCustomerCode)?accCredMap.get(accCustomerCode):FALSE;             
        }
        
        measure.Target_Item__c = item.Id;
        insert measure;
    }
}