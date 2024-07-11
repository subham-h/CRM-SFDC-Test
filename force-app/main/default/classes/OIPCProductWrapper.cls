public class OIPCProductWrapper {
    
    //public String createdDatetime {get; set;}
	//public String lastModifiedDatetime{get; set;}
	public String status{get; set;}
	public String code{get; set;}
	public Integer version{get; set;}
	public String name{get; set;}
	public Family family{get; set;}
	public String contracting{get; set;}
	public Header header{get; set;}
	public SalesInfo salesInfo{get; set;}
	//public List<Applicability> applicability{get; set;}
	public List<Components> components{get; set;}
	public List<Features> features{get; set;}
	public String productType{get; set;}
   
    
	public class Family {
		public String code{get; set;}
		public String portfolio{get; set;}
		public String name{get; set;}
		//public String displayOrder{get; set;}
	}
    	public class Header {
            public String maturity{get; set;}
            public String description{get; set;}
            public String keyContacts{get; set;}
            public String restriction{get; set;}
            public String limitation{get; set;}
            public String dependency{get; set;}
            public String customerCommitments{get; set;}
	}

	public class SalesInfo {
		public String tagline{get; set;}
		public String twowayCommitmentTagline{get; set;}
		public String customerNeed{get; set;}
		public String targetCustomerSegments{get; set;}
		public String targetCustomerVerticals{get; set;}
		public String salesChannels{get; set;}
		public String bookingChannels{get; set;}
		public String compatibleProducts{get; set;}
	}	

/*	public class Applicability {
		public String code{get; set;}
		public String scopeType{get; set;}
		public Scope scope{get; set;}
	}*/
    
   /* public class Scope {
		public String name{get; set;}
		public List<Dimensions> dimensions{get; set;}
		public String createdDatetime{get; set;}
		public String lastModifiedDatetime{get; set;}
	}*/
   /* public class Dimensions {
		public String type{get; set;}
		public List<String> value{get; set;}
	}*/
    
   // public List<String> value_v = new List<String>();
    public class Components {
       // public String createdDatetime{get; set;}
       // public String lastModifiedDatetime{get; set;}
       // public String associatedDatetime{get; set;}
        public String code{get; set;}
        public String name{get; set;}
        public String description{get; set;}
        public Integer displayOrder{get; set;}
	}
   
	public class Features {
	//	public String createdDatetime{get; set;}
	//	public String lastModifiedDatetime{get; set;}
	//	public String associatedDatetime{get; set;}
		public String code{get; set;}
		public String name{get; set;}
		public String description{get; set;}
		public Integer displayOrder{get; set;}
		public String componentRef{get; set;}
		public Specification specification{get; set;}
		public ConfigurableAtContracting configurableAtContracting{get; set;}
	}
		public class Specification {
            public String type{get; set;}
          
	}
    public class ConfigurableAtContracting {
		public Boolean enabled {get; set;}
		public Boolean choiceRequired{get; set;}
		public Boolean allowNoneValue{get; set;}
        public Boolean allowMultiselect{get; set;}
		public Boolean narrowToSingleValue{get; set;}
	}	
	public static List<OIPCProductWrapper> parse(String json) {
		return (List<OIPCProductWrapper>) System.JSON.deserialize(json, List<OIPCProductWrapper>.class);
	}
}