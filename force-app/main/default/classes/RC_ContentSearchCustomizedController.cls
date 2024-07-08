/**
 * RC_ContentSearchCustomizedController - Controller provides a list of relevant content for the record based on keywords (default: RC_Keywords__c)
 * Orginal code provided by the salesforce labs app Relevant Content <https://appexchange.salesforce.com/listingDetail?listingId=a0N3000000B5XerEAF>
 * 
 * Version History
 * ===============
 * 1. revathy.sudhindran@ust-global.com   29/6/2015   #RQ-001478  Suggested sales collateral to display on Salesforce Objects
 * 2. meghana.gupta@ust-global.com        13/8/2015   #RQ-001731  To change find logic to AND instead of OR    
 * 3. ramadevi.palaniswamy@ust-global.com 24/11/2016  #RQ-004515  Display Value Proposition Elements
 * 4. ramadevi.palaniswamy@ust-global.com 1/6/2017    #RQ-004640  Modify Value Proposition logic as search should return results only if both value proposition and Group value is present
 * 5. meghana.gupta@ust-global.com        31/8/2017   #RQ-004874/RQ-004875 - Add logic to check user's liber brand
 * 6. ramadevi.palaniswamy@ust-global.com 11/9/2017   #RQ-007289  Streamline Value Proposition - Content search change
 * 7. Manjunath.c.holekade@maersk.com     18-Dec-2018 #RQ-009583  Mod-01 , Mod-03 , Mod-06 & Mod-07 - Added For attaching files to the parent object &  Mod-02 & Mod-04 added for hidding post button in product page & Mod-05 added for removing the Name field from the query .
 * 8. meghana.gupta@ust-global.com        27/2/2019   #RQ-009988  Replace Value_Prosposition1__c by Value_Prosposition__c, and comment code to check multi-selected brand based value propositions
 * 9. Junaid.Khader@ust-global.com        14-Mar-2018 #RQ-009972  Added Internal_External__c field to the query
 * 10. Neha@TCS                           22-Oct-2019 #RQ-012219  Added another flag to check if it is CHB tariff
 * 11. Ronnie@SF                          09-Jun-2022  SPI-100    Removed brand hardcoding
 */

