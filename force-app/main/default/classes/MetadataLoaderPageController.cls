public without sharing class MetadataLoaderPageController {

    public Blob csvFileBody{get;set;}
    public String metadataApiName{get; set;}
    private String[] csvFileRows {get;set;}
    public List <sObject> lstMetadata {get;set;}
    public List<String> lstFieldNames{get;set;}
    public boolean readSuccess {get;set;}

    sObject metadataObj;
    String metadataAsString;
    String fieldValue;
    Integer fieldNumber;
    Map <String, Integer> fieldNumberMap = new Map < String, Integer > ();
    Map<String, List<String>> mdtValuesByLabel = new Map<String, List<String>>();
    private Schema.SObjectType metadataType;

    public MetadataLoaderPageController() {
        readSuccess = FALSE;
        csvFileRows = new String[] {};
        lstMetadata = new List <sObject> ();
        lstFieldNames = new List<String>();
    }

    //To Read data from CSV file uploaded
    public void readFromFile(){
        try{
            metadataType = Schema.getGlobalDescribe().get(metadataApiName);
            metadataAsString = csvFileBody.toString();
            readCSVFile();
        } catch(exception e){
            readSuccess = FALSE;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file');
            ApexPages.addMessage(errorMessage);
        }
    }

    public void readCSVFile() {
        lstMetadata.clear();
        lstFieldNames.clear();
        csvFileRows = metadataAsString.split('\n');
        string[] csvFieldNames = csvFileRows[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());
        }
        String csvLine;
        for (Integer i = 1; i < csvFileRows.size(); i++) {
            metadataObj = metadataType.newSObject();
            csvLine = formatCSVlineComa(csvFileRows[i]);
            string[] csvRecordData = csvLine.split(',');
            List<String> mdtValues = new List<String>();
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber].replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                metadataObj.put(fieldName.trim(), fieldValue.trim());
                mdtValues.add(fieldValue.trim());
            }
            lstMetadata.add(metadataObj);   
            mdtValuesByLabel.put(mdtValues[0], mdtValues);           
        }
        if(lstMetadata.size() > 0){
            readSuccess = TRUE;
        }            
    }

    public void saveData() {
        try {
            //todo- upsert metadata
            String nameSpacePrefix = '';
            List<Metadata.CustomMetadata> records = new List<Metadata.CustomMetadata>();
            for(sObject mdt : lstMetadata) {
                String masterLabel = String.valueOf(mdt.get('MasterLabel'));
                String recordDevName = masterLabel.replaceAll(' ', '_');
                // Set up custom metadata to be created in the subscriber org.
                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                customMetadata.values = new List<Metadata.CustomMetadataValue>();
                customMetadata.fullName = nameSpacePrefix + metadataApiName + '.' + recordDevName;
                customMetadata.label = masterLabel;

                List<String> mdtValues = mdtValuesByLabel.get(masterLabel);
                for(Integer i=1; i<lstFieldNames.size(); i++) {
                    String fieldName = lstFieldNames[i];
                    Metadata.CustomMetadataValue cmv = new Metadata.CustomMetadataValue();
                    cmv.field = fieldName;
                    cmv.value = mdtValues[i]; //todo - add field value from map using i
                    customMetadata.values.add(cmv);
                }
                records.add(customMetadata);
            }
            Metadata.DeployContainer deployContainer = new Metadata.DeployContainer();
            for(Metadata.CustomMetadata record : records) {
                deployContainer.addMetadata(record);
            }
            CustomMetadataCallback callback = new CustomMetadataCallback();        
            Id jobId = Metadata.Operations.enqueueDeployment(deployContainer, callback);            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Metadata deployment started: jobId: ' + jobId);
            ApexPages.addMessage(errorMessage);
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while saving data: ' + e.getStackTraceString());
            ApexPages.addMessage(errorMessage);
        }
    }

    private String formatCSVlineComa(String csvLine) {
        String originalLine = csvLine;
        Integer startIndex;
        Integer endIndex;

        while(csvLine.indexOf('"') > -1){

            if(startIndex == null){
                startIndex = csvLine.indexOf('"');
                csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
            }else{
                if(endIndex == null){
                    endIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                }
            }

            if(startIndex != null && endIndex != null){
                String sub = csvLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                startIndex = null;
                endIndex = null;
            }
        }
        return csvLine;
    }
}