/*
Class Name : QuoteEmailTemplateEditExtension
Description  : 1. Extension class to QuoteEmailTemplateEdit' VF page. Used to save Quote Email Template records
                and to get merge fields of Quote, Opportunity, Account and User objects.

Created By    : Cognizant Technology Solutions
Created On   : 26/03/2012
Change Log
--------------------------------------------------------------------------
Sr# Description                                     Updated By                          Updated On
01  #Upstream - Implemented code changes for
    handling AFLS Quote template records and 
    Quote email template records based on the       Jagadeesan.sakthivel@ust-global.com 21-Aug-2014
    record type selected while creating Template
    Definition record
02  RQ-007165: Changed the splitting of custom      Junaid.Khader@ust-global.com        16-Jul-2019
    labels from comma to semicolon
--------------------------------------------------------------------------  
*/ 


public with sharing class QuoteEmailTemplateEditExtension {

    public String strObjectSelect{get;set;}
    public String strFieldValue{get;set;}
    public String strDispValue{get;set;}
    public Quote_Template__c quoteEmailTempObj{get;set;}
    public List<SelectOption> fieldSelectList=new List<SelectOption>();
    public Boolean bShowDiv{get;set;}
    public String strBody{get;set;}
    public String strSubjectValue{get;set;}
    
    // #Upstream - Added variable to check whether the AFLS Quote email template is being created or Quote email template is being created
    public String isAflsQt{get;set;}
    
    private Set<String> userDisplayNameSet=new Set<String>(); //{'Alias','MobilePhone','City','CompanyName','Country','Department','Division','Email','EmployeeNumber','Extension','Fax','FirstName','Name','LanguageLocaleKey','LastName','Phone','State','Street','Title','Username','PostalCode'};
    private Set<String> quoteDisplayNameSet=new Set<String>(); //{'Generate_PDF__c','No_of_Quote_PDF__c','Send_Mail__c','SendMailCount__c','Send_To_Mail__c','ShippingHandling','ShippingCity','ShippingCountry','ShippingName','ShippingState','ShippingStreet','ShippingPostalCode','IsSyncing'};
    private Set<String> oppDisplayNameSet=new Set<String>(); //{'Activity_Check__c','IsClosed','IsDeleted','ForecastCategory','HasOpportunityLineItem','Lead_Id__c','LeadSource','NextStep','Record_Locked__c','ResentQuoteCount__c','Send_To_mail__c','IsWon'};
    private Set<String> accDisplayNameSet=new Set<String>(); //{'Activity_Monitor__c','IsDeleted'};
    private Set<String> aflsQuoteDisplayNameSet=new Set<String>();  //#Upstream - Added Set for storing AFLS Quote related fields. 
    
    public QuoteEmailTemplateEditExtension(ApexPages.StandardController controller) {
    
        this.quoteEmailTempObj=(Quote_Template__c)controller.getRecord();
        // #Upstream -  To get the parameter from record type selection page
        isAflsQt = ApexPages.currentPage().getParameters().get('IsAFLSQt');
        Set<String> qtTemplateRecTypeSet = new Set<String>();
        qtTemplateRecTypeSet.add('Quote_Email_Template');
        qtTemplateRecTypeSet.add('AFLS_Quote_Email_Template');
        Map<Id,RecordType> mapOfQtTemplateRecIdToRecObj = new Map<Id,RecordType>([Select id,DeveloperName  FROM RecordType WHERE SobjectType='Quote_Template__C' and DeveloperName in :qtTemplateRecTypeSet]);
        Map<String, Id> mapOfQtTemplateRecTypeNameToRecId = new Map<String, Id>();
        for( Id recTypeId: mapOfQtTemplateRecIdToRecObj.KeySet()){
            RecordType recTypeObj = mapOfQtTemplateRecIdToRecObj.get(recTypeId);
            mapOfQtTemplateRecTypeNameToRecId.put(recTypeObj.DeveloperName,recTypeObj.Id);
        }
        bShowDiv=false;
        strBody=quoteEmailTempObj.Body__c+'<br/><br/>'+quoteEmailTempObj.Signature__c;
        if(quoteEmailTempObj.Name==null)
            quoteEmailTempObj.Name='Quote Email Template';
        if(isAflsQt == 'False'){
            strObjectSelect='Quote';
            quoteEmailTempObj.Name='Quote Email Template';
            quoteEmailTempObj.RecordTypeId = mapOfQtTemplateRecTypeNameToRecId.get('Quote_Email_Template');
        }else{
            strObjectSelect='AFLS Quote';
            quoteEmailTempObj.Name='AFLS Quote Email Template';
            quoteEmailTempObj.RecordTypeId = mapOfQtTemplateRecTypeNameToRecId.get('AFLS_Quote_Email_Template');
        }
        strDispValue='';
        List<String> tempStringList=Label.UserFieldsToDisplay.split('; ');
        userDisplayNameSet.addAll(tempStringList);
        tempStringList=Label.QuoteFieldsNotToDisplay.split('; ');
        quoteDisplayNameSet.addAll(tempStringList);
        tempStringList=Label.OppFieldsNotToDisplay.split('; ');
        oppDisplayNameSet.addAll(tempStringList);
        tempStringList=Label.AccFieldsNotToDisplay.split('; ');
        accDisplayNameSet.addAll(tempStringList);
        tempStringList=Label.AddAccFieldToDisplay.split('; ');
        accDisplayNameSet.addAll(tempStringList);
        tempStringList=Label.AFLSQuoteFieldsToDisplay.split('; ');
        aflsQuoteDisplayNameSet.addAll(tempStringList);
        addSelectedObject();
    }

    public List<SelectOption> getfieldSelectList(){
        return fieldSelectList;
    }
    public void setfieldSelectList(List<SelectOption> so){
        this.fieldSelectList=so;
    }
    
   public List<SelectOption> getSObjectName(){
        List<SelectOption> options=new List<SelectOption>();
        // #Upstream - Added check for adding AFLS Quote or Quote to the list of objects available depending upon the record type of Template definition Object
        if( isAflsQt == 'False')
            options.add(new SelectOption('Quote','Quote'));
        else
            options.add(new SelectOption('AFLS Quote','AFLS Quote'));
        options.add(new SelectOption('Opportunity','Opportunity'));
        options.add(new SelectOption('Account','Account'));
        options.add(new SelectOption('User','User'));
        return options;
    }

    public PageReference addSelectedObject(){
    fieldSelectList.clear();
        if(strObjectSelect=='Quote'){
            Map<String, Schema.SObjectField> quoteFieldMap = Schema.SObjectType.Quote.fields.getMap();
            for(Schema.SObjectField quoteFieldMapObj:quoteFieldMap.values()){
               // if(quoteFieldMapObj.getDescribe().getType().Name()!='Reference')
                    if(quoteDisplayNameSet.contains(quoteFieldMapObj.getDescribe().getName()))
                        fieldSelectList.add(new SelectOption(quoteFieldMapObj.getDescribe().getName(),quoteFieldMapObj.getDescribe().getLabel()));
            }
        }
        // #Upstream - Added code for displaying AFLS Quote fields on selecting AFLS Quote email template record type
        if(strObjectSelect=='AFLS Quote'){
            Map<String, Schema.SObjectField> aflsQuoteFieldMap = Schema.SObjectType.Qt_Quote__c.fields.getMap();
            for(Schema.SObjectField aflsQuoteFieldMapObj:aflsQuoteFieldMap.values()){
               // if(quoteFieldMapObj.getDescribe().getType().Name()!='Reference')
                    if(aflsQuoteDisplayNameSet.contains(aflsQuoteFieldMapObj.getDescribe().getName()))
                        fieldSelectList.add(new SelectOption(aflsQuoteFieldMapObj.getDescribe().getName(),aflsQuoteFieldMapObj.getDescribe().getLabel()));
            }
        }
        if(strObjectSelect=='Opportunity'){
            Map<String, Schema.SObjectField> oppFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
            for(Schema.SObjectField oppFieldMapObj:oppFieldMap.values()){
                //if(oppFieldMapObj.getDescribe().getType().Name()!='Reference')
                    if(oppDisplayNameSet.contains(oppFieldMapObj.getDescribe().getName()))
                        fieldSelectList.add(new SelectOption(oppFieldMapObj.getDescribe().getName(),oppFieldMapObj.getDescribe().getLabel()));
            }
        }
        if(strObjectSelect=='Account'){
            Map<String, Schema.SObjectField> accFieldMap = Schema.SObjectType.Account.fields.getMap();
            for(Schema.SObjectField accFieldMapObj:accFieldMap.values()){
                //if(accFieldMapObj.getDescribe().getType().Name()!='Reference')
                    if(accDisplayNameSet.contains(accFieldMapObj.getDescribe().getName()))
                        fieldSelectList.add(new SelectOption(accFieldMapObj.getDescribe().getName(),accFieldMapObj.getDescribe().getLabel()));
            }
        }
        if(strObjectSelect=='User'){
            Map<String, Schema.SObjectField> userFieldMap = Schema.SObjectType.User.fields.getMap();
            for(Schema.SObjectField userFieldMapObj:userFieldMap.values()){
                if(userFieldMapObj.getDescribe().getType().Name()!='Reference'){
                    if(userFieldMapObj.getDescribe().isCustom() || userDisplayNameSet.contains(userFieldMapObj.getDescribe().getName())){
                        fieldSelectList.add(new SelectOption(userFieldMapObj.getDescribe().getName(),userFieldMapObj.getDescribe().getLabel()));
                    }
                }
            }
        }
        fieldSelectList=SortOptionList(fieldSelectList);
        return null;
    }
    
    //method to sort SelectOption list
    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort)
    {
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> lowerList = new List<SelectOption>();
        List<SelectOption> upperList = new List<SelectOption>();
        integer pivot = 0;
        
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption soObj : ListToSort)
        {
            if(soObj.getLabel() <= pivotValue.getLabel())
                lowerList.add(soObj);
            else if(soObj.getLabel() > pivotValue.getLabel())
                upperList.add(soObj);
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(SortOptionList(lowerList));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(upperList));
        return returnList; 
    }
    public PageReference addSelectedField(){
        strDispValue='';
        if( strObjectSelect == 'AFLS Quote')
            strDispValue='{!Qt_Quote__c.'+strFieldValue+'}';
        else
            strDispValue='{!'+strObjectSelect+'.'+strFieldValue+'}';
        return null;
    }
    
    public PageReference showValues(){
/*        PageReference pg=new PageReference('/apex/QuoteEmailTemplatePreview');
        pg.setRedirect(true);
        Blob b=pg.getContent();
        strBody=b.toString();
*/
        bShowDiv=true;
        strBody=quoteEmailTempObj.Body__c+'<br/><br/>'+quoteEmailTempObj.Signature__c;
        //strBody=quoteEmailTempObj.Body__c;
        return null;
    }
}