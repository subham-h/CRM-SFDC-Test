/*
* Author    : Ranjan
* Purpose   : Test class for CaseRelatedObjectsDataSourceConnnection
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   13-Oct-2022 Ranjan@Maersk            Created. 
* 
*/
@isTest
private class CaseRelatedObjectsDataSourceCon_Test {
    static testMethod void test_syncEmailArchival() {
        Test.setMock(HttpCalloutMock.class, new CaseRelatedObjDataSourceProviderMock());
        CaseRelatedObjectsDataSourceConnection conn =new  CaseRelatedObjectsDataSourceConnection(null);
        conn.sync();
    }
    static testMethod void test_CaseRelatedObjectsDataSourceProvider() {
        CaseRelatedObjectsDataSourceProvider dbObj= new CaseRelatedObjectsDataSourceProvider();
        dbObj.getAuthenticationCapabilities();
        dbObj.getCapabilities();
        dbObj.getConnection(new DataSource.ConnectionParams());
    }
}