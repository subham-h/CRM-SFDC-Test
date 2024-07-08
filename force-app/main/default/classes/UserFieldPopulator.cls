/*
*Version  Date         Owner                                    RQ#           Description
********************************************************************************************************************************************
*1.0      19/06/2017   meghana.gupta@ust-global.com             #RQ-005483    Implementing CBO architecture and code optimization
*2.0      25/09/2017   Nisha.arjunan@ust-global.com             #RQ-005636    Update references of GlobalErrorLogger
*3.0      15/01/2019   meghana.gupta@ust-global.com             #RQ-009884    To handle user exception when user is created with no last name
*4.0      30-Jan-2020  manjunath@maersk                          RQ-012371    Removed references of deprecated field, User.Associated_Cluster_Count__c

*/
public class UserFieldPopulator {
    
    public static void populateUserRegion ( list<User> userList ){
        
        try{            
            Map<String, String> clusterRegionMap = UserUtilities.getClusterRegionMap(); // getting all 27 cluster records --- should we get list of clusters to fetch required records only?
            
            for( User userRec : userList){    
                
                userRec.Region__c = clusterRegionMap.get(userRec.Cluster__c) != null ? clusterRegionMap.get(userRec.Cluster__c) :  '' ;
            }   
            
        } catch(Exception e){     
            ErrorLogger.writeErrors( 'SFDC', 'User', 'UserFieldPopulator.populateUserRegion', new list<Exception>{e}); // #RQ-005636     
        }       
    }
    
    /*Method to convert the Fed Id to lower case*/
    public static void setFedIdToLowerCase ( List<User> newList ){
        
        for( User userRec : newList ){        
            userRec.FederationIdentifier = userRec.FederationIdentifier.toLowerCase();
        }
    }
    
    /*Method to convert the user name to init caps case*/
    public static void setUserNameCase ( List<User> newList ){
        
        for( User userRec : newList ){        
            
            if (userRec.FirstName != null){
                List<String> firstNameList = userRec.FirstName.split(' ');
                String strFirstName = '';
                for ( String strName : firstNameList){
                    
                    strName = strName.capitalize();
                    if (strFirstName == '')
                        strFirstName = strName;
                    else    
                        strFirstName = strFirstName + ' ' + strName;
                }
                userRec.FirstName = strFirstName;
            }
            
            // #RQ-009884 - check if last name is null then show error
            List<String> lastNameList = new List<String>();
            if (userRec.LastName != null)
                lastNameList = userRec.LastName.split(' ');
            else
                userRec.addError('You must enter Last Name');
                
            String strlastName = '';
            for ( String strName : lastNameList){
                
                strName = strName.capitalize();
                if (strlastName == '')
                    strlastName = strName;
                else    
                    strlastName = strlastName + ' ' + strName;
            }           
            userRec.LastName = strlastName;         
        }
    }
    
    /*Method to update the Last Active Date
*This method also sets the Associated Cluster Count to '0' when user is made inactive.
*/
    public static void setLastActiveDate ( List<User> newList){
        
        for( User userRec : newList ){
            
            // Capture Date/Time when User is InActivated
            if( userRec.IsActive == FALSE ){
                userRec.Last_Active_On__c = System.Now();
            } else {
                userRec.Last_Active_On__c = null;
            }
        }
    }
    
    /*Method to set Synced flag*/
    public static void synchedFlagUpdate ( List<User> newList ){
        
        for( User userRec : newList ){        
            userRec.Synched__c = false;
        }
    }
    
    public static void mirrorUser ( List<User> newList ){
       Set<String> mirrorAccessList = new Set<String>();

        for( User userRec : newList ){        
            mirrorAccessList.add( userRec.Mirrored_Access__c );
        }
        
           List<User_Fields_To_Clone__mdt> fieldsToClone = [Select label from User_Fields_To_Clone__mdt];
        String fieldsNames = '';
        for (User_Fields_To_Clone__mdt field : fieldsToClone) {
            fieldsNames += ','+ field.label;
        }
        
        system.debug('--->'+fieldsNames);
        
        List<User> listUsersToClone = Database.query('SELECT Id, Maersk_User_Id__c'+fieldsNames+' FROM User  Where Maersk_User_Id__c in: mirrorAccessList');
        system.debug('lstc'+listUsersToClone);
        
        Map<String, User> mapUsersToClone = new Map<String, User>();
        for(User us : listUsersToClone){
            mapUsersToClone.put(us.Maersk_User_Id__c, us);
        }        

        //Map<User,List<String>> mapFieldstoUpdate = new Map<User,List<String>>();
        
        for(User userRec: newList){
            if(mapUsersToClone.containsKey(userRec.Mirrored_Access__c)){
                User userToClone = mapUsersToClone.get(userRec.Mirrored_Access__c);
                     
                for(User_Fields_To_Clone__mdt field : fieldsToClone){
                    userRec.put(field.label, userToClone.get(field.label));
               
                }
            }
        }
    }
}