/*
* @Name: PercentageCoverageMapValueSort
* @Description: Comparable class to sort map by value used in Schedule_MyNameSpaceApexTestResult class. 
*
* Version  Date         Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      28/08/2019   sidhartha.mohapatra@maersk.com           	       	   Created Class
*/
public class PercentageCoverageMapValueSort implements Comparable {
 	/*
     * @description className String
     * @return Name 
     */
    public String className;
    
    /*
     * @description decimal value
     * @return decimal 
     */
    public Decimal d;
    
    /*
     * @description constructor
     * @return size 
     */
    public PercentageCoverageMapValueSort(String className, Decimal d) {
        this.className = className;
        this.d = d;
    }
    
    /*
     * @description CompareTo method
     */
    public Integer compareTo(Object other) {
        return Integer.valueof(d-((PercentageCoverageMapValueSort)other).d);
    }
}