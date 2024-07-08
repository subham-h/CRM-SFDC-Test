/**
* 
* Revision Ref Number  Date            Owner                       Description
* -------- ----------  -----------     -------------------         -----------
* 1.0
* 2.0      SPI-100     13/06/2022      Ronnie@SF                  Removed brand hardcoding
* 3.0      SC-7827     05/05/2023      sunil.bs@maersk.com        Updated test class to test omni rule priority scenario's
* 4.0      SC-7826     09/06/2023      nayana.sharma@maersk.com   Added method to cover Subtype-based SR Routing
* 5.0      SC-8264     27-06-2023      Sunil BS                   Added logic to cover out of office scenario
* 6.0	   SC-10048	   15-05-2024	   Nayana@maersk			  Added logic to cover RFC-based SR Routing
*/

@istest
public class CaseOmniSkillBasedRouting_Test {
    
    /** 
* @description |To cover defineCaseSkillMap Methods Omni General Skill|
*/
    
    //To cover SR scenario     
    public static testmethod void omniSkillBasedRouting1() {
        
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap2);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.GSC_Agent__c = userlist[0].id;
        maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Export';
        maerskLineCCA.Sub_Type__c ='Submit SI/BL/VC';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        list < Care_Relationship__c > carelist = new list < Care_Relationship__c > ();
        carelist.add(maerskLineCR);
        Map < Id, Care_Relationship__c > mapRelatedCareRelation = new Map < Id, Care_Relationship__c > ();
        mapRelatedCareRelation.put(maerskLineCR.id, maerskLineCR);
        
        list < Client_Case_Assignments__c > clientCaselist = new list < Client_Case_Assignments__c > ();
        clientCaselist.add(maerskLineCCA);
        Map < Id, Client_Case_Assignments__c > mapClientCaseAssignment = new Map <Id,Client_Case_Assignments__c > ();
        mapClientCaseAssignment.put(maerskLineCCA.id,maerskLineCCA);
        
