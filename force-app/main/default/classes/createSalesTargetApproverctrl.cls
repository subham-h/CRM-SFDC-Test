public class createSalesTargetApproverctrl {
    
    @AuraEnabled(cacheable=true)
    public static areawrapper getBDARecords(string bdaId){
        BDA__c bdaname = [SELECT Id, Name from BDA__c WHERE Id =:bdaId];
        areawrapper aw = new areawrapper();
        aw.areaname = bdaname.Name;
        aw.areaid = bdaname.Id;
        return aw;
    }
    
    @AuraEnabled
    public static List<Target_Reviewer__c> getRecordsByStage(String stagename, string targetId) {   
        List<Target_Reviewer__c> trlst = [SELECT Id FROM Target_Reviewer__c WHERE 
                                          Target_Approval_Matrix__r.Target_Stage__c =: stagename AND Target_Approval_Matrix__r.Target__c =: targetId];
        return trlst;
    }
    
    @AuraEnabled
    public static Boolean chkifuserAdded(Id tId, Id uId,String step, String areaid, String salesChnel, String vertical, String regionid){
        Boolean existingReviewer = false;
        Map<String,String> mapStepStage = new Map<String,String>();
        mapStepStage.put('1','Level 1 creator - Area Commercial FBP');
        mapStepStage.put('3','Level 1 approver - Area Head of Sales Channel Verticalized');
        mapStepStage.put('4','Level 2 approver - Area Head of Sales Channel');
        mapStepStage.put('5','Level 3 approver - Area Sales Head');
        mapStepStage.put('6','Level 4 approver - Regional Sales Excellence');
        mapStepStage.put('7','Level 5 approver - Central Sales Channel Head');
        mapStepStage.put('8','Level 6 approver - Chief Commercial Officer');
        
        Set<Id> uIds = new Set<Id>();
        string query = 'SELECT Id, Name, Related_User__c,Target_Approval_Matrix__r.Area__c,Target_Approval_Matrix__r.Sales_Channel__c,Target_Approval_Matrix__r.Vertical__c,Target_Approval_Matrix__r.Region__c,Target_Stage__c from Target_Reviewer__c where Target_Approval_Matrix__r.Target__c =:tid';
        if(step == '1'){
        	query += 'AND Area__c =:areaid';
        }
        else if(step == '3'){
            query += 'AND Area__c =:areaid AND Sales_Channel__c =:salesChnel AND Vertical__c =:vertical';
        }
        else if(step == '4'){
            query += 'AND Area__c =:areaid AND Sales_Channel__c =:salesChnel';
        }
        else if(step == '5'){
            query += 'AND Area__c =:areaid';
        }
        else if(step == '6'){
            query += 'AND Region__c = :regionid';
        }
        else if(step == '7'){
            query += ' AND Sales_Channel__c =:salesChnel';
        }
        else if(step == '8'){
            query += ' AND Related_User__c =:uId';
        }
        List<Target_Reviewer__c> lstReviewer = Database.query(query);
        for(Target_Reviewer__c tr : lstReviewer){
            if(mapStepStage.get(step) == tr.Target_Approval_Matrix__r.Target_Stage__c){
            	existingReviewer = true;	
            }
        }
        return existingReviewer;
    }
    
    @AuraEnabled
    public static void deleteRecord(String trId , String tsmId){
         system.debug('@@@@ ' + trId);
         system.debug('@@@@ ' + tsmId);
        List<Target_Reviewer__c> trilst = new List<Target_Reviewer__c>();
        List<Target_Stage_Matrix__c> tslst = new List<Target_Stage_Matrix__c>();
        List<Target_Reviewer__c> trlst = [SELECT Id FROM Target_Reviewer__c WHERE Target_Approval_Matrix__c =: tsmId];
        system.debug('@@@@ ' + trlst);
        if(trlst.size() > 0 && trlst.size() == 1){
            Target_Stage_Matrix__c ts = new Target_Stage_Matrix__c();
            ts.Id = tsmId;
            tslst.add(ts);
        }else{
            Target_Reviewer__c tri = new Target_Reviewer__c();
            tri.Id = trId;
            trilst.add(tri);
        }
        system.debug('@@@@ ' + trilst);
        try{
            if(tslst.size() > 0) {
                delete tslst;
            }
            if(trilst.size() > 0){
             delete trilst;   
            }
        }catch(exception e) {
            system.debug('@@@@ ' + e);
        }
    }
    
    @AuraEnabled
    public static String updateTargetStageToComplete (String tId) {
    String status = '';
    List<Target_Reviewer__c>  lsttrsize = [select Id, Related_User__r.Name, Target_Approval_Matrix__r.Target__r.Stage_Status__c, Target_Approval_Matrix__r.Target_Stage__c from Target_Reviewer__c where Target_Approval_Matrix__c 
             IN (Select Id from Target_Stage_Matrix__c where Target__c =: tId)];
        system.debug('@@@@ ' + lsttrsize.size());
        if(lsttrsize.size() > 0){
            Target__c ta = new Target__c();
            ta.Id = tId;
            ta.Stage_Status__c = 'Completed';
            update ta;
            status = 'success';
        }else{
           status = 'failed'; 
        }
        return status; 
    }
    
    @AuraEnabled
    public static List<targetwrapper> getAllRecords (String tId) {
        system.debug('@@@@ ' + tId);
        List<targetwrapper> trwlst = new List<targetwrapper>();
        for(Target_Reviewer__c tr : [select Id, Target_Approval_Matrix__r.Region__r.Name, Target_Approval_Matrix__r.Region__c, Target_Approval_Matrix__r.Sales_Channel__c,  Target_Approval_Matrix__r.Vertical__c, Target_Approval_Matrix__r.Area__c,Target_Approval_Matrix__r.Target_Stage__c , Target_Approval_Matrix__r.Area__r.Name, Related_User__c from Target_Reviewer__c 
                                     WHERE  Target_Approval_Matrix__r.Target__c =:tid]) {
          system.debug('@@@@ ' + tr);
                                         targetwrapper trw = new targetwrapper();
                                         if(tr.Target_Approval_Matrix__r.Area__c !=null) {
                                             trw.areaid = tr.Target_Approval_Matrix__r.Area__c; 
                                             trw.areaname = tr.Target_Approval_Matrix__r.Area__r.Name;
                                         }
                                         if(tr.Target_Approval_Matrix__r.Region__c !=null) {
                                             trw.areaid = tr.Target_Approval_Matrix__r.Region__c;
                                             trw.areaname = tr.Target_Approval_Matrix__r.Region__r.Name;
                                         }
                                         trw.userid = tr.Related_User__c;
                                         trw.trid = tr.Id;
                                         trw.tsmid = tr.Target_Approval_Matrix__c;
                                         trw.stage = tr.Target_Approval_Matrix__r.Target_Stage__c;
                                         trw.saleschannel = tr.Target_Approval_Matrix__r.Sales_Channel__c;
                                         trw.verticalname = tr.Target_Approval_Matrix__r.Vertical__c;
                                         trwlst.add(trw);
                                     }
        return trwlst;
    }
    
    @AuraEnabled()
    public static targetwrapper saveRecords(List<Target_Reviewer__c> trlst, List<Target_Stage_Matrix__c> tsmlst, Map<String, List<string>> mapofAreaNametoUserId, List<wrappertest> wraplst){
        system.debug(mapofAreaNametoUserId);
        system.debug(trlst);
        system.debug(tsmlst);
        system.debug(wraplst);
        String status;
        List<Target_Stage_Matrix__c> lsttoInsert = new List<Target_Stage_Matrix__c>();
        Map<String, Target_Stage_Matrix__c> mapSObj = new Map<String, Target_Stage_Matrix__c>();
        Map<Id, List<Target_Stage_Matrix__c>> mapSObjlst = new Map<Id, List<Target_Stage_Matrix__c>>();
        if(tsmlst.size() > 0) {
            for(Target_Stage_Matrix__c tsold : tsmlst){
                List<Target_Stage_Matrix__c> l = mapSObjlst.get(tsold.Id);
                if (l == null) {
                    l = new List<Target_Stage_Matrix__c>();
                    mapSObjlst.put(tsold.Id, l);
                }
                l.add(tsold);
            }
            system.debug(mapSObjlst);
            for( ID iID : mapSObjlst.keySet() ) {
                system.debug(iID);
                for( Target_Stage_Matrix__c stmID : mapSObjlst.get( iID ) ) {
                    lsttoInsert.add(stmID);
                    if(stmID.Id == null) {
					   if(stmID.Area__c == null && stmID.Region__c ==null) {
                            mapSObj.put(stmID.Sales_Channel__c, stmID);   
                        }else if(stmID.Region__c == null && stmID.Sales_Channel__c ==null){
                            mapSObj.put(stmID.Area__c, stmID);
                        }else if(stmID.Area__c == null && stmID.Sales_Channel__c == null){
                            mapSObj.put(stmID.Region__c, stmID);   
                        }else {
                            mapSObj.put(stmID.Area__c+stmID.Sales_Channel__c+stmID.Vertical__c, stmID);
                        }  
                    }else{
                        mapSObj.put(stmID.Id, stmID);
                    }
                }
            }
            system.debug(lsttoInsert);
            system.debug(mapSObj);
        Map<String, Id> areatotsm = new Map<String, Id>();
        targetwrapper trw = new targetwrapper();
        try{
            List<Target_Reviewer__c> trlstInsert = new List<Target_Reviewer__c>();
            List<SObject> listUpsert = new List<SObject>();
            Database.upsert(mapSObj.values(), false);
            
            for(Target_Stage_Matrix__c tsm :mapSObj.values()) {
                system.debug('@@@@ ' + tsm);
                    if(mapofAreaNametoUserId.get(tsm.Area__c+tsm.Sales_Channel__c+tsm.Vertical__c) !=null){
                      areatotsm.put(tsm.Area__c+tsm.Sales_Channel__c+tsm.Vertical__c, tsm.Id);  
                    }else if(mapofAreaNametoUserId.get(tsm.Area__c+tsm.Sales_Channel__c) !=null) {
                        areatotsm.put(tsm.Area__c+tsm.Sales_Channel__c, tsm.Id);
                        system.debug('@@@@ ' + areatotsm);
                    }else if(mapofAreaNametoUserId.get(tsm.Area__c) !=null) {
                        areatotsm.put(tsm.Area__c, tsm.Id);
                        system.debug('@@@@ ' + areatotsm);
                    }else if (mapofAreaNametoUserId.get(tsm.Sales_Channel__c) !=null){
                        areatotsm.put(tsm.Sales_Channel__c, tsm.Id);  
                        system.debug('@@@@ ' + areatotsm);
                    }else if (mapofAreaNametoUserId.get(tsm.Region__c) !=null){
                        areatotsm.put(tsm.Region__c, tsm.Id);  
                        system.debug('@@@@ ' + areatotsm);
                }else{
                   areatotsm.put('stepseven', tsm.Id);  
                }
            }
                system.debug('$$$$$$' + areatotsm);
            Target_Reviewer__c eachReviewer;
            
            for (wrappertest s : wraplst) {
                eachReviewer = new Target_Reviewer__c();
                eachReviewer.Target_Approval_Matrix__c = areatotsm.get(s.areaid);
                eachReviewer.Related_User__c = s.childusrId;
                if(s.childrecId !=null){
                    eachReviewer.Id = s.childrecId;
                }
                trlstInsert.add(eachReviewer);   
            }
            system.debug('@@@@ ' + trlstInsert);
             Database.upsert(trlstInsert);
            
            trw.targetReviewerId = trlstInsert;
            trw.targetMatrixId = tsmlst;
            trw.status = 'success';
        }catch(exception e){
            system.debug('@@@@ ' + e);
            trw.status = 'failed';
        } 
        return trw;
        }else{
            targetwrapper trw = new targetwrapper();
            trw.status = 'success';
         	return trw;   
        } 
    }
    
    public class areawrapper {
        @AuraEnabled
        public string areaname{get;set;}
		@AuraEnabled
        public string areaid{get;set;}
    }
    
    public class wrappertest {
        @AuraEnabled
        public string areaid{get;set;}
        @AuraEnabled
        public string childusrId{get;set;}
        @AuraEnabled
        public string childrecId{get;set;}
    }
    
    public class targetwrapper {
        @AuraEnabled
        public List<Target_Reviewer__c> targetReviewerId{get;set;}
        @AuraEnabled
        public List<Target_Stage_Matrix__c> targetMatrixId{get;set;}
        @AuraEnabled
        public string status{get;set;}
        @AuraEnabled
        public string areaname{get;set;}
        @AuraEnabled
        public string areaid{get;set;}
        @AuraEnabled
        public string userid{get;set;}
        @AuraEnabled
        public string trid{get;set;}
        @AuraEnabled
        public string tsmid{get;set;}
        @AuraEnabled
        public string stage{get;set;}
        @AuraEnabled
        public string saleschannel{get;set;}
        @AuraEnabled
        public string verticalname{get;set;}
        @AuraEnabled
        public string Id{get;set;}
        
        public targetwrapper() {
            targetReviewerId = new List<Target_Reviewer__c>();
            targetMatrixId = new List<Target_Stage_Matrix__c>();
        }
    }
}