/*
Description: Post-refresh class. Includes all logic which need to be run after sandbox refresh

* Version       Date            Owner                               Description
******************************************************************************************************************************************************
* v1.0          22-Feb-2019     manjunath.c.holekade@maersk.com       RQ-010022 -> "Batch_InsertGeographyRecords" execute logic
* v2.0          26-Feb-2019     abhinav.ankit@maersk.com              RQ-010163 -> "Batch_EmailMaskingContact" execute logic
* v3.0          26-Feb-2019     abhinav.ankit@maersk.com              RQ-010163 -> "Batch_EmailMaskingLead" execute logic
* v4.0          26-Feb-2019     abhinav.ankit@maersk.com              RQ-010163 -> "Batch_EmailMaskingCase" execute logic
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/
global class PostRefreshClass implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        Database.executeBatch(new Batch_InsertGeographyRecords());
        Database.executeBatch(new Batch_EmailMaskingContact());
        Database.executeBatch(new Batch_EmailMaskingLead());
        Database.executeBatch(new Batch_EmailMaskingCase());
    }
}