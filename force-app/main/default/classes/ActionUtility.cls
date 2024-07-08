/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------  -----------------       -----------
* 1.0      SFSE-7819   16-11-2022   Bharti.Rana@maersk     Logic to validate that only internal stakeholder can be the owner of the action
  2.0      SFSE-12249  24-08-2023   Anjali                 Added null check for Internal Stakeholder Maersk User Id in Validation2ActionOwner method
*/

 

 

public class ActionUtility {

    public static void Validation2ActionOwner(List<Action__c> actlist){

        set<Id> ownerIds = new set<Id>();
        Set<Id> accountPlanIds = new Set<Id>();
        Map<Id,set<string>> mapOfstakeHolders =new Map<Id,set<string>>();

        for(Action__c act : actlist ){
            accountPlanIds.add(act.Account_Plan__c);
            ownerIds.add(act.OwnerId);
        }

        Map<Id,User> mapOfUserRecs =new map<Id,User>([select id,Maersk_User_Id__c from User where id =: OwnerIds]);
        Map<Id,Business_Plan__c> mapOfAccountPlans = new map<Id,Business_Plan__c>([select Id, OwnerId from Business_Plan__c where Id =: accountPlanIds]);

        List<Stakeholder__c> lststakeholder = [Select Internal_Stakeholder__r.Unique_User_ID__c, Internal_Stakeholder__r.id, Business_Plan__r.OwnerId, Business_Plan__c from Stakeholder__c where Business_Plan__c =: accountPlanIds and RecordType.Name = 'Internal'];
        for(Stakeholder__c stk : lststakeholder){
            if (stk.Internal_Stakeholder__r.Unique_User_ID__c != null) {
                if(mapOfstakeHolders.containsKey(stk.Business_Plan__c)){
                    mapOfstakeHolders.get(stk.Business_Plan__c).add(stk.Internal_Stakeholder__r.Unique_User_ID__c.tolowercase());
                } else{
                    mapOfstakeHolders.put(stk.Business_Plan__c, new Set<String>{stk.Internal_Stakeholder__r.Unique_User_ID__c.tolowercase()});
                }
            }
        }

        if(!mapOfUserRecs.isEmpty() && !mapOfAccountPlans.isEmpty()) {
            for(Action__c acc : actlist) {
                if(!mapOfstakeHolders.containskey(acc.Account_Plan__c ) && mapOfAccountPlans.get(acc.Account_Plan__c).OwnerId != acc.OwnerId ){
                    acc.addError(System.Label.ErrorMsgForActionOwner);
                } else {
                    Set<String> setlst = mapOfstakeHolders.get(acc.Account_Plan__c);
                    if(setlst!= null){
                        if(mapOfUserRecs.containskey(acc.OwnerId) && mapOfAccountPlans.containskey(acc.Account_Plan__c )){          
                            if(!setlst.contains(mapOfUserRecs.get(acc.OwnerId).Maersk_User_Id__c.tolowercase()) && mapOfAccountPlans.get(acc.Account_Plan__c).OwnerId != acc.OwnerId){
                                acc.addError(System.Label.ErrorMsgForActionOwner);
                            }
                        }
                    }
                }
            }
        }
    }

}