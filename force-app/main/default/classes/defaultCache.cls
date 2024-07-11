/*
* Author   : Partha@maesk
* Purpose  : Implement 'Cache' so that the performance of code will improve by retriving result from cache 
*             instead fo the Database also  
*          
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010061   06/03/2019  Naved@maersk          Return Geography record from database for 1st time only,Remaimng times it calls from Cache.
 
*/
public class defaultCache implements Cache.CacheBuilder {
    public object doLoad(String cachename) {
        if(cachename=='Country'){
           list<Geography__c > geolist=[ SELECT Id, Name, GEO_ID__c FROM Geography__c WHERE Type_of_location__c = 'Country'];
           return geoList;
         }  
         return null;
    }
}