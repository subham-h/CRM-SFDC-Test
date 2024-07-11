/* This class is used to find the similar opportunities based on the named account of a particular Opportunity.
* Created By: jagadeesan.sakthivel@ust-global.com
* Created On: 18/11/2013
* Version  Date         Owner                                    RQ#           Description
****************************************************************************************************************************************
* 1.0      13/11/2013   jagadeesan.sakthivel@ust-global.com                  Code created
* 2.0      18/11/2013   peter.aubrey@maersk.com                              Cleaned up code and changed method of updating NAC checkbox
* 3.0      01/08/2017   uvais.komath@ust-global.com           #RQ-005676     Deprecated Cluster Name, Introduced Cluster Code
* 4.0      06-Jun-2019  manjunath.c.holekade@maersk.com       #RQ-010819     Removal of references of deprecated fields
* 5.0      12-Apr-2021  Kiran@Maersk                          #SFSE-5787     Removal of Cluster_Code__c references
*/

public with sharing Class SimilarOpportunitiesCtrl{

        public Opportunity oppObj{ get; set; }
        public List<OppWitChkBox> similarDirOpps = new List<OppWitChkBox>();     //Wrapper list used for displaying direct named account opportunities
        public List<OppWitChkBox> similarFwdOpps = new List<OppWitChkBox>();     //Wrapper list used for displaying Forwarder named account opportunities
        public String chatterMsg{ get; set; }
        public integer recordCountIndirect{ get; set; }
        public integer recordCountDirect{ get; set; }
        
        // Wrapper class for showing duplicate opportunities with checkbox
        public Class OppWitChkBox{ 
            
            public boolean isSelected{ get; set; }
            public Opportunity opObj{ get; set; }
            
            public OppWitChkBox(boolean isSelected, Opportunity opObj){
                
                this.isSelected = isSelected;
                this.opObj = opObj;
                
            }
               
        }
        
        
        
        /**
        * Constructor...
        */
        public SimilarOpportunitiesCtrl( ApexPages.StandardController stdcontroller ){
        
            OppObj = (Opportunity)stdcontroller.getRecord();
            List<Account> accSibList = new List<Account>();
            Set<Id> sibAcctIdSet = new Set<Id>();
            recordCountIndirect = 0;
            recordCountDirect = 0;
            
            // Query for retrieving the details of Opportunity from which we are doing dupe check...
            if ( oppObj != null ){
                // #Safmarine_United - Added Liner_Brand__c to the query
                oppObj = [SELECT Id, Name, 
                                 OwnerId, Owner.Name, StageName, CloseDate, 
                                 AccountId, Account.Name, Account.ParentId,
                                 Named_Account__c, Named_Account__r.Name, Named_Account__r.ParentId,
                                 First_Shipment_Date__c, Last_Shipment_Date__c, NAC_Checked__c,Liner_Brand__c 
                          FROM Opportunity 
                          WHERE id =: oppObj.Id 
                          LIMIT 1];
                          
            }
            
            // Get the list of Opportunities...
            List<Opportunity> oppList = new List<Opportunity>();
            
            if ( oppObj != null ){
                
                Date foCloseDate = oppObj.CloseDate;
                Date foFirstShipDate = oppObj.First_Shipment_Date__c;
                Date foLastShipDate = oppObj.First_Shipment_Date__c;
                Date foQuoteExpiryLess15 = foCloseDate.addDays( -15 );
                Date foQuoteExpiryPlus15 = foCloseDate.addDays( 15 );
                Date foFirstShipmentLess90;
                
                if ( foFirstShipDate != null ){
                    
                    foFirstShipmentLess90 = foFirstShipDate.addDays( -90 );
                    
                } else {
                
                    foFirstShipmentLess90 = date.newinstance(2099, 12, 31);
                    foFirstShipDate = date.newinstance(2099, 12, 31);
                
                }

                if ( foLastShipDate == null ){
                    
                    foLastShipDate = date.newinstance(2099, 12, 31);
                    
                }
                
                
                
                // Create a set of the direct customer's sibling Accounts so we can check all customers that
                // have the same Parent, if there is no Parent then add the focus Opp's direct Account Id, 
                // also check the Accounts themselves are in the same cluster... (Deprecated V3.0)
                
                // Decide if we came from a direct or forwarder Opportunity, if the Named_Account__c field is not null
                // then it must be a forwarder Opportunity...
                if ( oppObj.Named_Account__c != null ){ 
                    
                    // Add the Named Account's Id so its always included in the results...
                    sibAcctIdSet.add( oppObj.Named_Account__c );
                    
                    accSibList = [SELECT Id, Name
                                  FROM Account 
                                  WHERE ParentId <> null 
                                  AND ParentId = :oppObj.Named_Account__r.ParentId                                 
                                  ];
                    
                    for ( Account acObj : accSibList ){
                    
                        sibAcctIdSet.add( acObj.id );
                    
                    }
                    
                } else {
                
                    // Add the Account's Id so its always included in the results...
                    sibAcctIdSet.add( oppObj.AccountId );
                    
                    accSibList = [SELECT id, name
                                  FROM Account 
                                  WHERE ParentId <> null 
                                  AND ( ParentId = :oppObj.Account.ParentId 
                                  )
                                  ];
                    
                    for( Account acObj : accSibList ){
                    
                        sibAcctIdSet.add(acObj.id); 
                    
                    }
                    
                }
                
                System.debug('----sibAcctIdSet---'+sibAcctIdSet);
                    
                // Query for retrieving the similar Opportunities...
                // #Safmarine_United - Added Liner_Brand__c to the query
                oppList = [SELECT Id, Named_Account__c, Named_Account__r.Name, AccountId, Account.Name, OwnerId, Owner.Name, First_Shipment_Date__c,
                           Type, Last_Shipment_Date__c, Cargo_type__c,Name, StageName, closeDate 
                           FROM Opportunity 
                           WHERE
                           ( IsWon = true OR IsClosed = false ) 

                           AND Liner_Brand__c =:oppObj.Liner_Brand__c AND (
                           
                           ( Named_Account__c in :sibAcctIdSet
                           AND (  
                           ( ( First_Shipment_Date__c != null OR Last_Shipment_Date__c != null ) AND Last_Shipment_Date__c >= :foFirstShipDate AND First_Shipment_Date__c <= :foLastShipDate )
                           OR ( ( First_Shipment_Date__c != null OR Last_Shipment_Date__c != null ) AND Last_Shipment_Date__c >= :foFirstShipmentLess90 ) 
                           OR ( ( First_Shipment_Date__c = null OR Last_Shipment_Date__c = null ) AND CloseDate >= :foQuoteExpiryLess15 AND CloseDate <= :foQuoteExpiryPlus15 ) ) )
                           
                           OR (
                           ( AccountId in :sibAcctIdSet
                           AND (  
                           ( ( First_Shipment_Date__c != null OR Last_Shipment_Date__c != null ) AND Last_Shipment_Date__c >= :foFirstShipDate AND First_Shipment_Date__c <= :foLastShipDate )
                           OR ( ( First_Shipment_Date__c != null OR Last_Shipment_Date__c != null ) AND Last_Shipment_Date__c >= :foFirstShipmentLess90 ) 
                           OR ( ( First_Shipment_Date__c = null OR Last_Shipment_Date__c = null ) AND CloseDate >= :foQuoteExpiryLess15 AND CloseDate <= :foQuoteExpiryPlus15 ) ) )
                           )
                           
                           )
                           
                           ORDER BY First_Shipment_Date__c
                           LIMIT 1000
                           ];
                
                // Now go through the list and add them either to the forwarder or direct lists...
                if ( oppList.Size() > 0 ){
                
                    for ( Opportunity opp : oppList ){
                    
                        if ( oppObj.Named_Account__c != null){
                        
                            if ( opp.Named_Account__c == oppObj.Named_Account__c || sibAcctIdSet.contains( opp.Named_Account__c ) ){ 
                                
                                similarFwdOpps.add( new OppWitChkBox( false, opp ) );
                            
                            }
                            
                            if ( opp.AccountId == oppObj.Named_Account__c || sibAcctIdSet.contains( opp.AccountId ) ){ 
                                
                                similarDirOpps.add( new OppWitChkBox( false, opp ) );
                            
                            }
                            
                        } else {
                        
                            if ( opp.Named_Account__c == oppObj.AccountId || sibAcctIdSet.contains( opp.Named_Account__c ) ){ 
                                
                                similarFwdOpps.add(new OppWitChkBox(false,opp));
                            
                            }
                            
                            if ( opp.AccountId == oppObj.AccountId || sibAcctIdSet.contains( opp.AccountId ) ){ 
                                
                                similarDirOpps.add( new OppWitChkBox( false, opp ) );
                            
                            }
                            
                        }
                        
                    }
                    
                    recordCountDirect = similarDirOpps.Size();
                    recordCountIndirect = similarFwdOpps.Size();
                    
                }
             
            }
            
        }
        
        
        
        /**
        * Method to set the NAC Check flag to true so we can unerstand if this page is being used...
        */
        public void namedAccountCheckToTrue(){ 
            
            if ( oppObj.NAC_Checked__c ){
            
                oppObj.NAC_Checked__c = True;
                update oppObj;
            
            }
            
        }
        
        
        
        /**
        * Method to return to Opportunity detail page...
        */
        public pageReference BackToOpportunityClick(){ 
            
            PageReference oppPage = new PageReference( '/'+ oppObj.Id );
            oppPage.setRedirect( true );
            return oppPage;
            
        } 
        
        
        
        /**
        * Method for posting the chatter message on the selected oportunity owner's user chatter page...
        */
        public void sendChatterPost(){ 
        
            if ( chatterMsg != '' ){
            
                List<Opportunity> chatterPostOpList = new List<Opportunity>();
                
                // For all of the direct Opps that are checked...
                for ( OppWitChkBox opsWitChkbBxObj : similarDirOpps ){
                    
                    if ( opsWitChkbBxObj.isSelected == true ){
                    
                        chatterPostOpList.add( opsWitChkbBxObj.opObj );
                    
                    }
                }
                
                // For all of the forwarder Opps that are checked...
                for ( OppWitChkBox opsWitChkbBxObj : similarFwdOpps ){

                    if (opsWitChkbBxObj.isSelected == true){

                        chatterPostOpList.add( opsWitChkbBxObj.opObj );

                    }

                }
                
                // Now post to the Opportunity Owner's feed just in case they aren't following the Opportunity...
                if ( chatterPostOpList.Size() > 0 ){
                    
                    List<FeedItem> posts = new List<FeedItem> ();
                    
                    for ( Opportunity opp : chatterPostOpList ){
                        
                        FeedItem post = new FeedItem();
                        post.ParentId = opp.OwnerId;
                        post.Body = chatterMsg + '\n';
                        post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
                        post.Title = 'Opportunity: ' + opp.name;
                        posts.add( post );
                        
                    }
                    
                    try {
                        
                        Database.SaveResult[] sr = Database.insert(posts, false);
                        
                        // Iterate through each returned result
                        for ( Database.SaveResult results : sr ) {
                            
                            if ( results.isSuccess() ) {
                                
                                ApexPages.Message msg = new ApexPages.Message( ApexPages.Severity.CONFIRM, System.Label.SimilarOppsChatterPostSuccess );
                                ApexPages.addMessage( msg );
                            
                            }
                            
                        }
                        
                    } catch ( exception e ) {

                        System.debug( e );
                    
                    }
                    
                } else {
                
                    ApexPages.Message msg = new ApexPages.Message( ApexPages.Severity.FATAL, System.Label.SimilarOppsNoRowsSelected );
                    ApexPages.addMessage( msg );
                    
                }
                
            } else {
                
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.SimilarOppsNoChatterMsg );
                ApexPages.addMessage(msg);
            
            }
            
        }
        
        
        
        /**
        * Getters and setters...
        */
        public List<OppWitChkBox> getsimilarDirOpps(){
            return similarDirOpps;
        }
        
        public Void setsimilarDirOpps(List<OppWitChkBox> similarDirOpps){
            this.similarDirOpps = similarDirOpps;
        }
        
        public List<OppWitChkBox> getsimilarFwdOpps(){
            return similarFwdOpps;
        }
        
        public Void setsimilarFwdOpps(List<OppWitChkBox> similarFwdOpps){
            this.similarFwdOpps = similarFwdOpps;
        }

        
        
    }