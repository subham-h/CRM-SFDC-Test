@isTest
public class OpportunityContractHandlerTest {
    @testSetup static void setup() {
       createContract();
    }
    
    static testmethod void testfetchOLIs() {
        Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];
        Test.startTest();
        OpportunitywithProductsCtrl.fetchOLIs(contract.Id);
        Test.stopTest();
    }
    
     static testmethod void testhasAccessToContract() {
         List<Id> lstContId = new List<Id>();
         Id uId = UserInfo.getUserId();
         for(Contract__c cont: [SELECT Id FROM Contract__c LIMIT 1]) {
             lstContId.add(cont.Id);
         }
        
        Test.startTest();
        ContractStatusCtrlr.hasAccessToContract(lstContId, uId);
        Test.stopTest();
    }
    
    public static void createContract() {
        Test.startTest();
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
        //Opportunity mslOppty2 = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null);
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Contract__c cont = new Contract__c();
        cont.Agreement_Type_Code__c = 'Credit_Agreement';
        cont.Brand_Name__c = 'Maersk';
        cont.Customer__c = clientAcc.Id;
        cont.Effective_Date__c  = system.today() + 1;
        cont.Expiration_Date__c = system.today() + 10;
        cont.Is_FMC_Contract__c = false;
        cont.Is_Master_Contract__c = false;
        cont.Status__c = 'Draft';
        insert cont;
        system.debug('cont ' + cont);
        Opportunity_Contract__c opc = new Opportunity_Contract__c();
        opc.Contract__c = cont.Id;
        opc.Opportunity__c = mslOppty2.Id;
        insert opc;
        system.debug('opc ' + opc);  
        ContractStatusCtrlr.getOpportunityContracts(opc.Opportunity__c);
        ContractStatusCtrlr.getContractPath();
        Test.stopTest();
    }
    
    public static testmethod void testContractCreate() {
        Contract_Event__e thisEvent = new Contract_Event__e(Json_1__c = '{"header":{"eventNotificationName":"com.maersk.contract.created","version":"2.0.0","correlationId":"9233168d-2871-4f00-a9f7-eb9561c7d5c6","system":"a-LEX (CLM)","tenantInformation":{"tenantId":"COMMERCIAL"},"messageId":"27a2841a-09b6-49f6-8e15-1c66dde2f9aa","eventTimestamp":1718344066932},"message":{"agreementNumber":"10035060","agreementVersionNumber":"1.0","relatedAgreements":null,"agreementName":"Q&N Test-2","agreementSigningType":null,"agreementComment":null,"agreementType":{"agreementTypeCode":"CONTYP044","agreementTypeName":"Covered by master agreement"},"agreementEffectiveDate":20178,"agreementExpirationDate":20453,"brand":{"brandCode":"MAEU","brandName":"Maersk"},"products":[{"productCode":"P-P0-20jb","productName":"Intermodal - Carrier Haulage","productVersion":"11.0","tradeRoutes":null},{"productCode":"P-P0-2hi9","productName":"Export Customs Services","productVersion":"4.0","tradeRoutes":null},{"productCode":"P-P0-dx1","productName":"Ocean - Seasonal Sync","productVersion":"33.0","tradeRoutes":[{"routeCode":"C1E","routeName":"Far East - Central America/Caribbean C1E"}]},{"productCode":"P-P0-2hib","productName":"Import Customs Services","productVersion":"4.0","tradeRoutes":null}],"parties":[{"party":{"partyCode":"USC3000987","partyName":"WOLVERINE WORLD WIDE INC"},"partyFunction":"CUSTOMER"}],"references":[{"reference":"OP-24-8588386","referenceType":{"referenceTypeCode":"SFDC","referenceTypeName":"Salesforce"}}],"documents":null,"agreementStatus":{"agreementStatusCode":"draft","agreementStatusName":"draft"},"agreementStatusReason":null,"changeDetail":{"actionBy":"29e1e672-35d4-4aaa-acc7-7632dd534da3","actionTimeStamp":1718344066931,"actionComment":null}}}');
        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(thisEvent);       
        Test.stopTest();
    }
    
    public static testmethod void testContractUpdate() {
        Contract_Event__e thisEvent = new Contract_Event__e(Json_1__c = '{"header":{"eventNotificationName":"com.maersk.contract.completed","version":"2.0.0","correlationId":"30ff3e4a-79fe-439f-b0c2-34809f762386","system":"a-LEX (CLM)","tenantInformation":{"tenantId":"COMMERCIAL"},"messageId":"3cbb9a72-d62a-4236-9033-8b44f8cd0c0c","eventTimestamp":1718344129831},"message":{"agreementNumber":"10035060","agreementVersionNumber":"1.0","relatedAgreements":null,"agreementName":"Q&N Test-2","agreementSigningType":"WETINK","agreementComment":null,"agreementType":{"agreementTypeCode":"CONTYP044","agreementTypeName":"Covered by master agreement"},"agreementEffectiveDate":20178,"agreementExpirationDate":20453,"brand":{"brandCode":"MAEU","brandName":"Maersk"},"products":[{"productCode":"P-P0-20jb","productName":"Intermodal - Carrier Haulage","productVersion":"11.0","tradeRoutes":null},{"productCode":"P-P0-2hi9","productName":"Export Customs Services","productVersion":"4.0","tradeRoutes":null},{"productCode":"P-P0-dx1","productName":"Ocean - Seasonal Sync","productVersion":"33.0","tradeRoutes":[{"routeCode":"C1E","routeName":"Far East - Central America/Caribbean C1E"}]},{"productCode":"P-P0-2hib","productName":"Import Customs Services","productVersion":"4.0","tradeRoutes":null}],"parties":[{"party":{"partyCode":"USC3000987","partyName":"WOLVERINE WORLD WIDE INC"},"partyFunction":"CUSTOMER"},{"party":{"partyCode":"Damco India Pvt. Ltd.","partyName":"Damco India Pvt. Ltd."},"partyFunction":"INTERNAL_LEGAL_ENTITY"}],"references":[{"reference":"OP-24-8588386","referenceType":{"referenceTypeCode":"SFDC","referenceTypeName":"Salesforce"}}],"documents":[{"documentNumber":"351e0d82-fc65-44de-a9f2-87b2d2448388","documentName":"dummy.pdf","documentType":{"documentTypeCode":"DOCCAT005","documentTypeName":"Email"}}],"agreementStatus":{"agreementStatusCode":"completed","agreementStatusName":"completed"},"agreementStatusReason":null,"changeDetail":{"actionBy":"29e1e672-35d4-4aaa-acc7-7632dd534da3","actionTimeStamp":1718344129831,"actionComment":null}}}');
        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(thisEvent);       
        Test.stopTest();
    }
    
    public static testmethod void testContractDelete() {
        Contract_Event__e thisEvent = new Contract_Event__e(Json_1__c = '{"header":{"eventNotificationName":"com.maersk.contract.deactivated","version":"2.0.0","correlationId":"eb6a8b53-0376-48cd-9fc3-642bbff9a522","system":"a-LEX (CLM)","tenantInformation":{"tenantId":"COMMERCIAL"},"messageId":"3372d198-b9b5-4ef7-9f1f-8e7eb6e70c03","eventTimestamp":1718344155136},"message":{"agreementNumber":"10035060","agreementVersionNumber":"1.0","relatedAgreements":null,"agreementName":"Q&N Test-2","agreementSigningType":"WETINK","agreementComment":null,"agreementType":{"agreementTypeCode":"CONTYP044","agreementTypeName":"Covered by master agreement"},"agreementEffectiveDate":20178,"agreementExpirationDate":20453,"brand":{"brandCode":"MAEU","brandName":"Maersk"},"products":[{"productCode":"P-P0-20jb","productName":"Intermodal - Carrier Haulage","productVersion":"11.0","tradeRoutes":null},{"productCode":"P-P0-2hi9","productName":"Export Customs Services","productVersion":"4.0","tradeRoutes":null},{"productCode":"P-P0-dx1","productName":"Ocean - Seasonal Sync","productVersion":"33.0","tradeRoutes":[{"routeCode":"C1E","routeName":"Far East - Central America/Caribbean C1E"}]},{"productCode":"P-P0-2hib","productName":"Import Customs Services","productVersion":"4.0","tradeRoutes":null}],"parties":[{"party":{"partyCode":"USC3000987","partyName":"WOLVERINE WORLD WIDE INC"},"partyFunction":"CUSTOMER"},{"party":{"partyCode":"Damco India Pvt. Ltd.","partyName":"Damco India Pvt. Ltd."},"partyFunction":"INTERNAL_LEGAL_ENTITY"}],"references":[{"reference":"OP-24-8588386","referenceType":{"referenceTypeCode":"SFDC","referenceTypeName":"Salesforce"}}],"documents":null,"agreementStatus":{"agreementStatusCode":"deactivated","agreementStatusName":"deactivated"},"agreementStatusReason":"test","changeDetail":{"actionBy":"29e1e672-35d4-4aaa-acc7-7632dd534da3","actionTimeStamp":1718344155136,"actionComment":null}}}');
        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(thisEvent);       
        Test.stopTest();
    }
}