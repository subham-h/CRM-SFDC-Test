/**
 * @description
* Author   : Vivek.agrawal@Maersk
* Purpose  : Wrapper class containing methods for ShipmentJson 
  
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0      SC-5462     2-Aug-2022    Vivek.agrawal@Maersk    ShipmentEventHandlerTest() handles code coverage for this method.
* 2.0      SC-7136     27-Feb-2023   Vivek Agarwal           Updated to consume tag01g0 and field ShipmentPropertyTypeRoot
* 3.0      SC-9950     19-March-2024 Vivek Agarwal           Updated to consume tag0900 and tag0910
*/

public class ShipmentJsonParser {
  

	public String parserName;
	public String parserVersion;
	public List<Tag0000> tag0000;
	public String eventName;
	
	/** 
	 * @description | SC-5462  Tag0191 Details|
	*/
	public class Tag0191 {
		public String instanceId;
		public String fkShipmentPartyRoleReceive;
		public String fkScvCustnoRecipient;
		public String receivingSystem;
		public String recipientAltText;
		public String fkDocumentTypeMedia;
		public String recipientAttention;
		public String eMailAddress;
		public String faxNumber;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkContAnnounceReceiver;
		public String transactionType;
		public String fkShipmentPartyReceive;
		public String kind;
	}

	/** 
	 * @description | SC-5462  Tag0190 Details|
	*/
	public class Tag0190 {
		public String instanceId;
		public String fkDocumentType;
		public String documentType;
		public String referenceEntityIdentifier;
		public String timeIssue;
		public String issueReferenceString;
		public String transactionType;
		public String fkDocumentIssuePrevious;
		public String internalComment;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String reasonText;
		public String documentClassId;
		public String documentClassName;
		public String kind;
		public String fkshipmentVersion;
		public List<Tag0191> tag0191;
	}

	//SC-7136

	public class Tag01g0 {

		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkShipmentPropTypeObject;
		public String shipmentPropTypeObject;
		public String propertyObjectIdentifier;
		public String fkShipmentPropTypeValue;
		public String shipmentPropTypeValue;
		public String valueString;
		public String valueNumber;
		public String valueDateTime;
		public String valueBoolean;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkGeoAreaScope;
		public String fkGeoSiteScope;
		public String fkRoutePointRoleTypeScope;
		public String routePointRoleTypeScope;
		public String geoAreaScope;
		public String rkstAreaScopeCode;
		public String fkGeoAreaScopeState;
		public String geoAreaScopeState;
		public String rkstAreaScopeStateCode;
		public String fkGeoAreaScopeCountry;
		public String geoAreaScopeCountry;
		public String rkstAreaScopeCountryCode;
		public String geoSiteScope;
		public String rkstSiteScopeCountry;
		public String fkShipmentVersion;
		public String extShipmentVersion;
		public String fkTransportDocVersion;
		public String extTransportDocVersion;
		public String extPropertyObjectIdentifier;
		public String fkentityType;
		public String entityType;
		public String fkshipmentPropertyTypeRoot;
		public String shipmentPropertyTypeRoot;
		public String fkTaskNestingPriorTo;
		public String isValueToBeSpecified;
		//public Object taiwanUniqueHack;
		//public Object tcnAutoGenerate;
		//public Object tag01g1;
	
	}	

	/** 
	 * @description | SC-5462  Tag01u1 Details|
	*/
	public class Tag01u1 {
		public String instanceId;
		public String fkShipmentCommitment;
		public String commitmentId;
		public String commitmentType;
		public String commitmentWeek;
		public String isConcernCode;
		public String contractValidityFrom;
		public String contractValidityTo;
		public String committedFfeWeek;
		public String consumedFfeWeek;
		public String committedFfePeriod;
		public String consumedFfePeriod;
		public String commitUptakeAcceptCode;
		public String commitUptakeAcceptDesc;
		public String commitValidationOutcomeCode;
		public String commitValidationOutcomeDesc;
		public String committedFfeShipment;
		public String notCommittedFfeShipment;
		public String unusedFfeWeek;
		public String unusedFfePeriod;
		public String commitmentStatus;
		public String presentationSequence;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public List<Tag01u2> tag01u2;
	}

	/** 
	 * @description | SC-5462  Tagt100 Details|
	*/
	public class Tagt100 {
		public String transportDocumentInstanceId;
		public String transportDocumentVersionInstanceId;
		public String transportDocumentExtReferenceId;
		public String transportDocumentVersionExtReferenceId;
		public String isIssued;
		public String isCscsIssued;
		public String invoiceVersionNumber;
		public String complianceRequired;
		public String advancedManifestWarning;
		public String invoiceVersionNumberCollect;
		public String invoiceVersionNumberPrepaid;
		public String fkShipmentVersionPricing;
	}

