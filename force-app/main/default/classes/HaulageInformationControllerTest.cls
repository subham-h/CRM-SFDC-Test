/**
 * Test class for HaulageInformationController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      28/06/2022   Ronnie@SF               SPI-100       Removed brand operator code hardcoding
 */

@isTest
public class HaulageInformationControllerTest {
    
    @isTest static void testGetImportHaulageInformation(){
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HaulageServiceHttpCalloutMock(true)); 
        Object import_response = HaulageInformationController.GetHaulageInformation('910415856', '', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());
    }
    
    @isTest static void testGetExportHaulageInformation(){
        Test.setMock(HttpCalloutMock.class, new HaulageServiceHttpCalloutMock(true)); 
        Object export_response = HaulageInformationController.GetHaulageInformation('', '910415856', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());    
    }
  
    @isTest static void testUpdateMerchantHaulage(){   
        Test.setMock(HttpCalloutMock.class, new MerchantHaulageServiceHttpCalloutMock());
        String body = '{"emptyContainerPickupDepotDetails":{"geoAreaId":"0FW19NDUZ2NI7","geoSiteId":"0BRZHC3NCZFLD","releaseFromDateTime":"2021-06-21T09:42:00","releaseReference":"Reference text","validToDateTime":"2021-08-29T11:42:00"},"fullContainerReturnDepotDetails":{"geoAreaId":"0G5RI2I2X2U8P","geoSiteId":"3UNG4KQFPKQLN","returnToDateTime":"2022-02-12T12:16:49"}}';
        String res = (String)HaulageInformationController.exportMerchantHaulage(body, 'S1SIT1RJP', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), '181124');        
        System.assertEquals('200', res);
    }
    
    @isTest static void testAddMerchantHaulage(){
        Test.setMock(HttpCalloutMock.class, new MerchantHaulageServiceHttpCalloutMock());
        String body = '{"containers":[{"equipmentAssignmentId":"HY8RGJZ9B1HIB"}],"emptyContainerPickupDepotDetails":{"geoSiteId":"0O3IA2CNGLZ53","validToDateTime":"2021-11-26T09:16:00","releaseReference":"testref","releaseFromDateTime":"2021-11-02T09:16:00"},"fullContainerReturnDepotDetails":{"geoSiteId":"0BRZHC3NCZFLD","returnToDateTime":"2021-11-26T09:16:00"},"haulageOrderRecipients":[]}';
        HaulageInformationController.HaulageWrapper res = (HaulageInformationController.HaulageWrapper)HaulageInformationController.addExportMerchantHaulage(body, '507351064', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());        
        System.assertEquals('227388', res.haulNumber);
    }
    
    @isTest static void testUpdateReceiverOnMerchantHaulage(){
        Test.setMock(HttpCalloutMock.class, new MerchantHaulageServiceHttpCalloutMock());
        String body = '{"haulageOrderRecipients":[{"receivingSystem":"CDS","recipientAttention":"","selectedMOC":{"name":"System"}}]}';
        Object res = HaulageInformationController.patchExportMerchantHaulage(body, '507351064', '227388', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());        
        System.assertEquals('200', res);
    }

}