public class ViewOrgChartControllerTestCLS {

    // method to update contact records to change reports to field
    @AuraEnabled
    public static String updateContact( Id reportToId, Id contactId){

        String message = 'success';
		
        Contact con = new Contact();
		con.id = contactId;
		system.debug('con id : '+ reportToId);
        if (String.valueof(reportToId).startsWith('001')){
            con.ReportsToId = null;
        } else{
            con.ReportsToId = reportToId;
        }

        try{
            update con;
        } catch(Exception ex){
            message = ex.getmessage();
        }
        return message;
	}
    
     public class OrgChartStructure{
        public String name;
        public String title;
        public String email;
        public String phone;
        public String primaryStakeholder;
        public String manager;
     }
    
    // get stakeholder details in wrapper class instance
    @auraEnabled
    public static List<OrgChartStructure> getStakeholderHierarchy(Id recordId){
        Map<String,OrgChartWrapper> mapOrgChartTemp = new Map<String,OrgChartWrapper>();
        orgChartResponse response = new orgChartResponse();        
        List<Business_Plan__c> getLeadAccDetails = [Select Name, Lead_Account__c, Lead_Account__r.Name, 
                                                        Lead_Account__r.Customer_Code__c, Lead_Account__r.Country__r.Name
                                                    from Business_Plan__c 
                                                    where Id =:recordId ];

        // form root node -- lead account details
        OrgChartWrapper orgItemLeadAcc = new OrgChartWrapper(getLeadAccDetails[0].Lead_Account__c, getLeadAccDetails[0].Lead_Account__r.Name, '0', getLeadAccDetails[0].Lead_Account__r.Customer_Code__c, getLeadAccDetails[0].Lead_Account__r.Country__r.Name);
        mapOrgChartTemp.put(orgItemLeadAcc.Id,orgItemLeadAcc);

        // get all external stakeholders
        mapOrgChartTemp.putAll( getContacts( recordId, getLeadAccDetails[0].Lead_Account__c));
        List<OrgChartStructure> lstOrgChartStructure = new List<OrgChartStructure>();
        
        for(String id : mapOrgChartTemp.keySet()){
            OrgChartStructure orgStruct = new OrgChartStructure();
            orgStruct.manager = mapOrgChartTemp.get(mapOrgChartTemp.get(id)?.parent)?.name;
            orgStruct.name = mapOrgChartTemp.get(id).name;
            orgStruct.title = mapOrgChartTemp.get(id).jobtitle;
            orgStruct.email = mapOrgChartTemp.get(id).email;
            orgStruct.phone = mapOrgChartTemp.get(id).phone;
            orgStruct.primaryStakeholder = mapOrgChartTemp.get(id).primaryStakeholder;
            lstOrgChartStructure.add(orgStruct);
        }
        
        return lstOrgChartStructure;
    }
    