	/** 
	 * @description | SC-5462  Tag0150 Details|
	*/
	public class Tag0150 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkApprovalType;
		public String approvalType;
		public String approvalObjectEntity;
		public String isExternalApproval;
		public String fkUAdmTeamApprover;
		public String uAdmTeamApprover;
		public String fkApprovalPartyType;
		public String approvalPartyType;
		public String externalApproverName;
		public String statusTimestamp;
		public String fkApprovalState;
		public String approvalState;
		public String cargoDetailReady;
		public String hitchLevel;
		public String timeDueApproval;
		public String noteToExternalApprover;
		public String isCurrent;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String dgdIndexingConfirmedViaEdi;
	}

		/** 
	 * @description | SC-5462  Tag01u0 Details|
	*/
	public class Tag01u0 {
		public String instanceId;
		public String fkShipmentVersion;
		public String shipmentUptakeAcceptCode;
		public String shipmentUptakeAcceptDesc;
		public String shipmentValidationOutcomeCode;
		public String shipmentValidationOutcomeDesc;
		public String statusCode;
		public String statusCodeMessage;
		public String largeBookingLimitFfe;
		public String uptakeManagerCondition;
		public String validationWarnings;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public List<Tag01u1> tag01u1;
	}

		/** 
	 * @description | SC-5462  Tag0370 Details|
	*/
	public class Tag0370 {
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
		public List<Tag0372> tag0372;
	}

	
		/** 
	 * @description | SC-5462  Tag0110 Details|
	*/
	public class Tag0110 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkTransportHandlerRole;
		public String transportHandlerRole;
		public String timeCommenced;
		public String fkOperatorUnitAssigned;
		public String operatorUnitAssigned;
		public String fkUserDefinitionAssigned;
		public String userDefinitionAssigned;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String uAdmTeamAssigned;
		public String teamName;
		public String uAdmUserAccountAssigned;
		public String userAccount;
		public String fkBusinessUnit;
		public String businessUnit;
		public String businessAddress;
		public String businessUnitCode;
		public String fkGeographicAreaCountry;
		public String geographicAreaCountryCode;
		public String geographicAreaCountryName;
        

	}

	
		/** 
	 * @description | SC-5462  Tag01u2Details|
	*/
	public class Tag01u2 {
		public String instanceId;
		public String fkCommitmentDetails;
		public String consumptionId;
		public String equipmentSizeTypeHeight;
		public String equipmentCount;
		public String ffeConsumed;
		public String ffeNotConsumed;
		public String equipUptakeAcceptCode;
		public String equipUptakeAcceptDesc;
		public String equipValidationOutcomeCode;
		public String equipValidationOutcomeDesc;
		public String bucketCylimit;
		public String cyCurrencyIsocd;
		public String tariffRateValue;
		public String ppuCurrencyIsocd;
		public String rateType;
		public String bucketColourCode;
		public String nextBucketColourCode;
		public String presentationSequence;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

	
		/** 
	 * @description | SC-5462  Tag0372 Details|
	*/
	public class Tag0372 {
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
	}

	
		/** 
	 * @description | SC-5462  Tag0610 Details|
	*/
	public class Tag0610 {
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
	 * @description | SC-5462  Tag0411 Details|
	*/
	public class Tag0411 {
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
	 * @description | SC-5462  Tag0510 Details|
	*/
	public class Tag0510 {
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
	}

	
		/** 
	 * @description | SC-5462  Tag0410 Details|
	*/
	public class Tag0410 {
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
		public List<Tag0411> tag0411;
	}

	
		/** 
	 * @description | SC-5462  Tag0630 Details|
	*/
	public class Tag0630 {
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
	 * @description | SC-5462  Tag0310 Details|
	*/
	public class Tag0310 {
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
	 * @description | SC-5462  Tag03j0 Details|
	*/
	public class Tag03j0 {
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
	 * @description | SC-5462  Tag0624 Details|
	*/
	public class Tag0624 {
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
	 * @description | SC-5462  Tag0623 Details|
	*/
	public class Tag0623 {
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
		public List<Tag0624> tag0624;
		public String fkMepcTransportModeLink;
	}

	
		/** 
	 * @description | SC-5462  Tag0600 Details|
	*/
	public class Tag0600 {
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
		public List<Tag0610> tag0610;
		public List<Tag0620> tag0620;
		public List<Tag0630> tag0630;
		public List<Tag0640> tag0640;
	}

	
		/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag03h0 {
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
	public class Tag0a30 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkHaulageArrangeEquipment;
		public String extHaulageArrangeEquipment;
		public String sequenceInEquipment;
		public String fkHaulageSiteDepart;
		public String extHaulageSiteDepart;
		public String fkHaulageSiteArrive;
		public String extHaulageSiteArrive;
		public String timingDepartFromLocal;
		public String timingDepartToLocal;
		public String timingArriveFromLocal;
		public String timingArriveToLocal;
		public String truckerPreference;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkHaulageSiteVisit;
		public String extHaulageSiteVisit;
		public String fkHaulageArrangementDepot;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0a10 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkEquipmentAssignment;
		public String extEquipmentAssignment;
		public String fkOperationalStage;
		public String operationalStage;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag01x0 {
		public String instanceId;
		public String fkShipmentVersion;
		public String fkDocumentType;
		public String documentType;
		public String fkTransportDocVersion;
		public String docBrokerUniqueId;
		public String fkScvCustnoRecipient;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0260 {
		public String instanceId;
		public String cmdCustomerCode;
		public String segmentTypeCode;
		public String segmentValueName;
		public String segmentValueCode;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0160 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkShipmentDescriptionType;
		public String shipmentDescriptionType;
		public String presentationSequence;
		public String text;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkShipmentVersion;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0100 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkOperatorKey;
		public String operatorKey;
		public String fkShipmentDomain;
		public String shipmentDomain;
		public String fkShipmentStatus;
		public String shipmentStatus;
		public String fkShipmentClass;
		public String shipmentClass;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String updateStrucTime;
		public String updateStrucUser;
		public String fkUAdmOperatorOwner;
		public String uAdmOperatorOwner;
		public String versionCreateTime;
		public String versionCreateUser;
		public String versionUpdateTime;
		public String versionUpdateUser;
		public String freezeTime;
		public String isCurrent;
		public String isConsistent;
		public String fkSnapshotPurpose;
		public String snapshotPurpose;
		public String fkSalesChannelDefCreated;
		public String salesChannelDefCreated;
		public String cargoReadyTimeLocal;
		public String isCargoReadyDateOnly;
		public String isCargoDeliveryDateOnly;
		public String bookingSegmentation;
		public String bookingSegmentationText;
		public String timeUpdateStructure;
		public String userUpdateStructure;
		public String fkShipmentProgressStatus;
		public String shipmentProgressStatus;
		public String workOrderReference;
		public String workOrder;
		public String issue;
		public String prevWorkOrderReference;
		public String vipClass;
		public String cargoDeliveryTimeLocal;
		public String fkTransportBillType;
		public String transportBillType;
		public String lineCode;
		public String fkBusinessSystemSource;
		public String businessSystemSource;
		public String fkReceiptDeliveryModeRec;
		public String receiptDeliveryModeRec;
		public String fkReceiptDeliveryModeDel;
		public String receiptDeliveryModeDel;
		public String nrOriginalBl;
		public String fkRkstvsaPartVsaOwner;
		public String rkstvsaPartVsaOwner;
		public String fkCommunicationMediaType;
		public String communicationMediaType;
		public String fkScvCustomerSegmentLocked;
		public String priceCalcBaseDateLocal;
		public String appliesSc;
		public String scIdentifiedByMars;
		public String priceBasedOnTariff;
		public String fkPriceAggregateTypeInvoice;
		public String priceAggregateTypeInvoice;
		public String transpDocUsesShipmentDesc;
		public String fkCommunicationMediaTypeSi;
		public String communicationMediaTypeSi;
		public String priceMustBasedSc;
		public String statusUpdateTime;
		public String scvVipclassLocked;
		public String isConferencePriced;
		public String dgdreceived;
		public String completePriceShipment;
		public String isShortShipped;
		public String documentClassId;
		public String documentClass;
		public String partialShipmentAllowed;
		public String shipmentVersionInstanceId;
		public String fkInlccurrPartMarsTotal;
		public String transportStartDate;
		public String routeCode;
		public String routeId;
		public String routeName;
		public String uAdmOperatorOwnerScac;
		public String readyInvoiceDetailsPrepaid;
		public String readyInvoiceDetailsCollect;
		public String fkMarsRatebasesProrate;
		public String isImportShipment;
		public String isOnceConfirmed;
		public String originalCreateTime;
		public String fkDeliveryAgreementType;
		public String deliveryAgreementType;
		public String fkUtmStatusValue;
		public String utmStatusValue;
		public String directionIndicator;
		public String isCommitmentCompleted;
		public String isPricedByAfls;
		public String isLogicallyCompleted;
		public String isFmcRegulated;
		public String isCreatedFromPreliminary;
		public String isSpotShipment;
		public String deliveryAgreementTypeDisplayname;
		public String fkBusinessProductType;
		public String businessProductTypeDescription;
		public String fkBusinessProductGroup;
		public String businessProductGroupDescription;
		public List<Tag0110> tag0110;
		public List<Tag0120> tag0120;
		public List<Tag0150> tag0150;
		public List<Tag0160> tag0160;
		public List<Tag0190> tag0190;
		public List<Tag01a0> tag01a0;
		public List<Tag01c0> tag01c0;
		public List<Tag01u0> tag01u0;
		public List<Tag01x0> tag01x0;
		public List<Tag0200> tag0200;
		public List<Tag0300> tag0300;
		public List<Tag0400> tag0400;
		public List<Tag0500> tag0500;
		public List<Tag0600> tag0600;
		public List<Tag0a00> tag0a00;
		public List<Tag0d00> tag0d00;
		public List<Tag01g0> tag01g0;
        public List<Tag0900> tag0900;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0220 {
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
		public List<Tagt100> tagt100;
		public List<Tag0100> tag0100;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0120 {
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
	public class Tag0240 {
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
	public class Tag0500 {
		public List<Tag0510> tag0510;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0621 {
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
	public class Tag0400 {
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
		public String fkReceiptDeliveryModeRec;
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
		public List<Tag0410> tag0410;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0620 {
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
		public String customsLocationCodeFirms;
		public List<Tag0621> tag0621;
		public List<Tag0623> tag0623;
	}

	/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0300 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String sequenceInRequirement;
		public String fkRmemeqbc;
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
		public List<Tag0310> tag0310;
		public List<Tag0370> tag0370;
		public List<Tag03h0> tag03h0;
		public List<Tag03j0> tag03j0;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0200 {
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
		public String geoAreaCountryId;
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
		public List<Tag0220> tag0220;
		public List<Tag0240> tag0240;
		public List<Tag0260> tag0260;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0640 {
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
	public class Header {
		public String messageID;
		public String version;
		public String messageType;
		public String errorStatus;
		public String event;
		public String sequenceNumber;
		public String referenceType;
		public String reference;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0620_Z {
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
		public String customsLocationCodeFirms;
		public List<Tag0621> tag0621;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag01a0 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String fkCargoTypeDefine;
		public String cargoTypeDefine;
		public String applies;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkshipmentVersion;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0d00 {
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
	*/
	public class Tag01c0 {
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
		public String fkshipmentVersion;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0a20 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String presentationSequence;
		public String name;
		public String address;
		public String fkHaulageSiteType;
		public String haulageSiteType;
		public String fkGeographicArea;
		public String geographicArea;
		public String geographicAreaAltText;
		public String instructionsUni;
		public String fkSite;
		public String site;
		public String zipCode;
		public String phoneNo;
		public String faxNo;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkScvCustnoDoor;
		public String ownerName;
		public String addressName;
		public String address1;
		public String address2;
		public String address3;
		public String city;
		public String state;
		public String country;
		public String streetNo;
		public String poBox;
		public String importFax;
		public String emailAddress;
		public String url;
		public String fkGeographicAreaState;
		public String geographicAreaState;
		public String fkGeographicAreaCountry;
		public String geographicAreaCountry;
		public String rkstStateCode;
		public String rkstCountryCode;
		public String rkstCityCode;
		public String rkstSiteCode;
		public List<Tag0240> tag0a21;
	}

			/** 
	 * @description | SC-5462  Tag Details|
	*/
	public class Tag0a00 {
		public String instanceId;
		public String extReferenceId;
		public String keyExchangeId;
		public String kind;
		public String arrangementType;
		public String haulageNumber;
		public String fkShipmentPartyReleaseTo;
		public String extShipmentPartyReleaseTo;
		public String shipmentPartyReleaseTo;
		public String fkOperationalStage;
		public String operationalStage;
		public String truckerPreference;
		public String instructions;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String fkShipmentVersion;
		public String fkTransportDocVersion;
		public String extShipmentVersion;
		public String extTransportDocVersion;
		public String clearanceSameAsPickup;
		public String inbondNeeded;
		public String carrierBond;
		public String isMerchantInspiredCarrier;
		public String customsBond;
		public List<Tag0a10> tag0a10;
		public List<Tag0a20> tag0a20;
		public List<Tag0a30> tag0a30;
	}
    /** 
	 * @description | SC-9950  Tag Details|
	*/
    public class Tag0900 {
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
		public String fktransportDocVersionIn;
		public List<Tag0910> tag0910;
	}
    /** 
	 * @description | SC-9950  Tag Details|
	*/
    public class Tag0910 {
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
		public String rkstSiteChargingCode;
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
		public String aflsRateType;
	//	public List<Tag0914> tag0914;
	}


	/** 
	 * @description | SC-5462  Tag Details|
	 * @param json accept the json data
	 * @return json parser for shipment
	*/
	public static ShipmentJsonParser parse(String json) {
		return (ShipmentJsonParser) System.JSON.deserialize(json, ShipmentJsonParser.class);
	}
}