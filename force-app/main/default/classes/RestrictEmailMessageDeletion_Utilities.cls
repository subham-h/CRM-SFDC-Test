/*
 RestrictEmailMessageDeletion Utility class using Single Trigger Framework.
** Version    Date            Owner                                               RQ#                 Description
*********************************************************************************************************************************  
* 1.0        21/10/2015       Prashanth D S                                     Code created
*/

public class RestrictEmailMessageDeletion_Utilities
{
  public static void DeleteRestrictionMethods(List<EmailMessage> EMList)
  {
    Id LoggedInUserId = UserInfo.getUserId();
    Validation_Rules_Bypass__c  val = Validation_Rules_Bypass__c.getInstance(LoggedInUserId);
    for(EmailMessage em : EMList)
    {
      if(val.Active__c==FALSE)
      {
        em.adderror(Label.Error_message_for_Restricting_EmailMessage_Deletion);
      }
    }
  }
}