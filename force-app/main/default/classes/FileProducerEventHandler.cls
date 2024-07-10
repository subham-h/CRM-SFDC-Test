/* To be used for creating File Platform Event for Artemis*/
      public without sharing class FileProducerEventHandler {
        public class fileWrapper{
            String sf_content_document_id;
            String sf_content_version_id;
            String file_id;
            String email_message_external_id;
            String case_artemis_external_id;
            String file_name;
            String content_type;
            String creation_date;
            String checksum;
            String sf_content_document_link_id;
            String contentsize;
            // String lastmodifieddate;
            public fileWrapper(String sf_content_document_id,
                String sf_content_version_id,
                String file_id,
                String email_message_id,
                String case_artemis_id,
                String file_name,
                String checksum,
                String sf_content_document_link_id,
                String content_type,
                String contentsize,
                String creation_date
                
                // String lastmodifieddate
                )
            {
                this.sf_content_document_id=sf_content_document_id;
                this.sf_content_version_id=sf_content_version_id;
                this.file_id=file_id;
                this.email_message_external_id=email_message_id;
                this.case_artemis_external_id=case_artemis_id;
                this.file_name=file_name;
                this.content_type=content_type;
                this.creation_date=creation_date;
                this.checksum=checksum;
                this.sf_content_document_link_id=sf_content_document_link_id;
                this.contentsize=contentsize;

                // this.lastmodifieddate=lastmodifieddate;
    
            }
        } 
        public static void createFileEvent(Map<Id,ContentDocumentLink> newConDocLinkMap) {
            
            List<ContentDocumentLink> conDocList=[select Id,
                                                        contentdocument.CreatedDate, 
                                                        ContentDocument.title, 
                                                        ContentDocument.FileExtension ,
                                                        LinkedEntityId, 
                                                        LinkedEntity.type, 
                                                        ContentDocumentId 
                                                        from ContentDocumentLink 
                                                        where Id=:newConDocLinkMap.keySet() ];
            Set<String> typeSet=new Set<String>();
            Set<Id> email_artemis_ids=new Set<Id>();
            Set<Id> case_artemis_id=new Set<Id>();
            Set<Id> contentdocIdSet=new Set<Id> ();
            Map<id,ContentDocumentLink> conLinkIdCdocMap=new Map<id,ContentDocumentLink>();
            for (ContentDocumentLink cdLinkObj : conDocList) {
                if('Case'.equalsIgnoreCase(cdLinkObj.LinkedEntity.type)){
                    case_artemis_id.add(cdLinkObj.LinkedEntityId);
                }else if('EmailMessage'.equalsIgnoreCase(cdLinkObj.LinkedEntity.type)){
                    email_artemis_ids.add(cdLinkObj.LinkedEntityId);
                }
                conLinkIdCdocMap.put(cdLinkObj.LinkedEntityId,cdLinkObj);
                contentdocIdSet.add(cdLinkObj.ContentDocumentId);
            }
            List<ContentVersion> converList=[select id,Contentdocumentid,Checksum,ContentSize from ContentVersion where Contentdocumentid=:contentdocIdSet];
            Map<id,List<String>> conDocIdConverIdMap=new Map<id,List<String>> ();
            for(ContentVersion conVerObj:converList){
                List<String> tempList=new List<String>();
                tempList.add(conVerObj.id);
                tempList.add(conVerObj.Checksum);
                tempList.add(String.valueOf(conVerObj.ContentSize));
                
                conDocIdConverIdMap.put(conVerObj.Contentdocumentid, tempList);
            }
            Map<id,Case> caseMap;
            Map<id,EmailMessage> emailMap;
            if(!case_artemis_id.isEmpty()){
                caseMap=new  Map<id,Case>([select id,Artemis_Id__c from Case where id in:case_artemis_id and Artemis_Id__c!=null]);
            } 
            if(!email_artemis_ids.isEmpty()){
                emailMap=new  Map<id,EmailMessage>([select id,Artemis_Id__c from EmailMessage where id in:email_artemis_ids and Artemis_Id__c!=null]);
            } 
            Map<id,id> fileIdParentArtIdMap=new Map<id,id> ();
            List<fileWrapper> fileWrapperList=new List<fileWrapper>();
            if(caseMap!=null && !caseMap.isEmpty())
            {
                for(case cseObj:caseMap.values()){
                    ContentDocumentLink cdlObj= conLinkIdCdocMap.get(cseObj.id);
                    fileWrapperList.add(ArtemisEMPUtility.createFileWrapper(conDocIdConverIdMap,cdlObj,cseObj.Artemis_Id__c,'Case'));
                }    
            }
            if(emailMap!=null && !emailMap.isEmpty())
            {
                for(EmailMessage emailObj:emailMap.values()){
                    ContentDocumentLink cdlObj= conLinkIdCdocMap.get(emailObj.id);
                    fileWrapperList.add(ArtemisEMPUtility.createFileWrapper(conDocIdConverIdMap,cdlObj,emailObj.Artemis_Id__c,'Email'));
                }    
            }
            if(!fileWrapperList.isEmpty()){
                ArtemisEMPUtility.produceFileEvent(fileWrapperList);
            }
            

        }
        
    }