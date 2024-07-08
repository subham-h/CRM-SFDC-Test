/**
 * Description  : Invocable class for making external webservice callout to GCSS for getting arrival notice details through Bot. 
 *
 * version    Ref Number     Date                Owner                               Description
 *******************************************************************************************************************
 * 1.0        SC-4094        13/12/2021          Richa@maersk.com                    Created getArrivalNotice Invocable method which is called from Einstein Chatbot. 
 * 2.0        SC-4457        11-04-2022          Thippeswamy@UST                     Apex Exception handling for bot method getArrivalNotice
 * 3.0        SPI-100        07-06-2022          Ronnie@SF                           Removed brand hardcodings 
 *-------------------------------------------------------------------------------------------------------------------
 */
global with sharing class ArrivalNoticeController {
    
    public class botInput {
        @InvocableVariable(required=true)
        public String shipmentNumber;
        @InvocableVariable(required=true)        
        public String brand;
        @InvocableVariable(required=true)
        public String scvCode;
    }
    
    public class arrivalNoticeInfo {
        @InvocableVariable(required=true)
        public String arrivalRoleAvailable; 
        @InvocableVariable(required=true)
        public String arrivalTaskStatus;  
        @InvocableVariable(required=true)
        public String arrivalNoticeError;        
    }
    
    //SC-4094: Invoked from chatbot to get party and task details.
    @InvocableMethod(label='getArrivalNotice')
    public static List<arrivalNoticeInfo> getArrivalNotice(List<botInput> lstBotInput) {
        List<arrivalNoticeInfo> lstArrivalNoticeInfo = new List<arrivalNoticeInfo>();       
        Boolean isException = false;
        Boolean isParty = false;
        String partyRes;
        String taskRes;
        Boolean isDuplicateTask = false;
        try {
            String shipmentNumber = lstBotInput[0].shipmentNumber;
            String scvCode = lstBotInput[0].scvCode;
            String operator = BrandUtilities.getBrandOperatorCode(lstBotInput[0].brand);
            operator = operator.toUpperCase();
            system.debug('***shipmentNumber'+shipmentNumber);
            
            Map<String,String> mapTaskStatus = new Map<String,String>();
            Map<String,Object> mapResponse = new Map<String,Object>();
            Map<String,Object> mapTaskResponse = new Map<String,Object>();
            try {  
                partyRes = (String)TransportDocumentServiceController.getTPDocDetails(shipmentNumber,operator);           
                if (partyRes == 'Read timed out') {
                    lstArrivalNoticeInfo = getArrivalNoticeInfo(null,null,Label.ReadTimedOut);
                    isException = true;   
                } else if (partyRes.containsIgnoreCase('debugMessage')) {
                    mapResponse = (Map<String,Object>)JSON.deserializeUntyped(partyRes);   
                    lstArrivalNoticeInfo = getArrivalNoticeInfo(null,null,(String)mapResponse.get('debugMessage'));
                    isException = true; 
                }
            } catch(Exception ex) {           
                lstArrivalNoticeInfo = getArrivalNoticeInfo(null,null,ex.getMessage());
                isException = true;
            }
            if (!isException) {
                mapResponse = (Map<String,Object>)JSON.deserializeUntyped(partyRes);
                List<Object> lstParties = (List<Object>) mapResponse.get('parties');           
                Set<String>setParties = new Set<String>();
                if (lstParties.size()>0) {
                    for (Object obj: lstParties) {
                        Map<String,Object> pData = (Map<String,Object>)obj;                                             
                        setParties.add((String)pData.get('partyRoleTypeName'));
                    }
                    for (Object obj: lstParties) {
                        Map<String,Object> pData = (Map<String,Object>)obj;
                        String partyName = (String)pData.get('partyRoleTypeName');                       
                        if (partyName.equalsIgnoreCase(Label.GCSSFirstNotifyParty) || partyName.equalsIgnoreCase(Label.GCSSAdditionalNotifyParty) || partyName.equalsIgnoreCase(Label.GCSSLawfulBLHolderParty) || partyName.equalsIgnoreCase(Label.GCSSSwitchedConsigneeParty)) {
                            if (scvCode == (String)pData.get('scvCustomerCode')) {
                                isParty = true;
                                break; 
                            }
                        } else if (!setParties.contains(Label.GCSSSwitchedConsigneeParty) && partyName.equalsIgnoreCase(Label.GCSSDocConsigneeParty)) {
                            if (scvCode == (String)pData.get('scvCustomerCode')) {
                                isParty = true;
                                break; 
                            }
                        } else if (!setParties.contains(Label.GCSSDocConsigneeParty) && partyName.equalsIgnoreCase(Label.GCSSConsigneeParty)) {
                            if(scvCode == (String)pData.get('scvCustomerCode')) {
                                isParty = true;
                                break; 
                            }
                        }                        
                    }
                }
                if (isParty) {
                    try {
                        taskRes = (String)GcssTasksController.getGcssTasksDetails(shipmentNumber,operator);                    
                        if (taskRes == 'Read timed out') {
                            lstArrivalNoticeInfo = getArrivalNoticeInfo(null,null,Label.ReadTimedOut);
                            isException = true;   
                        } else if(taskRes.containsIgnoreCase('debugMessage')) {
                            mapTaskResponse = (Map<String,Object>)JSON.deserializeUntyped(taskRes);
                            lstArrivalNoticeInfo = getArrivalNoticeInfo(null,null,(String)mapTaskResponse.get('debugMessage'));
                            isException = true; 
                        }
                    } catch(Exception ex) { 
                        lstArrivalNoticeInfo = getArrivalNoticeInfo(null,null,ex.getMessage());
                        isException = true;
                    }
                    if (!isException) {
                        mapTaskResponse = (Map<String,Object>)JSON.deserializeUntyped(taskRes);
                        List<Object> lstTasks = (List<Object>) mapTaskResponse.get('tasks');                    
                        if (lstTasks.size()>0) {
                            for (Object obj1: lstTasks) {
                                Map<String,Object> tData = (Map<String,Object>)obj1;
                                if (tData.get('taskName') == Label.GCSSArrivalNoticeTask) {
                                    if (!mapTaskStatus.containsKey((String)tData.get('taskName'))) {
                                        mapTaskStatus.put((String)tData.get('taskName'),(String)tData.get('status'));   
                                    } else {
                                        isDuplicateTask = true;
                                        break;
                                    }
                                }
                            }
                            if (!isDuplicateTask && mapTaskStatus.containsKey(Label.GCSSArrivalNoticeTask) && mapTaskStatus.get(Label.GCSSArrivalNoticeTask) != 'Closed') {
                                lstArrivalNoticeInfo = getArrivalNoticeInfo('Not Issued','Yes',null);   
                            } else if (!isDuplicateTask && mapTaskStatus.containsKey(Label.GCSSArrivalNoticeTask) && mapTaskStatus.get(Label.GCSSArrivalNoticeTask) == 'Closed') {
                                lstArrivalNoticeInfo = getArrivalNoticeInfo('Issued','Yes',null);     
                            } else {
                                lstArrivalNoticeInfo = getArrivalNoticeInfo(Label.TransferToAgent,'Yes',null);
                            }
                        } else {
                            lstArrivalNoticeInfo = getArrivalNoticeInfo(Label.TransferToAgent,'Yes',null); 
                        }
                    }
                }            
            }
        } catch(Exception ex) {
            lstArrivalNoticeInfo = getArrivalNoticeInfo(null,null,'System Error/Unhandled Error');
            isException = true; 
        }
        System.debug('***lstArrivalNoticeInfo'+JSON.serialize(lstArrivalNoticeInfo));
        return lstArrivalNoticeInfo; 
    }
    
    public static List<arrivalNoticeInfo> getArrivalNoticeInfo(String status, String isParty, String error) {
        List<arrivalNoticeInfo> lstArrivalNotice = new List<arrivalNoticeInfo>();
        arrivalNoticeInfo notice = new arrivalNoticeInfo();                 
        notice.arrivalRoleAvailable = isParty;
        notice.arrivalTaskStatus = status;
        notice.arrivalNoticeError = error;
        lstArrivalNotice.add(notice);
        return lstArrivalNotice;
    }
}