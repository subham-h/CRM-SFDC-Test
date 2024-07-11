public class Sales_ChatBotController {
    
public class FAQSearchInput{
       @InvocableVariable(required=true)
       public String sKeyword;
   }

   /** Outputs */
   public class FAQSearchOutput{
       @InvocableVariable(required=true)
       public ArticleSummaryWrapper sFAQSearchResult;
   }
 
   /** Invocable Method */
   @InvocableMethod(label='getFAQ' description = 'searchknowledge')
   public static List<List<FAQSearchOutput>> getFAQ(List<FAQSearchInput> faqSearchInput)
   {
       List<Knowledge__kav > lstknowArt = new List<Knowledge__kav >();
       //String sArticleBaseUrl = getCommunityArticleBaseUrl();
       String sKeyword = faqSearchInput[0].sKeyword;
       system.debug('sKeyword'+sKeyword);
       // Build the SOSL query
       String sQuery = 'FIND \'' + sKeyword + 
         '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, Title, UrlName,Summary WHERE PublishStatus = \'Online\' AND Language = \'en_US\') WITH DATA CATEGORY Type__c AT OIPC__c LIMIT 3';
       // Perform the SOSL search
       Search.SearchResults searchResults = Search.find(sQuery);
		system.debug('searchResults'+searchResults);
       // Use search results to get the list of articles
       List<Search.SearchResult> articlelist = searchResults.get('KnowledgeArticleVersion');
       system.debug('articlelist'+articlelist);
       List<FAQSearchOutput> faqSearchOutputs = new List<FAQSearchOutput>();

       // Loop through all the articles to get article info
       for (Search.SearchResult searchResult : articlelist)
       {
           KnowledgeArticleVersion article = (KnowledgeArticleVersion) searchResult.getSObject();

           System.debug(article);
           
           ArticleSummaryWrapper sFAQSearchResult = summarizeArticleForBot(article);          

            // Build the output structure containing the results            
            FAQSearchOutput faqSearchOutput = new FAQSearchOutput();
            faqSearchOutput.sFAQSearchResult = sFAQSearchResult;
            faqSearchOutputs.add(faqSearchOutput);
            
       }

       List<List<FAQSearchOutput>> returnResult = new List<List<FAQSearchOutput>>();
       returnResult.add(faqSearchOutputs);
       return returnResult;     
   }   

   public static ArticleSummaryWrapper summarizeArticleForBot(KnowledgeArticleVersion article)
   {
        ArticleSummaryWrapper sSummary = new ArticleSummaryWrapper();
       
       sSummary.Title = article.Title;
       sSummary.Summary = article.Summary;
       sSummary.UrlName = article.UrlName;

       return sSummary;
   }   

   public Class ArticleSummaryWrapper{
        @AuraEnabled public String Title {get;set;}
        @AuraEnabled public String Summary {get;set;}
        @AuraEnabled public String UrlName {get;set;}
    }

   

}