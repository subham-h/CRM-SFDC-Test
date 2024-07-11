/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11961  18-08-2023     Seba,Bharti and Vinay     Created.                                       
* 2.0 	   SFSE-13107  31-10-2023     Vinay					    Mapping the Lns Brand with SalesForce Brand. 
* */
public class AssessCreditEligibility {
    
    private Map<string, Sales_Credit_Eligibility_Check__mdt> mapCustomMetaData { private get; private set; }
    private Map<String, String> mapPOConcers{ private get; private set; }
    private Map<Id, List<String>> mapBDAs { private get; private set; }
    private Map<String, List<CreditEligibilityUtility.AccountTAAWrapper>> mapAccountTAARecords { private get; private set; }
    private Map<String,String> brandMapping{private get; private set; }
    
    public Map<Id, CreditEligibilityUtility.EligibilityWrapper> determineAccountEligibility(List<Target_Setting_Staging__c>  listStagingRecords){
        
        Map<Id, CreditEligibilityUtility.EligibilityWrapper> mapAccountCreditEligibility = new Map<Id, CreditEligibilityUtility.EligibilityWrapper>();        
        Map<String, String> mapPOAccountType = new Map<String, String>();        
        Map<String, String> mapPOParentIds = new Map<String, String>();
        Set<String> setPoAccountCodes = new Set<String>();
        Set<String> setAllAccountCodes = new Set<String>();
        Set<String> setPOParentIds = new Set<String>();
        String strAccountType = null;
        	
        String representsConcernAcc = system.label.AccountType_ClientAccountandRepresentsConcern;
        String clientAcc = system.label.AccountType_ClientAccount;
        String normalClientAcc = system.label.AccountType_NormalClientAccountofConcern; 
        
        String priceOwner = system.label.PartyType_PriceOwner;
        String shipper = system.label.PartyType_Shipper;
        String consignee = system.label.PartyType_Consignee;
        
        
        mapCustomMetaData = new Map<string, Sales_Credit_Eligibility_Check__mdt>();
        mapPOConcers = new Map<String, String>();
        mapBDAs = new Map<Id, List<String>>();
        
        brandMapping = TargetSettingBatchHelper.targetBrandMappingMethod();
        
        
        for(Target_Setting_Staging__c stg:listStagingRecords){
            if(stg.Price_Owner__c!=NULL){
                setPoAccountCodes.add(stg.Price_Owner__c);
                setAllAccountCodes.add(stg.Price_Owner__c);                
            }
            if(stg.Consignee__c!=NULL){
                setAllAccountCodes.add(stg.Consignee__c);}            	
            if(stg.Shipper__c!=NULL){
                setAllAccountCodes.add(stg.Shipper__c);                
            }
        }
        
        // Iterate over price Owners and determine whether it is Client Acc or Concern Acc or Normal Client Acc of Concern and Map it.
        if(!setPoAccountCodes.isEmpty()){
            Id clientAccRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
            for(Account Acc: [SELECT Id,Customer_Code__c,ParentId,Represents_Concern__c FROM Account WHERE Customer_Code__c IN: setPoAccountCodes AND RecordTypeId=:clientAccRecordTypeId AND SCV_Status__c='Active']){
                if(Acc.Represents_Concern__c){
                    mapPOAccountType.put(Acc.Customer_Code__c, representsConcernAcc); 
                }
                else if(!Acc.Represents_Concern__c && Acc.ParentId!=NULL){
                    mapPOAccountType.put(Acc.Customer_Code__c, normalClientAcc);
                    setPOParentIds.add(Acc.ParentId); 
                    mapPOParentIds.put(Acc.Customer_Code__c, Acc.ParentId);
                }
                else
                    mapPOAccountType.put(Acc.Customer_Code__c, clientAcc);  
            }
        }
        
        // Get Normal Client Account's Concern's Data and Mapping.
        if(!setPOParentIds.isEmpty()){
            for(Account ACC:[SELECT Id,ParentId,Customer_Code__c FROM Account WHERE ParentId IN:setPOParentIds AND Represents_Concern__c=True]){
                setAllAccountCodes.add(ACC.Customer_Code__c); 
                mapPOConcers.put(Acc.ParentId, ACC.Customer_Code__c); 
            }
        }
        
        //for all the PO, Shipper, Consignee Account Codes get corresponding Territory Account Association Records
        mapAccountTAARecords = CreditEligibilityUtility.getPortfolioOwnershipData(setAllAccountCodes);
        
        // Getting the BDA Records.        
        for(BDA_Geography__c BDA: [SELECT Id, BDA__C, Geography__r.GEO_Code__c FROM BDA_Geography__c WHERE BDA__r.Type__C='Cluster' AND BDA__r.Active__c=TRUE AND  BDA__r.Parent_BDA__c!=NULL]){
            if(mapBDAs.containsKey(BDA.BDA__C)){
                mapBDAs.get(BDA.BDA__C).add(BDA.Geography__r.GEO_Code__c);  
            }
            else{
                mapBDAs.put(BDA.BDA__C, new List<String>{BDA.Geography__r.GEO_Code__c});   
            }
        }
        
        // Getting the Metadata where the portfolios are mapped against Party Type and Customer Type. 
        for(Sales_Credit_Eligibility_Check__mdt mdt : Sales_Credit_Eligibility_Check__mdt.getAll().values()){
            mapCustomMetaData.put(mdt.Customer_Type__c+'-'+mdt.Party_Type__c, mdt); 
        }
        
        
        // Credit Eligibility logic Starts        
        String parentId, poConcernCode;
        //CreditEligibilityUtility.EligibilityWrapper Wrap;
        
        CreditEligibilityUtility.EligibilityWrapper wrap;
        
        for(Target_Setting_Staging__c stg:listStagingRecords){
            parentId='';
            poConcernCode='';
            wrap = new CreditEligibilityUtility.EligibilityWrapper(FALSE,FALSE,FALSE);
            
            // Code Starts for Price Owner and Shipper and Consignee are Same.
            if(stg.Price_Owner__c==stg.Consignee__c && stg.Price_Owner__c==stg.Shipper__c){
                // When PO is Normal Client Account of Concern 
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==normalClientAcc){
                    
                    parentId = mapPOParentIds.get(stg.Price_Owner__c);
                    poConcernCode  = parentId!=NULL? mapPOConcers.get(parentId):NULL;
                    
                  mapAccountCreditEligibility.put(stg.Id,validatePoAndShipper(normalClientAcc,TRUE,poConcernCode,stg,wrap,TRUE,TRUE));
                } // Ends When Po is Normal Client ACC.
                
                // When PO is Client Account and Represents Concern
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==representsConcernAcc){
                    mapAccountCreditEligibility.put(stg.Id,validatePoAndShipper(representsConcernAcc,FALSE,stg.Price_Owner__c,stg,wrap,FALSE,TRUE));
                    
                }  // End of PO is Client Account and Represents Concern 
                
                // When PO is Client Account
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==clientAcc){
                    
                    mapAccountCreditEligibility.put(stg.Id,validatePoAndShipper(clientAcc,FALSE,stg.Price_Owner__c,stg,wrap,FALSE,TRUE));
                    
                }// End of PO is Client ACcount                                
                
            }// Code Ends for Price Owner and Shipper and Consignee are Same
            
            
            
            //When PO, Shipper and Consignee all are different in a transaction record 
            if(stg.Price_Owner__c != stg.Shipper__c && stg.Price_Owner__c != stg.Consignee__c && stg.Shipper__c != stg.Consignee__c){
                
                //First, evaluate credit eligibility for PO  
                //When PO is Normal Client Account of Concern                   
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c) == normalClientAcc){  
                    
                    parentId = mapPOParentIds.get(stg.Price_Owner__c);//Get PO's parent id
                    poConcernCode  = mapPOConcers.get(parentId);//Get PO's parent's represent's code
                    
                    if(validateInfluencer(normalClientAcc + '-' + priceOwner, stg.Price_Owner__c,FALSE, stg) || 
                       validateInfluencer(normalClientAcc + '-' + priceOwner, poConcernCode, TRUE, stg)){
                           wrap.poCreditEligible = TRUE;    
                       }                    
                }
                
                // When PO is Client Account and Represents Concern  
                else if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c) == representsConcernAcc){
                    if(validateInfluencer(representsConcernAcc + '-' + priceOwner, stg.Price_Owner__c, FALSE, stg)){
                        wrap.poCreditEligible = TRUE;
                    }                    
                }
                
                // When PO is Non-concern Client Account  
                else if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c) == clientAcc){
                    if(validateInfluencer(clientAcc + '-' + priceOwner, stg.Price_Owner__c,FALSE, stg)){
                        wrap.poCreditEligible = TRUE;
                    }
                }
                //Code ends when Price Owner Eligibility check 
                wrap = validateShipperAndConsignee(wrap,FALSE, stg);
                mapAccountCreditEligibility.put(stg.Id, wrap);                  
                 
            }//Code Ends for Price Owner and Shipper and Consignee ALL are Different
            
            
            
            
            // When Consignee and shipper's accounts are same but Po is differnet. 
            if(stg.Price_Owner__c != stg.Consignee__c && stg.Price_Owner__c != stg.Shipper__c && stg.Consignee__c == stg.Shipper__c){
                
                // When PO is normal Client of Concern.
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==normalClientAcc){
                    
                    parentId = mapPOParentIds.get(stg.Price_Owner__c);
                    poConcernCode = parentId!=NULL? mapPOConcers.get(parentId):NULL;
                    
                    mapAccountCreditEligibility.put(stg.Id,validatePoAndShipper(normalClientAcc,TRUE,poConcernCode,stg,wrap,TRUE,FALSE)); 
                    
                }//End of when PO is normal client of concern 
                
                // When PO is Client Account and Represents Concern 
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==representsConcernAcc){
                    
                    mapAccountCreditEligibility.put(stg.Id,validatePoAndShipper(representsConcernAcc,FALSE,stg.Price_Owner__c,stg,wrap,FALSE,FALSE));
                    
                } //End of when PO is Client Account and Represents Concern  
                
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==clientAcc){
                    
                    mapAccountCreditEligibility.put(stg.Id,validatePoAndShipper(clientAcc,FALSE,stg.Price_Owner__c,stg,wrap,FALSE,FALSE));
                                        
                }    
            }//End when Po is different and consignee and shipper's account are same  
            
            
            // When Po is same as either Shipper or Consignee but Shipper and Consignee are not same.
            if((stg.Price_Owner__c==stg.Shipper__c || stg.Price_Owner__c==stg.Consignee__c) && stg.Shipper__c!=stg.Consignee__c){
                
                // When PO is normal Client of Concern.                
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==normalClientAcc){
                    
                    parentId = mapPOParentIds.get(stg.Price_Owner__c);
                    poConcernCode = parentId!=NULL? mapPOConcers.get(parentId):NULL;
                    
                    if(validateInfluencer(normalClientAcc+'-'+priceOwner, stg.Price_Owner__c,FALSE, stg) ||
                       validateInfluencer(normalClientAcc+'-'+priceOwner, poConcernCode, TRUE, stg)){ 
                           wrap.poCreditEligible = TRUE;                               
                       }
                    wrap = validateShipperAndConsignee(wrap,TRUE, stg);
                   
                }// End When PO is normal Client of Concern.
                
                
                // When PO is Client Account and Represents Concern
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==representsConcernAcc){
                  
                    if(validateInfluencer(representsConcernAcc+'-'+priceOwner, stg.Price_Owner__c, FALSE, stg)){
                        wrap.poCreditEligible = TRUE;
                    }
                    wrap = validateShipperAndConsignee(wrap,TRUE, stg);
                    
                } // End When PO is Client Account and Represents Concern
                
                
                // When PO is Client Account
                if(mapPOAccountType.containsKey(stg.Price_Owner__c) && mapPOAccountType.get(stg.Price_Owner__c)==clientAcc){
                    
                    if(validateInfluencer(clientAcc+'-'+priceOwner, stg.Price_Owner__c, FALSE, stg)){ 
                        wrap.poCreditEligible = TRUE;
                    }
                    wrap = validateShipperAndConsignee(wrap,TRUE, stg);
                    
                }
                mapAccountCreditEligibility.put(stg.Id, wrap);                  
                
            } // When Po is same as either Shipper or Consignee but Shipper and Consignee are not same.                            
        }
        return mapAccountCreditEligibility;
    }// End of Method.
    
    private Boolean validateAccount(String key, String accountCode, Boolean skipSO, Target_Setting_Staging__c stg){
        
        Boolean check = false;
        String responsibilites = mapCustomMetaData.get(key).Portfolio_Owner_Responsibility__c;        
        List<String> listResponsibilities = responsibilites.split(',');
        
        // SFSE-13107 - Mapping the Lns Brand with SalesForce Brand. 
        String brand = brandMapping.containsKey(stg.Brand__c) && !String.isBlank(brandMapping.get(stg.Brand__c))?brandMapping.get(stg.Brand__c):'';      
        
        if(skipSO && responsibilites.contains(TargetSettingConstants.SalesOwner)){
          listResponsibilities.remove(listResponsibilities.indexOf(TargetSettingConstants.SalesOwner));  
        }
        
        List<CreditEligibilityUtility.AccountTAAWrapper>listTAAs =  mapAccountTAARecords.containsKey(accountCode) ? mapAccountTAARecords.get(accountCode) : new List<CreditEligibilityUtility.AccountTAAWrapper>(); 
       
        if(listTAAs!=NULL && listTAAs.size()>0){
            for(CreditEligibilityUtility.AccountTAAWrapper TAA: listTAAs) {
                
                if(String.isNotBlank(TAA.Brand) && ('All'.equals(TAA.Brand) || (brand!='' && TAA.Brand.contains(brand)))){
                    if(listResponsibilities.contains(TAA.portfolio)) {
    	            	check = true;
        	            break;
	                }
                  }                 
            }
        }        
        return check;  
    }
    
    private Boolean validateInfluencer(String key, String customerCode, Boolean checkPOConcern, Target_Setting_Staging__c stg){
       Boolean check = False;        
       List<CreditEligibilityUtility.AccountTAAWrapper>listTAAs = mapAccountTAARecords.get(customerCode);
        String responsibilites = checkPOConcern?mapCustomMetaData.get(key).Concern_Portfolio_Responsibility__c:mapCustomMetaData.get(key).Portfolio_Owner_Responsibility__c;  
        List<String> listResponsibilities = responsibilites.split(',');
        
       // SFSE-13107 - Mapping the Lns Brand with SalesForce Brand. 
       String brand = brandMapping.containsKey(stg.Brand__c) && !String.isBlank(brandMapping.get(stg.Brand__c))?brandMapping.get(stg.Brand__c):'';      
       
        // When Eligible TAA is an Influencer then Staging Record BDA should be equals to TAA BDA (or) 
        // 				                  Staging Record Country should be equals to TAA Country (or)
        // 				                  Staging Country should fall under TAA BDA to get eligibility.
        // When Eligible TAA is not an infulencer then make Party is Credit Eligible.
        // Eligiblity is when TAA Portfolio Responsibility is one among the responsibilites in Custom Metadata against Customer Type and Party Type.
        				                     
        if(listTAAs!=NULL && listTAAs.size()>0){
           
            for(CreditEligibilityUtility.AccountTAAWrapper TAA: listTAAs){
                
                if(String.isNotBlank(TAA.Brand) && 
                   ('All'.equals(TAA.Brand) || (brand!='' && TAA.Brand.contains(brand))) && 
                   listResponsibilities.contains(TAA.portfolio)){                        
                    if(TAA.portfolio =='Influencer'){						                        
                       Id taaInfluencerBDA = TAA.BDAId;
                        if((stg.Country__c != null && TAA.geographyId == stg.Country__c) || 
                           (stg.Area__c != null && taaInfluencerBDA == stg.Area__c) || 
                           (taaInfluencerBDA!=NULL && stg.Country__c != null && stg.Country__r.GEO_Code__c != null && 
                        	mapBDAs!=NULL && mapBDAs.containsKey(taaInfluencerBDA) && 
                        	mapBDAs.get(taaInfluencerBDA).Contains(stg.Country__r.GEO_Code__c))){
                          check = TRUE; break;  
                        }                        
                    }
                    else{                        
                    check = TRUE; break;}    
                }
            }
        }        
        return check;
    }
    
    private CreditEligibilityUtility.EligibilityWrapper validateShipperAndConsignee(CreditEligibilityUtility.EligibilityWrapper wrapper, 
                                                                                    Boolean skipSO, Target_Setting_Staging__c stg){
          Boolean skipSOForShipper = FALSE;
          Boolean skipSOForConsignee = FALSE;
                                                                                       
           if(stg.Price_Owner__c == stg.Consignee__c && stg.Consignee__c!= stg.Shipper__c){
               skipSOforShipper= FALSE;
               skipSOforConsignee = TRUE;
           }
           else if(stg.Price_Owner__c == stg.Shipper__c && stg.Consignee__c!= stg.Shipper__c){
               skipSOforShipper= TRUE;
               skipSOforConsignee = FALSE;                                                                             
           }
           else{
               skipSOforShipper= skipSO;
               skipSOforConsignee = skipSO;                                                                               
           }    
                                                                                        
        if(validateAccount(system.label.AccountType_ClientAccount+'-'+system.label.PartyType_Shipper, stg.Shipper__c, skipSOForShipper, stg)){
           wrapper.shipperCreditEligible=TRUE; 
        }
        if(validateAccount(system.label.AccountType_ClientAccount+'-'+system.label.PartyType_Consignee, stg.Consignee__c, skipSOForConsignee	, stg)){
           wrapper.consigneeCreditEligible = TRUE;
        }             
		
        return wrapper;  
    }
    
    private CreditEligibilityUtility.EligibilityWrapper validatePoAndShipper(String customerType, Boolean normalAccCheck,
                                                                             String poConcernCode, Target_Setting_Staging__c stg, 
                                                                             CreditEligibilityUtility.EligibilityWrapper wrapper, 
                                                                             Boolean poConcernCheck,Boolean skipSO){
        if((normalAccCheck && validateInfluencer(customerType+'-'+system.label.PartyType_PriceOwner, stg.Price_Owner__c,FALSE, stg)) ||
           (validateInfluencer(customerType+'-'+system.label.PartyType_PriceOwner, poConcernCode, poConcernCheck, stg))){              
               wrapper.poCreditEligible = TRUE;                
           }
        if(validateAccount(customerType+'-'+system.label.PartyType_Shipper, stg.Shipper__c,skipSO, stg)){
            wrapper.shipperCreditEligible=TRUE;            
        }        
                                                                             
        return wrapper;	    
    }
             
}