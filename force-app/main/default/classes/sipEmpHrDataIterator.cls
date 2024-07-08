/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-8141        22/08/2022     Meghana Gupta            Code Created - Iterator for batch class Batch_Sip_LoadEmpHRData
* 
* ***/

public class sipEmpHrDataIterator implements Iterator<Employee_HR_Data__c>{
	
    private List<Employee_HR_Data__c> lstEmployee;
    private Integer currentIndex;
    
    public sipEmpHrDataIterator(List<Employee_HR_Data__c> lstEmps){
        this.lstEmployee = lstEmps;
        this.currentIndex = 0;
    }
    
    public boolean hasNext(){ 
        return currentIndex < lstEmployee.size() - 1;
    }    
     
    public Employee_HR_Data__c next(){
        if(hasNext()) {
            currentIndex++;
            return lstEmployee[currentIndex];
        } else {
            throw new NoSuchElementException();
        }
    }
}