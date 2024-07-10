/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		07-Aug-2023		Vazid@UST				SFSE-12021 : Apex class for LoopioVFGetSessionId to get the API Session Id
*/
public class LoopioAPIParametersCtrl {
    @AuraEnabled
    public static List<String> getAPISessionId(){
        PageReference apiPage = Page.LoopioVFGetSessionId;
        List<String> apiList = getAPIVarFromVF(apiPage);
        return apiList;
    }
    public static List<String> getAPIVarFromVF(PageReference vfPage){
        List<String> apiList = new List<String>();
        String content = '';
        if(Test.isRunningTest()) { 
            content = 'Start_of_SessionId00DEnd_of_SessionId Start_of_URLhttps://End_of_URL';
        } else {
            content=vfPage.getContent().toString();
        }
        
        Integer s=content.indexOf('Start_of_SessionId')+'Start_of_SessionId'.length(),
            e=content.indexOf('End_of_SessionId');
        system.debug('s DEBUG###'+s);
        apiList.add(content.substring(s,e));
        s=content.indexOf('Start_of_URL')+'Start_of_URL'.length();
        e=content.indexOf('End_of_URL');
        
        apiList.add(content.substring(s,e));
        return apiList;
    }
}