/*
Description  : Perform callout to RKEM to get the Schedule details

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          22/10/2019          nivedita.shukla@maersk.com                    Perform callout to RKEM to get the Schedule details from Bot
* V2.0          27/09/2023          Avinash@maersk                                Chat- Replace AO API with MEPC API for product schedules
*-------------------------------------------------------------------------------------------------------------------
*/


public class JSON2Apex_ScheduledEnquiry {
    
 	public class Vessel {
		public String vesselMaerskCode {get;set;} 
		public String vesselName {get;set;} 

		public Vessel(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'vesselMaerskCode') {
							vesselMaerskCode = parser.getText();
						} else if (text == 'vesselName') {
							vesselName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Vessel consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class RoutingLegs {
		public TransportMode transportMode {get;set;} 
		public Carriage carriage {get;set;} 
		public String shipmentRoutingType {get;set;} 
		public Boolean isDummy {get;set;} 

		public RoutingLegs(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'transportMode') {
							transportMode = new TransportMode(parser);
						} else if (text == 'carriage') {
							carriage = new Carriage(parser);
						} else if (text == 'shipmentRoutingType') {
							shipmentRoutingType = parser.getText();
						} else if (text == 'isDummy') {
							isDummy = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'RoutingLegs consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Routings {
		public String estimatedTransitTime {get;set;} 
		public List<RoutingLegs> routingLegs {get;set;} 
		public String routeId {get;set;} 
		public String routeSequenceNumber {get;set;} 
		public String tradeLaneCode {get;set;} 
		public String sourceSystem {get;set;} 

		public Routings(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'estimatedTransitTime') {
							estimatedTransitTime = parser.getText();
						} else if (text == 'routingLegs') {
							routingLegs = arrayOfRoutingLegs(parser);
						} else if (text == 'routeId') {
							routeId = parser.getText();
						} else if (text == 'routeSequenceNumber') {
							routeSequenceNumber = parser.getText();
						} else if (text == 'tradeLaneCode') {
							tradeLaneCode = parser.getText();
						} else if (text == 'sourceSystem') {
							sourceSystem = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Routings consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class AlternativeCodes {
		public String alternativeCode {get;set;} 
		public String alternativeCodeType {get;set;} 

		public AlternativeCodes(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'alternativeCode') {
							alternativeCode = parser.getText();
						} else if (text == 'alternativeCodeType') {
							alternativeCodeType = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AlternativeCodes consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Routings> routings {get;set;} 

	public JSON2Apex_ScheduledEnquiry(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'routings') {
						routings = arrayOfRoutings(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex_ScheduledEnquiry consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class VesselPortCallStart {
		public String carrierCode {get;set;} 
		public String departureVoyageNumber {get;set;} 
		public ArrivalService arrivalService {get;set;} 
		public ArrivalService departureService {get;set;} 
		public String estimatedTimeOfDeparture {get;set;} 
		public Location location {get;set;} 

		public VesselPortCallStart(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'carrierCode') {
							carrierCode = parser.getText();
						} else if (text == 'departureVoyageNumber') {
							departureVoyageNumber = parser.getText();
						} else if (text == 'arrivalService') {
							arrivalService = new ArrivalService(parser);
						} else if (text == 'departureService') {
							departureService = new ArrivalService(parser);
						} else if (text == 'estimatedTimeOfDeparture') {
							estimatedTimeOfDeparture = parser.getText();
						} else if (text == 'location') {
							location = new Location(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'VesselPortCallStart consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class VesselPortCallEnd {
		public String carrierCode {get;set;} 
		public String arrivalVoyageNumber {get;set;} 
		public ArrivalService arrivalService {get;set;} 
		public ArrivalService departureService {get;set;} 
		public String estimatedTimeOfArrival {get;set;} 
		public Location location {get;set;} 

		public VesselPortCallEnd(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'carrierCode') {
							carrierCode = parser.getText();
						} else if (text == 'arrivalVoyageNumber') {
							arrivalVoyageNumber = parser.getText();
						} else if (text == 'arrivalService') {
							arrivalService = new ArrivalService(parser);
						} else if (text == 'departureService') {
							departureService = new ArrivalService(parser);
						} else if (text == 'estimatedTimeOfArrival') {
							estimatedTimeOfArrival = parser.getText();
						} else if (text == 'location') {
							location = new Location(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'VesselPortCallEnd consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class TransportMode {
		public String transportModeCode {get;set;} 
		public String transportModeEnum {get;set;} 

		public TransportMode(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'transportModeCode') {
							transportModeCode = parser.getText();
						} else if (text == 'transportModeEnum') {
							transportModeEnum = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'TransportMode consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ArrivalService {
		public String serviceCode {get;set;} 
		public String serviceName {get;set;} 

		public ArrivalService(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'serviceCode') {
							serviceCode = parser.getText();
						} else if (text == 'serviceName') {
							serviceName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ArrivalService consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Facility {
		public List<AlternativeCodes> alternativeCodes {get;set;} 

		public Facility(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'alternativeCodes') {
							alternativeCodes = arrayOfAlternativeCodes(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Facility consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Location {
		public Facility facility {get;set;} 

		public Location(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'facility') {
							facility = new Facility(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Location consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Carriage {
		public String carriageType {get;set;} 
		public VesselPortCallStart vesselPortCallStart {get;set;} 
		public VesselPortCallEnd vesselPortCallEnd {get;set;} 
		public Vessel vessel {get;set;} 

		public Carriage(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'carriageType') {
							carriageType = parser.getText();
						} else if (text == 'vesselPortCallStart') {
							vesselPortCallStart = new VesselPortCallStart(parser);
						} else if (text == 'vesselPortCallEnd') {
							vesselPortCallEnd = new VesselPortCallEnd(parser);
						} else if (text == 'vessel') {
							vessel = new Vessel(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Carriage consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static JSON2Apex_ScheduledEnquiry parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new JSON2Apex_ScheduledEnquiry(parser);
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
	
    private static List<RoutingLegs> arrayOfRoutingLegs(System.JSONParser p) {
        List<RoutingLegs> res = new List<RoutingLegs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new RoutingLegs(p));
        }
        return res;
    }

    private static List<Routings> arrayOfRoutings(System.JSONParser p) {
        List<Routings> res = new List<Routings>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Routings(p));
        }
        return res;
    }

    private static List<AlternativeCodes> arrayOfAlternativeCodes(System.JSONParser p) {
        List<AlternativeCodes> res = new List<AlternativeCodes>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AlternativeCodes(p));
        }
        return res;
    }
}