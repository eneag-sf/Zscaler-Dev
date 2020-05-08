public class APTS_PartnerSelectionCOntroller {

    public string selectedPartner{get;set;}
    public string SelectedPartnerProgram{get;set;}
    public Apttus_Proposal__Proposal__c proposalrec;
    public boolean haserror{get;set;}
    public boolean needsRepricing { get; set; }
    public Map<Id, OpportunityPartner> opptypartnermap = new Map<Id, OpportunityPartner>();
    public boolean submittedforApproval {get;set;}
    //public boolean ShowSubmitButton{get;set;}
    //public boolean IsApprovalSuccess{get;set;}
    //public boolean IsInApproval{get;set;}
    public boolean hasDistributors {get;set;}
    public boolean hasPartners {get;set;}
    public boolean primaryProposal {get;set;}
    public string proposalBillTo {get;set;}
    public string proposalDistributor {get;set;}
    public string DistributorPartnerId{get;set;}
    public string UncheckDistributorPartnerId{get;set;}
    
    public string PartnerString{get;set;}
    public string DistributorPartnerString{get;set;}
    public List<Opportunity_Partner__c> OppPartnerList{get;set;}
    public List<OppPartnerInner> oppPartnerRecords {get;set;}
    public List<Opportunity_Partner__c> OppDistributorPartnerList {get;set;}
    public List<OppPartnerInner> OppDistributorPartnerRecords {get;set;}
    public string SelectedPartnerId{get;set;}
    public string SelectedDistributorPartnerId{get;set;}
    public string AttachmentId{get;set;}
    public boolean partnerModel{get;set;}
    // Partner Summit Model Variables Start //
    public string errorMessage {get;set;}
    public boolean hasModelError      {get;set;}
    public string selectedModelType {get;set;}
    public Opportunity oppRecord {get;set;}
    // Partner Summit Model Variables End //
    
    public class OppPartnerInner{
        public Opportunity_Partner__c oppPartner {get;set;}
        public String oppPartnerStatus {get;set;}
    }
     
    public APTS_PartnerSelectionCOntroller(ApexPages.StandardController stdController){
        /*oppPartnerRecords = new List<OppPartnerInner>();
        OppDistributorPartnerRecords = new List<OppPartnerInner>();*/
        //ShowSubmitButton = false;
        //IsApprovalSuccess = false;
        //IsInApproval = false;
        needsRepricing = false;
        proposalrec = (Apttus_Proposal__Proposal__c)stdCOntroller.getRecord();
        proposalrec = [select id, Apttus_Proposal__Opportunity__c, Price_List_Name__c, Distributor__c, Apttus_Proposal__Primary__c, Apttus_QPConfig__ConfigurationFinalizedDate__c, Apttus_Proposal__Opportunity__r.accountid, Model_Type_Partner__c, Apttus_QPConfig__BillToAccountId__c,/*Apttus_QPConfig__PartnerAccountId__c,*/ (SELECT Id FROM R00N70000001yUfBEAU__r) from Apttus_Proposal__Proposal__c where id=:proposalrec.id limit 1];
        OppPartnerList = new List<Opportunity_Partner__c>();
        OppDistributorPartnerList = new List<Opportunity_Partner__c>();
        getPartnersData();

        // Partner Summit Model Variables Start //
        oppRecord = new opportunity();
        oppRecord = [select id,Type,Recordtype.Name from Opportunity where id =: proposalrec.Apttus_Proposal__Opportunity__c];
        hasModelError = false;
        selectedModelType = '';
        // Partner Summit Model Variables End //
        

        //if(){
            
        //}
        /*haserror=false;
        needsRepricing = false;
        oppPartWrap= new List<OpportunityPartnerWrap> ();
        proposalrec= (Apttus_Proposal__Proposal__c)stdCOntroller.getRecord();
        proposalrec=[select id, Apttus_Proposal__Opportunity__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__r.accountid,Apttus_QPConfig__BillToAccountId__c, (SELECT Id FROM R00N70000001yUfBEAU__r) from Apttus_Proposal__Proposal__c where id=:proposalrec.id ];
        if( proposalrec!=null)
        {
        List<OpportunityPartner>OppPartList =[select id,AccountTo.Name, AccountToId,IsPrimary,Role from OpportunityPartner where opportunityid=:proposalrec.Apttus_Proposal__Opportunity__c and AccountToId!=:proposalrec.Apttus_Proposal__Opportunity__r.accountid AND AccountTo.Type Like 'Partner%'];
        if(OppPartList!=null && !OppPartList.isempty() )
        {
         set<id> setid = new  set<id> ();
        for (OpportunityPartner oppart : OppPartList )
        {
            if(!setid.contains(oppart.AccountToId))
            {
            if(proposalrec.Apttus_QPConfig__BillToAccountId__c==oppart.AccountToId)
            {
              oppPartWrap.add(new OpportunityPartnerWrap(proposalrec.Apttus_QPConfig__BillToAccountId__c,oppart) ) ;
            }
            else
            {
              oppPartWrap.add(new OpportunityPartnerWrap(null,oppart))    ;
            }
            }
            setid.add(oppart.AccountToId);
            opptypartnermap.put(oppart.AccountToId, oppart);
        }
        }
         else
        {
    
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No Partner Records found'));
        }
        }
        else
        {
    
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No  Records found'));
        }*/
        if(proposalrec.Apttus_Proposal__Primary__c){
            primaryProposal = true;
        }
        proposalDistributor = proposalrec.Distributor__c;
        proposalBillTo = proposalrec.Apttus_QPConfig__BillToAccountId__c;
    }
    
    
    /**
     * Performs the cancel action
     * @return the next page reference 
     */
    public PageReference doCancel() {
        // navigate to the opportunity 
        return new PageReference('/' + proposalrec.Id);
    }
    
    public void cancelModal() {
        // navigate to the opportunity 
        partnerModel = false;
    }

    
     public void CheckDistributorPartners(){
       system.debug('--OppDistributorPartnerRecords before--'+OppDistributorPartnerRecords);
           if(DistributorPartnerId != null){
           for(OppPartnerInner Inn:OppDistributorPartnerRecords){
               if(Inn.oppPartner.Id == DistributorPartnerId){
                   if(Inn.oppPartner.Is_Primary__c == true){
                       Inn.oppPartner.Is_Primary__c = false;
                       SelectedDistributorPartnerId = null;
                       UncheckDistributorPartnerId = DistributorPartnerId;
                   }else{
                       Inn.oppPartner.Is_Primary__c = true;
                       SelectedDistributorPartnerId = DistributorPartnerId;
                       UncheckDistributorPartnerId = null;
                   }
               }else{
                   Inn.oppPartner.Is_Primary__c = false;
               }
           }
       }
       system.debug(OppDistributorPartnerRecords.size()+'--OppDistributorPartnerRecords after--'+OppDistributorPartnerRecords);                  
       
    }
    
    
    /**
        Updated BY : Sateesh U 
        This method is used To get the Opportunity reseller and distributor partners data with their approval status
    **/
    public void getPartnersData(){
        oppPartnerRecords = new List<OppPartnerInner>();
        OppDistributorPartnerRecords = new List<OppPartnerInner>();
        if(proposalrec != null){
            if(proposalrec.Apttus_Proposal__Opportunity__c != null){
                List<Incumbent_Partner__c> accountIncumbentPartners = [Select Incumbent_Partner_Account__c,Partner_Type__c from Incumbent_Partner__c Where Account__c =: proposalrec.Apttus_Proposal__Opportunity__r.accountid];
                Map<String, String> accountIncumbentPartnersMap = new Map<String, String>();
                for(Incumbent_Partner__c IPRec : accountIncumbentPartners){
                    accountIncumbentPartnersMap.put(IPRec.Incumbent_Partner_Account__c+'-'+IPRec.Partner_Type__c, IPRec.Incumbent_Partner_Account__c);
                }
                OppPartnerList = [Select Id, Name, Account__c, Account__r.Name, Is_Primary__c, Opportunity__c, Opportunity__r.Name,  Opportunity__r.Type, Partner_Type__c, Approval_Status__c, Partner_Program__c from Opportunity_Partner__c where Opportunity__c = :proposalrec.Apttus_Proposal__Opportunity__c and Partner_Type__c = 'Reseller'];
                if(OppPartnerList.size()>0){
                    hasPartners = true;
                    PartnerString = JSON.serialize(OppPartnerList);
                    PartnerString = PartnerString.remove('\'');
                    
                    for(Opportunity_Partner__c OPRec : OppPartnerList){
                        OppPartnerInner OppPartnerRecord = new OppPartnerInner();
                        OppPartnerRecord.oppPartner = OPRec;
                        if(/*OPRec.Opportunity__r.Type == 'Existing Customer (Add On)' ||*/ OPRec.Opportunity__r.Type == 'Existing Customer (Renewal)'){
                            if(accountIncumbentPartnersMap.get(OPRec.Account__c+'-'+OPRec.Partner_Type__c) != null){
                                OppPartnerRecord.oppPartnerStatus = 'Account Incumbent Partner';
                            }
                            else if(OPRec.Approval_Status__c == 'Pending'){
                                OppPartnerRecord.oppPartnerStatus = 'Partner Approval Pending';
                            }
                            else if(OPRec.Approval_Status__c == 'Approved'){
                                OppPartnerRecord.oppPartnerStatus = 'Partner Approved';
                            }
                            else if(OPRec.Approval_Status__c == 'Rejected'){
                                OppPartnerRecord.oppPartnerStatus = 'Partner Rejected';
                            }
                            else{
                                OppPartnerRecord.oppPartnerStatus = 'Approval Required';
                            }
                        }
                        oppPartnerRecords.add(OppPartnerRecord);
                    }
                } 
                else{
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No Reseller Partner Records found'));
                    //haserror=true;
                    hasPartners = false;
                }
                OppDistributorPartnerList = [Select Id, Name, Account__c, Account__r.Name, Is_Primary__c, Opportunity__c, /**Opportunity__r.Name,**/  Opportunity__r.Type, Partner_Type__c, Approval_Status__c from Opportunity_Partner__c where Opportunity__c = :proposalrec.Apttus_Proposal__Opportunity__c and Partner_Type__c = 'Distributor'];
                if(OppDistributorPartnerList.size()>0){
                    hasDistributors = true;
                    DistributorPartnerString = JSON.serialize(OppDistributorPartnerList);
                    DistributorPartnerString = DistributorPartnerString.remove('\'');
                    
                    for(Opportunity_Partner__c OPRec : OppDistributorPartnerList){
                        OppPartnerInner OppPartnerRecord = new OppPartnerInner();
                        OppPartnerRecord.oppPartner = OPRec;
                        if(OPRec.Account__c == proposalrec.Distributor__c){
                            OppPartnerRecord.oppPartner.Is_Primary__c = true;
                        }else{
                            OppPartnerRecord.oppPartner.Is_Primary__c = false;
                        }
                        /*if(OPRec.Opportunity__r.Type == 'Existing Customer (Add On)' || OPRec.Opportunity__r.Type == 'Existing Customer (Renewal)'){
                            if(accountIncumbentPartnersMap.get(OPRec.Account__c+'-'+OPRec.Partner_Type__c) != null){
                                OppPartnerRecord.oppPartnerStatus = 'Account Incumbent Partner';
                            }
                            else if(OPRec.Approval_Status__c == 'Pending'){
                                OppPartnerRecord.oppPartnerStatus = 'Partner Approval Pending';
                            }
                            else if(OPRec.Approval_Status__c == 'Approved'){
                                OppPartnerRecord.oppPartnerStatus = 'Partner Approved';
                            }
                            else if(OPRec.Approval_Status__c == 'Rejected'){
                                OppPartnerRecord.oppPartnerStatus = 'Partner Rejected';
                            }
                            else{
                                OppPartnerRecord.oppPartnerStatus = 'Approval Required';
                            }
                        }*/
                        OppDistributorPartnerRecords.add(OppPartnerRecord);
                    }
                    /*system.debug('---proposalDistributor--'+proposalDistributor+'---'+proposalrec.Distributor__c);
                    for(OppPartnerInner Inn:OppDistributorPartnerRecords){
                       if(Inn.oppPartner.Account__c == proposalrec.Distributor__c){
                            Inn.oppPartner.Is_Primary__c = true;
                       }else{
                            Inn.oppPartner.Is_Primary__c = false;
                       }
                   }*/
                }
                else{
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No Distributor Partner Records found'));
                    //haserror=true;
                    hasDistributors = false;
                }
                
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No  Records found'));
            haserror=true;
        }
    }
    
    public PageReference SavePartner1(){
        if(proposalrec != null){
            if(SelectedPartnerId != null && proposalrec.Model_Type_Partner__c != SelectedPartnerProgram){
                partnerModel = true;
            }else{
                return SavePartner();
            }
        }
        return null;
    }
    /**
        Updated BY : Sateesh U 
        This method is used To save the Opportunity reseller and distributor partners and to map 'Bill to' and 'reseller' on quote.
    **/
    public PageReference SavePartner(){
        try{
            haserror = false;
            //ShowSubmitButton = false;
            //IsInApproval = false;
            List<Opportunity_Partner__c> PartNerList = new List<Opportunity_Partner__c>();
            List<Opportunity_Partner__c> ResellerPartNerList = new List<Opportunity_Partner__c>();
            List<Opportunity_Partner__c> DistributorPartNerList = new List<Opportunity_Partner__c>();
            if(proposalrec.Apttus_Proposal__Opportunity__c != null){
                PartNerList = [Select Id, Name, Account__c, Account__r.Name, Is_Primary__c,
                                            Opportunity__c,
                                            /**Opportunity__r.Name,**/
                                            Partner_Type__c 
                                            from 
                                            Opportunity_Partner__c 
                                            where 
                                            Opportunity__c = :proposalrec.Apttus_Proposal__Opportunity__c 
                                            and 
                                            /*Partner_Type__c = 'Reseller' And*/ 
                                            Is_Primary__c = true];
                                            
                for(Opportunity_Partner__c OppPart : PartNerList){
                    if(OppPart.Partner_Type__c == 'Reseller'){
                        ResellerPartNerList.Add(OppPart);
                    }
                    else if(OppPart.Partner_Type__c == 'Distributor'){
                        DistributorPartNerList.Add(OppPart);
                    }
                }
            }
            
            if(DistributorPartNerList.size()<=0 && ResellerPartNerList.size()>0){
                if(ResellerPartNerList[0].Account__c != null) {
                    proposalrec.Distributor__c = ResellerPartNerList[0].Account__c;
                }
            }
            update proposalrec;
            
            if(UncheckDistributorPartnerId != null && (SelectedDistributorPartnerId == null || SelectedDistributorPartnerId == '') && (SelectedPartnerId == null || SelectedPartnerId == '')){
                List<Opportunity_Partner__c> DeselectPartnerRec = [Select Id, Name, Account__c, Account__r.Name, Is_Primary__c,
                                                                    Opportunity__c,
                                                                    /**Opportunity__r.Name,**/
                                                                    Partner_Type__c 
                                                                    from 
                                                                    Opportunity_Partner__c 
                                                                    where 
                                                                    Id = :UncheckDistributorPartnerId limit 1];
                if(proposalrec.Apttus_Proposal__Primary__c){
                    if(DeselectPartnerRec.size()>0){
                        if(DeselectPartnerRec[0].Is_Primary__c == true){
                            DeselectPartnerRec[0].Is_Primary__c = false;
                            update DeselectPartnerRec;
                        }
                    }
                }
                
                if(proposalrec.Apttus_QPConfig__BillToAccountId__c != null) {
                    proposalrec.Distributor__c = proposalrec.Apttus_QPConfig__BillToAccountId__c;
                }
                /*if(ResellerPartNerList[0].Account__c != null) {
                    proposalrec.Distributor__c = ResellerPartNerList[0].Account__c;
                }*/
                update proposalrec;                                              
            }
            
            system.debug(proposalrec.Apttus_Proposal__Opportunity__c + '---' + PartNerList.size());
            if((SelectedPartnerId == null || SelectedPartnerId == '') && (SelectedDistributorPartnerId == null || SelectedDistributorPartnerId == '') && ResellerPartNerList.size()<=0 && DistributorPartNerList.size()<=0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Select Atleast one record'));
                haserror=true;
                return null;
            }
            else if((SelectedPartnerId == null || SelectedPartnerId == '') && (SelectedDistributorPartnerId == null || SelectedDistributorPartnerId == '') && (ResellerPartNerList.size()>0 && DistributorPartNerList.size()>0)){
                PageReference pr = new ApexPages.StandardController(proposalrec).view();
                pr.setRedirect(true);
                return pr;
            }
            else{
                
                boolean IsResellerAndIncumbentPartner = false;
                boolean IsDistributorAndIncumbentPartner = false;
                //This if condition is for Partner field
                if(SelectedPartnerId != null && SelectedPartnerId != ''){
                    Opportunity_Partner__c OppPartnerRec = new Opportunity_Partner__c();
                    String selectedPartnerProgram = '';
                    List<Opportunity_Partner__c> oppPartnerRecs = [Select Id, Name, Account__c, Account__r.Name,
                                                                                Approval_Status__c,
                                                                                Is_Primary__c,
                                                                                Opportunity__c,
                                                                                Opportunity__r.Name,
                                                                                Partner_Type__c, 
                                                                                Partner_Program__c 
                                                                                from 
                                                                                Opportunity_Partner__c 
                                                                                where 
                                                                                Id =: SelectedPartnerId
                                                                                And
                                                                                Partner_Type__c = 'Reseller'];
                    if(!oppPartnerRecs.isEmpty()){
                        OppPartnerRec = oppPartnerRecs[0];
                        selectedPartnerProgram = OppPartnerRec.Partner_Program__c;
                    }
                    Opportunity OppRecord = new Opportunity();
                    List<Incumbent_Partner__c> IncumbentPartnerAccountList = new List<Incumbent_Partner__c>();
                    
                    List<Opportunity> oppRecords = new List<Opportunity>();
                    
                    if(proposalrec.Apttus_Proposal__Opportunity__c != null){
                        oppRecords = [select Id, Name, AccountId,
                                                        RecordTypeId,
                                                        RecordType.Name 
                                                        from 
                                                        Opportunity 
                                                        where Id =: proposalrec.Apttus_Proposal__Opportunity__c 
                                                        and 
                                                        (/*Type = 'Existing Customer (Add On)' or*/ Type = 'Existing Customer (Renewal)')];
                        if(!oppRecords.isEmpty()){
                            //if(){
                            OppRecord = oppRecords[0];
                        }
                    }
                    
                    if(OppRecord != null && OppRecord.AccountId != null){
                        IncumbentPartnerAccountList = [select Id, Name, Account__c,
                                                                Incumbent_Partner_Account__c,
                                                                Partner_Type__c 
                                                                from 
                                                                Incumbent_Partner__c 
                                                                where 
                                                                Account__c =: OppRecord.AccountId 
                                                                And 
                                                                Partner_Type__c = 'Reseller'];
                        if(IncumbentPartnerAccountList.size() > 0){
                            for(Incumbent_Partner__c IncumPartner : IncumbentPartnerAccountList){
                                if(IncumPartner.Incumbent_Partner_Account__c == OppPartnerRec.Account__c){
                                    IsResellerAndIncumbentPartner = true;
                                }
                            }
                        }
                        else{
                            IsResellerAndIncumbentPartner = false;
                        }
                        if(OppPartnerRec.Approval_Status__c == 'Approved'){
                            IsResellerAndIncumbentPartner = true;
                        }
                    }
                    if(IsResellerAndIncumbentPartner == true || oppRecords.size() == 0 || OppPartnerRec.Approval_Status__c == 'Approved'){
                        ID GAMNAMId =null;
                        if(OppPartnerRec != null){
                            if(OppPartnerRec.Account__c != null){
                                String Partnername = OppPartnerRec.Account__r.Name;
                                Triggers_Switch__c tg = Triggers_Switch__c.getValues('Update_GAM_NAM');
                                if(tg != null && tg.Execute__c){
                                    Map<String, Partner_GAM_NAM_Mapping__c> stageforecastmap =  new Map<String, Partner_GAM_NAM_Mapping__c>();
                                    
                                    for(Partner_GAM_NAM_Mapping__c stg: Partner_GAM_NAM_Mapping__c.getAll().Values()){
                                        if(Partnername.containsIgnoreCase(stg.Name)){
                                            GAMNAMId = stg.GAM_NAM_Id__c;
                                            break;
                                        }
                                    }
                                } 
                            }
                            
                            /*if(proposalrec.Apttus_QPConfig__PartnerAccountId__c != OppPartnerRec.Account__c && OppPartnerRec.Account__c != null) {
                                proposalrec.Apttus_QPConfig__PartnerAccountId__c = OppPartnerRec.Account__c;
                                update proposalrec;
                            }*/
                            if(proposalrec.Apttus_QPConfig__BillToAccountId__c != OppPartnerRec.Account__c && OppPartnerRec.Account__c != null) {
                                
                                Opportunity opp = new Opportunity(Id =  proposalrec.Apttus_Proposal__Opportunity__c, GAM_NAM__c =GAMNAMId);
                                if(proposalrec.Apttus_Proposal__Primary__c){
                                    opp.Primary_Partner_Program__c = selectedPartnerProgram;
                                }
                                update opp;
                                
                                proposalrec.Apttus_QPConfig__BillToAccountId__c = OppPartnerRec.Account__c;
                                
                                if(DistributorPartNerList.size()<=0 || UncheckDistributorPartnerId != null){
                                    if(OppPartnerRec.Account__c != null) {
                                        proposalrec.Distributor__c = OppPartnerRec.Account__c;
                                    }
                                }
                                update proposalrec;
                                
                                if (proposalrec.Apttus_QPConfig__ConfigurationFinalizedDate__c != null && proposalrec.R00N70000001yUfBEAU__r.size() > 0) {
                                    needsRepricing = true;
                                }
                                  
                            }
                            system.debug(SelectedPartnerId + '----List save----' + OppPartnerList);
                            if(proposalrec.Apttus_Proposal__Primary__c){
                                for(Opportunity_Partner__c OppPartner : OppPartnerList){
                                    if(OppPartner.Id == SelectedPartnerId){
                                        OppPartner.Is_Primary__c = true;
                                    }else{
                                        OppPartner.Is_Primary__c = false;
                                    }
                                }
                                update OppPartnerList;
                            }
                        }
                        
                        /*PageReference pr = new ApexPages.StandardController(proposalrec).view();
                        pr.setRedirect(true);
                        return pr;*/
                    }
                    else if(IsResellerAndIncumbentPartner == false && OppRecord != null){ 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Reseller Partner is Not an Incumbent Partner. Approval is needed to Make this as Primary.'));
                        haserror = true;
                        partnerModel = false;
                        //ShowSubmitButton = true;
                        return null;
                    }
                }
                
                system.debug('--SelectedDistributorPartnerId--' + SelectedDistributorPartnerId);
                //This if condition is for Distributor
                if(SelectedDistributorPartnerId != null && SelectedDistributorPartnerId != ''){
                    
                    Opportunity_Partner__c OppPartnerRec = new Opportunity_Partner__c();
                    List<Opportunity_Partner__c> oppPartnerRecs = [Select Id, Name,
                                                                            Account__c,
                                                                            Account__r.Name,
                                                                            Approval_Status__c,
                                                                            Is_Primary__c,
                                                                            Opportunity__c,
                                                                            /**Opportunity__r.Name,**/
                                                                            Partner_Type__c 
                                                                            from 
                                                                            Opportunity_Partner__c 
                                                                            where 
                                                                            Id =: SelectedDistributorPartnerId
                                                                            And
                                                                            Partner_Type__c = 'Distributor'];
                    if(!oppPartnerRecs.isEmpty()){
                        OppPartnerRec = oppPartnerRecs[0];
                    }
                    /*
                    Opportunity OppRecord = new Opportunity();
                    List<Incumbent_Partner__c> IncumbentPartnerAccountList = new List<Incumbent_Partner__c>();
                    
                    List<Opportunity> oppRecords = new List<Opportunity>();
                    
                    if(proposalrec.Apttus_Proposal__Opportunity__c != null){
                        oppRecords = [select Id, Name, AccountId,RecordTypeId,RecordType.Name from Opportunity where Id=:proposalrec.Apttus_Proposal__Opportunity__c and (Type = 'Existing Customer (Add On)' or Type = 'Existing Customer (Renewal)')];
                        if(!oppRecords.isEmpty()){
                            //if(){
                            OppRecord = oppRecords[0];
                        }
                    }*/
                    
                    /*if(OppRecord != null && OppRecord.AccountId != null){
                        IsDistributorAndIncumbentPartner = true;
                        IncumbentPartnerAccountList = [select Id, Name, Account__c,
                                                                    Incumbent_Partner_Account__c,
                                                                    Partner_Type__c 
                                                                    from 
                                                                    Incumbent_Partner__c 
                                                                    where 
                                                                    Account__c =: OppRecord.AccountId 
                                                                    And  
                                                                    Partner_Type__c = 'Distributor'];
                        if(IncumbentPartnerAccountList.size() > 0){
                            for(Incumbent_Partner__c IncumPartner : IncumbentPartnerAccountList){
                                if(IncumPartner.Incumbent_Partner_Account__c == OppPartnerRec.Account__c){
                                    IsDistributorAndIncumbentPartner = true;
                                }
                            }
                        }else{
                            IsDistributorAndIncumbentPartner = false;
                        }
                        
                        if(OppPartnerRec.Approval_Status__c == 'Approved'){
                            IsDistributorAndIncumbentPartner = true;
                        }
                    }*/
                    //if(IsDistributorAndIncumbentPartner == true || oppRecords.size() == 0 || OppPartnerRec.Approval_Status__c == 'Approved'){
                        if(OppPartnerRec != null){
                            /*if(proposalrec.Apttus_QPConfig__BillToAccountId__c != OppPartnerRec.Account__c && OppPartnerRec.Account__c != null) {
                                proposalrec.Apttus_QPConfig__BillToAccountId__c = OppPartnerRec.Account__c;
                                update proposalrec;
                            }*/
                            if(proposalrec.Distributor__c != OppPartnerRec.Account__c && OppPartnerRec.Account__c != null) {
                                proposalrec.Distributor__c = OppPartnerRec.Account__c;
                                update proposalrec;
                            }
                        //}
                        
                        if(proposalrec.Apttus_Proposal__Primary__c){
                            for(Opportunity_Partner__c OppPartner : OppDistributorPartnerList){
                                if(OppPartner.Id == SelectedDistributorPartnerId){
                                    OppPartner.Is_Primary__c = true;
                                }
                                else{
                                    OppPartner.Is_Primary__c = false;
                                }
                            }
                            system.debug(SelectedDistributorPartnerId + '----List save----' + OppDistributorPartnerList);
                            update OppDistributorPartnerList;
                        }
                        
                    }
                    /*else if(IsDistributorAndIncumbentPartner == false && OppRecord != null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Distributor Partner is Not an Incumbent Partner. Approval is needed to Make this as Primary.'));
                        haserror = true;
                        //ShowSubmitButton = true;
                        return null;
                    }*/
                }
                
                if(partnerModel == true){
                    Confirm_Reprice_controller ctrl = new Confirm_Reprice_controller();
                    ctrl.proplst = new List<Apttus_Proposal__Proposal__c>{proposalrec};
                    ctrl.partnerProgram = selectedPartnerProgram;
                    ctrl.partnerprogSwitch();

                }else if(needsRepricing == true){
                    PageReference pr = new PageReference('/apex/RepriceApttusProposals?proposalIds=' + proposalrec.Id);
                    pr.setRedirect(true);
                    return pr;
                }
                PageReference pr = new ApexPages.StandardController(proposalrec).view();
                pr.setRedirect(true);
                return pr;
                
            }
        }
        catch(Exception e){
            system.debug('--Message--'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            haserror=true;
            partnerModel = false;
            return null;
        }
        return null;
    }

    public void AssignPartnerId(){
        system.debug(SelectedPartnerId + '----List asign----' + OppPartnerList);
    }
    
    public void AssignDistributorPartnerId(){
        system.debug(SelectedDistributorPartnerId + '----SelectedDistributorPartnerId----' + OppDistributorPartnerList);
    }
    
    /**
        Updated BY : Sateesh U 
        This method is used To submit the selected Partner for Approval
    **/
    public string selectedPartnerIdForApproval{get;set;}
    public void submitForApproval(){
        haserror = false;
        try{
            system.debug('--AttachmentId--'+AttachmentId);
            if(AttachmentId != null && AttachmentId != ''){
                Attachment attach = [select Id,Name,Body,ParentId from Attachment where Id=:AttachmentId limit 1];
                ContentVersion cv = new ContentVersion(ContentLocation = 'S',PathOnClient = attach.Name,
                                                                   Origin = 'H',OwnerId = UserInfo.getUserId(),Title = attach.Name,VersionData = attach.Body);
                insert cv;
                List<ContentVersion> ContentVersioinList = [select ContentDocumentId from ContentVersion where Id = :cv.Id limit 1];
                if(ContentVersioinList.size()>0){
                    ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = attach.ParentId, ContentDocumentId = ContentVersioinList[0].ContentDocumentId, ShareType = 'I');
                    insert cl;
                }
            }
            
            system.debug('---Submitted---' + selectedPartnerIdForApproval);
            Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
            appReq.setComments('Submitting request for Partner');
            appReq.setObjectId(selectedPartnerIdForApproval);
            Approval.ProcessResult result = Approval.process(appReq);
            oppPartnerRecords = new List<OppPartnerInner>();
            OppPartnerList = new List<Opportunity_Partner__c>();
            getPartnersData();
        }
        catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, exp.getMessage()));
            haserror = true;
        }
    }

    /*public class OptyPartnerWrap{
        public ID partnerid{get;set;}
        public Opportunity_Partner__c oppPartner{get;set;}
    }*/
    
    /*public PageReference saveAction() 
    {
        try
        {
            if(selectedPartner!=null && selectedPartner!='')
            {
                ID partnerid =ID.valueof(selectedPartner);
                ID GAMNAMId =null;
                String Partnername = opptypartnermap.containskey(partnerid) && opptypartnermap.get(partnerid) != null ? opptypartnermap.get(partnerid).AccountTo.Name : '' ;
                if(Partnername != '' && Partnername != null){
                    Triggers_Switch__c tg = Triggers_Switch__c.getValues('Update_GAM_NAM');
                    if(tg != null && tg.Execute__c){
                        Map<String, Partner_GAM_NAM_Mapping__c> stageforecastmap =  new Map<String, Partner_GAM_NAM_Mapping__c>();
                        
                        for(Partner_GAM_NAM_Mapping__c stg: Partner_GAM_NAM_Mapping__c.getAll().Values()){
                            if(Partnername.containsIgnoreCase(stg.Name)){
                                GAMNAMId = stg.GAM_NAM_Id__c;
                                break;
                            }
                        }
                    }
                }
                
                if (proposalrec.Apttus_QPConfig__BillToAccountId__c != partnerId) {
                    proposalrec.Apttus_QPConfig__BillToAccountId__c=partnerid;
                    update proposalrec;
                    
                    if (proposalrec.Apttus_QPConfig__ConfigurationFinalizedDate__c != null && proposalrec.R00N70000001yUfBEAU__r.size() > 0) {
                        needsRepricing = true;
                    }
                    
                    Opportunity opp = new Opportunity(Id =  proposalrec.Apttus_Proposal__Opportunity__c, GAM_NAM__c =GAMNAMId);
                    update opp;
                }
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error while saving the Quote'));
            haserror=true;
            return null;
    
        }
        if (needsRepricing) {
            PageReference pr = new PageReference('/apex/RepriceApttusProposals?proposalIds=' + proposalrec.Id);
            pr.setRedirect(true);
            return pr;
        } else {
            PageReference pr = new ApexPages.StandardController(proposalrec).view();
            pr.setRedirect(true);
            return pr;
        }
    }*/
    
    public PageReference cancelAction(){
        PageReference pr = new ApexPages.StandardController(proposalrec).view();
        pr.setRedirect(true);
        return pr;
    }

    /*public class OpportunityPartnerWrap{
    
        public ID partnerid{get;set;}
        public OpportunityPartner oppPartner{get;set;}
    
        public OpportunityPartnerWrap(Id partnerid, OpportunityPartner oppPartner)
        {
            this.partnerid=partnerid;
            this.oppPartner=oppPartner;
        }
    
    
    }*/
    
    /**public void SubmitPartnerForApproval(){
        try{
            IsInApproval = false;
            List<Opportunity_Partner__c> oppPartnerRecs = new List<Opportunity_Partner__c>();
            Opportunity_Partner__c oppPartnerRec = new Opportunity_Partner__c();
            
            if(SelectedPartnerId != null){
                oppPartnerRecs = [Select Id,Name,Account__c,Account__r.Name,Approval_Status__c,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c from Opportunity_Partner__c where Id=:SelectedPartnerId];
            }
            if(oppPartnerRecs.size()>0){
                oppPartnerRec = oppPartnerRecs[0];
            }
            
            if(oppPartnerRec.Approval_Status__c == 'Pending'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'This Record is already in approval'));
                ShowSubmitButton = false;
                haserror = false;
                IsInApproval = true;
            }else{
                if(SelectedPartnerId != null && SelectedPartnerId != ''){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval automatically');
                    req1.setObjectId(SelectedPartnerId);
                    req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
                    // Submit the approval request for the Opportunity
                    Approval.ProcessResult result = Approval.process(req1);
                    system.debug('Result '+result.getInstanceStatus());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Approval Submitted Successfully!'));
                    haserror = false;
                    ShowSubmitButton = false;
                }
            }
            
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
            haserror = false;
            ShowSubmitButton = false; 
        }
    }**/
}