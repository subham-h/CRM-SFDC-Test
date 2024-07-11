/*
*Version  Date         Owner                                    RQ#           Description
********************************************************************************************************************************************
*1.0      19/06/2017   meghana.gupta@ust-global.com             #RQ-005483    Implementing CBO architecture and code optimization
*/
public class UserUtilities{
    
    /*This Method gives the Map of Cluster and Corresponding Region*/
    public static Map<String, String> getClusterRegionMap(){
        
        Map<String, String> clusterRegionMap = new Map<String, String>();//Map to store the Child BDA and it's Parent BDA
        for( Parent_BDA__c bda : [ SELECT Child_BDA__r.Name, Parent_BDA__r.Name 
                                    FROM Parent_BDA__c  WHERE Parent_BDA__c != null AND Child_BDA__c != null ]){
            
                clusterRegionMap.put(bda .Child_BDA__r.Name, bda.Parent_BDA__r.Name);
        }
        clusterRegionMap.put('GSC', Label.Cluster_GSC_Region);
        clusterRegionMap.put('Centre Function', Label.Cluster_Centre_Function_Region);
        return clusterRegionMap;
    }
    
    /* This method returns the Map of BDA Name and corresponding BDA Id*/
    public static Map<String, Id> getBdaMap (List<String> clusterList ){
        
        Map<String, Id> bdaMap = new Map<String, Id>();
        for (BDA__c bda : [SELECT Id, Name FROM BDA__c WHERE Type__c = 'Cluster' AND Active__c = True AND Name in :clusterList ]){
   
            bdaMap.put( bda.Name, bda.ID);
        }        
        return bdaMap;
    }
    
    /*Gets the map of User Id and User Cluster for a set of User Ids*/
    public static Map<Id, User_Cluster__c> getUserClusterMap (Set <Id> userSet){
        
        Map<Id, User_Cluster__c> userClusterMap = new Map<Id, User_Cluster__c>();
        for( User_Cluster__c ucRec : [ SELECT Id, BDA__c, User__c FROM User_Cluster__c WHERE User__c IN :userSet ]){
            
            userClusterMap.put( ucRec.User__c, ucRec);            
        }        
        return userClusterMap;        
    }
    
    public static void manageUserCluster ( List<User> newList ){        
        
        List <User_Cluster__c> ucUpdateList = new List <User_Cluster__c> ();
        Map<Id, Id> userClusterCreateMap = new Map<Id, Id> ();
        List<String> clusterList = new List<String>();
        
        Set<Id> userIdSet = new Set<Id>();
        for ( User usr : newList){
            userIdSet.add( usr.Id );
            clusterList.add ( usr.Cluster__c );
        }
        
        Map<Id, User_Cluster__c> userClusterMap = getUserClusterMap( userIdSet );   

        Map <String, Id> bdaMap = getBdaMap(clusterList);
        for( User usrRec : newList ){
            
            if( userClusterMap.get(usrRec.Id) != null){
                
                userClusterMap.get(usrRec.Id).BDA__c = bdaMap.get( usrRec.Cluster__c );
                ucUpdateList.add(userClusterMap.get(usrRec.Id));//Update the user cluster if existing.
            
            } else {
            
                userClusterCreateMap.put( usrRec.Id, bdaMap.get( usrRec.Cluster__c ));              
            }
        }
    
        if (!ucUpdateList.isEmpty())
            UserTriggerUtility.manageDML(ucUpdateList,'Update');//Method call to update the existing User Clusters.
        
        if (!userClusterCreateMap.isEmpty())
            UserTriggerUtility.createUserCluster(userClusterCreateMap);//Method(@future) call to create new user clusters.
    
    }   
}