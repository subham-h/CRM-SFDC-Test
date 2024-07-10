public class GeographyEventParser {

	public class Geography {
		public String geoId;
		public String geoType;
		public String name;
		public String status;
		public Integer validFrom;
		public Integer validTo;
		public String longitude;
		public String latitude;
		public String timeZone;
		public String daylightSavingTime;
		public String utcOffsetMinutes;
		public String daylightSavingStart;
		public String daylightSavingEnd;
		public String daylightSavingShiftMinutes;
		public String description;
		public String workaroundReason;
		public String restricted;
		public String postalCodeMandatory;
		public String stateProvinceMandatory;
		public String dialingCode;
		public String dialingCodeDescription;
		public Boolean portFlag;
		public String olsonTimezone;
		public String bdaType;
		public String hsudName;
		public Boolean isMaerskCity;
		public List<AlternateNames> alternateNames;
		public List<AlternateCodes> alternateCodes;
		public Country country;
		public List<Parents> parents;
		public List<Parents> subCityParents;
		public List<Bdas> bdas;
		public List<BdaLocations> bdaLocations;
	}

	public class AlternateCodes {
		public String codeType;
		public String code;
	}

	public class BdaLocations {
		public String name;
		public String type;
		public String status;
		public List<AlternateCodes> alternateCodes;
	}

	public Geography geography;

	public class Parents {
		public String name;
		public String type;
		public String bdaType;
		public List<AlternateCodes> alternateCodes;
	}

	public class Country {
		public String name;
		public List<AlternateCodes> alternateCodes;
	}

	public class Bdas {
		public String name;
		public String type;
		public String bdaType;
		public List<AlternateCodes> alternateCodes;
	}

	public class AlternateNames {
		public String name;
		public String description;
		public String status;
	}

	
	public static GeographyEventParser parse(String json) {
		return (GeographyEventParser) System.JSON.deserialize(json, GeographyEventParser.class);
	}

}