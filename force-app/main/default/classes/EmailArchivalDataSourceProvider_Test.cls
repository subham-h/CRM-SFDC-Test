/*
* Author    : Ranjan
* Purpose   : Test class for EmailArchivalDataSourceProvider
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   13-Oct-2022 Ranjan@Maersk            Created. 
* 
*
*/
@isTest(SeeAllData=false)
private class EmailArchivalDataSourceProvider_Test {
    static testMethod void test_syncEmailArchival() {
        Test.setMock(HttpCalloutMock.class, new EmailArchivalDataSourceProviderMock());
        EmailArchivalDataSourceConnection conn =new  EmailArchivalDataSourceConnection(null);
        conn.sync();
        //query
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.tableSelection = new DataSource.TableSelection();
        context.tableSelection.tableSelected = 'emailmessagearchival';
        context.tableSelection.filter = new DataSource.Filter();
        context.tableSelection.filter.columnName = 'subject';
        context.tableSelection.filter.columnValue = 'Re: Shipment Inquiry Details';
        context.tableSelection.columnsSelected=new List<DataSource.ColumnSelection>();
        context.tableSelection.filter.type = DataSource.FilterType.EQUALS;

        EmailArchivalDataSourceConnection aConnObj = new EmailArchivalDataSourceConnection (null);
        DataSource.TableResult tableObj=aConnObj.query(context);
        DataSource.UpsertContext upContextObj = new DataSource.UpsertContext();
        List<Map<String, Object>> rows = tableObj.rows;
        for (Map<String, Object> row : rows){
            row.put('ExternalId', null);
        }
        upContextObj.rows=tableObj.rows;
        upContextObj.tableSelected=context.tableSelection.tableSelected;
        
        EmailArchivalDataSourceConnection upConnObj = new EmailArchivalDataSourceConnection (null);
        upConnObj.upsertRows(upContextObj);
        EmailArchivalDataSourceConnection.getGlobalErrorLogger('SFDC', 'EmailArchivalDataSourceConnection', 'EmailArchivalDataSourceConnection.getData', 'Error', 'Status Code:400', 'Response:Status Code:400');

    }
    static testMethod void test_EmailArchivalDataSourceProvider() {
        EmailArchivalDataSourceProvider dbObj= new EmailArchivalDataSourceProvider();
        dbObj.getAuthenticationCapabilities();
        dbObj.getCapabilities();
        dbObj.getConnection(new DataSource.ConnectionParams());
    }
}