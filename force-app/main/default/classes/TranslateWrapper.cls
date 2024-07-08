/*
Description  : Wrapper class to parse the response

* version       Ref Number    Date                Owner                                       Description
*******************************************************************************************************************
* V1.0                        27/11/2023          ranjan.kumar.1@maersk.com                   Wrapper class to parse the response
*-------------------------------------------------------------------------------------------------------------------
*/
public class TranslateWrapper {

    public DetectedLanguage detectedLanguage;
    public List<Translations> translations;

    public class DetectedLanguage {
        public String language;
        public Double score;
    }

    public class Translations {
        public String text;
        public String to;
    }

    
    public static List<TranslateWrapper> parse(String json) {
        return (List<TranslateWrapper>) System.JSON.deserialize(json, List<TranslateWrapper>.class);
    }
}