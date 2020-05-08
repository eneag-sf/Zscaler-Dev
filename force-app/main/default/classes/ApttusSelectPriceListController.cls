public class ApttusSelectPriceListController {
    public Boolean isPriceListSwitchMode { get; set; }
    public Boolean ispartnerProgramChange{ get; set; }
    public String partnerProgram{ get; set; }
    public Id opptyId { get; set; }
    public String redirectTo { get; set; }
    public String retUrl { get; set; }
    public String selectedPriceListId { get; set; }
    public String proposalId {get; set;}
    public String originalPriceListId { get; set; }

    public Map<String, Id> mapPriceLists { get; set; }

    public ApttusSelectPriceListController() {
        
    }
    
    public Boolean isAdmin{
        get{
            List<Profile> proflst = [Select Id from profile where name in ('System Administrator') and Id = :Userinfo.getprofileId()];
            if(proflst.isEmpty() && Users_to_Exempt_for_FY17__c.getInstance(Userinfo.getuserId()).Id == null){
                return false;
            }else{
                return true;
            }
        
        } set;
    
    }

    public ApttusSelectPriceListController(ApexPages.StandardController controller) {
        opptyId = ApexPages.currentPage().getParameters().get('Id');
        proposalId = ApexPages.currentPage().getParameters().get('proposalId');
        originalPriceListId = ApexPages.currentPage().getParameters().get('originalPriceListId');
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');

        if (proposalId != null && proposalId != '') {
            isPriceListSwitchMode = true;
        } else {
            isPriceListSwitchMode = false;
        }
        ispartnerProgramChange = false;
    }

    public List<SelectOption> getPriceLists() {
        List<SelectOption> lstPriceListOptions = new List<SelectOption>();
        lstPriceListOptions.add(new SelectOption('', '-- Select --'));
        mapPriceLists = new Map<String, Id>();
        for (Apttus_Config2__PriceList__c priceList : [SELECT Id, Name FROM Apttus_Config2__PriceList__c WHERE Apttus_Config2__Active__c = true AND Name LIKE 'Zscaler FY%']) {
            if(isAdmin || priceList.Name == 'ZScaler FY2020 Price List'){
                lstPriceListOptions.add(new SelectOption(priceList.Name, priceList.Name));
                mapPriceLists.put(priceList.Name, priceList.Id);
            }
        }

        return lstPriceListOptions;
    }

    public PageReference proceed() {
        PageReference returnUrl;

        if (isPriceListSwitchMode
            && originalPriceListId == mapPriceLists.get(selectedPriceListId)) {
            return new PageReference('/' + proposalId);
        }

        if (!mapPriceLists.containsKey(selectedPriceListId)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Select a valid price list'));
            return null;
        }

        //Update the price list based on user selection
        if (isPriceListSwitchMode) {
            Savepoint sp = Database.setSavePoint();
            List<Apttus_Config2__ProductConfiguration__c> lstProdConfigs = new List<Apttus_Config2__ProductConfiguration__c>();
            List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            List<APTS_Year_Wise_Split__c> lstYearWiseSplit = new List<APTS_Year_Wise_Split__c>();
            List<Year_Wise_Split__c> lstYearWiseSplit_new = new List<Year_Wise_Split__c>();

            Apttus_Proposal__Proposal__c proposalToBeUpdated = new Apttus_Proposal__Proposal__c(Id = proposalId, Apttus_QPConfig__PriceListId__c = mapPriceLists.get(selectedPriceListId), Apttus_Proposal__Approval_Stage__c = 'Draft', Apttus_QPApprov__Approval_Status__c = 'Not Submitted', Needs_Repricing__c = false);
            if(ispartnerProgramChange){
                proposalToBeUpdated.Model_Type_Partner__c = partnerProgram;
            }
            for (Apttus_Config2__ProductConfiguration__c config : [SELECT Id, Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c = :proposalId]) {
                lstProdConfigs.add(config);
            }

            for (APTS_Year_Wise_Split__c split : [SELECT Id, APTS_Proposal__c FROM APTS_Year_Wise_Split__c WHERE APTS_Proposal__c = :proposalId]) {
                lstYearWiseSplit.add(split);
            }
            
            for (Year_Wise_Split__c split : [SELECT Id, Quote_Proposal__c FROM Year_Wise_Split__c WHERE Quote_Proposal__c = :proposalId]) {
                lstYearWiseSplit_new.add(split);
            }

            for (Apttus_Proposal__Proposal_Line_Item__c config : [SELECT Id, Apttus_Proposal__Proposal__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c = :proposalId]) {
                lstProposalLineItems.add(config);
            }

            try {
                update proposalToBeUpdated;
                delete lstProdConfigs;
                delete lstProposalLineItems;
                delete lstYearWiseSplit;
                delete lstYearWiseSplit_new;

                returnUrl =  new PageReference('/' + proposalId);
            } catch (Exception ex) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
                System.debug('>>>> Unable to switch price list: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
                returnUrl = null;
            }

        } else {
            returnUrl = new PageReference('/apex/ApttusCreateNewQuotePage?id=' + opptyId + '&pricelistid=' + selectedPriceListId);
        }

        return returnUrl;
    }

    public PageReference cancel() {
        return new PageReference('/' + ((isPriceListSwitchMode == true) ? proposalId : opptyId));
    }
}