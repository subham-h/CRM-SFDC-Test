/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-8141        22/08/2022     Meghana Gupta            Code Created -- Iterable for batch class Batch_Sip_LoadEmpHRData
* 
* ***/
public class sipEmpHrDataIterable implements Iterable<Employee_HR_Data__c>{
    
    public Iterator<Employee_HR_Data__c> iterator(){
        return new sipEmpHrDataIterator(sipWorkdayUtilities.getEmpHrData()); // When batch class initiated, Iterable will fetch data from Workday
   }

}