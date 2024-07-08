/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-007189   04-Oct-2019 Neha@TCS       Code created
*/
public class ContentDocumentLinkUtilities {
    
    public static void updateEventswithNotes( List<Event> lstEventsWithNotes, map<Id, ContentDocumentLink> oldMap) {
        try{
            // Update the has note field to true if note is connected to Event 
            List<Event> listToupdate = new List<Event>();
            for(Event eventrec: lstEventsWithNotes){                
                eventrec.HasNotes__c = true;
                listToupdate.add(eventrec);
            }
            if(listToupdate.size() > 0) { 
                update listToupdate;  
            }
        }
        catch(Exception ex){
            ErrorLogger.writeErrors('SFDC', 'Event', 'lstExceptions', new list<Exception>{ex}); 
        }
    }
    
    public static void deleteDuplicateContentDocuments(Map<Id, Id> contentDocIdToEntityIdMap, String context){
        List<ContentVersion> contentVerList = new List<ContentVersion>();
        Set<String> latestChecksumSet = new Set<String>();
        Set<String> existingChecksumSet = new Set<String>();
        Map<Id, ContentDocument> conDocMapToDelete = new Map<Id, ContentDocument>();
        Map<String,List<ContentVersion>> checksumToConVerListMap = new Map<String,List<ContentVersion>>();
        Map<String, General_Key_Value_Configurations__mdt> genKeyValConfigMap = new Map<String, General_Key_Value_Configurations__mdt>();
        Map<String, ContentVersion> checksumToExistingConVerMap = new Map<String, ContentVersion>();
        Map<String, ContentDocumentLink> cdlListForExistingToInsert = new Map<String, ContentDocumentLink>();
        
        for(General_Key_Value_Configurations__mdt genKey : [Select Id, DeveloperName, First_Field_Value__c From General_Key_Value_Configurations__mdt Where Key__c = 'BatchDeleteDuplicateEmailMessageFiles']){
            genKeyValConfigMap.put(genKey.DeveloperName, genKey);
        }
        
        Integer docSize = (genKeyValConfigMap.containsKey('ContentDocumentSize') && genKeyValConfigMap.get('ContentDocumentSize').First_Field_Value__c != null) ? Integer.valueOf(genKeyValConfigMap.get('ContentDocumentSize').First_Field_Value__c) : null;
        List<String> fileTypeList = (genKeyValConfigMap.containsKey('ContentDocumentType') && genKeyValConfigMap.get('ContentDocumentType').First_Field_Value__c != null) ? genKeyValConfigMap.get('ContentDocumentType').First_Field_Value__c.split(',') : null;
        Integer docSize10KB = (genKeyValConfigMap.containsKey('ContentDocumentSize10KB') && genKeyValConfigMap.get('ContentDocumentSize10KB').First_Field_Value__c != null) ? Integer.valueOf(genKeyValConfigMap.get('ContentDocumentSize10KB').First_Field_Value__c) : null;
        Integer size = 0;
        if(context == 'less than 10KB'){
            size = docSize10KB;
        }
        else{
            size = docSize;
        }
        
        if(size > 0 && !fileTypeList.isEmpty()){
            for(ContentDocument cd : [Select Id, ContentSize, (Select Id, ContentDocumentId, checksum, Checksum__c, ContentSize, FileExtension, FileType, Title, VersionNumber, IsLatest From ContentVersions Where IsLatest = true LIMIT 1) From ContentDocument Where Id =: contentDocIdToEntityIdMap.keyset() AND FileType IN: fileTypeList AND ContentSize <=: size LIMIT 25000]){
                if(!cd.ContentVersions.isEmpty()){
                    if(context == 'less than 10KB'){
                        ContentDocument cdToDelete = new ContentDocument();
                        cdToDelete.Id = cd.Id;
                        conDocMapToDelete.put(cdToDelete.Id, cdToDelete);
                    }
                    else if(context == 'Duplicate only'){
                        contentVerList.add(cd.ContentVersions[0]);
                        if(!String.isEmpty(cd.ContentVersions[0].Checksum__c)){
                            latestChecksumSet.add(cd.ContentVersions[0].Checksum__c);
                            if(checksumToConVerListMap.isEmpty() || !checksumToConVerListMap.containsKey(cd.ContentVersions[0].Checksum__c)){
                                checksumToConVerListMap.put(cd.ContentVersions[0].Checksum__c, new List<ContentVersion>{cd.ContentVersions[0]});
                            }
                            else{
                                checksumToConVerListMap.get(cd.ContentVersions[0].Checksum__c).add(cd.ContentVersions[0]);
                            }
                        }
                    }
                    else{
                        if(cd.ContentSize <= docSize10KB){
                            ContentDocument cdToDelete = new ContentDocument();
                            cdToDelete.Id = cd.Id;
                            conDocMapToDelete.put(cdToDelete.Id, cdToDelete);
                        }
                        else{
                            contentVerList.add(cd.ContentVersions[0]);
                            if(!String.isEmpty(cd.ContentVersions[0].Checksum__c)){
                                latestChecksumSet.add(cd.ContentVersions[0].Checksum__c);
                                if(checksumToConVerListMap.isEmpty() || !checksumToConVerListMap.containsKey(cd.ContentVersions[0].Checksum__c)){
                                    checksumToConVerListMap.put(cd.ContentVersions[0].Checksum__c, new List<ContentVersion>{cd.ContentVersions[0]});
                                }
                                else{
                                    checksumToConVerListMap.get(cd.ContentVersions[0].Checksum__c).add(cd.ContentVersions[0]);
                                }
                            }
                        }
                    }
                }
            }
            
            if(!latestChecksumSet.isEmpty()){
                for(ContentVersion con : [Select Id, ContentDocumentId, checksum, Checksum__c From ContentVersion Where Checksum__c =: latestChecksumSet AND ContentDocumentId !=: contentDocIdToEntityIdMap.keyset() AND CreatedDate = LAST_N_DAYS:120 LIMIT 25000]){
                    existingChecksumSet.add(con.Checksum__c);
                    checksumToExistingConVerMap.put(con.Checksum__c, con);                    
                }
            }
            
            
            for(ContentVersion con : contentVerList){
                if(!existingChecksumSet.isEmpty() && existingChecksumSet.contains(con.Checksum__c)){
                    ContentDocument cdToDelete = new ContentDocument();
                    cdToDelete.Id = con.ContentDocumentId;
                    conDocMapToDelete.put(cdToDelete.Id, cdToDelete);
                    if(contentDocIdToEntityIdMap.containsKey(con.ContentDocumentId) && (cdlListForExistingToInsert.isEmpty() || !cdlListForExistingToInsert.containsKey(String.valueOf(con.ContentDocumentId)+String.valueOf(contentDocIdToEntityIdMap.get(con.ContentDocumentId))))){
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.LinkedEntityId = contentDocIdToEntityIdMap.get(con.ContentDocumentId);
                        cdl.ContentDocumentId = checksumToExistingConVerMap.get(con.Checksum__c).ContentDocumentId;
                        cdl.ShareType = 'V';
                        cdlListForExistingToInsert.put(String.valueOf(cdl.ContentDocumentId)+String.valueOf(cdl.LinkedEntityId), cdl);
                    }                    
                }
                else if(!checksumToConVerListMap.isEmpty() && checksumToConVerListMap.containsKey(con.Checksum__c) && checksumToConVerListMap.get(con.Checksum__c).size() > 1){
                    for(Integer i = 1; i < checksumToConVerListMap.get(con.Checksum__c).size(); i++){
                        ContentDocument cdToDelete = new ContentDocument();
                        cdToDelete.Id = checksumToConVerListMap.get(con.Checksum__c)[i].ContentDocumentId;
                        conDocMapToDelete.put(cdToDelete.Id, cdToDelete);
                    }
                }
            }
            if(!conDocMapToDelete.isEmpty()){
                delete conDocMapToDelete.values();
                Database.emptyRecycleBin(conDocMapToDelete.values());
            }
            
            if(!cdlListForExistingToInsert.isEmpty()){
                insert cdlListForExistingToInsert.values();
            }
            
            if(General_Settings__c.getInstance() != null && General_Settings__c.getInstance().Track_Batch_Records__c){
                ErrorLogger.writeError('SFDC', 'ContentDocument', 'ContentDocumentLinkUtilities.deleteDuplicateContentDocuments', 'Warning', 'Deleted content document ids', String.valueOf(conDocMapToDelete.keyset()));
            }
        }
    }
    
}