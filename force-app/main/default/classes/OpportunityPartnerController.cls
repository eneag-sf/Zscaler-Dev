public with sharing class OpportunityPartnerController {
    
    /**
    	Updated BY : Sateesh U 
    	This method is used To get All Opportunity Partners data
    **/
    @AuraEnabled
    public static InnerClass GetOppPartnersDetais(String OppId){
        List<Opportunity_Partner__c> OppPartnersList = new List<Opportunity_Partner__c>();
        boolean IsResellerPresent = false;
        boolean IsTechPartnerPresent = false;
        boolean IsIntegratorPresent = false;
        boolean IsDistributorPresent = false;
        boolean isDealRegPresent = false;
        boolean isArchPresent = false;
        boolean isPOVPresent = false;
        
        if(OppId != null){
            OppPartnersList = [Select Id,Name,Account__c, Account__r.Model_Type_Partner__c, Partner_Program__c, Account__r.Name,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c, Account__r.Partner_Type__c,Restrict_Partner_Program_Change__c from Opportunity_Partner__c where Opportunity__c = :OppId];
            List<Opportunity> opplst = [Select Id, Deal_Reg__r.Partner_Category__c, StageName from Opportunity where Id = :OppId];
            for(Opportunity_Partner__c OppPartner:OppPartnersList){
                if(OppPartner.Partner_Type__c == 'Distributor'){
                    IsDistributorPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'System Integrator'){
                    IsIntegratorPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'Tech Partner'){
                    IsTechPartnerPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'Reseller'){
                    IsResellerPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'Deal Reg'){
                    isDealRegPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'Architecture Workshop'){
                    isArchPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'POV'){
                    isPOVPresent = true;
                }
            }
            InnerClass Inn = new InnerClass();
            Inn.PartnersList = OppPartnersList;
            Inn.IsResellerPresent = IsResellerPresent;
            Inn.IsTechPartnerPresent = IsTechPartnerPresent;
            Inn.IsIntegratorPresent = IsIntegratorPresent;
            Inn.IsDistributorPresent = IsDistributorPresent;
            Inn.isDealRegPresent = isDealRegPresent;
            Inn.isPOVPresent = isPOVPresent;
            Inn.isArchPresent = isArchPresent;
            Inn.partnerProgramPickvals = sObjectPicklistValuesHelper.getPickListValues('Opportunity_Partner__c', 'Partner_Program__c');
            Boolean showactions = false;
            if(!opplst.isEmpty()){
                if(opplst[0].Stagename != Label.Stage_5_Contracts_Complete && opplst[0].Stagename != Label.Stage_6_Closed_Won && opplst[0].Stagename != Label.Stage_7_Closed_Lost){
                    showactions =  true;
                }else{
                    Show_Actions_on_Manage_Partner__c proftoskip = Show_Actions_on_Manage_Partner__c.getInstance(Userinfo.getProfileId());
                    Show_Actions_on_Manage_Partner__c usertoskip = Show_Actions_on_Manage_Partner__c.getInstance(Userinfo.getUserId());
                    if(proftoskip.Id != null || usertoskip.Id != null){
                        showactions = true;
                    }
                }
            }
            Inn.showEditandDelete = showactions;
            return Inn;
        }
        return null;
    }
    
    public class InnerClass{
        @AuraEnabled
        public List<Opportunity_Partner__c> PartnersList{get;set;}
        @AuraEnabled
        public List<String> partnerProgramPickvals{get;set;}
        @AuraEnabled
        public boolean IsResellerPresent{get;set;}
        @AuraEnabled
        public boolean IsTechPartnerPresent{get;set;}
        @AuraEnabled
        public boolean IsIntegratorPresent{get;set;}
        @AuraEnabled
        public boolean IsDistributorPresent{get;set;}
        @AuraEnabled
        public boolean isDealRegPresent{get;set;}
        @AuraEnabled
        public boolean isPOVPresent{get;set;}
        @AuraEnabled
        public boolean isArchPresent{get;set;}
        @AuraEnabled
        public boolean showEditandDelete{get;set;}
    }
    
    /**
    	Updated BY : Sateesh U 
    	This method is used To get Opportunity details
    **/
    @AuraEnabled
    public static Opportunity GetOpportunity(String OppId){
        Opportunity Opprec = new Opportunity();
        if(OppId != null){
            Opprec = [Select Id,Name from Opportunity where Id=:OppId];
        }
        return Opprec;
    }
    
    /**
    	Updated BY : Sateesh U 
    	This method is used To save the selected partner records.
    **/
    @AuraEnabled
    public static Map<string,string> SavePartnerRec(string OppId, string PartnerRecords, string PartnerType){
        Map<string,string> ResultMap = new Map<string,string>();
        Map<string,string> IdvsTypeMap = new Map<string,string>();
        List<Opportunity_Partner__c> oppparttoDelete = new List<Opportunity_Partner__c>();
        Map<Id, Opportunity> opptoUpdate = new Map<Id, Opportunity>();
        List<Opportunity_Partner__c> OppPartnersList = [Select Id,Name,Account__c,Account__r.Name,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c from Opportunity_Partner__c where Opportunity__c = :OppId];
        for(Opportunity_Partner__c OppPartner:OppPartnersList){
            IdvsTypeMap.put(OppPartner.Account__c+'-'+OppPartner.Partner_Type__c,OppPartner.Id);
            if(OppPartner.Partner_Type__c == PartnerType && (PartnerType == 'Deal Reg' || PartnerType == 'Architecture Workshop' || PartnerType == 'POV')){
                oppparttoDelete.add(OppPartner);
            }
        }
        boolean IsSameAccount = false;
        boolean IsPrimarySelected = false;
        string SelectedPrimaryPartner = '';
        string SelectedPrimaryAccount = '';
        
        List<Apttus_Proposal__Proposal__c> PrimaryProposalList = [Select Id,Name from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c=:OppId and Apttus_Proposal__Primary__c = true];
        /*if(PrimaryProposalList.size()>0 && PartnerType == 'Reseller'){
            ResultMap.put('State', 'Validation');
            ResultMap.put('Message','You can not change the Primary Reseller Partner if Opportunity has Primary Proposal. You can change the Primary Reseller from the Proposal');
        }else{*/
            //try{
                list<WrapperClass> PartnerRecsList = new list<WrapperClass>();
                system.debug('--PartnerRecords--'+PartnerRecords);
                
                PartnerRecsList = (List<WrapperClass>)System.JSON.deserialize(PartnerRecords, List<WrapperClass>.class); 
                system.debug('---List--'+PartnerRecsList);
                
                List<Opportunity_Partner__c> PartnersList = new List<Opportunity_Partner__c>();
                Set<Id> accIds = new Set<Id>();
                Map<Id, String> accpartnermap = new Map<Id, String>();
                for(WrapperClass Wrap: PartnerRecsList){
                    if(Wrap.SelectedRecord != null){
                        accIds.add(Wrap.SelectedRecord.Id);
                    }
                }
                if(!accIds.isEmpty()){
                    for(Account acc: [Select Id, Model_Type_Partner__c from account where id in :accIds]){
                        accpartnermap.put(acc.id, acc.Model_Type_Partner__c == 'Both'?  'Partner Summit': acc.Model_Type_Partner__c);
                    }
                }
                for(WrapperClass Wrap:PartnerRecsList){
                    system.debug(IdvsTypeMap+'---Map---'+IdvsTypeMap.get(Wrap.SelectedRecord.Id+'-'+PartnerType));
                    if(IdvsTypeMap.get(Wrap.SelectedRecord.Id+'-'+PartnerType) == null){
                        
                        Opportunity_Partner__c Partner = new Opportunity_Partner__c();
                        if(Wrap.SelectedRecord != null){
                            Partner.Account__c = Wrap.SelectedRecord.Id;
                            if(Partner.Account__c != null && accpartnermap.containsKey(Partner.Account__c)){
                                Partner.Partner_Program__c = accpartnermap.get(Partner.Account__c);
                                if(Wrap.IsRadioChecked == true){
                                    if(Partner.Partner_Program__c == 'Both')
                                    {
                                        opptoUpdate.put(OppId, new Opportunity(Id = OppId, Primary_Partner_Program__c = 'Partner Summit'));
                                    }
                                    else
                                    {
                                        opptoUpdate.put(OppId, new Opportunity(Id = OppId, Primary_Partner_Program__c = Partner.Partner_Program__c));
                                    }
                                }
                            }
                            
                        }
                        if(Wrap.IsRadioChecked == true){
                            IsPrimarySelected = true;
                            SelectedPrimaryPartner = PartnerType;
                            SelectedPrimaryAccount = Wrap.SelectedRecord.Id;
                        }
                        if(PartnerType == 'Deal Reg' || PartnerType == 'Architecture Workshop' || PartnerType == 'POV'){
                            Partner.Is_Primary__c = true;
                            if(PartnerType == 'Deal Reg'){
                                if(opptoUpdate.containskey(OppId)){
                                    Opportunity opp = opptoUpdate.get(OppId);
                                    opp.Deal_Reg_Margin__c = Wrap.SelectedRecord.Id;
                                    opptoUpdate.put(OppId, opp);
                                }else{
                                    opptoUpdate.put(OppId, new Opportunity(Id = OppId, Deal_Reg_Margin__c = Wrap.SelectedRecord.Id));
                                }
                            }else if(PartnerType == 'Architecture Workshop'){
                                if(opptoUpdate.containskey(OppId)){
                                    Opportunity opp = opptoUpdate.get(OppId);
                                    opp.Architectural_Workshop_Margin__c = Wrap.SelectedRecord.Id;
                                    opptoUpdate.put(OppId, opp);
                                }else{
                                    opptoUpdate.put(OppId, new Opportunity(Id = OppId, Architectural_Workshop_Margin__c = Wrap.SelectedRecord.Id));
                                }
                            }else if(PartnerType == 'POV'){
                                if(opptoUpdate.containskey(OppId)){
                                    Opportunity opp = opptoUpdate.get(OppId);
                                    opp.POV_Margin__c = Wrap.SelectedRecord.Id;
                                    opptoUpdate.put(OppId, opp);
                                }else{
                                    opptoUpdate.put(OppId, new Opportunity(Id = OppId, POV_Margin__c = Wrap.SelectedRecord.Id));
                                }
                            }
                            
                        }else{
                            Partner.Is_Primary__c = Wrap.IsRadioChecked;
                        }
                        Partner.Opportunity__c = OppId;
                        Partner.Partner_Type__c = PartnerType;
                        PartnersList.Add(Partner);
                        IdvsTypeMap.put(Wrap.SelectedRecord.Id+'-'+PartnerType,Wrap.SelectedRecord.Id);
                    }else{
                        IsSameAccount = true;
                    }
                }
                
                if(PrimaryProposalList.size()>0 && PartnerType == 'Reseller' && IsPrimarySelected == true){
                    ResultMap.put('State', 'Validation');
                    ResultMap.put('Message','You can not change the Primary Reseller Partner if Opportunity has Primary Proposal. You can change the Primary Reseller from the Proposal');
                }else if(PrimaryProposalList.size()>0 && PartnerType == 'Distributor' && IsPrimarySelected == true){
                    ResultMap.put('State', 'Validation');
                    ResultMap.put('Message','You can not change the Primary Distributor Partner if Opportunity has Primary Proposal. You can change the Primary Distributor from the Proposal');
                }else if(IsSameAccount == false){
                    if(PartnersList.size()>0){
                        if(IsPrimarySelected == true){
                            List<Opportunity_Partner__c> Partners = [Select Id,Name,Account__c,Account__r.Name,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c from Opportunity_Partner__c where Opportunity__c = :OppId and Partner_Type__c = :SelectedPrimaryPartner And Account__c != :SelectedPrimaryAccount];
                            for(Opportunity_Partner__c OppPartner:Partners){
                                OppPartner.Is_Primary__c = false;
                            }
                            update Partners;
                        }
                        insert PartnersList;
                    }
                    if(!oppparttoDelete.isEmpty()){
                        DeleteOpportunityPartner.deleteopppart(oppparttoDelete);
                    }
                    if(opptoUpdate != null && !opptoUpdate.isEmpty()){
                        update opptoUpdate.values();
                    }
                    ResultMap.put('State','Success');
                    ResultMap.put('Message','Partner Added Successfully');
                }else{
                    ResultMap.put('State','Validation');
                    ResultMap.put('Message', 'Same Partner Already Added. Please select another Partner');
                }
            /*}Catch(Exception ex){
                ResultMap.put('State','Error');
                ResultMap.put('Message',ex.getMessage());
            }*/
        //}
        return ResultMap;
    }

    @AuraEnabled
    public static Map<string,string> updatePartnerProgram(String PartnerId, String Program, String OppId){
        Map<string,string> ResultMap = new Map<string,string>();
        if(PartnerId != null && PartnerId != ''){
            List<Opportunity_Partner__c> oppPartlst = [Select Id from Opportunity_Partner__c where Id = :PartnerId and Is_Primary__c = true];
            Opportunity_Partner__c opPart = new Opportunity_Partner__c(Id=PartnerId, Partner_Program__c=Program);
            update opPart;
            if(OppId != null && OppId != '' && !oppPartlst.isEmpty()){
                String programDate = '';
                if(Program == 'Both')
                {
                    programDate = 'Partner Summit';
                }
                else {
                    programDate = Program;
                }
                Opportunity opp = new Opportunity(Id = OppId, Primary_Partner_Program__c=programDate);
                update opp;
            }
            ResultMap.put('State','Success');
            ResultMap.put('Message','Partner Program Updated Successfully');
        }
        return ResultMap;
    }
    
    /**
    	Updated BY : Sateesh U 
    	This method is used To delete the Selected partner record.
    **/
    @AuraEnabled
    public static Map<string,string> DeletePartnerRec(string PartnerId){
        Map<string,string> ResultMap = new Map<string,string>();
        List<Opportunity> opptoUpdate = new List<Opportunity>();
        try{
            if(PartnerId != null){
                List<Opportunity_Partner__c> oplst = [select Id, Opportunity__c, Partner_Type__c, Name from Opportunity_Partner__c Where Id=:PartnerId];
                if(!oplst.isEmpty()){
                    if(oplst[0].Opportunity__c != null && oplst[0].Partner_Type__c == 'Architecture Workshop'){
                        Opportunity opp = new Opportunity(Id = oplst[0].Opportunity__c, Architectural_Workshop_Margin__c = null);
                        opptoUpdate.add(opp);
                    } else if(oplst[0].Opportunity__c != null && oplst[0].Partner_Type__c == 'POV'){
                        Opportunity opp = new Opportunity(Id = oplst[0].Opportunity__c, POV_Margin__c = null);
                        opptoUpdate.add(opp);
                    }
                    if(!opptoUpdate.isEmpty()){
                        update opptoUpdate;
                    }
                    DeleteOpportunityPartner.deleteopppart(oplst);
                }
                ResultMap.put('State','Success');
                ResultMap.put('Message','Partner Removed Successfully');
            }
        }Catch(Exception ex){
            ResultMap.put('State','Error');
            ResultMap.put('Message',ex.getMessage());
        }
        return ResultMap;
    }
    
    public class WrapperClass{
        
        @AuraEnabled
        public Account SelectedRecord{get;set;}
        @AuraEnabled
        public boolean IsRadioChecked{get;set;}
    }
    
    /**
       Updated BY : Sateesh U
       This method is used To Make the selected partner as primary
       Reseller and Distributor partners are selected as primary only when no Primary proposal is created. If primary proposal created they can make changes from partner selection page on quote.
    **/
    @AuraEnabled
    public static Map<string,string> UpdatePrimaryPartner(string PartnerId,string Type,string OppId){
        Map<string,string> ResultMap = new Map<string,string>();
        Opportunity_Partner__c OppPartnerRec = new Opportunity_Partner__c();
        List<Opportunity_Partner__c> OppPartnerList = new List<Opportunity_Partner__c>();
        
        if(PartnerId != null && OppId != null){
            List<Apttus_Proposal__Proposal__c> PrimaryProposalList = [Select Id,Name from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c=:OppId and Apttus_Proposal__Primary__c = true];
            if(PrimaryProposalList.size()>0 && Type == 'Reseller'){
                ResultMap.put('State','Validation');
                ResultMap.put('Message','You can not change the Primary Reseller Partner if Opportunity has Primary Proposal. You can change the Primary Reseller from the Proposal');
            }else if(PrimaryProposalList.size()>0 && Type == 'Distributor'){
                ResultMap.put('State','Validation');
                ResultMap.put('Message','You can not change the Primary Distributor Partner if Opportunity has Primary Proposal. You can change the Primary Distributor from the Proposal');
            }else{
                try{
                    OppPartnerList = [Select Id,Name,Account__c,Is_Primary__c,Opportunity__c,Partner_Type__c from Opportunity_Partner__c where Opportunity__c=:OppId and Is_Primary__c = true And Partner_Type__c=:Type];
                    for(Opportunity_Partner__c OppPartner:OppPartnerList){
                        OppPartner.Is_Primary__c = false;
                    }
                    update OppPartnerList;
                    OppPartnerRec = [Select Id,Name,Account__c,Is_Primary__c,Opportunity__c,Partner_Type__c, Partner_Program__c from Opportunity_Partner__c where Id=:PartnerId];
                    OppPartnerRec.Is_Primary__c = true;
                    update OppPartnerRec;
                    Opportunity opp = new Opportunity(Id=OppId, Primary_Partner_Program__c=OppPartnerRec.Partner_Program__c);
                    update opp;
                    ResultMap.put('State','Success');
                    ResultMap.put('Message','Partner Updated Successfully');
                }catch(exception ex){
                    ResultMap.put('State','Error');
                    ResultMap.put('Message',ex.getMessage());
                }
            }
        }
        return ResultMap;
    }
    
    @AuraEnabled
    public static Map<string,string> UuncheckPrimaryPartner(string PartnerId,string Type,string OppId){
        Map<string,string> ResultMap = new Map<string,string>();
        Opportunity_Partner__c OppPartnerRec = new Opportunity_Partner__c();
        List<Opportunity_Partner__c> OppPartnerList = new List<Opportunity_Partner__c>();
        
        if(PartnerId != null && OppId != null){
            try{
                OppPartnerRec = [Select Id,Name,Account__c,Is_Primary__c,Opportunity__c,Partner_Type__c from Opportunity_Partner__c where Id=:PartnerId];
                OppPartnerRec.Is_Primary__c = false;
                update OppPartnerRec;
                ResultMap.put('State','Success');
                ResultMap.put('Message','Partner Updated Successfully');
            }catch(exception ex){
                ResultMap.put('State','Error');
                ResultMap.put('Message',ex.getMessage());
            }
        }
        return ResultMap;
    }
}