global with sharing class RC_ContentSearchCustomizedController {
    
    /* Define member variables   */  
    
    // Member variable to hold the current record
    public final sObject thisRecord {get; private set;}
    
    // Member variable for the number of search results displayed per page (currently only 1 page)
    public Integer RESULTS_PER_PAGE = 50;
    
    // Member variable to hold a flag to show the form
    public Boolean showForm {get; private set;}
    
    // Member variable to hold the sObject type
    public String thisObjectType {get; private set;}
    
    // Member variable for the record's Keywords 
    public String recordSearchString {get; set;}
    
    // Member variable for the record's Name 
    public String recordName {get; set;}
    
    // Member variable for the record's object icon 
    public String objectIcon {get; private set;}
    
    // Member variable for the total number of search results available (not currently displayed)
    public Integer totalResults {get; private set;}
    
    // Member variable to store whether or not Content is available in this org to this user
    public Boolean contentAvailable {get; private set;}
    
    // Member variable for the way Content is handled ('Content' if Content is available to the User or 'File' otherwise)
    public String contentType {get; private set;}
    
    // Member variable for the full list of record's Related Content data (up to totalResults in size)
    public List<ContentVersionContainer> recordContentAll{get; private set;}
    
    // Member variable for the receiving Comment on the post
    public String commentBody{get;set;}
    
    // Member variable for the Object label
    public String thisObjectLabel;
    
    // Member variable for the Object label
    public Id thisRecordId;
    
    // Added this varaible for RQ-009583 - Mod-01 for Parent attachement 
    public Id attachementParentId;
    
    //To take current user information
    public User crrUser; 
    
    // To the list of Liner Brands to which the user belongs
    public list<String> linerbrand { get ; set; }
    
    //To store the FieldSet names based on the LinerBrand
    public map<String,String> linerbrandFieldsetMap= new map<String,String>();    
    
    public Boolean fcFlag { get ; set; } // Flag to check which button was clicked
    public Boolean chbflag  { get ; set; } // Flag to check for CHB
    public Boolean errFlag { get ; set; }  // flag to check if there is error based on user's liner brand and available data
    public Boolean displayPostFlag{ get ; set; } // Flag to check if post button has to be displayed 
    
    //to store VP values
    Map<String,String>  lbSearchKeys= new Map<String,String>();
     
    /*  Constructor to initialize the Content list based on the record's RC_Keywords__c */
    public RC_ContentSearchCustomizedController() {
        
        /*  Initialize variables  */
        String chbflagValue = ApexPages.currentPage().getParameters().get('chbflag'); // this is added to identify if CHB Tarriff button is clciked on Opportunity Product
        thisRecordID = ApexPages.currentPage().getParameters().get('id');  // Get the record ID from the Visualforce page
        String flagValueStr = ApexPages.currentPage().getParameters().get('fcFlag'); //#RQ-004515 - To check which button was clicked
        String displayPostflagValueStr = ApexPages.currentPage().getParameters().get('displayPostFlag'); //Added this varaible for RQ-009583 Mod-02- hidding post button in product page . 
        attachementParentId = ApexPages.currentPage().getParameters().get('attachementParentId'); //Added this varaible for RQ-009583 Mod-03 for Parent attachement 
        // Prevent form from showing when the record ID or fcFlag is not available
        //  For example: during record creation
        if (thisRecordID == null || flagValueStr == null) {
            showForm = false;
            return;
        } 
        else {
            showForm = true;
        }  
        //RQ-009583 Start Mod-04 :- Hidding post button in product page for product information button.
        if (displayPostflagValueStr == null){ 
            displayPostFlag = false;
        }
        else{
            displayPostFlag = Boolean.valueOf(displayPostflagValueStr);
            
        }
        //RQ-009583 End Mod-04
         fcFlag = Boolean.valueOf(flagValueStr);
         //Added for CHB Product
        if(chbflagValue == null){
            chbflag = false;
        }
        else{
            chbflag =Boolean.valueOf(chbflagValue);
        }
        
        //#RQ-004515 - Get the Liner Brand of the current user
        Id uId = System.UserInfo.getUserId();
        
        // v5.0 - Starts
        errFlag = false; 
        
        // RQ-007289  
        String loggedInUserLinerBrand = '';   
        Map<String, String> brandPrefixMap = new Map<String, String>();
        brandPrefixMap = BrandUtilities.getShortFormAndBrandMap();
        
        List<String> rcAllowedBrandsList = BrandUtilities.getAllBrandsListWithRCSearchAllowed(); // get brands for which RC_ContentSearch is allowed.
        
        if (fcFlag == false){
            
            // fetch logged in user's liner brand
            List<User> loggedInUser = [ SELECT id, Liner_Brand__c FROM User WHERE Id = :UserInfo.getUserId() ];
            loggedInUserLinerBrand = loggedInUser.get(0).Liner_Brand__c;
            
            // form SOQL to fetch account details based on user's liner brand
            //#RQ-007289 - Included new fields
            //#RQ-009988 - replace field
            String soqlStr = 'SELECT id, Value_Proposition__c, Attractiveness__c FROM Account ';
            soqlStr += ' WHERE Id = :thisRecordID AND ';
            
            boolean valuePropCheck = false;
            
            for (String brand : rcAllowedBrandsList){
                if (loggedInUserLinerBrand.contains(brand))
                    valuePropCheck = true;
            }
         
         // If logged in user's liner brand contains any brand that has RC_ContentSearch enabled 
            if (valuePropCheck) {
                soqlStr += ' ( Value_Proposition__c != null ) ';
                
            } else {  
                
                errFlag = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, Label.Search_not_available_currently));
                return;
            }
            
            if ( !errFlag ){
                List<Account> accList = Database.Query(soqlStr); // execute SOQL to fetch account details
                if (accList == null || accList.isEmpty()){
                    
                    errFlag = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, Label.Search_not_available_currently));
                    return;
                    
                } 
            }
            //v5.0 Ends
        }
                
        // #RQ-004515 - Take the field set based on button clicked
        if(chbflag == true && fcFlag == true ){
            linerbrandFieldsetMap.put('All Brands','CHB_fields');
            
        }
        else if( fcFlag == true ) {
            linerbrandFieldsetMap.put('All Brands','RC_Keywords');
            
        }else {
            
            list<String> linerbrand = loggedInUserLinerBrand.split(';');
            if( linerbrand.size() > 0) {
                linerbrandFieldsetMap.put('All Brands','RC_VP_Keywords');
                                
                for (String lb : linerbrand ){
                    // check if user's brand has Content Search enabled
                    if (rcAllowedBrandsList.contains(lb)) {
                        lbSearchKeys.put(lb, '');
                    }                    
                }
            }
        }
        
        system.debug('Liner Brand of User: '+lbSearchKeys.keyset());
        
        // Get the object type and set the thisObjectType member variable
        thisObjectType = getObjectType(thisRecordID);
        
        
        /* Determine the sObject's name field. This will be sObject.Name for most objects and sObject.Subject for Tasks/Events and Cases */
        
        // Get the sObject field Map info from the ID
        Schema.SObjectType token = thisRecordID.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
        String nameFieldName = '';
        
        if (fieldMap.containsKey('Name')) {
            // Most Salesforce objects have a Name field
            nameFieldName = 'Name';
        } 
        else if (fieldMap.containsKey('Subject')) {
            
            // Tasks/Events do not have a Name field so use Subject
            nameFieldName = 'Subject';
        }
                
        /* Query the record for the Id, name, keywords */
        // Build the query string
        String thisRecordQueryString = 'SELECT Id';
        
        if (nameFieldName != '') {            
            thisRecordQueryString += ', ' + nameFieldName;
        }
        
        //#RQ-004515 - Getting the fields from corresponding field sets Fieldsets - RQ-004515
        for(String fieldsetTogetInfo : linerbrandFieldsetMap.values()) {
            for(Schema.FieldSetMember f : readFieldSet(fieldsetTogetInfo,thisObjectType)) {
                if(f.getFieldPath()!='name')  //RQ-009583  Mod-05 
                thisRecordQueryString += ', '+f.getFieldPath() ;
            }
        }    
        
        thisRecordQueryString += ' FROM ' + thisObjectType;
        thisRecordQueryString += ' WHERE Id = \'' + thisRecordID + '\'';
        thisRecordQueryString += ' LIMIT 1';
        system.debug('f.getFieldPath()'+thisRecordQueryString);
        // Query the record
        try {
            
            thisRecord = Database.query(thisRecordQueryString);
        } 
        catch (DmlException e) { 
            
            System.debug(LoggingLevel.ERROR, e.getMessage()); 
            return; 
        }
        
        // If the record is found, initialize the record name & object file icon
        // Note: thisRecord is a generic sObject, hence the use of getter methods
        recordContentAll = new List<ContentVersionContainer>();
        
        if (thisRecord.Id != null) {
            
            // Get the record's Name (or ID if the Name/Subject could not be determined)
            if (nameFieldName != '') {
                
                recordName = String.valueOf(thisRecord.get(nameFieldName));                
            } else {
                
                recordName = thisRecordID;
            }
        }
        
        // Initialize the totalResults to 0
        totalResults = 0;
        
        // Initialize the content availability and type (Content or File)
        contentAvailable = contentAvailableCheck();
        
        if (contentAvailable) {            
            contentType = 'Content';
        
        } else {            
            contentType = 'File';
        }
        
        // Perform the initial search with the record's keywords as the search string
        //  If the object contains a keyword field, use it's contents for the search string
        //  Otherwise, use the record's name
        
        // ************* #RQ-001731 STARTS - Form keyword search string while looping through fields so that multi-picklist data can be separated with OR 
        
        String SOSLSearchString = '';
        recordSearchString='';
        if (thisRecord.Id != null) {
            
            // Get the values from each field in Field Set to display on serach text fields 
            //(VAL1 OR val2 ) AND Val3 AND Val4
            
            for(String fieldsetTogetInfo : linerbrandFieldsetMap.values()) {
                
                String previousSrchvalue = Null;
                //Boolean valPropSearch = FALSE;
                
                for(Schema.FieldSetMember f : readFieldSet(fieldsetTogetInfo,thisObjectType)) {
                    
                    String fldValue = String.valueOf(recursiveGet(thisRecord,f.getFieldPath()));
                    String temp;
                  
                    if(fldValue != null) { 
                        
                        recordSearchString +=' '+ fldValue;
                        
                        if (f.gettype() == Schema.DisplayType.MultiPicklist){   
                        
                            // #RQ-007289 : build query string for attractiveness based on Liner Brand 
                            // #RQ-009988 - code modified to check only for Attractiveness not for Value Proposition                               
                            if(f.getLabel()== 'Attractiveness') {
                                
                                // default to 'Not Applicable' for all brands
                                for (String brand : rcAllowedBrandsList){                                       
                                    if(lbSearchKeys.containsKey(brand)) {
                                        temp = lbSearchKeys.get(brand)+ ' AND ' + Label.NotApplicable;
                                        lbSearchKeys.put(brand, temp);
                                    }                               
                                }   
                                
                                list<String> fldVals = fldValue.split('\\;'); 
                                fldValue = '';
                                for( String str : fldVals) {
                                    
                                    String lb = str.right(3);
                                    String srchVal = str.left(str.length()-4).replaceAll( '\\s+', '');                                                                        
                                    String linerBrandFullName = brandPrefixMap.get(lb);
                                        
                                    // if a brand match is found then replce Not Applicable by respective brand's Attractiveness value
                                    if( lbSearchKeys.containsKey(linerBrandFullName)) {
                                        
                                        if(lbSearchKeys.get(linerBrandFullName).contains(Label.NotApplicable)){
                                            temp = lbSearchKeys.get(linerBrandFullName).replace(Label.NotApplicable, srchVal);                                                                                    
                                        } else {                                            
                                            temp = lbSearchKeys.get(linerBrandFullName)+ ' AND ' + srchVal;
                                        }
                                        lbSearchKeys.put(linerBrandFullName,temp);
                                        system.debug('temp+++++'+lbSearchKeys.get(linerBrandFullName));
                                    }                               
                                } 
                                
                                // from above map form query criteria string ex. ( (Key-Client) Or (NotApplicable))
                                for( String str : lbSearchKeys.keySet()) {                                           
                                    String srchstr = lbSearchKeys.get(str).right(lbSearchKeys.get(str).length()-5);                                         
                                    if(srchstr != '') {
                                        if(fldValue =='')
                                            fldValue = '(' + srchstr + ')';   
                                        else {                                            
                                            fldValue = fldValue + ' OR ('+ srchstr + ')';                                              
                                        }
                                    }
                                }
                                fldValue = '(' + fldValue + ')'; //When concatenated with value props this multi-value string should be in () Ex. Ease AND ((Key-Client) Or (NotApplicable)) 
                            } else {
                                
                                fldValue = fldValue.replaceAll(';',' OR ');     
                            }
                        }   
                        system.debug('inside sosl construction'+lbSearchKeys.values());
                        
                        if (SOSLSearchString == '') {
                            SOSLSearchString = fldValue;
                        } else {
                            SOSLSearchString = SOSLSearchString + ' AND ' + fldValue;
                        }
                       
                        System.debug('$$$ SOSLSearchString : '+ SOSLSearchString);
                    } else {
                        // #RQ-007289 : Even if the value is not specified for Attractiveness and Value Proposition value is present then Not Applicable should be added to the query
                        if(f.getLabel()== 'Attractiveness' && lbSearchKeys.values().size()> 0 ) {
                            SOSLSearchString = SOSLSearchString + Label.NotApplicable;
                        }
                    }
                }
            }            
        }        
        
        SOSLSearchString = SOSLSearchString.removeEnd(' OR ');
        
        system.debug('SOSLSearchString +++++++'+SOSLSearchString );
        
        if(recordSearchString=='')// If record string has no value for fields from Fieldset default ito reocrd name
        {                
            recordSearchString += recordName;
            SOSLSearchString = recordName;
        }
        
        recordSearchString = recordSearchString.replaceAll(';',' '); //Removing Semicolon from serach string -There may be the fields in Fieldset that are multipicklist and values fron those fields will be seperated with semi colon. 
        
        performSearch(SOSLSearchString, true);              
        
        // ************ #RQ-001731 - END
        
    }
    
    
    
    /*
ContentVersionContainer - wrapper class for storing ContentVersion sObject & related information
*/
    public class ContentVersionContainer {
        
        // Getter/Setter for the contained sObject
        public ContentVersion contentVersionSObject {get; private set;}
        
        // Member variable for the formatted date string
        public String contentModifiedDateFormatted {get; private set;}
        
        // Member variable for the formatted file type string
        public String fileTypeFormatted {get; private set;}
        
        // Member variable for the file icon filename
        public String iconFilename {get; private set;}
        
        //#RQ-001478 Member variable for the file Selection
        public Boolean selected {get; set;}
        
        // Overloaded constructor to initialize formatted strings when given a ContentVersion input
        public ContentVersionContainer(ContentVersion c) {
            
            contentVersionSObject = c;
            
            // Format the date string
            contentModifiedDateFormatted = '';
            if (c.ContentModifiedDate != null) {
                
                contentModifiedDateFormatted = c.ContentModifiedDate.month() + '/' + c.ContentModifiedDate.day() + '/' + c.ContentModifiedDate.year();
            }
            
            // Format the FileType string
            fileTypeFormatted = '';
            
            if (c.FileType != null) {
                
                fileTypeFormatted = cleanFileType(c.FileType,c.PathOnClient);
            }
            
            // Determine the icon filename
            iconFilename = 'unknown.svg';
            if (fileTypeFormatted != null) {
                
                iconFilename = getIconFilename(fileTypeFormatted);
            }
            
            selected=false;
        }
    }
    
    
    
    /*
getObjectType - method to determine the type of an sObject given an ID
Inputs:
ID - record ID for which the sObject type will be returned
Returns:
String - sObject type
*/
    public String getObjectType(ID testRecordID) {
        system.debug('get sobjecttype');
        
        // Get the sObject token from the ID
        Schema.SObjectType token = testRecordID.getSObjectType();
        
        // Using the token, do a describe and construct query the record's Name
        Schema.DescribeSObjectResult dr = token.getDescribe();
        
        // Determine the sObject type for the current record
        String testObjectType = dr.getName();
        
        //#RQ-001478 getting Object label
        thisObjectLabel=dr.getLabel();
        
        // Return the sObject type
        return testObjectType;
    }
    
    
    
    
    /*
performSearch - method to perform the content search and update the relevant content lists
Inputs:
- String searchString - the search string on which the content should be searched
Returns: none
Actions:
- Update this.recordContentAll with all search results
- Update this.totalResults with full count of results
*/
    public void performSearch(String searchString,Boolean FirstDefaultSearch) {
        
        // Ensure we don't receive a null string
        if (searchString == null) {
            return; 
        }
        
        /*
Generate a list of keywords for the from the input searchString
Two key variables:
Set<String> keywordSearchSet - Set containing the keywords
String keywordsSearchString - String containing the keywords separated by OR for SOSL
*/
        
        // List of ignored keywords
        //#RQ-001478 Remove hard coding Not possible because text field in custom label and Custom setting can hold only 255 chars
        Set<String> stopWords = new Set<String>{'a','A','B','C','about', 'above', 'above', 'across', 'after', 'afterwards', 'again', 'against', 'all', 'almost', 'alone', 
            'along', 'already', 'also','although','always','am','among', 'amongst', 'amoungst', 'amount',  'an', 'and', 'another', 'any','anyhow','anyone',
            'anything','anyway', 'anywhere', 'are', 'around', 'as',  'at', 'And', 'back','be','became', 'because','become','becomes', 'becoming', 'been', 'before',
            'beforehand', 'behind', 'being', 'below', 'beside', 'besides', 'between', 'beyond', 'bill', 'both', 'bottom','but', 'by', 'call', 'can', 'cannot', 
            'cant', 'co', 'con', 'could', 'couldnt', 'cry', 'de', 'describe', 'detail', 'do', 'done', 'down', 'due', 'during', 'each', 'eg', 'eight', 'either', 
            'eleven','else', 'elsewhere', 'empty', 'enough', 'etc', 'even', 'ever', 'every', 'everyone', 'everything', 'everywhere', 'except', 'few', 'fifteen', 
            'fify', 'fill', 'find', 'fire', 'first', 'five', 'for', 'former', 'formerly', 'forty', 'found', 'four', 'from', 'front', 'full', 'further', 'get',
            'give', 'go', 'had', 'has', 'hasnt', 'have', 'he', 'hence', 'her', 'here', 'hereafter', 'hereby', 'herein', 'hereupon', 'hers', 'herself', 'him', 
            'himself', 'his', 'how', 'however', 'hundred', 'ie', 'if', 'in', 'inc', 'indeed', 'interest', 'into', 'is', 'it', 'its', 'itself', 'keep', 'last',
            'latter', 'latterly', 'least', 'less', 'ltd', 'made', 'many', 'may', 'me', 'meanwhile', 'might', 'mill', 'mine', 'more', 'moreover', 'most',
            'mostly', 'move', 'much', 'must', 'my', 'myself', 'name', 'namely', 'neither', 'never', 'nevertheless', 'next', 'nine', 'no', 'nobody', 'none', 
            'noone', 'nor', 'not', 'nothing', 'now', 'nowhere', 'of', 'off', 'often', 'on', 'once', 'one', 'only', 'onto', 'or', 'other', 'others', 'otherwise', 
            'our', 'ours', 'ourselves', 'out', 'over', 'own', 'OR', 'part', 'per', 'perhaps', 'please', 'put', 'rather', 're', 'same', 'see', 'seem', 'seemed', 'seeming',
            'seems', 'serious', 'several', 'she', 'should', 'show', 'side', 'since', 'sincere', 'six', 'sixty', 'so', 'some', 'somehow', 'someone', 'something',
            'sometime', 'sometimes', 'somewhere', 'still', 'such', 'system', 'take', 'ten', 'than', 'that', 'the', 'their', 'them', 'themselves', 'then', 'thence', 
            'there', 'thereafter', 'thereby', 'therefore', 'therein', 'thereupon', 'these', 'they', 'thickv', 'thin', 'third', 'this', 'those', 'though', 'three', 
            'through', 'throughout', 'thru', 'thus', 'to', 'together', 'too', 'top', 'toward', 'towards', 'twelve', 'twenty', 'two', 'un', 'under', 'until', 'up', 
            'upon', 'us', 'very', 'via', 'was', 'we', 'well', 'were', 'what', 'whatever', 'when', 'whence', 'whenever', 'where', 'whereafter', 'whereas', 'whereby',
            'wherein', 'whereupon', 'wherever', 'whether', 'which', 'while', 'whither', 'who', 'whoever', 'whole', 'whom', 'whose', 'why', 'will', 'with', 'within', 
            'without', 'would', 'yet', 'you', 'your', 'yours', 'yourself', 'yourselves', 'the'};
                
                String keywordSearchString = '';
        
        // ************* #RQ-001731  - Check if its first default search from record field values skip cleaning and removing special characters
        // so that we dont remove paranthesis added for multi-picklist vlaues
        
        if (FirstDefaultSearch == true) {
            keywordSearchString =  searchString;              
        }
        else{
            // Replace special characters with spaces
            //  spaces are used in place of removing the characters in case there is a string like "test-string")
            String cleanKeywords = searchString.replaceAll('[\\p{Punct}]',' ');
            
            // Put the space separated keywords into a List for manipulation
            List<String> workingKeywordList = new List<String>();
            workingKeywordList = cleanKeywords.split(' ');
            Set<String> keywordSearchSet = new Set<String>();
            
            // Add the keywords ot the Set and string skipping stop words and blanks
            for (String s : workingKeywordList) {
                
                if (!stopWords.contains(s) && !s.isWhiteSpace()) {
                    
                    keywordSearchSet.add(s.toLowerCase());
                    keywordSearchString += s + ' AND ';
                }
            }
            
            //#RQ-001478 :Strip the trailing ' AND '
            keywordSearchString = keywordSearchString.removeEnd(' AND ');
            
        }       
        
        // Clear the existing content list
        this.recordContentAll.clear();
        
        
        //#RQ-001478 Get the librabry Id's to be seach from CUstom setting.
        //RQ-004515 - Get the Library Id's based on the Button clicked
        
        String libraryIds='';
        for(Library_Related_To_Objects__c objLib : Library_Related_To_Objects__c.getall().values()){
            system.debug('objLib.Library_IDs__c'+objLib.Library_IDs__c);
            system.debug('thisObjectLabel.equalsIgnoreCase(objLib.Object_Name__c)'+thisObjectLabel.equalsIgnoreCase(objLib.Object_Name__c));
            system.debug('Label.Find_Content'+Label.Find_Content);
            system.debug('objLib.Find_Content_ID__c'+objLib.Find_Content_ID__c);
            system.debug('objLib.Object_Name__c'+objLib.Object_Name__c);
             system.debug('thisObjectLabel'+thisObjectLabel);
            if( thisObjectLabel.equalsIgnoreCase(objLib.Object_Name__c) && fcFlag==True && objLib.Find_Content_ID__c == Label.Find_Content){
                
                libraryIds += objLib.Library_IDs__c;
            }
            
            if( thisObjectLabel.equalsIgnoreCase(objLib.Object_Name__c) && fcFlag==False&& objLib.Find_Content_ID__c == Label.Val_Prop){
                
                libraryIds += objLib.Library_IDs__c;
            }
            
        }
        
        List<String> splitLibratyIds = new List<String>();
         system.debug('libraryIds'+libraryIds);
        if(libraryIds != null){
            
            splitLibratyIds=libraryIds.split(';');
        }
        
        // Peform the search
        
        List<ContentVersion> returnContent = new List<ContentVersion>();
        system.debug('splitLibratyIds'+splitLibratyIds);
        if (keywordSearchString.length() > 2) {
            system.debug('keywordSearchString++++++++++'+keywordSearchString);
            String contentQueryString = 'FIND :keywordSearchString IN ALL FIELDS';
            contentQueryString += ' RETURNING ContentVersion (Id, Title, FileType, PathOnClient, ContentSize, ContentDocumentId, ContentModifiedDate';
            contentQueryString += ', Internal_External__c, Description, TagCsv, PositiveRatingCount, NegativeRatingCount';
            contentQueryString += ' WHERE IsLatest = TRUE AND IsDeleted = FALSE ';
            contentQueryString += ' AND ContentDocument.ParentId in :splitLibratyIds'; //#RQ-001478: Adding librbaries to be searched
            contentQueryString += ')';
            contentQueryString += ' LIMIT ' + this.RESULTS_PER_PAGE;            
             system.debug('contentQueryString'+contentQueryString);
            List<List<ContentVersion>> rawContentList = new List<List<ContentVersion>>();
            
            try {
                
                rawContentList = search.query(contentQueryString);
                system.debug('rawContentList'+rawContentList);
            } 
            catch (DmlException e) { 
                
                System.debug(LoggingLevel.ERROR, e.getMessage()); 
                return; 
            }
            
            // Add any non-deleted content to the result list member variables
            for (ContentVersion c : rawContentList[0]) {
                
                // Add the content to the full result list
                this.recordContentAll.add( new ContentVersionContainer(c) );
            }
            
            // Set them member variable for the total number of results
            this.totalResults = this.recordContentAll.size();
        }
    }
    
    
    
    /*
updateSearch - method to update the Search results using the searchButton on the Visualforce page
Inputs: none, but references this.recordSearchString which is input by the Visualforce page
Returns:
- null PageReference (Visualforce re-renders pageBlock)
Actions:
- Performs a new search via performSearch()
*/
    public PageReference updateSearch() {
        
        // Perform the search with the current member variables which were updated by the Visualforce page
        performSearch(this.recordSearchString, false);
        
        // Return null to stay on the same page; Visualforce re-renders the list
        return null;
    }
    
    
    
    /*
cleanFileType - method to return a 3-4 character filetype for a known input ContentVersion.FileType string
Inputs:
- String inputFileTypeString - input string in format used by ContentVersion.FileType
- String inputFilename - input string in format used by ContentVersion.PathOnClient
Returns: 
- String outputFileTypeString - 3-4 character string for recognized file types
or lower case version of inputFileTypeString for unrecognized extensions
*/
    public static String cleanFileType(String inputFileTypeString, String inputFilename) {
        
        // Initialize the file type string to manipulate & output
        //  By default, if a match of FileType or file extension is not made,
        //  the lower case version of the FileType will be returned
        String outputFileTypeString = inputFileTypeString.toLowerCase();
        
        // Convert the inputFilename string to lower case
        if (inputFilename != null) {
            
            inputFilename = inputFilename.toLowerCase();
        }
        
        
        // Set the input/output file type string mappings
        //  Identical FileType to known file extensions (e.g. bmp => bmp) are not explicitly mapped
        //  since the output file type string will be passed through from the input file type string
        Map<String, String> knownFileTypes = new Map<String, String> {
            'jpeg' => 'jpg',
                'power_point' => 'ppt', 'power_point_m' => 'pptm', 'power_point_t' => 'potx', 'power_point_x' => 'pptx',
                'excel' => 'xls', 'excel_m' => 'xlsm', 'excel_t' => 'xltx', 'excel_x' => 'xlsx',
                'word' => 'doc', 'word_m' => 'docm', 'word_t' => 'dotx', 'word_x' => 'docx',
                'text' => 'txt', 'rfc822' => 'msg',
                'visio' => 'vsd',
                'flash' => 'swf'
                };
                    
                    
                    // Attempt to match the input file type string to a known value
                    //  If there isn't a known value, attempt to use a file extension
                    String knownFileTypeString = knownFileTypes.get(outputFileTypeString);
        if (knownFileTypeString != null) {
            
            outputFileTypeString = knownFileTypeString;
        }
        else {
            
            // Unknown FileType, use file extension if present
            if (inputFilename <> '' && inputFilename <> null) {
                
                if (inputFilename.indexOf('.') != -1) {
                    
                    outputFileTypeString = inputFilename.substring(inputFilename.indexOf('.') + 1);
                }
            }
        }
        
        return outputFileTypeString;
    }
    
    
    
    /*
getIconFilename - method to return the file name for a file type icon given a file type
that has been cleaned by cleanFileType()
Inputs:
- String inputFileTypeString - input string in format used by ContentVersion.FileType
Returns: 
- String iconFilename - name of the icon file
*/
    public static String getIconFilename(String inputFileTypeString) {
        
        // Set the fileType to icon file base name string mappings
        Map<String, String> knownFileTypes = new Map<String, String> {
            'pdf' => 'pdf',
                'jpg' => 'image', 'jpeg' => 'image', 'bmp' => 'image', 'gif' => 'image', 'png' => 'image',
                'pack' => 'pack',
                'ppt' => 'ppt', 'pptm' => 'ppt', 'potx' => 'ppt', 'pptx' => 'ppt', 'ppsx' => 'ppt',
                'xls' => 'excel', 'xlsm' => 'excel', 'xltx' => 'excel', 'xlsx' => 'excel',
                'csv' => 'csv',
                'doc' => 'word', 'docm' => 'word', 'dotx' => 'word', 'docx' => 'word',
                'rtf' => 'rtf', 'txt' => 'txt',
                'vsd' => 'visio',
                'swf' => 'flash', 'fla' => 'flash',
                'google_document' => 'gdoc', 'google_spreadsheet' => 'gsheet', 'google_presentation' => 'gpres',
                'link' => 'link', 'htm' => 'html', 'html' => 'html', 'xml' => 'xml',
                'ai' => 'illustrator', 'psd' => 'psd', 'eps' => 'eps',
                'exe' => 'exe', 'zip' => 'zip',
                'keynote' => 'keynote', 'key' => 'keynote',
                'mp4' => 'mp4', 'm4v' => 'video', 'wmv' => 'video', 'arf' => 'webex', 'wrf' => 'webex',
                'mp3' => 'audio', 'wav' => 'audio',
                'msg' => 'unknown'
                };
                    
                    
                    // Attempt to match the input file type string to a known value
                    String knownIconFileBase = knownFileTypes.get(inputFileTypeString);
        String iconFilename;
        if (knownIconFileBase != null) {
            
            iconFilename = knownIconFileBase + '.svg';
            
        } else {
            
            iconFilename = 'unknown.svg';
        }
        
        return iconFilename;
    }
    
    
    
    /*
contentAvailableCheck - method to determine if CRM Content is enabled for this user:
1) Ensure enabled for the Org via 
Setup | Salesforce CRM Content | Settings -> "Enable Salesforce CRM Content" is enabled
2) Ensure enabled for the User via "Salesforce CRM Content User" feature license
Inputs: none
Returns: 
- true - if CRM Content is available to the logged in user
- false - if CRM Content is note available to the logged in user
*/
    public static Boolean contentAvailableCheck() {
        
        // Initialize the return variable
        Boolean contentIsAvailable = false;
        
        // Determine if Content is enabled in the org by determining if the
        //  ContentWorkspace object is available
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SobjectType findContentWorkspace = gd.get('ContentWorkspace');
        
        if (findContentWorkspace != null) {
            
            // If the ContentWorkspace object is available, Content is enabled for the Org
            // Determine if Content is available to the logged in User
            User thisUser = [SELECT Id, UserPermissionsSFContentUser
                             FROM User u WHERE u.Id = :Userinfo.getUserId()
                             LIMIT 1];
            if (thisUser.UserPermissionsSFContentUser == true) {
                
                contentIsAvailable = true;
            } 
            else {
                
                contentIsAvailable = false;
            }
        } 
        else {
            // If the ContentWorkspace object is not available, Content is not enabled
            contentIsAvailable = false;
        }
        
        // Return the content availability
        return contentIsAvailable;
    }
    
    
    
    
    /*
*  #RQ-001478 - postFileToFeed -  method to post a piece of Content to an record's Chatter feed with optional comments
*               All files selected will be posted to the chatter as seperate feed  and redirected to Object detail view 
*/
    
    public PageReference postFilesToFeed() { 
        
       
        // Build the Feed post of type ContentPost referencing the existing Content
        List<FeedItem> feedItemsList= new List<FeedItem>(); //#RQ-001478 - Hold the list of feedItems to be insrted
        
        for(ContentVersionContainer c:recordContentAll){
            
            if(c.selected==true){ //Add only select files
                
                FeedItem contentPost = new FeedItem();
                if(attachementParentId==null )//RQ-009583 :- Mod-06 - For attaching files to the parent object.
                contentPost.ParentId = thisRecord.Id;
                    else 
                contentPost.ParentId = attachementParentId;//RQ-009583 :-  Mod-07 - For attaching files to the parent object.
                contentPost.Type = 'ContentPost';
                contentPost.RelatedRecordId = c.contentVersionSObject.Id; 
                
                if (commentBody != null && commentBody != '') {
                    
                    contentPost.Body = commentBody;
                }
                
                feedItemsList.add(contentPost);
            }
            
        }
        
        // Attempt to create the Feed post
        try {
            
            insert feedItemsList;
        }
        catch (DmlException e) {
            
            System.debug(LoggingLevel.ERROR, e.getMessage()); 
            return null; 
        }
                    this.recordContentAll.clear();
                    commentBody = null;
                    return (new ApexPages.StandardController(thisRecord)).view();
                
    }   
    
    
    
    
    
    /*
* #RQ-001478   Action on Back link to Record
*
*/
    public pagereference backToRecord(){
        
        return (new ApexPages.StandardController(thisRecord)).view();
    }
    
    
    
    /*
* #RQ-001478Getting Field Name out of  Field Set
*/
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {       
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        
        List<Schema.FieldSetMember> fieldSetMemberList =  new  List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> fieldSetMemberListAll =  new  List<Schema.FieldSetMember>();
        
        Schema.FieldSet fieldSetObj;  
        
        //To read the values for field set
        if(DescribeSObjectResultObj.FieldSets.getMap()!= null){
            fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        }
        if(fieldSetObj!=null){
            
            fieldSetMemberList=fieldSetObj.getFields();
        }
        fieldSetMemberListAll.addAll(fieldSetMemberList);
        
        return fieldSetMemberListAll; 
    }  
    
    
    
    /*
* #RQ-001478 Getting Fields Recursively
*/
    public static Object recursiveGet(sObject record, String field) {
        
        if(field.contains('.')) {
            
            Integer firstPeriod = field.indexOf('.');
            String nextObjectName = field.subString(0, firstPeriod);
            String remainingfieldName = field.subString(firstPeriod + 1, field.length());
            sObject nextObject = record.getSObject(nextObjectName);
            if(nextObject == null) {
                return null;
            } 
            else {
                
                return recursiveGet(nextObject, remainingfieldName);
            }
        } 
        else 
        {
            return record.get(field);   
        }
    }
}