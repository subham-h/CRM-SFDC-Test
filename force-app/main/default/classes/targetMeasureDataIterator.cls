public with sharing class targetMeasureDataIterator implements Iterator<Target_Item__c> {
    private List<Target_Item__c> lsttargetMeasures;
    private Integer currentIndex;
    public targetMeasureDataIterator(List<Target_Item__c> lstTIMs) {
        system.debug('@@@@ ' + lstTIMs.size());
        this.lsttargetMeasures = lstTIMs;
        this.currentIndex = 0;
    }
    public boolean hasNext(){ 
        return currentIndex < lsttargetMeasures.size();
    }
    public Target_Item__c next(){
        if(hasNext()) {
            return lsttargetMeasures[currentIndex++];
        } else {
            throw new NoSuchElementException('Iterator has no more elements.');
        }
    }  
}