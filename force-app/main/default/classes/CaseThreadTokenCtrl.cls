public class CaseThreadTokenCtrl {
    public Id caseIdFromComp{get;set;}
    public string getThreadId(){
        String tempToken='';
        if(caseIdFromComp!=null){
            tempToken= EmailMessages.getFormattedThreadingToken(caseIdFromComp);
        }
        return tempToken;
    }
}