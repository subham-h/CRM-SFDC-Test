/**
* Description : Wrapper Class for Email Response from Informatica
*
* Date         Owner               RQ#         Description
************************************************************************************************************
* 28/03/2019   Sid/Nitin@Maersk          RQ-010026   Class created.
*/
public class EmailResponseWrapper {

	public class WebServiceResponse {
		public SubscriptionInfo SubscriptionInfo;
		public VerifyEmailResponse VerifyEmailResponse;
	}

	public WebServiceResponse WebServiceResponse;
    
	public class Email {
		public String Complete;
		public String LocalPart;
		public String DomainPart;
	}
    
    public class DestinationCountry {
        public String Code;
        public String Alpha2Code;
        public String Alpha3Code;
        public String Name;
    }

	public class ServiceResult {
		public String Timestamp;
		public Email Email;
		public Reason Reason;
		public Hygiene Hygiene;
		public SendRecommendation SendRecommendation;
		public DestinationCountry DestinationCountry;
		public String Cached;
		public String Disposable;
		public String PotentiallyVulgar;
		public String RoleBased;
	}

	public class VerifyEmailResponse {
		public VerifyEmailResult VerifyEmailResult;
	}

	public class ServiceStatus {
		public String StatusNbr;
		public String StatusDescription;
	}


	public class SubscriptionInfo {
		public String LicenseStatusCode;
		public String LicenseStatus;
		public String LicenseActionCode;
		public String LicenseAction;
		public String RemainingHits;
		public String Amount;
	}
    
    public class SendRecommendation {
        public String RiskProfile;
        public String Recommendation;
        public String RecommendedRetries;
        public String RecommendedRetryDelaySeconds;
    }

	public class VerifyEmailResult {
		public ServiceStatus ServiceStatus;
		public ServiceResult ServiceResult;
	}

	public class Reason {
		public String Code;
		public String Description;
	}
    public class Hygiene {
        public String HygieneResult;
        public String NetProtected;
    }

}