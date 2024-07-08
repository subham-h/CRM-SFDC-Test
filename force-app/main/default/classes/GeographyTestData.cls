/*
* Purpose  : Test Data For EMPConsumerHandler_Test Class
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5864     28-Feb-2023  Vivek@Maersk            Created.
*/

@isTest
public class GeographyTestData {

    /** 
    * @description | SC-5864  Create Sample data for testing Event Bus Publish|
    * @return Geography Event
    */
    public static Geography_Event__e geographyTestData1(){
        Geography_Event__e thisEvent =  new Geography_Event__e();
        thisEvent.Json_1__c= '{"geography":{'+
		'"geoId":"12WELBLF7OUA9",'+
		'"geoType":"State/Prov",'+
		'"name":"Mato Grosso do Sul",'+
		'"status":"Active",'+
		'"validFrom":"19397",'+
		'"validTo":"2932896",'+
		'"longitude":null,'+
		'"latitude":null,'+
		'"timeZone":"BRST",'+
		'"daylightSavingTime":"BRDT",'+
		'"utcOffsetMinutes":"-180",'+
		'"daylightSavingShiftMinutes":"60",'+
		'"description":null,'+
		'"workaroundReason":null,'+
		'"restricted":null,'+
		'"postalCodeMandatory":null,'+
		'"stateProvinceMandatory":null,'+
		'"dialingCode":null,'+
		'"dialingCodeDescription":null,'+
		'"portFlag":false,'+
		'"olsonTimezone":null,'+
		'"bdaType":null,'+
		'"hsudName":null,'+
		'"isMaerskCity":false,'+
		'"alternateNames":null,'+
		'"alternateCodes":['+
		'         {'+
		'            "codeType":"ISO TERRITORY",'+
		'            "code":"MS"'+
		'         },'+
		'         {'+
		'            "codeType":"HSUD NUMBER",'+
		'            "code":"100000835"'+
		'         },'+
		'         {'+
		'            "codeType":"HSUD CODE",'+
		'            "code":"MS"'+
		'         },'+
		'         {'+
		'            "codeType":"GEOID",'+
		'            "code":"12WELBLF7OUA9"'+
		'         },'+
		'         {'+
		'            "codeType":"STATE",'+
		'            "code":"MS"'+
		'         }'+
		'      ],'+
		'"country":{'+
		'         "name":"Brazil",'+
		'         "alternateCodes":['+
		'            {'+
		'               "codeType":"GEOID",'+
		'               "code":"33YYZ8LYAH9XA"'+
		'            },'+
		'            {'+
		'               "codeType":"RKTS",'+
		'               "code":"305"'+
		'            },'+
		'            {'+
		'               "codeType":"RKST",'+
		'               "code":"BR"'+
		'            },'+
		'            {'+
		'               "codeType":"HSUD NUMBER",'+
		'               "code":"100000063"'+
		'            },'+
		'            {'+
		'               "codeType":"HSUD CODE",'+
		'               "code":"BR"'+
		'            },'+
		'            {'+
		'               "codeType":"FIPS",'+
		'               "code":"BR"'+
		'            }'+
		'         ]'+
		'      },'+
		'"parents":['+
		'      {'+
		'         "name":"Brazil",'+
		'         "type":"Country",'+
		'         "bdaType":null,'+
		'         "alternateCodes":['+
		'            {'+
		'               "codeType":"GEOID",'+
		'               "code":"33YYZ8LYAH9XA"'+
		'            },'+
		'            {'+
		'               "codeType":"RKTS",'+
		'               "code":"305"'+
		'            },'+
		'            {'+
		'               "codeType":"RKST",'+
		'               "code":"BR"'+
		'            },'+
		'            {'+
		'               "codeType":"HSUD NUMBER",'+
		'               "code":"100000063"'+
		'            },'+
		'            {'+
		'               "codeType":"HSUD CODE",'+
		'               "code":"BR"'+
		'            },'+
		'            {'+
		'               "codeType":"FIPS",'+
		'               "code":"BR"'+
		'            }'+
		'         ]'+
		'      }'+
		'     ],'+
		'"subCityParents":null,'+
		'"bdas":null,'+
		'"bdaLocations":null'+
		'   }'+
		'}';
        return thisEvent;
    }
    
