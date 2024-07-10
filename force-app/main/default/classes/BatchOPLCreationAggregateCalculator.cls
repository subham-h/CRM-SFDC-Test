/*
* Author   : Richa
* Purpose  : Batch class to create Aggregate table records for Ocean Plus Lead object
*         
* Revision Ref Number  Date          Owner               Description
* -------- ----------  -----------   ----------          -----------
* 1.0      SC-9742     05-Jun-2024   Richa@Maersk        Batch class to calculate the aggregate values of existing OPL records
*/ 
public class BatchOPLCreationAggregateCalculator implements Database.Batchable<sObject>, Database.Stateful {
    public Date startDate;
    public Date endDate;
    public Integer batchSize;
    // Maps to store the count 
    private Map<String, Ocean_Plus_Lead_Aggregate__c> mapAggregate = new Map<String, Ocean_Plus_Lead_Aggregate__c>();
    private Integer iteration;
    private Map<String, Integer> mapCountOfLeads = new Map<String, Integer> ();
    private Map<String, Integer> mapCountOfHandedOverLeads = new Map<String, Integer> ();
    private Map<String, Integer> mapLeadGeoCount = new Map<String, Integer> ();
    private Map<String, Integer> mapLeadHandoverGeoCount = new Map<String, Integer> ();
    
