/*
* Author   : Richa
* Purpose  : Batch class to update Aggregate table records for Ocean Plus Lead object
*         
* Revision Ref Number  Date          Owner               Description
* -------- ----------  -----------   ----------          -----------
* 1.0      SC-9742     05-Jun-2024   Richa@Maersk        Batch class to calculate the aggregate values of existing OPL records
*/ 

public class BatchOPLCompletionAggregateCalculator implements Database.Batchable<sObject>, Database.Stateful {
    
    public Date startDate;
    public Date endDate;
    public Integer batchSize;
    public List<String> lstCompletedStatus = System.label.CrossSellCompletedStatusValues.split(',');
    
    // Maps to store the count 
    private Map<String, Ocean_Plus_Lead_Aggregate__c> mapAggregate = new Map<String, Ocean_Plus_Lead_Aggregate__c>();
    private Integer iteration;
    private Map<String, Integer> mapCountOfWonOpps = new Map<String, Integer> ();      
    private Map<String, Integer> mapOppGeoCount = new Map<String, Integer> ();      
    private Set<String> setTotalProcessedOPLs = new Set<String> (); 
    private Set<String> setTotalWonProcessedOPLs = new Set<String> (); 
    private Set<String> setOriginRegionProcessedOPLs = new Set<String> ();
    private Set<String> setOriginRegionWonProcessedOPLs = new Set<String> ();
    private Set<String> setDestinationRegionProcessedOPLs = new Set<String> ();
    private Set<String> setDestinationRegionWonProcessedOPLs = new Set<String> ();
    private Set<String> setOriginAreaProcessedOPLs = new Set<String> ();
    private Set<String> setOriginAreaWonProcessedOPLs = new Set<String> ();
    private Set<String> setDestinationAreaProcessedOPLs = new Set<String> ();
    private Set<String> setDestinationAreaWonProcessedOPLs = new Set<String> ();
    private Set<String> setOwnerRegionProcessedOPLs = new Set<String> ();
    private Set<String> setOwnerRegionWonProcessedOPLs = new Set<String> ();
    private Set<String> setOwnerAreaProcessedOPLs = new Set<String> ();
    private Set<String> setOwnerAreaWonProcessedOPLs = new Set<String> ();
    
