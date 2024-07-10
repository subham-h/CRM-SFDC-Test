/**
 * Description  : Perform callout to RKEM to get the Schedule details
 * 
 * Version       Date                Owner                                       Description
 *******************************************************************************************************************
 * v1.0          22/10/2019          nivedita.shukla@maersk.com                  Perform callout to RKEM to get the Schedule details from Bot
 * v2.0          12/11/2019          Sreya@Maersk                                Test scenario added for invalid date range for ETD 
 * v3.0          27/06/2022          Ronnie@SF                                   SPI-100: Removed brand hardcoding
 * -------------------------------------------------------------------------------------------------------------------
 */


@isTest
public class AO_ScheduleEnquiryControllerTest {
    
    @isTest static void testGetScheduledEnquiry() {
                
        //Calling the getScheduledEnquiry method from AO_ScheduleEnquiryController by passing the parameters.
        AO_ScheduleEnquiryController.ScheduledInput sc= new AO_ScheduleEnquiryController.ScheduledInput();
        sc.porGeoId='2XXSSRXSR5JTL';
        sc.podGeoId ='2WB42QQDVXC3J';
        sc.operator = BrandUtilities.MAERSK;
        sc.haulageCombination='CY/SD';
        sc.botLanguage='Chinese';
        
        String date1 =system.today().format();
        String dat= date1.split('/')[0];
        String mon=date1.split('/')[1];
        string year=date1.split('/')[2];
        String etdDate=  dat+'-'+mon+'-'+year;
        sc.etdDate=etdDate;
        
        
        System.debug(sc.etdDate);
        
        System.debug('************ ' + system.today().format());
        
        List<AO_ScheduleEnquiryController.ScheduledInput> listScheduled = new List<AO_ScheduleEnquiryController.ScheduledInput>();
        listScheduled.add(sc);
        
        string invalidDate = string.valueOf((system.today() - 95));
        string[] arrInvalidDt = invalidDate.split('-');
        string strInvalidDt = arrInvalidDt[2] + '-' + arrInvalidDt[1] + '-' + arrInvalidDt[0];
        
        AO_ScheduleEnquiryController.ScheduledInput sc1= new AO_ScheduleEnquiryController.ScheduledInput();
        sc1.porGeoId = '2XXSSRXSR5JTL';
        sc1.podGeoId = '2WB42QQDVXC3J';
        sc1.operator = BrandUtilities.MAERSK;
        sc1.haulageCombination = 'CY/SD';
        sc1.etdDate  = strInvalidDt;
        sc1.botLanguage='English';
        
        List<AO_ScheduleEnquiryController.ScheduledInput> listScheduled1 = new List<AO_ScheduleEnquiryController.ScheduledInput>();
        listScheduled1.add(sc1);
        
        
        // for English langauge
        AO_ScheduleEnquiryController.ScheduledInput sc2= new AO_ScheduleEnquiryController.ScheduledInput();
        List<AO_ScheduleEnquiryController.ScheduledInput> listScheduled2 = new List<AO_ScheduleEnquiryController.ScheduledInput>();
        sc2.porGeoId='2XXSSRXSR5JTL';
        sc2.podGeoId ='2WB42QQDVXC3J';
        sc2.operator = BrandUtilities.MAERSK;
        sc2.haulageCombination='CY/SD';
        sc2.botLanguage='English';
        sc2.etdDate=etdDate;
        listScheduled2.add(sc2);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMockSchedules());
        List<AO_ScheduleEnquiryController.ScheduledInfo> lstTrack = AO_ScheduleEnquiryController.getScheduledEnquiry(listScheduled);
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMockSchedules());
        
        System.debug('lstTrack => '+lstTrack);
        List<AO_ScheduleEnquiryController.ScheduledInfo> lstTrack1 = AO_ScheduleEnquiryController.getScheduledEnquiry(listScheduled1);
        
        System.debug('lstTrack1 => '+lstTrack1);
        List<AO_ScheduleEnquiryController.ScheduledInfo> lstTrack2 = AO_ScheduleEnquiryController.getScheduledEnquiry(listScheduled2);
        test.stopTest();
        
        System.debug('lstTrack[0].strLatestSchduled '+lstTrack[0].strLatestSchduled);
        System.assertEquals(String.isNotBlank(lstTrack[0].strLatestSchduled),true);
        System.assertEquals(lstTrack1[0].ScheduleEnquiryDateRangeInvalid, 'true');
    }   
}