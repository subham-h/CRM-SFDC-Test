public class RichTextCapture {    
    public String inputText{get;set;}
    public String template { get; set; }
    public List<EmailMessage> email = new List<EmailMessage>();
    public List<EmailMessage> draftEmail = new List<EmailMessage>();
    public List<EmailTemplate> emailTemplate;
    public String htmlString = '';
    public RichTextCapture() {
        // Retrieve the page parameters from the URL
        //  try{
        template = ApexPages.currentPage().getParameters().get('templateid');
        if(template != Null){
            emailTemplate = [SELECT Id, DeveloperName, HtmlValue, Subject, Body FROM EmailTemplate WHERE Id = :template];            
            inputText = emailTemplate[0].HtmlValue;  
        }
    }  
    
}