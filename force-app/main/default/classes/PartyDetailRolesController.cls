/*
Description  : Invocable class for making external webservice callout to GCSS for getting party and task details through Bot. 

* version    Ref Number     Date                Owner                               Description
*******************************************************************************************************************
* 1.0     SC-4737    23-08-2022    Thippeswamy@UST                                   Created getPartyRole Invocable method which is called from Einstein Chatbot. 
*-------------------------------------------------------------------------------------------------------------------
*/
global with sharing class PartyDetailRolesController {
    
    public class botInput{
        @InvocableVariable(required=true)
        public string shipmentNumber;
        @InvocableVariable(required=true)        
        public string brand;
        @InvocableVariable(required=true)
        public string scvCode;
    }    
    public class partyRoleInfo
    {
        @InvocableVariable(required=true)
        public boolean isImport; 
        @InvocableVariable(required=true)
        public boolean isExport;  
        @InvocableVariable(required=true)
        public boolean isInvoice;
        @InvocableVariable(required=true)
        public boolean isGeneric;
        @InvocableVariable(required=true)
        public string partyError;       
    }
    public static List<String> lstExportRole ;
    public static List<String> lstImportRole ;
    public static List<String> lstInvoiceRole ; 
    //SC-4737: Invoked from chatbot to get party role
    @InvocableMethod(label='getPartyRole')
    public static List<PartyRoleInfo> getPartyRole(List<botInput> lstBotInput)
    {
        Boolean isException = false;
        String partyRes;
        String roleAvailable; 
        Map<String,Object> mapResponse;
        List<partyRoleInfo> lstPartyRoleInfo = new List<partyRoleInfo>();   
        try{
            String shipmentNumber = lstBotInput[0].shipmentNumber;        
            String scvCode = lstBotInput[0].scvCode;
            String operator = BrandUtilities.getBrandOperatorCode(lstBotInput[0].brand);
            operator = operator.toUpperCase();
            try{
                partyRes = (String)GCSSPartyDetailsController.getGCSSPartyDetails(shipmentNumber,scvCode,operator);
                if(partyRes == 'Read timed out'){
                    lstPartyRoleInfo = partyRoleInfo(false,false,false,false,Label.ReadTimedOut);
                    isException = true;   
                }
                if(!isException)
                {
                    
                    mapResponse = (Map<String,Object>)JSON.deserializeUntyped(partyRes);
                    roleAvailable = (String)mapResponse.get('customerRoleAvailable');
                    if(roleAvailable != 'Yes' || (String)mapResponse.get('message') == 'Data not found')
                    {
                        partyRes = (String)GCSSPartyDetailsController.getGCSSPartyDetailsFortpDoc(shipmentNumber,scvCode,operator);
                        if(partyRes == 'Read timed out'){
                            lstPartyRoleInfo = partyRoleInfo(false,false,false,false,Label.ReadTimedOut);
                            isException = true;   
                        }
                        else
                        {
                            mapResponse = (Map<String,Object>)JSON.deserializeUntyped(partyRes);
                            roleAvailable = (String)mapResponse.get('customerRoleAvailable');
                        }
                    }
                    
                }
            }
            catch(Exception ex)
            {
                lstPartyRoleInfo  = partyRoleInfo(false,false,false,false, 'System Error/Unhandled Error');
                isException = true;  
            }           
            
            if(!isException){                                
                getPartyRoleFromMdt();
                boolean isImport = false;
                boolean isExport = false;
                boolean isInvoice = false;
                boolean isGeneric = false;
                if(roleAvailable== 'Yes'){
                    List<Object> lstRoles = (List<Object>) mapResponse.get('verifyCustomerRoleResponse');
                    if(lstRoles.size()>0){    
                        for(Object obj: lstRoles){                   
                            Map<String,Object> data = (Map<String,Object>)obj;
                            String  partyRoleTypeName =  ((String)data.get('partyRoleTypeName')).toLowerCase();                                                 
                            if(lstExportRole.contains(partyRoleTypeName))
                            {
                                isExport = true; 
                            }
                            else if(lstImportRole.contains(partyRoleTypeName))
                            {
                                isImport = true;    
                            }
                            else if(lstInvoiceRole.contains(partyRoleTypeName))
                            {                                 
                                isInvoice = true;
                                
                            }
                            else
                            {
                                isGeneric = true;   
                            }
                        }
                    } 
                    lstPartyRoleInfo = partyRoleInfo(isExport,isImport,isInvoice,isGeneric, null);               
                }
                else{                
                    String errorReceived = (String)mapResponse.get('debugMessage');                
                    lstPartyRoleInfo = partyRoleInfo(false,false,false,false,errorReceived);
                }
                
            }
            
        }   
        catch(Exception e)
        {
            lstPartyRoleInfo  = partyRoleInfo(false,false,false,false,'System Error/Unhandled Error');  
            isException = true;  
        }
        
        return lstPartyRoleInfo;
    }   
    public static List<partyRoleInfo> partyRoleInfo(boolean isExport, boolean isImport, boolean isInvoice, boolean isGeneric, string error){
        List<partyRoleInfo> lstParty = new List<partyRoleInfo>();
        partyRoleInfo party = new partyRoleInfo();  
        party.isExport = isExport;                
        party.isImport = isImport;
        party.isInvoice = isInvoice;
        party.isGeneric = isGeneric;
        party.partyError = error;
        lstParty.add(party);
        return lstParty;
    }
    
    public static void getPartyRoleFromMdt()
    {
         lstExportRole = new  List<String>();
         lstImportRole = new  List<String>();
         lstInvoiceRole = new  List<String>(); 
        List<General_Key_Value_Configurations__mdt> genKeyValueMdt = [Select Id, First_Field_Value__c, Second_Field_Value__c, Key__c 
                                                                      From General_Key_Value_Configurations__mdt 
                                                                      Where Key__c IN ('ImportRole', 'ExportRole', 'InvoiceRole')];                                                               
        for(General_Key_Value_Configurations__mdt mdt : genKeyValueMdt)
        {
            if(mdt.Key__c == 'ImportRole')
            {
                lstImportRole.add(mdt.First_Field_Value__c);
                if(mdt.Second_Field_Value__c != null)
                {
                    lstImportRole.add(mdt.Second_Field_Value__c);
                }
            }
            if(mdt.Key__c == 'ExportRole')
            {
                lstExportRole.add(mdt.First_Field_Value__c);
                if(mdt.Second_Field_Value__c != null)
                {
                    lstExportRole.add(mdt.Second_Field_Value__c);
                }
            }
            if(mdt.Key__c == 'InvoiceRole')
            {
                lstInvoiceRole.add(mdt.First_Field_Value__c);
                if(mdt.Second_Field_Value__c != null)
                {
                    lstInvoiceRole.add(mdt.Second_Field_Value__c);
                }
            }
        } 
        
    } 
}