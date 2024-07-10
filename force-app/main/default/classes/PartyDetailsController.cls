/**
* Description  : Invocable class for making external webservice callout to GCSS for getting party and task details through Bot. 
* 
* Version    Ref Number     Date                Owner                               Description
*******************************************************************************************************************
* 1.0        SC-2784        26-07-2021          Richa@maersk.com                    Created getPartyDetails Invocable method which is called from Einstein Chatbot. 
* 2.0        SC-4457        11-04-2022          Thippeswamy@UST                     Apex Exception handling for bot method getPartyDetails 
* 3.0        SPI-100        09-06-2022          Ronnie@SF                           Removed brand hardcoding
*-------------------------------------------------------------------------------------------------------------------
*/
global with sharing class PartyDetailsController {
    
    public class botInput{
        @InvocableVariable(required=true)
        public string shipmentNumber;
        @InvocableVariable(required=true)        
        public string brand;
        @InvocableVariable(required=true)
        public string scvCode;
    }    
    public class partyInfo{
        @InvocableVariable(required=true)
        public string customerRoleAvailable; 
        @InvocableVariable(required=true)
        public string taskStatus;  
        @InvocableVariable(required=true)
        public string partyError;        
    }
    //SC-2784: Invoked from chatbot to get party and task details.
    @InvocableMethod(label='getPartyDetails')
    public static List<partyInfo> getPartyDetails(List<botInput> lstBotInput){ 
        List<partyInfo> lstPartyInfo = new List<partyInfo>();       
        Boolean isException = false;
        Boolean isParty = false;
        String partyRes;
        String taskRes;
        String roleAvailable; 
        Boolean isDuplicateTask = false;
        String errorReceived;
        try
        {
            String shipmentNumber = lstBotInput[0].shipmentNumber;        
            String scvCode = lstBotInput[0].scvCode;
            String operator = BrandUtilities.getBrandOperatorCode(lstBotInput[0].brand);
            operator = operator.toUpperCase();       
            Map<String,String> mapTaskStatus = new Map<String,String>();
            try{  
                partyRes = (String)GCSSPartyDetailsController.getGCSSPartyDetails(shipmentNumber,scvCode,operator);
                if(partyRes == 'Read timed out'){
                    lstPartyInfo = getPartyInfo(null,null,Label.ReadTimedOut);
                    isException = true;   
                }
            }catch(Exception ex){
                lstPartyInfo = getPartyInfo(null,null,ex.getMessage());
                isException = true;
            }
            if(!isException){                                
                Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(partyRes);
                roleAvailable= (String)mapResponse.get('customerRoleAvailable');
                if(roleAvailable== 'Yes'){
                    List<Object> lstRoles = (List<Object>) mapResponse.get('verifyCustomerRoleResponse');
                    if(lstRoles.size()>0){    
                        System.debug('***lstRoles'+lstRoles.size());           
                        for(Object obj: lstRoles){                   
                            Map<String,Object> data = (Map<String,Object>)obj;
                            if(data.get('partyRoleTypeName') == Label.GCSSBookedByParty || data.get('partyRoleTypeName') == Label.GCSSShipperParty || data.get('partyRoleTypeName') == Label.GCSSTPDocParty){                                           
                                isParty = true;
                                break;
                            }
                        }
                    }                
                }else if(roleAvailable == 'No' || (roleAvailable == 'Yes' && !isParty)){               
                    lstPartyInfo = getPartyInfo(null,'No',null);
                    isParty = false;
                }else{                
                    errorReceived = (String)mapResponse.get('debugMessage');                
                    lstPartyInfo = getPartyInfo(null,null,errorReceived);
                    isParty = false; 
                }
                
                if(isParty){ 
                    try{  
                        taskRes = (String)GcssTasksController.getGcssTasksDetails(shipmentNumber,operator);
                        if(taskRes == 'Read timed out'){
                            lstPartyInfo = getPartyInfo(null,null,Label.ReadTimedOut);
                            isException = true;   
                        }
                    }catch(Exception ex){
                        lstPartyInfo = getPartyInfo(null,null,ex.getMessage());
                        isException = true;
                    }
                    if(!isException){
                        Map<String,Object> mapTaskResponse = (Map<String,Object>)JSON.deserializeUntyped(taskRes);
                        List<Object> lstTasks = (List<Object>) mapTaskResponse.get('tasks');                    
                        if(lstTasks != null && lstTasks.size()>0){                        
                            for(Object obj1: lstTasks){                           
                                Map<String,Object> tData = (Map<String,Object>)obj1;
                                if(tData.get('taskName') == Label.GCSSIssueVCTask || tData.get('taskName') == Label.GCSSTPDocInstrTask || tData.get('taskName') == Label.GCSSCnfrmShpmntTask || tData.get('taskName') == Label.GCSSIssueOrgnlTPDocTask){                              
                                    if(!mapTaskStatus.containsKey((String)tData.get('taskName'))){
                                        mapTaskStatus.put((String)tData.get('taskName'),(String)tData.get('status'));   
                                    }
                                    else{
                                        isDuplicateTask = true;
                                        break;
                                    }
                                }
                            }
                            if(!isDuplicateTask && mapTaskStatus.containsKey(Label.GCSSIssueVCTask) && mapTaskStatus.containsKey(Label.GCSSTPDocInstrTask) && mapTaskStatus.get(Label.GCSSTPDocInstrTask) != 'Closed'){
                                lstPartyInfo = getPartyInfo(Label.GCSSSIRejected,'Yes',null);   
                            }
                            else if(!isDuplicateTask && mapTaskStatus.containsKey(Label.GCSSIssueVCTask) && mapTaskStatus.get(Label.GCSSIssueVCTask) != 'Closed' && mapTaskStatus.containsKey(Label.GCSSTPDocInstrTask) && mapTaskStatus.get(Label.GCSSTPDocInstrTask) == 'Closed'){
                                lstPartyInfo = getPartyInfo(Label.GCSSSIProcessing,'Yes',null);     
                            }
                            else if(!isDuplicateTask && mapTaskStatus.containsKey(Label.GCSSIssueVCTask) && mapTaskStatus.get(Label.GCSSIssueVCTask) == 'Closed' && mapTaskStatus.containsKey(Label.GCSSTPDocInstrTask) && mapTaskStatus.get(Label.GCSSTPDocInstrTask) == 'Closed' && mapTaskStatus.containsKey(Label.GCSSCnfrmShpmntTask) && mapTaskStatus.get(Label.GCSSCnfrmShpmntTask) != 'Closed' && mapTaskStatus.containsKey(Label.GCSSIssueOrgnlTPDocTask) && mapTaskStatus.get(Label.GCSSIssueOrgnlTPDocTask) != 'Closed'){
                                lstPartyInfo = getPartyInfo(Label.TransferToAgent,'Yes',null);     
                            }
                            else if(!isDuplicateTask && mapTaskStatus.containsKey(Label.GCSSIssueVCTask) && mapTaskStatus.get(Label.GCSSIssueVCTask) == 'Closed' && mapTaskStatus.containsKey(Label.GCSSTPDocInstrTask) && mapTaskStatus.get(Label.GCSSTPDocInstrTask) == 'Closed' && mapTaskStatus.containsKey(Label.GCSSCnfrmShpmntTask) && mapTaskStatus.get(Label.GCSSCnfrmShpmntTask) == 'Closed' && mapTaskStatus.containsKey(Label.GCSSIssueOrgnlTPDocTask) && mapTaskStatus.get(Label.GCSSIssueOrgnlTPDocTask) != 'Closed'){
                                lstPartyInfo = getPartyInfo(Label.GCSSVCReleased,'Yes',null);    
                            }
                            else if(!isDuplicateTask && mapTaskStatus.containsKey(Label.GCSSIssueVCTask) && mapTaskStatus.get(Label.GCSSIssueVCTask) == 'Closed' && mapTaskStatus.containsKey(Label.GCSSTPDocInstrTask) && mapTaskStatus.get(Label.GCSSTPDocInstrTask) == 'Closed' && mapTaskStatus.containsKey(Label.GCSSCnfrmShpmntTask) && mapTaskStatus.containsKey(Label.GCSSIssueOrgnlTPDocTask) && mapTaskStatus.get(Label.GCSSIssueOrgnlTPDocTask) == 'Closed'){
                                lstPartyInfo = getPartyInfo(Label.GCSSOriginalReleased,'Yes',null);  
                            }
                            else{
                                lstPartyInfo = getPartyInfo(Label.TransferToAgent,'Yes',null);
                            }
                        }
                        else{
                            lstPartyInfo = getPartyInfo(Label.TransferToAgent,'Yes',null); 
                        }
                    }
                }            
            }
        }
        catch(Exception ex)
        {
            lstPartyInfo = getPartyInfo(null,null,'System Error/Unhandled Error');
            isException = true;    
        }
        return lstPartyInfo; 
    }
    
    public static List<partyInfo> getPartyInfo(string status,string isParty, string error){
        List<partyInfo> lstParty = new List<partyInfo>();
        partyInfo party = new partyInfo();                  
        party.customerRoleAvailable = isParty;
        party.taskStatus = status;
        party.partyError = error;
        lstParty.add(party);
        return lstParty;
    }
}