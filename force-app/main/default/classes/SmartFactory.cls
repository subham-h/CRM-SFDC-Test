/**
   Copyright 2011 Mavens Consulting, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   @description The original code has been modified to use fake Ids instead of actually inserting records. Additionally the field type if-else statements have been converted to a switch statement 
   and a bunch of typos and incorrectly formatted code has been corrected.
*/   
@isTest
public with sharing class SmartFactory {
	public static Boolean fillAllFields = false;

	// Key : SobjectAPIName  For ex. Account 
	// Value : Map<String, Schema.SObjectField>, field map (k:fieldname, v:Schema.Sobjectfield)
	public static Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

	private static final Map<String, Map<String, Schema.SObjectField>> FIELDMAPCACHE = new Map<String, Map<String, Schema.SObjectField>>();
	private static final Map<String, Id> DEFAULTRECTYPECACHE = new Map<String, Id>();
	private static final Map<String, Id> REFERENCEOBJECTCACHE = new Map<String, Id>();
	private static final Map<String, Schema.SObjectType> GLOBALDESCRIBE = Schema.getGlobalDescribe();
    
    private static final Boolean isPersonAccountEnabled = (fieldMapFor('Account').get('IsPersonAccount') != null);
	private static final Set<String> skipPersonAccountFields = new Set<String>{ 'Salutation' };
    
    private static Integer fakeIdCounter = 0;
    private static final String PATTERN = '000000000000';

	// Key: sobject.field
	// Value: first picklist value
	private static final Map<String, String> DEFAULTPICKLISTVALUE = new Map<String, String>();

	// can't map by Schema.sObjectType, use object name String instead
	public static Map<String, Set<String>> ExcludedFields = new Map<String, Set<String>>{
		'All' => new Set<String>{'OwnerId', 'LastModifiedById', 'CreatedById', 'LastModifiedDate', 'CreatedDate'},
		'Account' => new Set<String>{'FirstName', 'LastName'},
		'User' => new Set<String>{'IsActive','DelegatedApproverId','CallCenterId','ContactId','DelegatedApproverId','ManagerId','UserRoleId','FederationIdentifier'}
	};

	// to fill nillable fields, specify them here
	public static Map<String, Set<String>> IncludedFields = new Map<String, Set<String>>();

	// various simplified signatures for flexibility and backward compatibility
	public static SObject createSObject(String objectType, Boolean create) {
		return createSObject(objectType, false, 1, null, create);
	}

	public static SObject createSObject(String objectType, Map<String, Object> fieldValues, Boolean create) {
		return createSObject(objectType, false, 1, fieldValues, create);
	}

	public static SObject createSObject(String objectType, Boolean cascade, Boolean create) {
		return createSObject(objectType, cascade, 1, null, create);
	}

	public static SObject createSObject(String objectType, Boolean cascade, Integer counter, Boolean create) {
		return createSObject(objectType, cascade, counter, null, create);
	}

	public static SObject createSObject(String objectType, Boolean cascade, Map<String, Object> fieldValues, Boolean create) {
		return createSObject(objectType, cascade, 1, fieldValues, create);
	}

	// full service signature
	// by passing in fieldValues, you can set defaults for any fields you like (data types must match)
	// for reference fields, fieldValues can optionally be actual parent objects to which you want the new objects to be related
	public static SObject createSObject(String objectType, Boolean cascade, Integer counter, Map<String, Object> fieldValues, Boolean create) {
		Schema.sObjectType token = GLOBALDESCRIBE.get(objectType);
		if (token == null) {
			//throw new UnsupportedObjectTypeException('Unsupported ObjectType ' + objectType);
			System.assert(false);
		}

		SObject obj = token.newSObject();		

		Set<String> exclude = new Set<String>(); 
        if (ExcludedFields.get('All') != null) {
            exclude.addAll(ExcludedFields.get('All'));
        }
        if (ExcludedFields.get(objectType) != null) {
            exclude.addAll(ExcludedFields.get(objectType));
        }
		Set<String> include = new Set<String>(); 
        if (IncludedFields.get(objectType) != null) {
            include.addAll(IncludedFields.get(objectType));		
        }
        if (fieldValues != null) {
            include.addAll(fieldValues.keyset());		
        }

		for (Schema.SObjectField field : fieldMapFor(objectType).values()) {
			setFieldValue(obj, field, cascade, counter, include, exclude, fieldValues, create);
		}
		return obj;
	}

	// more simplified signatures 
	public static List<SObject> createSObjectList(String objectType, Integer numberOfObjects, Boolean create) {
		return createSObjectList(objectType, false, numberOfObjects, null, create);
	}

	public static List<SObject> createSObjectList(String objectType, Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
		return createSObjectList(objectType, false, numberOfObjects, fieldValues, create);
	}

	public static List<SObject> createSObjectList(String objectType, Boolean cascade, Integer numberOfObjects, Boolean create) {
		return createSObjectList(objectType, cascade, numberOfObjects, null, create);
	}

	// main method to create a list of objects
	// fieldValues here work as above, but can optionally be a list of objects, in which case they will each be used 
	// in some of the objects created (see the test class for examples)
	public static List<SObject> createSObjectList(String objectType, Boolean cascade, Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
		List<SObject> sos = new List<SObject>();
        for (Integer i = 0; i < numberOfObjects; i++) {
			sos.add(createSObject(objectType, cascade, i, fieldValues, create));
        }
		return sos;  
	}

	/**
		Returns a field map for a given sobject. 

		Note : this method is kept public for Test cases to share the same field map info, without requiring a field describe.

		@param objectType sobject api name for ex. Account
		@returns FieldMap [Key:FieldName,Value:Schema.SObjectField]
	*/
	public static Map<String, Schema.SObjectField> fieldMapFor(String objectType) {
		Map<String, Schema.SObjectField> fieldMap = null;
		String normalizedObjectType = objectType.toLowerCase();

		if (FIELDMAPCACHE.containsKey(normalizedObjectType)) {
			fieldMap = FIELDMAPCACHE.get(normalizedObjectType);
		} else {
			fieldMap = GLOBALDESCRIBE.get(objectType).getDescribe().fields.getMap();
			// cache it for next use
			FIELDMAPCACHE.put(normalizedObjectType, fieldMap);
		}
		return fieldMap;
	}

	static String getDefaultPicklistValue(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
		String key = obj.getSObjectType() + '.' + fieldDescribe.getName();

		if (!DEFAULTPICKLISTVALUE.containsKey(key)) {
			List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
			String value = entries.size() > 0 ? entries[0].getValue() : null;
			DEFAULTPICKLISTVALUE.put(key, value);
		}
		return DEFAULTPICKLISTVALUE.get(key);
	}

	static boolean isExcludedField(Schema.DescribeFieldResult fieldDescribe) {
		return ExcludedFields.get('All').contains(fieldDescribe.getName());
	}

	static boolean isExcludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
		Set<String> fields = ExcludedFields.get(obj.getSObjectType().getDescribe().getName());
		return fields == null ? false : fields.contains(fieldDescribe.getName());
	}

	static boolean isIncludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
		Set<String> fields = includedFields.get(obj.getSObjectType().getDescribe().getName());
		return fields == null ? false : fields.contains(fieldDescribe.getName());
	}
	
	static Boolean isPersonAccountField(Schema.DescribeFieldResult fieldDescribe) {
        Boolean customPerson = fieldDescribe.isCustom() && fieldDescribe.getName().endsWith('pc');
        Boolean standardPerson = !fieldDescribe.isCustom() && fieldDescribe.getName().startsWith('Person');
        return (isPersonAccountEnabled && (customPerson || standardPerson || skipPersonAccountFields.contains(fieldDescribe.getName())));
	}

	static void setFieldValue(SObject obj, Schema.SObjectField field, Boolean cascade, Integer counter, Set<String> include, Set<String> exclude, Map<String, Object> fieldValues, Boolean create) {
		Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
		Schema.DisplayType ft = fieldDescribe.getType();
		String fn = fieldDescribe.getName();
		
		if (fieldDescribe.isCreateable() && 
				(
					(
						!exclude.contains(fn) &&
						(!fieldDescribe.isNillable() || fillAllFields || (ft == Schema.DisplayType.Reference && cascade)) && 
						(!isPersonAccountEnabled || !isPersonAccountField(fieldDescribe))
					) 
				|| include.contains(fn))
			) {
			// look for a default value provided for this field
			if (fieldValues != null && fieldValues.containsKey(fn)) {

				// set the field to the default provided, whether it is a value or a list of values
				// also supports getting the Id of an sobject if that is what is provided as a default
				setFieldOverrideValue(obj, field, fieldValues.get(fn), counter);
            } else {
                switch on ft {
                    when String {
                        if (fn == 'CommunityNickname') { 
                            obj.put(field, 't' + String.valueof(math.roundtolong(math.random() * 1000000)));
                        } else if (fn == 'Username') { 
                            obj.put(field, 'test' + String.valueof(Userinfo.getOrganizationId()) + String.valueof(math.roundtolong(math.random() * 1000000)) + String.valueof(Datetime.now()).replace('-', '').replace(':', '').replace(' ', '') + '@test.com');
                        } else {
                            String s = (fn + counter.format());
                            obj.put(field, (fieldDescribe.getLength() > s.length()) ? s : counter.format()); 
                        }
                    }
                    when Picklist {
                        obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
                    }
                    when Integer {
                        obj.put(field, counter);
                    }
                    when Boolean {
                        obj.put(field, false);
                    }
                    when Currency {
                        obj.put(field, counter);
                    }
                    when Date {
                        obj.put(field, Date.today());
                    }
                    when DateTime {
                        obj.put(field, DateTime.now());
                    }
                    when Double {
                        obj.put(field, counter);
                    }
                    when Email {
                        obj.put(field, 'test' + counter.format() + '@test.com');
                    }
                    when TextArea {
                        obj.put(field, fn + counter.format());
                    }
                    when Reference {
                        String objName = obj.getSObjectType().getDescribe().getName();
                        String referenceObjectType = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                        
                        if (referenceObjectType == 'RecordType') {
                            setRecordType(obj);
                        } else if (referenceObjectType == 'Profile') { 
                            obj.put(field, userProfile.Id);
                        } else if (referenceObjectType == 'User') { 
                            obj.put(field, UserInfo.getUserId());
                        } else if (cascade && referenceObjectType != objName) {
                            // TODO avoid infinite loop for same-type references
                            if (REFERENCEOBJECTCACHE.containsKey(referenceObjectType)) {
                                obj.put(field, REFERENCEOBJECTCACHE.get(referenceObjectType));
                            } else {
                                SObject reference = createSObject(referenceObjectType, fieldValues, create);
                                // Addition Sep 2022
                                Schema.SObjectType refObjType = reference.getSObjectType();
                                reference.Id = getFakeId(refObjType);
                                obj.put(field, reference.Id);
                                REFERENCEOBJECTCACHE.put(referenceObjectType, reference.Id);
                            }
                        }
                    }
                    when MultiPicklist {
                        obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
                    }
                    when Percent {
                        obj.put(field, counter);
                    }
                    when Phone {
                        obj.put(field, '+44 123456');
                    }
                    when Combobox {
                        obj.put(field, counter.format());
                    }
                    when EncryptedString {
                        obj.put(field, 's');
                    }
                    when Time {
                        obj.put(field, Time.newInstance(0, 0, 0, 0));
                    }
                    when URL {
                        obj.put(field, 'http://test' + counter + '.com'); 
                    }
                    when base64 {
                        obj.put(field, blob.valueOf(counter.format()));
                    }
                    when else {
                        //throw new UnsupportedObjectTypeException('Unhandled field type ' + ft);
                        System.assert(false);
                    }
                }
            }
		} else if (!create) {
            if (ft == Schema.DisplayType.Id) {
				Schema.SObjectType objType = obj.getSObjectType();
                obj.put(field, getFakeId(objType));
			}
        }
	}

	static void setFieldOverrideValue(SObject obj, Schema.SObjectField field, Object v, Integer counter) {

		// first try to cast the object to a list of objects and use the right one
		// failing that, assume it is a single object or value
		try { 
			List<Object> oo = (List<Object>)(v);
			Integer i = (counter < oo.size()) ? counter : Math.mod(counter, oo.size());
			try {
				obj.put(field, oo[i]);
			} catch (Exception ex1) {
				// if it isn't a value, try it as an sObject
				obj.put(field, ((sObject)(oo[i])).get('Id'));
			}
		} catch (Exception ex) {
			try { 
				// try the sObject first
				obj.put(field, ((sObject)(v)).get('Id'));
			} catch (Exception ex2) {
				// finally the object itself - this will throw an error if the datatype doesn't match
				obj.put(field, v);
			}
		}	
	}								

	static void setRecordType(SObject obj) {
		Schema.DescribeSObjectResult objDR = obj.getSObjectType().getDescribe();
		String otn = objDR.getName();

		List<Schema.RecordTypeInfo> recordTypes;
		if (DEFAULTRECTYPECACHE.containsKey( otn )) {
			obj.put('RecordTypeId', DEFAULTRECTYPECACHE.get( otn ));
		} else {
			recordTypes = objDR.getRecordTypeInfos();
			if (recordTypes.size() > 1) { // all objects have default Master type
				for (Schema.RecordTypeInfo recordType : recordTypes) {
					if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) {
						obj.put('RecordTypeId', recordType.getRecordTypeId());
						DEFAULTRECTYPECACHE.put(otn, recordType.getRecordTypeId());
						break;
					}
				}
			}
		}
	}
    
    static Id getFakeId(Schema.SObjectType type) {
        fakeIdCounter++;
        String keyPrefix = type.getDescribe().getKeyPrefix();
        String fakeIdPattern = PATTERN.substring(0, 12 - fakeIdCounter.format().length());
		return Id.valueOf(keyPrefix + fakeIdPattern + fakeIdCounter);
    }
}