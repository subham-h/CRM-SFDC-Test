/**
 * @description
* Author   : Vivek.agrawal@Maersk
* Purpose  : Wrapper class containing methods for TPDoc Json 
  
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0      SC-5462     2-Aug-2022 Vivek.agrawal@Maersk     ShipmentEventHandlerTest() handles code coverage for this method.
   
*/

public class TpDocJsonParser {

	
	public String parserName;
	public String parserVersion;
	public List<Tag0000> tag0000;
    public String eventName;
	
	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2370 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String sequenceInEquipment;
		public String fkCargo;
		public String extCargo;
		public String weight;
		public String fkMeasureUnitWeight;
		public String measureUnitWeight;
		public String measure;
		public String fkMeasureUnitMeasure;
		public String measureUnitMeasure;
		public String packageCount;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String weightKgs;
		public String weightLbs;
		public String measureCbm;
		public String measureCbf;
		public String insideStowagePosition;
		public String fkEquipmentStuffingType;
		public String equipmentStuffingType;
		public String isOog;
		public String stuffingConfirmed;
		public List<Tag2372> tag2372;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2372 {
		public String cargoDescription;
		public String marksAndNumbers;
		public String fkManifestLines;
		public String intlHsCode;
		public String intlHsDescription;
		public String quantity;
		public String packageKind;
		public String fkMeasureUnitWeight;
		public String measureUnitWeight;
		public String weight;
		public String weightKgs;
		public String weightLbs;
		public String fkMeasureUnitMeasure;
		public String measureUnitMeasure;
		public String measure;
		public String measureCbm;
		public String measureCbf;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag21m0 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String updateStrucTime;
		public String updateStrucUser;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2411 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String textBlockSequence;
		public String text;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2510 {
		public String instanceId;
		public String taskName;
		public String fkActivityStatus;
		public String presentationSequence;
		public String timeStarted;
		public String timeDueCompleted;
		public String timeAheadReminder;
		public String timeCompleted;
		public String fkUAdmTeamResponsible;
		public String teamName;
		public String fkUAdmBusinessUnitResponsible;
		public String businessUnit;
		public String userResponsible;
		public String description;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String isActive;
		public String fkTaskStatus;
		public String taskStatus;
		public String timeStatusChanged;
		public String userStatusChanged;
		public String fkTaskDefinition;
		public String kind;
		public String fkShipmentRouteUpdatesDoc;
		public String fkTaskNesting;
		public String fkUAdmBusinessUnitDistrib;
		public String fkShipment;
		public String fkTransportDoc;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2610 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkRouteType;
		public String routeType;
		public String presentationSequence;
		public String fkRouteTypeReferenceBased;
		public String extRouteTypeReferenceBased;
		public String mepcTradeLane;
		public String isProductRouteValidated;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2310 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkQuoteContainerProperty;
		public String quantity;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String remark;
		public String fkEquipmentAvailabilityStatus;
		public String equipmentAvailabilityStatus;
		public String quoteContainerProperty;
		public String fkContPropValueRkem;
		public String gcssName;
		public String columnRkemeqcoName;
		public String contPropValueRkem;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2910_Y {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String presentationSequence;
		public String fkMarsRulesFreightType;
		public String freightType;
		public String freightRate;
		public String freightAmount;
		public String fkRateBaseType;
		public String rateBaseType;
		public String fkMarsCurrencies;
		public String marsCurrencies;
		public String fkPaymentTermType;
		public String paymentTermType;
		public String fkShipmentPartyRoleInvoice;
		public String extShipmentPartyRoleInvoice;
		public String fkCargo;
		public String extCargo;
		public String fkEquipmentRequirement;
		public String extEquipmentRequirement;
		public String currencyExchRateDateLocal;
		public String fkGeographicAreaPayAt;
		public String extGeographicAreaPayAt;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkShipmentPartyRoleCredit;
		public String fkUAdmBusinessUnitCollect;
		public String fkInvoiceRequestLineCurr;
		public String isPercentageRate;
		public String creditPartyFollowsInvoice;
		public String isManuallyAdded;
		public String isLogicallyDeleted;
		public String isVas;
		public String isFromTariff;
		public String isPrintable;
		public String invoiceSeparator;
		public String validFkInvoiceRequestLine;
		public String extShipmentPartyRoleCredit;
		public String fkShipmentPartyInvoice;
		public String fkShipmentPartyCredit;
		public String blankRateFromMars;
		public String fkInlccurrPart;
		public String inlccurrPart;
		public String fkGeoAreaCharging;
		public String geoAreaCharging;
		public String fkGeoAreaChargingState;
		public String geoAreaChargingState;
		public String fkGeoAreaChargingCountry;
		public String geoAreaChargingCountry;
		public String rkstAreaCode;
		public String rkstStateCode;
		public String rkstCountryCode;
		public String quantity;
		public String isMarsOptionalCharge;
		public String approvalRequiredForDelete;
		public String invoicePartyDefaulted;
		public String collectionUnitDefaulted;
		public String marsTariffType;
		public String marsCommodityCode;
		public String marsDangerousCode;
		public String marsBaseRateClassCode;
		public String marsExportInlandLineNumber;
		public String marsImportInlandLineNumber;
		public String marsExportInlandTransportMode;
		public String marsImportInlandTransportMode;
		public String marsBaseRateTariff;
		public String marsExportInlandTariff;
		public String marsImportInlandTariff;
		public String extShipmentPartyInvoice;
		public String extShipmentPartyCredit;
		public String fkPriceProratePercent;
		public String blankQuantityFromMars;
		public String fkGeoSiteCharging;
		public String geoSiteCharging;
		public String rkstSiteCharging;
		public String notToInvoice;
		public String originalWm;
		public String marsMinUnits;
		public String marsMaxUnits;
		public String marsMinAmount;
		public String marsMinUnitApplied;
		public String marsMaxUnitApplied;
		public String marsMinAmountApplied;
		public String marsSumAmountCcy;
		public String marsValidFrom;
		public String marsValidTo;
		public String isMarsModified;
		public String lineNumber;
		public String aggregationIdCargoLevel;
		public String aggregationIdDocumentLevel;
		public String fkFlinvoiceDetailsUpdatedby;
		public List<Tag2913> tag2913;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2410 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkCargoDescriptionType;
		public String cargoDescriptionType;
		public String presentationSequence;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String cargoDescStrucUpdateTime;
		public String cargoDescStrucUpdateUser;
		public List<Tag2411> tag2411;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2630 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkRoutePointStart;
		public String extRoutePointStart;
		public String fkRoutePointEnd;
		public String extRoutePointEnd;
		public String departureTimeLocalExpected;
		public String arrivalTimeLocalExpected;
		public String fkMepcTransportMode;
		public String mepcTransportMode;
		public String fkGeoAreaDesiredFlag;
		public String geoAreaDesiredFlag;
		public String mepcLinkId;
		public String transitTime;
		public String routingType;
		public String hasProductLimitation;
		public String isOutOfContractScope;
		public String rkstCarrierCode;
		public String blockStowageCode;
		public String scheduleSelectMethod;
		public String limitGrossWeight;
		public String limitValidDateFromLocal;
		public String limitValidDateToLocal;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String waterLandMode;
		public String fkRkstvesPartVehicle;
		public String vehicleIdAltText;
		public String vehicleVoyageNumber;
		public String foreignCarrierName;
		public String rkstvesPartVehicle;
		public String fkGeoAreaOptionalDischarge;
		public String geoAreaOptionalDischarge;
		public String rkstOptionalDischargeCode;
		public String fkGeoAreaOptionalDischargeState;
		public String geoAreaOptionalDischargeState;
		public String rkstOptionalDischargeCodeState;
		public String fkGeoAreaOptionalDischargeCountry;
		public String geoAreaOptionalDischargeCountry;
		public String rkstOptionalDischargeCodeCountry;
		public String vehicleVoyageNumberArrive;
		public String departureTimeUtcExpected;
		public String arrivalTimeUtcExpected;
		public String translatedVesselName;
		public String translatedVoyageNumber;
		public String translatedVesselArriveName;
		public String translatedVoyageArriveNumber;
		public String fkRkstvesPartVehicleArrive;
		public String isRkstvesPartAsProduct;
		public String isArrivalTimeRevised;
		public String isReadyForLoad;
		public String serviceCode;
		public String isSteeredLeg;
		public String isDepartureTimeRevised;
		public String ownerCompany;
		public String vesselFlag;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2910_Z {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String presentationSequence;
		public String fkMarsRulesFreightType;
		public String freightType;
		public String freightRate;
		public String freightAmount;
		public String fkRateBaseType;
		public String rateBaseType;
		public String fkMarsCurrencies;
		public String marsCurrencies;
		public String fkPaymentTermType;
		public String paymentTermType;
		public String fkShipmentPartyRoleInvoice;
		public String extShipmentPartyRoleInvoice;
		public String fkCargo;
		public String extCargo;
		public String fkEquipmentRequirement;
		public String extEquipmentRequirement;
		public String currencyExchRateDateLocal;
		public String fkGeographicAreaPayAt;
		public String extGeographicAreaPayAt;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkShipmentPartyRoleCredit;
		public String fkUAdmBusinessUnitCollect;
		public String fkInvoiceRequestLineCurr;
		public String isPercentageRate;
		public String creditPartyFollowsInvoice;
		public String isManuallyAdded;
		public String isLogicallyDeleted;
		public String isVas;
		public String isFromTariff;
		public String isPrintable;
		public String invoiceSeparator;
		public String validFkInvoiceRequestLine;
		public String extShipmentPartyRoleCredit;
		public String fkShipmentPartyInvoice;
		public String fkShipmentPartyCredit;
		public String blankRateFromMars;
		public String fkInlccurrPart;
		public String inlccurrPart;
		public String fkGeoAreaCharging;
		public String geoAreaCharging;
		public String fkGeoAreaChargingState;
		public String geoAreaChargingState;
		public String fkGeoAreaChargingCountry;
		public String geoAreaChargingCountry;
		public String rkstAreaCode;
		public String rkstStateCode;
		public String rkstCountryCode;
		public String quantity;
		public String isMarsOptionalCharge;
		public String approvalRequiredForDelete;
		public String invoicePartyDefaulted;
		public String collectionUnitDefaulted;
		public String marsTariffType;
		public String marsCommodityCode;
		public String marsDangerousCode;
		public String marsBaseRateClassCode;
		public String marsExportInlandLineNumber;
		public String marsImportInlandLineNumber;
		public String marsExportInlandTransportMode;
		public String marsImportInlandTransportMode;
		public String marsBaseRateTariff;
		public String marsExportInlandTariff;
		public String marsImportInlandTariff;
		public String extShipmentPartyInvoice;
		public String extShipmentPartyCredit;
		public String fkPriceProratePercent;
		public String blankQuantityFromMars;
		public String fkGeoSiteCharging;
		public String geoSiteCharging;
		public String rkstSiteCharging;
		public String notToInvoice;
		public String originalWm;
		public String marsMinUnits;
		public String marsMaxUnits;
		public String marsMinAmount;
		public String marsMinUnitApplied;
		public String marsMaxUnitApplied;
		public String marsMinAmountApplied;
		public String marsSumAmountCcy;
		public String marsValidFrom;
		public String marsValidTo;
		public String isMarsModified;
		public String lineNumber;
		public String aggregationIdCargoLevel;
		public String aggregationIdDocumentLevel;
		public String fkFlinvoiceDetailsUpdatedby;
		public List<Tag2913> tag2913;
		public List<Tag2915> tag2915;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2624 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String act;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag23j0 {
		public String instanceId;
		public String fkEquipmentAssignment;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkExportTransportMode;
		public String exportMotDescription;
		public String fkImportTransportMode;
		public String importMotDescription;
		public String kind;
		public String extReferenceId;
		public String keyExchangeId;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2900 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkCargo;
		public String extCargo;
		public String fkPriceStrategyType;
		public String priceStrategyType;
		public String fkMarsRateBases;
		public String marsRateBases;
		public String fkTariff;
		public String tariff;
		public String fkServiceContract;
		public String extServiceContract;
		public String fkPaymentTermTypePrimary;
		public String paymentTermTypePrimary;
		public String fkEquipmentRequirement;
		public String equipmentRequirement;
		public String fkShipmentVersion;
		public String extShipmentVersion;
		public String fkRouteTypeReference;
		public String extRouteTypeReference;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkPriceAggregateType;
		public String priceAggregateType;
		public String fkEquipmentStuffing;
		public String serviceContractLine;
		public String extEquipmentStuffing;
		public String shipmentIdCopiedFrom;
		public String marsExportInlandLineNumber;
		public String marsImportInlandLineNumber;
		public String marsExportInlandTransportMode;
		public String marsImportInlandTransportMode;
		public String marsBaseRateTariff;
		public String marsExportInlandTariff;
		public String marsImportInlandTariff;
		public String fkTransportDocVersionIn;
		public List<Tag2910> tag2910;
		public List<Tag2920> tag2920;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag23h0 {
		public String instanceId;
		public String fkShipmentVersion;
		public String fkEquipmentAssignment;
		public String departureTimeUtcExpected;
		public String fkRouteUpdateHistory;
		public String isRolledByVesselSchedule;
		public String isOriginalTime;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String rollUpdateTime;
		public String rollUpdateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2620_Z {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String pointSequence;
		public String fkGeographicArea;
		public String geographicArea;
		public String geographicAreaAltText;
		public String fkGeoSite;
		public String geoSite;
		public String fkGeoAreaCountry;
		public String geoAreaCountry;
		public String carrierCustomerPoint;
		public String layoverTime;
		public String exportStackTimeLocalOpen;
		public String exportStackTimeLocalClose;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkGeoAreaState;
		public String geoAreaState;
		public String rkstStateCode;
		public String rkstCountryCode;
		public String rkstCityCode;
		public String rkstSiteCode;
		public List<Tag2621> tag2621;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2240 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String address1;
		public String address2;
		public String address3;
		public String addressName;
		public String city;
		public String country;
		public String dodaacId;
		public String emailAddress;
		public String fax;
		public String fkHaulageSite;
		public String extHaulageSite;
		public String fkShipmentParty;
		public String extShipmentParty;
		public String importFax;
		public String name;
		public String phone;
		public String poBox;
		public String printableAddress1;
		public String printableAddress2;
		public String printableAddress3;
		public String printableAddress4;
		public String state;
		public String streetNo;
		public String url;
		public String zipCity;
		public String zipCode;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2120 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkShipmentPartyOwner;
		public String extShipmentPartyOwner;
		public String fkHiLevelPartyOwner;
		public String extHiLevelPartyOwner;
		public String sequenceInOwnerObject;
		public String fkEntityTypeReferenceType;
		public String entityTypeReferenceType;
		public String referenceEntityIdentifier;
		public String extReferenceEntityIdentifier;
		public String referenceString;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkShipmentVersion;
		public String extShipmentVersion;
		public String fkTransportDocVersion;
		public String extTransportDocVersion;
		public String fkEntityType;
		public String entityType;
	}


	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2400 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String presentationSequence;
		public String weight;
		public String weightPricing;
		public String fkMeasureUnitWeight;
		public String measureUnitWeight;
		public String measure;
		public String measurePricing;
		public String fkMeasureUnitMeasure;
		public String measureUnitMeasure;
		public String fkReceiptDeliverModeRec;
		public String receiptDeliveryModeRec;
		public String fkReceiptDeliveryModeDel;
		public String receiptDeliveryModeDel;
		public String fkMarsCommodity;
		public String fkBookingLine;
		public String extBookingLine;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkCargoApprovalStatus;
		public String cargoApprovalStatus;
		public String fkRateBaseStrategyType;
		public String rateBaseStrategyType;
		public String weightKgs;
		public String weightLbs;
		public String weightPricingKgs;
		public String weightPricingLbs;
		public String measureCbm;
		public String measureCbf;
		public String measurePricingCbm;
		public String measurePricingCbf;
		public String fkMarsCommoditiesCustomer;
		public String weightNet;
		public String measureNet;
		public String weightNetKgs;
		public String weightNetLbs;
		public String measureNetCbm;
		public String measureNetCbf;
		public String marsCommodity;
		public String marsCommodityCustomer;
		public String fkShipmentVersion;
		public String fkTransportDocVersion;
		public String extShipmentVersion;
		public String extTransportDocumentVersion;
		public String isShortShipped;
		public String fkShipmentVersionPrice;
		public String customerSpecifiedHsCode;
		public String fkCommodityGroup;
		public String commodityGroup;
		public String commodityGroupDescription;
		public List<Tag2410> tag2410;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2620 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String pointSequence;
		public String fkGeographicArea;
		public String geographicArea;
		public String geographicAreaAltText;
		public String fkGeoSite;
		public String geoSite;
		public String fkGeoAreaCountry;
		public String geoAreaCountry;
		public String carrierCustomerPoint;
		public String layoverTime;
		public String exportStackTimeLocalOpen;
		public String exportStackTimeLocalClose;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkGeoAreaState;
		public String geoAreaState;
		public String rkstStateCode;
		public String rkstCountryCode;
		public String rkstCityCode;
		public String rkstSiteCode;
		public List<Tag2621> tag2621;
		public List<Tag2623> tag2623;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tags100 {
		public String shipmentInstanceId;
		public String shipmentVersionInstanceId;
		public String lineCode;
		public String fkReceiptDeliveryModeRec;
		public String receiptDeliveryModeRec;
		public String fkReceiptDeliveryModeDel;
		public String receiptDeliveryModeDel;
		public String fkShipmentClass;
		public String shipmentClass;
		public String cargoReadyTimeLocal;
		public String isCargoReadyDateOnly;
		public String cargoDeliveryTimeLocal;
		public String isCargoDeliveryDateOnly;
		public String bookingSegmentation;
		public String bookingSegmentationText;
		public String fkScvCustomerSegmentLocked;
		public String vipClass;
		public String scvVipclassLocked;
		public String priceCalcBaseDateLocal;
		public String appliesSc;
		public String scIdentifiedByMars;
		public String priceBasedOnTariff;
		public String fkPriceAggregateTypeInvoice;
		public String priceAggregateTypeInvoice;
		public String transpDocUsesShipmentDesc;
		public String priceMustBasedSc;
		public String statusUpdateTime;
		public String isConferencePriced;
		public String dgdreceived;
		public String completePriceShipment;
		public String shipmentUpdateStrucTime;
		public String shipmentUpdateStrucUser;
		public String fkCommunicationMediaType;
		public String communicationMediaType;
		public String fkBusinessSystemSource;
		public String businessSystemSource;
		public String extShipment;
		public String extShipmentVersion;
		public String relatedTpdocs;
		public String transportHandlerRole;
		public String timeCommenced;
		public String uAdmTeamAssigned;
		public String teamName;
		public String fkBusinessUnit;
		public String businessUnit;
		public String businessAddress;
		public String businessUnitCode;
		public String businessUnitCityRkstCode;
		public String shipmentCreateTime;
		public String readyInvoiceDetailsPrepaid;
		public String readyInvoiceDetailsCollect;
		public String fkMarsRatebasesProrate;
		public String originalShipmentCreateTime;
		public String fkDeliveryAgreementType;
		public String deliveryAgreementType;
		public String fkGeographicAreaCountry;
		public String geographicAreaCountryCode;
		public String geographicAreaCountryName;
		public String directionIndicator;
		public String isLogicallyCompleted;
		public String isPricedByAfls;
		public String isFmcRegulated;
		public String isSpotShipment;
		public String deliveryAgreementTypeDisplayname;
		public String fkBusinessProductType;
		public String businessProductTypeDescription;
		public String fkBusinessProductGroup;
		public String businessProductGroupDescription;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2500 {
		public List<Tag2510> tag2510;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2621 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkRoutePointRoleType;
		public String routePointRoleType;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0000 {
		public String dateSent;
		public String timeSent;
		public String sender;
		public String receiver;
		public String messageReference;
		public String applicationReference;
		public String gcssReference;
		public String kind;
		public String dateReceived;
		public String timeReceived;
		public String replyRequested;
		public String messageTypeCode;
		public String testFlag;
		public String ediReceiver;
		public String ediAppRefNum;
		public String version;
		public List<Tags100> tags100;
		public List<Tag2100> tag2100;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2600 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String isThroughRoute;
		public String isCompositeRoute;
		public String routeStrucUpdateTime;
		public String routeStrucUpdateUser;
		public String fkMepcTradeLaneOperator;
		public String fkMepcTradeLaneCode;
		public String mepcTradeLane;
		public String earliestDepartureDate;
		public String latestArrivalDate;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String timeUpdateStructure;
		public String userUpdateStructure;
		public String fkGeoSite1stOptionalDischarge;
		public String fkGeoArea1stOptionalDischarge;
		public String geographicAreaAltText1stOptionalDischarge;
		public String fkGeoArea1stOptionalDischargeState;
		public String geoArea1stOptionalDischargeState;
		public String fkGeoArea1stOptionalDischargeCountry;
		public String geoArea1stOptionalDischargeCountry;
		public String rkst1stOptionalDischargeStateCode;
		public String rkst1stOptionalDischargeCountryCode;
		public String rkst1stOptionalDischargeCityCode;
		public String rkst1stOptionalDischargeSiteCode;
		public String fkShipmentVersion;
		public String extShipmentVersion;
		public String fkRouteUpdateHistoryLatest;
		public List<Tag2610> tag2610;
		public List<Tag2620> tag2620;
		public List<Tag2630> tag2630;
		public List<Tag2640> tag2640;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2623 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String actLocRkem;
		public String fkActivityTask;
		public String extActivityTask;
		public String fkContActTemplate;
		public String extContActTemplate;
		public String fkRoutePoint;
		public String extRoutePoint;
		public String timeExpectedLocal;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String actfor;
		public String stemptyRkem;
		public List<Tag2624> tag2624;
		public String fkMepcTransportModeLink;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2920 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkPricePurposeType;
		public String pricePurposeType;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2220 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String custno;
		public String contactPersonName;
		public String phoneNo;
		public String faxNo;
		public String emailAddress;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String presentationSequence;
		public String contactName;
		public String jobTitle;
		public String phone;
		public String fax;
		public String email;
		public String cellPhone;
		public String initials;
		public String sex;
		public String homePhone;
		public String homeEmail;
		public String extCmdContactId;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2100 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String updateStrucTime;
		public String updateStrucUser;
		public String isIssued;
		public String isHitchment;
		public String isSwitch;
		public String fkUAdmOperatorOwner;
		public String uAdmOperatorOwner;
		public String fkCommunicationMediaTypeSi;
		public String communicationMediaTypeSi;
		public String documentClassId;
		public String documentClass;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String versionCreateTime;
		public String versionCreateUser;
		public String versionUpdateTime;
		public String versionUpdateUser;
		public String fkShipmentVersionProduct;
		public String loadPortRoutePointSequence;
		public String fkDocumentType;
		public String documentType;
		public String fkCommunicationMediaTypeDi;
		public String communicationMediaTypeDi;
		public String fkTransportDocMaster;
		public String isHouse;
		public String isTransportDocLevelPrinting;
		public String fkUAdmTeamAssigned;
		public String teamName;
		public String fkBusinessUnit;
		public String businessUnit;
		public String businessUnitCode;
		public String isHouseMaster;
		public String transportDocVersionInstanceId;
		public String fkTpdocAddressGroup;
		public String userAssigned;
		public String isCscsIssued;
		public String extShipmentVersionProduct;
		public String extTpDocAddressGroup;
		public String uAdmOperatorOwnerScac;
		public String fkBusinessSystemInvoice;
		public String businessSystemInvoice;
		public String isImportShipmentTpdoc;
		public String isOnceIssued;
		public String preventAutoIssue;
		public String useRfsPort;
		public String complianceRequired;
		public String advancedManifestWarning;
		public String fkShipmentVersionPricing;
		public List<Tag2120> tag2120;
		public List<Tag21c0> tag21c0;
		public List<Tag21m0> tag21m0;
		public List<Tag2200> tag2200;
		public List<Tag2300> tag2300;
		public List<Tag2400> tag2400;
		public List<Tag2500> tag2500;
		public List<Tag2600> tag2600;
		public List<Tag2900> tag2900;
		public List<Tag2d00> tag2d00;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2200 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String custno;
		public String name;
		public String address;
		public String cuname;
		public String cuadr1;
		public String cuadr2;
		public String cuadr3;
		public String cuadr4;
		public String fkGeoAreaCityCode;
		public String cityName;
		public String state;
		public String zipCode;
		public String countryCode;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String countryName;
		public String addressName;
		public String streetNo;
		public String poBox;
		public String phone;
		public String fax;
		public String importFax;
		public String emailAddress;
		public String url;
		public String docAddress;
		public String fkPartyRoleSpecialText;
		public String partyRoleSpecialText;
		public String fkPaymentTermTypeAutoPop;
		public String paymentTermTypeAutoPop;
		public String fkPartyRoleType;
		public String partyRoleType;
		public String printableAddress1;
		public String printableAddress2;
		public String printableAddress3;
		public String printableAddress4;
		public String fkGeoAreaCityId;
		public String geoAreaCityName;
		public String rkstCityCode;
		public String fkGeoAreaCountryId;
		public String geoAreaCountryName;
		public String rkstCountryCode;
		public String fkShipmentVersion;
		public String extShipmentVersion;
		public String fkTransportDocVersion;
		public String extTransportDocVersion;
		public String dodaacId;
		public String fofmc;
		public String negotiableBl;
		public String nonNegotiableWaybill;
		public String customsId;
		public String extCmdCustomerId;
		public List<Tag2220> tag2220;
		public List<Tag2240> tag2240;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2640 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String productPropertyType;
		public String operator;
		public String propertyValue;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkProductPropType;
		public String productPropType;
		public String propertyValueString;
		public String propertyValueDate;
		public String propertyValueNumber;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2300 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String sequenceInRequirement;
		public String fkRkemeqbc;
		public String rkemeqbcAltText;
		public String fkQuoteContainerType;
		public String quoteContainerType;
		public String quoteContainerSize;
		public String weightCustomer;
		public String fkMeasureUnitWeightCustomer;
		public String measureUnitWeightCustomer;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkSpaceAllocationStatus;
		public String spaceAllocationStatus;
		public String weightCustomerKgs;
		public String weightCustomerLbs;
		public String fkContTypeRkem;
		public String contTypeRkem;
		public String contSizeRkem;
		public String isoCodeMessage;
		public String equipmentTareWeightLbs;
		public String equipmentTareWeightKgs;
		public String equipmentGrossWeightLbs;
		public String equipmentGrossWeightKgs;
		public String isShipperOwned;
		public String isVented;
		public String isFinallyStuffed;
		public String fkShipmentVersionHistory;
		public String hderDeclarationReceived;
		public String isShortShipped;
		public String fkShipmentVersion;
		public String extShipmentVersion;
		public String extShipmentVersionHistory;
		public String fkMarsRatebasesProrate;
		public String weightRkemScaledKgs;
		public String weightRkemScaledLbs;
		public String weightTotalCargoMostReliableKgs;
		public String weightTotalCargoMostReliableLbs;
		public String verifiedGrossMassStatus;
		public String verifiedGrossMass;
		public String fkVerifiedGrossMassSourceFlag;
		public String verifiedGrossMassSourceFlag;
		public String fkMeasureUnitVerifiedGrossMass;
		public List<Tag2310> tag2310;
		public List<Tag2370> tag2370;
		public List<Tag23e0> tag23e0;
		public List<Tag23h0> tag23h0;
		public List<Tag23j0> tag23j0;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2915 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkShipmentApproval;
		public String fkPriceElement;
		public String isAcceptable;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag21c0 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkCargoPackageOuterPackage;
		public String extCargoPackageOuterPackage;
		public String presentationSequence;
		public String isFinestLevel;
		public String packageCount;
		public String fkPackageStyle;
		public String packageStyle;
		public String packageStyleAltText;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkPackageDescriptionType;
		public String packageDescriptionType;
		public String fkMeasureUnitWeightGross;
		public String measureUnitWeightGross;
		public String weightGross;
		public String weightGrossKgs;
		public String weightGrossLbs;
		public String fkMeasureUnitMeasure;
		public String measureUnitMeasure;
		public String measureGross;
		public String measureGrossCbm;
		public String measureGrossCbf;
		public String fkMeasureUnitWeightNet;
		public String measureUnitWeightNet;
		public String weightNet;
		public String weightNetKgs;
		public String weightNetLbs;
		public String fkCargo;
		public String extCargo;
		public String fkEquipmentAssignment;
		public String extEquipmentAssignment;
		public String hderDeclarationBreakBulkReceived;
		public String fkShipmentVersion;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag23e0 {
		public String fkMeasureUnitWeight;
		public String measureUnitWeight;
		public String totalWeight;
		public String totalWeightKgs;
		public String totalWeightLbs;
		public String fkMeasureUnitMeasure;
		public String measureUnitMeasure;
		public String totalMeasure;
		public String totalMeasureCbm;
		public String totalMeasureCbf;
		public String totalPackageCount;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2910 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String presentationSequence;
		public String fkMarsRulesFreightType;
		public String freightType;
		public String freightRate;
		public String freightAmount;
		public String fkRateBaseType;
		public String rateBaseType;
		public String fkMarsCurrencies;
		public String marsCurrencies;
		public String fkPaymentTermType;
		public String paymentTermType;
		public String fkShipmentPartyRoleInvoice;
		public String extShipmentPartyRoleInvoice;
		public String fkCargo;
		public String extCargo;
		public String fkEquipmentRequirement;
		public String extEquipmentRequirement;
		public String currencyExchRateDateLocal;
		public String fkGeographicAreaPayAt;
		public String extGeographicAreaPayAt;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkShipmentPartyRoleCredit;
		public String fkUAdmBusinessUnitCollect;
		public String fkInvoiceRequestLineCurr;
		public String isPercentageRate;
		public String creditPartyFollowsInvoice;
		public String isManuallyAdded;
		public String isLogicallyDeleted;
		public String isVas;
		public String isFromTariff;
		public String isPrintable;
		public String invoiceSeparator;
		public String validFkInvoiceRequestLine;
		public String extShipmentPartyRoleCredit;
		public String fkShipmentPartyInvoice;
		public String fkShipmentPartyCredit;
		public String blankRateFromMars;
		public String fkInlccurrPart;
		public String inlccurrPart;
		public String fkGeoAreaCharging;
		public String geoAreaCharging;
		public String fkGeoAreaChargingState;
		public String geoAreaChargingState;
		public String fkGeoAreaChargingCountry;
		public String geoAreaChargingCountry;
		public String rkstAreaCode;
		public String rkstStateCode;
		public String rkstCountryCode;
		public String quantity;
		public String isMarsOptionalCharge;
		public String approvalRequiredForDelete;
		public String invoicePartyDefaulted;
		public String collectionUnitDefaulted;
		public String marsTariffType;
		public String marsCommodityCode;
		public String marsDangerousCode;
		public String marsBaseRateClassCode;
		public String marsExportInlandLineNumber;
		public String marsImportInlandLineNumber;
		public String marsExportInlandTransportMode;
		public String marsImportInlandTransportMode;
		public String marsBaseRateTariff;
		public String marsExportInlandTariff;
		public String marsImportInlandTariff;
		public String extShipmentPartyInvoice;
		public String extShipmentPartyCredit;
		public String fkPriceProratePercent;
		public String blankQuantityFromMars;
		public String fkGeoSiteCharging;
		public String geoSiteCharging;
		public String rkstSiteCharging;
		public String notToInvoice;
		public String originalWm;
		public String marsMinUnits;
		public String marsMaxUnits;
		public String marsMinAmount;
		public String marsMinUnitApplied;
		public String marsMaxUnitApplied;
		public String marsMinAmountApplied;
		public String marsSumAmountCcy;
		public String marsValidFrom;
		public String marsValidTo;
		public String isMarsModified;
		public String lineNumber;
		public String aggregationIdCargoLevel;
		public String aggregationIdDocumentLevel;
		public List<Tag2913> tag2913;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2913 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkPriceElementSum;
		public String fkPriceElementDetail;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String extPriceElementSum;
		public String extPriceElementDetail;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag2d00 {
		public String shipmentNumber;
		public String reasonCategory;
		public String reasonCode;
		public String reasonDescription;
		public String freeText;
		public String routeUpdateUser;
		public String routeUpdateTime;
		public String routeType;
		public String linkToStatisticTable;
		public String createUser;
		public String createTime;
		public String updateUser;
		public String updateTime;
		public String fkRoute;
		public String instanceId;
		public String reasonCustomerView;
		public String reasonDetailsCustomerView;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	 * @param json accept the json data
	 * @return json parser for shipment
	*/	
	public static TpDocJsonParser parse(String json) {
		return (TpDocJsonParser) System.JSON.deserialize(json, TpDocJsonParser.class);
	}
}