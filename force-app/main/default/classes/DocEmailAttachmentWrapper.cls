/*
Description  : Wrapper class to handle response of Docbrokerid API

* version    Ref Number     Date               Owner                              Description
*******************************************************************************************************************
* 1.0        SC-6596       07/02/2023         sunil.bs@maersk.com                 Wrapper class to handle response of Docbrokerid API
*-------------------------------------------------------------------------------------------------------------------
*/
global class DocEmailAttachmentWrapper {
   
	global class DocBrokerId implements Comparable {
        
		public String tpdoc_no;
		public String instanceId;
		public String fk_transport_doc_version;
		public String docbroker_unique_id;
		public String fk_documentType;
		public String documentType;
		public String documentGroup;
		public String doc_broker_framework_name;
		public String fk_operatorOwner;
		public String scv_custno_recipient;
		public String is_verify_copy;
		public String createTime;
		public String createUser;
		public String updateTime;
		public String updateUser;
		public String is_certified_true_copy;
		public String is_original_tpdoc;
        
        // Constructor
        /*
        public DocBrokerId(string createTime){
        createTime = createTime; 
   		 }*/
        
        //Implement the compareTo() method
        global Integer compareTo(Object compareTo) {
        DocBrokerId compareToEmp = (DocBrokerId)compareTo;
        if (createTime == compareToEmp.createTime) return 0;
        if (createTime > compareToEmp.createTime) return -1;
        return 1;        
   		 }
	}

	public List<DocBrokerId> docBrokerId;

	/*
	public static DocEmailAttachmentWrapper parse(String json) {
		return (DocEmailAttachmentWrapper) System.JSON.deserialize(json, DocEmailAttachmentWrapper.class);
	}*/
    
    
 
}