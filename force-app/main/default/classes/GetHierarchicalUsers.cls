/* 
* Story               Owner            Description
SFSE-13419			   Vinay			Calculate Target for Hierachial Users reporting for a given SIP Participant.
*/
public class GetHierarchicalUsers {
   
    public static Map<Id,List<Id>> map_hier;
	public static Set<Id> reportingUserIdsSet;    
    public static  Map<Id,List<Id>> retriveSubordinatesList (Set<Id> UserIds){
        map_hier = new Map<Id,List<Id>>();
        reportingUserIdsSet = new Set<Id>();
        
		List<User> subOrdinatesList = [SELECT Id,Name,ManagerId, 
                                      				 Manager.ManagerId, 
                                      				 Manager.Manager.ManagerId, 
                                      				 Manager.Manager.Manager.ManagerId, 
                                      				 Manager.Manager.Manager.Manager.ManagerId,
                                      				 Manager.Manager.Manager.Manager.Manager.ManagerId FROM User WHERE 
                                      				 ManagerId IN:UserIds OR 
                                                     Manager.ManagerId IN:UserIds OR 
                                                     Manager.Manager.ManagerId IN:UserIds OR 
                                                     Manager.Manager.Manager.ManagerId IN:UserIds OR 
                                                     Manager.Manager.Manager.Manager.ManagerId IN:UserIds OR 
                                                     Manager.Manager.Manager.Manager.Manager.ManagerId IN:UserIds];         
        for(User usr: subOrdinatesList){
            reportingUserIdsSet.add(usr.Id); 
            if(usr.ManagerId!=NULL && UserIds.contains(usr.ManagerId)){
            	map_hier = addUserToMap(usr.ManagerId, usr.Id,map_hier);}
            if(usr.Manager.ManagerId!=NULL && UserIds.contains(usr.Manager.ManagerId)){
                map_hier = addUserToMap(usr.Manager.ManagerId, usr.Id,map_hier);}
            if(usr.Manager.Manager.ManagerId!=NULL && UserIds.contains(usr.Manager.Manager.ManagerId)){
                map_hier = addUserToMap(usr.Manager.Manager.ManagerId, usr.Id,map_hier);}
            if(usr.Manager.Manager.Manager.ManagerId!=NULL && UserIds.contains(usr.Manager.Manager.Manager.ManagerId)){
            	map_hier = addUserToMap(usr.Manager.Manager.Manager.ManagerId, usr.Id,map_hier);}
            if(usr.Manager.Manager.Manager.Manager.ManagerId!=NULL && UserIds.contains(usr.Manager.Manager.Manager.Manager.ManagerId)){
            	map_hier = addUserToMap(usr.Manager.Manager.Manager.Manager.ManagerId, usr.Id,map_hier);}
            if(usr.Manager.Manager.Manager.Manager.Manager.ManagerId!=NULL && UserIds.contains(usr.Manager.Manager.Manager.Manager.Manager.ManagerId)){
                map_hier = addUserToMap(usr.Manager.Manager.Manager.Manager.Manager.ManagerId, usr.Id,map_hier);}            
        }       
        subOrdinatesList.clear();
        return map_hier;         
    }
    
    public static Map<Id,List<Id>> addUserToMap(Id managerId, Id reporteeId, Map<Id,List<Id>> incomingMap){        
        if(!incomingMap.containsKey(managerId)){
           incomingMap.put(managerId, new List<Id>{});   
       	}
        incomingMap.get(managerId).add(reporteeId);
     return incomingMap;
    }
}