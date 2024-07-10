@isTest
public class ConstantsTest {
    
    @isTest
    public static void testConstants(){
        Assert.areEqual('Omni_Channel_Email_Presence_Statuses', Constants.emailPresenceStatusDevName, 'Omni_Channel_Email_Presence_Statuses');
        Assert.areEqual(Schema.SObjectType.Maersk_Admin_Configuration__c.getRecordTypeInfosByDeveloperName().get('Omni_Nudge').getRecordTypeId(), Constants.Maersk_Admin_Omni_Nudge_RTId, 'rt check');
        Assert.areEqual(false, Constants.stopEmailParentRRFUpdate, 'RRF check false');
        Assert.areEqual(false, Constants.servicePresenceTest, 'servicePresenceTest false');
        Assert.areEqual('MCC', Constants.mcc_brand, 'brand check');
        Assert.areEqual('Domestic', Constants.domestic_direction, 'direction check');
        Assert.areEqual('Philippines', Constants.philippines_country, 'country check');
    }

}