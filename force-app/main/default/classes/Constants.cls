public class Constants {
    
    public static String emailPresenceStatusDevName = 'Omni_Channel_Email_Presence_Statuses';
    public static Id Maersk_Admin_Omni_Nudge_RTId = Schema.SObjectType.Maersk_Admin_Configuration__c.getRecordTypeInfosByDeveloperName().get('Omni_Nudge').getRecordTypeId();

    public static Boolean stopEmailParentRRFUpdate = false;
    public static Boolean servicePresenceTest = false;
    public static String mcc_brand = 'MCC';
    public static String domestic_direction = 'Domestic';
    public static String philippines_country = 'Philippines';

}