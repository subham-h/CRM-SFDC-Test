@IsTest
public class GeographyEventParserTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'   \"geography\":{'+
		'      \"geoId\":\"002IHUHKV9ME9\",'+
		'      \"geoType\":\"Postal Code\",'+
		'      \"name\":\"PORTO\",'+
		'      \"status\":\"Active\",'+
		'      \"validFrom\":\"19397\",'+
		'      \"validTo\":\"2932896\",'+
		'      \"longitude\":null,'+
		'      \"latitude\":null,'+
		'      \"timeZone\":null,'+
		'      \"daylightSavingTime\":null,'+
		'      \"utcOffsetMinutes\":null,'+
		'      \"daylightSavingStart\":null,'+
		'      \"daylightSavingEnd\":null,'+
		'      \"daylightSavingShiftMinutes\":null,'+
		'      \"description\":\"Retrigger 20171226 12:01:02\",'+
		'      \"workaroundReason\":null,'+
		'      \"restricted\":null,'+
		'      \"postalCodeMandatory\":null,'+
		'      \"stateProvinceMandatory\":null,'+
		'      \"dialingCode\":null,'+
		'      \"dialingCodeDescription\":null,'+
		'      \"portFlag\":false,'+
		'      \"olsonTimezone\":null,'+
		'      \"bdaType\":null,'+
		'      \"hsudName\":null,'+
		'      \"isMaerskCity\":false,'+
		'      \"alternateNames\":'+
		'      ['+
		'         {'+
		'            \"name\":\"IJER\",'+
		'            \"description\":\"TEST\",'+
		'            \"status\":\"Active\"'+
		'            '+
		'         }'+
		'      ],'+
		'      \"alternateCodes\":['+
		'         {'+
		'            \"codeType\":\"POSTAL CODE\",'+
		'            \"code\":\"4150-502\"'+
		'         },'+
		'         {'+
		'            \"codeType\":\"GEOID\",'+
		'            \"code\":\"002IHUHKV9ME9\"'+
		'         }'+
		'      ],'+
		'      \"country\":{'+
		'         \"name\":\"Portugal\",'+
		'         \"alternateCodes\":['+
		'            {'+
		'               \"codeType\":\"RKTS\",'+
		'               \"code\":\"124\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"FIPS\",'+
		'               \"code\":\"PO\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"RKST\",'+
		'               \"code\":\"PT\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"GEOID\",'+
		'               \"code\":\"2J5Q5I2Z56B26\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"HSUD NUMBER\",'+
		'               \"code\":\"100000227\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"HSUD CODE\",'+
		'               \"code\":\"PT\"'+
		'            }'+
		'         ]'+
		'      },'+
		'      \"parents\":['+
		'      {'+
		'         \"name\":\"Portugal\",'+
		'         \"type\":\"Country\",'+
		'         \"bdaType\":null,'+
		'         \"alternateCodes\":['+
		'            {'+
		'               \"codeType\":\"RKTS\",'+
		'               \"code\":\"124\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"FIPS\",'+
		'               \"code\":\"PO\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"RKST\",'+
		'               \"code\":\"PT\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"GEOID\",'+
		'               \"code\":\"2J5Q5I2Z56B26\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"HSUD NUMBER\",'+
		'               \"code\":\"100000227\"'+
		'            },'+
		'            {'+
		'               \"codeType\":\"HSUD CODE\",'+
		'               \"code\":\"PT\"'+
		'            }'+
		'         ]'+
		'      }'+
		'     ],'+
		'      \"subCityParents\":['+
		'         {'+
		'            \"name\":\"Mumbai\",'+
		'            \"type\":\"City\",'+
		'            \"bdaType\":null,'+
		'            \"alternateCodes\":['+
		'               {'+
		'                  \"codeType\":\"GEOID\",'+
		'                  \"code\":\"2DTM7OZL4OPP2\"'+
		'               },'+
		'               {'+
		'                  \"codeType\":\"RKST\",'+
		'                  \"code\":\"INBO1\"'+
		'               },'+
		'               {'+
		'                  \"codeType\":\"RKTS\",'+
		'                  \"code\":\"==O\"'+
		'               },'+
		'               {'+
		'                  \"codeType\":\"UN CODE(Return Only)\",'+
		'                  \"code\":\"INBOM\"'+
		'               }'+
		'            ]'+
		'         }'+
		'      ],'+
		'      \"bdas\":['+
		'         {'+
		'            \"name\":\"PTLEX\",'+
		'            \"type\":\"Business Defined Area\",'+
		'            \"bdaType\":\"POOL\",'+
		'            \"alternateCodes\":['+
		'               {'+
		'                  \"codeType\":\"BDA CODE\",'+
		'                  \"code\":\"PTLEX\"'+
		'               },'+
		'               {'+
		'                  \"codeType\":\"GEOID\",'+
		'                  \"code\":\"7JKQKLBAYZ0JQ\"'+
		'               }'+
		'            ]'+
		'         }'+
		'      ],'+
		'      \"bdaLocations\":['+
		'         {'+
		'            \"name\":\"Argentina\",'+
		'            \"type\":\"Business Defined Area\",'+
		'            \"status\":\"Active\",'+
		'            \"alternateCodes\":['+
		'               {'+
		'                  \"codeType\":\"GEOID\",'+
		'                  \"code\":\"2004081600300\"'+
		'               },'+
		'               {'+
		'                  \"codeType\":\"BDA CODE\",'+
		'                  \"code\":\"300\"'+
		'               }'+
		'            ]'+
		'         },'+
		'         {'+
		'            \"name\":\"Paraguay\",'+
		'            \"type\":\"Business Defined Area\",'+
		'            \"status\":\"Active\",'+
		'            \"alternateCodes\":['+
		'               {'+
		'                  \"codeType\":\"GEOID\",'+
		'                  \"code\":\"2004081600326\"'+
		'               },'+
		'               {'+
		'                  \"codeType\":\"BDA CODE\",'+
		'                  \"code\":\"326\"'+
		'               }'+
		'            ]'+
		'         },'+
		'         {'+
		'            \"name\":\"Uruguay\",'+
		'            \"type\":\"Business Defined Area\",'+
		'            \"status\":\"Active\",'+
		'            \"alternateCodes\":['+
		'               {'+
		'                  \"codeType\":\"GEOID\",'+
		'                  \"code\":\"2004081600330\"'+
		'               },'+
		'               {'+
		'                  \"codeType\":\"BDA CODE\",'+
		'                  \"code\":\"330\"'+
		'               }'+
		'            ]'+
		'         }'+
		'      ]'+
		'   }'+
		'}';
		GeographyEventParser obj = GeographyEventParser.parse(json);
		System.assert(obj != null);
	}
}