/*
* Author    : Richa
* Purpose   : Ocean Plus Line Item LWC component controller
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8872     22-06-2023  Richa@Maersk            Query and update OPLI items
* 2.0       SC-9147     29-09-2023  Richa@Maersk            Mass update of selected OPL and OPLIs
* 3.0       SC-9294     18-10-2023  Richa@Maersk            Refresh parent OPL status valueon Mass update screen after load
*/

public class OceanPlusLineItemController {
    @AuraEnabled(cacheable=true)
    public static List<Ocean_Plus_Line_Item__c> getOceanPlusLineItems(String oplId) {
        return [
            SELECT  Id, Name,Ocean_Plus_Lead__c,Status__c, Product__c,No_of_FFEs_sold__c, Reasons_for_In_progress__c, Reasons_for_Selling__c, Reasons_for_Not_Selling__c,Reasons_for_Lead_creation__c,Other_Reason__c,Additional_Comments__c,Partial_Booking__c,Ocean_Plus_Lead__r.Booked_FFE__c
            FROM Ocean_Plus_Line_Item__c WHERE Ocean_Plus_Lead__c = :oplId];
    }
    
    @AuraEnabled
    public static void updateOceanPlusLineItems(List<Ocean_Plus_Line_Item__c> lstOPLI) {
        try{
            if(lstOPLI != null && lstOPLI.size()>0){
                update lstOPLI;
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        } 
    }
    
    @AuraEnabled
    public static String massUpdateOPLsAndOPLIs(List<String> lstOPLIds, String ownerId,String status,String products, List<Ocean_Plus_Line_Item__c> lstOPLIs) {
        List<Ocean_Plus_Lead__c> lstUpdateOPL = new List<Ocean_Plus_Lead__c>();
        List<Ocean_Plus_Line_Item__c> lstUpdateOPLI = new List<Ocean_Plus_Line_Item__c>();
        Set<String> setOPLIStatus = new Set<String>();
        String finalStatus;
        try{
            if(lstOPLIds.size() >0 && lstOPLIds != null){
                for(Ocean_Plus_Lead__c opl:[Select Id, OwnerId,Status__c,Products_Pitched__c,Booked_FFE__c from Ocean_Plus_Lead__c where Id IN:lstOPLIds]){
                    if(!String.isEmpty(ownerId)){
                        opl.OwnerId = ownerId;
                    }
                    if(!String.isEmpty(status)){             
                        opl.Status__c = status;
                    }               
                    opl.Products_Pitched__c = products;
                    lstUpdateOPL.add(opl);                
                }
                if(lstUpdateOPL != null && lstUpdateOPL.size() >0){
                    update lstUpdateOPL;
                }
                List<Ocean_Plus_Line_Item__c> lstNewOPLIs = [SELECT  Id, Name,Ocean_Plus_Lead__c,Status__c, Product__c,No_of_FFEs_sold__c, Reasons_for_In_progress__c, Reasons_for_Selling__c, Reasons_for_Not_Selling__c,Reasons_for_Lead_creation__c,Other_Reason__c,Additional_Comments__c,Partial_Booking__c,Ocean_Plus_Lead__r.Booked_FFE__c
                                                             FROM Ocean_Plus_Line_Item__c WHERE Ocean_Plus_Lead__c IN: lstOPLIds];
                
                if(lstNewOPLIs != null && lstOPLIs != null && lstOPLIs.size() >0 && lstNewOPLIs.size()>0){
                    for(Ocean_Plus_Line_Item__c opli:lstOPLIs){                   
                        for(Ocean_Plus_Line_Item__c newOPLI:lstNewOPLIs){
                            if(opli.Product__c == newOPLI.Product__c ){  
                                setOPLIStatus.add(opli.Status__c);
                                newOPLI.Status__c = opli.Status__c;
                                newOPLI.Reasons_for_In_progress__c = opli.Reasons_for_In_progress__c;
                                newOPLI.Reasons_for_Not_Selling__c = opli.Reasons_for_Not_Selling__c;
                                newOPLI.Reasons_for_Selling__c = opli.Reasons_for_Selling__c;
                                newOPLI.Reasons_for_Lead_creation__c = opli.Reasons_for_Lead_creation__c;
                                newOPLI.Other_Reason__c = opli.Other_Reason__c;
                                newOPLI.No_of_FFEs_sold__c = opli.No_of_FFEs_sold__c;
                                newOPLI.Partial_Booking__c = opli.Partial_Booking__c;
                                newOPLI.Additional_Comments__c = opli.Additional_Comments__c;
                                lstUpdateOPLI.add(newOPLI);
                            }
                        }
                    }
                }
                if(lstUpdateOPLI.size() >0 && lstUpdateOPLI != null){
                    update lstUpdateOPLI;
                }
                if(setOPLIStatus.contains('New') || setOPLIStatus.contains('In Progress')){
                    finalStatus = 'In Progress'; 
                }else if(setOPLIStatus.contains('Sold')){
                    finalStatus = 'Sold';  
                }else if(setOPLIStatus.contains('Lead for Sales')){
                    finalStatus= 'Lead for Sales'; 
                }else if(setOPLIStatus.contains('Not Sold')){
                    finalStatus = 'Not Sold';   
                }
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        } 
        return finalStatus;
    }
    
}