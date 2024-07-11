/*
Description  : Utility class for CluAP lightning pages

* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          3/11/2017          ramadevi.palaniswamy@ust-global.com          #RE-4898:Wrapper class used in Tender Target Page
* V2.0         11/29/2017          sandhya.sambasivan@ust-global.com            #RQ-007297: Added Toggle button for Next 100 Tender
* v3.0         14-Aug-2019         manjunath.c.holekade@maersk.com              #RQ-011436 - Remove references/logic related to "Customer_Rating__c"
* v4.0         23-Dec-2019         manjunath.c.holekade@maersk.com              #RQ-012367 - Remove references/logic related to "Rate__c" and "Rate_Guidance__c" of OpptyLineItem
*
*/
Public class TenderOLIResponse extends AuraResponse{

     @AuraEnabled public List<wrapperOLI_Rating> tenderOLIList{get;set;}
     
     public TenderOLIResponse(){
     
         tenderOLIList = new List<wrapperOLI_Rating>();
         
     }
     
     public class wrapperOLI_Rating{
             
            @AuraEnabled public OpportunityLineItem optylineItem { get; set; }
            @AuraEnabled public Decimal oldTenderTarget {get; set;}
            @AuraEnabled public Decimal oldTenderFFE {get; set;}
            @AuraEnabled public String oldComments {get; set;}
            @AuraEnabled public String oldTargetStatus {get; set;}
            @AuraEnabled public boolean corrGuidanceExists { get; set; } // make this true if corridor guidance is created and has Corr. Guidance Detail Count > 0
            @AuraEnabled public Integer rowNum{get;set;}
            @AuraEnabled public String oppName{get;set;}
            @AuraEnabled public boolean isTender{get;set;}
                    
            public wrapperOLI_Rating ( OpportunityLineItem recOLI, boolean corrFlag, Integer rowNum ,String strOppName, Boolean isTenderRT){ 
            
                optylineItem = recOLI;
                oldTenderTarget = recOLI.Tender_Target__c;
               // oldTenderFFE = recOLI.Long_term_Potential_FFE__c;
               // oldTargetStatus = recOLI.Target_Status__c;
                oldComments  = recOLI.Comments__c;
                corrGuidanceExists = corrFlag;
                rowNum = rowNum;
                oppName = strOppName;
                isTender = isTenderRT;
               
            }
        }
    }