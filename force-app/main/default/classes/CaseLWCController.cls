public with sharing class CaseLWCController {

    @AuraEnabled(cacheable=true)
    public static CaseSummaryWrapper fetchCases(Boolean showallCases, String AccountId) {
        
        List<Case> caseopenList = new List<Case>();
        List<Case> caseclosedList = new List<Case>();
        User ur = [select id, AccountId, contactId, Account.Name from User where id =: UserInfo.getUserId() limit 1];
        CaseSummaryWrapper wrp =  new CaseSummaryWrapper();
        String query = 'SELECT Id, AccountId, Account.Name, Createddate, IsClosed, ClosedDate, CaseNumber,Subject,Status,CreatedById,CreatedBy.Name,LastModifiedDate,Community_url__c,Requester__r.Name,Owner.Name,Priority, ContactId, Contact.Name, Zendesk_Reference_Id__c From Case where RecordType.Name =\'Support\' and Zen2SFDC_Account_Mismatch__c = false and Customer_Mismatch_Data_breach_check__c = false ';
        if(showallCases){
            if(AccountId == '' || AccountId == null){
                query +=  'AND AccountId = \'' + ur.AccountId + '\'';
            }else{
                query +=  'AND AccountId = \'' + AccountId + '\'';
            }
        }else{
            query +=  'AND AccountId = \'' + ur.AccountId + '\'';
        }
        caseopenList = Database.query(query + ' and isclosed = false');
        Integer closedsize = 50000 - caseopenList.size();
        caseclosedList = Database.query(query + ' and isclosed = true and closeddate >= last_n_days:365 limit ' + closedsize);
        
        for(Case cs: caseopenList){
            wrp.selectedAccountName = cs.Account.Name;
            
            if(cs.Status == 'Pending Customer' || cs.Status == 'Pending Fix Verification'){
                wrp.pendingCases.add(new CaseWrapper(cs, 'zs-pending-status'));
                wrp.pendingCasecount++;
            }
            if(!cs.IsClosed){
                wrp.openCases.add(new CaseWrapper(cs, 'zs-open-status'));
                wrp.openCasecount++;
            }
            if(!cs.IsClosed && cs.ContactId == ur.ContactId){
                wrp.myCases.add(new CaseWrapper(cs, 'zs-open-status'));
                wrp.myCasecount++;
            }
            if(showallCases && (AccountId == '' || AccountId == null)){
                wrp.accMap.put(cs.Account.Name, cs.AccountId);
            }
        }
        for(Case cs: caseclosedList){
            wrp.selectedAccountName = cs.Account.Name;
            if(cs.IsClosed && cs.ClosedDate >= date.today().addYears(-1)){
                wrp.closedCases.add(new CaseWrapper(cs, 'zs-closed-status'));
                wrp.closedCasecount++;
            }
            
            if(showallCases && (AccountId == '' || AccountId == null)){
                wrp.accMap.put(cs.Account.Name, cs.AccountId);
            }
        }
        if(showallCases && (AccountId == '' || AccountId == null)){
            for(Account acc: [Select Id, Name from Account where Id != :ur.AccountId])
            wrp.accMap.put(acc.Name, acc.Id);
        }
        return wrp;
    }
    public class CaseSummaryWrapper{
        @AuraEnabled
        public List<CaseWrapper> myCases;
        @AuraEnabled
        public List<CaseWrapper> openCases;
        @AuraEnabled
        public List<CaseWrapper> closedCases;
        @AuraEnabled
        public List<CaseWrapper> pendingCases;
        @AuraEnabled
        public Integer myCasecount;
        @AuraEnabled
        public Integer pendingCasecount;
        @AuraEnabled
        public Integer openCasecount;
        @AuraEnabled
        public Integer closedCasecount;
        @AuraEnabled
        public String selectedAccountName;
        @AuraEnabled
        public Map<String, String> accMap;
        public CaseSummaryWrapper(){
            myCases = new List<CaseWrapper>();
            openCases = new List<CaseWrapper>();
            closedCases = new List<CaseWrapper>();
            pendingCases = new List<CaseWrapper>();
            pendingCasecount = 0;
            myCasecount = 0;
            openCasecount = 0;
            closedCasecount = 0;
            accMap = new Map<String, String>();
            selectedAccountName = '';
        }
    }
    public class CaseWrapper {
        @AuraEnabled
        public Case cs = new Case();
        @AuraEnabled
        public String classcss = '';
        public CaseWrapper(Case c, String cname){
            cs = c;
            classcss = cname;
        }
    }
}