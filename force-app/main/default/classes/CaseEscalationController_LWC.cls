public without sharing class CaseEscalationController_LWC {
    @AuraEnabled
    public static String escalateCs(String recId, String reason, String typeofEscalation, String deflevel, Boolean custBasedEsc){
        system.debug('+++++'+recId+reason+typeofEscalation+deflevel);
        Map<string, DEFCON_Ranking__c> defconrankmap = DEFCON_Ranking__c.getAll();
        List<Case> cslst = [Select Id, Defcon_Level__c, isEscalated, OwnerId from case where id  = :recId];
        Boolean oldEscalatedVal;
        String olddefconval;
        if(!cslst.isEmpty()){
            oldEscalatedVal = cslst[0].isEscalated;
            olddefconval = cslst[0].Defcon_Level__c;
        }
        String message = '';
        Boolean defconassigned = false;
        Case cs = new Case(Id = recId);
        
        if(typeofEscalation == 'handoff'){
            cs.HandOff_Cases__c = true;
        }else{
            if(deflevel != null && deflevel != ''){
                if(olddefconval == null || (defconrankmap != null && defconrankmap.containsKey(deflevel) && defconrankmap.containsKey(olddefconval) && defconrankmap.get(deflevel).Rank__c > defconrankmap.get(olddefconval).Rank__c)){
                    cs.Defcon_Level__c = deflevel;
                }
                if(cs.Defcon_Level__c != '5'){
                    cs.isEscalated = true;
                }
                
            }else{
                List<User> usrinfo = [Select Id, Level__c, Service_Level__c, Profile.name from User where id = :UserInfo.getUserId()];
                if(!usrinfo.isEmpty()){
                    for(DEFCON_User_Mapping__c dum: DEFCON_User_Mapping__c.getAll().values()){
                        System.debug(dum);
                        if((dum.Level__c != null && usrinfo[0].Level__c != null && dum.Level__c.contains(usrinfo[0].Level__c)) || (dum.Profile_Name__c != null && dum.Profile_Name__c.contains(usrinfo[0].Profile.Name))){
                            if(olddefconval == null || (defconrankmap != null && defconrankmap.containsKey(dum.name) && defconrankmap.containsKey(olddefconval) && defconrankmap.get(dum.name).Rank__c > defconrankmap.get(olddefconval).Rank__c)){
                                cs.Defcon_Level__c = dum.name;
                            }
                            defconassigned = true;
                        }
                        
                        if(defconassigned){
                            if(cs.Defcon_Level__c != '5'){
                                cs.isEscalated = true;
                            }
                            break;
                        }
                    }
                }
            }
            
        }
        try{
            if(custBasedEsc != null){
                cs.Escalation_on_behalf_of_Customer__c = custBasedEsc;
            }
            cs.Escalation_reason__c = reason;
            System.debug(cs.isEscalated);
            System.debug(cs.Escalation_reason__c);
            
            if(!cslst.isEmpty() && !oldEscalatedVal){
                cs.Escalated_By__c = UserInfo.getUserId();
                List<User> usrlst = [Select Id, Name, ManagerId from User where Id = :cslst[0].OwnerId];
                cs.Escalation_Owner__c = !usrlst.isEmpty() && usrlst[0].ManagerId != null ? usrlst[0].ManagerId: !usrlst.isEmpty() ? usrlst[0].Id : null;
                cs.Escalation_Stage__c = 'Open';
                cs.Escalation_Start_Time__c = System.now();
            }
            update cs;
            createFeedItem(recId, 'Customer Escalation reason: ' + reason);
            message = 'Success';
        }catch(Exception ex){
            message = '' + ex;
        }
        return message;
    }
    @AuraEnabled
    public static String caseHandoff(String recId, String reason){
        Case cs = new Case(Id = recId);
        String message = '';
        try{
            cs.HandOff_Cases__c = true;
            cs.Case_Escalation_Reason__c = reason;
            update cs;
            createFeedItem(recId, 'Case Escalation reason: ' + reason);
            message = 'Success';
        }catch(Exception ex){
            message = '' + ex;
        }
        return message;
    }
    @AuraEnabled(cacheable=true)
    public static caseHandOffdetails initcaseHandoff(String recId){
        List<Case> cslst = [Select Id, Isescalated, Case_Escalation_Reason__c, Owner_Service_Level__c, AccountId, OwnerId, Escalation_reason__c, Defcon_Level__c from Case where id = :recId];
        caseHandOffdetails ctrl = new caseHandOffdetails();
        if(!cslst.isEmpty()){
            List<User> usrinfo = [Select Id, name, Level__c, Service_Level__c, Profile.name, ContactId from User where id = :UserInfo.getUserId()];
            system.debug(usrinfo);
            system.debug(usrinfo[0].Service_Level__c);
            if(!usrinfo.isEmpty()){
                if(cslst[0].Owner_Service_Level__c != 'L3'  && (cslst[0].OwnerId == UserInfo.getUserId() || usrinfo[0].Service_Level__c == 'Support Leads' || usrinfo[0].Service_Level__c == 'Support Managers')){
                    ctrl.showhandoff = true;
                }else  if(cslst[0].Case_Escalation_Reason__c != null){
                    ctrl.showEscalated = true;
                }else{
                    ctrl.showInsuff = true;
                }
            }
        }
        return ctrl;
    }

    @AuraEnabled
    public static String closeCs(String recId, String reason){
        system.debug('+++++'+recId+reason);
        
        String message = '';
        Case cs = new Case(Id = recId, Customer_Close_Request_Reason__c = reason, Status='Customer Close Request');
        try{
            update cs;
            createFeedItem(recId, 'Customer close request reason: ' + reason);
            message = 'Success';
        }catch(Exception ex){
            message = '' + ex;
        }
        return message;
    }
    @AuraEnabled
    public static String reOpenCs(String recId, String reason){
        system.debug('+++++'+recId+reason);
        
        String message = '';
        Case cs = new Case(Id = recId, Customer_Reopen_Reason__c = reason, status='Re-Open');
        try{
            update cs;
            createFeedItem(recId, 'Re-open reason: ' + reason);
            message = 'Success';
        }catch(Exception ex){
            message = '' + ex;
        }

        return message;
    }
    @AuraEnabled
    public static caseDetails checkCaseEscalation(Id recId){
        caseDetails ctrl = new caseDetails();
        List<Case> cslst = [Select Id, Isescalated, AccountId, OwnerId, Escalation_reason__c, Defcon_Level__c from Case where id = :recId];
        if(!cslst.isEmpty()){
            List<Account> acclst = [Select id from account where id = :cslst[0].AccountId and (TAM_Name_New__c =:cslst[0].OwnerId or Secondary_TAM_Name__c =:cslst[0].OwnerId or X3rd_TAM_Name__c =:cslst[0].OwnerId)];
            
            
            List<User> usrinfo = [Select Id, name, Level__c, Service_Level__c, Profile.name, ContactId from User where id = :UserInfo.getUserId()];
            system.debug(usrinfo);
            system.debug(usrinfo[0].Service_Level__c);
            if(!usrinfo.isEmpty()){
                ctrl.isEscalated = (cslst[0].Defcon_Level__c != null && cslst[0].Defcon_Level__c != '5') && usrinfo[0].ContactId != null;
                ctrl.showdefcon = (cslst[0].OwnerId == UserInfo.getUserId() || usrinfo[0].Service_Level__c == 'Support Leads' || usrinfo[0].Service_Level__c == 'Support Managers');
                for(Case_Escalation_Button_Visibility__c csv: Case_Escalation_Button_Visibility__c.getAll().values()){
                    system.debug(csv.Level__c);
                    system.debug(csv.Name);
                    if(csv.Name == 'Engineering_Escalation'){
                        ctrl.showengesc = (csv.Level__c != null && usrinfo[0].Service_Level__c != null && csv.Level__c.contains(usrinfo[0].Service_Level__c)) || !acclst.isEmpty() ? true: false;
                    }
                    if(csv.Name == 'Handoff'){
                       ctrl.showhandoff = ((csv.Level__c != null && usrinfo[0].Service_Level__c != null && csv.Level__c.contains(usrinfo[0].Service_Level__c) && cslst[0].OwnerId == UserInfo.getUserId()) || !acclst.isEmpty()) || usrinfo[0].Service_Level__c == 'Support Leads' || usrinfo[0].Service_Level__c == 'Support Managers' ? true: false;
                    }
                }
            }
        }
        return ctrl;
    }

    public static void createFeedItem(String recId, String reason){
        FeedItem cc = new FeedItem(parentId = recId);
            cc.Body = reason;
            cc.Visibility = 'AllUsers';
            cc.IsRichText = false;
            TriggerUtility.CaseBeforeInsertExecuted();
            TriggerUtility.CaseAfterInsertExecuted();
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            TriggerUtility.SkipFeedItemTriggerExecuted();
            TriggerUtility.SkipCaseCommentTriggerExecuted();
            insert cc;
    }
    public class caseDetails{
        @AuraEnabled
        public boolean isEscalated;
        @AuraEnabled
        public boolean showengesc;
        @AuraEnabled
        public boolean showhandoff;
        @AuraEnabled
        public boolean showdefcon;
    }
    public class caseHandOffdetails{
        @AuraEnabled
        public boolean showInsuff;
        @AuraEnabled
        public boolean showEscalated;
        @AuraEnabled
        public boolean showhandoff;
        public caseHandOffdetails(){
            showInsuff = false;
            showEscalated = false;
            showhandoff = false;

        }
    }
}