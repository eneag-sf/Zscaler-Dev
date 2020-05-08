public class DealRegConversionController {

    public string dealRegId {get;set;}
    public Deal_Reg__c dealReg {get;set;}
    public string selectedOppId {get;set;}
    public string partnerId ;
    map<id, id> oppIdAccountIdMap = new map<id, id>();
    public list<OpportunityListWrapper> oppWrapperList {get; set;}
    list<Opportunity> oppList = new list<Opportunity>();
    Map<Id, Map<String, Opportunity_Partner__c>> mapOpptoOppPart = new Map<Id, Map<String, Opportunity_Partner__c>>();
    public DealRegConversionController (){
        dealRegId = '';
        partnerId= '';
        dealReg = new Deal_Reg__c();
        selectedOppId = '';
        oppList = new list<Opportunity>();
        oppWrapperList = new  list<OpportunityListWrapper>();
        dealRegId = ApexPages.currentPage().getParameters().get('Id');
        if(dealRegId != null && dealRegId != ''){
            dealReg = [Select Id, Name, Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c , Partner_Role__c, Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c,Partner_Company_Name__c , Lead__c, Contact__c, Contact__r.AccountId, OwnerId, End_Customer_Domain__c, End_Customer_Street_Address__c, End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c  from Deal_Reg__c where ID =: dealRegId];
            for(Opportunity opp : [Select Id, Name, AccountId, Account.Name, OwnerId, Owner.Name, StageName, CloseDate, Amount, Type, Deal_Reg__c, Deal_Reg__r.Name, (Select id, AccountTo.Name from OpportunityPartnersFrom where IsPrimary =: true limit 1), (Select Id, Partner_Type__c from Opportunity_Partners__r where Is_Primary__c = true and Partner_Type__c in ('Reseller', 'Tech Partner', 'System Integrator', 'Distributor', 'Deal Reg')) from Opportunity Where Account.Domain__c =: dealReg.End_Customer_Domain__c AND isClosed =: false]){
                oppList.add(opp);
                Map<String, Opportunity_Partner__c> mapOppPartners = new Map<String, Opportunity_Partner__c>();
                for(Opportunity_Partner__c op: opp.Opportunity_Partners__r){
                    if(!mapOppPartners.containsKey(op.Partner_Type__c)){
                        mapOppPartners.put(op.Partner_Type__c, op);
                    }
                }
                if(!mapOppPartners.isEmpty()){
                    mapOpptoOppPart.put(opp.Id, mapOppPartners);
                }
            }
        }   
    }
    
    public PageReference convertDealReg() {
        PageReference pageRef;
        if(dealReg != null){
            if(!oppList.isEmpty()){
                oppWrapperList.add(new OpportunityListWrapper(true, 'Create a New Opportunity'));
                for(Opportunity opp : oppList){
                    oppIdAccountIdMap.put(opp.Id, opp.AccountId);
                    oppWrapperList.add(new OpportunityListWrapper(false, opp));
                }
            }else{
                if(dealReg.Lead__c != null){
                    pageRef = leadConversion(dealReg.Lead__c);
                }else if(dealReg.Contact__c != null){
                   pageRef =  contactConversion();
                } else if (null == dealReg.Lead__c
                    && null == dealReg.Contact__c) {
                    pageRef = opportunityConversion();
                }
            }
            return pageRef;
        }else{
            return null;
        }
        
    }

    public PageReference opportunityConversion() {
        //1. If no contact or lead is found, create a new account and an opportunity with all existing mappings per contactConversion() method
        //2. If an account matches with the same domain, do not create a new one
        //   Also, if an opportunity matches with deal reg, let the user tag the existing one or create a new one - This is handled in the constructor and action method
        Opportunity newOpportunity;

        Id customerAccountId;
        for (Account account : [SELECT Id FROM Account WHERE Domain__c = :dealReg.End_Customer_Domain__c ORDER BY CreatedDate DESC LIMIT 1]) {
            customerAccountId = account.Id;
        }

        if (null == customerAccountId) {
            Account newAccount = new Account(
                                        Name = dealReg.End_Customer_Name__c,
                                        BillingStreet = dealReg.End_Customer_Street_Address__c,
                                        BillingCity = dealReg.End_Customer_City__c,
                                        BillingState = dealReg.End_Customer_State__c,
                                        BillingCountry = dealReg.End_Customer_Country__c,
                                        BillingPostalCode = dealReg.End_Customer_Postal_Code__c,
                                        Domain__c = dealReg.End_Customer_Domain__c
                                    );
            insert newAccount;

            customerAccountId = newAccount.Id;
        }
        newOpportunity = createOpportunity(customerAccountId);
        insert newOpportunity;

        if (null != dealReg.Partner_Account__c) {
            createOpportunityPartner(dealReg.Partner_Account__c, newOpportunity.Id,dealReg.Partner_Program__c);
        }
        updateDealStatustoConverted();

        PageReference opportunityDetailPage = new PageReference('/' + newOpportunity.Id);

        return opportunityDetailPage;
    }
    
    public PageReference leadConversion(Id leadId){
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setOwnerId(dealReg.OwnerId);
        //lc.ConvertedStatus = 'Converted - New Opportunity';
        lc.ConvertedStatus = 'VO';
        
        list<Account> accList = new list<Account>();
        accList = [select Id from Account where Domain__c = : dealReg.End_Customer_Domain__c  Order By CreatedDate DESC Limit 1];
        if(!accList.isEmpty())
            lc.setAccountId(accList[0].Id);
        
        //lc.setOpportunityName('');
        Database.LeadConvertResult lcr = Database.convertLead(lc); 
        
        Opportunity opp = new Opportunity(Id =lcr.getOpportunityId(), Deal_Reg_Margin__c = dealReg.Partner_Account__c, Deal_Reg__c = dealReg.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Amount = dealReg.Estimated_Amount__c, Type = 'New Business', Partner_Role__c = dealReg.Partner_Role__c);
        Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(lcr.getOpportunityId()) ? mapOpptoOppPart.get(lcr.getOpportunityId()) : new Map<String, Opportunity_Partner__c>();
        if(!existingOppPartners.isEmpty() && !existingOppPartners.containsKey('Reseller')){
            opp.Primary_Partner_Program__c = dealReg.Partner_Account_Program__c;
        }
        update opp;
        if(dealReg.Partner_Account__c != null)
        createOpportunityPartner(dealReg.Partner_Account__c, lcr.getOpportunityId(),dealReg.Partner_Program__c);
        updateDealStatustoConverted();
        PageReference pageRef = new PageReference('/'+lcr.getOpportunityId());
        return pageRef;
    }
    
    public void leadConversionWithAccAndOpp(Id leadId,Id accId, id selectedOppId){
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setOwnerId(dealReg.OwnerId);
        //lc.ConvertedStatus = 'Converted - Additional Contact';
        lc.ConvertedStatus = 'VO';
        lc.setAccountId(accId);
        lc.setDoNotCreateOpportunity(true);
        if(!Test.isRunningTest())
            Database.LeadConvertResult lcr = Database.convertLead(lc); 
        updateDealStatustoConverted();
    }
    
    
    public PageReference contactConversion(){
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        insert opp; 
        if(dealReg.Partner_Account__c != null)
        createOpportunityPartner(dealReg.Partner_Account__c, opp.Id,dealReg.Partner_Program__c);
        updateDealStatustoConverted();
        PageReference pageRef = new PageReference('/'+opp.Id);
        return pageRef;
    }
    
    public void updateDealStatustoConverted(){
        Deal_Reg__c deal = new Deal_Reg__c(Id= dealReg.Id, Status__c = 'Converted');
        update deal;
    }
    
    public void updateDealStatustoExpired(id dealRegId){
        Deal_Reg__c deal = new Deal_Reg__c(Id= dealRegId, Status__c = 'Expired');
        update deal;
    }
    
    // modified by Raghu as part of Primary Partner project
    public void createOpportunityPartner(id accId, id OppId,String partnerProgram){
        
        List<Opportunity_Partner__c> oppPartnerlst = new List<Opportunity_Partner__c>();
        oppPartnerlst.add(getOppPartner(accId, OppId, dealReg.Partner_Category__c == 'Partner-Distributor' ? 'Distributor' : dealReg.Partner_Category__c == 'Partner-Integrator' ? 'System Integrator' : dealReg.Partner_Category__c == 'Technology Partner'? 'Tech Partner' : 'Reseller',partnerProgram));
        oppPartnerlst.add(getOppPartner(accId, OppId, 'Deal Reg',partnerProgram));
        insert oppPartnerlst;

        Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(oppId) ? mapOpptoOppPart.get(oppId) : new Map<String, Opportunity_Partner__c>();
        if(!existingOppPartners.isEmpty() && existingOppPartners.containsKey('Deal Reg')){
            List<Opportunity_Partner__c> lsttoDelete = new List<Opportunity_Partner__c>();
            lsttoDelete.add(existingOppPartners.get('Deal Reg'));
            DeleteOpportunityPartner.deleteopppart(lsttoDelete);
        }
        /*
        Partner oppPartner = new Partner();
        oppPartner.AccountToId = accId;
        oppPartner.OpportunityId = oppId;
        oppPartner.isPrimary = true;
        insert oppPartner;
        */
    }
    public Opportunity_Partner__c getOppPartner(id accId, id OppId, String parttype,String partnerProgram){
        Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(oppId) ? mapOpptoOppPart.get(oppId) : new Map<String, Opportunity_Partner__c>();
        
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c();
        oppPartner.Account__c = accId;
        oppPartner.Opportunity__c = oppId;
        oppPartner.Partner_Type__c = parttype;
        if(partnerProgram != null && partnerProgram == 'Both')
        {
            oppPartner.Partner_Program__c = 'Partner Summit';
        }
        else
        {
            oppPartner.Partner_Program__c = partnerProgram;
        }
        if(!existingOppPartners.isEmpty() && existingOppPartners.containsKey(parttype) && parttype != 'Deal Reg'){
            oppPartner.Is_Primary__c = false;
        }else{
            oppPartner.Is_Primary__c = true;
        }
        return oppPartner;
        /*
        Partner oppPartner = new Partner();
        oppPartner.AccountToId = accId;
        oppPartner.OpportunityId = oppId;
        oppPartner.isPrimary = true;
        insert oppPartner;
        */
    }

    public Opportunity createOpportunity(){
        return createOpportunity(null);
    }
    
    public Opportunity createOpportunity(Id customerAccountId){
        Opportunity opp = new Opportunity();
        opp.Name = dealReg.End_Customer_Name__c+'Deal Reg';
        Opp.AccountId = (null != customerAccountId) ? customerAccountId : dealReg.Contact__r.AccountId;
        Opp.OwnerId = dealReg.OwnerId;
        opp.Partner_Role__c = dealReg.Partner_Role__c;
        opp.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp.CloseDate = dealReg.Expected_Close_Date__c;
        opp.Type = 'New Business';
        opp.Source__c = 'Partners';
        opp.Deal_Reg__c = dealReg.Id;
        opp.Deal_Reg_Margin__c = dealReg.Partner_Account__c;
        opp.Primary_Partner_Program__c = dealReg.Partner_Account_Program__c;
        opp.Amount = dealReg.Estimated_Amount__c;
        opp.LeadSource = 'Deal Registration';
        return opp;
    }
    
    
    public PageReference associateDealToOpp(){
        PageReference pageRef ;
    system.debug('# selectedOppId'+selectedOppId);
        if(selectedOppId != '' && selectedOppId != null){
            system.debug('# selectedOppId'+selectedOppId);
            list<Opportunity> oppList = new List<Opportunity>();
            oppList = [Select Id, Deal_Reg__c from Opportunity Where Id =: selectedOppId];
            Opportunity opp = new Opportunity(Id = selectedOppId, Deal_Reg_Margin__c = dealReg.Partner_Account__c, Deal_Reg__c = dealRegId, Partner_Role__c = dealReg.Partner_Role__c);
            Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(selectedOppId) ? mapOpptoOppPart.get(selectedOppId) : new Map<String, Opportunity_Partner__c>();
            if(!existingOppPartners.isEmpty() && !existingOppPartners.containsKey('Reseller')){
                opp.Primary_Partner_Program__c = dealReg.Partner_Account_Program__c;
            }
            update opp;
            if(dealReg.Partner_Account__c != null)
                createOpportunityPartner(dealReg.Partner_Account__c, selectedOppId,dealReg.Partner_Program__c);
            updateDealStatustoConverted();
            if(!oppList.isEmpty()){
                if(oppList[0].Deal_Reg__c != null)
                    updateDealStatustoExpired(oppList[0].Deal_Reg__c);
            }
            if(dealReg.Lead__c != null){
                leadConversionWithAccAndOpp(dealReg.Lead__c, oppIdAccountIdMap.get(selectedOppId), selectedOppId);
            }else if(dealReg.Contact__c != null){
                //contactConversion();
               // createDealRegOpp(dealReg.Id, opp.Id);
                
            } else if (null == dealReg.Lead__c
                && null == dealReg.Contact__c) {
                opportunityConversion();
            }
            pageRef = new PageReference('/'+selectedOppId);
            
        }else{
            //New Opportunity Logic
            if(dealReg.Lead__c != null){
                pageRef = leadConversion(dealReg.Lead__c);
            }else if(dealReg.Contact__c != null){
                pageRef = contactConversion();
            } else if (null == dealReg.Lead__c
                && null == dealReg.Contact__c) {
                pageRef = opportunityConversion();
            }
        }       
        return pageRef;    
    }
    
    public class OpportunityListWrapper{
        public boolean isSelected {get;set;}
        public id oppId {get;set;}
        public String oppName {get;set;}
        public string accName {get; set;}
        public decimal amount {get; set;}
        public string stageName {get; set;}
        public date closeDate {get; set;}
        public string type {get; set;}
        public string dealRegName {get; set;}
        public string dealRegId {get; set;}
        public Opportunity opp {get;set;}
        public OpportunityListWrapper(boolean s,Opportunity o){
            this.isSelected = s;
            this.opp = o;
            this.oppName = o.Name;
            this.oppId = o.Id;
            this.accName = o.Account.Name;
            this.amount = o.Amount != null ? o.Amount : 0;
            this.StageName = o.StageName;
            this.closeDate = o.CloseDate;
            this.dealRegId = o.Deal_Reg__c;
            this.dealRegName = o.Deal_Reg__r.Name;
            this.Type = o.Type;
        }
        
        public OpportunityListWrapper(boolean s,string newOppName){
            this.isSelected = s;
            this.oppName = newOppName;
            this.oppId = null;
        }
    }
}