        insert lstCases;
        
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, null, null);
    }
    
    //To cover sub-Type scenario
    public static testmethod void omniSkillBasedRouting4() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap3 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap3',Developer_Name__c ='SkillMap3', Active__c = true, Case_Field__c = 'Sub_Type__c', Origin__c = 'MSLCNIMP', Value__c = 'Booking Confirmation Request', Skill_Id__c = '0C50D0000008QDn');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        omnimap.add(skillmap3);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, null,null, false, false, null, null);
    }
    
    //To cover General scenario       
    
    public static testmethod void omniSkillBasedRouting3() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        
        Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c, Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name From Case Where Id in:caseIds]);
        
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, null,null, false, false, null, caseMap);
    }
    
    //To cover SR and sub-Type scenario
    public static testmethod void omniSkillBasedRouting5() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap5 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap5',Developer_Name__c ='SkillMap5', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCLIMP', Value__c = 'Case_MSL_Chile_Import', Skill_Id__c = '0C57E0000008WIU');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        omnimap.add(skillmap5);
        insert omnimap;
        
        Omni_Service_Relationship_Mappings__c sr1 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCNIMP', Active__c = true, Origin__c = 'MSLCNIMP', Preferred_Agent__c = 'GSC_Agent__c;GSC_Backup_Agent__c', Sub_Type__c = '');
        Omni_Service_Relationship_Mappings__c sr2 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCLIMP', Active__c = true, Origin__c = 'MSLCLIMP', Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c', Sub_Type__c = 'Amend Booking Details');
        List < Omni_Service_Relationship_Mappings__c > omnimap2 = new List < Omni_Service_Relationship_Mappings__c > ();
        omnimap2.add(sr1);
        omnimap2.add(sr2);
        insert omnimap2;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend Booking Details';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;    
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(true);  
        user einteinUser = [select id,name from user where name='Einstein User' LIMIT 1];  
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import/Export';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.Care_Business_Partner__c = einteinUser.id;
        maerskLineCR.GSC_Agent__c = einteinUser.id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Export';
        maerskLineCCA.Sub_Type__c ='Submit SI/BL/VC';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        lstCases[0].Care_Relationship__c =  maerskLineCR.id;
        update lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id); 
    }
    
    //To cover out of office scenario
    public static testmethod void omniSkillBasedRouting6() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap5 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap5',Developer_Name__c ='SkillMap5', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCLIMP', Value__c = 'Case_MSL_Chile_Import', Skill_Id__c = '0C57E0000008WIU');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        omnimap.add(skillmap5);
        insert omnimap;
        
        Omni_Service_Relationship_Mappings__c sr1 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCNIMP', Active__c = true, Origin__c = 'MSLCNIMP', Preferred_Agent__c = 'GSC_Agent__c;GSC_Backup_Agent__c', Sub_Type__c = '');
        Omni_Service_Relationship_Mappings__c sr2 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCLIMP', Active__c = true, Origin__c = 'MSLCLIMP', Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c', Sub_Type__c = 'Amend Booking Details');
        List < Omni_Service_Relationship_Mappings__c > omnimap2 = new List < Omni_Service_Relationship_Mappings__c > ();
        omnimap2.add(sr1);
        omnimap2.add(sr2);
        insert omnimap2;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend Booking Details';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;    
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(true);  
        user einteinUser = [select id,name from user where name='Einstein User' LIMIT 1];  
        
        outofoffice outofofficeInstance1 = new outofoffice ();
        outofoffice outofofficeInstance2 = new outofoffice ();
        list<outofoffice> useroutofofficelist = new list<outofoffice>();
        
        outofofficeInstance1.StartDate = system.today();
        outofofficeInstance1.EndDate = system.today();
        outofofficeInstance1.IsEnabled = true;
        outofofficeInstance1.Message = 'Iam OOO';
        outofofficeInstance1.UserId = einteinUser.id;
        
        outofofficeInstance2.StartDate = system.today();
        outofofficeInstance2.EndDate = system.today();
        outofofficeInstance2.IsEnabled = true;
        outofofficeInstance2.Message = 'Iam OOO';
        outofofficeInstance2.UserId = userlist[0].id;
        
        useroutofofficelist.add(outofofficeInstance1);
        useroutofofficelist.add(outofofficeInstance2);
        
        insert useroutofofficelist;
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import/Export';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.Care_Business_Partner__c = einteinUser.id;
        maerskLineCR.GSC_Agent__c = einteinUser.id;
        insert maerskLineCR;
        lstCases[0].Care_Relationship__c =  maerskLineCR.id;
        update lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);  
    }
    
    //To cover Portal scenario       
    
    public static testmethod void omniSkillBasedRouting7() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'Portal';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, null,null, false, true, null, null);
    }
    
    
    //To cover update scenario       
    
    public static testmethod void omniSkillBasedRouting8() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, null,null, true, false, null, null);
    }
    
    //To cover SR sub type scenario  
    public static testmethod void omniSkillBasedRouting9() {
        
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap3 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap3',Developer_Name__c ='SkillMap3', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCLEXP', Value__c = 'Case_MSL_Chile_Export', Skill_Id__c = '0C50D0000008QWn');
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap2);
        omnimap.add(skillmap3);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.GSC_Agent__c = userlist[0].id;
        maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Export';
        maerskLineCCA.Sub_Type__c ='Submit SI/BL/VC';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        list < Care_Relationship__c > carelist = new list < Care_Relationship__c > ();
        carelist.add(maerskLineCR);
        Map < Id, Care_Relationship__c > mapRelatedCareRelation = new Map < Id, Care_Relationship__c > ();
        mapRelatedCareRelation.put(maerskLineCR.id, maerskLineCR);
        
        list < Client_Case_Assignments__c > clientCaselist = new list < Client_Case_Assignments__c > ();
        clientCaselist.add(maerskLineCCA);
        Map < Id, Client_Case_Assignments__c > mapClientCaseAssignment = new Map <Id,Client_Case_Assignments__c > ();
        mapClientCaseAssignment.put(maerskLineCCA.id,maerskLineCCA);
        
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.care_relationship__c = maerskLineCR.id;
        }
        
        insert lstCases;
        
        list<OutofOffice> outofofficelist = new list<OutofOffice>();
        OutofOffice outofficeuser1 = new OutofOffice();
        outofficeuser1.userid = userlist[0].id;
        outofficeuser1.Message = 'hi';
        outofficeuser1.StartDate =system.today();
        outofficeuser1.EndDate = system.today();
        outofofficelist.add(outofficeuser1);
        OutofOffice outofficeuser2 = new OutofOffice();
        outofficeuser2.userid = userlist[1].id;
        outofficeuser2.Message = 'hi';
        outofficeuser2.StartDate =system.today();
        outofficeuser2.EndDate = system.today();
        outofofficelist.add(outofficeuser2);
        insert outofofficelist;
        
        list<Omni_Service_Relationship_Mappings__c> omnisrmap = new list<Omni_Service_Relationship_Mappings__c>();
        Omni_Service_Relationship_Mappings__c omniserec = new Omni_Service_Relationship_Mappings__c();
        omniserec.Name = 'test';
        omniserec.Origin__c = 'MSLCNIMP';
        omniserec.Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c';
        omniserec.Sub_Type__c = 'Booking Confirmation Request';
        omniserec.Active__c = true;
        omnisrmap.add(omniserec);
        Omni_Service_Relationship_Mappings__c sr3 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCLEXP', Active__c = true, Origin__c = 'MSLCLEXP', Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c', Reason_for_Case__c = 'Amend Container Type');
        omnisrmap.add(sr3);
        insert omnisrmap;
        
        list<case> lstCases2 = new list<case>();
        lstCases2 = lstCases;
        TriggerExecutionController.skipAllTriggers(true);
        lstCases[1].sub_type__c = 'Amend Booking Details';
        lstCases[1].Reason_For_Case__c = 'Amend Container Type';
        lstCases[1].origin = 'MSLCLEXP';
        update lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        caseIds.add(lstCases[1].id);
        Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c,Reason_for_Case__c, Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name From Case Where Id in:caseIds]);
        
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, caseMap, null);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, null, null);
    }
    
    
    //To cover SR  scenario  
    public static testmethod void omniSkillBasedRouting10() {
        
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap2);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.GSC_Agent__c = userlist[0].id;
        maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Export';
        maerskLineCCA.Sub_Type__c ='Submit SI/BL/VC';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        list<OutofOffice> outofofficelist = new list<OutofOffice>();
        OutofOffice outofficeuser1 = new OutofOffice();
        outofficeuser1.userid = userlist[0].id;
        outofficeuser1.Message = 'hi';
        outofficeuser1.StartDate =system.today();
        outofficeuser1.EndDate = system.today();
        outofofficelist.add(outofficeuser1);
        OutofOffice outofficeuser2 = new OutofOffice();
        outofficeuser2.userid = userlist[1].id;
        outofficeuser2.Message = 'hi';
        outofficeuser2.StartDate =system.today();
        outofficeuser2.EndDate = system.today();
        outofofficelist.add(outofficeuser2);
        insert outofofficelist;
        
        
        list < Care_Relationship__c > carelist = new list < Care_Relationship__c > ();
        carelist.add(maerskLineCR);
        Map < Id, Care_Relationship__c > mapRelatedCareRelation = new Map < Id, Care_Relationship__c > ();
        mapRelatedCareRelation.put(maerskLineCR.id, maerskLineCR);
        
        list < Client_Case_Assignments__c > clientCaselist = new list < Client_Case_Assignments__c > ();
        clientCaselist.add(maerskLineCCA);
        Map < Id, Client_Case_Assignments__c > mapClientCaseAssignment = new Map <Id,Client_Case_Assignments__c > ();
        mapClientCaseAssignment.put(maerskLineCCA.id,maerskLineCCA);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLATEXP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.care_relationship__c = maerskLineCR.id;
        }
        
        insert lstCases;
        list<Omni_Service_Relationship_Mappings__c> omnisrmap = new list<Omni_Service_Relationship_Mappings__c>();
        Omni_Service_Relationship_Mappings__c omniserec = new Omni_Service_Relationship_Mappings__c();
        omniserec.Name = 'test';
        omniserec.Origin__c = 'MSLATEXP';
        omniserec.Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c';
        omniserec.Active__c = true;
        omnisrmap.add(omniserec);
        insert omnisrmap;  
        
        list<case> lstCases2 = new list<case>();
        lstCases2 = lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c, Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name From Case Where Id in:caseIds]);
        
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, caseMap, null);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, null, null);
        CaseOmniSkillBasedRouting.deletePSRForOmniEmail(caseIds,lstCases2);
    }
    
    //To cover Portal to Case Scenario with Origin
    public static testmethod void omniSkillBasedRouting11() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap5 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap5',Developer_Name__c ='SkillMap5', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCLIMP', Value__c = 'Case_MSL_Chile_Import', Skill_Id__c = '0C57E0000008WIU');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        omnimap.add(skillmap5);
        insert omnimap;
        
        Omni_Service_Relationship_Mappings__c sr1 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCNIMP', Active__c = true, Origin__c = 'MSLCNIMP', Preferred_Agent__c = 'GSC_Agent__c;GSC_Backup_Agent__c', Sub_Type__c = '');
        Omni_Service_Relationship_Mappings__c sr2 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCLIMP', Active__c = true, Origin__c = 'MSLCLIMP', Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c', Sub_Type__c = 'Amend Booking Details');
        List < Omni_Service_Relationship_Mappings__c > omnimap2 = new List < Omni_Service_Relationship_Mappings__c > ();
        omnimap2.add(sr1);
        omnimap2.add(sr2);
        insert omnimap2;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend Booking Details';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'Portal';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;    
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(true);  
        user einteinUser = [select id,name from user where name='Einstein User' LIMIT 1]; 
        map<id,care_relationship__c> careMap = new map<id,care_relationship__c>();
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import/Export';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.Care_Business_Partner__c = einteinUser.id;
        maerskLineCR.GSC_Agent__c = einteinUser.id;
        insert maerskLineCR;
        careMap.put(maerskLineCR.id,maerskLineCR);
        lstCases[0].Care_Relationship__c =  maerskLineCR.id;
        update lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, null,null, false, true, null, null);
    }
    
    //To cover SR scenario without OOO
    public static testmethod void omniSkillBasedRouting12() {
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap5 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap5',Developer_Name__c ='SkillMap5', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCLIMP', Value__c = 'Case_MSL_Chile_Import', Skill_Id__c = '0C57E0000008WIU');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        omnimap.add(skillmap5);
        insert omnimap;
        
        Omni_Service_Relationship_Mappings__c sr1 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCNIMP', Active__c = true, Origin__c = 'MSLCNIMP', Preferred_Agent__c = 'GSC_Agent__c;GSC_Backup_Agent__c', Sub_Type__c = '');
        Omni_Service_Relationship_Mappings__c sr2 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCLIMP', Active__c = true, Origin__c = 'MSLCLIMP', Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c', Sub_Type__c = 'Amend Booking Details');
        List < Omni_Service_Relationship_Mappings__c > omnimap2 = new List < Omni_Service_Relationship_Mappings__c > ();
        omnimap2.add(sr1);
        omnimap2.add(sr2);
        insert omnimap2;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Amend Booking Details';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'Portal';
            caseIterator.origin = '';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;    
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(true);  
        user einteinUser = [select id,name from user where name='Einstein User' LIMIT 1]; 
        map<id,care_relationship__c> careMap = new map<id,care_relationship__c>();
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import/Export';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.Care_Business_Partner__c = einteinUser.id;
        maerskLineCR.GSC_Agent__c = einteinUser.id;
        insert maerskLineCR;
        careMap.put(maerskLineCR.id,maerskLineCR);
        lstCases[0].Care_Relationship__c =  maerskLineCR.id;
        update lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, null,null, false, true, null, null);
    }
    
    //To cover out of office scenario
    public static testmethod void omniSkillBasedRouting13() {
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap2);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.GSC_Agent__c = userlist[0].id;
        maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Export';
        maerskLineCCA.Sub_Type__c ='Submit SI/BL/VC';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        list < Care_Relationship__c > carelist = new list < Care_Relationship__c > ();
        carelist.add(maerskLineCR);
        Map < Id, Care_Relationship__c > mapRelatedCareRelation = new Map < Id, Care_Relationship__c > ();
        mapRelatedCareRelation.put(maerskLineCR.id, maerskLineCR);
        
        list < Client_Case_Assignments__c > clientCaselist = new list < Client_Case_Assignments__c > ();
        clientCaselist.add(maerskLineCCA);
        Map < Id, Client_Case_Assignments__c > mapClientCaseAssignment = new Map <Id,Client_Case_Assignments__c > ();
        mapClientCaseAssignment.put(maerskLineCCA.id,maerskLineCCA);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLATEXP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.care_relationship__c = maerskLineCR.id;
        }
        
        insert lstCases;
        list<Omni_Service_Relationship_Mappings__c> omnisrmap = new list<Omni_Service_Relationship_Mappings__c>();
        Omni_Service_Relationship_Mappings__c omniserec = new Omni_Service_Relationship_Mappings__c();
        omniserec.Name = 'test';
        omniserec.Origin__c = 'MSLATEXP';
        omniserec.Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c';
        omniserec.Active__c = true;
        omnisrmap.add(omniserec);
        insert omnisrmap;  
        
        list<case> lstCases2 = new list<case>();
        lstCases2 = lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c, Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name From Case Where Id in:caseIds]);
        
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, caseMap, null);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, null, null);
        CaseOmniSkillBasedRouting.deletePSRForOmniEmail(caseIds,lstCases2);
    }
    
    //To cover twill scenarios
    public static testmethod void omniSkillBasedRouting14() {
        Skill s1 = [select id from skill where developername like 'GLO_Twill_CS'];
        String twillQueueSkill1 = s1.id;
        Skill s2 = [select id from skill where developername like 'General'];
        String twillQueueSkill2 = s2.id;
        Skill s3 = [select id from skill where developername like 'Cargo_Flow'];
        String twillQueueSkill3 = s3.id;
        Skill s4 = [select id from skill where developername like 'China'];
        String twillQueueSkill4 = s4.id;
        Skill s5 = [select id from skill where developername like 'Booking'];
        String twillQueueSkill5 = s5.id;
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLGLOBALMAERSKGO', Value__c = 'GLO_Twill_CS', Skill_Id__c = twillQueueSkill1);
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Case_Field__c = 'General', Origin__c = 'MSLGLOBALMAERSKGO', Value__c = 'General',Case_Field_2__c ='Case_country__c',Value_2__c = 'China', Skill_Id__c = twillQueueSkill2+';'+twillQueueSkill4);
        Case_OmniSkill_Mappings__c skillmap3 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap3',Developer_Name__c ='SkillMap3', Active__c = true, Case_Field__c = 'Cargo_Field__c', Origin__c = 'MSLGLOBALMAERSKGO', Value__c = 'Cargo Flow',Case_Field_2__c ='Case_country__c',Value_2__c = 'China',Skill_Id__c =twillQueueSkill3+';'+twillQueueSkill4);
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Case_Field__c = 'Type', Origin__c = 'MSLGLOBALMAERSKGO', Value__c = 'Booking',Case_Field_2__c ='Case_country__c',Value_2__c = 'China',Skill_Id__c =twillQueueSkill5+';'+twillQueueSkill4);
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap2);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.GSC_Agent__c = userlist[0].id;
        maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Export';
        maerskLineCCA.Sub_Type__c ='Submit SI/BL/VC';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        list < Care_Relationship__c > carelist = new list < Care_Relationship__c > ();
        carelist.add(maerskLineCR);
        Map < Id, Care_Relationship__c > mapRelatedCareRelation = new Map < Id, Care_Relationship__c > ();
        mapRelatedCareRelation.put(maerskLineCR.id, maerskLineCR);
        
        list < Client_Case_Assignments__c > clientCaselist = new list < Client_Case_Assignments__c > ();
        clientCaselist.add(maerskLineCCA);
        Map < Id, Client_Case_Assignments__c > mapClientCaseAssignment = new Map <Id,Client_Case_Assignments__c > ();
        mapClientCaseAssignment.put(maerskLineCCA.id,maerskLineCCA);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLGLOBALMAERSKGO';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'MaerskGo Action Required';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.delivery_channel__c = 'MaerskGo';
            caseIterator.care_relationship__c = maerskLineCR.id;
        }
        
        insert lstCases;
        System.debug('Sunil '+lstCases[0].cargo_flow__c);
        list<Omni_Service_Relationship_Mappings__c> omnisrmap = new list<Omni_Service_Relationship_Mappings__c>();
        Omni_Service_Relationship_Mappings__c omniserec = new Omni_Service_Relationship_Mappings__c();
        omniserec.Name = 'test';
        omniserec.Origin__c = 'MSLGLOBALMAERSKGO';
        omniserec.Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c';
        omniserec.Active__c = true;
        omnisrmap.add(omniserec);
        insert omnisrmap;  
        
        list<case> lstCases2 = new list<case>();
        lstCases2 = lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c, Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name From Case Where Id in:caseIds]);
        Test.startTest();
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, caseMap, null);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, null, null);
        CaseOmniSkillBasedRouting.deletePSRForOmniEmail(caseIds,lstCases2);
        Test.stopTest();
    }
    
    
    //To cover SR sub type scenario  
    public static testmethod void omniSkillBasedRouting15() {
        
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap2);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.GSC_Agent__c = userlist[0].id;
        maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Export';
        maerskLineCCA.Sub_Type__c ='Submit SI/BL/VC';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        list < Care_Relationship__c > carelist = new list < Care_Relationship__c > ();
        carelist.add(maerskLineCR);
        Map < Id, Care_Relationship__c > mapRelatedCareRelation = new Map < Id, Care_Relationship__c > ();
        mapRelatedCareRelation.put(maerskLineCR.id, maerskLineCR);
        
        list < Client_Case_Assignments__c > clientCaselist = new list < Client_Case_Assignments__c > ();
        clientCaselist.add(maerskLineCCA);
        Map < Id, Client_Case_Assignments__c > mapClientCaseAssignment = new Map <Id,Client_Case_Assignments__c > ();
        mapClientCaseAssignment.put(maerskLineCCA.id,maerskLineCCA);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.care_relationship__c = maerskLineCR.id;
        }
        
        insert lstCases;
        
        list<OutofOffice> outofofficelist = new list<OutofOffice>();
        OutofOffice outofficeuser1 = new OutofOffice();
        outofficeuser1.userid = userlist[0].id;
        outofficeuser1.Message = 'hi';
        outofficeuser1.StartDate =system.today();
        outofficeuser1.EndDate = system.today();
        outofofficelist.add(outofficeuser1);
        OutofOffice outofficeuser2 = new OutofOffice();
        outofficeuser2.userid = userlist[1].id;
        outofficeuser2.Message = 'hi';
        outofficeuser2.StartDate =system.today();
        outofficeuser2.EndDate = system.today();
        outofofficelist.add(outofficeuser2);
        insert outofofficelist;
        
        list<Omni_Service_Relationship_Mappings__c> omnisrmap = new list<Omni_Service_Relationship_Mappings__c>();
        Omni_Service_Relationship_Mappings__c omniserec = new Omni_Service_Relationship_Mappings__c();
        omniserec.Name = 'test';
        omniserec.Origin__c = 'MSLCNIMP';
        omniserec.Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c';
        omniserec.Active__c = true;
        omnisrmap.add(omniserec);
        insert omnisrmap;
        
        list<case> lstCases2 = new list<case>();
        lstCases2 = lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c, Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name From Case Where Id in:caseIds]);
        
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, caseMap, null);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, null, null);
    }
    
    //To cover CCA sub type scenario  
    public static testmethod void omniSkillBasedRouting16() {
        
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap1);
        omnimap.add(skillmap2);
        insert omnimap;
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000007951';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.GSC_Agent__c = userlist[0].id;
        maerskLineCR.Care_Business_Partner__c = userlist[1].id;
        insert maerskLineCR;
        
        Client_Case_Assignments__c maerskLineCCA = new Client_Case_Assignments__c();
        maerskLineCCA.Account__c = acc.id;
        maerskLineCCA.Direction__c = 'Import';
        maerskLineCCA.Sub_Type__c ='Booking Confirmation Request';
        maerskLineCCA.Active__c= true;
        maerskLineCCA.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCCA.Back_up_Dedicated_Agent__c = userlist[0].id;
        maerskLineCCA.Dedicated_Agent__c = userlist[1].id;
        insert maerskLineCCA;
        
        list < Care_Relationship__c > carelist = new list < Care_Relationship__c > ();
        carelist.add(maerskLineCR);
        Map < Id, Care_Relationship__c > mapRelatedCareRelation = new Map < Id, Care_Relationship__c > ();
        mapRelatedCareRelation.put(maerskLineCR.id, maerskLineCR);
        
        list < Client_Case_Assignments__c > clientCaselist = new list < Client_Case_Assignments__c > ();
        clientCaselist.add(maerskLineCCA);
        Map < Id, Client_Case_Assignments__c > mapClientCaseAssignment = new Map <Id,Client_Case_Assignments__c > ();
        mapClientCaseAssignment.put(maerskLineCCA.id,maerskLineCCA);
        
        for (Case caseIterator: lstCases) {
            caseIterator.Direction__c = 'Import';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Booking';
            caseIterator.On_Behalf_Account__c=acc.id;
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Booking Confirmation Request';
            //caseIterator.Reason_For_Case__c = 'Container Status Enquiry';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.origin = 'MSLCNIMP';
            caseIterator.contactid = conInstance.id;
            caseIterator.Country__c = BDAGeographyData_Test.countryCH.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT';
            caseIterator.care_relationship__c = maerskLineCR.id;
        }
        
        insert lstCases;
        
        list<OutofOffice> outofofficelist = new list<OutofOffice>();
        OutofOffice outofficeuser1 = new OutofOffice();
        outofficeuser1.userid = userlist[0].id;
        outofficeuser1.Message = 'hi';
        outofficeuser1.StartDate =system.today();
        outofficeuser1.EndDate = system.today();
        outofficeuser1.IsEnabled = true;
        outofofficelist.add(outofficeuser1);
        OutofOffice outofficeuser2 = new OutofOffice();
        outofficeuser2.userid = userlist[1].id;
        outofficeuser2.Message = 'hi';
        outofficeuser2.StartDate =system.today();
        outofficeuser2.EndDate = system.today();
        outofficeuser2.IsEnabled = true;
        outofofficelist.add(outofficeuser2);
        insert outofofficelist;
        
        list<case> lstCases2 = new list<case>();
        lstCases2 = lstCases;
        
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, CaseNumber, OwnerId, Subject, Description, Origin, Status, MLL__c, Cargo_Classification__c, Type, Sub_Type__c, Case_Channel__c, Delivery_Channel__c, Case_Country__c, Shipment_Number__c, Care_Relationship__c, Omni_Skill_Type__c, Value_Proposition__c, Product__c, Country__c,country__r.name, Account.Name, Account.SCV_Code__c,Care_Relationship_Business_Partner__c,Backup_Agent__c,Care_Relationship_GSC_Agent__c,Owner.Name,On_Behalf_Account__c From Case Where Id in:caseIds]);
        
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, caseMap, null);
        CaseOmniSkillBasedRouting.defineCaseSkillMap(lstCases, mapRelatedCareRelation,mapClientCaseAssignment, false, false, null, null);
    }
    
} //End of class