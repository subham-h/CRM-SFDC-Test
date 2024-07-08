public with sharing class Sales_Bot_Controller {
    public String script { get; set; }   

    public Sales_Bot_Controller() {
        Sales_ChatBot__mdt chatConfig = [SELECT Id, EmbededServiceScript__c from Sales_ChatBot__mdt Where MasterLabel = 'ScriptCode' ];
        
        this.script = chatConfig.EmbededServiceScript__c;

    }

}