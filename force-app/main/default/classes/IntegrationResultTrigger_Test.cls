/*
* Created By   : Shahanawaz@Maersk
* Purpose  : Utility test class for creating Case related data. 
*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      #SC-8789    04-Oct-2023 	Shahanawaz@Maersk       Created
* 2.0	   #SC-8631	   25-Apr-2024	Kiran@Maersk			Auto Case Assignment - Ocean - based on Cargo types - Reefer, OOG, Break Bulk
*/
@isTest(SeeAllData=false)
public class IntegrationResultTrigger_Test {
    
    @testSetup
    public static void setup(){
        List<Shipment__c> shipmentList = new List<Shipment__c>();
        Shipment__c ship1 = TestBusinessHelper.createShipment('224069341', false);
        ship1.Id = null;
        shipmentList.add(ship1);
        
        Shipment__c ship2 = TestBusinessHelper.createShipment('589565490', false);
        ship2.Id = null;
        shipmentList.add(ship2);
        
        insert shipmentList;
        
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
    }
    
    @isTest
    public static void testCaseShipmentSummaryAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"shipmentSummary":{"header":{"businessUnitId":"1089","businessUnitCode":"CNSGHMSL1","bookingcountryGeoArea":"China","bookingcountryCode":"CN","shipmentVersionId":"JKUG9MXHE2CLB","businessUnit":"Maersk China Shipping (Shanghai)","bookedByCustomerName":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","contactName":"CHEN QI","contactNumber":"86-55668366","serviceModeExportName":"CY","serviceModeImportName":"CY","serviceMode":"CY/CY","placeOfReceiptId":"9FHJRNXHE2P3B","placeOfReceipt":"Ningbo, Zhejiang, China","placeOfDeliveryId":"SBUJRNXHE2P3B","placeOfDelivery":"Bekasi, Indonesia","partialShipment":"true","isPricedByAFLS":"true","isFMCRegulated":"N","isFirstOPSOUTClosed":"true","priceCalcBaseDateLocal":"2023-11-26","shipmentInstanceId":"PVQG9MXHE2CLB","shipmentClassId":"3","shipmentClass":"Ordinary Transport Order","shipmentStatusId":"1","shipmentStatus":"Active","isReefer":"false","isDangerous":"true","isOOG":"false","lastchangedUserId":"AA-CRBIMP02","lastChangedTimestamp":"2023-12-05T06:28:11.392164","isShortShipped":"false","isImportShipment":"false","isSpotBooking":"false","operator":"MSL","customerCommodity":"","priceOwner":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","bookedByScvCustomerCode":"40602926822","priceOwnerScvCustomerCode":"40602926822","shipperScvCustomerCode":"40600739987","consigneeScvCustomerCode":"41100106641","shipperName":"MILLENNIUM LOGISTICS (SHENZHEN) LTD","mepcTradeLaneCode":"FEA/FEA(MCC)"},"exportEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"2023-11-23T01:00:00","hsCommodityDescription":["Sacks and bags, plastic"],"containerNumber":"MRKU9986377","haulageSiteName":"NIngbo Beilun Donghwa Cont. Transp.","haulageSiteCityName":"NIngbo Beilun Donghwa Cont. Transp.","haulageReference":"","haulageSent":"true","haulageNumber":"209311577","isOnImportShipment":"false"}],"importEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"","tpDocNumbers":["233458266"],"containerNumber":"MRKU9986377","haulageSiteName":"","haulageSiteCityName":"","haulageReference":"","haulageSent":"false","haulageNumber":"","isOnImportShipment":"false"}],"equipmentTrackings":[{"containerNo":"MRKU9986377","containerSizeAndType":"20 DRY","cargoWeightKgs":"5419","cargoWeightLbs":"11947","carrier":"QINGDAO STAR","voyageNo":"347S","slotNo":"070512","status":"NA","location":"Beilun container terminal, Phase 2","activity":"LOAD","activityDateTime":"2023-11-28T14:23:00","nextCarrier":"","nextVoyageNo":"","carrierSeal":"CN5017174","shipperSeal":"","customsSeal":"","vetSeal":"","loadReference":"","tcn":""}],"mainLocations":{"receiptLocation":{"routePointId":"9FHJRNXHE2P3B","geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","state":"Zhejiang","stateId":"398QCI744592C","cyTerminalFlag":"true","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"deliveryLocation":{"routePointId":"SBUJRNXHE2P3B","geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","state":"","stateId":"","cyTerminalFlag":"true","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"firstLoadPort":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","geoSiteId":"15W6NU75ECEPB","name":"Beilun container terminal, Phase 2","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"finalDischargePort":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","geoSiteId":"DUYEDVI26TJG4","name":"PT New Priok Container Terminal One","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"}},"transportRoutePlan":[{"origin":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"destination":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"W","vesselName":"QINGDAO STAR(MH)","vesselVoyage":"347S","vesselVoyageArrive":"347S","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-11-28T21:00:00","destinationArrivalDate":"2023-12-07T19:00:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"Y","vesselCode":"ET7","service":"IA1","iflrCode":"C","mepctransportMode":"MVS"},{"origin":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"destination":{"geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"L","vesselName":"","vesselVoyage":"","vesselVoyageArrive":"","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-12-08T09:15:00","destinationArrivalDate":"2023-12-08T21:15:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"N","vesselCode":"","service":"","iflrCode":"","mepctransportMode":"TRK"}],"equipmentAndCargoSummary":{"cargoLines":[{"cargoId":"Q2RDQNXHE2P3B","hsCommodityCode":"003208","hsCommodityDescription":"Sacks and bags, plastic","commodityGroup":"320","cargoWeight":"5419.400000","cargoWeightUnit":"KGS","cargoVolume":"26.994000","cargoVolumeUnit":"CBM","cargoPackageId":"YJ2DQNXHE2P3B","cargoPackageName":"CARTONS","quantity":"246","dangerous":"false","cargoSequenceNumber":"1","customerSpecifiedHSCode":"420212","transportDocumentNumber":"233458266","isRelatedTPDocIssued":"true","hscodeSpecifiedByCustomer":"false","shipmentVersionPriceId":"JKUG9MXHE2CLB"}],"equipments":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerTypeId":"4","containerType":"DRY","containerSize":"20","containerHeight":"8 6","bookedWeight":"18000.000000","bookedWeightUnit":"KGS","hangerBeams":[{"instanceId":"RCPDQNXHE2P3B","containerPropKey":"5TYK9EV3XRAAA"},{"instanceId":"ULLDQNXHE2P3B","containerPropKey":"1UBN9EV3XRAAA"}],"shippersOwnFlag":"false","containerNo":"MRKU9986377","linkedContainerNumber":"MRKU9986377","preAssignedContainerNumber":"MRKU9986377","proratingType":"","isRelatedToDocCargoStuffing":"false","sequenceNr":"1"}],"equipmentStuffings":[{"equipmentStuffingId":"EF7DQNXHE2P3B","equipmentAssignmentId":"AAIDQNXHE2P3B","cargoId":"Q2RDQNXHE2P3B","stuffingWeight":"5419.400000","stuffingWeightUnits":"KGS","stuffingVolume":"26.994000","stuffingVolumeUnits":"CBM","stuffingQuantity":"246.000000","stuffingConfirmed":"true","isRelatedToDocCargo":"false"}]},"shipmentReferences":[{"shipmentPropertyId":"K5GETLATE2LYB","propertyTypeId":"1022","shipmentVersion":"JKUG9MXHE2CLB","levelId":"302","propertyTypeName":"Carrier Seal","referencedObject":"AAIDQNXHE2P3B","valueString":"CN5017174","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"W00PRNXHE2P3B","propertyTypeId":"O9KTVXY3UZ8JB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"201","propertyTypeName":"6 digit HS code","referencedObject":"Q2RDQNXHE2P3B","valueString":"420212","direction":"Place of Receipt","categoryId":"1","country":"China","countryId":"1HDVVRK6OM45A","valueName":"","dataDomainId":"2","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"SNKQRNXHE2P3B","propertyTypeId":"1XLFR50OPZELB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Tax reference - Indonesia","referencedObject":"PVQG9MXHE2CLB","valueString":"017211236054000","direction":"Final Vessel Discharge","categoryId":"1","country":"Indonesia","countryId":"32L6DQM2PYU7Y","valueName":"","dataDomainId":"3","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"XKMHSNXHE2P3B","propertyTypeId":"2100000000068","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Short Sea","referencedObject":"PVQG9MXHE2CLB","valueString":"","categoryId":"2","valueName":"","dataDomainId":"1","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"LSPPSNXHE2P3B","propertyTypeId":"1198","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Reference Number","referencedObject":"PVQG9MXHE2CLB","valueString":"3290ece9-e5c7-49a4-8c8e-83cb0a55a928","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"false"},{"shipmentPropertyId":"UFCRSNXHE2P3B","propertyTypeId":"2100000000066","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Consumer","referencedObject":"PVQG9MXHE2CLB","valueString":"web","categoryId":"2","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"NVXE35IWE2K3B","propertyTypeId":"1038","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Shipment Reference number","referencedObject":"PVQG9MXHE2CLB","valueString":"233458266:","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"}]}}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Test.stopTest();        
        
        Case newCase = [Select Id,Cargo_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Dangerous Cargo', newCase.Cargo_Type__c);
    }
    
    @isTest
    public static void testCaseShipmentSummaryReeferAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"shipmentSummary":{"header":{"businessUnitId":"1089","businessUnitCode":"CNSGHMSL1","bookingcountryGeoArea":"China","bookingcountryCode":"CN","shipmentVersionId":"JKUG9MXHE2CLB","businessUnit":"Maersk China Shipping (Shanghai)","bookedByCustomerName":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","contactName":"CHEN QI","contactNumber":"86-55668366","serviceModeExportName":"CY","serviceModeImportName":"CY","serviceMode":"CY/CY","placeOfReceiptId":"9FHJRNXHE2P3B","placeOfReceipt":"Ningbo, Zhejiang, China","placeOfDeliveryId":"SBUJRNXHE2P3B","placeOfDelivery":"Bekasi, Indonesia","partialShipment":"true","isPricedByAFLS":"true","isFMCRegulated":"N","isFirstOPSOUTClosed":"true","priceCalcBaseDateLocal":"2023-11-26","shipmentInstanceId":"PVQG9MXHE2CLB","shipmentClassId":"3","shipmentClass":"Ordinary Transport Order","shipmentStatusId":"1","shipmentStatus":"Active","isReefer":"true","isDangerous":"false","isOOG":"false","lastchangedUserId":"AA-CRBIMP02","lastChangedTimestamp":"2023-12-05T06:28:11.392164","isShortShipped":"false","isImportShipment":"false","isSpotBooking":"false","operator":"MSL","customerCommodity":"","priceOwner":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","bookedByScvCustomerCode":"40602926822","priceOwnerScvCustomerCode":"40602926822","shipperScvCustomerCode":"40600739987","consigneeScvCustomerCode":"41100106641","shipperName":"MILLENNIUM LOGISTICS (SHENZHEN) LTD","mepcTradeLaneCode":"FEA/FEA(MCC)"},"exportEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"2023-11-23T01:00:00","hsCommodityDescription":["Sacks and bags, plastic"],"containerNumber":"MRKU9986377","haulageSiteName":"NIngbo Beilun Donghwa Cont. Transp.","haulageSiteCityName":"NIngbo Beilun Donghwa Cont. Transp.","haulageReference":"","haulageSent":"true","haulageNumber":"209311577","isOnImportShipment":"false"}],"importEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"","tpDocNumbers":["233458266"],"containerNumber":"MRKU9986377","haulageSiteName":"","haulageSiteCityName":"","haulageReference":"","haulageSent":"false","haulageNumber":"","isOnImportShipment":"false"}],"equipmentTrackings":[{"containerNo":"MRKU9986377","containerSizeAndType":"20 DRY","cargoWeightKgs":"5419","cargoWeightLbs":"11947","carrier":"QINGDAO STAR","voyageNo":"347S","slotNo":"070512","status":"NA","location":"Beilun container terminal, Phase 2","activity":"LOAD","activityDateTime":"2023-11-28T14:23:00","nextCarrier":"","nextVoyageNo":"","carrierSeal":"CN5017174","shipperSeal":"","customsSeal":"","vetSeal":"","loadReference":"","tcn":""}],"mainLocations":{"receiptLocation":{"routePointId":"9FHJRNXHE2P3B","geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","state":"Zhejiang","stateId":"398QCI744592C","cyTerminalFlag":"true","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"deliveryLocation":{"routePointId":"SBUJRNXHE2P3B","geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","state":"","stateId":"","cyTerminalFlag":"true","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"firstLoadPort":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","geoSiteId":"15W6NU75ECEPB","name":"Beilun container terminal, Phase 2","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"finalDischargePort":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","geoSiteId":"DUYEDVI26TJG4","name":"PT New Priok Container Terminal One","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"}},"transportRoutePlan":[{"origin":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"destination":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"W","vesselName":"QINGDAO STAR(MH)","vesselVoyage":"347S","vesselVoyageArrive":"347S","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-11-28T21:00:00","destinationArrivalDate":"2023-12-07T19:00:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"Y","vesselCode":"ET7","service":"IA1","iflrCode":"C","mepctransportMode":"MVS"},{"origin":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"destination":{"geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"L","vesselName":"","vesselVoyage":"","vesselVoyageArrive":"","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-12-08T09:15:00","destinationArrivalDate":"2023-12-08T21:15:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"N","vesselCode":"","service":"","iflrCode":"","mepctransportMode":"TRK"}],"equipmentAndCargoSummary":{"cargoLines":[{"cargoId":"Q2RDQNXHE2P3B","hsCommodityCode":"003208","hsCommodityDescription":"Sacks and bags, plastic","commodityGroup":"320","cargoWeight":"5419.400000","cargoWeightUnit":"KGS","cargoVolume":"26.994000","cargoVolumeUnit":"CBM","cargoPackageId":"YJ2DQNXHE2P3B","cargoPackageName":"CARTONS","quantity":"246","dangerous":"false","cargoSequenceNumber":"1","customerSpecifiedHSCode":"420212","transportDocumentNumber":"233458266","isRelatedTPDocIssued":"true","hscodeSpecifiedByCustomer":"false","shipmentVersionPriceId":"JKUG9MXHE2CLB"}],"equipments":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerTypeId":"4","containerType":"DRY","containerSize":"20","containerHeight":"8 6","bookedWeight":"18000.000000","bookedWeightUnit":"KGS","hangerBeams":[{"instanceId":"RCPDQNXHE2P3B","containerPropKey":"5TYK9EV3XRAAA"},{"instanceId":"ULLDQNXHE2P3B","containerPropKey":"1UBN9EV3XRAAA"}],"shippersOwnFlag":"false","containerNo":"MRKU9986377","linkedContainerNumber":"MRKU9986377","preAssignedContainerNumber":"MRKU9986377","proratingType":"","isRelatedToDocCargoStuffing":"false","sequenceNr":"1"}],"equipmentStuffings":[{"equipmentStuffingId":"EF7DQNXHE2P3B","equipmentAssignmentId":"AAIDQNXHE2P3B","cargoId":"Q2RDQNXHE2P3B","stuffingWeight":"5419.400000","stuffingWeightUnits":"KGS","stuffingVolume":"26.994000","stuffingVolumeUnits":"CBM","stuffingQuantity":"246.000000","stuffingConfirmed":"true","isRelatedToDocCargo":"false"}]},"shipmentReferences":[{"shipmentPropertyId":"K5GETLATE2LYB","propertyTypeId":"1022","shipmentVersion":"JKUG9MXHE2CLB","levelId":"302","propertyTypeName":"Carrier Seal","referencedObject":"AAIDQNXHE2P3B","valueString":"CN5017174","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"W00PRNXHE2P3B","propertyTypeId":"O9KTVXY3UZ8JB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"201","propertyTypeName":"6 digit HS code","referencedObject":"Q2RDQNXHE2P3B","valueString":"420212","direction":"Place of Receipt","categoryId":"1","country":"China","countryId":"1HDVVRK6OM45A","valueName":"","dataDomainId":"2","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"SNKQRNXHE2P3B","propertyTypeId":"1XLFR50OPZELB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Tax reference - Indonesia","referencedObject":"PVQG9MXHE2CLB","valueString":"017211236054000","direction":"Final Vessel Discharge","categoryId":"1","country":"Indonesia","countryId":"32L6DQM2PYU7Y","valueName":"","dataDomainId":"3","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"XKMHSNXHE2P3B","propertyTypeId":"2100000000068","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Short Sea","referencedObject":"PVQG9MXHE2CLB","valueString":"","categoryId":"2","valueName":"","dataDomainId":"1","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"LSPPSNXHE2P3B","propertyTypeId":"1198","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Reference Number","referencedObject":"PVQG9MXHE2CLB","valueString":"3290ece9-e5c7-49a4-8c8e-83cb0a55a928","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"false"},{"shipmentPropertyId":"UFCRSNXHE2P3B","propertyTypeId":"2100000000066","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Consumer","referencedObject":"PVQG9MXHE2CLB","valueString":"web","categoryId":"2","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"NVXE35IWE2K3B","propertyTypeId":"1038","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Shipment Reference number","referencedObject":"PVQG9MXHE2CLB","valueString":"233458266:","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"}]}}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Test.stopTest();        
        
        Case newCase = [Select Id,Cargo_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Reefer', newCase.Cargo_Type__c);
    }
    
    @isTest
    public static void testCaseShipmentSummaryOOGAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"shipmentSummary":{"header":{"businessUnitId":"1089","businessUnitCode":"CNSGHMSL1","bookingcountryGeoArea":"China","bookingcountryCode":"CN","shipmentVersionId":"JKUG9MXHE2CLB","businessUnit":"Maersk China Shipping (Shanghai)","bookedByCustomerName":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","contactName":"CHEN QI","contactNumber":"86-55668366","serviceModeExportName":"CY","serviceModeImportName":"CY","serviceMode":"CY/CY","placeOfReceiptId":"9FHJRNXHE2P3B","placeOfReceipt":"Ningbo, Zhejiang, China","placeOfDeliveryId":"SBUJRNXHE2P3B","placeOfDelivery":"Bekasi, Indonesia","partialShipment":"true","isPricedByAFLS":"true","isFMCRegulated":"N","isFirstOPSOUTClosed":"true","priceCalcBaseDateLocal":"2023-11-26","shipmentInstanceId":"PVQG9MXHE2CLB","shipmentClassId":"3","shipmentClass":"Ordinary Transport Order","shipmentStatusId":"1","shipmentStatus":"Active","isReefer":"false","isDangerous":"false","isOOG":"true","lastchangedUserId":"AA-CRBIMP02","lastChangedTimestamp":"2023-12-05T06:28:11.392164","isShortShipped":"false","isImportShipment":"false","isSpotBooking":"false","operator":"MSL","customerCommodity":"","priceOwner":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","bookedByScvCustomerCode":"40602926822","priceOwnerScvCustomerCode":"40602926822","shipperScvCustomerCode":"40600739987","consigneeScvCustomerCode":"41100106641","shipperName":"MILLENNIUM LOGISTICS (SHENZHEN) LTD","mepcTradeLaneCode":"FEA/FEA(MCC)"},"exportEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"2023-11-23T01:00:00","hsCommodityDescription":["Sacks and bags, plastic"],"containerNumber":"MRKU9986377","haulageSiteName":"NIngbo Beilun Donghwa Cont. Transp.","haulageSiteCityName":"NIngbo Beilun Donghwa Cont. Transp.","haulageReference":"","haulageSent":"true","haulageNumber":"209311577","isOnImportShipment":"false"}],"importEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"","tpDocNumbers":["233458266"],"containerNumber":"MRKU9986377","haulageSiteName":"","haulageSiteCityName":"","haulageReference":"","haulageSent":"false","haulageNumber":"","isOnImportShipment":"false"}],"equipmentTrackings":[{"containerNo":"MRKU9986377","containerSizeAndType":"20 DRY","cargoWeightKgs":"5419","cargoWeightLbs":"11947","carrier":"QINGDAO STAR","voyageNo":"347S","slotNo":"070512","status":"NA","location":"Beilun container terminal, Phase 2","activity":"LOAD","activityDateTime":"2023-11-28T14:23:00","nextCarrier":"","nextVoyageNo":"","carrierSeal":"CN5017174","shipperSeal":"","customsSeal":"","vetSeal":"","loadReference":"","tcn":""}],"mainLocations":{"receiptLocation":{"routePointId":"9FHJRNXHE2P3B","geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","state":"Zhejiang","stateId":"398QCI744592C","cyTerminalFlag":"true","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"deliveryLocation":{"routePointId":"SBUJRNXHE2P3B","geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","state":"","stateId":"","cyTerminalFlag":"true","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"firstLoadPort":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","geoSiteId":"15W6NU75ECEPB","name":"Beilun container terminal, Phase 2","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"finalDischargePort":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","geoSiteId":"DUYEDVI26TJG4","name":"PT New Priok Container Terminal One","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"}},"transportRoutePlan":[{"origin":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"destination":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"W","vesselName":"QINGDAO STAR(MH)","vesselVoyage":"347S","vesselVoyageArrive":"347S","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-11-28T21:00:00","destinationArrivalDate":"2023-12-07T19:00:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"Y","vesselCode":"ET7","service":"IA1","iflrCode":"C","mepctransportMode":"MVS"},{"origin":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"destination":{"geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"L","vesselName":"","vesselVoyage":"","vesselVoyageArrive":"","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-12-08T09:15:00","destinationArrivalDate":"2023-12-08T21:15:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"N","vesselCode":"","service":"","iflrCode":"","mepctransportMode":"TRK"}],"equipmentAndCargoSummary":{"cargoLines":[{"cargoId":"Q2RDQNXHE2P3B","hsCommodityCode":"003208","hsCommodityDescription":"Sacks and bags, plastic","commodityGroup":"320","cargoWeight":"5419.400000","cargoWeightUnit":"KGS","cargoVolume":"26.994000","cargoVolumeUnit":"CBM","cargoPackageId":"YJ2DQNXHE2P3B","cargoPackageName":"CARTONS","quantity":"246","dangerous":"false","cargoSequenceNumber":"1","customerSpecifiedHSCode":"420212","transportDocumentNumber":"233458266","isRelatedTPDocIssued":"true","hscodeSpecifiedByCustomer":"false","shipmentVersionPriceId":"JKUG9MXHE2CLB"}],"equipments":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerTypeId":"4","containerType":"DRY","containerSize":"20","containerHeight":"8 6","bookedWeight":"18000.000000","bookedWeightUnit":"KGS","hangerBeams":[{"instanceId":"RCPDQNXHE2P3B","containerPropKey":"5TYK9EV3XRAAA"},{"instanceId":"ULLDQNXHE2P3B","containerPropKey":"1UBN9EV3XRAAA"}],"shippersOwnFlag":"false","containerNo":"MRKU9986377","linkedContainerNumber":"MRKU9986377","preAssignedContainerNumber":"MRKU9986377","proratingType":"","isRelatedToDocCargoStuffing":"false","sequenceNr":"1"}],"equipmentStuffings":[{"equipmentStuffingId":"EF7DQNXHE2P3B","equipmentAssignmentId":"AAIDQNXHE2P3B","cargoId":"Q2RDQNXHE2P3B","stuffingWeight":"5419.400000","stuffingWeightUnits":"KGS","stuffingVolume":"26.994000","stuffingVolumeUnits":"CBM","stuffingQuantity":"246.000000","stuffingConfirmed":"true","isRelatedToDocCargo":"false"}]},"shipmentReferences":[{"shipmentPropertyId":"K5GETLATE2LYB","propertyTypeId":"1022","shipmentVersion":"JKUG9MXHE2CLB","levelId":"302","propertyTypeName":"Carrier Seal","referencedObject":"AAIDQNXHE2P3B","valueString":"CN5017174","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"W00PRNXHE2P3B","propertyTypeId":"O9KTVXY3UZ8JB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"201","propertyTypeName":"6 digit HS code","referencedObject":"Q2RDQNXHE2P3B","valueString":"420212","direction":"Place of Receipt","categoryId":"1","country":"China","countryId":"1HDVVRK6OM45A","valueName":"","dataDomainId":"2","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"SNKQRNXHE2P3B","propertyTypeId":"1XLFR50OPZELB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Tax reference - Indonesia","referencedObject":"PVQG9MXHE2CLB","valueString":"017211236054000","direction":"Final Vessel Discharge","categoryId":"1","country":"Indonesia","countryId":"32L6DQM2PYU7Y","valueName":"","dataDomainId":"3","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"XKMHSNXHE2P3B","propertyTypeId":"2100000000068","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Short Sea","referencedObject":"PVQG9MXHE2CLB","valueString":"","categoryId":"2","valueName":"","dataDomainId":"1","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"LSPPSNXHE2P3B","propertyTypeId":"1198","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Reference Number","referencedObject":"PVQG9MXHE2CLB","valueString":"3290ece9-e5c7-49a4-8c8e-83cb0a55a928","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"false"},{"shipmentPropertyId":"UFCRSNXHE2P3B","propertyTypeId":"2100000000066","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Consumer","referencedObject":"PVQG9MXHE2CLB","valueString":"web","categoryId":"2","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"NVXE35IWE2K3B","propertyTypeId":"1038","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Shipment Reference number","referencedObject":"PVQG9MXHE2CLB","valueString":"233458266:","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"}]}}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Test.stopTest();        
        
        Case newCase = [Select Id,Cargo_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Out-of-gauge', newCase.Cargo_Type__c);
    }
    
    @isTest
    public static void testCaseBreakBulkAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert cs;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"isBreakBulk": "true"}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Test.stopTest();        
        
        Case newCase = [Select Id,Cargo_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Break Bulk', newCase.Cargo_Type__c);
    }
    
    @isTest
    public static void testCaseClassificationAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_Classification_API_status__c = true;
        gs.Custom_Model_CC_Callout_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Origin = 'MSLINEXP';
        cs.Status = 'New';
        cs.Type = null;
        cs.Sub_Type__c = null;
        insert cs;
        
        Test.startTest();
        Case newCs = [Select Id, CaseNumber, Care_Relationship__c From Case Where Id =: cs.Id];
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"Results": [{"Case_number": "'+newCs.CaseNumber+'", "Product": "Ocean", "Sub_Type": "Container Status", "Type": "Cargo/Container", "Reason_For_Case": "Container Maritime Tracking Request", "Confidence_Score": 0.36903998255729675, "Error_Reason": "", "Language": "en_US", "Language_score": 0.5515563488006592}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'OK',sampleBody,headers));
        Test.stopTest();
        
        Case newCase = [Select Id, Type, Sub_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Cargo/Container', newCase.Type);
        Assert.areEqual('Container Status', newCase.Sub_Type__c);
    }
    
    @isTest
    public static void testCaseClassificationAPIslaWaitFlagYes(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_Classification_API_status__c = true;
        gs.Custom_Model_CC_Callout_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Origin = 'MSLINEXP';
        cs.Status = 'New';
        cs.Type = null;
        cs.Sub_Type__c = null;
        insert cs;
        
        Test.startTest();
        Case newCs = [Select Id, CaseNumber, Care_Relationship__c From Case Where Id =: cs.Id];
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"Results": [{"Case_number": "'+newCs.CaseNumber+'", "Product": "Ocean", "Sub_Type": "Container Status", "Type": "Cargo/Container", "Reason_For_Case": "Container Maritime Tracking Request", "Confidence_Score": 0.36903998255729675, "Error_Reason": "", "Language": "en_US", "Language_score": 0.5515563488006592, "slaWait": "Yes"}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'OK',sampleBody,headers));
        Test.stopTest();
        
        Case newCase = [Select Id, Type, Sub_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Cargo/Container', newCase.Type);
        Assert.areEqual('Container Status', newCase.Sub_Type__c);
        
        Integration_Staging__c ins = [Select Id, Wait_Status__c, Status_Updated_Time__c From Integration_Staging__c Where Related_Record_Id__c =: cs.Id];
        Assert.areEqual(ins.Wait_Status__c, 'Wait', 'Wait Status updates to Wait when slaWait flag received as Yes');
    }
    
    @isTest
    public static void testCaseClassificationAPIslaWaitFlagNo(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_Classification_API_status__c = true;
        gs.Custom_Model_CC_Callout_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Origin = 'MSLINEXP';
        cs.Status = 'New';
        cs.Type = null;
        cs.Sub_Type__c = null;
        insert cs;
        
        Test.startTest();
        Case newCs = [Select Id, CaseNumber, Care_Relationship__c From Case Where Id =: cs.Id];
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"Results": [{"Case_number": "'+newCs.CaseNumber+'", "Product": "Ocean", "Sub_Type": "Container Status", "Type": "Cargo/Container", "Reason_For_Case": "Container Maritime Tracking Request", "Confidence_Score": 0.36903998255729675, "Error_Reason": "", "Language": "en_US", "Language_score": 0.5515563488006592, "slaWait": "No"}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'OK',sampleBody,headers));
        Test.stopTest();
        
        Case newCase = [Select Id, Type, Sub_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Cargo/Container', newCase.Type);
        Assert.areEqual('Container Status', newCase.Sub_Type__c);
        
        Integration_Staging__c ins = [Select Id, Wait_Status__c, Status_Updated_Time__c From Integration_Staging__c Where Related_Record_Id__c =: cs.Id];
        Assert.isNull(ins.Wait_Status__c, 'Wait Status will be null when slaWait flag is No');
    }
    
    @isTest
    public static void testCaseSentimentAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_sentiment_API_status__c = true;
        gs.Case_sentiment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Closure_Language_Code__c = 'en_US';
        insert cs;
        
        Integration_Staging__c ins = TestBusinessHelper.createIntegrationStaging('Sentiment Analysis', 1, cs.Id, false);
        ins.Id = null;
        insert ins;
        
        Integration_Results__c inRes = TestBusinessHelper.createIntegrationResults('Sentiment Analysis', false);
        inRes.Id = null;
        inRes.Integration_Staging__c = ins.Id;
        insert inRes;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"documents":[{"id":"'+cs.Id+'","sentiment":"neutral","confidenceScores":{"positive":0.03,"neutral":0.97,"negative":0.01},"sentences":[{"sentiment":"neutral","confidenceScores":{"positive":0.03,"neutral":0.97,"negative":0.01},"offset":0,"length":7,"text":"bghnbgr"}],"warnings":[]}],"errors":[],"modelVersion":"2022-11-01"}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Test.stopTest();
        
        Case newCase = [Select Id, Sentiment_Analysis__c From Case Where Id =: cs.Id];
        Assert.areEqual('Neutral', newCase.Sentiment_Analysis__c);
        
        IntegrationStagingTriggerHelper.getGlobalErrorLogger('SFDC', 'Case', 'IntegrationStagingTriggerHelper.processShipmentSummaryResponse', 'test', 'test', 'test');
    }
    
    @isTest
    public static void testCaseShipmentReferenceAPI() {
        // Create test data
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 589565490';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        Test.startTest();
        
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"shipmentNumber":"589565490","references":[{"referenceType":"Reference","id":"32BFXESOH2ALB","typeId":"2100000000037","name":"ACID-Egypt","value":"1111111"},{"referenceType":"Status","id":"SL1C24UMH2VJB","typeId":"2100000000068","name":"Short Sea","value":"Yes"}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        
        Test.stopTest();
        Case newCase = [Select Id, Priority, Short_Transit__c From Case Where Id =: cs.Id];
        Assert.areEqual(true, newCase.Short_Transit__c);
        Assert.areEqual('High', newCase.Priority);
        
        Shipment__c ship = [Select Id, IsShortShipped__c From Shipment__c Where Shipment_Number__c = '589565490'];
        Assert.areEqual(true, ship.IsShortShipped__c);
        
    }
    
    @isTest
    public static void testCaseShipmentReferenceAPIUpdate() {
        // Create test data
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 589565496';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        
        cs.Shipment_Number__c = '589565490';
        update cs;
        Test.startTest();
        
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        String sampleBody = '{"shipmentNumber":"589565490","references":[{"referenceType":"Reference","id":"32BFXESOH2ALB","typeId":"2100000000037","name":"ACID-Egypt","value":"1111111"},{"referenceType":"Status","id":"SL1C24UMH2VJB","typeId":"2100000000068","name":"Short Sea","value":"Yes"}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        
        Test.stopTest();
        Case newCase = [Select Id, Priority, Short_Transit__c From Case Where Id =: cs.Id];
        Assert.areEqual(true, newCase.Short_Transit__c);
        Assert.areEqual('High', newCase.Priority);
        
        Shipment__c ship = [Select Id, IsShortShipped__c From Shipment__c Where Shipment_Number__c = '589565490'];
        Assert.areEqual(true, ship.IsShortShipped__c);
    }
    
    @isTest
    public static void testCaseShipmentSummaryAPIUpdate(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_shipment_API_status__c = true;
        gs.Case_shipment_API_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559626';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        
        cs.Shipment_Number__c = '234559625';
        update cs;
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"shipmentSummary":{"header":{"businessUnitId":"1089","businessUnitCode":"CNSGHMSL1","bookingcountryGeoArea":"China","bookingcountryCode":"CN","shipmentVersionId":"JKUG9MXHE2CLB","businessUnit":"Maersk China Shipping (Shanghai)","bookedByCustomerName":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","contactName":"CHEN QI","contactNumber":"86-55668366","serviceModeExportName":"CY","serviceModeImportName":"CY","serviceMode":"CY/CY","placeOfReceiptId":"9FHJRNXHE2P3B","placeOfReceipt":"Ningbo, Zhejiang, China","placeOfDeliveryId":"SBUJRNXHE2P3B","placeOfDelivery":"Bekasi, Indonesia","partialShipment":"true","isPricedByAFLS":"true","isFMCRegulated":"N","isFirstOPSOUTClosed":"true","priceCalcBaseDateLocal":"2023-11-26","shipmentInstanceId":"PVQG9MXHE2CLB","shipmentClassId":"3","shipmentClass":"Ordinary Transport Order","shipmentStatusId":"1","shipmentStatus":"Active","isReefer":"false","isDangerous":"true","isOOG":"false","lastchangedUserId":"AA-CRBIMP02","lastChangedTimestamp":"2023-12-05T06:28:11.392164","isShortShipped":"false","isImportShipment":"false","isSpotBooking":"false","operator":"MSL","customerCommodity":"","priceOwner":"ZHEJIANG MINGJUN SUPPLY CHAIN MANAGEMENT CO LTD","bookedByScvCustomerCode":"40602926822","priceOwnerScvCustomerCode":"40602926822","shipperScvCustomerCode":"40600739987","consigneeScvCustomerCode":"41100106641","shipperName":"MILLENNIUM LOGISTICS (SHENZHEN) LTD","mepcTradeLaneCode":"FEA/FEA(MCC)"},"exportEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"2023-11-23T01:00:00","hsCommodityDescription":["Sacks and bags, plastic"],"containerNumber":"MRKU9986377","haulageSiteName":"NIngbo Beilun Donghwa Cont. Transp.","haulageSiteCityName":"NIngbo Beilun Donghwa Cont. Transp.","haulageReference":"","haulageSent":"true","haulageNumber":"209311577","isOnImportShipment":"false"}],"importEquipmentHaulage":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerSize":"20","containerType":"Dry","containerHeight":"8 6","containerCollapsible":"","dateTime":"","tpDocNumbers":["233458266"],"containerNumber":"MRKU9986377","haulageSiteName":"","haulageSiteCityName":"","haulageReference":"","haulageSent":"false","haulageNumber":"","isOnImportShipment":"false"}],"equipmentTrackings":[{"containerNo":"MRKU9986377","containerSizeAndType":"20 DRY","cargoWeightKgs":"5419","cargoWeightLbs":"11947","carrier":"QINGDAO STAR","voyageNo":"347S","slotNo":"070512","status":"NA","location":"Beilun container terminal, Phase 2","activity":"LOAD","activityDateTime":"2023-11-28T14:23:00","nextCarrier":"","nextVoyageNo":"","carrierSeal":"CN5017174","shipperSeal":"","customsSeal":"","vetSeal":"","loadReference":"","tcn":""}],"mainLocations":{"receiptLocation":{"routePointId":"9FHJRNXHE2P3B","geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","state":"Zhejiang","stateId":"398QCI744592C","cyTerminalFlag":"true","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"deliveryLocation":{"routePointId":"SBUJRNXHE2P3B","geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","state":"","stateId":"","cyTerminalFlag":"true","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"firstLoadPort":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","geoSiteId":"15W6NU75ECEPB","name":"Beilun container terminal, Phase 2","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"finalDischargePort":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","geoSiteId":"DUYEDVI26TJG4","name":"PT New Priok Container Terminal One","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"}},"transportRoutePlan":[{"origin":{"geoArea":"Ningbo","geoAreaId":"104T898SJZ6GU","site":"Beilun container terminal, Phase 2","siteId":"15W6NU75ECEPB","country":"China","countryId":"1HDVVRK6OM45A","countryCode":"CN"},"destination":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"W","vesselName":"QINGDAO STAR(MH)","vesselVoyage":"347S","vesselVoyageArrive":"347S","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-11-28T21:00:00","destinationArrivalDate":"2023-12-07T19:00:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"Y","vesselCode":"ET7","service":"IA1","iflrCode":"C","mepctransportMode":"MVS"},{"origin":{"geoArea":"Jakarta","geoAreaId":"1T5KH4LY00TQ7","site":"PT New Priok Container Terminal One","siteId":"DUYEDVI26TJG4","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"destination":{"geoArea":"Bekasi","geoAreaId":"05RG94BTCTDRP","site":"Cikarang Dry Port","siteId":"0FM1N11F1O72J","country":"Indonesia","countryId":"32L6DQM2PYU7Y","countryCode":"ID"},"optionalDischarge":{"geoArea":"","geoAreaId":"","routePointId":"","country":"","countryId":"","countryCode":""},"freightMode":"L","vesselName":"","vesselVoyage":"","vesselVoyageArrive":"","vesselAltText":"","openExportStackTime":"","closeExportStackTime":"","originDepartureDate":"2023-12-08T09:15:00","destinationArrivalDate":"2023-12-08T21:15:00","limitations":"N","isArrivalTimeRevised":"true","isDepartureTimeRevised":"true","isReadyForLoad":"true","isSteeredLeg":"N","vesselCode":"","service":"","iflrCode":"","mepctransportMode":"TRK"}],"equipmentAndCargoSummary":{"cargoLines":[{"cargoId":"Q2RDQNXHE2P3B","hsCommodityCode":"003208","hsCommodityDescription":"Sacks and bags, plastic","commodityGroup":"320","cargoWeight":"5419.400000","cargoWeightUnit":"KGS","cargoVolume":"26.994000","cargoVolumeUnit":"CBM","cargoPackageId":"YJ2DQNXHE2P3B","cargoPackageName":"CARTONS","quantity":"246","dangerous":"false","cargoSequenceNumber":"1","customerSpecifiedHSCode":"420212","transportDocumentNumber":"233458266","isRelatedTPDocIssued":"true","hscodeSpecifiedByCustomer":"false","shipmentVersionPriceId":"JKUG9MXHE2CLB"}],"equipments":[{"equipmentAssignmentId":"AAIDQNXHE2P3B","containerTypeId":"4","containerType":"DRY","containerSize":"20","containerHeight":"8 6","bookedWeight":"18000.000000","bookedWeightUnit":"KGS","hangerBeams":[{"instanceId":"RCPDQNXHE2P3B","containerPropKey":"5TYK9EV3XRAAA"},{"instanceId":"ULLDQNXHE2P3B","containerPropKey":"1UBN9EV3XRAAA"}],"shippersOwnFlag":"false","containerNo":"MRKU9986377","linkedContainerNumber":"MRKU9986377","preAssignedContainerNumber":"MRKU9986377","proratingType":"","isRelatedToDocCargoStuffing":"false","sequenceNr":"1"}],"equipmentStuffings":[{"equipmentStuffingId":"EF7DQNXHE2P3B","equipmentAssignmentId":"AAIDQNXHE2P3B","cargoId":"Q2RDQNXHE2P3B","stuffingWeight":"5419.400000","stuffingWeightUnits":"KGS","stuffingVolume":"26.994000","stuffingVolumeUnits":"CBM","stuffingQuantity":"246.000000","stuffingConfirmed":"true","isRelatedToDocCargo":"false"}]},"shipmentReferences":[{"shipmentPropertyId":"K5GETLATE2LYB","propertyTypeId":"1022","shipmentVersion":"JKUG9MXHE2CLB","levelId":"302","propertyTypeName":"Carrier Seal","referencedObject":"AAIDQNXHE2P3B","valueString":"CN5017174","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"W00PRNXHE2P3B","propertyTypeId":"O9KTVXY3UZ8JB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"201","propertyTypeName":"6 digit HS code","referencedObject":"Q2RDQNXHE2P3B","valueString":"420212","direction":"Place of Receipt","categoryId":"1","country":"China","countryId":"1HDVVRK6OM45A","valueName":"","dataDomainId":"2","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"SNKQRNXHE2P3B","propertyTypeId":"1XLFR50OPZELB","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Tax reference - Indonesia","referencedObject":"PVQG9MXHE2CLB","valueString":"017211236054000","direction":"Final Vessel Discharge","categoryId":"1","country":"Indonesia","countryId":"32L6DQM2PYU7Y","valueName":"","dataDomainId":"3","completeBeforeId":"1000000000080","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"XKMHSNXHE2P3B","propertyTypeId":"2100000000068","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Short Sea","referencedObject":"PVQG9MXHE2CLB","valueString":"","categoryId":"2","valueName":"","dataDomainId":"1","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"LSPPSNXHE2P3B","propertyTypeId":"1198","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Reference Number","referencedObject":"PVQG9MXHE2CLB","valueString":"3290ece9-e5c7-49a4-8c8e-83cb0a55a928","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"false"},{"shipmentPropertyId":"UFCRSNXHE2P3B","propertyTypeId":"2100000000066","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"SSIB Consumer","referencedObject":"PVQG9MXHE2CLB","valueString":"web","categoryId":"2","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"},{"shipmentPropertyId":"NVXE35IWE2K3B","propertyTypeId":"1038","shipmentVersion":"JKUG9MXHE2CLB","levelId":"101","propertyTypeName":"Shipment Reference number","referencedObject":"PVQG9MXHE2CLB","valueString":"233458266:","categoryId":"1","valueName":"","dataDomainId":"3","isValueToBeSpecified":"false","isModifyable":"true","canBeDeleted":"true"}]}}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200, 'OK', sampleBody, headers));
        Test.stopTest();        
        
        Case newCase = [Select Id,Cargo_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Dangerous Cargo', newCase.Cargo_Type__c);
    }
    
    @isTest
    public static void testEntitlementUpdate(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        Validation_Rules_Bypass__c vb = new Validation_Rules_Bypass__c();
        vb.SetupOwnerId = UserInfo.getUserId();
        vb.Active__c = true;
        insert vb;
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_Classification_API_status__c = true;
        gs.Custom_Model_CC_Callout_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Origin = 'MSLINEXP';
        cs.Status = 'New';
        cs.Type = null;
        cs.Sub_Type__c = null;
        insert cs;
        
        Test.startTest();
        Case newCs = [Select Id, CaseNumber, Care_Relationship__c From Case Where Id =: cs.Id];
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'OK',sampleBody,headers));
        Test.stopTest();
        
        Case newCase = [Select EntitlementId From Case Where Id =: cs.Id];
        Assert.areEqual(Label.Default_Entitlement_Id, newCase.EntitlementId);
    }
    
    @isTest
    public static void testVesselService(){
        Case_OmniSkill_Mappings__c skillmap1 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap1',Developer_Name__c ='SkillMap1', Active__c = true, Mandatory__c = true, Case_Field__c = 'QueueApiName', Origin__c = 'MSLINIMP', Value__c = 'Case_MSL_India_Import', Skill_Id__c = '0C57E0000008WW7');
        Case_OmniSkill_Mappings__c skillmap2 = new Case_OmniSkill_Mappings__c(Name = 'SkillMap2',Developer_Name__c ='SkillMap2', Active__c = true, Origin__c = 'MSLINIMP', Case_Field__c = 'Vessel_Service_Numbers__c', Value__c = 'IA1', Case_Field_2__c = 'Sub_Type__c', Value_2__c = 'Container Status', Skill_Id__c = '0C50D0000008ShTSAU;0C50D0000008QOhSAM', Vessel_Journey_Leg__c = 'Last Leg');
        
        List<Case_OmniSkill_Mappings__c> omnimapList = new List<Case_OmniSkill_Mappings__c>();
        omnimapList.add(skillmap1);
        omnimapList.add(skillmap2);
        insert omnimapList;
        
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        
        General_Settings__c gs = new General_Settings__c();
        gs.Case_Classification_API_status__c = true;
        gs.Custom_Model_CC_Callout_Count__c = 1;
        insert gs;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Origin = 'MSLINIMP';
        cs.Status = 'New';
        cs.Type = null;
        cs.Sub_Type__c = null;
        cs.Vessel_Service_Numbers__c = 'IA1';
        insert cs;
        
        Test.startTest();
        Case newCs = [Select Id, CaseNumber, Care_Relationship__c From Case Where Id =: cs.Id];
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"Results": [{"Case_number": "'+newCs.CaseNumber+'", "Product": "Ocean", "Sub_Type": "Container Status", "Type": "Cargo/Container", "Reason_For_Case": "Container Maritime Tracking Request", "Confidence_Score": 0.36903998255729675, "Error_Reason": "", "Language": "en_US", "Language_score": 0.5515563488006592, "slaWait": "No"}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'OK',sampleBody,headers));
        Test.stopTest();
        
        Case newCase = [Select Id, Type, Sub_Type__c, Omni_Skill_Type__c From Case Where Id =: cs.Id];
        Assert.areEqual('Cargo/Container', newCase.Type);
        Assert.areEqual('Container Status', newCase.Sub_Type__c);
    }
    
}