    public static Map<String,OrgChartWrapper> getContacts(Id recordId, Id leadAccId){
        
        Map<String,OrgChartWrapper> MaporgChartData = new Map<String,OrgChartWrapper>();

        // get external record type id from stakeholder object
        Id recordTypeId = Schema.SObjectType.Stakeholder__c.getRecordTypeInfosByDeveloperName().get('External').getRecordTypeId();
        
        Map<Id,Stakeholder__c> stakeHoldersMap = new Map<Id, Stakeholder__c>();

        // fetch external stakeholder records for given account plan
        for(Stakeholder__c stakeholder : [SELECT Id, External_Stakeholder__c, External_Stakeholder__r.Name, External_Stakeholder__r.Title, 
                                                External_Stakeholder__r.Phone, External_Stakeholder__r.Email,
                                                External_Stakeholder__r.ReportsToId, External_Stakeholder__r.ReportsTo.ReportsToId, 
                                                External_Stakeholder__r.ReportsTo.ReportsTo.ReportsToId,
                                                Primary_Stakeholder__r.Stakeholder__c, Primary_Stakeholder__c
                                            FROM Stakeholder__c 
                                            WHERE Business_Plan__c =:recordId and RecordTypeId =:recordTypeId]){

                stakeHoldersMap.put(stakeholder.External_Stakeholder__c, stakeholder);
        }
        
        for(Stakeholder__c stakeHolder : stakeHoldersMap.values()){

            boolean directRelation = false;
            Id parentId;

            // check if stakeholder contact is directly associated to account plan or
            // if ReportsTo contact is not realted to account plan then display it as indirect relationship

            if(stakeHolder.External_Stakeholder__r.ReportsToId != null && stakeHoldersMap.containsKey(stakeHolder.External_Stakeholder__r.ReportsToId)){
                directRelation= true;
                parentId = stakeHolder.External_Stakeholder__r.ReportsToId;
            }else if(stakeHolder.External_Stakeholder__r.ReportsToId == null){
                directRelation= true;
                parentId = leadAccId;
            }else if(stakeHolder.External_Stakeholder__r.ReportsTo.ReportsToId != null && stakeHoldersMap.containsKey(stakeHolder.External_Stakeholder__r.ReportsTo.ReportsToId)){
                parentId = stakeHolder.External_Stakeholder__r.ReportsTo.ReportsToId;
            }else if(stakeHolder.External_Stakeholder__r.ReportsTo.ReportsTo.ReportsToId != null && stakeHoldersMap.containsKey(stakeHolder.External_Stakeholder__r.ReportsTo.ReportsTo.ReportsToId)){
                parentId = stakeHolder.External_Stakeholder__r.ReportsTo.ReportsTo.ReportsToId;                
            }else{
                parentId = leadAccId;
            }
            OrgChartWrapper orgChartCon = new OrgChartWrapper(stakeHolder, parentId, directRelation);
            MaporgChartData.put(orgChartCon.Id,orgChartCon);  
        }
        return MaporgChartData;
    }
    
    //method to fetch and return chart css details from metadata
    @AuraEnabled
    public static List<Account_Plan_Org_Chart_Color__mdt> getOrgChartColors(){
        List<Account_Plan_Org_Chart_Color__mdt> orgChartColors = [SELECT Id, DeveloperName, MasterLabel, Color__c 
                                                                    FROM Account_Plan_Org_Chart_Color__mdt];
        return orgChartColors;
    }
    
    // wrapper to store stakeholder records and account plan name
    public class orgChartResponse{

        @AuraEnabled public List<OrgChartWrapper> lstNodes;
        @AuraEnabled public String accPlanName;

        public orgChartResponse(){
            lstNodes = new List<OrgChartWrapper>();
            accPlanName = '';
        }
    }

    // wrapper to store stakeholder details
    public class OrgChartWrapper{

        @AuraEnabled public String id;
        @AuraEnabled public String stakeholder;
        @AuraEnabled public String name;
        @AuraEnabled public String parent;
        @AuraEnabled public String jobtitle;
        @AuraEnabled public String phone;
        @AuraEnabled public String email;
        @AuraEnabled public boolean directRelation;
        @AuraEnabled public String primaryStakeholder;
        @AuraEnabled public Id primaryStakeholderId;
        
        public OrgChartWrapper(String id, String name, String parent, String jobtitle, String phone){
            
            this.id = id;
            this.stakeholder = null;
            this.name = name;
            this.parent = parent;
            this.jobtitle = jobtitle;
            this.phone = phone;
            this.email = null;
            this.directRelation = true;
        }

        public OrgChartWrapper(Stakeholder__c rec, String parent, boolean directRelation){
            
            this.id = rec.External_Stakeholder__c;
            this.stakeholder = rec.Id;
            this.name = rec.External_Stakeholder__r.Name;
            this.parent = parent;
            this.jobtitle = rec.External_Stakeholder__r.Title;
            this.phone =  rec.External_Stakeholder__r.phone;
            this.email = rec.External_Stakeholder__r.email;
            this.directRelation = directRelation;
            this.primaryStakeholderId = rec.Primary_Stakeholder__c;
            this.primaryStakeholder = rec.Primary_Stakeholder__r.Stakeholder__c;
        }
    }

    
}