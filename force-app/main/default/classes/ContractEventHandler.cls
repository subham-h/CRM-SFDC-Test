public class ContractEventHandler {
    public static List<Contract__c> lstContractToInsert = new List<Contract__c>();
    public static Set<String> oppNum = new Set<String>();
    public static Set<String> agreementNum = new Set<String>();
    public static Set<String> customNum = new Set<String>();
    public static Map<String, Id> mapOfAccId = new Map<String, Id>();
    public static Map<String, Id> mapOfContIdtoNumber = new Map<String, Id>();
    public static Map<String, Id> mapNumberToId = new Map<String, Id>();
    public static List<Opportunity_Contract__c> lstOPCToInsert = new List<Opportunity_Contract__c>();
    public static Set<Id> setContractIds = new Set<Id>();
    public static List<Opportunity_Contract__c> lstContractsTobeDeleted = new List<Opportunity_Contract__c>();
	public Integer index = 0;    
    public static void createALexContracts(List<Contract_Event__e> newList) {
        //String jsonStr = null;
        List<AgreementWrapper> lstOfJsonData = new List<AgreementWrapper>();
        Map<String, Id> mapOfContIdtoNumber = new Map<String, Id>();
        String jsonStr = '';
        AgreementWrapper mapOfJsonData = new AgreementWrapper();
       // String jsonStr = '{  "header": {    "eventNotificationName": "com.maersk.contract.completed",    "version": "1.0.0",    "correlationId": "a8a096c6-49a3-4a74-8d4f-0fcd5ceb93dd",    "system": "a-LEX (CLM)",    "tenantInformation": {      "tenantId": "COMMERCIAL"    },    "messageId": "719a7274-5497-4bdf-b445-f697ac3877c8",    "eventTimestamp": 1687518155981  },  "message": {    "agreementNumber": "10003616",    "agreementVersionNumber": "1.0",    "relatedAgreements": [      {        "agreementNumber": "10003617",        "agreementRelationReason": {          "agreementRelationReasonCode": "LINKDAGRMNT001",          "agreementRelationReasonName": ""        }      }    ],    "agreementName": "Nike_Contract",    "agreementSigningType": "ESIGN",    "agreementComment": "Agreement sample",    "agreementType": {      "agreementTypeCode": "CONTYP001",      "agreementTypeName": "Bailment Agreement"    },    "agreementEffectiveDate": 1579787264,    "agreementExpirationDate": 1591980032,    "brand": {      "brandCode": "MAEU",      "brandName": "Maersk"    },    "products": [      {        "productCode": "P-P0-dx1",        "productName": "Ocean - Seasonal Sync",        "productVersion": "1"      }    ],    "parties": [      {        "party": {          "partyCode": "TW48726848",          "partyName": "NIKE HOLDINGS INC"        },        "partyFunction": "CUSTOMER"      },      {        "party": {          "partyCode": "Maersk Line India Pvt. Ltd.",          "partyName": "Maersk Line India Pvt. Ltd."        },        "partyFunction": "INTERNAL_LEGAL_ENTITY"      },      {        "party": {          "partyCode": "FMC",          "partyName": "Federal Maritime Commission"        },        "partyFunction": "REGULATOR"      }    ],    "references": [      {        "reference": "OP-23-80277448",        "referenceType": {          "referenceTypeCode": "SFDC",          "referenceTypeName": "Salesforce"        }      },      {        "reference": "115",        "referenceType": {          "referenceTypeCode": "NEGOTIATION",          "referenceTypeName": "NEGOTIATION AS A SERVICE"        }      },      {        "reference": "106",        "referenceType": {          "referenceTypeCode": "PRICE",          "referenceTypeName": "PRICE"        }      }    ],    "documents": [      {        "documentNumber": "d793d369-a1a1-4ce9-b910-ba61bd8e76cc",        "documentName": "agreement_sample.pdf",        "documentType": {          "documentTypeCode": "DOCCAT002",          "documentTypeName": "Agreement"        }      }    ],    "agreementStatus": {      "agreementStatusCode": "COMPLETED",      "agreementStatusName": "Completed"    },    "agreementStatusReason": "all parties signed",    "changeDetail": {      "actionBy": "fbb62d3b-3aae-404c-a423-012f7bcd0738",      "actionTimeStamp": 1687518108690,      "actionComment": ""    }  }}';
        for(Contract_Event__e ce: newList) {
              jsonStr = ce.Json_1__c;
              mapOfJsonData = (AgreementWrapper)JSON.deserialize(jsonStr.replace('system', 'system_Z'),AgreementWrapper.class);
              system.debug('mapOfJsonData'+mapOfJsonData);
              lstOfJsonData.add(mapOfJsonData);     	
         }
        system.debug('Here'+jsonStr);
        
        for(References ref : mapOfJsonData.message.references){
            if(ref.ReferenceType.referenceTypeCode == 'SFDC'){
                oppNum.add(ref.reference);   
                system.debug('Opportunity Number'+ref.reference);
            }
        }
        agreementNum.add(mapOfJsonData.message.agreementNumber);
        for(Parties pt : mapOfJsonData.message.parties){
            if(pt.partyFunction == 'CUSTOMER'){
                customNum.add(pt.party.partyCode);
                system.debug('mapOfJsonData'+pt.party.partyCode);
            }
        }
		if(!customNum.isEmpty() && customNum !=null){
            mapOfAccId = getAccountId(customNum);
        }        
        mapOfContIdtoNumber = getAgreementDetails(agreementNum);
        Schema.SObjectField ftoken = Contract__c.Fields.Name;
        lstContractToInsert = createContracts(lstOfJsonData, mapOfContIdtoNumber,customNum);
        Database.UpsertResult[] results =  Database.upsert(lstContractToInsert,ftoken, false); 
        
        ErrorLogger.writeErrors('SFDC', 'Contract', 'ContractEventHandler.createALexContract', results, lstContractToInsert);
        for(Contract__c ct: lstContractToInsert) {
            mapOfContIdtoNumber.put(ct.Name, ct.Id);  
        	lstOPCToInsert = createOppContracts(lstOfJsonData, mapOfContIdtoNumber);
        }
        lstOPCToInsert = createOppContracts(lstOfJsonData, mapOfContIdtoNumber);

        Database.SaveResult[] srList = Database.insert(lstOPCToInsert, false);  
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {                   
                    ErrorLogger.writeError('SFDC', 'Opp Contract', 'ContractEventHandler.createALexContract', JSON.serialize(err),err.getMessage(),JSON.serialize(lstOPCToInsert));                                             
                }
            }    
        }
        lstContractsTobeDeleted = deleteContract(lstOfJsonData, mapOfContIdtoNumber); 
        if(lstContractsTobeDeleted.size() > 0) {
            try{
                delete lstContractsTobeDeleted;
            }catch(exception ex){
               ErrorLogger.writeErrors( 'SFDC', 'Contract', 'ContractEventHandler.createALexContracts', new list<Exception>{ex});  
            }
        }        
    }
    
	public class AgreementType {
		public String agreementTypeCode {get;set;} 
		public String agreementTypeName {get;set;} 
	}
	
	/*public class Products {
		public String productCode {get;set;} 
		public String productName {get;set;} 
		public String productVersion {get;set;} 
	}*/
    public class AgreementWrapper {
        public Header header {get;set;} 
        public Message message {get;set;}   
        
    }
	public class TenantInformation {
		public String tenantId {get;set;} 
	}
	
	public class Message {
		public String agreementNumber {get;set;} 
		//public String agreementVersionNumber {get;set;} 
		//public List<RelatedAgreements> relatedAgreements {get;set;} 
		public String agreementName {get;set;} 
		//public String agreementSigningType {get;set;} 
		//public String agreementComment {get;set;} 
		public AgreementType agreementType {get;set;} 
		public Integer agreementEffectiveDate {get;set;} 
		public Integer agreementExpirationDate {get;set;} 
		public Brand brand {get;set;} 
		//public List<Products> products {get;set;} 
		public List<Parties> parties {get;set;} 
		public List<References> references {get;set;} 
		//public List<Documents> documents {get;set;} 
		public AgreementStatus agreementStatus {get;set;} 
		public String agreementStatusReason {get;set;} 
		//public ChangeDetail changeDetail {get;set;} 

	}
	
	/*public class DocumentType {
		public String documentTypeCode {get;set;} 
		public String documentTypeName {get;set;} 

	}*/
	
	public class ReferenceType {
		public String referenceTypeCode {get;set;} 
		public String referenceTypeName {get;set;}
	}
	
	public class Brand {
		public String brandCode {get;set;} 
		public String brandName {get;set;} 

	}
	
	public class Parties {
		public Party party {get;set;} 
		public String partyFunction {get;set;} 
	}
	
	/*public class AgreementRelationReason {
		public String agreementRelationReasonCode {get;set;} 
		public String agreementRelationReasonName {get;set;} 
	}*/
	
	public class Party {
		public String partyCode {get;set;} 
		public String partyName {get;set;} 
	}
	
	public class Header {
		public String eventNotificationName {get;set;} 
		public String version {get;set;} 
		public String correlationId {get;set;} 
		public String system_Z {get;set;} // in json: system
		public TenantInformation tenantInformation {get;set;} 
		public String messageId {get;set;} 
		public Long eventTimestamp {get;set;} 
	}
	
	public class References {
		public String reference {get;set;} 
		public ReferenceType referenceType {get;set;} 
	}
	
	/*public class Documents {
		public String documentNumber {get;set;} 
		public String documentName {get;set;} 
		public DocumentType documentType {get;set;} 
	}*/
	
	/*public class RelatedAgreements {
		public String agreementNumber {get;set;} 
		public AgreementRelationReason agreementRelationReason {get;set;} 
	}*/
	
	public class AgreementStatus {
		public String agreementStatusCode {get;set;} 
		public String agreementStatusName {get;set;} 
	}
	
