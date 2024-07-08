/**
* Description : Wrapper Class for Single Phone Response from Informatica
*
* Date         Owner               RQ#         Description
************************************************************************************************************
* 28/03/2019   Sid/Nitin@Maersk          RQ-010026   Class created.
*/
public class PhoneResponseWrapperSingleResult {
	public WebServiceResponse WebServiceResponse;
    
    public class WebServiceResponse {
        public SubscriptionInfo SubscriptionInfo;
        public ValidateNumberBatchResponse ValidateNumberBatchResponse;
        
    }

    public class SubscriptionInfo {
        public String LicenseStatusCode; 
        public String LicenseStatus;
        public String LicenseActionCode;
        public String LicenseAction;
        public String RemainingHits;
        public String Amount;
        
    }

    public class ValidateNumberBatchResponse {
        public ValidateNumberBatchResult ValidateNumberBatchResult;
        
    }

    public class ValidateNumberBatchResult {
        public ServiceStatus ServiceStatus; 
        public ServiceResult ServiceResult;
    }

    public class ServiceStatus {
        public String StatusNbr; 
        public String StatusDescription;
        
    }
    
    public class ServiceResult {
        public Results Results;
        
    }
    
    public class Results {
        public GlobalPhoneEntryWithStatus GlobalPhoneEntryWithStatus;
        
    }

    public class GlobalPhoneEntryWithStatus {
        public ServiceStatus ItemStatus; 
        public Listing Listing;
    }

    public class ItemStatus {
        public String StatusNbr; 
        public String StatusDescription;
    }
    
    public class Listing {
        public String Number_Z; // in json: Number
        public String CountryCode;
        public String InternationalPrefix;
        public String NationalPrefix;
        public Object CellPrefix;
        public String NDC;
        public String SN_From;
        public String SN_To;
        public String Uses_NDC;
        public String Number_Type;
        public String CarrierName;
        public String Language;
        public String Country;
        public String ISO;
        public String RegionCode;
        public String RegionName;
        public String City;
        public String TimeZone;
        public String UTC;
        public String DST;
        public String Latitude;
        public String Longitude;
        public String ErrorCode;
        public String NationalFormat;
        public String InternationalFormat; 
        public String E164Format;
        public String LinkFormat;
        
    }
}