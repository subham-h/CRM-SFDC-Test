public class OIPCProdFeatureWrapper {
    //public String code{get; set;}
    //public String name{get; set;}
    
    public class Features {
		//public String createdDatetime{get; set;}
		//public String lastModifiedDatetime{get; set;}
		//public String associatedDatetime{get; set;}
		//public String code{get; set;}
		//public String name{get; set;}
		//public String description{get; set;}
		//public Integer displayOrder{get; set;}
		//public String componentRef{get; set;}
		public Specification specification{get; set;}
		public ConfigurableAtContracting configurableAtContracting{get; set;}
	}
		/*public class Specification {
            public String type;
            public List<OptionValue> optionValue;
            public RangeValue rangeValue;
            public String textValue;
            public Boolean booleanValue;           
	}*/
    
    public class Specification {
            public String type{get; set;}
            public OptionValue optionValue{get; set;}
            public RangeValue rangeValue{get; set;}
            public String textValue{get; set;}
            public Boolean booleanValue{get; set;}           
	}
        
    
    public class OptionValue{
        Public String option{get; set;}
        Public String description{get; set;}
    }
     public class RangeValue{
                 public Decimal min{get; set;}
                 public Decimal max{get; set;}
                 public String unit{get; set;}
                 public Boolean percentage{get; set;}
         
            }
    
    
     public class ConfigurableAtContracting {
		public Boolean enabled{get; set;}
		public Boolean choiceRequired{get; set;}
		public Boolean allowNoneValue{get; set;}
        public Boolean allowMultiselect{get; set;}
		public Boolean narrowToSingleValue{get; set;}
	}

}