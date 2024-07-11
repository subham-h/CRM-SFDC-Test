/*
Date            Story       Developer       Description
			       							Code Created
27-Jun-2022		SFSE-8624	Kiran			Custom lookup for Executive City / State
28-Oct-2022		SFSE-9691	Kiran			Live issue fix
13-Mar-2023		SFSE-10179	Vazid			Added code for Warehouse_Site__c object based on parent Id  
03-May-2023		SFSE-10726	Aditi & Bharti	Added code to show Active Customer Contacts in 'To' lookup of 'Send Offer on Email' lwc 
06-Nov-2023		SFSE-13253	Seba	        Added code to add filter in else part in findRecords method
*/
public class CustomLookupController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        String myQuery = '';
        if(myObject == 'Geography__c'){
            Map<Id, Geography__c> geoMap = new Map<Id, Geography__c>();
            myQuery = buildGeoQuery(searchTerm, myObject, filter);
            system.debug('****myQuery-->'+myQuery);
            if(!String.isEmpty(myQuery)){
                List<Geography__c> lookUpList = database.query(myQuery);
                if(!lookUpList.isEmpty()){
                    General_Key_Value_Configurations__mdt locationType = General_Key_Value_Configurations__mdt.getInstance('Geography_Location_Types');
                    List<String> locationTypeList = (locationType != null && !String.isEmpty(locationType.First_Field_Value__c)) ? locationType.First_Field_Value__c.split(',') : null;
                    for(Geography__c geo : lookUpList){
                        if(!locationTypeList.isEmpty() && locationTypeList.contains(geo.Type_Of_Location__c) && !geoMap.containsKey(geo.Id)){
                            geoMap.put(geo.Id, geo);
                        }
                        else if(geo.Type_Of_Location__c == 'City' && !geo.Parent_Geographies__r.isEmpty()){
                            for(Geography__c ge : geo.Parent_Geographies__r){
                                if(!locationTypeList.isEmpty() && locationTypeList.contains(ge.Type_Of_Location__c) && !geoMap.containsKey(ge.Id)){
                                    geoMap.put(ge.Id, ge);
                                }
                            }
                        }
                    }
                    return geoMap.values();
                }
            }
        }
        else{
            myQuery = buildQuery(searchTerm, myObject, filter);
            if(!String.isEmpty(myQuery)){
                List<sObject> lookUpList = database.query(myQuery);
                return lookUpList;
            }
        }
        
        return null;
    }
    
    public static String buildGeoQuery(String searchTerm, string myObject, String filter){
        String query = '';
        if(filter != null && filter != ''){
            query = 'Select Id, Name, Type_Of_Location__c, GEO_ID__c, Parent_Geography__c, Parent_Geography__r.GEO_ID__c, Parent_Geography__r.Geography_With_Country_Code__c, (Select Id, Name, Type_Of_Location__c, GEO_ID__c, Parent_Geography__c, Parent_Geography__r.GEO_ID__c, Parent_Geography__r.Geography_With_Country_Code__c From Parent_Geographies__r Where Type_Of_Location__c = \'Terminal\' AND Name LIKE  \'%' + searchTerm + '%\') from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' Order By Name LIMIT  10000';
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                query = 'Select Id, Name, Type_Of_Location__c, GEO_ID__c, Parent_Geography__c, Parent_Geography__r.GEO_ID__c, Parent_Geography__r.Geography_With_Country_Code__c, (Select Id, Name, Type_Of_Location__c, GEO_ID__c, Parent_Geography__c, Parent_Geography__r.GEO_ID__c, Parent_Geography__r.Geography_With_Country_Code__c From Parent_Geographies__r Where Type_Of_Location__c = \'Terminal\') from '+myObject+' Where (Type_Of_Location__c = \'Terminal\' OR Type_Of_Location__c = \'City\') ORDER BY Name DESC LIMIT 10000';
            }
            else {
                query = 'Select Id, Name, Type_Of_Location__c, GEO_ID__c, Parent_Geography__c, Parent_Geography__r.GEO_ID__c, Parent_Geography__r.Geography_With_Country_Code__c, (Select Id, Name, Type_Of_Location__c, GEO_ID__c, Parent_Geography__c, Parent_Geography__r.GEO_ID__c, Parent_Geography__r.Geography_With_Country_Code__c From Parent_Geographies__r Where Type_Of_Location__c = \'Terminal\' AND Name LIKE  \'%' + searchTerm + '%\') from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' ORDER BY Name DESC LIMIT 10000';
            }
        }
        return query;
    }
    
    public static String buildQuery(String searchTerm, string myObject, String filter){
        String myQuery = '';
        String key = searchTerm+'%';
        if(myObject == 'Account'){
            System.debug('***search'+searchTerm+'***'+key);            
            myQuery = 'SELECT Id,Name,Customer_Code__c,SCV_Code__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry FROM '+myObject+' Where Name Like \'%' + searchTerm + '%\' OR SCV_Code__c Like \'%' + searchTerm + '%\' LIMIT 5';  
        }
        else if(filter != null && filter != ''){
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like \'%' + searchTerm + '%\' AND '+filter+' LIMIT 5';          
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from '+myObject+' Where CreatedDate != NULL ORDER BY CreatedDate DESC LIMIT 5';
            }
            else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like \'%' + searchTerm + '%\' LIMIT 5';
            }
        }   
        system.debug('myQuery'+myQuery);
        return myQuery;
    }
    
    //SFSE-8624 Kiran Added
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName, String filter, String parentId) {  
        system.debug('searchKey@@@'+searchKey); 
        
        string searchText = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';
        string countryType = 'Country';
        string query = '';
        List<String> locationTypes = new List<String>();
        locationTypes.add('City');
        locationTypes.add('State');
        if(objectName == 'Geography__c'){
            if(parentId != null && parentId != ''){
                query = 'SELECT Id, Name, GEO_ID__c FROM ' +objectName+ ' WHERE Name LIKE '+searchText;
                query = query + ' AND (Parent_Geography__c = \''+ parentId + '\' OR Parent_Geography__r.Parent_Geography__c = \''+ parentId + '\')';
                query = query + ' AND Type_Of_Location__c  IN :locationTypes AND Active__c = true';
                if(filter != null && filter != ''){ //SFSE-13253  
                	query = query + ' AND '+ filter;    
            	}
                query = query + ' LIMIT 5';
            }
            else{
                 query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText;
                 
                 if(filter != null && filter != ''){ //SFSE-13253  
                	query = query + ' AND '+ filter;    
            	 }
                 query = query + ' AND Type_Of_Location__c=:countryType LIMIT 5';
            }
            //SFSE-10179
        } else if(objectName == 'Warehouse_Site__c'){
            if(parentId != null && parentId != ''){
                query = 'SELECT Id, Name, Country__c FROM ' +objectName+ ' WHERE ';
                if(searchKey != ''){
                   query = query + 'Name LIKE '+searchText+ ' AND ';
                }
                query = query + ' Country__c = \''+ parentId + '\'';
                query = query + ' LIMIT 5';
            }
        } else if(objectName == 'Account'){
            Id clientRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE ';
            query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE ';
            if(searchKey !=''){ query = query + 'Name LIKE '+searchText; }
            if(clientRecordTypeId!=NULL){query = query+' AND RecordTypeId =\''+clientRecordTypeId+'\''; }  
        } else if(objectName == 'User'){
            query = 'SELECT Id, Name, Maersk_User_Id__c FROM ' +objectName+ ' WHERE IsActive = true AND Name Like '+searchText;
            query = query + ' LIMIT 5';
        }  
           //10726
            else if(objectName == 'Contact'){
                System.debug('coming inside');
                if(parentId !=null && parentId != ''){
                    query = 'Select id,Email,Name FROM ' + objectName+ ' Where ';
                    if(searchKey != ''){
                        query = query+ ' Name LIKE '+searchText+ ' AND ';
                    }
                    query = query + ' AccountId = \''+parentId +'\' AND RecordType.Name = \'Customer Contact\' AND Contact_Status__c = \'Active\' ';
                }
                
            }
         else{
            query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText;
            //SFSE-13253
            if(filter != null && filter != ''){   
                query = query + ' AND '+ filter;    
            }
            query = query + ' LIMIT 5';
        }
        
        System.debug('query '+query);
        if(query != ''){
            return Database.query(query);  
        }else{
            return null;
        }
    }
}