    public BatchOPLCreationAggregateCalculator(Date startDate,Date endDate,Integer batchSize) { 
        this.startDate = startDate;
        this.endDate = endDate;
        this.batchSize = batchSize;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {       
        String query = 'SELECT Id,Booking_Number__c,Max_Probability__c,Max_Export_Probability__c,Max_Import_Probability__c, Container_Type__c, Commodity__c,createddate,lastmodifieddate,Status__c,Owner_Area__c,Primary_Owner_Region__c,Origin_Region__r.Name,Destination_Region__r.Name,Origin_Area__r.Name,Destination_Area__r.Name FROM Ocean_Plus_Lead__c WHERE Status__c !=\'Cancelled\'' +
            ' AND (Booking_Status__c = \'Active\' OR Booking_Status__c = null)  ' ;
        if(startDate != null && endDate != null){
            query += ' AND CreatedDate  >= :startDate AND CreatedDate  < :endDate';
        }else{
            query += ' AND CreatedDate = LAST_MONTH';
        }
        query += ' ORDER BY CreatedDate DESC';
        if(batchSize != null){
            query += ' LIMIT ' + batchSize;
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, list<Ocean_Plus_Lead__c> scope) {         
        try {
            if(iteration == null){
                iteration = 0;
                List<Lead> lstLeadsCreated = new List<Lead>();
                if(startDate != null && endDate != null){
                    lstLeadsCreated = [Select Id,CreatedDate,Lead_Owner_Profile__c,Country_Ownership_Cluster__r.Name,Country_Ownership_Cluster__r.Parent_BDA__r.Name from Lead where CreatedDate >=: startDate AND CreatedDate <: endDate AND (Ocean_Plus_Lead__c != null OR Comments_for_Lead_source__c LIKE 'CX%') Limit 50000];
                }else{
                    lstLeadsCreated = [Select Id,CreatedDate,Lead_Owner_Profile__c,Country_Ownership_Cluster__r.Name,Country_Ownership_Cluster__r.Parent_BDA__r.Name from Lead where CreatedDate = LAST_MONTH AND (Ocean_Plus_Lead__c != null OR Comments_for_Lead_source__c LIKE 'CX%') Limit 50000];
                }
                for(Lead objLead : lstLeadsCreated){
                    String month = getMonthName(objLead.CreatedDate.month());
                    String year = String.valueOf(objLead.CreatedDate.year());
                    
                    //Global Lead count
                    String globalKey = ('Global'+ '_'+ month + '_' + year).deleteWhitespace();
                    
                    if(mapCountOfLeads.containsKey(globalKey)) {
                        mapCountOfLeads.put(globalKey,mapCountOfLeads.get(globalKey) + 1);   
                    }else{
                        mapCountOfLeads.put(globalKey, 1);
                    }
                    if(objLead.Lead_Owner_Profile__c == null || objLead.Lead_Owner_Profile__c.startsWith('Sales')){
                        if (mapCountOfHandedOverLeads.containsKey(globalKey)) {
                            mapCountOfHandedOverLeads.put(globalKey,mapCountOfHandedOverLeads.get(globalKey) + 1);   
                        }else{
                            mapCountOfHandedOverLeads.put(globalKey, 1);
                        }
                    }
                    //Lead Area based count 
                    if(objLead.Country_Ownership_Cluster__c != null){
                        String areaKey = ('Area'+ '_'+ objLead.Country_Ownership_Cluster__r.Name + '_' + month + '_' + year).deleteWhitespace();                 
                        if (mapLeadGeoCount.containsKey(areaKey)) {
                            mapLeadGeoCount.put(areaKey, mapLeadGeoCount.get(areaKey) + 1);
                            if(objLead.Lead_Owner_Profile__c == null || objLead.Lead_Owner_Profile__c.startsWith('Sales')){
                                mapLeadHandoverGeoCount.put(areaKey, mapLeadHandoverGeoCount.get(areaKey) + 1);   
                            }
                        } else {                           
                            mapLeadGeoCount.put(areaKey, 1);
                            if(objLead.Lead_Owner_Profile__c == null || objLead.Lead_Owner_Profile__c.startsWith('Sales')){
                                mapLeadHandoverGeoCount.put(areaKey, 1);   
                            }
                        } 
                        //Lead Region based count
                        String regionKey = ('Region'+ '_'+ objLead.Country_Ownership_Cluster__r.Parent_BDA__r.Name + '_' + month + '_' + year).deleteWhitespace();                 
                        if (mapLeadGeoCount.containsKey(regionKey)) {
                            mapLeadGeoCount.put(regionKey, mapLeadGeoCount.get(regionKey) + 1);
                            if(objLead.Lead_Owner_Profile__c == null || objLead.Lead_Owner_Profile__c.startsWith('Sales')){
                                mapLeadHandoverGeoCount.put(regionKey, mapLeadHandoverGeoCount.get(regionKey) + 1);   
                            }
                        } else {
                            mapLeadGeoCount.put(regionKey, 1);
                            if(objLead.Lead_Owner_Profile__c == null || objLead.Lead_Owner_Profile__c.startsWith('Sales')){
                                mapLeadHandoverGeoCount.put(regionKey, 1);   
                            }
                        } 
                    }
                }	
            }
            
            for (Ocean_Plus_Lead__c record : scope) {
                String month = getMonthName(record.CreatedDate.month());
                String year = String.valueOf(record.CreatedDate.year());
                
                //Global Aggregate
                String globalKey = ('Global'+ '_'+ month + '_' + year).deleteWhitespace();
                Ocean_Plus_Lead_Aggregate__c globalAgg = getOrCreateGlobalAggregate(mapAggregate, globalKey, month, year);               
                globalAgg.Total_Leads_Created__c = !mapCountOfLeads.isEmpty() && mapCountOfLeads.get(globalKey) != null ? mapCountOfLeads.get(globalKey):0;
                globalAgg.Total_Leads_Handed_Over_To_Sales__c = !mapLeadHandoverGeoCount.isEmpty() && mapLeadHandoverGeoCount.get(globalKey) != null ? mapLeadHandoverGeoCount.get(globalKey):0;
                globalAgg.Total_OPLs_created__c += 1;
                if (record.Max_Probability__c != null && record.Max_Probability__c >= 60) {  
                    globalAgg.Total_60_Above_OPLs_Created__c += 1;
                }else{
                    globalAgg.Total_60_Below_OPLs_Created__c += 1;
                }                
                
                //Region Aggregates
                //Origin region aggregate
                if (record.Origin_Region__c != null) {
                    String regionKey = ('Region'+ '_'+ record.Origin_Region__r.Name + '_' + month + '_' + year).deleteWhitespace(); 
                    Ocean_Plus_Lead_Aggregate__c orgRegAgg = getOrCreateGeoAggregate(mapAggregate, regionKey,record.Origin_Region__r.Name, month, year, 'Region');
                    orgRegAgg.Total_Leads_Created__c = !mapLeadGeoCount.isEmpty() && mapLeadGeoCount.get(regionKey) != null ? mapLeadGeoCount.get(regionKey):0;
                    orgRegAgg.Total_Leads_Handed_Over_To_Sales__c = !mapLeadHandoverGeoCount.isEmpty() && mapLeadHandoverGeoCount.get(regionKey) != null? mapLeadHandoverGeoCount.get(regionKey):0;
                    orgRegAgg.OPLs_Created_Export__c += 1;
                    if (record.Max_Export_Probability__c != null && record.Max_Export_Probability__c >= 60) {  
                        orgRegAgg.X60_Above_OPLs_Created_Export__c += 1;
                    }else{ 
                        orgRegAgg.X60_Below_OPLs_Created_Export__c += 1;
                    }               
                }
                //Destination region aggregate
                if (record.Destination_Region__c != null) {
                    String regionKey = ('Region' + '_'+ record.Destination_Region__r.Name + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c desRegAgg = getOrCreateGeoAggregate(mapAggregate, regionKey,record.Destination_Region__r.Name, month, year, 'Region');
                    desRegAgg.Total_Leads_Created__c = !mapLeadGeoCount.isEmpty() && mapLeadGeoCount.get(regionKey) != null ? mapLeadGeoCount.get(regionKey):0;
                    desRegAgg.Total_Leads_Handed_Over_To_Sales__c = !mapLeadHandoverGeoCount.isEmpty() && mapLeadHandoverGeoCount.get(regionKey) != null ? mapLeadHandoverGeoCount.get(regionKey):0;
                    desRegAgg.OPLs_Created_Import__c += 1;
                    if (record.Max_Import_Probability__c != null && record.Max_Import_Probability__c >= 60) {                       
                        desRegAgg.X60_Above_OPLs_Created_Import__c += 1;
                    }else{ 
                        desRegAgg.X60_Below_OPLs_Created_Import__c += 1;
                    }
                }                
                
                //Area Aggregates
                //Origin Area aggregate
                if (record.Origin_Area__c != null) {
                    String areaKey = ('Area'+ '_'+ record.Origin_Area__r.Name + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c orgAreaAgg = getOrCreateGeoAggregate(mapAggregate, areaKey,record.Origin_Area__r.Name, month, year, 'Area');
                    orgAreaAgg.Total_Leads_Created__c = !mapLeadGeoCount.isEmpty() && mapLeadGeoCount.get(areaKey) != null? mapLeadGeoCount.get(areaKey):0;
                    orgAreaAgg.Total_Leads_Handed_Over_To_Sales__c = !mapLeadHandoverGeoCount.isEmpty() && mapLeadHandoverGeoCount.get(areaKey) != null? mapLeadHandoverGeoCount.get(areaKey):0;
                    orgAreaAgg.OPLs_Created_Export__c += 1;
                    if (record.Max_Export_Probability__c != null && record.Max_Export_Probability__c >= 60) {  
                        orgAreaAgg.X60_Above_OPLs_Created_Export__c += 1;
                    }else{ 
                        orgAreaAgg.X60_Below_OPLs_Created_Export__c += 1;
                    }
                }
                
                //Destination Area aggregate
                if (record.Destination_Area__c != null) {
                    String areaKey = ('Area'+ '_'+ record.Destination_Area__r.Name + '_' + month + '_' + year).deleteWhitespace();                    
                    Ocean_Plus_Lead_Aggregate__c desAreaAgg = getOrCreateGeoAggregate(mapAggregate, areaKey,record.Destination_Area__r.Name, month, year, 'Area');
                    desAreaAgg.Total_Leads_Created__c = !mapLeadGeoCount.isEmpty() && mapLeadGeoCount.get(areaKey) != null? mapLeadGeoCount.get(areaKey):0;
                    desAreaAgg.Total_Leads_Handed_Over_To_Sales__c = !mapLeadHandoverGeoCount.isEmpty() && mapLeadHandoverGeoCount.get(areaKey) != null? mapLeadHandoverGeoCount.get(areaKey):0;
                    desAreaAgg.OPLs_Created_Import__c += 1;
                    if (record.Max_Import_Probability__c != null && record.Max_Import_Probability__c >= 60) { 
                        desAreaAgg.X60_Above_OPLs_Created_Import__c += 1;
                    }else{ 
                        desAreaAgg.X60_Below_OPLs_Created_Import__c += 1;
                    }
                } 
                //For Center and GSC areas and region which will never be OPL origin/destination but can be User Area/Region
                if (record.Primary_Owner_Region__c != null) {
                    String regionKey = ('Region'+ '_'+ record.Primary_Owner_Region__c + '_' + month + '_' + year).deleteWhitespace();                    
                    Ocean_Plus_Lead_Aggregate__c ownrRegionAgg = getOrCreateGeoAggregate(mapAggregate, regionKey,record.Primary_Owner_Region__c, month, year, 'Region');
                }
                if (record.Owner_Area__c != null) {
                    String areaKey = ('Area'+ '_'+ record.Owner_Area__c + '_' + month + '_' + year).deleteWhitespace();                    
                    Ocean_Plus_Lead_Aggregate__c ownrAreaAgg = getOrCreateGeoAggregate(mapAggregate, areaKey,record.Owner_Area__c, month, year, 'Area');
                } 
                
            }
        }
        catch(Exception e) {
            ErrorLogger.writeErrors('SFDC', 'OceanPlusLeadAggregate', 'Batch_OPLCreationAggregateCalculator.execute', new list<Exception>{e}); 
        }
    }
    
    public static String getMonthName(Integer monthNumber) {
        Map<Integer, String> mapOfMonthName = new Map<Integer, String>();
        mapOfMonthName.put(1, 'January');
        mapOfMonthName.put(2, 'February');
        mapOfMonthName.put(3, 'March');
        mapOfMonthName.put(4, 'April');
        mapOfMonthName.put(5, 'May');
        mapOfMonthName.put(6, 'June');
        mapOfMonthName.put(7, 'July');
        mapOfMonthName.put(8, 'August');
        mapOfMonthName.put(9, 'September');
        mapOfMonthName.put(10, 'October');
        mapOfMonthName.put(11, 'November');
        mapOfMonthName.put(12, 'December');
        return mapOfMonthName.get(monthNumber);
    }    
    
    private Ocean_Plus_Lead_Aggregate__c getOrCreateGlobalAggregate(Map<String, Ocean_Plus_Lead_Aggregate__c> mapAggregate, String key, String month, String year) {
        if (!mapAggregate.containsKey(key)) {
            mapAggregate.put(key, new Ocean_Plus_Lead_Aggregate__c(
                Month__c = month,
                Year__c = year,
                Key__c = key,
                Geography_Split__c = 'Global',
                Total_OPLs_created__c = 0,
                Total_60_Above_OPLs_Created__c = 0,
                Total_60_Below_OPLs_Created__c = 0,
                Total_Leads_Created__c = 0,
                Total_Leads_Handed_Over_To_Sales__c = 0
            ));
        }
        return mapAggregate.get(key);
    } 
    
    private Ocean_Plus_Lead_Aggregate__c getOrCreateGeoAggregate(Map<String, Ocean_Plus_Lead_Aggregate__c> mapAggregate, String key, String geography, String month, String year, String splitType) {
        if (!mapAggregate.containsKey(key)) {
            mapAggregate.put(key, new Ocean_Plus_Lead_Aggregate__c(
                Month__c = month,
                Year__c = year,
                Key__c = key,
                Geographyy__c = geography,
                Geography_Split__c = splitType,
                OPLs_Created_Export__c = 0 ,
                X60_Above_OPLs_Created_Export__c =0,
                X60_Below_OPLs_Created_Export__c = 0,
                OPLs_Created_Import__c = 0,                            
                X60_Above_OPLs_Created_Import__c = 0,
                X60_Below_OPLs_Created_Import__c = 0,
                Total_Leads_Created__c = 0,
                Total_Leads_Handed_Over_To_Sales__c = 0
            ));
        }
        return mapAggregate.get(key);
    }    
    
    public void finish(Database.BatchableContext bc) {
        try{
            if(mapAggregate.values() != null && mapAggregate.values().size() >0){
                insert mapAggregate.values();
            }
        }catch(Exception e) {
            ErrorLogger.writeErrors('SFDC', 'OceanPlusLeadAggregate', 'Batch_OPLCreationAggregateCalculator.finish', new list<Exception>{e}); 
        }
    }
    
}