/**
  * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Rev   Name                       Date                Comments
 * 1.     Bharti Rana                16/06/2023          Code Created to encrypt and decrypt the Offer sending in I agree.
 
**/
public class EncryptionAndDecryptionController {
    
    //Method to encrypt the data
    public  Map<string,String> encryptData(Set<String> dataToEncrypt){
        Blob key1;
        Map<String,String> MapofferIdAndMailAddress = new Map<String,String>();
        
        //Encryption Key is stored in Heirarchy Custom Setting - One_Click_Journey_Details__c
        One_Click_Journey_Details__c  one = One_Click_Journey_Details__c.getInstance(userinfo.getProfileId());
        if(one.Secret_Key__c != null){
        	key1 =EncodingUtil.base64Decode(one.Secret_Key__c);
        }
        
        if(key1 != null){
        	for(String st: dataToEncrypt){
            Blob data = blob.valueOf(st);
            String encryptedData = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256',key1, data));
           	//Map to store the OfferId + mail combination as key and its encrypted data as value 
            MapofferIdAndMailAddress.put(st,encryptedData); 
        	}
        }       
        return MapofferIdAndMailAddress;                
    }
    
    //Method to decrypt the data
    public string decryptData(String dataToDecrypt){
        Blob key;
        Blob decryptData;
        String decryptedDataString;
        //Decryption Key is stored in Heirarchy Custom Setting - One_Click_Journey_Details__c
         One_Click_Journey_Details__c  one = One_Click_Journey_Details__c.getInstance(userinfo.getProfileId());
        if(one.Secret_Key__c != null){
           key = EncodingUtil.base64Decode(one.Secret_Key__c);
         }
        Blob decodedData = EncodingUtil.base64Decode(dataToDecrypt);
        
        if(key!=NULL){
        decryptData = Crypto.decryptWithManagedIV('AES256', key, decodedData);
        decryptedDataString = decryptData.toString();
        }
        return decryptedDataString;      
    }

}