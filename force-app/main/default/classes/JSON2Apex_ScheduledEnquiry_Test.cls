/*
Description  : Perform callout to RKEM to get the Schedule details

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          22/10/2019          nivedita.shukla@maersk.com                    Perform callout to RKEM to get the Schedule details from Bot
* V2.0          27/09/2023          Avinash@maersk                                Chat- Replace AO API with MEPC API for product schedules
*-------------------------------------------------------------------------------------------------------------------
*/

@IsTest
public class JSON2Apex_ScheduledEnquiry_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'    \"routings\": ['+
		'        {'+
		'            \"estimatedTransitTime\": \"P66DT13H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-28T16:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-03T01:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-03T02:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-06T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-15T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-16T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"T4P\",'+
		'                            \"vesselName\": \"MAERSK CANDOR\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"346S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-11-18T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"346S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-04T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"720\",'+
		'                            \"vesselName\": \"MAERSK LOTA\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"1\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P80DT13H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-28T16:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-03T01:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-17T02:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-20T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"P7J\",'+
		'                            \"vesselName\": \"MSC SIXIN\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"343W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-29T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"343W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-30T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"788\",'+
		'                            \"vesselName\": \"EBBA MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-12-02T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-18T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"I3D\",'+
		'                            \"vesselName\": \"SAN VICENTE\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"1\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P80DT13H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-28T16:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-03T01:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-03T02:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-06T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"343W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-29T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"343W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-30T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"788\",'+
		'                            \"vesselName\": \"EBBA MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-12-02T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-18T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"I3D\",'+
		'                            \"vesselName\": \"SAN VICENTE\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"1\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P73DT13H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-28T16:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-03T01:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-03T02:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-06T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"342W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-22T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"342W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-23T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"787\",'+
		'                            \"vesselName\": \"EVELYN MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"347S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-11-25T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"347S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-11T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"Z80\",'+
		'                            \"vesselName\": \"CMA CGM COLUMBIA\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"1\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P73DT13H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-28T16:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-03T01:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-10T02:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-13T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"DE7\",'+
		'                            \"vesselName\": \"MSC IRINA\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"342W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-22T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"342W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-23T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"787\",'+
		'                            \"vesselName\": \"EVELYN MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"347S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-11-25T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"347S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-11T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"Z80\",'+
		'                            \"vesselName\": \"CMA CGM COLUMBIA\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"1\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P73DT13H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-28T16:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-03T01:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-03T02:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-06T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-15T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-16T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"T4P\",'+
		'                            \"vesselName\": \"MAERSK CANDOR\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"347S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-11-25T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"347S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-11T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"Z80\",'+
		'                            \"vesselName\": \"CMA CGM COLUMBIA\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"1\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P80DT13H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-28T16:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-03T01:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-03T02:30:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E2441M\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"441\",'+
		'                                \"serviceName\": \"AE11\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-06T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"O4W\",'+
		'                            \"vesselName\": \"MSC LENI\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-15T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-16T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"T4P\",'+
		'                            \"vesselName\": \"MAERSK CANDOR\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-12-02T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-18T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"I3D\",'+
		'                            \"vesselName\": \"SAN VICENTE\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"1\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P63DT17H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"departureVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-15T12:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"arrivalVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-20T02:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"1GM\",'+
		'                            \"vesselName\": \"MAERSK MC-KINNEY M\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"departureVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-20T03:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"arrivalVoyageNumber\": \"341W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-22T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"1GM\",'+
		'                            \"vesselName\": \"MAERSK MC-KINNEY M\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"departureVoyageNumber\": \"343W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-29T15:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1437M\",'+
		'                            \"arrivalVoyageNumber\": \"343W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"437\",'+
		'                                \"serviceName\": \"AE7\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-30T11:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"788\",'+
		'                            \"vesselName\": \"EBBA MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-12-02T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"348S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-18T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"I3D\",'+
		'                            \"vesselName\": \"SAN VICENTE\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"9\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P41DT20H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X4X4AM\",'+
		'                            \"departureVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"X4A\",'+
		'                                \"serviceName\": \"NEOASAS\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"X4A\",'+
		'                                \"serviceName\": \"NEOASAS\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-09-26T17:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"ZGLEYV31HL1CM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X4X4AM\",'+
		'                            \"arrivalVoyageNumber\": \"339W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"X4A\",'+
		'                                \"serviceName\": \"NEOASAS\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"X4A\",'+
		'                                \"serviceName\": \"NEOASAS\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-07T13:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"607\",'+
		'                            \"vesselName\": \"MAERSK LA PAZ\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"7\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        },'+
		'        {'+
		'            \"estimatedTransitTime\": \"P56DT17H\",'+
		'            \"routingLegs\": ['+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"departureVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-08T12:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"2TK5NLOD7R0O6\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"arrivalVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-13T02:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"1UM\",'+
		'                            \"vesselName\": \"MUNKEBO MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"departureVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-13T03:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"YTICB0UTX30MM\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1432M\",'+
		'                            \"arrivalVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"432\",'+
		'                                \"serviceName\": \"AE10\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-10-15T10:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"1UM\",'+
		'                            \"vesselName\": \"MUNKEBO MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"E1431M\",'+
		'                            \"departureVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"431\",'+
		'                                \"serviceName\": \"AE5\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"431\",'+
		'                                \"serviceName\": \"AE5\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-10-16T22:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"33R7MNJ1ZSB4I\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"E1431M\",'+
		'                            \"arrivalVoyageNumber\": \"340W\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"431\",'+
		'                                \"serviceName\": \"AE5\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"431\",'+
		'                                \"serviceName\": \"AE5\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-11-13T08:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"Y31\",'+
		'                            \"vesselName\": \"MURCIA MAERSK\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                },'+
		'                {'+
		'                    \"transportMode\": {'+
		'                        \"transportModeCode\": \"MVS\",'+
		'                        \"transportModeEnum\": \"MOTHER_VESSEL\"'+
		'                    },'+
		'                    \"carriage\": {'+
		'                        \"carriageType\": \"OCEAN\",'+
		'                        \"vesselPortCallStart\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"departureVoyageNumber\": \"346S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfDeparture\": \"2023-11-18T14:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"CDQYK28YV7BKN\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vesselPortCallEnd\": {'+
		'                            \"carrierCode\": \"X396MM\",'+
		'                            \"arrivalVoyageNumber\": \"346S\",'+
		'                            \"arrivalService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"departureService\": {'+
		'                                \"serviceCode\": \"96M\",'+
		'                                \"serviceName\": \"NEOBOSSANOVA\"'+
		'                            },'+
		'                            \"estimatedTimeOfArrival\": \"2023-12-04T05:00:00\",'+
		'                            \"location\": {'+
		'                                \"facility\": {'+
		'                                    \"alternativeCodes\": ['+
		'                                        {'+
		'                                            \"alternativeCode\": \"3J5VPMJ4VXR6A\",'+
		'                                            \"alternativeCodeType\": \"GEO_ID\"'+
		'                                        }'+
		'                                    ]'+
		'                                }'+
		'                            }'+
		'                        },'+
		'                        \"vessel\": {'+
		'                            \"vesselMaerskCode\": \"720\",'+
		'                            \"vesselName\": \"MAERSK LOTA\"'+
		'                        }'+
		'                    },'+
		'                    \"shipmentRoutingType\": \"MAIN_ROUTING\",'+
		'                    \"isDummy\": false'+
		'                }'+
		'            ],'+
		'            \"routeId\": \"4387215916\",'+
		'            \"routeSequenceNumber\": \"6\",'+
		'            \"tradeLaneCode\": \"FEA/ESA\",'+
		'            \"sourceSystem\": \"MEPC\"'+
		'        }'+
		'    ]'+
		'}';
		JSON2Apex_ScheduledEnquiry r = JSON2Apex_ScheduledEnquiry.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.Vessel objVessel = new JSON2Apex_ScheduledEnquiry.Vessel(System.JSON.createParser(json));
		System.assert(objVessel != null);
		System.assert(objVessel.vesselMaerskCode == null);
		System.assert(objVessel.vesselName == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.RoutingLegs objRoutingLegs = new JSON2Apex_ScheduledEnquiry.RoutingLegs(System.JSON.createParser(json));
		System.assert(objRoutingLegs != null);
		System.assert(objRoutingLegs.transportMode == null);
		System.assert(objRoutingLegs.carriage == null);
		System.assert(objRoutingLegs.shipmentRoutingType == null);
		System.assert(objRoutingLegs.isDummy == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.Routings objRoutings = new JSON2Apex_ScheduledEnquiry.Routings(System.JSON.createParser(json));
		System.assert(objRoutings != null);
		System.assert(objRoutings.estimatedTransitTime == null);
		System.assert(objRoutings.routingLegs == null);
		System.assert(objRoutings.routeId == null);
		System.assert(objRoutings.routeSequenceNumber == null);
		System.assert(objRoutings.tradeLaneCode == null);
		System.assert(objRoutings.sourceSystem == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.AlternativeCodes objAlternativeCodes = new JSON2Apex_ScheduledEnquiry.AlternativeCodes(System.JSON.createParser(json));
		System.assert(objAlternativeCodes != null);
		System.assert(objAlternativeCodes.alternativeCode == null);
		System.assert(objAlternativeCodes.alternativeCodeType == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry objJSON2Apex = new JSON2Apex_ScheduledEnquiry(System.JSON.createParser(json));
		System.assert(objJSON2Apex != null);
		System.assert(objJSON2Apex.routings == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.VesselPortCallStart objVesselPortCallStart = new JSON2Apex_ScheduledEnquiry.VesselPortCallStart(System.JSON.createParser(json));
		System.assert(objVesselPortCallStart != null);
		System.assert(objVesselPortCallStart.carrierCode == null);
		System.assert(objVesselPortCallStart.departureVoyageNumber == null);
		System.assert(objVesselPortCallStart.arrivalService == null);
		System.assert(objVesselPortCallStart.departureService == null);
		System.assert(objVesselPortCallStart.estimatedTimeOfDeparture == null);
		System.assert(objVesselPortCallStart.location == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.VesselPortCallEnd objVesselPortCallEnd = new JSON2Apex_ScheduledEnquiry.VesselPortCallEnd(System.JSON.createParser(json));
		System.assert(objVesselPortCallEnd != null);
		System.assert(objVesselPortCallEnd.carrierCode == null);
		System.assert(objVesselPortCallEnd.arrivalVoyageNumber == null);
		System.assert(objVesselPortCallEnd.arrivalService == null);
		System.assert(objVesselPortCallEnd.departureService == null);
		System.assert(objVesselPortCallEnd.estimatedTimeOfArrival == null);
		System.assert(objVesselPortCallEnd.location == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.TransportMode objTransportMode = new JSON2Apex_ScheduledEnquiry.TransportMode(System.JSON.createParser(json));
		System.assert(objTransportMode != null);
		System.assert(objTransportMode.transportModeCode == null);
		System.assert(objTransportMode.transportModeEnum == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.ArrivalService objArrivalService = new JSON2Apex_ScheduledEnquiry.ArrivalService(System.JSON.createParser(json));
		System.assert(objArrivalService != null);
		System.assert(objArrivalService.serviceCode == null);
		System.assert(objArrivalService.serviceName == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.Facility objFacility = new JSON2Apex_ScheduledEnquiry.Facility(System.JSON.createParser(json));
		System.assert(objFacility != null);
		System.assert(objFacility.alternativeCodes == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.Location objLocation = new JSON2Apex_ScheduledEnquiry.Location(System.JSON.createParser(json));
		System.assert(objLocation != null);
		System.assert(objLocation.facility == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		JSON2Apex_ScheduledEnquiry.Carriage objCarriage = new JSON2Apex_ScheduledEnquiry.Carriage(System.JSON.createParser(json));
		System.assert(objCarriage != null);
		System.assert(objCarriage.carriageType == null);
		System.assert(objCarriage.vesselPortCallStart == null);
		System.assert(objCarriage.vesselPortCallEnd == null);
		System.assert(objCarriage.vessel == null);
	}
}