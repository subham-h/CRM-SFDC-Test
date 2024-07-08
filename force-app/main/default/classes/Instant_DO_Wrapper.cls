public class Instant_DO_Wrapper {

	public class HaulageInstructionsDetails {
		public String billOfLadingId {get;set;} 
		public String demurrageFreeDays {get;set;} 
		public String detentionFreeDays {get;set;} 
		public List<Integer> demurrageLastFreeDate {get;set;} 
		public List<Integer> detentionLastFreeDate {get;set;} 

		public HaulageInstructionsDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'billOfLadingId') {
							billOfLadingId = parser.getText();
						} else if (text == 'demurrageFreeDays') {
							demurrageFreeDays = parser.getText();
						} else if (text == 'detentionFreeDays') {
							detentionFreeDays = parser.getText();
						} else if (text == 'demurrageLastFreeDate') {
							demurrageLastFreeDate = arrayOfInteger(parser);
						} else if (text == 'detentionLastFreeDate') {
							detentionLastFreeDate = arrayOfInteger(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'HaulageInstructionsDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
   
	public class HaulageOrderValidityDetails {
		public List<Integer> releaseFromDate {get;set;} 
		public List<Integer> estimatedTimeOfArrival {get;set;} 

		public HaulageOrderValidityDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'releaseFromDate') {
							releaseFromDate = arrayOfInteger(parser);
						} else if (text == 'estimatedTimeOfArrival') {
							estimatedTimeOfArrival = arrayOfInteger(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'HaulageOrderValidityDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String carrierCode {get;set;} 
	public String customerCode {get;set;} 
	public String salesForceCaseId {get;set;} 
	public String salesForceCaseNumber {get;set;} 
	public String importServiceMode {get;set;} 
	public ReleaseToParty releaseToParty {get;set;} 
	public FinalDischargePort finalDischargePort {get;set;} 
	public String releaseToBadge {get;set;} 
	public String haulierReference {get;set;} 
	public FinalDischargePort placeOfDelivery {get;set;} 
	public String requestedFeature {get;set;} 
	public String capacity {get;set;} 
	public String modeOfTransport {get;set;} 
	public List<DeliveryOrderRecipients> deliveryOrderRecipients {get;set;} 
	public List<HaulageInstructions> haulageInstructions {get;set;} 
	public List<DeliveryOrderPayers> deliveryOrderPayers {get;set;} 
	public Payers payers {get;set;} 
	public String deliveryOrderStatus {get;set;} 
	public DeliveryOrderAuthorization deliveryOrderAuthorization {get;set;} 
	public DeliveryOrderProofOfPayment deliveryOrderProofOfPayment {get;set;} 
	public List<DeliveryOrderSupportingDocuments> deliveryOrderSupportingDocuments {get;set;} 
	public Requestor requestor {get;set;} 
	public List<ReleaseToParty> parties {get;set;} 

	public Instant_DO_Wrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'carrierCode') {
						carrierCode = parser.getText();
					} else if (text == 'customerCode') {
						customerCode = parser.getText();
					} else if (text == 'salesForceCaseId') {
						salesForceCaseId = parser.getText();
					} else if (text == 'salesForceCaseNumber') {
						salesForceCaseNumber = parser.getText();
					} else if (text == 'importServiceMode') {
						importServiceMode = parser.getText();
					} else if (text == 'releaseToParty') {
						releaseToParty = new ReleaseToParty(parser);
					} else if (text == 'finalDischargePort') {
						finalDischargePort = new FinalDischargePort(parser);
					} else if (text == 'releaseToBadge') {
						releaseToBadge = parser.getText();
					} else if (text == 'haulierReference') {
						haulierReference = parser.getText();
					} else if (text == 'placeOfDelivery') {
						placeOfDelivery = new FinalDischargePort(parser);
					} else if (text == 'requestedFeature') {
						requestedFeature = parser.getText();
					} else if (text == 'capacity') {
						capacity = parser.getText();
					} else if (text == 'modeOfTransport') {
						modeOfTransport = parser.getText();
					} else if (text == 'deliveryOrderRecipients') {
						deliveryOrderRecipients = arrayOfDeliveryOrderRecipients(parser);
					} else if (text == 'haulageInstructions') {
						haulageInstructions = arrayOfHaulageInstructions(parser);
					} else if (text == 'deliveryOrderPayers') {
						deliveryOrderPayers = arrayOfDeliveryOrderPayers(parser);
					} else if (text == 'payers') {
						payers = new Payers(parser);
					} else if (text == 'deliveryOrderStatus') {
						deliveryOrderStatus = parser.getText();
					} else if (text == 'deliveryOrderAuthorization') {
						deliveryOrderAuthorization = new DeliveryOrderAuthorization(parser);
					} else if (text == 'deliveryOrderProofOfPayment') {
						deliveryOrderProofOfPayment = new DeliveryOrderProofOfPayment(parser);
					} else if (text == 'deliveryOrderSupportingDocuments') {
						deliveryOrderSupportingDocuments = arrayOfDeliveryOrderSupportingDocuments(parser);
					} else if (text == 'requestor') {
						requestor = new Requestor(parser);
					} else if (text == 'parties') {
						parties = arrayOfReleaseToParty(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'Instant_DO_Wrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class HaulageInstructions {
		public String containerId {get;set;} 
		public String containerType {get;set;} 
		public String cargoType {get;set;} 
		public HaulageInstructionsDetails haulageInstructionsDetails {get;set;} 
		public HaulageOrderValidityDetails haulageOrderValidityDetails {get;set;} 
		public List<DeliveryStops> deliveryStops {get;set;} 
		public FinalDischargePort returnDepot {get;set;} 
		public String instructions {get;set;} 
		public String userInstructions {get;set;} 
		public String preferredContractor {get;set;} 

		public HaulageInstructions(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'containerId') {
							containerId = parser.getText();
						} else if (text == 'containerType') {
							containerType = parser.getText();
						} else if (text == 'cargoType') {
							cargoType = parser.getText();
						} else if (text == 'haulageInstructionsDetails') {
							haulageInstructionsDetails = new HaulageInstructionsDetails(parser);
						} else if (text == 'haulageOrderValidityDetails') {
							haulageOrderValidityDetails = new HaulageOrderValidityDetails(parser);
						} else if (text == 'deliveryStops') {
							deliveryStops = arrayOfDeliveryStops(parser);
						} else if (text == 'returnDepot') {
							returnDepot = new FinalDischargePort(parser);
						} else if (text == 'instructions') {
							instructions = parser.getText();
						} else if (text == 'userInstructions') {
							userInstructions = parser.getText();
						} else if (text == 'preferredContractor') {
							preferredContractor = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'HaulageInstructions consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DeliveryOrderPayers {
		public ReleaseToParty party {get;set;} 
		public String chargeType {get;set;} 

		public DeliveryOrderPayers(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'party') {
							party = new ReleaseToParty(parser);
						} else if (text == 'chargeType') {
							chargeType = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DeliveryOrderPayers consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class TaskStatus {
		public String avcidTaskCode {get;set;} 

		public TaskStatus(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'avcidTaskCode') {
							avcidTaskCode = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'TaskStatus consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Payers {
		public String billOfLadingId {get;set;} 
		public String carrierCode {get;set;} 
		public String customerCode {get;set;} 
		public String invoiceReference {get;set;} 
		public String updatedBy {get;set;} 
		public List<Charges> charges {get;set;} 
		public String shipmentNotes {get;set;} 
		public String placeOfDeliveryCountryCode {get;set;} 
		public String placeOfReceiptCountryCode {get;set;} 
		public TaskStatus taskStatus {get;set;} 
		public Boolean isPayerWriteSuccess {get;set;} 

		public Payers(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'billOfLadingId') {
							billOfLadingId = parser.getText();
						} else if (text == 'carrierCode') {
							carrierCode = parser.getText();
						} else if (text == 'customerCode') {
							customerCode = parser.getText();
						} else if (text == 'invoiceReference') {
							invoiceReference = parser.getText();
						} else if (text == 'updatedBy') {
							updatedBy = parser.getText();
						} else if (text == 'charges') {
							charges = arrayOfCharges(parser);
						} else if (text == 'shipmentNotes') {
							shipmentNotes = parser.getText();
						} else if (text == 'placeOfDeliveryCountryCode') {
							placeOfDeliveryCountryCode = parser.getText();
						} else if (text == 'placeOfReceiptCountryCode') {
							placeOfReceiptCountryCode = parser.getText();
						} else if (text == 'taskStatus') {
							taskStatus = new TaskStatus(parser);
						} else if (text == 'isPayerWriteSuccess') {
							isPayerWriteSuccess = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Payers consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DeliveryOrderRecipients {
		public String email {get;set;} 

		public DeliveryOrderRecipients(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'email') {
							email = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DeliveryOrderRecipients consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class FinalDischargePort {
		public String maerskGeoLocationId {get;set;} 
		public String unLocCode {get;set;} 
		public String maerskRkstCode {get;set;} 
		public String siteName {get;set;} 
		public String cityName {get;set;} 
		public String regionCode {get;set;} 
		public String regionName {get;set;} 
		public String countryName {get;set;} 
		public String countryCode {get;set;} 
		public String address {get;set;} 

		public FinalDischargePort(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'maerskGeoLocationId') {
							maerskGeoLocationId = parser.getText();
						} else if (text == 'unLocCode') {
							unLocCode = parser.getText();
						} else if (text == 'maerskRkstCode') {
							maerskRkstCode = parser.getText();
						} else if (text == 'siteName') {
							siteName = parser.getText();
						} else if (text == 'cityName') {
							cityName = parser.getText();
						} else if (text == 'regionCode') {
							regionCode = parser.getText();
						} else if (text == 'regionName') {
							regionName = parser.getText();
						} else if (text == 'countryName') {
							countryName = parser.getText();
						} else if (text == 'countryCode') {
							countryCode = parser.getText();
						} else if (text == 'address') {
							address = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'FinalDischargePort consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DeliveryStops {
		public FinalDischargePort site {get;set;} 
		public String deliveryAddress {get;set;} 
		public String deliveryFromDateTimeLocal {get;set;} 
		public String deliveryToDateTimeLocal {get;set;} 
		public String deliveryReference {get;set;} 
		public String cmdCustomerFacility {get;set;} 
		public DeliveryOrderContact deliveryOrderContact {get;set;} 

		public DeliveryStops(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'site') {
							site = new FinalDischargePort(parser);
						} else if (text == 'deliveryAddress') {
							deliveryAddress = parser.getText();
						} else if (text == 'deliveryFromDateTimeLocal') {
							deliveryFromDateTimeLocal = parser.getText();
						} else if (text == 'deliveryToDateTimeLocal') {
							deliveryToDateTimeLocal = parser.getText();
						} else if (text == 'deliveryReference') {
							deliveryReference = parser.getText();
						} else if (text == 'cmdCustomerFacility') {
							cmdCustomerFacility = parser.getText();
						} else if (text == 'deliveryOrderContact') {
							deliveryOrderContact = new DeliveryOrderContact(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'DeliveryStops consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DeliveryOrderSupportingDocuments {
		public String documentName {get;set;} 
		public String documentType {get;set;} 
		public Boolean mandatory {get;set;} 
		public String fileName {get;set;} 
		public String referenceValue {get;set;} 

		public DeliveryOrderSupportingDocuments(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'documentName') {
							documentName = parser.getText();
						} else if (text == 'documentType') {
							documentType = parser.getText();
						} else if (text == 'mandatory') {
							mandatory = parser.getBooleanValue();
						} else if (text == 'fileName') {
							fileName = parser.getText();
						} else if (text == 'referenceValue') {
							referenceValue = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DeliveryOrderSupportingDocuments consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CreditParty {
		public String id {get;set;} 
		public String name {get;set;} 

		public CreditParty(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreditParty consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Pricing {
		public String amount {get;set;} 
		public String currency_Z {get;set;} // in json: currency

		public Pricing(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'amount') {
							amount = parser.getText();
						} else if (text == 'currency') {
							currency_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Pricing consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DeliveryOrderProofOfPayment {
		public Boolean proofOfPaymentNeeded {get;set;} 
		public String fileName {get;set;} 

		public DeliveryOrderProofOfPayment(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'proofOfPaymentNeeded') {
							proofOfPaymentNeeded = parser.getBooleanValue();
						} else if (text == 'fileName') {
							fileName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DeliveryOrderProofOfPayment consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Charges {
		public String code {get;set;} 
		public String name {get;set;} 
		public String paymentTerm {get;set;} 
		public CreditParty creditParty {get;set;} 
		public CreditParty invoiceParty {get;set;} 
		public Pricing pricing {get;set;} 
		public String printableFreightLineFlag {get;set;} 
		public List<String> freightLineIdentifiers {get;set;} 
		public List<String> equipmentAssignmentIds {get;set;} 

		public Charges(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'paymentTerm') {
							paymentTerm = parser.getText();
						} else if (text == 'creditParty') {
							creditParty = new CreditParty(parser);
						} else if (text == 'invoiceParty') {
							invoiceParty = new CreditParty(parser);
						} else if (text == 'pricing') {
							pricing = new Pricing(parser);
						} else if (text == 'printableFreightLineFlag') {
							printableFreightLineFlag = parser.getText();
						} else if (text == 'freightLineIdentifiers') {
							freightLineIdentifiers = arrayOfString(parser);
						} else if (text == 'equipmentAssignmentIds') {
							equipmentAssignmentIds = arrayOfString(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Charges consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Requestor {
		public String name {get;set;} 
		public String tradingName {get;set;} 
		public String email {get;set;} 

		public Requestor(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'tradingName') {
							tradingName = parser.getText();
						} else if (text == 'email') {
							email = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Requestor consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DeliveryOrderContact {
		public String name {get;set;} 
		public String phone {get;set;} 
		public String email {get;set;} 

		public DeliveryOrderContact(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'email') {
							email = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DeliveryOrderContact consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DeliveryOrderAuthorization {
		public String fileName {get;set;} 
		public String phone {get;set;} 
		public String email {get;set;} 

		public DeliveryOrderAuthorization(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'fileName') {
							fileName = parser.getText();
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'email') {
							email = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DeliveryOrderAuthorization consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ReleaseToParty {
		public String id {get;set;} 
		public String name {get;set;} 
		public String roleCode {get;set;} 
		public String address {get;set;} 
		public String postalCode {get;set;} 
		public String poBox {get;set;} 
		public String city {get;set;} 
		public String countryName {get;set;} 
		public String countryCode {get;set;} 
		public String region {get;set;} 
		public String email {get;set;} 
		public String phone {get;set;} 
		public String taxReference {get;set;} 

		public ReleaseToParty(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'roleCode') {
							roleCode = parser.getText();
						} else if (text == 'address') {
							address = parser.getText();
						} else if (text == 'postalCode') {
							postalCode = parser.getText();
						} else if (text == 'poBox') {
							poBox = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'countryName') {
							countryName = parser.getText();
						} else if (text == 'countryCode') {
							countryCode = parser.getText();
						} else if (text == 'region') {
							region = parser.getText();
						} else if (text == 'email') {
							email = parser.getText();
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'taxReference') {
							taxReference = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ReleaseToParty consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static Instant_DO_Wrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new Instant_DO_Wrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	






    private static List<DeliveryOrderPayers> arrayOfDeliveryOrderPayers(System.JSONParser p) {
        List<DeliveryOrderPayers> res = new List<DeliveryOrderPayers>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DeliveryOrderPayers(p));
        }
        return res;
    }




    private static List<Charges> arrayOfCharges(System.JSONParser p) {
        List<Charges> res = new List<Charges>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Charges(p));
        }
        return res;
    }





    private static List<ReleaseToParty> arrayOfReleaseToParty(System.JSONParser p) {
        List<ReleaseToParty> res = new List<ReleaseToParty>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ReleaseToParty(p));
        }
        return res;
    }




    private static List<DeliveryOrderRecipients> arrayOfDeliveryOrderRecipients(System.JSONParser p) {
        List<DeliveryOrderRecipients> res = new List<DeliveryOrderRecipients>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DeliveryOrderRecipients(p));
        }
        return res;
    }


    private static List<HaulageInstructions> arrayOfHaulageInstructions(System.JSONParser p) {
        List<HaulageInstructions> res = new List<HaulageInstructions>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new HaulageInstructions(p));
        }
        return res;
    }



    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
    
    private static List<Integer> arrayOfInteger(System.JSONParser p) {
        List<Integer> res = new List<Integer>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getIntegerValue());
        }
        return res;
    }

    private static List<DeliveryStops> arrayOfDeliveryStops(System.JSONParser p) {
        List<DeliveryStops> res = new List<DeliveryStops>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DeliveryStops(p));
        }
        return res;
    }


    private static List<DeliveryOrderSupportingDocuments> arrayOfDeliveryOrderSupportingDocuments(System.JSONParser p) {
        List<DeliveryOrderSupportingDocuments> res = new List<DeliveryOrderSupportingDocuments>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DeliveryOrderSupportingDocuments(p));
        }
        return res;
    }


}