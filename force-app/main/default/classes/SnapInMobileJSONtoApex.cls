/*
 * Author   : Mohammad Naved
 * Purpose  : parse for SnapinCode for Mobile chat
 *        
 * Revision Ref Number            Date        Owner                   Description
 * -------- --------------------  ----------- -------------------     -----------
 * 1.0      RQ-008801/RQ-008799   27-Mar-2019 Naved@maersk                Created.
 * 
 *  
 */
public class SnapInMobileJSONtoApex {

    
    public String orgId {get;set;} 
    public List<ListEsla> listEsla {get;set;} 
    
    public String baseLiveAgentUrl {get;set;} 
    public String baseLiveAgentContentUrl {get;set;} 
    public List<PreChatSetupInfo> preChatSetupInfo {get;set;} 

    public SnapInMobileJSONtoApex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'orgId') {
                        orgId = parser.getText();
                    } else if (text == 'listEsla') {
                        listEsla = arrayOfListEsla(parser);
                    } else if (text == 'baseLiveAgentUrl') {
                        baseLiveAgentUrl = parser.getText();
                    } else if (text == 'baseLiveAgentContentUrl') {
                        baseLiveAgentContentUrl = parser.getText();
                    } else if (text == 'preChatSetupInfo') {
                        preChatSetupInfo = arrayOfPreChatSetupInfo(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class EntityFieldMaps {
        public Boolean doCreate {get;set;} 
        public Boolean doFind {get;set;} 
        public String fieldName {get;set;} 
        public Boolean isExactMatch {get;set;} 
        public String label {get;set;} 

        public EntityFieldMaps(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'doCreate') {
                            doCreate = parser.getBooleanValue();
                        } else if (text == 'doFind') {
                            doFind = parser.getBooleanValue();
                        } else if (text == 'fieldName') {
                            fieldName = parser.getText();
                        } else if (text == 'isExactMatch') {
                            isExactMatch = parser.getBooleanValue();
                        } else if (text == 'label') {
                            label = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'EntityFieldMaps consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ListEsla {
        public String ml {get;set;} 
        public String liveChatDeployment {get;set;} 
        public String liveChatButton {get;set;} 
        public String lcdId {get;set;} 
        public String lcbId {get;set;} 
        public String lang {get;set;} 

        public ListEsla(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'ml') {
                            ml = parser.getText();
                        } else if (text == 'liveChatDeployment') {
                            liveChatDeployment = parser.getText();
                        } else if (text == 'liveChatButton') {
                            liveChatButton = parser.getText();
                        } else if (text == 'lcdId') {
                            lcdId = parser.getText();
                        } else if (text == 'lcbId') {
                            lcbId = parser.getText();
                        } else if (text == 'lang') {
                            lang = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ListEsla consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class PreChatSetupInfo {
        public List<EntityFieldMaps> entityFieldMaps {get;set;} 
        public String entityName {get;set;} 
        public Boolean showOnCreate {get;set;} 
        public String linkToEntityName {get;set;} 
        public String linkToEntityField {get;set;} 
        public String saveToTranscript {get;set;} 

        public PreChatSetupInfo(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'entityFieldMaps') {
                            entityFieldMaps = arrayOfEntityFieldMaps(parser);
                        } else if (text == 'entityName') {
                            entityName = parser.getText();
                        } else if (text == 'showOnCreate') {
                            showOnCreate = parser.getBooleanValue();
                        } else if (text == 'linkToEntityName') {
                            linkToEntityName = parser.getText();
                        } else if (text == 'linkToEntityField') {
                            linkToEntityField = parser.getText();
                        } else if (text == 'saveToTranscript') {
                            saveToTranscript = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'PreChatSetupInfo consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static SnapInMobileJSONtoApex parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SnapInMobileJSONtoApex(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    



    private static List<ListEsla> arrayOfListEsla(System.JSONParser p) {
        List<ListEsla> res = new List<ListEsla>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ListEsla(p));
        }
        return res;
    }





    private static List<PreChatSetupInfo> arrayOfPreChatSetupInfo(System.JSONParser p) {
        List<PreChatSetupInfo> res = new List<PreChatSetupInfo>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new PreChatSetupInfo(p));
        }
        return res;
    }



    private static List<EntityFieldMaps> arrayOfEntityFieldMaps(System.JSONParser p) {
        List<EntityFieldMaps> res = new List<EntityFieldMaps>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new EntityFieldMaps(p));
        }
        return res;
    }


}