/*	public class ChangeDetail {
		public String actionBy {get;set;} 
		public Long actionTimeStamp {get;set;} 
		public String actionComment {get;set;} 
	}*/
    
    public static Map<String, Id> getAccountId(Set<String> accCode) {
        
         Map<String, Id> cusNumToId = new Map<String, Id>();
        if(!accCode.isEmpty() && accCode !=null) {
            system.debug('@@@@ accCode' + accCode);
            for(Account acc: [SELECT Id, Customer_Code__c FROM Account WHERE Customer_Code__c IN:accCode]) {
                cusNumToId.put(acc.Customer_Code__c, acc.Id);
            }
        }
        return cusNumToId;
    }
    
    public static Map<String, Id> getAgreementDetails(Set<String> contractNum) {
        Map<String, Id> contractNumToId = new Map<String, Id>();
        if(contractNum.size() > 0 && !contractNum.isEmpty()) {
            for(Contract__c cont: [SELECT Id, Name FROM Contract__c WHERE Name IN: contractNum]) { 
                contractNumToId.put(cont.Name, cont.Id);
            }
        }
        return contractNumToId; 
    }
    
    public static List<Contract__c> createContracts(List<AgreementWrapper> agreementWrap, map<String, Id> contIdtoNum,Set<String> customNum) {
        List<Contract__c> agreements = new List<Contract__c>();
        for(AgreementWrapper cp: agreementWrap) {
            Contract__c cont = new Contract__c();
            cont.Name = cp.message.agreementNumber;
            cont.Contract_Name__c = cp.message.agreementName;
            If(contIdtoNum.get(cp.message.agreementNumber) != null) {
                cont.Id = contIdtoNum.get(cp.message.agreementNumber);
            }
            cont.Agreement_Type_Code__c = cp.message.agreementType.agreementTypeCode;
            cont.Agreement_Type_Name__c = cp.message.agreementType.agreementTypeName;
            cont.Brand_Code__c = cp.message.brand.brandCode;
            cont.Brand_Name__c = cp.message.brand.brandName;
            cont.Effective_Date__c = convertEpochDays(String.valueOf(cp.message.agreementEffectiveDate).SubStringBefore('-'));
            cont.Expiration_Date__c = convertEpochDays(String.valueOf(cp.message.agreementExpirationDate).SubStringBefore('-'));
            //cont.Is_FMC_Contract__c = cp.message.isFmcContract;
            //cont.Is_Master_Contract__c = cp.message.isMasterContract;
            String custCode = new List<String> (customNum).get(0);
            cont.Customer__c = mapOfAccId.get(custCode);
            cont.Status__c = cp.message.agreementStatus.agreementStatusName;
            cont.Status_Code__c = cp.message.agreementStatus.agreementStatusCode;
            agreements.add(cont);  
        }
        return agreements;
    }
    
   public static List<Opportunity_Contract__c> createOppContracts(List<AgreementWrapper> contractWrap, map<String, Id> mapOfcontNumToId) {
        List<Opportunity_Contract__c> oppcontracts = new List<Opportunity_Contract__c>();
        Map<Id, Opportunity_Contract__c> mapOfContractToOppContract = new Map<Id, Opportunity_Contract__c>();
        List<Opportunity_Contract__c> getExsitingContracts = [SELECT Id, Contract__r.Status_Code__c, Status__c, Contract__c FROM Opportunity_Contract__c WHERE Contract__c IN: mapOfcontNumToId.values()];
        for(Opportunity_Contract__c opc: getExsitingContracts) {
            mapOfContractToOppContract.put(opc.Contract__c, opc);
        }
        system.debug('mapOfcontNumToId ' + mapOfcontNumToId);
        system.debug('getExsitingContracts ' + getExsitingContracts);
        if(!oppNum.isEmpty() && oppNum !=null) {
            mapNumberToId = getOpporId(oppNum);
        }
        for(AgreementWrapper cw : contractWrap) {
            if(mapOfcontNumToId.containsKey(cw.message.agreementNumber) && !mapOfContractToOppContract.containsKey(mapOfcontNumToId.get(cw.message.agreementNumber))) {
                Opportunity_Contract__c opc = new Opportunity_Contract__c();
                opc.Contract__c = mapOfcontNumToId.get(cw.message.agreementNumber);  
                List<String> tempOppNum = new List<String>(oppNum);
                opc.Opportunity__c = mapNumberToId.get(tempOppNum[0]);
                oppcontracts.add(opc);   
            }
        }
        system.debug('oppcontracts ' + oppcontracts);
        return oppcontracts;
    }
    
    public static List<Opportunity_Contract__c> deleteContract(List<AgreementWrapper> contractWrap, map<String, Id> mapOfcontNumToId){
        List<Opportunity_Contract__c> oppcontracts = new List<Opportunity_Contract__c>();
        Map<Id, Opportunity_Contract__c> mapOfContractToOppContract = new Map<Id, Opportunity_Contract__c>();
        List<Opportunity_Contract__c> getExsitingContracts = [SELECT Id, Contract__r.Status_Code__c, Status__c, Contract__c FROM Opportunity_Contract__c WHERE Contract__c IN: mapOfcontNumToId.values()];
        for(Opportunity_Contract__c opc: getExsitingContracts) {
            mapOfContractToOppContract.put(opc.Contract__c, opc);
        }
        system.debug('mapOfcontNumToId ' + mapOfcontNumToId);
        system.debug('getExsitingContracts ' + getExsitingContracts);
        if(!oppNum.isEmpty() && oppNum !=null) {
            mapNumberToId = getOpporId(oppNum);
        }
        for(AgreementWrapper cw : contractWrap) {
            if(mapOfcontNumToId.containsKey(cw.message.agreementNumber) && mapOfContractToOppContract.containsKey(mapOfcontNumToId.get(cw.message.agreementNumber))){
                if(mapOfContractToOppContract.get(mapOfcontNumToId.get(cw.message.agreementNumber)).Contract__r.Status_Code__c.toLowercase() == 'deactivated') {
                    lstContractsTobeDeleted.add(mapOfContractToOppContract.get(mapOfcontNumToId.get(cw.message.agreementNumber))); 
                } 
            }
        }
        return lstContractsTobeDeleted;
    }
    
 	public static Map<String, Id> getOpporId(Set<String> opportunityNumber) {
        Map<String, Id> opRefToId = new Map<String, Id>();
        If(!test.isRunningTest()) {
            if(opportunityNumber.size() > 0 && !opportunityNumber.isEmpty()) {
                for(Opportunity op: [SELECT Id, Opportunity_Ref__c FROM Opportunity WHERE Opportunity_Ref__c IN: opportunityNumber]) { 
                    opRefToId.put(op.Opportunity_Ref__c, op.Id);
                }
            }
        }else{
            for(Opportunity op: [SELECT Id, Opportunity_Ref__c FROM Opportunity]) { 
                opRefToId.put(op.Opportunity_Ref__c, op.Id);
            }  
        }
        return opRefToId;
    }
    
    public static Date convertEpochDays(String epochDays) {    
        return Date.newInstance(1970, 1, 1).addDays(Integer.valueOf(epochDays));
    }

}