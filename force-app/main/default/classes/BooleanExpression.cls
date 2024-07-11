/*      
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0      SFSE-14324  20-03-2024     ramadevi.p@maersk.com        class to resolve the boolean expression given in String
*/
public class BooleanExpression {
    static Map<String, String> logicTypes = new Map<String, String>();
    static Map<String, Map<String, String>> expressionLogic = new Map<String, Map<String, String>>();
    
    /**
    * Evaluate a boolean expreassion 
    * 
    */
    public static Boolean eval(String expression) {        
        // If expression contains all TRUE or FALSE
        if(expression.containsNone('FALSE')) { return TRUE; }        
        if(expression.containsNone('TRUE')) { return FALSE; }

        fillLogic();

        return Boolean.valueOf(evaluateExpression(expression.toUpperCase()));
    }
    
 /* public static Boolean eval(String expression, List<boolean> values) {
    expression = substituteValues(expression.toUpperCase(), values);
     
    // If expression contains all true or false
    if(expression.containsNone('false')) { return true; }        
    if(expression.containsNone('true')) { return false; }
     
    return Boolean.valueOf(evaluateExpression(expression));
}   


public static String substituteValues(String expression, List<boolean> values) {
    String[] arguments = expression.split(' ');
    for(String arg : arguments) {
        try {
            Integer index = Integer.valueOf(arg.replaceAll('[^0-9]', ''));
            expression = expression.replaceAll(String.valueOf(index), String.valueOf(values[index - 1]));    
        } catch(Exception e) {}
    }
    return expression;
}
*/
    /**
    * Evaluate the expression
    * 
    */
    public static String evaluateExpression(String expression) {   
   
        for(String logicType : logicTypes.keySet()) {
            if(expression.contains(logicType)) {
                expression = simplifyExpression(expression, logicTypes.get(logicType));
            }
        }
        
        if(expression.contains('AND') || expression.contains('OR') || expression.contains('(')) {
            expression = evaluateExpression(expression);
        }
        
        return expression;
    }
    
    /**
     * Simplify the expression
     * 
     */
    public static string simplifyExpression(String expression, String LogicType){
        Map<String, String> Logic = expressionLogic.get(LogicType);
       
        
        for(String key : Logic.keySet()) {
            expression = expression.replace(key, Logic.get(key));
           
     }
        
        return expression;
    } 
    
    /**
    * Fill AND and OR Logic
    * 
    */
    public static void fillLogic() {
        Map<String, String> ANDLogic = new Map<String, String>();
        Map<String, String> ORLogic = new Map<String, String>();
        Map<String, String> BRACELogic = new Map<String, String>();
        
        logicTypes.put('AND','AND');
        logicTypes.put('OR','OR');
        logicTypes.put('(','BRACES');
        
        // AND Logic
        ANDLogic.put('TRUE AND TRUE', 'TRUE');
        ANDLogic.put('TRUE AND FALSE', 'FALSE');
        ANDLogic.put('FALSE AND TRUE', 'FALSE');
        ANDLogic.put('FALSE AND FALSE', 'FALSE');
        expressionLogic.put('AND',ANDLogic);
        
        // OR Logic
        ORLogic.put('TRUE OR TRUE', 'TRUE');
        ORLogic.put('TRUE OR FALSE', 'TRUE');
        ORLogic.put('FALSE OR TRUE', 'TRUE');
        ORLogic.put('FALSE OR FALSE', 'FALSE');
        expressionLogic.put('OR',ORLogic);
        
        // Braces Logic
        BRACELogic.put('(TRUE OR TRUE','TRUE');
        BRACELogic.put('(FALSE OR FALSE','FALSE');
        BRACELogic.put('(TRUE AND TRUE','TRUE');
        BRACELogic.put('(FALSE AND FALSE','FALSE');
        BRACELogic.put('(TRUE OR FALSE','TRUE');
        BRACELogic.put('(FALSE OR TRUE','TRUE');
        BRACELogic.put('(TRUE AND FALSE','FALSE');
        BRACELogic.put('(TRUE AND FALSE','FALSE');
        
        BRACELogic.put('(TRUE OR TRUE)','TRUE');
        BRACELogic.put('(FALSE OR FALSE)','FALSE');
        BRACELogic.put('(TRUE AND TRUE)','TRUE');
        BRACELogic.put('(FALSE AND FALSE)','FALSE');
        BRACELogic.put('(TRUE OR FALSE)','TRUE');
        BRACELogic.put('(FALSE OR TRUE)','TRUE');
        BRACELogic.put('(TRUE AND FALSE)','FALSE');
        BRACELogic.put('(TRUE AND FALSE)','FALSE');
        
        
        BRACELogic.put('TRUE OR TRUE)','TRUE');
        BRACELogic.put('FALSE OR FALSE)','FALSE');
        BRACELogic.put('TRUE AND TRUE)','TRUE');
        BRACELogic.put('FALSE AND FALSE)','FALSE');
        BRACELogic.put('TRUE OR FALSE)','TRUE');
        BRACELogic.put('FALSE OR TRUE)','TRUE');
        BRACELogic.put('TRUE AND FALSE)','FALSE');
        BRACELogic.put('TRUE AND FALSE)','FALSE');
        
        BRACELogic.put('(TRUE)','TRUE');
        BRACELogic.put('(FALSE)','FALSE');
        
        expressionLogic.put('BRACES',BRACELogic);
    }
}