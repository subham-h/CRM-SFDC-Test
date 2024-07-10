@isTest(seeAllData=true)
public class AgentWorkFieldPopulator_Test {
    
    @isTest
    static void updateCaseAssignmentIndicatortest(){
        Case_OmniSkill_Mappings__c skillmap4 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap4',Developer_Name__c ='SkillMap4', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCNIMP', Value__c = 'Case_MSL_China_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Case_Field__c = 'Unassigned', Origin__c = 'Global', Value__c = 'General', Skill_Id__c = '0C52o000000L2nY');
        Case_OmniSkill_Mappings__c skillmap5 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap5',Developer_Name__c ='SkillMap5', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLCLIMP', Value__c = 'Case_MSL_Chile_Import', Skill_Id__c = '0C57E0000008WIU');
        
        List < Case_OmniSkill_Mappings__c > omnimap = new List < Case_OmniSkill_Mappings__c > ();
        omnimap.add(skillmap4);
        omnimap.add(skillmap1);
        omnimap.add(skillmap5);
        
        Omni_Service_Relationship_Mappings__c sr1 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCNIMP', Active__c = true, Origin__c = 'MSLCNIMP', Preferred_Agent__c = 'GSC_Agent__c', Sub_Type__c = '');
        Omni_Service_Relationship_Mappings__c sr2 = new Omni_Service_Relationship_Mappings__c(Name = 'MSLCLIMP', Active__c = true, Origin__c = 'MSLCLIMP', Preferred_Agent__c = 'Care_Business_Partner__c;Frontline_Backup__c', Sub_Type__c = 'Amend Booking Details');
        List < Omni_Service_Relationship_Mappings__c > omnimap2 = new List < Omni_Service_Relationship_Mappings__c > ();
        omnimap2.add(sr1);
        omnimap2.add(sr2);
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.bCreate = false;
        ContactData_Test.createCustomerContacts();
        List<Contact> conList = ContactData_Test.lstContacts;
        conList[0].Phone = '+1 1231231254';
        insert conList;
        Contact conInstance = conList[0];
        
        list < user > userlist = [select id, name from user where name like '%test%' LIMIT 2];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.conInstance = conInstance;
        list < Case > lstCases = new list < Case > ();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        Geography__c geo = [Select Id From Geography__c Where Name = 'China' AND Type_Of_Location__c = 'Country' LIMIT 1];
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
            caseIterator.Country__c = geo.Id;
            caseIterator.City__c = BDAGeographyData_Test.cityBeijing.id;
            caseIterator.ownerid = userlist[0].Id;
            caseIterator.Subject = 'TO BE UPDATED BY CHAT AGENT 224069341';
            caseIterator.description = 'TO BE UPDATED BY CHAT AGENT 224069341';
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '10000008888';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;    
        TriggerExecutionController.skipAllTriggers(false);
        
        insert lstCases;
        TriggerExecutionController.skipAllTriggers(true);  
        
        UserServicePresence usrSerPresence = [SELECT Id,ConfiguredCapacity, UserId FROM UserServicePresence Where IsCurrentState = TRUE AND ServicePresenceStatus.MasterLabel = 'Case Online' LIMIT 1];
        User RunUser2 = [Select id from user where Id =: usrSerPresence.UserId LIMIT 1];
        
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import/Export';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = geo.Id;
        maerskLineCR.Care_Business_Partner__c = '0052o000009qrDlAAI';
        maerskLineCR.GSC_Agent__c = '0052o000009qrDlAAI';
        insert maerskLineCR;
        lstCases[0].OwnerId = RunUser2.Id;
        lstCases[0].Care_Relationship__c =  maerskLineCR.id;
        update lstCases;
        TriggerExecutionController.skipAllTriggers(false);
        Map < String, String > headers = new Map < String, String > ();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"Results": [{"Case_number": "' + lstCases[0].CaseNumber + '", "Class_Probability": {"Amend Booking Details": 0.003354905638843775, "Amend SI/BL/VC": 0.0026299203746020794, "Booking Confirmation Request": 0.003429069649428129, "COD DIT Transhipment": 4.076581899425946e-05, "Cancel Booking": 0.00045322056394070387, "Cargo Restrictions/Support Enquiry": 0.001217402401380241, "Certificate/Letter": 0.00018847470346372575, "Container Damaged": 9.735977073432878e-05, "Container Longstanding": 0.00012844604498241097, "Container Status": 0.004746004473417997, "Container Tracking Information": 0.017384301871061325, "Credit / Statement": 0.0006784289726056159, "Customer Registration/User ID/Password": 0.03919510543346405, "Cut-off/Deadline Request": 0.00026194844394922256, "Delivery Order/Container Release": 0.0162273608148098, "Demurrage / Detention": 0.009068586863577366, "Depot / Terminal": 0.003147900803014636, "Invoice / Payer Party": 0.3668147325515747, "Mandatory Documents": 5.518203033716418e-05, "Manifest / Customs": 0.0002456871443428099, "New Booking Request": 0.000670662266202271, "Onboarding/How To": 0.49637532234191895, "Payment": 0.003403052920475602, "Rates/Quotes": 0.003337888978421688, "Release SI/BL/VC": 0.009786400012671947, "Request Arrival Notice": 0.0026085772551596165, "Request SI/BL/VC": 0.0029985548462718725, "Sales coordination activities": 0.0003184553643222898, "Schedule/Vessel/Container/Space Availability": 0.00011187034397153184, "Spam/Case Created in Error": 0.006153902038931847, "Submit SI/BL/VC": 0.003116634441539645, "Verified Gross Mass (VGM)": 0.00028399977600201964, "Website Error": 0.0014697937294840813}, "Prediction": "Onboarding/How To", "Error_Reason": ""}]}';
        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Set < Id > caseIds = new Set < Id > ();
        caseIds.add(lstCases[0].id);
        PendingServiceRouting psr = new PendingServiceRouting();
        psr.CapacityWeight=1;
        psr.IsReadyForRouting=true;
        psr.RoutingModel='LeastActive';
        psr.RoutingPriority=1;
        psr.RoutingType='SkillsBased';
        psr.ServiceChannelId= '0N92o0000004KM3CAM';
        psr.WorkItemId=lstCases[0].id;
        psr.IsPreferredUserRequired = TRUE;
        psr.PreferredUserId = RunUser2.Id;
        insert psr;
        
        System.runas(RunUser2){
            AgentWork aw = new AgentWork();
            aw.ServiceChannelId= '0N92o0000004KM3CAM';
            aw.UserId=RunUser2.Id;
            aw.WorkItemid=lstCases[0].id;
            insert aw;
        }
    }
    
}