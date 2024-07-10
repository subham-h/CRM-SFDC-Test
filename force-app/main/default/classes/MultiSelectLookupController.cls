/*
* Version  Date           Owner                    RQ#           Description
****************************************************************************************************************************************
* 1.0      27-Jul-2019    sidhartha mohapatra      #RQ-011128    Controller class for searching multiple origin and destination.
																 The section from where it is fired should be coming from LWC.
                                                                 Ex - It is fired from OriginDestion section of LWC
                                                                 So isFired = 'isOriginDestination' is passed from LWC.
* 1.1       27-Sept-2019    sidhartha mohapatra     #RQ-012024  Added 'City' as filter criteria.
*/
public class MultiSelectLookupController {
    
private final static Integer MAX_RESULTS = 5;
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String isfired) {

        String query;
        String sObjIcon = 'custom:custom9';
        String strName;
        String strQueryFilter;
        String strobjectName;
        String strFilterCriteria;
        String routeDirectioncode;
        String strSubtitle;

        If(isfired !=null && isfired == 'isOriginDestination') {
            strFilterCriteria = '(Is_Port__c = true OR Type_Of_Location__c = \'City\') AND Active__c = true';
            strQueryFilter = 'GEO_Code__c';
            strobjectName = 'Geography__c';
        }

        // Prepare query paramters
        searchTerm += '*';
        If(strQueryFilter !=null) {
            query = 'Id, Name,'+strQueryFilter;
        } else {
            query = 'Id, Name,';
        }
        if(strFilterCriteria !=null) {
            query += ' WHERE Name NOT IN :selectedIds AND ' + strFilterCriteria;     
        } else {
            query += ' WHERE Name NOT IN :selectedIds ';    
        }
        query = 'FIND \'' + String.escapeSingleQuotes(searchTerm) + '\'  IN ALL FIELDS RETURNING ' + strobjectName + ' (' + query + ') '+'LIMIT :MAX_RESULTS';
        system.debug('query' + query);
        List<List<sObject>> searchResults = search.query(query);
        system.debug('searchResults' + searchResults);
        
        // Convert objectName to SObjectType
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(strobjectName);
        system.debug('sObj' + sObj);
        Sobject genericObject = sObj.newSObject();
        
        // Prepare results
        
        Sobject [] sObjResults = ((List<Sobject>) searchResults[0]);
        system.debug('sObjResults' + sObjResults);
        
        //Extract object record details & convert them into LookupSearchResult
        for (Sobject sObjdetails : sObjResults) {
            strName = (String) sObjdetails.get('Name');
            routeDirectioncode = (String) sObjdetails.get('GEO_Code__c');
            if(strobjectName == 'Geography__c') {
                strSubtitle = routeDirectioncode;
            }
            results.add(new LookupSearchResult(sObjdetails.Id, strobjectName, sObjIcon, strName , strSubtitle)); 
            system.debug('results' + results);
        }        
        return results;
    }
}