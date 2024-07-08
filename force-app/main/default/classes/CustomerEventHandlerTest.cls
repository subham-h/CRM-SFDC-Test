/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		28-Dec-2022		Kiran@maersk			Code created. Test class for CustomerEventHandler
* 2.0       28-Feb-2024     Aleena@maersk           Added snippet for Sales Channel and Added Asserts for checking various fields 
*/
@isTest
public class CustomerEventHandlerTest {
    
    @isTest 
    static void testValidCustomerEvent() {
        String json=		'{'+
		'   "customerEntity":{'+
		'      "customerDetails":{'+
		'         "customerCoreInformation":{'+
		'            "customerCode":"AE00042692",'+
		'            "externalSystemIdentifiers":['+
		'               {'+
		'                  "externalSystemName":"MODS",'+
		'                  "externalSystemReference":"DAIMLER2",'+
		'                  "isDeletedFlag":false'+
		'               },'+
		'               {'+
		'                  "externalSystemName":"SCV",'+
		'                  "externalSystemReference":"43600042692",'+
		'                  "isDeletedFlag":false'+
		'               }'+
		'            ],'+
		'            "legalName":null,'+
		'            "tradingName":"DAIMLER AG, RLC MIDDLE EAST",'+
		'            "customerType":"ZEXC",'+
		'            "url":null,'+
		'            "isSoleProprietor":false,'+
		'            "isWorkflowPending":false,'+
		'            "workflowInformation":null,'+
		'            "customerStatus":{'+
		'               "statusCode":"A",'+
		'               "statusName":"Active",'+
		'               "customerStatusReasons":null'+
		'            },'+
		'            "telecommunicationNumber":{'+
		'               "phoneNumberType":"TEL",'+
		'               "phoneCountry":{'+
		'                  "isoCountryCode":"AE",'+
		'                  "countryName":"United Arab Emirates"'+
		'               },'+
		'               "internationalDialingCode":"971",'+
		'               "extensionNumber":null,'+
		'               "number":"48075129",'+
		'               "isDeletedFlag":false'+
		'            },'+
		'            "brands":null,'+
		'            "customerAddress":{'+
		'               "streetNumber":null,'+
		'               "streetName":null,'+
		'               "poBoxNumber":"17890",'+
		'               "apartmentOrFloor":null,'+
		'               "subArea":"JEBEL ALI",'+
		'               "district":null,'+
		'               "cityName":"JEBEL ALI",'+
		'               "cityCode":null,'+
		'               "region":{'+
		'                  "regionCode":null,'+
		'                  "regionName":null'+
		'               },'+
		'               "postalCode":null,'+
		'               "isoLanguageCode":"EN",'+
		'               "country":{'+
		'                  "isoCountryCode":"AE",'+
		'                  "countryName":"UNITED ARAB EMIRATES"'+
		'               },'+
		'               "latitude":null,'+
		'               "longitude":null'+
		'            }'+
		'         },'+
		'         "customerExtendedInformation":{'+
		'            "customerGroupType":"SCPI",'+
		'            "invoiceISOLanguageCodePreference":"EN",'+
		'            "isBrokerage":false,'+
		'            "isForwardersCompensation":false,'+
		'            "vipNonRoll":"A1"'+
		'         },'+
		'         "customerIdentifiers":['+
		'            '+
		'         ],'+
		'         "customerEnrichedInformation":null,'+
		'         "customerHierarchyInformation":null,'+
		'         "customerSegments":['+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"VERT",'+
		'                     "segmentValueCode":"ATMO",'+
		'                     "segmentValueName":"AUTOMOTIVE",'+
		'                     "segmentValueDescription":"AUTOMOTIVE"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"SAFM",'+
		'                  "brandName":"SAFMARINE"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"VALP",'+
		'                     "segmentValueCode":"EXPT",'+
		'                     "segmentValueName":"EXPERTISE",'+
		'                     "segmentValueDescription":"EXPERTISE"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"SEJJ",'+
		'                  "brandName":"SEALAND MAERSK EUROPE AND MEDITERRANEAN"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"VALP",'+
		'                     "segmentValueCode":"EXPT",'+
		'                     "segmentValueName":"EXPERTISE",'+
		'                     "segmentValueDescription":"EXPERTISE"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MCPU",'+
		'                  "brandName":"SEALAND MAERSK ASIA"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"VALP",'+
		'                     "segmentValueCode":"EXPT",'+
		'                     "segmentValueName":"EXPERTISE",'+
		'                     "segmentValueDescription":"EXPERTISE"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MCPU",'+
		'                  "brandName":"SEALAND MAERSK ASIA"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"SERV",'+
		'                     "segmentValueCode":"KEYC",'+
		'                     "segmentValueName":"KEY CLIENT",'+
		'                     "segmentValueDescription":"KEY CLIENT"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"SEAU",'+
		'                  "brandName":"SEALAND MAERSK AMERICA"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"VALP",'+
		'                     "segmentValueCode":"EXPT",'+
		'                     "segmentValueName":"EXPERTISE",'+
		'                     "segmentValueDescription":"EXPERTISE"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"SEJJ",'+
		'                  "brandName":"SEALAND MAERSK EUROPE AND MEDITERRANEAN"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"CUST",'+
		'                     "segmentValueCode":"BCO",'+
		'                     "segmentValueName":"BCO ",'+
		'                     "segmentValueDescription":"BCO "'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"SEAU",'+
		'                  "brandName":"SEALAND MAERSK AMERICA"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"SERV",'+
		'                     "segmentValueCode":"KEYC",'+
		'                     "segmentValueName":"KEY CLIENT",'+
		'                     "segmentValueDescription":"KEY CLIENT"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"SEAU",'+
		'                  "brandName":"SEALAND MAERSK AMERICA"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"CUST",'+
		'                     "segmentValueCode":"BCO",'+
		'                     "segmentValueName":"BCO ",'+
		'                     "segmentValueDescription":"BCO "'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"SAFM",'+
		'                  "brandName":"SAFMARINE"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"CUST",'+
		'                     "segmentValueCode":"BCO",'+
		'                     "segmentValueName":"BCO ",'+
		'                     "segmentValueDescription":"BCO "'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MCPU",'+
		'                  "brandName":"SEALAND MAERSK ASIA"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"CUST",'+
		'                     "segmentValueCode":"BCO",'+
		'                     "segmentValueName":"BCO ",'+
		'                     "segmentValueDescription":"BCO "'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isDeletedFlag":true,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"SERV",'+
		'                     "segmentValueCode":"KEYC",'+
		'                     "segmentValueName":"Key Client",'+
		'                     "segmentValueDescription":"KEY CLIENT"'+
		'                  }'+
		'               ]'+
		'            },'+
		'			{'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isDeletedFlag":true,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"SERV",'+
		'                     "segmentValueCode":"KEYC",'+
		'                     "segmentValueName":"RunWay",'+
		'                     "segmentValueDescription":"KEY CLIENT"'+
		'                  }'+
		'               ]'+
		'            },'+
		'			{'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"EFCY",'+
		'                     "segmentValueCode":"KEYC",'+
		'                     "segmentValueName":"Local Champion",'+
		'                     "segmentValueDescription":"KEY CLIENT"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"VALP",'+
		'                     "segmentValueCode":"EXPT",'+
		'                     "segmentValueName":"EXPERTISE",'+
		'                     "segmentValueDescription":"EXPERTISE"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"ROLP",'+
		'                     "segmentValueCode":"A1",'+
		'                     "segmentValueName":"A1",'+
		'                     "segmentValueDescription":"A1"'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "segmentBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isDeletedFlag":false,'+
		'               "segmentClassifications":['+
		'                  {'+
		'                     "segmentTypeCode":"CUST",'+
		'                     "segmentValueCode":"BCO",'+
		'                     "segmentValueName":"BCO ",'+
		'                     "segmentValueDescription":"BCO "'+
		'                  }'+
		'               ]'+
		'            },'+
        '   		{'+
        '  			 	"segmentBrandInformation":{'+
        '    			"brandCode":"MAEU", '+
        '           	"brandName":"MAERSK LINE"'+
        '  			},'+
        '  				"isDeletedFlag":false,'+
        '  				"segmentClassifications":['+
        '    		{'+
        '      			"segmentTypeCode":"SALC",'+
        '      			"segmentValueCode":"DITS",'+
        '      			"segmentValueName":"DIRECT TRANSPORT SALES",'+
        '      			"segmentValueDescription":"DIRECT TRANSPORT SALES"'+
        '    		}'+
        '  ]'+
        '}'+
		'         ],'+
		'         "customerRelationships":['+
		'            {'+
		'               "parentCustomerCode":"AE00042692",'+
		'               "parentAlternateCode":"43600042692",'+
		'               "parentCustomerName":"DAIMLER AG, RLC MIDDLE EAST",'+
		'               "childCustomerCode":"WW00167",'+
		'               "childAlternateCode":"***00167",'+
		'               "childCustomerName":"DAIMLER AG",'+
		'               "parentConcernCustCode":null,'+
		'               "parentConcernCustAlternateCode":null,'+
		'               "relationshipType":"CONCRN_MEM",'+
		'               "relationshipTypeName":"Concern Member",'+
		'               "isDeletedFlag":false,'+
		'               "validFromDate":1494720000000,'+
		'               "validThroughDate":4102358400000'+
		'            }'+
		'         ],'+
		'         "customerWebBillLadings":['+
		'            {'+
		'               "webBillBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "isNegotiableBL":false,'+
		'               "isNonNegotiableBL":true,'+
		'               "isDeletedFlag":false'+
		'            },'+
		'            {'+
		'               "webBillBrandInformation":{'+
		'                  "brandCode":"MCPU",'+
		'                  "brandName":"SEALAND MAERSK ASIA"'+
		'               },'+
		'               "isNegotiableBL":false,'+
		'               "isNonNegotiableBL":true,'+
		'               "isDeletedFlag":false'+
		'            },'+
		'            {'+
		'               "webBillBrandInformation":{'+
		'                  "brandCode":"MAEI",'+
		'                  "brandName":"MAERSK LINE, LIMITED"'+
		'               },'+
		'               "isNegotiableBL":false,'+
		'               "isNonNegotiableBL":true,'+
		'               "isDeletedFlag":false'+
		'            },'+
		'            {'+
		'               "webBillBrandInformation":{'+
		'                  "brandCode":"SAFM",'+
		'                  "brandName":"SAFMARINE"'+
		'               },'+
		'               "isNegotiableBL":false,'+
		'               "isNonNegotiableBL":true,'+
		'               "isDeletedFlag":false'+
		'            },'+
		'            {'+
		'               "webBillBrandInformation":{'+
		'                  "brandCode":"SEJJ",'+
		'                  "brandName":"SEALAND MAERSK EUROPE AND MEDITERRANEAN"'+
		'               },'+
		'               "isNegotiableBL":false,'+
		'               "isNonNegotiableBL":true,'+
		'               "isDeletedFlag":false'+
		'            },'+
		'            {'+
		'               "webBillBrandInformation":{'+
		'                  "brandCode":"SEAU",'+
		'                  "brandName":"SEALAND MAERSK AMERICA"'+
		'               },'+
		'               "isNegotiableBL":false,'+
		'               "isNonNegotiableBL":true,'+
		'               "isDeletedFlag":false'+
		'            }'+
		'         ],'+
		'         "collectionBusinessUnits":['+
		'            {'+
		'               "cbuBrandInformation":{'+
		'                  "brandCode":"MAEU",'+
		'                  "brandName":"MAERSK LINE"'+
		'               },'+
		'               "cbuInformation":['+
		'                  {'+
		'                     "cbuName":"Maersk Kanoo Llc ",'+
		'                     "cbuId":"2465",'+
		'                     "cbuTypeCode":"CUST_CBU_LCL",'+
		'                     "isDeletedFlag":false,'+
		'                     "validFromDate":1670371200000,'+
		'                     "validThroughDate":64060502400000'+
		'                  },'+
		'                  {'+
		'                     "cbuName":"Maersk Kanoo Llc (Dxb)",'+
		'                     "cbuId":"21",'+
		'                     "cbuTypeCode":"CUST_CBU_LCL",'+
		'                     "isDeletedFlag":false,'+
		'                     "validFromDate":1570233600000,'+
		'                     "validThroughDate":64060502400000'+
		'                  }'+
		'               ]'+
		'            },'+
		'            {'+
		'               "cbuBrandInformation":{'+
		'                  "brandCode":"SAFM",'+
		'                  "brandName":"SAFMARINE"'+
		'               },'+
		'               "cbuInformation":['+
		'                  {'+
		'                     "cbuName":"Safmarine Dubai (Dubai)",'+
		'                     "cbuId":"1875",'+
		'                     "cbuTypeCode":"CUST_CBU_LCL",'+
		'                     "isDeletedFlag":false,'+
		'                     "validFromDate":1570233600000,'+
		'                     "validThroughDate":64060502400000'+
		'                  }'+
		'               ]'+
		'            }'+
		'         ],'+
		'         "customerAuditData":{'+
		'            "creationUser":"admin",'+
		'            "creationDate":1468179539558,'+
		'            "lastUpdateUser":"EMP_TEMP",'+
		'            "lastUpdateDate":1670395162985,'+
		'            "lastUpdateSourceSystem":"OP_EMP"'+
		'         }'+
		'      }'+
		'   }'+
		'}';
		Customer_Message_Event__e customerEvent = new Customer_Message_Event__e(JSON_1__c = json);
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(customerEvent);
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        
        Test.stopTest();
        Account Acc = [SELECT id ,Industry__c,Vertical__c,Sub_Segment__c,Value_Proposition__c,Customer_Type__c,Rolling_Protection__c,Attractiveness__c,Sales_Channel__c FROM Account LIMIT 1];
        System.assertEquals('Direct Transport Sales', Acc.Sales_Channel__c);
        System.assertEquals('Automotive', Acc.Vertical__c);
        System.assertEquals(null, Acc.Attractiveness__c);
        System.assertEquals('Expertise', Acc.Value_Proposition__c);
        System.assertEquals('External', Acc.Customer_Type__c);
        System.assertEquals('A1', Acc.Rolling_Protection__c);



        

    }

}