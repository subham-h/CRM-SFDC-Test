public class AzureRequestClass {
    

    
    @invocableMethod
    public static void AzureDisableUsersByEmail(List<User> userList){
        
        system.debug('userList'+userList);
        for(user u:userList){
            AzureRequestCalloutCls.AzureDisableUsersByEmail(u.Email);
        }
     
    }
    
}