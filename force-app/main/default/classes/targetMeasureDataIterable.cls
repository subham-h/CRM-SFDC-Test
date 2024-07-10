public with sharing class targetMeasureDataIterable implements Iterable<Target_Item__c>{
    public Id targetIds;
    public string wherequery;
    //public String strMeasureType;
    public String sipEligibleVal;
   // public String growthtypeVal;
    public String targetCusPortQuery;
   // public Map<String, String> mapOfMonthTovalue = new Map<String, String>();
   // public Map<String, String> previousActualMap = new Map<String, String>();7
  //  public String partytype= '';
    //public Boolean blncreditcheck = false;
    public targetMeasureDataIterable(string targetRecId, String targetCusPortQuery, String whereQuery, Integer offset, integer noOfRows, String strOrderBy, String strOrderDirection, string sipEligible){
        this.targetIds = targetRecId;
       // this.strMeasureType = strMeasureType;
       // this.mapOfMonthTovalue = mapOfMonthTovalue;
       // this.partytype = partytype;
       // this.blncreditcheck = creditcheck;
        //this.previousActualMap = previousActualMap;
        this.wherequery = whereQuery;
        this.sipEligibleVal = sipEligible;
        //this.growthtypeVal = growthtypeVal;
        this.targetCusPortQuery = targetCusPortQuery;
    }
    public Iterator<Target_Item__c> iterator(){
        if(!Test.isRunningTest()) {
            return new targetMeasureDataIterator(TargetPlanningCntrl.getTargetItemRecords(targetIds, targetCusPortQuery, wherequery, 0, 0, 'Name','ASC', sipEligibleVal));
        }else{
            List<Target_Item__c> lstTim = [Select Id, Name,Target__c, Account__c, Brand__c, Account_Represents_Concern__c, Account_Name__c, Account_Customer_Code__c, Represent_Concern_Account__c, Sales_Channel__c, Attractiveness__c, Vertical__c
                                          FROM Target_Item__c];
            return new targetMeasureDataIterator(lstTim);
        }
   }
}