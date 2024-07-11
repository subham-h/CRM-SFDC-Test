public class lwcCMDNSPContactCreateCtrl {
    
    public class responsewrap {
        public string status;
        public string description;
        public string contid;
    }

    @AuraEnabled
    public static string createNSPContact(String jsonString) {
        try {
            string detailRes;
            
            // Deserialize JSON string into Map<String, Object>
            Map<String, Object> contactMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

            // Create a new Contact using the data from the payload
            Contact newContact = new Contact();

            // Iterate through the fields and set them dynamically
            for (String fieldName : contactMap.keySet()) {
                Object value = contactMap.get(fieldName);

                // Only set non-null values
                if (value != null && fieldName != 'sobjectType') {
                    newContact.put(fieldName, value);
                }
            }

            // Insert the new Contact
            insert newContact; 

            // Print the Contact object to the debug log
            responsewrap reswrap = new responsewrap();
            reswrap.status = 'success';
            reswrap.description = 'Contact successfully created';
            reswrap.contid = newContact.id;
            detailres = JSON.serialize(reswrap);

            return detailres;
        } catch (Exception e) {
            // Handle any exceptions or log errors
            System.debug('Error creating Contact: ' + e.getMessage());
            responsewrap reswrap = new responsewrap();
            reswrap.status = 'error';
            reswrap.description = e.getMessage();
            string errRes = JSON.serialize(reswrap);
            return errRes;
        }
    }
}