public class CheckTriggerRecursive {
	private static boolean blnRun = true;
    public static boolean runOnce(){
        if(blnRun){
            blnRun=false;
            return true;
        }else{
            return blnRun;
        }
    }
}