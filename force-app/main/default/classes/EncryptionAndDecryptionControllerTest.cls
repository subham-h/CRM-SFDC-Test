/**
  * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Rev   Name                       Date                Comments
 * 1     Bharti Rana                19/06/2023           Test class for EncrpytionAndDecryptionController class
 
**/
@IsTest
public class EncryptionAndDecryptionControllerTest {
    @IsTest
    public static void testEncryptData() {
        // Create test data
        Set<String> testData = new Set<String>{'data1', 'data2', 'data3'};
         Blob cryptoKey = Crypto.generateAesKey(256); 
        
        String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
        UserDataGeneratorHelper_Test.initializeSystemAdminUser();
      
        User adminUser = UserDataGeneratorHelper_Test.systemAdminUser;
       
        // Create a mock record for One_Click_Journey_Details__c with the valid key
        One_Click_Journey_Details__c mockRecord = new One_Click_Journey_Details__c(Secret_Key__c = cryptoKeyString, setUpOwnerId = adminUser.ProfileId);
        insert mockRecord;
        
        // Set the mock user context
        System.runAs(adminUser) {
            One_Click_Journey_Details__c.getInstance(adminUser.ProfileId);
            System.debug('coming value' + One_Click_Journey_Details__c.getInstance(adminUser.ProfileId));
            // Create an instance of the controller
            EncryptionAndDecryptionController controller = new EncryptionAndDecryptionController();
            
            // Call the encryptData method
            Map<String, String> encryptedData = controller.encryptData(testData);
            
            List<String> val = encryptedData.values();
            String first = val[0];
            
            controller.decryptData(first);
            
            // Verify the results
            System.assertEquals(testData.size(), encryptedData.size());
            for (String key : testData) {
                System.assertNotEquals(null, encryptedData.get(key));
            }
        }
    }
    
    
}