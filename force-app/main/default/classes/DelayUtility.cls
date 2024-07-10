/*
* Author   : Meghna
* Purpose  : Class to invoke delay in ending the chat in certain scenarios.

* Revision Ref Number    Date          Owner                  Description
* -------- ----------    -----------   -------------------    -----------
* 1.0      SC-8111       13-06-2023    Meghna                  Option Yes from the sub menu shouldn't close the chat
*/


public class DelayUtility {
    
        public class BotDelayParameter {
        @InvocableVariable(required=true)
        public Integer delaySeconds;
    }
    public class chatInfo{
        @InvocableVariable(required=true)
        public string isSuccess;
        @InvocableVariable(required=true)
        public string Brand;
    }
    @InvocableMethod(label='Delay Utility')
    public static List<chatInfo> addDelay(List<BotDelayParameter> lstBotInput) {
        List<chatInfo> lstchatInfo = new List<chatInfo>();
        Integer delaySeconds=lstBotInput[0].delaySeconds;
        
String Brand='Maersk Line';
            
            // Call the delayedMethod asynchronously
            //delayedMethod(delaySeconds);
            //
            try {
            // Sleep for the specified number of seconds
            
            
            DateTime futureTime = DateTime.now().addseconds(delaySeconds);
            system.debug('Future Time'+futureTime);
            system.debug('Current Time'+DateTime.now());
            Integer i=0;
            while (DateTime.now() < futureTime) {
           
                // Wait until the specified time has passed
            }
            
            lstchatInfo=getChatInfo('Yes',Brand);
			system.debug('lstchatInfo after assign'+lstchatInfo);
            
        } catch (Exception ex) {
            
            lstchatInfo=getChatInfo(ex.getMessage(),Brand);
            // Handle the exception if necessary
            System.debug('Delay interrupted: ' + ex.getMessage());
        }
        List<List<chatInfo>> lstlstinfo = new List<List<chatInfo>>();
        
        system.debug('lstchatInfo message'+lstchatInfo);
        lstlstinfo.add(lstchatInfo);
        //return lstlstinfo;
        return lstchatInfo;
    }
    
   
   /* public static void delayedMethod(Integer delaySeconds) {
        try {
            // Sleep for the specified number of seconds
            
            
            DateTime futureTime = DateTime.now().addseconds(delaySeconds);
            system.debug('Future Time'+futureTime);
            system.debug('Current Time'+DateTime.now());
            Integer i=0;
            while (DateTime.now() < futureTime) {
           
                // Wait until the specified time has passed
            }
            
             lstchatInfo=getChatInfo('Yes');

            
        } catch (Exception ex) {
            // Handle the exception if necessary
            System.debug('Delay interrupted: ' + ex.getMessage());
        }
        
        return lstchatInfo;
    }*/
    
    // Inner class to hold the parameter structure
        public static List<chatInfo> getChatInfo(string isSuccess,String Brand){
        List<chatInfo> lstchatInfo = new List<chatInfo>();
        chatInfo info = new chatInfo();                  
        info.isSuccess = isSuccess;
        info.Brand=Brand;
        lstchatInfo.add(info);
        return lstchatInfo;
    }
}