     /** 
    * @description | SC-5864  Create Sample data for testing Publish Geography Event|
    * @return Geography Event
    */
     public static Geography_Event__e GeographyTestData2(){
        Geography_Event__e thisEvent =  new Geography_Event__e();
        thisEvent.Json_1__c =  '{'+
		'"geography":{'+
		'"geoId":"20090923000AR",'+
		'"geoType":"Business Defined Area",'+
		'"name":"River Plate",'+
		'"status":"Active",'+
		'"validFrom":"19397",'+
		'"validTo":"2932896",'+
		'"longitude":null,'+
		'"latitude":null,'+
		'"timeZone":null,'+
		'"daylightSavingTime":null,'+
		'"utcOffsetMinutes":null,'+
		'"daylightSavingStart":null,'+
		'"daylightSavingEnd":null,'+
		'"daylightSavingShiftMinutes":null,'+
		'"description":"River Plate",'+
		'"workaroundReason":null,'+
		'"restricted":null,'+
		'"postalCodeMandatory":null,'+
		'"stateProvinceMandatory":null,'+
		'"dialingCode":null,'+
		'"dialingCodeDescription":null,'+
		'"portFlag":false,'+
		'"olsonTimezone":null,'+
		'"bdaType":"CLUSTER",'+
		'"hsudName":null,'+
		'"isMaerskCity":false,'+
		'"alternateNames":null,'+
		'"alternateCodes":['+
		'         {'+
		'            "codeType":"BDA CODE",'+
		'            "code":"RIV"'+
		'         },'+
		'         {'+
		'            "codeType":"GEOID",'+
		'            "code":"20090923000AR"'+
		'         }'+
		'      ],'+
		'"country":null,'+
		'"parents":['+
		'      {'+
		'         "name":"Latin America Region",'+
		'         "type":"Business Defined Area",'+
		'         "bdaType":"REGION",'+
		'         "alternateCodes":['+
		'            {'+
		'               "codeType":"GEOID",'+
		'               "code":"2012061500003"'+
		'            },'+
		'            {'+
		'               "codeType":"BDA CODE",'+
		'               "code":"LAM"'+
		'            }'+
		'         ]'+
		'      }'+
		'    ],'+
		'"subCityParents":null,'+
		'"bdas":null,'+
		'"bdaLocations":['+
		'         {'+
		'            "name":"Argentina",'+
		'            "type":"Business Defined Area",'+
		'            "status":"Active",'+
		'            "alternateCodes":['+
		'               {'+
		'                  "codeType":"GEOID",'+
		'                  "code":"2004081600300"'+
		'               },'+
		'               {'+
		'                  "codeType":"BDA CODE",'+
		'                  "code":"300"'+
		'               }'+
		'            ]'+
		'         },'+
		'         {'+
		'            "name":"Paraguay",'+
		'            "type":"Business Defined Area",'+
		'            "status":"Active",'+
		'            "alternateCodes":['+
		'               {'+
		'                  "codeType":"GEOID",'+
		'                  "code":"2004081600326"'+
		'               },'+
		'               {'+
		'                  "codeType":"BDA CODE",'+
		'                  "code":"326"'+
		'               }'+
		'            ]'+
		'         },'+
		'         {'+
		'            "name":"Uruguay",'+
		'            "type":"Business Defined Area",'+
		'            "status":"Active",'+
		'            "alternateCodes":['+
		'               {'+
		'                  "codeType":"GEOID",'+
		'                  "code":"2004081600330"'+
		'               },'+
		'               {'+
		'                  "codeType":"BDA CODE",'+
		'                  "code":"330"'+
		'               }'+
		'            ]'+
		'         }'+
		'      ]'+
		'   }'+
		'}';
        
        return thisEvent;
    }

