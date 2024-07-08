@IsTest
public class Instant_DO_Wrapper_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"carrierCode\": \"MAEU\",'+
		'  \"customerCode\": \"10000007951\",'+
		'  \"salesForceCaseId\": \"12222ef56xc2478\",'+
		'  \"salesForceCaseNumber\": \"1079-2875643\",'+
		'  \"importServiceMode\": \"CY\",'+
		'  \"releaseToParty\": {'+
		'    \"id\": \"10000007951\",'+
		'    \"name\": \"COMPANY/CUSTOMER NAME\",'+
		'    \"roleCode\": \"For Consignee - 4, For Lawful BL Holder - 32, For Release To Party - 31.\",'+
		'    \"address\": \"20, Test address street\",'+
		'    \"postalCode\": \"E123456\",'+
		'    \"poBox\": \"PO2789\",'+
		'    \"city\": \"London\",'+
		'    \"countryName\": \"United Kingdom\",'+
		'    \"countryCode\": \"UK\",'+
		'    \"region\": \"Test region\",'+
		'    \"email\": \"test_email@test.com\",'+
		'    \"phone\": \"12345678\",'+
		'    \"taxReference\": \"Test reference\"'+
		'  },'+
		'  \"finalDischargePort\": {'+
		'    \"maerskGeoLocationId\": \"1JUESJ0XRJI5V\",'+
		'    \"unLocCode\": \"CNCSX\",'+
		'    \"maerskRkstCode\": \"AUSYD11\",'+
		'    \"siteName\": \"Changsha Mingze Depot\",'+
		'    \"cityName\": \"Changsha\",'+
		'    \"regionCode\": \"43\",'+
		'    \"regionName\": \"Hunan\",'+
		'    \"countryName\": \"China\",'+
		'    \"countryCode\": \"CN\",'+
		'    \"address\": \"20, Test address street\"'+
		'  },'+
		'  \"releaseToBadge\": \"12222ef56xc2478\",'+
		'  \"haulierReference\": \"12222ef56xc2478\",'+
		'  \"placeOfDelivery\": {'+
		'    \"maerskGeoLocationId\": \"1JUESJ0XRJI5V\",'+
		'    \"unLocCode\": \"CNCSX\",'+
		'    \"maerskRkstCode\": \"AUSYD11\",'+
		'    \"siteName\": \"Changsha Mingze Depot\",'+
		'    \"cityName\": \"Changsha\",'+
		'    \"regionCode\": \"43\",'+
		'    \"regionName\": \"Hunan\",'+
		'    \"countryName\": \"China\",'+
		'    \"countryCode\": \"CN\",'+
		'    \"address\": \"20, Test address street\"'+
		'  },'+
		'  \"requestedFeature\": \"CH\",'+
		'  \"capacity\": \"UNKNOWN\",'+
		'  \"modeOfTransport\": \"TRK\",'+
		'  \"deliveryOrderRecipients\": ['+
		'    {'+
		'      \"email\": \"recipient@test.com\"'+
		'    }'+
		'  ],'+
		'  \"haulageInstructions\": ['+
		'    {'+
		'      \"containerId\": \"MRKU1234567\",'+
		'      \"containerType\": \"20 DRY\",'+
		'      \"cargoType\": \"DRY\",'+
		'      \"haulageInstructionsDetails\": {'+
		'        \"billOfLadingId\": \"DND000103\",'+
		'        \"demurrageFreeDays\": 0,'+
		'        \"detentionFreeDays\": 0,'+
		'        \"demurrageLastFreeDate\": [],'+
		'        \"detentionLastFreeDate\": []'+
		'      },'+
		'      \"haulageOrderValidityDetails\": {'+
		'        \"releaseFromDate\": [],'+
		'        \"estimatedTimeOfArrival\": []'+
		'      },'+
		'      \"deliveryStops\": ['+
		'        {'+
		'          \"site\": {'+
		'            \"maerskGeoLocationId\": \"1JUESJ0XRJI5V\",'+
		'            \"unLocCode\": \"CNCSX\",'+
		'            \"maerskRkstCode\": \"AUSYD11\",'+
		'            \"siteName\": \"Changsha Mingze Depot\",'+
		'            \"cityName\": \"Changsha\",'+
		'            \"regionCode\": \"43\",'+
		'            \"regionName\": \"Hunan\",'+
		'            \"countryName\": \"China\",'+
		'            \"countryCode\": \"CN\",'+
		'            \"address\": \"20, Test address street\"'+
		'          },'+
		'          \"deliveryAddress\": \"19, Test Street\",'+
		'          \"deliveryFromDateTimeLocal\": \"2022-05-11T06:14:01.694Z\",'+
		'          \"deliveryToDateTimeLocal\": \"2022-05-11T06:14:01.694Z\",'+
		'          \"deliveryReference\": \"Delivery reference example\",'+
		'          \"cmdCustomerFacility\": \"DKHGF66589\",'+
		'          \"deliveryOrderContact\": {'+
		'            \"name\": \"John Smith\",'+
		'            \"phone\": \"12345678\",'+
		'            \"email\": \"contact@test.com\"'+
		'          }'+
		'        }'+
		'      ],'+
		'      \"returnDepot\": {'+
		'        \"maerskGeoLocationId\": \"1JUESJ0XRJI5V\",'+
		'        \"unLocCode\": \"CNCSX\",'+
		'        \"maerskRkstCode\": \"AUSYD11\",'+
		'        \"siteName\": \"Changsha Mingze Depot\",'+
		'        \"cityName\": \"Changsha\",'+
		'        \"regionCode\": \"43\",'+
		'        \"regionName\": \"Hunan\",'+
		'        \"countryName\": \"China\",'+
		'        \"countryCode\": \"CN\",'+
		'        \"address\": \"20, Test address street\"'+
		'      },'+
		'      \"instructions\": \"INLAND CONTAINERS NIGERIA LIMITED Empty containers to be return Fano Bonded\",'+
		'      \"userInstructions\": \"User haulage Instructions\",'+
		'      \"preferredContractor\": \"HGFESXFE\"'+
		'    }'+
		'  ],'+
		'  \"deliveryOrderPayers\": ['+
		'    {'+
		'      \"party\": {'+
		'        \"id\": \"10000007951\",'+
		'        \"name\": \"COMPANY/CUSTOMER NAME\",'+
		'        \"roleCode\": \"For Consignee - 4, For Lawful BL Holder - 32, For Release To Party - 31.\",'+
		'        \"address\": \"20, Test address street\",'+
		'        \"postalCode\": \"E123456\",'+
		'        \"poBox\": \"PO2789\",'+
		'        \"city\": \"London\",'+
		'        \"countryName\": \"United Kingdom\",'+
		'        \"countryCode\": \"UK\",'+
		'        \"region\": \"Test region\",'+
		'        \"email\": \"test_email@test.com\",'+
		'        \"phone\": \"12345678\",'+
		'        \"taxReference\": \"Test reference\"'+
		'      },'+
		'      \"chargeType\": \"LPF\"'+
		'    }'+
		'  ],'+
		'  \"payers\": {'+
		'    \"billOfLadingId\": \"DND000101\",'+
		'    \"carrierCode\": \"MAEU\",'+
		'    \"customerCode\": \"10000007951\",'+
		'    \"invoiceReference\": \"12345ABCS\",'+
		'    \"updatedBy\": \"GCSS\",'+
		'    \"charges\": ['+
		'      {'+
		'        \"code\": \"BAS\",'+
		'        \"name\": \"string\",'+
		'        \"paymentTerm\": \"BAS\",'+
		'        \"creditParty\": {'+
		'          \"id\": \"10000007951\",'+
		'          \"name\": \"string\"'+
		'        },'+
		'        \"invoiceParty\": {'+
		'          \"id\": \"10000007951\",'+
		'          \"name\": \"string\"'+
		'        },'+
		'        \"pricing\": {'+
		'          \"amount\": \"0\",'+
		'          \"currency\": \"string\"'+
		'        },'+
		'        \"printableFreightLineFlag\": \"BAS\",'+
		'        \"freightLineIdentifiers\": ['+
		'          \"string\"'+
		'        ],'+
		'        \"equipmentAssignmentIds\": ['+
		'          \"string\"'+
		'        ]'+
		'      }'+
		'    ],'+
		'    \"shipmentNotes\": \"Shipment Notes of the Payers Request\",'+
		'    \"placeOfDeliveryCountryCode\": \"PH\",'+
		'    \"placeOfReceiptCountryCode\": \"PH\",'+
		'    \"taskStatus\": {'+
		'      \"avcidTaskCode\": \"4\"'+
		'    },'+
		'    \"isPayerWriteSuccess\": true'+
		'  },'+
		'  \"deliveryOrderStatus\": \"SUBMITTED\",'+
		'  \"deliveryOrderAuthorization\": {'+
		'    \"fileName\": \"auth.pdf\",'+
		'    \"phone\": \"12345678\",'+
		'    \"email\": \"contact@test.com\"'+
		'  },'+
		'  \"deliveryOrderProofOfPayment\": {'+
		'    \"proofOfPaymentNeeded\": true,'+
		'    \"fileName\": \"ProofOfPayment.pdf\"'+
		'  },'+
		'  \"deliveryOrderSupportingDocuments\": ['+
		'    {'+
		'      \"documentName\": \"Undertaking Letter from Consignee or Freight Forwarder\",'+
		'      \"documentType\": \"DOCUMENT\",'+
		'      \"mandatory\": true,'+
		'      \"fileName\": \" Letter from Consignee.pdf\",'+
		'      \"referenceValue\": \"New Reference\"'+
		'    }'+
		'  ],'+
		'  \"requestor\": {'+
		'    \"name\": \"requestor name example\",'+
		'    \"tradingName\": \"GCSS\",'+
		'    \"email\": \"requestor@test.com\"'+
		'  },'+
		'  \"parties\": ['+
		'    {'+
		'      \"id\": \"10000007951\",'+
		'      \"name\": \"COMPANY/CUSTOMER NAME\",'+
		'      \"roleCode\": \"For Consignee - 4, For Lawful BL Holder - 32, For Release To Party - 31.\",'+
		'      \"address\": \"20, Test address street\",'+
		'      \"postalCode\": \"E123456\",'+
		'      \"poBox\": \"PO2789\",'+
		'      \"city\": \"London\",'+
		'      \"countryName\": \"United Kingdom\",'+
		'      \"countryCode\": \"UK\",'+
		'      \"region\": \"Test region\",'+
		'      \"email\": \"test_email@test.com\",'+
		'      \"phone\": \"12345678\",'+
		'      \"taxReference\": \"Test reference\"'+
		'    }'+
		'  ]'+
		'}';
		Instant_DO_Wrapper r = Instant_DO_Wrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.HaulageInstructionsDetails objHaulageInstructionsDetails = new Instant_DO_Wrapper.HaulageInstructionsDetails(System.JSON.createParser(json));
		System.assert(objHaulageInstructionsDetails != null);
		System.assert(objHaulageInstructionsDetails.billOfLadingId == null);
		System.assert(objHaulageInstructionsDetails.demurrageFreeDays == null);
		System.assert(objHaulageInstructionsDetails.detentionFreeDays == null);
		System.assert(objHaulageInstructionsDetails.demurrageLastFreeDate == null);
		System.assert(objHaulageInstructionsDetails.detentionLastFreeDate == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.HaulageOrderValidityDetails objHaulageOrderValidityDetails = new Instant_DO_Wrapper.HaulageOrderValidityDetails(System.JSON.createParser(json));
		System.assert(objHaulageOrderValidityDetails != null);
		System.assert(objHaulageOrderValidityDetails.releaseFromDate == null);
		System.assert(objHaulageOrderValidityDetails.estimatedTimeOfArrival == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper objJSON2Apex = new Instant_DO_Wrapper(System.JSON.createParser(json));
		System.assert(objJSON2Apex != null);
		System.assert(objJSON2Apex.carrierCode == null);
		System.assert(objJSON2Apex.customerCode == null);
		System.assert(objJSON2Apex.salesForceCaseId == null);
		System.assert(objJSON2Apex.salesForceCaseNumber == null);
		System.assert(objJSON2Apex.importServiceMode == null);
		System.assert(objJSON2Apex.releaseToParty == null);
		System.assert(objJSON2Apex.finalDischargePort == null);
		System.assert(objJSON2Apex.releaseToBadge == null);
		System.assert(objJSON2Apex.haulierReference == null);
		System.assert(objJSON2Apex.placeOfDelivery == null);
		System.assert(objJSON2Apex.requestedFeature == null);
		System.assert(objJSON2Apex.capacity == null);
		System.assert(objJSON2Apex.modeOfTransport == null);
		System.assert(objJSON2Apex.deliveryOrderRecipients == null);
		System.assert(objJSON2Apex.haulageInstructions == null);
		System.assert(objJSON2Apex.deliveryOrderPayers == null);
		System.assert(objJSON2Apex.payers == null);
		System.assert(objJSON2Apex.deliveryOrderStatus == null);
		System.assert(objJSON2Apex.deliveryOrderAuthorization == null);
		System.assert(objJSON2Apex.deliveryOrderProofOfPayment == null);
		System.assert(objJSON2Apex.deliveryOrderSupportingDocuments == null);
		System.assert(objJSON2Apex.requestor == null);
		System.assert(objJSON2Apex.parties == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.HaulageInstructions objHaulageInstructions = new Instant_DO_Wrapper.HaulageInstructions(System.JSON.createParser(json));
		System.assert(objHaulageInstructions != null);
		System.assert(objHaulageInstructions.containerId == null);
		System.assert(objHaulageInstructions.containerType == null);
		System.assert(objHaulageInstructions.cargoType == null);
		System.assert(objHaulageInstructions.haulageInstructionsDetails == null);
		System.assert(objHaulageInstructions.haulageOrderValidityDetails == null);
		System.assert(objHaulageInstructions.deliveryStops == null);
		System.assert(objHaulageInstructions.returnDepot == null);
		System.assert(objHaulageInstructions.instructions == null);
		System.assert(objHaulageInstructions.userInstructions == null);
		System.assert(objHaulageInstructions.preferredContractor == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.DeliveryOrderPayers objDeliveryOrderPayers = new Instant_DO_Wrapper.DeliveryOrderPayers(System.JSON.createParser(json));
		System.assert(objDeliveryOrderPayers != null);
		System.assert(objDeliveryOrderPayers.party == null);
		System.assert(objDeliveryOrderPayers.chargeType == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.TaskStatus objTaskStatus = new Instant_DO_Wrapper.TaskStatus(System.JSON.createParser(json));
		System.assert(objTaskStatus != null);
		System.assert(objTaskStatus.avcidTaskCode == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.Payers objPayers = new Instant_DO_Wrapper.Payers(System.JSON.createParser(json));
		System.assert(objPayers != null);
		System.assert(objPayers.billOfLadingId == null);
		System.assert(objPayers.carrierCode == null);
		System.assert(objPayers.customerCode == null);
		System.assert(objPayers.invoiceReference == null);
		System.assert(objPayers.updatedBy == null);
		System.assert(objPayers.charges == null);
		System.assert(objPayers.shipmentNotes == null);
		System.assert(objPayers.placeOfDeliveryCountryCode == null);
		System.assert(objPayers.placeOfReceiptCountryCode == null);
		System.assert(objPayers.taskStatus == null);
		System.assert(objPayers.isPayerWriteSuccess == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.DeliveryOrderRecipients objDeliveryOrderRecipients = new Instant_DO_Wrapper.DeliveryOrderRecipients(System.JSON.createParser(json));
		System.assert(objDeliveryOrderRecipients != null);
		System.assert(objDeliveryOrderRecipients.email == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.FinalDischargePort objFinalDischargePort = new Instant_DO_Wrapper.FinalDischargePort(System.JSON.createParser(json));
		System.assert(objFinalDischargePort != null);
		System.assert(objFinalDischargePort.maerskGeoLocationId == null);
		System.assert(objFinalDischargePort.unLocCode == null);
		System.assert(objFinalDischargePort.maerskRkstCode == null);
		System.assert(objFinalDischargePort.siteName == null);
		System.assert(objFinalDischargePort.cityName == null);
		System.assert(objFinalDischargePort.regionCode == null);
		System.assert(objFinalDischargePort.regionName == null);
		System.assert(objFinalDischargePort.countryName == null);
		System.assert(objFinalDischargePort.countryCode == null);
		System.assert(objFinalDischargePort.address == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.DeliveryStops objDeliveryStops = new Instant_DO_Wrapper.DeliveryStops(System.JSON.createParser(json));
		System.assert(objDeliveryStops != null);
		System.assert(objDeliveryStops.site == null);
		System.assert(objDeliveryStops.deliveryAddress == null);
		System.assert(objDeliveryStops.deliveryFromDateTimeLocal == null);
		System.assert(objDeliveryStops.deliveryToDateTimeLocal == null);
		System.assert(objDeliveryStops.deliveryReference == null);
		System.assert(objDeliveryStops.cmdCustomerFacility == null);
		System.assert(objDeliveryStops.deliveryOrderContact == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.DeliveryOrderSupportingDocuments objDeliveryOrderSupportingDocuments = new Instant_DO_Wrapper.DeliveryOrderSupportingDocuments(System.JSON.createParser(json));
		System.assert(objDeliveryOrderSupportingDocuments != null);
		System.assert(objDeliveryOrderSupportingDocuments.documentName == null);
		System.assert(objDeliveryOrderSupportingDocuments.documentType == null);
		System.assert(objDeliveryOrderSupportingDocuments.mandatory == null);
		System.assert(objDeliveryOrderSupportingDocuments.fileName == null);
		System.assert(objDeliveryOrderSupportingDocuments.referenceValue == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.CreditParty objCreditParty = new Instant_DO_Wrapper.CreditParty(System.JSON.createParser(json));
		System.assert(objCreditParty != null);
		System.assert(objCreditParty.id == null);
		System.assert(objCreditParty.name == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.Pricing objPricing = new Instant_DO_Wrapper.Pricing(System.JSON.createParser(json));
		System.assert(objPricing != null);
		System.assert(objPricing.amount == null);
		System.assert(objPricing.currency_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.DeliveryOrderProofOfPayment objDeliveryOrderProofOfPayment = new Instant_DO_Wrapper.DeliveryOrderProofOfPayment(System.JSON.createParser(json));
		System.assert(objDeliveryOrderProofOfPayment != null);
		System.assert(objDeliveryOrderProofOfPayment.proofOfPaymentNeeded == null);
		System.assert(objDeliveryOrderProofOfPayment.fileName == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.Charges objCharges = new Instant_DO_Wrapper.Charges(System.JSON.createParser(json));
		System.assert(objCharges != null);
		System.assert(objCharges.code == null);
		System.assert(objCharges.name == null);
		System.assert(objCharges.paymentTerm == null);
		System.assert(objCharges.creditParty == null);
		System.assert(objCharges.invoiceParty == null);
		System.assert(objCharges.pricing == null);
		System.assert(objCharges.printableFreightLineFlag == null);
		System.assert(objCharges.freightLineIdentifiers == null);
		System.assert(objCharges.equipmentAssignmentIds == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.Requestor objRequestor = new Instant_DO_Wrapper.Requestor(System.JSON.createParser(json));
		System.assert(objRequestor != null);
		System.assert(objRequestor.name == null);
		System.assert(objRequestor.tradingName == null);
		System.assert(objRequestor.email == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.DeliveryOrderContact objDeliveryOrderContact = new Instant_DO_Wrapper.DeliveryOrderContact(System.JSON.createParser(json));
		System.assert(objDeliveryOrderContact != null);
		System.assert(objDeliveryOrderContact.name == null);
		System.assert(objDeliveryOrderContact.phone == null);
		System.assert(objDeliveryOrderContact.email == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.DeliveryOrderAuthorization objDeliveryOrderAuthorization = new Instant_DO_Wrapper.DeliveryOrderAuthorization(System.JSON.createParser(json));
		System.assert(objDeliveryOrderAuthorization != null);
		System.assert(objDeliveryOrderAuthorization.fileName == null);
		System.assert(objDeliveryOrderAuthorization.phone == null);
		System.assert(objDeliveryOrderAuthorization.email == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Instant_DO_Wrapper.ReleaseToParty objReleaseToParty = new Instant_DO_Wrapper.ReleaseToParty(System.JSON.createParser(json));
		System.assert(objReleaseToParty != null);
		System.assert(objReleaseToParty.id == null);
		System.assert(objReleaseToParty.name == null);
		System.assert(objReleaseToParty.roleCode == null);
		System.assert(objReleaseToParty.address == null);
		System.assert(objReleaseToParty.postalCode == null);
		System.assert(objReleaseToParty.poBox == null);
		System.assert(objReleaseToParty.city == null);
		System.assert(objReleaseToParty.countryName == null);
		System.assert(objReleaseToParty.countryCode == null);
		System.assert(objReleaseToParty.region == null);
		System.assert(objReleaseToParty.email == null);
		System.assert(objReleaseToParty.phone == null);
		System.assert(objReleaseToParty.taxReference == null);
	}
}