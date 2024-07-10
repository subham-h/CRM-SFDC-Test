/**
 * Description  : This Test Class is designed to Cover class which updates NBA Reporting fields
 * 
 * Version        Date               Owner                                      Description
 *******************************************************************************************************************
 * v1.0           02/05/2022         sunil.bs@maersk.com                        Test Class is designed to Cover class which updates NBA Reporting fields
 * v2.0           27/06/2022         Ronnie@SF                                  SPI-100: Replaced brand hardcoding
 *-------------------------------------------------------------------------------------------------------------------
 */
@istest
public class caseNBAReporting_Test {

    static testmethod void caseNBAReporting1(){
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        //list<Case> mylstCases2 = new list<Case>();
        //mylstCases2 = lstCases;
        
        for(Case caseIterator : lstCases) {      
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Cargo/Container'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.sub_type__c = 'Container Status';
            caseIterator.Reason_For_Case__c = 'Container Maritime Tracking Request';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.contactid = conInstance.id;
        }  
        
        List<Recommendation> reclist = new List<Recommendation>();
        Recommendation inputeRec = new Recommendation(name = 'Cargo Container (Container Tracking)', ActionReference = 'Run_NBA_Recommendation_Action', Description = 'Cargo Desc', AcceptanceLabel = 'A', RejectionLabel = 'R');
        reclist.add(inputeRec);
        insert reclist ;
                
        test.startTest();        
        insert lstCases;
        
        caseNBAReporting.NBAReportingInputs inputereq= new caseNBAReporting.NBAReportingInputs();
        list<caseNBAReporting.NBAReportingInputs> inputereqlist = new list<caseNBAReporting.NBAReportingInputs>();
        inputereq.caseId = lstCases[0].id;
        inputereq.recommendationlist = reclist ;
        inputereqlist.add(inputereq);
        
        caseNBAReporting.NBAReportingUpdate(inputereqlist);
        
        //To cover exception error scenario
        list<caseNBAReporting.NBAReportingInputs> inputereqlist2 = new list<caseNBAReporting.NBAReportingInputs>();
        caseNBAReporting.NBAReportingUpdate( inputereqlist2);
        
        test.stopTest();
    }
     
}