   /** 
    * @description | SC-5864  Create Sample data for testing Publish Geography Event|
    * @return Geography Event
    */
    public static Geography_Event__e GeographyTestData3(){
        Geography_Event__e thisEvent =  new Geography_Event__e();
        thisEvent.Json_1__c =  '{'+
		'"geography":{'+
    '"geoId":"20090929100GR",'+
    '"geoType":"Country",'+
    '"name":"River Plate",'+
    '"status":"Active",'+
    '"validFrom":"19397",'+
    '"validTo":"2932896",'+
    '"longitude":null,'+
    '"latitude":null,'+
    '"timeZone":null,'+
    '"daylightSavingTime":null,'+
    '"utcOffsetMinutes":null,'+
    '"daylightSavingStart":null,'+
    '"daylightSavingEnd":null,'+
    '"daylightSavingShiftMinutes":null,'+
    '"description":"River Plate",'+
    '"workaroundReason":null,'+
    '"restricted":null,'+
    '"postalCodeMandatory":null,'+
    '"stateProvinceMandatory":null,'+
    '"dialingCode":null,'+
    '"dialingCodeDescription":null,'+
    '"portFlag":false,'+
    '"olsonTimezone":null,'+
    '"bdaType":null,'+
    '"hsudName":null,'+
    '"isMaerskCity":false,'+
    '"alternateNames":null,'+
    '"alternateCodes":['+
    '         {'+
    '            "codeType":"BDA CODE",'+
    '            "code":"RIV"'+
    '         },'+
    '         {'+
    '            "codeType":"GEOID",'+
    '            "code":"20090923000AR"'+
    '         }'+
    '      ],'+
    '"country":null,'+
    '"parents":['+
    '      {'+
    '         "name":"Latin America Region",'+
    '         "type":"Continent",'+
    '         "bdaType":null,'+
    '         "alternateCodes":['+
    '            {'+
    '               "codeType":"GEOID",'+
    '               "code":"2012061500003"'+
    '            },'+
    '            {'+
    '               "codeType":"BDA CODE",'+
    '               "code":"LAM"'+
    '            }'+
    '         ]'+
    '      }'+
    '    ],'+
    '"subCityParents":null,'+
    '"bdas":['+
    '         {'+
    '            "name":"Argentina",'+
    '            "type":"Business Defined Area",'+
    '            "status":"Active",'+
    '            "alternateCodes":['+
    '               {'+
    '                  "codeType":"GEOID",'+
    '                  "code":"2004081600300"'+
    '               },'+
    '               {'+
    '                  "codeType":"BDA CODE",'+
    '                  "code":"300"'+
    '               }'+
    '            ]'+
    '         },'+
    '         {'+
    '            "name":"Paraguay",'+
    '            "type":"Business Defined Area",'+
    '            "status":"Active",'+
    '            "alternateCodes":['+
    '               {'+
    '                  "codeType":"GEOID",'+
    '                  "code":"2004081600326"'+
    '               },'+
    '               {'+
    '                  "codeType":"BDA CODE",'+
    '                  "code":"326"'+
    '               }'+
    '            ]'+
    '         },'+
    '         {'+
    '            "name":"Uruguay",'+
    '            "type":"Business Defined Area",'+
    '            "status":"Active",'+
    '            "alternateCodes":['+
    '               {'+
    '                  "codeType":"GEOID",'+
    '                  "code":"2004081600330"'+
    '               },'+
    '               {'+
    '                  "codeType":"BDA CODE",'+
    '                  "code":"330"'+
    '               }'+
    '            ]'+
    '         }'+
    '   ],'+
    '"bdaLocations":null'+
	'   }'+
	'}';

    return thisEvent;
    }
}