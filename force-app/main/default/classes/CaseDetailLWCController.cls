public without sharing class CaseDetailLWCController {
    @AuraEnabled
    public static Case updateCase(String caseDetailId) {
        if(String.isNotBlank(caseDetailId)) {
            Case cse = [select id from case where id =: caseDetailId];
            cse.Status = 'Closed - Resolved';
            update cse;
            return cse;
        }
        else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static list<Case> fetchCase(String strObjectName) {
        if(String.isNotBlank(strObjectName)) {
            return Database.query('SELECT Id, Account.Name,Account.Id, Contact.Name,Priority,Case_Type__c, Case_Category__c,Product_New__c, '+
            'CaseNumber,Subject,Status,CreatedById,CreatedBy.name,LastModifiedDate,'+
            'Community_url__c,Owner.Name,CreatedDate,Requester__r.Name,Preferred_Contact_Number__c,'+
            'Preferred_Contact_Time_Zone__c, Zendesk_Reference_Id__c, (select id, CreatedBy.name,CommentBody from '+
            'CaseComments) From Case where Id = :strObjectName');
        }
        else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getCustomerCCList(String strObjectName) {
        if(String.isNotBlank(strObjectName)) {
            Set<String> emailset = new Set<String>();
            List<Case> cslst = [Select id, customer_cc_list__c from case where id = :strObjectName];
            if(!cslst.isEmpty()){
                if(cslst[0].customer_cc_list__c != null){
                    for(String s: cslst[0].customer_cc_list__c.trim().split(';')){
                        if(!s.contains('@zscaler.com')){
                            emailset.add(s);
                        }
                    }
                }
            }
            List<String> emailIds = new List<String>(emailset);
            return emailIds;
        }
        else {
            return null;
        }
    }
    @AuraEnabled
    public static void updateCustomerCCList(String caseId, String custcclist) {
        if(String.isNotBlank(caseId)) {
            Case cs = new Case(id=caseId, Customer_cc_list__c = custcclist);
            update cs;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getUserDetails() {
        user ur = [select id,Profile.UserLicense.Name from User where id =: UserInfo.getUserId()];
        return  ur.Profile.UserLicense.Name;
    }
    @AuraEnabled(cacheable=true)
    public static list<String> getDomains() {
            Map<String, Email_Domains_to_Exclude__c> mapemaildomains = Email_Domains_to_Exclude__c.getAll();
            return new List<String>(mapemaildomains.keySet());
    }
    @AuraEnabled
    public static Contact updateContact(Contact objCt, Id caseId) {
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        update objCt;
        List<Case> cslst = [Select Id, Case_CC_List__c from case where Id = :caseId];
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return objCt;
    }
    @AuraEnabled
    public static Contact deleteContact(String objCtId, Id caseId) {
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        delete [select id from Contact where id = :objCtId];
        List<Case> cslst = [Select Id, Case_CC_List__c from case where Id = :caseId];
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return null;
    }
    
    @AuraEnabled                                           
    public static CaseTeamMember addUserToCaseTeamMember(String objCtId,String caseId) {
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        System.debug('Here:-'+caseId);
        System.debug('objCt:-'+objCtId);
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c from case where Id = :caseId];
        User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
        CaseTeamMember cseMember = null;
        if(objCtId != null) {
            if(ur != null && ur.ContactId != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
            }else if(ur != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
            }
            cseMember = new CaseTeamMember();
            cseMember.MemberId = objCtId;
            cseMember.ParentId = caseId;
            cseMember.TeamRoleId = teamRoleId;
            insert csemember;
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return csemember;
    }
    @AuraEnabled                                           
    public static List<CaseTeamMember> addMultiContactToCaseTeamMember(List<String> objCtId,String caseId) {
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        System.debug('Here:-'+caseId);
        System.debug('objCt:-'+objCtId);
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c from case where Id = :caseId];
       
        User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
       // CaseTeamMember cseMember = null;
       List<CaseTeamMember> lstCaseTeams = new List<CaseTeamMember>();
        if(objCtId != null) {
           // List<String> obj1 = objCtId.split(',');
            teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
            List<CaseTeamMember> lst1 = [select id from CaseTeamMember where ParentId =:caseId and TeamRoleId =: teamRoleId];
            System.debug(lst1.size());
            delete lst1;
            //System.debug(obj1.size());
            for(String s : objCtId)  {
                System.debug(s);
                CaseTeamMember cseMember = new CaseTeamMember();
                cseMember.MemberId = s;
                cseMember.ParentId = caseId;
                cseMember.TeamRoleId = teamRoleId;
                lstCaseTeams.add(cseMember);
            }
            System.debug(lstCaseTeams.size());
            Database.insert(lstCaseTeams,true);
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return lstCaseTeams;
    }

    @AuraEnabled                                           
    public static List<CaseTeamMember> addMultiUserToCaseTeamMember(List<String> objCtId,String caseId) {
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c from case where Id = :caseId];
       
        User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
       List<CaseTeamMember> lstCaseTeams = new List<CaseTeamMember>();
        if(objCtId != null) {
            teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
            List<CaseTeamMember> lst1 = [select id from CaseTeamMember where ParentId =:caseId and TeamRoleId =: teamRoleId];
            System.debug(lst1.size());
            delete lst1;
            for(String s : objCtId)  {
                System.debug(s);
                CaseTeamMember cseMember = new CaseTeamMember();
                cseMember.MemberId = s;
                cseMember.ParentId = caseId;
                cseMember.TeamRoleId = teamRoleId;
                lstCaseTeams.add(cseMember);
            }
            System.debug(lstCaseTeams.size());
            Database.insert(lstCaseTeams,true);
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return lstCaseTeams;
    }

    @AuraEnabled
    public static CaseTeamMember addContactToCaseTeamMember(String objCtId,String caseId) {
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        System.debug('Here:-'+caseId);
        System.debug('objCt:-'+objCtId);
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c from case where Id = :caseId];
        User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
        CaseTeamMember cseMember = null;
        if(objCtId != null) {
            if(ur != null && ur.ContactId != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
            }else if(ur != null){
                teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
            }
            cseMember = new CaseTeamMember();
            cseMember.MemberId = objCtId;
            cseMember.ParentId = caseId;
            cseMember.TeamRoleId = teamRoleId;
            insert csemember;
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return csemember;
    }
    @AuraEnabled
    public static Contact createContact(Contact objCt,String caseId) {
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        String teamRoleId = '';
        List<Case> cslst = [Select Id, Case_CC_List__c,AccountId from case where Id = :caseId];
        User ur = [select id, AccountId, ContactId, Profile.UserLicense.Name from User where id =: UserInfo.getUserId() limit 1];
        List<Contact> ctList = [select id, Email, FirstName, Lastname from Contact where email =: objCt.email and AccountId =: ur.AccountId];
        if(ctList.size() < 1){
            objCt.AccountId = cslst.get(0).AccountId;
            if(ur.Profile.UserLicense.Name == 'Customer Community Login'){
                objCt.Contact_Type__c = 'Support';
            }
            insert objCt;
            if(objCt.Id != null) {
                if(ur != null && ur.ContactId != null){
                    teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
                }else if(ur != null){
                    teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
                }
                CaseTeamMember cseMember = new CaseTeamMember();
                cseMember.MemberId = objCt.Id;
                cseMember.ParentId = caseId;
                cseMember.TeamRoleId = teamRoleId;
                insert csemember;
            }
        }else{
            objCt = ctList[0];
            if(objCt.Id != null) {
                if(ur != null && ur.ContactId != null){
                    teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
                }else if(ur != null){
                    teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Internal Agent' limit 1].Id;
                }
                CaseTeamMember cseMember = new CaseTeamMember();
                cseMember.MemberId = objCt.Id;
                cseMember.ParentId = caseId;
                cseMember.TeamRoleId = teamRoleId;
                insert csemember;
            }
        }
        if(!cslst.isEmpty()){
            updatecaseCCList(cslst);
        }
        return objCt;
    }
    @AuraEnabled(cacheable=true)
    public static list<CaseTeamMember> fetchUserCaseTeamMember(String csId) {
        if(String.isNotBlank(csId)) {
            String teamrole = 'Internal Agent';
            List<CaseTeamMember> userCaseMembers = [select id, MemberId from CaseTeamMember where ParentId =: csId and TeamRole.Name=: teamrole order by Member.name];
            return userCaseMembers;
        }
        else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static list<Contact> fetchAccountContacts(String csId) {
        System.debug('strObjectName:-'+csId);
        if(String.isNotBlank(csId)) {
            Case cs = [select id, AccountId from Case where id =:csId];
            if(cs.AccountId != null){
                List<Contact> ctList = [SELECT Id, Email, FirstName, LastName, Name FROM Contact where AccountId =: cs.AccountId order by Firstname];
                return ctList;
            }else{
                return null;
            }
        }
        else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static list<User> fetchUsers(String csId) {
        List<User> userList = [SELECT Id, Email, FirstName, LastName, Name FROM User where IsActive = true AND Profile.UserLicense.name = 'Salesforce' order by FirstName];
        return userList;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Contact> fetchEmailList(String csId) {
        if(String.isNotBlank(csId)) {
            String teamrole = '';
            User ur = [select id, AccountId, ContactId from User where id =: UserInfo.getUserId() limit 1];
            if(ur != null && ur.ContactId != null){
                teamrole = 'Customer';
            }
            List<CaseTeamMember> lstc = new List<CaseTeamMember>();
            if(teamrole != ''){
                lstc = [select id, MemberId from CaseTeamMember where ParentId =: csId and TeamRole.Name=: teamrole order by Member.name];
            }else{
                lstc = [select id, MemberId from CaseTeamMember where ParentId =: csId order by Member.name];
            }
            List<Id> lstIds = new List<Id>();
            for(CaseTeamMember ct : lstc) {
                lstIds.add(ct.MemberId);
            }
            List<User> lstU = [SELECT Id, Email, FirstName, LastName FROM User where Id in : lstIds order by Name];
            if(lstU.size() > 0)  {
                List<Contact> lstC1 = [SELECT Id, Email, FirstName, LastName FROM Contact where Id in : lstIds order by name];
                for(User u : lstU)  {
                    Contact ct1 = new Contact();
                    ct1.email = u.email;
                    ct1.FirstName = u.FirstName;
                    ct1.LastName = u.LastName;
                    lstC1.add(ct1);
                }    
                return lstC1;
            }else {
                return Database.query('SELECT Id, Email, FirstName, LastName FROM Contact where Id in : lstIds');
            }    
        }
        else {
            return null;
        }
    }
    public static void updatecaseCCList(List<case> cslst) {
        Map<Id, String> cclstmap = new Map<Id, String>();
        Map<Id, String> conIdtoemailMap = new Map<Id, String>();
        Map<Id, String> userIdtoemailMap = new Map<Id, String>();
        Set<Id> contIds = new Set<Id>();
        for(CaseTeamMember ctr: [Select Id, MemberId, Member.Email, ParentId from CaseTeamMember where ParentId in :cslst]){
            contIds.add(ctr.MemberId);
        }
        for(Contact con: [Select Id, Email from Contact where Id in :contIds]){
            conIdtoemailMap.put(con.Id, con.Email);
        }
        for(User ur: [Select Id, Email from User where Id in :contIds]){
            userIdtoemailMap.put(ur.Id, ur.Email);
        }
        for(CaseTeamMember ctr: [Select Id, MemberId, Member.Email, ParentId from CaseTeamMember where ParentId in :cslst]){
            if(cclstmap.containsKey(ctr.ParentId)){
                String emails = cclstmap.get(ctr.ParentId);
                emails += conIdtoemailMap.containsKey(ctr.MemberId) ? conIdtoemailMap.get(ctr.MemberId) + ';' : (userIdtoemailMap.containsKey(ctr.MemberId) ? userIdtoemailMap.get(ctr.MemberId) + ';' : '');
                cclstmap.put(ctr.ParentId, emails);
            }else{
                cclstmap.put(ctr.ParentId, conIdtoemailMap.containsKey(ctr.MemberId) ? conIdtoemailMap.get(ctr.MemberId) + ';' : (userIdtoemailMap.containsKey(ctr.MemberId) ? userIdtoemailMap.get(ctr.MemberId) + ';' : ''));
            }
        }
        
        for(Case cs: cslst){
            cs.Case_CC_List__c = cclstmap.containsKey(cs.Id) ? cclstmap.get(cs.Id) : '';
        }
        TriggerUtility.SkipCaseTriggerExecuted();
        update cslst;
    }
}