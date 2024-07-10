/*              
 * Revision Ref Number  Date          Owner                   Description
 * -------- ----------  -----------   -----------------       -----------
 * 1.0      SFSE-11233  23-June-2023    Vinay				  Test class for OfferConfirmationPageController   
 * 2.0      SFSE-12098  25-August-2023  Aditi                 Added condition in SOQL to query only 'Active' OpportunityTeamMembers
*/
@istest
public class OfferConfirmationPageControllerTest {

    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        List<Contact> lstContacts = new list<Contact>();
        List<One_Click_Journey_Details__c> listJourneyDetails = new List<One_Click_Journey_Details__c>();
        
       User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.SEAGO, true);
		system.debug(adminUser.Id);
        Assert.isNotNull(adminUser.Id);
        
       User guestUser = TestBusinessHelper.createUser('offerconfirmationpage Profile',BrandUtilities.SEAGO,true);
	   	system.debug(guestUser.Id);
        Assert.isNotNull(guestUser.Id);
        
        Id guestprofileId = guestUser.profileId;
        Assert.isNotNull(guestprofileId);
        
        system.runAs(adminUser){
            TriggerExecutionController.skipAllTriggers(true);
            Test.startTest();  
            User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
            salesUser.Id=null;
            salesUser.CM_Visibility__c='Single Carrier';
            insert salesUser;
            
            Assert.isNotNull(salesUser.Id); 
            system.debug(salesUser.Username);
            
            Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
            Assert.isNotNull(clientAcc.Id);
            system.debug(clientAcc); 
            
            List<contact> contacts = TestBusinessHelper.createContacts(clientAcc, new List<String>{'Customer_Contact','Customer_Contact'}, BrandUtilities.MAERSKLINE, true);	            
            Assert.areEqual(contacts.Size(), 2);    
            Test.stopTest();
            
            Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAcc, null, adminUser, System.Label.OppShippingCargoRecordType, BrandUtilities.MAERSKLINE, true);  
            Assert.isNotNull(mslOppty.Id);
            
            OpportunityTeamMember opm = new OpportunityTeamMember(OpportunityId=mslOppty.Id,UserId=salesUser.Id,TeamMemberRole='Client Program Manager', OpportunityAccessLevel='Edit');
            insert opm;
            
            String cryptoKeyString = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
                                
        One_Click_Journey_Details__c mockRecord = new One_Click_Journey_Details__c(Secret_Key__c = cryptoKeyString, setUpOwnerId = adminUser.ProfileId);
        listJourneyDetails.add(mockRecord);
        One_Click_Journey_Details__c mockRecord1 = new One_Click_Journey_Details__c(Secret_Key__c = cryptoKeyString, setUpOwnerId = Label.TestClean_ProfileIdsSales);
        listJourneyDetails.add(mockRecord1);  
            One_Click_Journey_Details__c mockRecord2 = new One_Click_Journey_Details__c(Secret_Key__c = cryptoKeyString, setUpOwnerId = guestprofileId);
            listJourneyDetails.add(mockRecord2);
            insert listJourneyDetails;  
            Assert.areEqual(listJourneyDetails.Size(), 3);
            
            
        }// End of system run as adminUser
        
  }
    
    @istest
    static void updateRecordsAndNotifyTest(){
        
        List<Opportunity> oppty= [SELECT Id, Offer_Type__c,First_Shipment_Date__c,Last_Shipment_Date__c,AccountId,OwnerId,Opportunity_contains_Dangerous_Goods__c FROM Opportunity];
        Assert.areEqual(1, oppty.size());   
        system.debug('Goods--->'+oppty[0].Opportunity_contains_Dangerous_Goods__c);
        Id accountId = oppty[0].AccountId;
        Assert.isNotNull(accountId);
        
        List<Contact> listContacts =[SELECT Id,Email from Contact Where AccountId =:accountId];
        System.assertEquals(2, listContacts.size());
                
        Id salesProfileId;
        Id guestUserProfileId;
        for(Profile pf: [SELECT Id,Name FROM Profile WHERE Name='Sales' OR Name='offerconfirmationpage Profile']){
            if(pf.Name=='Sales'){
              salesProfileId = pf.Id;  
            }
            else{
            guestUserProfileId = pf.Id;    
            }
        }
        Assert.isNotNull(salesProfileId);
        Assert.isNotNull(guestUserProfileId);
        
        List<OpportunityTeamMember> optyTeam = [SELECT id, userId FROM OpportunityTeamMember WHERE OpportunityId=: oppty[0].Id AND user.profileId =: salesProfileId AND User.isActive = TRUE];
        Assert.areEqual(1, optyTeam.size());
        
        Id salesUserId = optyTeam[0].userId;
        List<String> encryptedDatalist = new List<String>();
        
        system.runAs(new user(Id = salesUserId)){
        Offer_Information__c offer = new Offer_Information__c();
        offer.Opportunity__c = oppty[0].Id;
        offer.Date_Sent__c = system.today();
        offer.Offer_Status__c = System.Label.Offer_Sent;
        offer.CC_Recipients__c ='test@testinvaliddomain.com, test1@testinvaliddomain.com';    
        insert offer;
            Assert.isNotNull(offer.Id);
            
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=offer.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';                 
        insert contentlink;
        
            String str = offer.Id+listContacts[0].Email;        
            Set<String> testData = new Set<String>{str};
                
            EncryptionAndDecryptionController controller = new EncryptionAndDecryptionController();
            Map<String, String> encryptedData = controller.encryptData(testData);            
            Assert.isNotNull(encryptedData);
            encryptedDatalist = encryptedData.values();
                        
        }// End of system run as SalesUsers
        
        User guestUsr = [SELECT Id FROM User WHERE profileId=:guestUserProfileId AND IsActive=TRUE LIMIT 1];
        
        system.runAs(guestUsr){          
            System.debug('Code executing'+encryptedDatalist);
            
            Test.startTest();
            	string str = OfferConfirmationPageController.updateRecordsAndNotify(encryptedDatalist[0]);
            	Assert.isNotNull(str);
            	string str1 = OfferConfirmationPageController.updateRecordsAndNotify(encryptedDatalist[0]);
            	Assert.isNotNull(str1);
            Test.stopTest();
        }
        
    }
    
    @istest
    static void updateRecordsAndNotifyTest1(){
        
        List<Opportunity> oppty= [SELECT Id, Offer_Type__c,First_Shipment_Date__c,Last_Shipment_Date__c,AccountId,OwnerId,Opportunity_contains_Dangerous_Goods__c FROM Opportunity];
        Assert.areEqual(1, oppty.size());   
        
        oppty[0].Opportunity_contains_Dangerous_Goods__c ='';
        update oppty;
        Assert.areEqual(oppty[0].Opportunity_contains_Dangerous_Goods__c,'');
        
        Id accountId = oppty[0].AccountId;
        Assert.isNotNull(accountId);
        
        List<Contact> listContacts =[SELECT Id,Email from Contact Where AccountId =:accountId];
        System.assertEquals(2, listContacts.size());
        
        Id salesProfileId;
        Id guestUserProfileId;
        for(Profile pf: [SELECT Id,Name FROM Profile WHERE Name='Sales' OR Name='offerconfirmationpage Profile']){
            if(pf.Name=='Sales'){
              salesProfileId = pf.Id;  
            }
            else{
            guestUserProfileId = pf.Id;    
            }
        }
        Assert.isNotNull(salesProfileId);
        Assert.isNotNull(guestUserProfileId);
        
        List<OpportunityTeamMember> optyTeam = [SELECT id, userId FROM OpportunityTeamMember WHERE OpportunityId=: oppty[0].Id AND user.profileId =: salesProfileId];
        Assert.areEqual(1, optyTeam.size());
        
        Id salesUserId = optyTeam[0].userId;
        List<String> encryptedDatalist = new List<String>();
        
        system.runAs(new user(Id = salesUserId)){
            Offer_Information__c offer = new Offer_Information__c();
            offer.Opportunity__c = oppty[0].Id;
            offer.Date_Sent__c = system.today();
            offer.Offer_Status__c = System.Label.Offer_Sent;
            offer.CC_Recipients__c ='test@testinvaliddomain.com, test1@testinvaliddomain.com';    
            insert offer;
            Assert.isNotNull(offer.Id);
            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=offer.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers';                 
            insert contentlink;
            
            String str = offer.Id+listContacts[0].Email;        
            Set<String> testData = new Set<String>{str};
                
            EncryptionAndDecryptionController controller = new EncryptionAndDecryptionController();
            Map<String, String> encryptedData = controller.encryptData(testData);            
            Assert.isNotNull(encryptedData);
            encryptedDatalist = encryptedData.values();
                        
        }// End of system run as SalesUsers
        
        User guestUsr = [SELECT Id FROM User WHERE profileId=:guestUserProfileId AND IsActive=TRUE LIMIT 1];
        
        system.runAs(guestUsr){          
            System.debug('Code executing'+encryptedDatalist);
            
            Test.startTest();
            	string str = OfferConfirmationPageController.updateRecordsAndNotify(encryptedDatalist[0]);
            	Assert.isNotNull(str);
            	string str1 = OfferConfirmationPageController.updateRecordsAndNotify(encryptedDatalist[0]);
            	Assert.isNotNull(str1);
            Test.stopTest();
        }
        
    }
    
}