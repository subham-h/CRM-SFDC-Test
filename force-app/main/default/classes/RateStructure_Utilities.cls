/*
* version       Date                Owner                                       Description
*******************************************************************************************************
 * 1.0      RQ-003428   19-Jul-2016     Meghana.Gupta@ust-global.com          Code created
 * 2.0      RQ-007182   10/10/2017      ramadevi.palaniswamy@ust-global.com   Rate Structure Input file ** 
 * 3.0      RQ-009022   13/08/2018      Junaid.Khader@ust-global.com          Salesforce completes related task when rate structure is approved
 * 4.0      RQ-011539   18/09/2019       Sidhartha@maersk.com                Commented Sales_Approach__c as it is dependent on Type__c 
 * 5.0      SFSE-5349   01/02/2021      Neha@TCS                             updated the addRateStructureItems() as per the user story SFSE-5351 and SFSE- 5349 to set additional fields 
 * 6.0		SFSE-6393	14-Jun-2021		Kiran@Maersk							ProjectTaskStatus update logic removed as Project_Task__c deprecation
 * 7.0      SFSE-7742	18-Feb-2022     Meghana@UST							 Hamburg Sud brand check added in method addRateStructureItems
 * 8.0      SFSE-8493   04-Aug-2022     Vazid@UST							 Alianca brand check added in method addRateStructureItems and Modified hard coded values BrandUtilities class
 * 9.0		SFSE-8951   22-Aug-2022		Vazid@UST							 Modifed code to populate Sales Approach from custom setting if value is not active from cloned RS record.
------------------------------------------------------------------------------------------------------
*/

public class RateStructure_Utilities {