    public BatchOPLCompletionAggregateCalculator(Date startDate,Date endDate,Integer batchSize) { 
        this.startDate = startDate;
        this.endDate = endDate;
        this.batchSize = batchSize;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {       
        String query = 'SELECT Id,Booking_Number__c,Last_Status_Update__c,Ocean_Plus_Lead__c,Product__c,Revenue__c,Owner_Region__c, Owner_Area__c,Ocean_Plus_Lead__r.Total_Revenue__c,Ocean_Plus_Lead__r.Booked_FFE__c,Ocean_Plus_Lead__r.Status__c,Ocean_Plus_Lead__r.Max_Probability__c,Ocean_Plus_Lead__r.Max_Export_Probability__c,Ocean_Plus_Lead__r.Max_Import_Probability__c,createddate,lastmodifieddate,Status__c,Ocean_Plus_Lead__r.Origin_Region__c,Ocean_Plus_Lead__r.Destination_Region__c,Ocean_Plus_Lead__r.Origin_Area__c,Ocean_Plus_Lead__r.Destination_Area__c,Ocean_Plus_Lead__r.Origin_Region__r.Name,Ocean_Plus_Lead__r.Destination_Region__r.Name,Ocean_Plus_Lead__r.Origin_Area__r.Name,Ocean_Plus_Lead__r.Destination_Area__r.Name FROM Ocean_Plus_Line_Item__c WHERE Status__c IN :lstCompletedStatus'+
            ' AND (Ocean_Plus_Lead__r.Booking_Status__c = \'Active\' OR Ocean_Plus_Lead__r.Booking_Status__c = null) AND Ocean_Plus_Lead__r.Status__c IN:lstCompletedStatus ' ;
        if(startDate != null && endDate != null){
            query += ' AND Last_Status_Update__c  >= :startDate AND Last_Status_Update__c  < :endDate';
        }else{
            query += ' AND Last_Status_Update__c = LAST_MONTH';
        }
        query += ' ORDER BY Booking_Number__c, Last_Status_Update__c DESC';
        if(batchSize != null){
            query += ' LIMIT ' + batchSize;
        } 
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, list<Ocean_Plus_Line_Item__c> scope) {       
        List<Ocean_Plus_Lead_Aggregate__c> lstOPLAggregate = new List<Ocean_Plus_Lead_Aggregate__c>();
        try {                 
            List<String> lstExportProds = System.label.CrossSellExportProducts.toLowerCase().split(',');
            List<String> lstImportProds = System.label.CrossSellImportProducts.toLowerCase().split(','); 
            if(iteration == null){
                iteration = 0;
                List<Opportunity> lstOpportunityWon = new List<Opportunity>();
                if(startDate != null && endDate != null){
                    lstOpportunityWon = [Select Id,CloseDate,Account.Account_Address_Area__r.Name,Account.Account_Address_Area__r.Parent_BDA__r.Name from Opportunity where CloseDate >=:startDate AND CloseDate <:endDate AND StageName = 'Closed Won' AND Comments_for_Lead_source__c LIKE 'CX%' Limit 50000];
                }else{
                    lstOpportunityWon = [Select Id,CloseDate,Account.Account_Address_Area__r.Name,Account.Account_Address_Area__r.Parent_BDA__r.Name from Opportunity where CloseDate = LAST_MONTH AND StageName = 'Closed Won' AND Comments_for_Lead_source__c LIKE 'CX%' Limit 50000];
                }
                for(Opportunity opp : lstOpportunityWon){
                    
                    String month = BatchOPLCreationAggregateCalculator.getMonthName(opp.CloseDate.month());
                    String year = String.valueOf(opp.CloseDate.year()); 
                    String globalKey = ('Global' +'_' + month + '_' + year).deleteWhitespace();
                    //Global Won Opportunity count
                    if(mapCountOfWonOpps.containsKey(globalKey)) {
                        mapCountOfWonOpps.put(globalKey,mapCountOfWonOpps.get(globalKey) + 1);   
                    }else{
                        mapCountOfWonOpps.put(globalKey, 1);
                    }
                    if(opp.Account.Account_Address_Area__r.Name != null){
                        String areaKey = ('Area' +'_' +opp.Account.Account_Address_Area__r.Name + '_' + month + '_' + year).deleteWhitespace();                 
                        //Won Opportunity per Area count
                        if (mapOppGeoCount.containsKey(areaKey)) {
                            mapOppGeoCount.put(areaKey, mapOppGeoCount.get(areaKey) + 1);
                        } else {
                            mapOppGeoCount.put(areaKey, 1);
                        } 
                        String regionKey = ('Region' +'_' + opp.Account.Account_Address_Area__r.Parent_BDA__r.Name + '_' + month + '_' + year).deleteWhitespace();                 
                        //Won Opportunity per Region count
                        if (mapOppGeoCount.containsKey(regionKey)) {
                            mapOppGeoCount.put(regionKey, mapOppGeoCount.get(regionKey) + 1);
                        } else {
                            mapOppGeoCount.put(regionKey, 1);
                        } 
                    }
                }	
            }
            
            for (Ocean_Plus_Line_Item__c record : scope) {  
                String month = BatchOPLCreationAggregateCalculator.getMonthName(record.Last_Status_Update__c.month());
                String year = String.valueOf(record.Last_Status_Update__c.year());                       
                
                //Global Aggregate
                String globalKey = ('Global' +'_' + month + '_' + year).deleteWhitespace();  
                Ocean_Plus_Lead_Aggregate__c globalAgg = getOrCreateGlobalAggregate(mapAggregate, globalKey, month, year); 
                if(!setTotalProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){ 
                    globalAgg.Total_OPLs_Completed__c += 1;
                    globalAgg.Total_Opportunities_Won__c = !mapCountOfWonOpps.isEmpty() && mapCountOfWonOpps.get(globalKey) != null ? mapCountOfWonOpps.get(globalKey):0;
                    if(record.Ocean_Plus_Lead__r.Max_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Probability__c >= 60) {
                        globalAgg.Total_60_Above_OPLs_Completed__c += 1;
                    }else{
                        globalAgg.Total_60_Below_OPLs_Completed__c += 1;
                    }
                    setTotalProcessedOPLs.add(record.Ocean_Plus_Lead__c);//Set to avoid duplicate count of OPLs as iteration is on OPLIs
                }
                
                if(record.Status__c == 'Sold' && lstCompletedStatus.contains(record.Ocean_Plus_Lead__r.Status__c) && !setTotalWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){                       
                    globalAgg.Total_OPLs_Won__c += 1;
                    globalAgg.Total_Revenue__c += record.Ocean_Plus_Lead__r.Total_Revenue__c;
                    globalAgg.Total_FFEs_Won__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                    if(record.Ocean_Plus_Lead__r.Max_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Probability__c >= 60) {
                        globalAgg.Total_60_Above_OPLs_Won__c += 1;
                        globalAgg.Total_60_Above_Revenue__c += record.Ocean_Plus_Lead__r.Total_Revenue__c;
                        globalAgg.Total_60_Above_FFEs_Won__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                    }else{
                        globalAgg.Total_60_Below_OPLs_Won__c += 1;
                        globalAgg.Total_60_Below_Revenue__c += record.Ocean_Plus_Lead__r.Total_Revenue__c;
                        globalAgg.Total_60_Below_FFEs_Won__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                    }
                    setTotalWonProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                }
                
                //Region aggregate   
                
                //Origin Region aggregate                    
                if (record.Ocean_Plus_Lead__r.Origin_Region__c != null && lstExportProds.contains(record.Product__c.toLowerCase())) {                   
                    String regionKey = ('Region' +'_' + record.Ocean_Plus_Lead__r.Origin_Region__r.Name + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c orgRegAgg = getOrCreateGeoAggregate(mapAggregate, regionKey,record.Ocean_Plus_Lead__r.Origin_Region__r.Name, month, year, 'Region'); 
                    orgRegAgg.Total_Opportunities_Won__c = !mapOppGeoCount.isEmpty() && mapOppGeoCount.get(regionKey) != null ? mapOppGeoCount.get(regionKey):0;
                    if(!setOriginRegionProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){	
                        orgRegAgg.OPLs_Completed_Export__c += 1;
                        if(record.Ocean_Plus_Lead__r.Max_Export_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Export_Probability__c >= 60) {
                            orgRegAgg.X60_Above_OPLs_Completed_Export__c += 1;
                        }else{
                            orgRegAgg.X60_Below_OPLs_Completed_Export__c += 1;
                        }
                        setOriginRegionProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                    }
                    if(record.Status__c == 'Sold' && lstCompletedStatus.contains(record.Ocean_Plus_Lead__r.Status__c)){ 
                        if(!setOriginRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                            orgRegAgg.OPLs_Won_Export__c += 1;                       
                            orgRegAgg.FFEs_Won_Export__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                        }
                        orgRegAgg.Revenue_Export__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        if(record.Ocean_Plus_Lead__r.Max_Export_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Export_Probability__c >= 60) {
                            if(!setOriginRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                orgRegAgg.X60_Above_OPLs_Won_Export__c += 1;
                                orgRegAgg.X60_Above_FFEs_Won_Export__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            orgRegAgg.X60_Above_Revenue_Export__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }else{
                            if(!setOriginRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                orgRegAgg.X60_Below_OPLs_Won_Export__c += 1;
                                orgRegAgg.X60_Below_FFEs_Won_Export__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            orgRegAgg.X60_Below_Revenue_Export__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }
                        setOriginRegionWonProcessedOPLs.add(record.Ocean_Plus_Lead__c);//Separate set for won OPLIs to avoid double count of won OPL and FFE
                    }
                }
                
                //Destination Region Aggregate                
                if (record.Ocean_Plus_Lead__r.Destination_Region__c != null &&lstImportProds.contains(record.Product__c.toLowerCase())) {
                    String regionKey = ('Region' +'_' + record.Ocean_Plus_Lead__r.Destination_Region__r.Name + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c desRegAgg = getOrCreateGeoAggregate(mapAggregate, regionKey,record.Ocean_Plus_Lead__r.Destination_Region__r.Name, month, year, 'Region'); 
                    desRegAgg.Total_Opportunities_Won__c = !mapOppGeoCount.isEmpty() && mapOppGeoCount.get(regionKey) != null? mapOppGeoCount.get(regionKey):0;
                    if(!setDestinationRegionProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){	
                        desRegAgg.OPLs_Completed_Import__c += 1;
                        if(record.Ocean_Plus_Lead__r.Max_Import_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Import_Probability__c >= 60) {
                            desRegAgg.X60_Above_OPLs_Completed_Import__c += 1;
                        }else{
                            desRegAgg.X60_Below_OPLs_Completed_Import__c += 1;
                        }
                        setDestinationRegionProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                    }
                    if(record.Status__c == 'Sold' && lstCompletedStatus.contains(record.Ocean_Plus_Lead__r.Status__c)){ 
                        if(!setDestinationRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                            desRegAgg.OPLs_Won_Import__c += 1;                       
                            desRegAgg.FFEs_Won_Import__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                        }
                        desRegAgg.Revenue_Import__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        if(record.Ocean_Plus_Lead__r.Max_Import_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Import_Probability__c >= 60) {
                            if(!setDestinationRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                desRegAgg.X60_Above_OPLs_Won_Import__c += 1;
                                desRegAgg.X60_Above_FFEs_Won_Import__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            desRegAgg.X60_Above_Revenue_Import__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }else{
                            if(!setDestinationRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                desRegAgg.X60_Below_OPLs_Won_Import__c += 1;
                                desRegAgg.X60_Below_FFEs_Won_Import__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            desRegAgg.X60_Below_Revenue_Import__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }
                        setDestinationRegionWonProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                    }
                    
                }
                
                //Owner Region aggregate
                if (record.Owner_Region__c != null ) {                   
                    String regionKey = ('Region' +'_' + record.Owner_Region__c + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c ownrRegAgg = getOrCreateGeoAggregate(mapAggregate, regionKey,record.Owner_Region__c, month, year, 'Region'); 
                    if(!setOwnerRegionProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Region__c)){	
                        ownrRegAgg.OPLs_Completed_Owner__c += 1;
                        if(record.Ocean_Plus_Lead__r.Max_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Probability__c >= 60) {
                            ownrRegAgg.X60_Above_OPLs_Completed_Owner__c += 1;
                        }else{
                            ownrRegAgg.X60_Below_OPLs_Completed_Owner__c += 1;
                        }
                        setOwnerRegionProcessedOPLs.add(record.Ocean_Plus_Lead__c+record.Owner_Region__c);//Set has both OPL Id and Owner geography as key in case of multiple Owners for OPL to avoid missing count of OPL
                    }
                    if(record.Status__c == 'Sold'){ 
                        if(!setOwnerRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Region__c)){
                            ownrRegAgg.OPLs_Won_Owner__c += 1;                       
                            ownrRegAgg.FFEs_Won_owner__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                        }
                        ownrRegAgg.Revenue_Owner__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        if(record.Ocean_Plus_Lead__r.Max_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Probability__c >= 60) {
                            if(!setOwnerRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Region__c)){
                                    ownrRegAgg.X60_Above_OPLs_Won_Owner__c += 1;
                                    ownrRegAgg.X60_Above_FFEs_Won_Owner__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                                }
                            ownrRegAgg.X60_Above_Revenue_Owner__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }else{
                            if(!setOwnerRegionWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Region__c)){
                                ownrRegAgg.X60_Below_OPLs_Won_Owner__c += 1;
                                ownrRegAgg.X60_Below_FFEs_Won_Owner__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            ownrRegAgg.X60_Below_Revenue_Owner__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }
                        setOwnerRegionWonProcessedOPLs.add(record.Ocean_Plus_Lead__c+record.Owner_Region__c);
                    }
                }
                
                //Area aggregate
                
                //Origin Area aggregate
                if (record.Ocean_Plus_Lead__r.Origin_Area__c != null && lstExportProds.contains(record.Product__c.toLowerCase())) {
                    String areaKey = ('Area' +'_' + record.Ocean_Plus_Lead__r.Origin_Area__r.Name + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c orgAreaAgg = getOrCreateGeoAggregate(mapAggregate, areaKey,record.Ocean_Plus_Lead__r.Origin_Area__c, month, year, 'Area'); 
                    orgAreaAgg.Total_Opportunities_Won__c = !mapOppGeoCount.isEmpty() && mapOppGeoCount.get(areaKey) != null ? mapOppGeoCount.get(areaKey):0;
                    if(!setOriginAreaProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){	
                        orgAreaAgg.OPLs_Completed_Export__c += 1;
                        if(record.Ocean_Plus_Lead__r.Max_Export_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Export_Probability__c >= 60) {
                            orgAreaAgg.X60_Above_OPLs_Completed_Export__c += 1;
                        }else{
                            orgAreaAgg.X60_Below_OPLs_Completed_Export__c += 1;
                        }
                        setOriginAreaProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                    }
                    if(record.Status__c == 'Sold' && lstCompletedStatus.contains(record.Ocean_Plus_Lead__r.Status__c)){ 
                        if(!setOriginAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                            orgAreaAgg.OPLs_Won_Export__c += 1;                       
                            orgAreaAgg.FFEs_Won_Export__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                        }
                        orgAreaAgg.Revenue_Export__c += record.Revenue__c != null?record.Revenue__c:0;
                        if(record.Ocean_Plus_Lead__r.Max_Export_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Export_Probability__c >= 60) {
                            if(!setOriginAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                orgAreaAgg.X60_Above_OPLs_Won_Export__c += 1;
                                orgAreaAgg.X60_Above_FFEs_Won_Export__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            orgAreaAgg.X60_Above_Revenue_Export__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }else{  
                            if(!setOriginAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                orgAreaAgg.X60_Below_OPLs_Won_Export__c += 1;
                                orgAreaAgg.X60_Below_FFEs_Won_Export__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            orgAreaAgg.X60_Below_Revenue_Export__c += record.Revenue__c != null?record.Revenue__c:0;                     		
                        }
                        setOriginAreaWonProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                    }                   
                }
                //Destination Area Aggregate                    
                if (record.Ocean_Plus_Lead__r.Destination_Area__c != null && lstImportProds.contains(record.Product__c.toLowerCase())) {
                    String areaKey = ('Area' +'_' + record.Ocean_Plus_Lead__r.Destination_Area__r.Name + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c desAreaAgg = getOrCreateGeoAggregate(mapAggregate, areaKey,record.Ocean_Plus_Lead__r.Destination_Area__c, month, year,'Area'); 
                    desAreaAgg.Total_Opportunities_Won__c = !mapOppGeoCount.isEmpty() && mapOppGeoCount.get(areaKey) != null ? mapOppGeoCount.get(areaKey):0;
                    if(!setDestinationAreaProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){	
                        desAreaAgg.OPLs_Completed_Import__c += 1;
                        if(record.Ocean_Plus_Lead__r.Max_Import_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Import_Probability__c >= 60) {
                            desAreaAgg.X60_Above_OPLs_Completed_Import__c += 1;
                        }else{
                            desAreaAgg.X60_Below_OPLs_Completed_Import__c += 1;
                        }
                        setDestinationAreaProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                    }
                    if(record.Status__c == 'Sold' && lstCompletedStatus.contains(record.Ocean_Plus_Lead__r.Status__c)){ 
                        if(!setDestinationAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                            desAreaAgg.OPLs_Won_Import__c += 1;                       
                            desAreaAgg.FFEs_Won_Import__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                        }
                        desAreaAgg.Revenue_Import__c += record.Revenue__c != null?record.Revenue__c:0;
                        if(record.Ocean_Plus_Lead__r.Max_Import_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Import_Probability__c >= 60) {
                            if(!setDestinationAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                desAreaAgg.X60_Above_OPLs_Won_Import__c += 1;
                                desAreaAgg.X60_Above_FFEs_Won_Import__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            desAreaAgg.X60_Above_Revenue_Import__c += record.Revenue__c != null?record.Revenue__c:0;                               
                        }else{
                            if(!setDestinationAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c)){
                                desAreaAgg.X60_Below_OPLs_Won_Import__c += 1;
                                desAreaAgg.X60_Below_FFEs_Won_Import__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            desAreaAgg.X60_Below_Revenue_Import__c += record.Revenue__c != null?record.Revenue__c:0;                   		
                        }
                        setDestinationAreaWonProcessedOPLs.add(record.Ocean_Plus_Lead__c);
                    }                    
                }
                
                //Owner Area aggregate
                if (record.Owner_Area__c != null) {
                    String areaKey = ('Area' +'_' + record.Owner_Area__c + '_' + month + '_' + year).deleteWhitespace();
                    Ocean_Plus_Lead_Aggregate__c ownrAreaAgg = getOrCreateGeoAggregate(mapAggregate, areaKey,record.Owner_Area__c, month, year, 'Area'); 
                    if(!setOwnerAreaProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Area__c)){	
                        ownrAreaAgg.OPLs_Completed_Owner__c += 1;
                        if(record.Ocean_Plus_Lead__r.Max_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Probability__c >= 60) {
                            ownrAreaAgg.X60_Above_OPLs_Completed_Owner__c += 1;
                        }else{
                            ownrAreaAgg.X60_Below_OPLs_Completed_Owner__c += 1;
                        }
                        setOwnerAreaProcessedOPLs.add(record.Ocean_Plus_Lead__c+record.Owner_Area__c);
                    }
                    if(record.Status__c == 'Sold'){ 
                        if(!setOwnerAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Area__c)){
                            ownrAreaAgg.OPLs_Won_Owner__c += 1;                       
                            ownrAreaAgg.FFEs_Won_Owner__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                        }
                        ownrAreaAgg.Revenue_Owner__c += record.Revenue__c != null?record.Revenue__c:0;
                        if(record.Ocean_Plus_Lead__r.Max_Probability__c != null && record.Ocean_Plus_Lead__r.Max_Probability__c >= 60) {
                            if(!setOwnerAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Area__c)){
                                ownrAreaAgg.X60_Above_OPLs_Won_Owner__c += 1;
                                ownrAreaAgg.X60_Above_FFEs_Won_Owner__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            ownrAreaAgg.X60_Above_Revenue_Owner__c += record.Revenue__c != null?record.Revenue__c:0;                              
                        }else{  
                            if(!setOwnerAreaWonProcessedOPLs.contains(record.Ocean_Plus_Lead__c+record.Owner_Area__c)){
                                ownrAreaAgg.X60_Below_OPLs_Won_Owner__c += 1;
                                ownrAreaAgg.X60_Below_FFEs_Won_Owner__c += record.Ocean_Plus_Lead__r.Booked_FFE__c != null ? record.Ocean_Plus_Lead__r.Booked_FFE__c:0;
                            }
                            ownrAreaAgg.X60_Below_Revenue_Owner__c += record.Revenue__c != null?record.Revenue__c:0;                     		
                        }
                        setOwnerAreaWonProcessedOPLs.add(record.Ocean_Plus_Lead__c+record.Owner_Area__c);
                    }                   
                }
                
            }
            
            //Update the existing aggregate records
            for (Ocean_Plus_Lead_Aggregate__c aggRecords : [Select Id,Month__c,Year__c,Key__c,Geographyy__c,Geography_Split__c,Total_OPLs_Completed__c,Total_60_Above_OPLs_Completed__c,Total_60_Below_OPLs_Completed__c,Total_OPLs_Won__c,Total_Revenue__c,Total_FFEs_Won__c,Total_60_Above_OPLs_Won__c,Total_60_Above_Revenue__c,Total_60_Above_FFEs_Won__c,Total_60_Below_OPLs_Won__c,Total_60_Below_Revenue__c,Total_60_Below_FFEs_Won__c,Total_Opportunities_Won__c,OPLs_Completed_Export__c,X60_Above_OPLs_Completed_Export__c,X60_Below_OPLs_Completed_Export__c,OPLs_Won_Export__c,Revenue_Export__c,FFEs_Won_Export__c,X60_Above_OPLs_Won_Export__c,X60_Above_Revenue_Export__c,X60_Above_FFEs_Won_Export__c,X60_Below_OPLs_Won_Export__c,X60_Below_Revenue_Export__c,X60_Below_FFEs_Won_Export__c,OPLs_Completed_Import__c,X60_Above_OPLs_Completed_Import__c,X60_Below_OPLs_Completed_Import__c,OPLs_Won_Import__c,Revenue_Import__c,FFEs_Won_Import__c,X60_Above_OPLs_Won_Import__c,X60_Above_Revenue_Import__c,X60_Above_FFEs_Won_Import__c,X60_Below_OPLs_Won_Import__c,X60_Below_Revenue_Import__c,X60_Below_FFEs_Won_Import__c  from Ocean_Plus_Lead_Aggregate__c where Key__c IN: mapAggregate.keySet()]) {
                if (mapAggregate.containsKey(aggRecords.Key__c)) {
                    Ocean_Plus_Lead_Aggregate__c aggregate = mapAggregate.get(aggRecords.Key__c);
                    aggRecords.Total_OPLs_Completed__c += aggregate.Total_OPLs_Completed__c != null?aggregate.Total_OPLs_Completed__c:0;
                    aggRecords.Total_60_Above_OPLs_Completed__c += aggregate.Total_60_Above_OPLs_Completed__c != null?aggregate.Total_60_Above_OPLs_Completed__c:0;
                    aggRecords.Total_60_Below_OPLs_Completed__c += aggregate.Total_60_Below_OPLs_Completed__c != null?aggregate.Total_60_Below_OPLs_Completed__c:0;
                    aggRecords.Total_OPLs_Won__c += aggregate.Total_OPLs_Won__c != null?aggregate.Total_OPLs_Won__c:0;
                    aggRecords.Total_Revenue__c += aggregate.Total_Revenue__c != null?aggregate.Total_Revenue__c:0;
                    aggRecords.Total_FFEs_Won__c += aggregate.Total_FFEs_Won__c != null?aggregate.Total_FFEs_Won__c:0;
                    aggRecords.Total_60_Above_OPLs_Won__c += aggregate.Total_60_Above_OPLs_Won__c != null?aggregate.Total_60_Above_OPLs_Won__c:0;
                    aggRecords.Total_60_Above_Revenue__c += aggregate.Total_60_Above_Revenue__c != null?aggregate.Total_60_Above_Revenue__c:0;
                    aggRecords.Total_60_Above_FFEs_Won__c += aggregate.Total_60_Above_FFEs_Won__c != null?aggregate.Total_60_Above_FFEs_Won__c:0;
                    aggRecords.Total_60_Below_OPLs_Won__c += aggregate.Total_60_Below_OPLs_Won__c != null?aggregate.Total_60_Below_OPLs_Won__c:0;
                    aggRecords.Total_60_Below_Revenue__c += aggregate.Total_60_Below_Revenue__c != null?aggregate.Total_60_Below_Revenue__c:0;
                    aggRecords.Total_60_Below_FFEs_Won__c += aggregate.Total_60_Below_FFEs_Won__c != null?aggregate.Total_60_Below_FFEs_Won__c:0;
                    aggRecords.OPLs_Completed_Export__c = aggregate.OPLs_Completed_Export__c != null?aggregate.OPLs_Completed_Export__c:0;
                    aggRecords.X60_Above_OPLs_Completed_Export__c = aggregate.X60_Above_OPLs_Completed_Export__c != null?aggregate.X60_Above_OPLs_Completed_Export__c:0;
                    aggRecords.X60_Below_OPLs_Completed_Export__c = aggregate.X60_Below_OPLs_Completed_Export__c != null?aggregate.X60_Below_OPLs_Completed_Export__c:0;
                    aggRecords.OPLs_Won_Export__c = aggregate.OPLs_Won_Export__c != null?aggregate.OPLs_Won_Export__c:0;
                    aggRecords.Revenue_Export__c = aggregate.Revenue_Export__c != null?aggregate.Revenue_Export__c:0;
                    aggRecords.FFEs_Won_Export__c = aggregate.FFEs_Won_Export__c != null?aggregate.FFEs_Won_Export__c:0;
                    aggRecords.X60_Above_OPLs_Won_Export__c = aggregate.X60_Above_OPLs_Won_Export__c != null?aggregate.X60_Above_OPLs_Won_Export__c:0;
                    aggRecords.X60_Above_Revenue_Export__c = aggregate.X60_Above_Revenue_Export__c != null?aggregate.X60_Above_Revenue_Export__c:0;
                    aggRecords.X60_Above_FFEs_Won_Export__c = aggregate.X60_Above_FFEs_Won_Export__c != null?aggregate.X60_Above_FFEs_Won_Export__c:0;
                    aggRecords.X60_Below_OPLs_Won_Export__c =aggregate.X60_Below_OPLs_Won_Export__c != null?aggregate.X60_Below_OPLs_Won_Export__c:0;
                    aggRecords.X60_Below_Revenue_Export__c = aggregate.X60_Below_Revenue_Export__c != null?aggregate.X60_Below_Revenue_Export__c:0;
                    aggRecords.X60_Below_FFEs_Won_Export__c = aggregate.X60_Below_FFEs_Won_Export__c != null?aggregate.X60_Below_FFEs_Won_Export__c:0;
                    aggRecords.OPLs_Completed_Import__c = aggregate.OPLs_Completed_Import__c != null?aggregate.OPLs_Completed_Import__c:0;
                    aggRecords.X60_Above_OPLs_Completed_Import__c = aggregate.X60_Above_OPLs_Completed_Import__c != null?aggregate.X60_Above_OPLs_Completed_Import__c:0;
                    aggRecords.X60_Below_OPLs_Completed_Import__c = aggregate.X60_Below_OPLs_Completed_Import__c != null?aggregate.X60_Below_OPLs_Completed_Import__c:0;
                    aggRecords.OPLs_Won_Import__c = aggregate.OPLs_Won_Import__c != null?aggregate.OPLs_Won_Import__c:0;
                    aggRecords.Revenue_Import__c = aggregate.Revenue_Import__c != null?aggregate.Revenue_Import__c:0;
                    aggRecords.FFEs_Won_Import__c = aggregate.FFEs_Won_Import__c != null?aggregate.FFEs_Won_Import__c:0;
                    aggRecords.X60_Above_OPLs_Won_Import__c = aggregate.X60_Above_OPLs_Won_Import__c != null?aggregate.X60_Above_OPLs_Won_Import__c:0;
                    aggRecords.X60_Above_Revenue_Import__c = aggregate.X60_Above_Revenue_Import__c != null?aggregate.X60_Above_Revenue_Import__c:0;
                    aggRecords.X60_Above_FFEs_Won_Import__c = aggregate.X60_Above_FFEs_Won_Import__c != null?aggregate.X60_Above_FFEs_Won_Import__c:0;
                    aggRecords.X60_Below_OPLs_Won_Import__c = aggregate.X60_Below_OPLs_Won_Import__c != null?aggregate.X60_Below_OPLs_Won_Import__c:0;
                    aggRecords.X60_Below_Revenue_Import__c = aggregate.X60_Below_Revenue_Import__c != null?aggregate.X60_Below_Revenue_Import__c:0;
                    aggRecords.X60_Below_FFEs_Won_Import__c = aggregate.X60_Below_FFEs_Won_Import__c != null?aggregate.X60_Below_FFEs_Won_Import__c:0;
                    aggRecords.OPLs_Completed_Owner__c = aggregate.OPLs_Completed_Owner__c != null?aggregate.OPLs_Completed_Owner__c:0;
                    aggRecords.X60_Above_OPLs_Completed_Owner__c = aggregate.X60_Above_OPLs_Completed_Owner__c != null?aggregate.X60_Above_OPLs_Completed_Owner__c:0;
                    aggRecords.X60_Below_OPLs_Completed_Owner__c = aggregate.X60_Below_OPLs_Completed_Owner__c != null?aggregate.X60_Below_OPLs_Completed_Owner__c:0;
                    aggRecords.OPLs_Won_Owner__c = aggregate.OPLs_Won_Owner__c != null?aggregate.OPLs_Won_Owner__c:0;
                    aggRecords.Revenue_Owner__c = aggregate.Revenue_Owner__c != null?aggregate.Revenue_Owner__c:0;
                    aggRecords.FFEs_Won_Owner__c = aggregate.FFEs_Won_Owner__c != null?aggregate.FFEs_Won_Owner__c:0;
                    aggRecords.X60_Above_OPLs_Won_Owner__c = aggregate.X60_Above_OPLs_Won_Owner__c != null?aggregate.X60_Above_OPLs_Won_Owner__c:0;
                    aggRecords.X60_Above_Revenue_Owner__c = aggregate.X60_Above_Revenue_Owner__c != null?aggregate.X60_Above_Revenue_Owner__c:0;
                    aggRecords.X60_Above_FFEs_Won_Owner__c = aggregate.X60_Above_FFEs_Won_Owner__c != null?aggregate.X60_Above_FFEs_Won_Owner__c:0;
                    aggRecords.X60_Below_OPLs_Won_Owner__c = aggregate.X60_Below_OPLs_Won_Owner__c != null?aggregate.X60_Below_OPLs_Won_Owner__c:0;
                    aggRecords.X60_Below_Revenue_Owner__c = aggregate.X60_Below_Revenue_Owner__c != null?aggregate.X60_Below_Revenue_Owner__c:0;
                    aggRecords.X60_Below_FFEs_Won_Owner__c = aggregate.X60_Below_FFEs_Won_Owner__c != null?aggregate.X60_Below_FFEs_Won_Owner__c:0;
                    aggRecords.Total_Opportunities_Won__c = aggregate.Total_Opportunities_Won__c != null?aggregate.Total_Opportunities_Won__c:0;
                    mapAggregate.remove(aggRecords.Key__c);
                    lstOPLAggregate.add(aggRecords);
                }  
            }
            if(lstOPLAggregate != null && lstOPLAggregate.size() >0){
                update lstOPLAggregate;
            }
        }
        catch(Exception e) {
            ErrorLogger.writeErrors('SFDC', 'OceanPlusLeadAggregate', 'Batch_OPLCompletionAggregateCalculator', new list<Exception>{e}); 
        }
    }
    
    private Ocean_Plus_Lead_Aggregate__c getOrCreateGlobalAggregate(Map<String, Ocean_Plus_Lead_Aggregate__c> mapAggregate, String key, String month, String year) {
        if (!mapAggregate.containsKey(key)) {
            mapAggregate.put(key, new Ocean_Plus_Lead_Aggregate__c(
                Month__c = month,
                Year__c = year,
                Key__c = key,
                Total_OPLs_Completed__c = 0,
                Total_60_Above_OPLs_Completed__c = 0,
                Total_60_Below_OPLs_Completed__c = 0,
                Total_OPLs_Won__c = 0,
                Total_Revenue__c = 0,
                Total_FFEs_Won__c = 0,
                Total_60_Above_OPLs_Won__c = 0,
                Total_60_Above_Revenue__c = 0,
                Total_60_Above_FFEs_Won__c = 0,
                Total_60_Below_OPLs_Won__c = 0,
                Total_60_Below_Revenue__c = 0,
                Total_60_Below_FFEs_Won__c = 0,
                Total_Opportunities_Won__c= 0
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
                OPLs_Completed_Export__c = 0,
                X60_Above_OPLs_Completed_Export__c = 0,
                X60_Below_OPLs_Completed_Export__c = 0,
                OPLs_Won_Export__c = 0,               
                Revenue_Export__c = 0,
                FFEs_Won_Export__c = 0,
                X60_Above_OPLs_Won_Export__c = 0,
                X60_Above_Revenue_Export__c = 0,
                X60_Above_FFEs_Won_Export__c = 0,
                X60_Below_OPLs_Won_Export__c = 0,
                X60_Below_Revenue_Export__c = 0,
                X60_Below_FFEs_Won_Export__c = 0,                
                
                OPLs_Completed_Import__c = 0,
                X60_Above_OPLs_Completed_Import__c = 0,
                X60_Below_OPLs_Completed_Import__c = 0,
                OPLs_Won_Import__c = 0,
                Revenue_Import__c = 0,
                FFEs_Won_Import__c = 0,
                X60_Above_OPLs_Won_Import__c = 0,
                X60_Above_Revenue_Import__c = 0,
                X60_Above_FFEs_Won_Import__c = 0,
                X60_Below_OPLs_Won_Import__c = 0,
                X60_Below_Revenue_Import__c = 0,
                X60_Below_FFEs_Won_Import__c = 0,
                
                OPLs_Completed_Owner__c = 0,
                X60_Above_OPLs_Completed_Owner__c = 0,
                X60_Below_OPLs_Completed_Owner__c = 0,
                OPLs_Won_Owner__c = 0,
                Revenue_Owner__c = 0,
                FFEs_Won_Owner__c = 0,
                X60_Above_OPLs_Won_Owner__c = 0,
                X60_Above_Revenue_Owner__c = 0,
                X60_Above_FFEs_Won_Owner__c = 0,
                X60_Below_OPLs_Won_Owner__c = 0,
                X60_Below_Revenue_Owner__c = 0,
                X60_Below_FFEs_Won_Owner__c = 0,                
                Total_Opportunities_Won__c = 0
            ));
        }
        return mapAggregate.get(key);
    }    
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
}