    public static void addRateStructureItems ( List<Rate_Structure__c> newTriggerList ){
        
        List<Rate_Structure_Item_List__c> rsiList = [select name, Cargo_Type__c ,Charge_Name__c, Charge_Type__c, Long_Term_AFLS_Category__c, New_Code__c,
                                                        Order__c, Occurrence__c,Product_Family__c,Sales_Approach__c,Type__c, Exceptions__c ,
                                                     	Other_Charge_Type__c, Other_Surcharge_Code__c, Other_Surcharge_Name__c, Brand__c
                                                        From Rate_Structure_Item_List__c
                                                        where isActive__c = true
                                                        Order by Order__c ];
                                                    //Rate_Structure_Item_List__c.getAll().values();
        
        List<Rate_Structure_Item__c> insertRSIList = new List<Rate_Structure_Item__c>();
        List<id> sourceRateStructureIdLst = new List<id>();
        for ( Rate_Structure__c rs : newTriggerList ){     
            sourceRateStructureIdLst.add(rs.Cloned_From__c);          
        }
        // added the section to get the Previous rate structure item based on charge code to copy sales approach and comments
        Map<String,Map<String,Rate_Structure_Item__c>> rateStructureItemOfSourceDatMap = new Map<String,Map<String,Rate_Structure_Item__c>> ();
        for(Rate_Structure_Item__c rsItem: [ select id,New_Code__c,Sales_Approach__c,Sales_Comments__c,Rate_Structure__c from Rate_Structure_Item__c where Rate_Structure__c in :sourceRateStructureIdLst]){
            
            if(rateStructureItemOfSourceDatMap.containsKey(rsItem.Rate_Structure__c)){
                system.debug('IF rsItem.Rate_Structure__c>>>>'+rsItem.Rate_Structure__c);
                rateStructureItemOfSourceDatMap.get(rsItem.Rate_Structure__c).put(rsItem.New_Code__c, rsItem);
            }else{
                system.debug('ELSE rsItem.Rate_Structure__c>>>>'+rsItem.Rate_Structure__c);
                rateStructureItemOfSourceDatMap.put(rsItem.Rate_Structure__c, new Map<String,Rate_Structure_Item__c> {rsItem.New_Code__c => rsItem});
            }           
        }
        system.debug('rateStructureItemOfSourceDatMap>>>>'+JSON.serialize(rateStructureItemOfSourceDatMap));
              
        
        for ( Rate_Structure__c rs : newTriggerList ){
           system.debug('$$$ rs brand :' + rs.Brand__c);
            
            for ( Rate_Structure_Item_List__c rsiRec : rsiList ){
                       system.debug('$$$ rsiRec.Brand__c :' + rsiRec.Brand__c);
				//SFSE-8493
                if (((rs.Brand__c == BrandUtilities.HAMBURGSUD && rsiRec.Brand__c == rs.Brand__c) || (rs.Brand__c == BrandUtilities.ALIANCA && rsiRec.Brand__c == BrandUtilities.HAMBURGSUD)) || ((rs.Brand__c != BrandUtilities.HAMBURGSUD && rs.Brand__c != BrandUtilities.ALIANCA) && String.isEmpty(rsiRec.Brand__c))){
                                           system.debug('$$$ ifff');

                
                    Rate_Structure_Item__c newRec = new Rate_Structure_Item__c();
                    newRec.Rate_Structure__c = rs.id;
                    newRec.Charge_Name__c = rsiRec.Charge_Name__c ;
                    newRec.New_Code__c = rsiRec.New_Code__c ;
                    newRec.Long_term_AFLS_Category__c = rsiRec.Long_Term_AFLS_Category__c ;
                    newRec.Type__c = rsiRec.Type__c;
                    newRec.Exceptions__c = rsiRec.Exceptions__c;
                    newRec.Cargo_Type__c = rsiRec.Cargo_Type__c;
                    newRec.Charge_Type__c = rsiRec.Charge_Type__c;
                    newRec.Occurrence__c = rsiRec.Occurrence__c;
                    newRec.Product_Family__c = rsiRec.Product_Family__c;
                    newRec.Other_Charge_Type__c = rsiRec.Other_Charge_Type__c;
                    newRec.Other_Surcharge_Code__c = rsiRec.Other_Surcharge_Code__c;
                    newRec.Other_Surcharge_Name__c = rsiRec.Other_Surcharge_Name__c;
                    
                    
                    if(String.isNotEmpty(rs.Cloned_From__c)){
                        Rate_Structure_Item__c tempRateStructureItem = new Rate_Structure_Item__c();                    
                        tempRateStructureItem = rateStructureItemOfSourceDatMap.get(rs.Cloned_From__c).get(rsiRec.New_Code__c);
                        system.debug('tempRateStructureItem>>>>'+JSON.serializepretty(tempRateStructureItem));
                        if(tempRateStructureItem!=null){
							//SFSE-8951                          
                            if(getPicklistValues().contains(tempRateStructureItem.Sales_Approach__c)){
                            newRec.Sales_Approach__c = tempRateStructureItem.Sales_Approach__c;
                            }else if(rsiRec.Sales_Approach__c != null){
                                newRec.Sales_Approach__c = rsiRec.Sales_Approach__c;
                            }
                            newRec.Sales_Comments__c = tempRateStructureItem.Sales_Comments__c;
                        }else{
                            SYstem.debug('RS Record not available :::::'+rsiRec.New_Code__c);
                        }
                        
                    }
                	insertRSIList.add( newRec );
                }
            }
            
        }
        
        Database.SaveResult[] saveResultList = database.insert( insertRSIList, false );
        for (Database.SaveResult sr : saveResultList) {
            if (!sr.isSuccess()) {
                System.debug('Successfully inserted RSI. RSI ID: ' + sr);
            }
            else {             
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('RSIt affected this error: ' + err.getFields());
                }
            }
        }
    }
    //SFSE-8951
    public static set<string> getPicklistValues() {
        List<Schema.PicklistEntry> values = Rate_Structure_Item__c.Sales_Approach__c.getDescribe().getPickListValues();
        set<string> activeEntries = new set<string>();
        for (Schema.PicklistEntry val:values) {
            if (val.isActive()) {
                activeEntries.add(val.getvalue());
            }
        }
        return activeEntries;
    }
}