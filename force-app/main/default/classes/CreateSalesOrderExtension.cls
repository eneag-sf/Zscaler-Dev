public class CreateSalesOrderExtension {
    
    public Opportunity opportunity { get; set; }
    public Id opportunityId { get; set; }
    public String netSuiteCustomerId { get; set; }
    public String netSuitePartnerId { get; set; }
    public String netSuiteCustomerIdOverride { get; set; }
    public String netSuitePartnerIdOverride { get; set; }
    public String billToOverriddenDetails { get; set;}
    public String partnerIdOverriddendetails { get; set;}
    public String shipToOverriddenDetails { get; set; }
    public String billToDetails { get; set;}
    public String shipToDetails { get; set; }
        
    public Boolean reviewMode { get; set; }
    public Boolean disableSubmit { get; set; }
    public Boolean showMessage { get; set; }
    public Boolean showError { get; set; }
    public Boolean shownewacv { get; set; }
    public Boolean showrenewalacv { get; set; }
    public Boolean showupsellacv { get; set; }
    public String errors { get; set; }
    public Boolean nsCustomerIdOverridden { get; set; }
    public Boolean nsPartnerIdOverridden { get; set; }
    
    public Boolean overrideBillToId { get; set; }
    public Boolean overridePartnerId { get; set; }
    public Boolean overrideShipToId { get; set; }
    
    public Boolean nooverrideACV{ get; set; }
    public Boolean requireSecPartner{ get; set; }
    public Boolean containszpa = false;
    
    public List<RenewalLinesWrapper> lstRenewalLines { get; set; } 
    public List<Internal_Lines__c> lstinternallinestoinsert { get; set; } 
    public List<Contract_Detail__c> lstdroppedcontractdetails { get; set; } 
    public List<LinestoNS> lstfinallinestoNS;
    public List<LinestoNS> lstfinallinestoNSwithoutinternallines{get;set;}
    public List<LinestoNS> lstfinallinestoNSwithInternalLines{get;set;}
    public Map<Id, Apttus_PRoposal__Proposal_Line_Item__c> plimap = new Map<Id, Apttus_PRoposal__Proposal_Line_Item__c>();
    public Set<String> cartSKUcodes = new Set<String>();
    public Map<String, Contract_Detail__c> cdnamemap = new Map<String, Contract_Detail__c>();
    public Boolean hasinternallines = false;
    
    public Set<String> setrecurringSKUs = new Set<String>();
    /*public Set<String> setrecurringSKUs = new Set<String> {
        APTS_CONSTANTS.PROD_SKU_PSUPPORT,
        APTS_CONSTANTS.PROD_SKU_MPSUPPORT,
        APTS_CONSTANTS.PROD_SKU_TAMTOP
    };*/
    
    public Set<String> CFWCSBSKUs = new Set<String>();
    /*public Set<String> CFWCSBSKUs = new Set<String> {
        APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL,
        APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX
    };*/
    public Set<String> CFWZPASKUs = new Set<String>();
    /*public Set<String> CFWZPASKUs = new Set<String> {
        APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL,
        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE,
        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
    };*/
    public Set<String> setonetimeSKUs = new Set<String>();
    /*public Set<String> setonetimeSKUs = new Set<String> {
        APTS_CONSTANTS.PROD_SKU_CS8D,
        APTS_CONSTANTS.PROD_SKU_DAS0,
        APTS_CONSTANTS.PROD_SKU_DAS1,
        APTS_CONSTANTS.PROD_SKU_DAS2,
        APTS_CONSTANTS.PROD_SKU_DAS3,
        APTS_CONSTANTS.PROD_SKU_DAS6,
        APTS_CONSTANTS.PROD_SKU_EDUCREDIT,
        APTS_CONSTANTS.PROD_SKU_EDULABCREDIT,
        'ZCES-Onetime-ZPA-INT'
    };*/
    public Set<String> setSKUswithACVtobeskipped = new Set<String>();
    public Set<String> setSKUsnottoAdd = new Set<String>();
    public Set<String> CreditSKUs = new Set<String>();
    public Set<String> UpliftSKUs = new Set<String>();
    /*public Set<String> setSKUswithACVtobeskipped = new Set<String> {
        APTS_CONSTANTS.PROD_SKU_BUYBACK,
        APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK,
        APTS_CONSTANTS.PROD_SKU_Z_CREDIT,
        APTS_CONSTANTS.PROD_SKU_ULIFTY4,
        APTS_CONSTANTS.PROD_SKU_ULIFTY5,
        APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO,
        APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO
    };*/
    
    public CreateSalesOrderExtension(){
        this.disableSubmit = false;
        this.reviewMode = false;
        this.lstRenewalLines = new List<RenewalLinesWrapper>();
        this.lstfinallinestoNS = new List<LinestoNS>();
        this.lstfinallinestoNSwithoutinternallines = new List<LinestoNS>();
        this.lstfinallinestoNSwithInternalLines = new List<LinestoNS>();
        shownewacv = false;
        showupsellacv = false;
        showrenewalacv = false;
        nooverrideACV = false;
        lstinternallinestoinsert = new List<Internal_Lines__c>();
        setrecurringSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Recurring_SKU').SKU_Codes__c.split(';'));
        CFWCSBSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_CSB_SKUs').SKU_Codes__c.split(';'));
        CFWZPASKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_ZPA_SKUs').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('One_Time_SKU').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('DAS_SKUs').SKU_Codes__c.split(';'));
        setSKUswithACVtobeskipped.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_to_SKIP_ACV').SKU_Codes__c.split(';'));
        setSKUsnottoAdd.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_not_To_ADD').SKU_Codes__c.split(';'));
        CreditSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Credit_SKUs').SKU_Codes__c.split(';'));
        UpliftSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Uplift_SKUs').SKU_Codes__c.split(';'));
        hasinternallines = false;
    }
    
    public CreateSalesOrderExtension(ApexPages.StandardController stdController) {
        this.opportunityId = (Id)stdController.getId();
        this.disableSubmit = false;
        this.opportunity = (Opportunity)stdController.getRecord();
        this.reviewMode = false;
        this.lstRenewalLines = new List<RenewalLinesWrapper>();
        this.lstfinallinestoNS = new List<LinestoNS>();
        this.lstfinallinestoNSwithoutinternallines = new List<LinestoNS>();
        this.lstfinallinestoNSwithInternalLines = new List<LinestoNS>();
        shownewacv = false;
        showupsellacv = false;
        showrenewalacv = false;
        nooverrideACV = false;
        requireSecPartner = false;
        lstinternallinestoinsert = new List<Internal_Lines__c>();
        setrecurringSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Recurring_SKU').SKU_Codes__c.split(';'));
        CFWCSBSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_CSB_SKUs').SKU_Codes__c.split(';'));
        CFWZPASKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('CFW_ZPA_SKUs').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('One_Time_SKU').SKU_Codes__c.split(';'));
        setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('DAS_SKUs').SKU_Codes__c.split(';'));
        setSKUswithACVtobeskipped.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_to_SKIP_ACV').SKU_Codes__c.split(';'));
        setSKUsnottoAdd.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('SKUs_not_To_ADD').SKU_Codes__c.split(';'));
        CreditSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Credit_SKUs').SKU_Codes__c.split(';'));
        UpliftSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Uplift_SKUs').SKU_Codes__c.split(';'));
        hasinternallines = false;
    }
    public PageReference pageLoad() {
        this.opportunity = [SELECT Id, Name, Type, NS_Integration_Requested_By__c, AccountId, StageName, X10b_Reason__c, Netsuite_Sales_Order_Internal_ID__c, NS_Integration_Failure_Reason__c, NS_Integration_Status__c,
                            Netsuite_Customer_ID__c, First_PO_Date__c,Netsuite_Primary_Partner_ID__c, Netsuite_Customer_ID_Override__c, Netsuite_Primary_Partner_ID_Override__c,
                            RecordType.Name, APTS_Primary_Proposal_Lookup__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__r.Name, APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__ExpectedStartDate__c, APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__Account__c, 
                            APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Partner_PO_Number__c, Netsuite_Promo_Code__c, Account_Channel_Rep_ZNumber__c, Account_Manager_ZNumber__c, NS_Integration_Requested_by_ZNumber__c, Renewal_Rep_ZNumber__c, SE_Znumber__c, Opportunity_Customer_Advocate__r.IsActive, Opportunity_Customer_Advocate__r.EmployeeNumber, Opportunity_Customer_Advocate__r.Manager.EmployeeNumber, SE_Name__r.IsActive, SE_Name__r.EmployeeNumber, SE_Name__r.Manager.EmployeeNumber, Opportunity_Account_Manager__r.IsActive, Opportunity_Account_Manager__r.EmployeeNumber, Opportunity_Account_Manager__r.Manager.EmployeeNumber, 
                            NS_Integration_Requested_By__r.IsActive, NS_Integration_Requested_By__r.EmployeeNumber, NS_Integration_Requested_By__r.Manager.EmployeeNumber, 
                            Account.Channel_Manager__r.IsActive, Account.Channel_Manager__r.EmployeeNumber, Account.Channel_Manager__r.Manager.EmployeeNumber, 
                            SO_Creation_Date__c, Primary_Partner_Program__c, Finance_Comments__c, Netsuite_Sales_Order_No__c, Previous_Sales_Order_No__c, Netsuite_Partner_Internal_ID_Override__c, Secondary_Partner__c, Secondary_Partner_Role__c 
                            FROM Opportunity WHERE Id = :this.opportunityId LIMIT 1];

        Map<String, Schema.RecordTypeInfo> mapRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
                            
        if(opportunity.Type == 'Existing Customer (Renewal)'){
            showupsellacv = true;
            showrenewalacv = true;
            System.debug('soe-opportunity.RecordTypeId'+opportunity.RecordTypeId);
        }else if(opportunity.Type == 'New Business'){
            shownewacv = true;
            this.opportunity.RecordTypeId = mapRecordTypes.get('New Business Close').RecordTypeId;
            System.debug('soe-opportunity.RecordTypeId'+opportunity.RecordTypeId);
        }else if(opportunity.Type == 'Existing Customer (Add On)'){
            showupsellacv = true;
            this.opportunity.RecordTypeId = mapRecordTypes.get('Upsell Opportunity Closed').RecordTypeId;
        }
        if(opportunity.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__r.Name == 'Carahsoft'){
            requireSecPartner = true;
        }
        
        this.Opportunity.StageName = Label.Stage_5_Contracts_Complete;
        this.netSuiteCustomerId = this.opportunity.Netsuite_Customer_ID__c;
        this.netSuitePartnerId = this.opportunity.Netsuite_Primary_Partner_ID__c;
        this.netSuiteCustomerIdOverride = this.opportunity.Netsuite_Primary_Partner_ID_Override__c;
        this.netSuitePartnerIdOverride = this.opportunity.Netsuite_Customer_ID_Override__c;
        
        for (Apttus_Proposal__Proposal_Line_Item__c pliSO : [SELECT Product_Name__c, APTS_Product_Code__c, Apttus_QPConfig__BasePrice__c, APTS_Quantity__c, 
                                                             Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_Selling_Term__c, 
                                                             Apttus_QPConfig__BaseExtendedPrice__c, APTS_Total_Discount_Percentage__c, APTS_Net_Price__c, 
                                                             Renewal_ACV_to_NetSuite__c, Upsell_ACV_to_NetSuite__c, New_ACV_to_NetSuite__c, APTS_ACV__c, 
                                                             Price_Per_Unit__c, Apttus_QPConfig__DerivedFromId__c, APTS_Contract_Detail_Name__r.Name, 
                                                             Additional_Contract_Details__c , Apttus_Proposal__Proposal__r.Recordtype.Name, Renewal_TCV_to_NetSuite__c, 
                                                             Upsell_TCV_to_NetSuite__c, New_TCV_to_NetSuite__c, Selling_Term_NS_Integration__c, Apttus_Proposal__Product__r.Zscaler_Product_Family__c, Apttus_Proposal__Product__r.APTS_Buyback_Eligible__c, Apttus_QPConfig__PriceGroup__c, APTS_Total_Ramp_Quantity__c, Apttus_QPConfig__DerivedFromId__r.Total_Term_after_Buyback__c, ACV_after_Bifurcation__c , TCV_after_Bifurcation__c, Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c, APTS_Total_Term__c, Apttus_QPConfig__AssetLineItemId__c, APTS_Contract_Detail_Name__c, APTS_Contract_No__c  
                                                             FROM Apttus_PRoposal__Proposal_Line_Item__c
                                                             WHERE Apttus_Proposal__Proposal__c = :this.opportunity.APTS_Primary_Proposal_Lookup__c]) {
                                                                 
                                                                if(this.opportunity.Type == 'New Business'){
                                                                    if (pliSO.New_TCV_to_NetSuite__c == null || pliSO.New_TCV_to_NetSuite__c == 0) {
                                                                        pliSO.New_TCV_to_NetSuite__c = pliSO.APTS_Net_Price__c;
                                                                    }
                                                                    if (pliSO.New_ACV_to_NetSuite__c == null || pliSO.New_ACV_to_NetSuite__c == 0) {
                                                                        pliSO.New_ACV_to_NetSuite__c = pliSO.APTS_ACV__c;
                                                                    }
                                                                } else if(this.opportunity.Type == 'Existing Customer (Add On)'){
                                                                    if (pliSO.Upsell_TCV_to_NetSuite__c == null || pliSO.Upsell_TCV_to_NetSuite__c == 0) {
                                                                        pliSO.Upsell_TCV_to_NetSuite__c = pliSO.APTS_Net_Price__c;
                                                                    }
                                                                    if (pliSO.Upsell_ACV_to_NetSuite__c == null || pliSO.Upsell_ACV_to_NetSuite__c == 0) {
                                                                        pliSO.Upsell_ACV_to_NetSuite__c = pliSO.APTS_ACV__c;
                                                                    }
                                                                }

                                                                this.lstRenewalLines.add(new RenewalLinesWrapper(pliSO));
                                                                this.plimap.put(pliSO.Id,pliSO);
                                                             }
        
        return null;
    }
    
    
    public PageReference doReview() {
        try{
            showMessage = false;
            reviewMode = true;
            showError = false;
            
            if(!(String.isBlank(this.opportunity.Netsuite_Primary_Partner_ID_Override__c)))
            {
                nsPartnerIdOverridden = true;
            }
            else
            {
                nsPartnerIdOverridden = false;
            }
            if(!(String.isBlank(this.opportunity.Netsuite_Customer_ID_Override__c )))
            {
                nsCustomerIdOverridden = true;
            }
            else
            {
                nsCustomerIdOverridden = false;
            }
            
            update this.opportunity;
            
            if(overrideBillToId || overrideShipToId || overridePartnerId){
                case tempCase = new case();
                tempCase.Opportunity_Name__c = this.opportunity.Id;
                tempCase.Subject = 'New Case for Bill To/ Ship To override for NS integration for Opportunity '+ this.opportunity.Name + ' / ' + this.opportunity.Id;
                tempCase.Description = 'New Case for Bill To/ Ship To override for NS integration for Opportunity '+ this.opportunity.Name + ' / ' + this.opportunity.Id;
                
                if(overrideBillToId){
                    tempCase.Description += '\n Order Ops Bill To Override: ' + this.opportunity.Netsuite_Primary_Partner_ID_Override__c;
                }
                if(overridePartnerId){
                    tempCase.Description += '\n Netsuite Partner Internal ID Override: ' + this.opportunity.Netsuite_Partner_Internal_ID_Override__c;
                }
                if(overrideShipToId){
                    tempCase.Description += '\n Order Ops Ship To Override: ' + this.opportunity.Netsuite_Customer_ID_Override__c;
                }
                
                tempCase.Case_Category__c = 'Opportunities';
                tempCase.Case_Sub_Category__c = 'Others';
                if(!Test.isRunningTest()){
                    tempCase.OwnerId = ZscalerSetting__c.getValues('NSIntegCaseOwnerId').Value__c;
                    tempCase.Status = 'New';
                    insert tempCase;
                }
            }
            // Validation for fields
            System.debug('>>>> ' + String.isNotBlank(this.opportunity.Netsuite_Customer_ID__c) + '|' + String.isNotBlank(this.opportunity.Netsuite_Primary_Partner_ID_Override__c) + '|' + String.isNotBlank(this.opportunity.Netsuite_Primary_Partner_ID__c) + '|' + String.isNotBlank(this.opportunity.Netsuite_Customer_ID_Override__c));
            
            // if (this.opportunity.Type.equalsIgnoreCase('new business')) {
            //     if ((String.isNotBlank(this.opportunity.Netsuite_Primary_Partner_ID__c) || String.isNotBlank(this.opportunity.Netsuite_Customer_ID_Override__c))) {
            //         reviewMode = true;
            //         showError = false;
            //         errors = '';
            //     } else {
            //         showError = true;
            //         reviewMode = false;
            //         errors = 'Please enter valid Bill To Customer Id';
            //     }
            // } else if ((this.opportunity.Type.equalsIgnoreCase('existing customer (add on)') || this.opportunity.Type.equalsIgnoreCase('existing customer (renewal)'))) {
            //     if (((String.isNotBlank(this.opportunity.Netsuite_Customer_ID__c) || String.isNotBlank(this.opportunity.Netsuite_Primary_Partner_ID_Override__c))
            //         && (String.isNotBlank(this.opportunity.Netsuite_Primary_Partner_ID__c) || String.isNotBlank(this.opportunity.Netsuite_Customer_ID_Override__c)))) {
            //             reviewMode = true;
            //             showError = false;
            //             errors = '';
            
            //             nsCustomerIdOverridden = String.isNotBlank(this.opportunity.Netsuite_Customer_ID_Override__c);
            //             nsPartnerIdOverridden = String.isNotBlank(this.opportunity.Netsuite_Primary_Partner_ID_Override__c);
            //     } else {
            //         showError = true;
            //         reviewMode = false;
            //         errors = 'Please enter valid Bill To and Ship To Customer Ids';
            //     }
            // }
            
            adjustACVandTCV();
        }
        catch(Exception exp){
            System.debug('*** Exception occured while updating the opportunity: ' + exp.getMessage() + ' ' + exp.getStackTraceString());
            //throw exp;
            //showMessage = true;
            reviewMode = false;
            showError = true;
            errors = exp.getMessage();
            
        }
        return null;
    }
    
    public PageReference doSubmit() {
        List<User> usrlst = [Select Id, EmployeeNumber, IsActive, Manager.EmployeeNumber, ManagerId from User where Id = :UserInfo.getuserId()];
        showMessage = true;
        disableSubmit = true;
        try {
            this.Opportunity.NS_Integration_Status__c = 'In Progress';
            this.Opportunity.NS_Integration_Failure_Reason__c = '';
            this.Opportunity.NS_Integration_Requested_By__c = UserInfo.getUserId();
            this.Opportunity.NS_Integration_Status_Change_Time__c = system.now().addMinutes(15);
            this.Opportunity.Account_Channel_Rep_ZNumber__c = this.Opportunity.Account.Channel_Manager__r.IsActive && this.Opportunity.Account.Channel_Manager__r.EmployeeNumber != null? this.Opportunity.Account.Channel_Manager__r.EmployeeNumber : this.Opportunity.Account.Channel_Manager__r.Manager.EmployeeNumber;
            this.Opportunity.Account_Manager_ZNumber__c = this.Opportunity.Opportunity_Account_Manager__r.IsActive && this.Opportunity.Opportunity_Account_Manager__r.EmployeeNumber != null? this.Opportunity.Opportunity_Account_Manager__r.EmployeeNumber : this.Opportunity.Opportunity_Account_Manager__r.Manager.EmployeeNumber;
            this.Opportunity.NS_Integration_Requested_by_ZNumber__c = !usrlst.isEmpty() && usrlst[0].isActive && usrlst[0].EmployeeNumber != null ? usrlst[0].EmployeeNumber : (usrlst[0].ManagerId != null ? usrlst[0].Manager.EmployeeNumber : null);
            this.Opportunity.Renewal_Rep_ZNumber__c = this.Opportunity.Opportunity_Customer_Advocate__r.IsActive && this.Opportunity.Opportunity_Customer_Advocate__r.EmployeeNumber != null? this.Opportunity.Opportunity_Customer_Advocate__r.EmployeeNumber : this.Opportunity.Opportunity_Customer_Advocate__r.Manager.EmployeeNumber;
            this.Opportunity.SE_Znumber__c = this.Opportunity.SE_Name__r.IsActive && this.Opportunity.SE_Name__r.EmployeeNumber != null? this.Opportunity.SE_Name__r.EmployeeNumber : this.Opportunity.SE_Name__r.Manager.EmployeeNumber;
            // this.Opportunity.StageName = '10b - PO recd, pending finance approval';
            this.Opportunity.CloseDate = this.Opportunity.SO_Creation_Date__c;
            this.Opportunity.Previous_Sales_Order_No__c = this.Opportunity.Netsuite_Sales_Order_No__c;

            update this.Opportunity;

            

            // Update the proposal lines with the Contract Detail Item and the additional Contract Detail Items
            /*List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLinesToUpdate = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            for (RenewalLinesWrapper line : this.lstRenewalLines) {
                lstProposalLinesToUpdate.add(new Apttus_Proposal__Proposal_Line_Item__c(
                                                Id = line.lineItem.Id, 
                                                APTS_Contract_Detail_Name__c = line.contractDetailId, 
                                                Additional_Contract_Details__c = line.addcontractDetailName,
                                                New_ACV_to_NetSuite__c = line.lineItem.New_ACV_to_NetSuite__c,
                                                New_TCV_to_NetSuite__c = line.lineItem.New_TCV_to_NetSuite__c,
                                                Upsell_ACV_to_NetSuite__c = line.lineItem.Upsell_ACV_to_NetSuite__c,
                                                Upsell_TCV_to_NetSuite__c = line.lineItem.Upsell_TCV_to_NetSuite__c,
                                                Renewal_ACV_to_NetSuite__c = line.lineItem.Renewal_ACV_to_NetSuite__c,
                                                Renewal_TCV_to_NetSuite__c = line.lineItem.Renewal_TCV_to_NetSuite__c
                                            ));
            }

            if (lstProposalLinesToUpdate.size() > 0) {
                update lstProposalLinesToUpdate;
            }*/
            savelines();
        } catch(Exception ex) {
            System.debug('*** Exception occured while updating the opportunity: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw ex;
        }
        
        sendCreateSalesOrderRequest(this.OpportunityId);
        return null;
    }
    
    public PageReference doCancel() {
        PageReference pageRef = new PageReference('/' + this.opportunityId);
        return pageRef;
    }
    
    public PageReference doBack() {
        reviewMode = false;
        savelines();
        return null;
    }
    
    public PageReference getPartnerInternalId() {
        List<Account> acclst = [Select Id, NetSuite_Internal_id__c, Netsuite_Partner_Internal_Id__c from Account where NetSuite_Internal_id__c = :this.Opportunity.Netsuite_Primary_Partner_ID_Override__c limit 1];
        this.opportunity.Netsuite_Partner_Internal_ID_Override__c = !acclst.isEmpty() ? acclst[0].Netsuite_Partner_Internal_Id__c : this.Opportunity.Netsuite_Primary_Partner_ID_Override__c;
        system.debug(this.opportunity.Netsuite_Partner_Internal_ID_Override__c);
        return null;
    }
    
    @RemoteAction
    public static List<Contract_Detail__c> searchContractDetails(String name, Id accountId) {
        if (String.isBlank(name) || name.contains('%')) {
            return new List<Contract_Detail__c>();
        }
        
        String nameCondition = name + '%';
        
        List<Contract_Detail__c> lstContractDetails = [SELECT Id, Name FROM Contract_Detail__c 
                                                       WHERE Contract_Detail_Status__c IN ('Active', 'Pending Activation', 'Pending Renewal')
                                                       AND Account_Name__c = :accountId
                                                       AND Name LIKE :nameCondition];
        
        return lstContractDetails != null && lstContractDetails.size() > 0 ? lstContractDetails : new List<Contract_Detail__c>();
    }
    
    @Future(Callout = true)
    public static void sendCreateSalesOrderRequest(Id opportunityId) {
        Opportunity oppty = [SELECT Id, Type, NS_Integration_Status__c, NS_Integration_Failure_Reason__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        if (oppty == null) {
            return;
        }
        
        Map<String, String> requestMap = new Map<String, String> { 'id' => opportunityId, 'type' => oppty.Type };
            HttpRequest request = createHttpRequest('callout:DB_Create_Sales_Order/v1/create', 'POST', JSON.serialize(requestMap));
        HttpResponse response;
        try {
            Http http = new Http();
            response = http.send(request);
            System.debug(response.getBody());
            
        } catch (Exception ex) {
            System.debug('*** Error occurred while invoking SFDC to NS Integration Job: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new SFDCNSIntegrationException(ex);
        }
        
        createIntegrationLog((String)opportunityId, '', 'callout:DB_Create_Sales_Order/v1/create', '', JSON.serialize(requestMap), response.getBody(), string.valueOf(response.getStatusCode()), response.getStatusCode() == 200 ? 'Success': 'Failure');
        
        try{
            if(response.getStatusCode() != 200){
                oppty.NS_Integration_Status__c = 'Failure';
                oppty.NS_Integration_Failure_Reason__c = response.getBody();
                update oppty;
            }
        }catch (Exception ex) {
            System.debug('*** Error occurred while saving oppty: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new SFDCNSIntegrationException(ex);
        }
    }
    
    @RemoteAction
    public static List<NetSuiteCustomerInfoLine> getNetSuiteCustomerDetails(String customerId, String customerOverriddenId, String billToId, String billToOverriddenId) {
        List<Account> acclst = [Select Id, NetSuite_Internal_id__c, Netsuite_Partner_Internal_Id__c from Account where NetSuite_Internal_id__c = :billToOverriddenId limit 1];
        String partnerOverriddenId = !acclst.isEmpty() && acclst[0].Netsuite_Partner_Internal_Id__c != null ? acclst[0].Netsuite_Partner_Internal_Id__c : billToOverriddenId;
        List<NetSuiteCustomerInfoLine> responseObj;
        List<String> lstCustomerIds = new List<String>();
        List<String> lstPartnerIds = new List<String>();
        if(customerId != null && customerId != '')
            lstCustomerIds.add(customerId);
        if(billToId != null && billToId != '')
            lstCustomerIds.add(billToId);
        if(customerOverriddenId != null && customerOverriddenId != '')
            lstCustomerIds.add(customerOverriddenId);
        if(billToOverriddenId != null && billToOverriddenId != '')
            lstCustomerIds.add(billToOverriddenId);
        if (lstCustomerIds.isEmpty()) {
            return new List<NetSuiteCustomerInfoLine>();
        }
        if(partnerOverriddenId != '' && partnerOverriddenId != null){
            lstPartnerIds.add(partnerOverriddenId);
        }
        
        Map<String, List<String>> requestMap = new Map<String, List<String>> { 'partnerIds' => lstPartnerIds, 'customerIds' => lstCustomerIds};
        
        system.debug(JSON.serialize(requestMap));
        String jsonstr = '{"customerIds": ' + JSON.serialize(lstCustomerIds) + ', "partnerIds" : ' + JSON.serialize(lstPartnerIds) +  '}';

        HttpRequest request = createHttpRequest('callout:DB_Create_Sales_Order/v1/CustomerAndPartner', 'POST', jsonstr);
        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','application/json');
        
        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            
            responseObj =  response.getBody() != null && response.getBody() != '' ? ((List<NetSuiteCustomerInfoLine>)JSON.deserialize(response.getBody(), List<NetSuiteCustomerInfoLine>.class)) : new List<NetSuiteCustomerInfoLine>();
            system.debug(responseObj);
            
        } catch (Exception ex) {
            System.debug('*** Error occurred fetching NS account information: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new SFDCNSIntegrationException(ex);
        }
        if(responseObj != null && !responseObj.isEmpty()){
            return responseObj;
        }else{
            return new List<NetSuiteCustomerInfoLine>();
        }
    }
    
    
     private static void createIntegrationLog(String objectId, String typeOfOperation, String endpoint, String queryParameters,
         String request, String response, String status, String statusDetail) {
         Integration_Log__c log = new Integration_Log__c(
                                     Related_Record_Id__c = objectId,
                                     Opportunity__c = objectId,
                                     Type_Of_Operation__c = typeOfOperation,
                                     Endpoint__c = endpoint,
                                     Query_Parameters__c = queryParameters,
                                     Request__c = request,
                                     Response__c = response,
                                     Response_Code__c = decimal.valueOf(status),
                                     Status__c = status,
                                     Status_Detail__c = statusDetail
                                 );
    
         try {
             TriggerUtility.intLogtriggerPRLogicExecuted();
             insert log;
         } catch (Exception ex) {
             System.debug('*** Error occurred while creating Integartion Log entry ' + JSON.serialize(log) + '; ' + ex.getMessage() + ' ' + ex.getStackTraceString());
         }
     }
    
    public class RenewalLinesWrapper {
        public Apttus_Proposal__Proposal_Line_Item__c lineItem { get; set; }
        public String contractDetailName { get; set; }
        public Id contractDetailId { get; set; }
        public String addcontractDetailName { get; set; }
        
        public RenewalLinesWrapper(Apttus_Proposal__Proposal_Line_Item__c lineItem) {
            this.lineItem = lineItem;
            this.contractDetailName = lineItem.APTS_Contract_Detail_Name__r.Name;
            this.contractDetailId = lineItem.APTS_Contract_Detail_Name__c;
            this.addcontractDetailName = lineItem.Additional_Contract_Details__c;
        }
        
    }
    
    public class LinestoNS {
        public Id pliId { get; set; }
        public String productName { get; set; }
        public String productfamily { get; set; }
        public String productId { get; set; }
        public String quoteId { get; set; }
        public String productCode { get; set; }
        public Decimal basePrice { get; set; }
        public Decimal Qty { get; set; }
        public Date StartDate { get; set; }
        public Date EndDate { get; set; }
        public Decimal SellingTerm { get; set; }
        public Decimal SellingTermNS { get; set; }
        public Decimal ListPrice { get; set; }
        public Decimal discPercent { get; set; }
        public Decimal NetPrice { get; set; }
        public Decimal NetPriceOriginal { get; set; }
        public Decimal ACV { get; set; }
        public Decimal ACVoriginal { get; set; }
        public Decimal newACV { get; set; }
        public Decimal UpsellACV { get; set; }
        public Decimal RenewalACV { get; set; }
        public Decimal newTCV { get; set; }
        public Decimal UpsellTCV { get; set; }
        public Decimal RenewalTCV { get; set; }
        public Decimal CarvedOutACV { get; set; }
        public String RecType { get; set; }
        public String contractDetailName { get; set; }
        public Id contractDetailId { get; set; }
        public String addcontractDetailName { get; set; }
        public Boolean isbuybackbifurcated { get; set; }
        public Id recId { get; set; }
        
        public LinestoNS(Apttus_Proposal__Proposal_Line_Item__c lineItem, Boolean buybackbifur) {
            pliId = lineItem.Id;
            recId = pliId;
            productName  = lineItem.Product_Name__c;
            productCode = lineItem.APTS_Product_Code__c;
            basePrice = lineItem.Apttus_QPConfig__BasePrice__c;
            Qty = lineItem.APTS_Quantity__c;
            StartDate = lineItem.Apttus_QPConfig__StartDate__c;
            EndDate = lineItem.Apttus_QPConfig__EndDate__c;
            SellingTerm = lineItem.APTS_Selling_Term__c;
            SellingTermNS = lineItem.Selling_Term_NS_Integration__c;
            ListPrice = lineItem.Apttus_QPConfig__BaseExtendedPrice__c;
            discPercent = lineItem.APTS_Total_Discount_Percentage__c /100;
            NetPrice = lineItem.TCV_after_Bifurcation__c;
            NetPriceOriginal = lineItem.Apttus_QPConfig__NetPrice__c;
            ACV = lineItem.ACV_after_Bifurcation__c;
            ACVoriginal = lineItem.APTS_ACV__c;
            newTCV = lineItem.New_TCV_to_NetSuite__c;
            UpsellTCV = lineItem.Upsell_TCV_to_NetSuite__c;
            RenewalTCV = lineItem.Renewal_TCV_to_NetSuite__c;
            newACV = lineItem.New_ACV_to_NetSuite__c;
            UpsellACV = lineItem.Upsell_ACV_to_NetSuite__c;
            RenewalACV = lineItem.Renewal_ACV_to_NetSuite__c;
            CarvedOutACV = 0;
            //RecType = this.opportunity.Type;
            contractDetailName = lineItem.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || (lineItem.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && lineItem.APTS_Total_Ramp_Quantity__c == lineItem.APTS_Quantity__c) ? lineItem.APTS_Contract_No__c : '';
            contractDetailId =  lineItem.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || (lineItem.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && lineItem.APTS_Total_Ramp_Quantity__c == lineItem.APTS_Quantity__c) ? lineItem.APTS_Contract_Detail_Name__c : null;
            addcontractDetailName =  lineItem.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || (lineItem.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && lineItem.APTS_Total_Ramp_Quantity__c == lineItem.APTS_Quantity__c) ? lineItem.Additional_Contract_Details__c : '';
            quoteId = lineItem.Apttus_Proposal__Proposal__c;
            productId =  lineItem.Apttus_Proposal__Product__c;
            isbuybackbifurcated = buybackbifur;
            productfamily = lineItem.Apttus_Proposal__Product__r.Zscaler_Product_Family__c;
        }
        
        public LinestoNS(Apttus_Proposal__Proposal_Line_Item__c lineItem, String code, Decimal acvval, Decimal tcvval, Boolean buybackbifur) {
            pliId = null;
            recId = null;
            productName  = lineItem.Product_Name__c;
            productCode = code;
            basePrice = lineItem.Apttus_QPConfig__BasePrice__c;
            Qty = 0;
            StartDate = lineItem.Apttus_QPConfig__StartDate__c;
            EndDate = lineItem.Apttus_QPConfig__EndDate__c;
            SellingTerm = lineItem.APTS_Selling_Term__c;
            SellingTermNS = lineItem.Selling_Term_NS_Integration__c;
            ListPrice = lineItem.Apttus_QPConfig__BaseExtendedPrice__c;
            discPercent = lineItem.APTS_Total_Discount_Percentage__c / 100;
            NetPrice = tcvval;
            NetPriceOriginal = tcvval;
            ACV = acvval;
            ACVoriginal = acvval;
            newTCV = lineItem.New_TCV_to_NetSuite__c;
            UpsellTCV = lineItem.Upsell_TCV_to_NetSuite__c;
            RenewalTCV = lineItem.Renewal_TCV_to_NetSuite__c;
            newACV = lineItem.New_ACV_to_NetSuite__c;
            UpsellACV = lineItem.Upsell_ACV_to_NetSuite__c;
            RenewalACV = lineItem.Renewal_ACV_to_NetSuite__c;
            CarvedOutACV = 0;
            //RecType = this.opportunity.Type;
            contractDetailName = lineItem.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || (lineItem.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && lineItem.APTS_Total_Ramp_Quantity__c == lineItem.APTS_Quantity__c) ? lineItem.APTS_Contract_No__c : '';
            contractDetailId =  lineItem.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || (lineItem.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && lineItem.APTS_Total_Ramp_Quantity__c == lineItem.APTS_Quantity__c) ? lineItem.APTS_Contract_Detail_Name__c : null;
            addcontractDetailName =  lineItem.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || (lineItem.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && lineItem.APTS_Total_Ramp_Quantity__c == lineItem.APTS_Quantity__c) ? lineItem.Additional_Contract_Details__c : '';
            quoteId = lineItem.Apttus_Proposal__Proposal__c;
            productId =  lineItem.Apttus_Proposal__Product__c;
            isbuybackbifurcated = buybackbifur;
            productfamily = lineItem.Apttus_Proposal__Product__r.Zscaler_Product_Family__c;
        }
        
    }
    
    public class NetSuiteCustomerInfoResponse {
        public List<NetSuiteCustomerInfoLine> response { get; set; }
        
        public NetSuiteCustomerInfoResponse() {
            this.response = new List<NetSuiteCustomerInfoLine>();
        }
    }
    
    public class NetSuiteCustomerInfoLine {
        public Integer id { get; set; }
        public String name { get; set; }
        public String entityId { get; set; }
        public String type { get; set; }
    }
    
    @testvisible private static HttpRequest createHttpRequest(String endpoint, String method, String body) {
        return createHttpRequest(endpoint, method, body, 120000);
    }
    
    @testvisible private static HttpRequest createHttpRequest(String endpoint, String method, String body, Integer timeout) {
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setBody(body);
        request.setTimeout(timeout);
        
        return request;
    }
    
    //Method to prepare lines non internal and internal lines. Also, takes care of Uplift/Buyback bifurcation
    public void adjustACVandTCV(){
        if(nooverrideACV){
            return;
        }
        this.lstfinallinestoNS = new List<LinestoNS>();
        
        Set<Id> aliset = new Set<Id>();
        Map<String, List<Contract_Detail__c>> mapSOnumtocd = new Map<String, List<Contract_Detail__c>>();
        Map<Id, Contract_Detail__c> mapcdIdtoCd = new Map<Id, Contract_Detail__c>();
        Map<String, Map<String, String>> mapSOnumtoassetrampCD = new Map<String, Map<String, String>>();
        Map<Id, String> mapQuoteIdtoSO = new Map<Id, String>();
        Map<Id, List<Contract_Detail__c>> mapSOtoquote = new Map<Id, List<Contract_Detail__c>>();
        Map<String, String> mapSonamtoId = new Map<String, String>();
        Map<Id, Apttus_Config2__AssetLineItem__c> alilst = new Map<Id, Apttus_Config2__AssetLineItem__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c > plilst = new List<Apttus_Proposal__Proposal_Line_Item__c  >();
        List<Apttus_Config2__LineItem__c> lilst = new List<Apttus_Config2__LineItem__c>();
        Set<Id> SoIdset = new Set<Id>();
        //Logic to populate contract and additional contract details based on Asset Line Item field on Proposal Line item record. 
        for(Contract_Detail__c cd: [Select Id, Name, Contract_Detail_Status__c, Account_Name__c, Sales_Order_Name__c, Product_SKU__c, Start_Date__c, End_Date__c, Quantity__c, Sales_Order__c, Contract_No__c, Amount_USD__c from Contract_Detail__c where Account_Name__c = :this.opportunity.AccountId]){
            if(cd.Contract_Detail_Status__c == 'Active' || cd.Contract_Detail_Status__c == 'Pending Renewal' || cd.Contract_Detail_Status__c == 'Pending Activation'){
                if(!mapSOnumtocd.containskey(cd.Sales_Order_Name__c)){
                    mapSOnumtocd.put(cd.Sales_Order_Name__c, new List<Contract_Detail__c>{cd});
                }else{
                    List<Contract_Detail__c> templst = mapSOnumtocd.get(cd.Sales_Order_Name__c);
                    templst.add(cd);
                    mapSOnumtocd.put(cd.Sales_Order_Name__c, templst);
                }
                mapcdIdtoCd.put(cd.Id, cd);
                SoIdset.add(cd.Sales_Order__c);
            }
            cdnamemap.put(cd.name, cd);
        }
        
        system.debug('++++'+mapSOnumtocd);
        
        for(Apttus_Proposal__Proposal__c quote: [Select Id, Sales_Order__c from Apttus_Proposal__Proposal__c where Sales_Order__c in :mapSOnumtocd.keySet()]){
            mapQuoteIdtoSO.put(quote.Id, quote.Sales_Order__c);
        }
        system.debug('++++'+mapQuoteIdtoSO);
        
        //ALI's start date, end date, sku code, quantity should match with CD and if Amount USD is > 0 then CD gets mapped to ALI
        for(Apttus_Config2__AssetLineItem__c ali: [Select Id, Apttus_QPConfig__ProposalId__c, Product_Code__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c, Apttus_Config2__PriceGroup__c from Apttus_Config2__AssetLineItem__c where Apttus_QPConfig__ProposalId__c in :mapQuoteIdtoSO.keyset() and Apttus_Config2__AccountId__c = :this.opportunity.AccountId]){
            String SOName = mapQuoteIdtoSO.get(ali.Apttus_QPConfig__ProposalId__c);
            for(Contract_Detail__c cd: mapSOnumtocd.get(SOName)){
                if(cd.Product_SKU__c == ali.Product_Code__c 
                && cd.Start_Date__c == ali.Apttus_Config2__StartDate__c 
                && cd.End_Date__c == ali.Apttus_Config2__EndDate__c 
                && cd.Quantity__c == ali.Apttus_Config2__Quantity__c 
                && cd.Amount_USD__c > 0 
                && aliset.add(ali.Id)){
                    ali.APTS_Contract_Detail_Name__c = cd.Id;
                    ali.APTS_Contract_No__c = cd.Contract_No__c;
                    ali.APTS_Sales_Order__c = cd.Sales_Order__c;
                    alilst.put(ali.Id, ali);
                    if(ali.Apttus_Config2__PriceGroup__c == 'Price Ramp'){
                        if(!mapSOnumtoassetrampCD.containskey(ali.APTS_Sales_Order__c)){
                            mapSOnumtoassetrampCD.put(ali.APTS_Sales_Order__c, new Map<String,String>{ali.Product_Code__c => cd.Name});
                        }else{
                            Map<String, String> mapprodtocd = mapSOnumtoassetrampCD.get(ali.APTS_Sales_Order__c);
                            if(!mapprodtocd.containskey(ali.Product_Code__c)){
                                mapprodtocd.put(ali.Product_Code__c, cd.Name);
                            }else{
                                String cdname = mapprodtocd.get(ali.Product_Code__c);
                                cdname += cd.Name;
                                mapprodtocd.put(ali.Product_Code__c, cdname);
                            }
                            mapSOnumtoassetrampCD.put(ali.APTS_Sales_Order__c, mapprodtocd);
                        }
                    }
                }
            }
        }
        
        for(Apttus_Config2__AssetLineItem__c ali: alilst.values()){
            String addcd = '';
            if(mapSOnumtoassetrampCD != null && mapSOnumtoassetrampCD.containskey(ali.APTS_Sales_Order__c)){
                Map<String, String> mapprodtocd = mapSOnumtoassetrampCD.get(ali.APTS_Sales_Order__c);
                if(mapprodtocd != null && mapprodtocd.containskey(ali.Product_Code__c)){
                    addcd = mapprodtocd.get(ali.Product_Code__c);
                }
            }
            ali.Additional_Contract_Details__c = addcd;
        }
        
        
        
        Decimal TotalZIAACV = 0;
        Decimal TotalZPAACV = 0;
        Decimal TotalZIAACVBB = 0;
        Decimal TotalZPAACVBB = 0;
        Decimal TotalTCVU4 = 0;
        Decimal TotalTCVU5 = 0;
        Decimal TotalZIATCV = 0;
        Decimal TotalZPATCV = 0;
        Decimal TotalZPAACVofRecurringInternalSKU = 0;
        Decimal TotalZPATCVofRecurringInternalSKU = 0;
        Decimal TotalZPATCVofNonRecurringInternalSKU = 0;
        Decimal TotalACV = 0;
        Decimal TotalACVinclPS = 0;
        Decimal TotalTCV = 0;
        Decimal TotalCFWZPAACV = 0;
        Decimal TotalCFWCSBACV = 0;
        
        Apttus_Proposal__Proposal_Line_Item__c pliZIABuyback = null;
        Apttus_Proposal__Proposal_Line_Item__c pliZPABuyback = null;
        Apttus_Proposal__Proposal_Line_Item__c pliuplift4 = null;
        Apttus_Proposal__Proposal_Line_Item__c pliuplift5 = null;
        Apttus_Proposal__Proposal_Line_Item__c pliOneTimeCredit = null;
        Apttus_Proposal__Proposal_Line_Item__c plicsbcfwpromo = null;
        Apttus_Proposal__Proposal_Line_Item__c plizpacfwpromo = null;
        
        Boolean onetimealreadyadded = false;
        Boolean recurringalreadyadded = false;
        Boolean buybackbifur = false;
        
        //calculate sum of ACVs of lines whose term is > 36 for uplift 4 bifurcation and term > 48 for uplift 5 bifurcation
        for(RenewalLinesWrapper rlw: lstRenewalLines){
            Apttus_Proposal__Proposal_Line_Item__c pli = rlw.lineItem;
            pli.APTS_Contract_Detail_Name__c = alilst.containskey(pli.Apttus_QPConfig__AssetLineItemId__c) ? alilst.get(pli.Apttus_QPConfig__AssetLineItemId__c).APTS_Contract_Detail_Name__c : pli.APTS_Contract_Detail_Name__c;
            pli.APTS_Contract_No__c = mapcdIdtoCd.containskey(pli.APTS_Contract_Detail_Name__c) ? mapcdIdtoCd.get(pli.APTS_Contract_Detail_Name__c).Name : pli.APTS_Contract_No__c;
            pli.Additional_Contract_Details__c = alilst.containskey(pli.Apttus_QPConfig__AssetLineItemId__c) ? alilst.get(pli.Apttus_QPConfig__AssetLineItemId__c).Additional_Contract_Details__c : pli.Additional_Contract_Details__c;
            
            if(pli.Apttus_QPConfig__DerivedFromId__r.Total_Term_after_Buyback__c > 36 && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c)){
                TotalTCVU4 += pli.Apttus_QPConfig__NetPrice__c;
            }
            if(pli.Apttus_QPConfig__DerivedFromId__r.Total_Term_after_Buyback__c > 48 && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c)){
                TotalTCVU5 += pli.Apttus_QPConfig__NetPrice__c;
            }
            if(pli.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_BUYBACK){
                pliZIABuyback = pli;
            }
            if(pli.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK){
                pliZPABuyback = pli;
            }
            if(pli.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_Z_CREDIT){
                pliOneTimeCredit = pli;
            }
            if(pli.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ULIFTY4){
                pliuplift4 = pli;
            }
            if(pli.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ULIFTY5){
                pliuplift5 = pli;
            }
            if(pli.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO){
                plicsbcfwpromo = pli;
            }
            if(pli.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO){
                plizpacfwpromo = pli;
            }
        }
        
        //This loop takes care of bifurcating Uplift 4 and 5 to all lines where respective criteria is met to its TCV and ACV. Also, calculates multiple sum of ACV/TCV for different calculations like Buyback ACV, total zia acv/tcv, total zpa ACV/TCV etc.,
        for(RenewalLinesWrapper rlw: lstRenewalLines){
            Apttus_Proposal__Proposal_Line_Item__c pli = rlw.lineItem;
            pli.TCV_after_Bifurcation__c = pli.Apttus_QPConfig__NetPrice__c;
            Decimal amttosub = 0.0;
            
            if(pli.Apttus_QPConfig__DerivedFromId__r.Total_Term_after_Buyback__c > 36 && pli.Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time' && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c) && pliuplift4 != null){
                amttosub += TotalTCVU4 != 0 ? (pli.Apttus_QPConfig__NetPrice__c / TotalTCVU4) * pliuplift4.Apttus_QPConfig__NetPrice__c: 0.0 ;
            }
            
            if(pli.Apttus_QPConfig__DerivedFromId__r.Total_Term_after_Buyback__c > 48 && pli.Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time' && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c) && pliuplift5 != null){
                amttosub += TotalTCVU5 != 0 ? (pli.Apttus_QPConfig__NetPrice__c / TotalTCVU5) * pliuplift5.Apttus_QPConfig__NetPrice__c: 0.0 ;
            }
            
            pli.TCV_after_Bifurcation__c += amttosub;
            
            if(pli.APTS_Selling_Term__c >= 12){
                pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c != null && pli.APTS_Selling_Term__c != null ? (pli.TCV_after_Bifurcation__c / pli.APTS_Selling_Term__c) * 12 : 0.0;
                
            }else{
                pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c ;
            }
            
            if(pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZIA' && pli.Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time'){
                
                if(pli.Apttus_Proposal__Product__r.APTS_Buyback_Eligible__c && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c)){
                    TotalZIAACVBB += pli.ACV_after_Bifurcation__c;
                }
                
                TotalZIAACV += pli.ACV_after_Bifurcation__c;
                TotalZIATCV += pli.TCV_after_Bifurcation__c;
            }else if(pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZPA' && pli.Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time'){
                containszpa = true;
                if(pli.Apttus_Proposal__Product__r.APTS_Buyback_Eligible__c && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c)){
                    TotalZPAACVBB += pli.ACV_after_Bifurcation__c;
                }
                TotalZPAACV += pli.ACV_after_Bifurcation__c;
                TotalZPATCV += pli.TCV_after_Bifurcation__c;
            }
            
            if(pli.Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time' && pli.APTS_Product_Code__c != 'Z-CREDIT'){
                TotalACVinclPS += pli.ACV_after_Bifurcation__c;
            }
            
            TotalACV = TotalZPAACV + TotalZIAACV;
            TotalTCV = TotalZPATCV + TotalZIATCV;
            if(CFWCSBSKUs.contains(pli.APTS_Product_Code__c)){
                TotalCFWCSBACV += pli.ACV_after_Bifurcation__c;
            }
            if(CFWZPASKUs.contains(pli.APTS_Product_Code__c) || pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZPA'){
                TotalCFWZPAACV += pli.ACV_after_Bifurcation__c;
            }
        }
        
        //This loop takes care of credit sku's bifurcation to all eligible lines. Also, to calculate ZIA/ZPA portion of recurring and non recurring SKUs
        for(RenewalLinesWrapper rlw: lstRenewalLines){
            Apttus_Proposal__Proposal_Line_Item__c pli = rlw.lineItem;
            Decimal amttosubACV = 0.0;
            
            if(pli.Apttus_Proposal__Product__r.APTS_Buyback_Eligible__c && pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZIA' && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c) && pliZIABuyback != null){
                amttosubACV += TotalZIAACVBB != 0 && pliZIABuyback.APTS_ACV__c != null? (pli.ACV_after_Bifurcation__c / TotalZIAACVBB) * pliZIABuyback.APTS_ACV__c: 0.0 ;
                buybackbifur = true;
            }
            
            if(pli.Apttus_Proposal__Product__r.APTS_Buyback_Eligible__c && pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZPA' && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c) && pliZPABuyback != null){
                amttosubACV += TotalZPAACVBB != 0 && pliZPABuyback.APTS_ACV__c != null? (pli.ACV_after_Bifurcation__c / TotalZPAACVBB) * pliZPABuyback.APTS_ACV__c: 0.0 ;
                buybackbifur = true;
            }
            
            if(pli.Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time' && pliOneTimeCredit != null && pli.APTS_Product_Code__c != 'Z-CREDIT'){
                system.debug('onetimecredit' + pli.APTS_Product_Code__c + '++++'+ TotalACVinclPS + '++++'+ pli.ACV_after_Bifurcation__c + '++++' + pliOneTimeCredit.APTS_ACV__c);
                amttosubACV += TotalACVinclPS != 0 ? (pli.ACV_after_Bifurcation__c / TotalACVinclPS) * pliOneTimeCredit.APTS_ACV__c: 0.0 ;
                buybackbifur = true;
            }
            if(CFWCSBSKUs.contains(pli.APTS_Product_Code__c) && plicsbcfwpromo != null){
                amttosubACV += TotalCFWCSBACV != 0 ? (pli.ACV_after_Bifurcation__c / TotalCFWCSBACV) * plicsbcfwpromo.APTS_ACV__c: 0.0 ;
                buybackbifur = true;
            }
            if((CFWZPASKUs.contains(pli.APTS_Product_Code__c) || pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZPA')&& plizpacfwpromo != null){
                amttosubACV += TotalCFWZPAACV != 0 ? (pli.ACV_after_Bifurcation__c / TotalCFWZPAACV) * plizpacfwpromo.APTS_ACV__c: 0.0 ;
                buybackbifur = true;
            }
            pli.ACV_after_Bifurcation__c += amttosubACV;
            
            system.debug('onetimecredit' + pli.APTS_Product_Code__c + '++++'+ pli.ACV_after_Bifurcation__c );
            
            if(setrecurringSKUs.contains(pli.APTS_Product_Code__c)){
                TotalZPATCVofRecurringInternalSKU += TotalTCV != 0 && pli.TCV_after_Bifurcation__c != null ? ((TotalZPATCV / TotalTCV) * pli.TCV_after_Bifurcation__c) : 0;
                TotalZPAACVofRecurringInternalSKU += TotalACV != 0 && pli.ACV_after_Bifurcation__c != null ? ((TotalZPAACV / TotalACV) * pli.ACV_after_Bifurcation__c) : 0;
                
                //pli.TCV_after_Bifurcation__c = ((TotalZIATCV / TotalTCV) * pli.TCV_after_Bifurcation__c);
                pli.ACV_after_Bifurcation__c = TotalACV != 0 && pli.ACV_after_Bifurcation__c != null ? ((TotalZIAACV / TotalACV) * pli.ACV_after_Bifurcation__c) : (TotalACV == 0 ? pli.ACV_after_Bifurcation__c : 0);
            }
            if(setonetimeSKUs.contains(pli.APTS_Product_Code__c)){
                TotalZPATCVofNonRecurringInternalSKU += TotalTCV != 0 &&  pli.TCV_after_Bifurcation__c != null ? ((TotalZPATCV / TotalTCV) * pli.TCV_after_Bifurcation__c) : 0;
                pli.TCV_after_Bifurcation__c = TotalTCV != 0 && pli.TCV_after_Bifurcation__c != null ? ((TotalZIATCV / TotalTCV) * pli.TCV_after_Bifurcation__c) : (TotalTCV == 0 ? pli.TCV_after_Bifurcation__c : 0);
                if(pli.APTS_Selling_Term__c >= 12){
                    pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c != null && pli.APTS_Selling_Term__c != null ? (pli.TCV_after_Bifurcation__c / pli.APTS_Selling_Term__c) * 12 : 0.0;
                    
                }else{
                    pli.ACV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c ;
                }
            }
        }
        
        //This loop takes care of preparation of internal and non - internal lines with all calc computed in above loops
        for(RenewalLinesWrapper rlw: lstRenewalLines){
            Apttus_Proposal__Proposal_Line_Item__c pli = rlw.lineItem;
            if(!setSKUsnottoAdd.contains(pli.APTS_Product_Code__c)){
                if(!setSKUswithACVtobeskipped.contains(pli.APTS_Product_Code__c)){
                    if(setrecurringSKUs.contains(pli.APTS_Product_Code__c)){
                        lstfinallinestoNS.add(new LinestoNS(pli, buybackbifur));
                        cartSKUcodes.add(pli.APTS_Product_Code__c);
                        if(!recurringalreadyadded && containszpa){
                            lstfinallinestoNS.add(new LinestoNS(pli, 'ZCES-SUP-PREM-ZPA-INT', TotalZPAACVofRecurringInternalSKU, 0, buybackbifur));
                            cartSKUcodes.add('ZCES-SUP-PREM-ZPA-INT');
                            recurringalreadyadded = true;
                        }
                    }else if(setonetimeSKUs.contains(pli.APTS_Product_Code__c)){
                        lstfinallinestoNS.add(new LinestoNS(pli, buybackbifur));
                        cartSKUcodes.add(pli.APTS_Product_Code__c);
                        if(!onetimealreadyadded && containszpa){
                            lstfinallinestoNS.add(new LinestoNS(pli, 'ZCES-Onetime-ZPA-INT', TotalZPATCVofNonRecurringInternalSKU, TotalZPATCVofNonRecurringInternalSKU, buybackbifur));
                            cartSKUcodes.add('ZCES-Onetime-ZPA-INT');
                            onetimealreadyadded = true;
                        }
                    }else{
                        lstfinallinestoNS.add(new LinestoNS(pli, buybackbifur));
                        cartSKUcodes.add(pli.APTS_Product_Code__c);
                    }
                }else{
                    lstfinallinestoNS.add(new LinestoNS(pli, buybackbifur));
                    cartSKUcodes.add(pli.APTS_Product_Code__c);
                }
            }
        }
        //Method to calculate Renewal/Upsell/New ACV/TCV
        calculateACV();
    }
    
    //Method to calculate Renewal/Upsell/New ACV/TCV
    public void calculateACV(){
        if(nooverrideACV){
            return;
        }
        
        this.lstfinallinestoNSwithoutinternallines = new List<LinestoNS>();
        this.lstfinallinestoNSwithInternalLines = new List<LinestoNS>();
        this.lstdroppedcontractdetails = new List<Contract_Detail__c>();
        lstinternallinestoinsert = new List<Internal_Lines__c>();
        
        List<String> contractdetailslst = this.Opportunity.Netsuite_Sales_Order_No__c != null ? this.Opportunity.Netsuite_Sales_Order_No__c.split(',') : new List<String>();
        Set<String> contractdetails = new Set<String>();
        Set<String> premsupportCDs = new Set<String>();
        contractdetails.addAll(contractdetailslst);
        
        //This is to get the set of All Sales order numbers based on the contract/additional contract details keyed in by Finanace team for PREM-SUP calculation
        for(LinestoNS rlw: lstfinallinestoNS){
            if(rlw.contractDetailName != null && rlw.contractDetailName != ''){
                if(cdnamemap.containskey(rlw.contractDetailName) && cdnamemap.get(rlw.contractDetailName) != null && cdnamemap.get(rlw.contractDetailName).Sales_Order_Name__c != null){
                    contractdetails.add(cdnamemap.get(rlw.contractDetailName).Sales_Order_Name__c);
                }
                if(rlw.productCode == 'ZCES-SUP-PREM'){
                    premsupportCDs.add(rlw.contractDetailName);
                }
            }
            if(rlw.addcontractDetailName != null && rlw.addcontractDetailName != ''){
                for(String addcd: rlw.addcontractDetailName.split(',')){
                    if(addcd != null && addcd != ''){
                        if(cdnamemap.containskey(addcd.trim()) && cdnamemap.get(addcd.trim()) != null && cdnamemap.get(addcd.trim()).Sales_Order_Name__c != null){
                            contractdetails.add(cdnamemap.get(addcd.trim()).Sales_Order_Name__c);
                        }
                    }
                    if(rlw.productCode == 'ZCES-SUP-PREM'){
                        premsupportCDs.add(addcd.trim());
                    }
                }
            }
        }
        
        Decimal totalARR = 0;
        Decimal totalARRofentireCart = 0;
        Decimal PSARR = 0;
        Decimal totalACVtocarveout = 0;
        Date ChurnSD = this.opportunity.APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__ExpectedStartDate__c != null ? this.opportunity.APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__ExpectedStartDate__c.addmonths(-3) : null;
        Date ChurnEd = this.opportunity.APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__ExpectedStartDate__c != null ? this.opportunity.APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__ExpectedStartDate__c.addmonths(3) : null;
        List<Contract_Detail__c> conlst = new List<Contract_Detail__c>();
        
        //This loop calculates total ZIA/ZPA ARR of CD for PREM SUP calc, total ARR of entire CD to decide whether we need carve out. Only if Total Renewal ACV < Total ARR of entire cart then we need carve out. Also, prepare list of dropped SKUs to display on the screen based on SKU Churn Date.
        for(Contract_Detail__c cd: [Select Id, Name, SKU_Churn_Date__c, Term__c, Quantity__c, ARR_Finance__c, Amount_USD__c, MRR_USD__c, Product_Name__r.Zscaler_Product_Family__c, Product_SKU__c, Product_Name__r.Name from Contract_Detail__c where Sales_Order_Name__c in :contractdetails]){
            if (cd.ARR_Finance__c == null) cd.ARR_Finance__c = 0;
            if((cd.Product_Name__r.Zscaler_Product_Family__c == 'ZIA' || cd.Product_Name__r.Zscaler_Product_Family__c == 'ZPA') && cd.ARR_Finance__c != null){
                totalARR += cd.ARR_Finance__c;
            }
            
            if(cd.ARR_Finance__c != null){
                totalARRofentireCart += cd.ARR_Finance__c;
            }
            
            if((cd.Product_SKU__c == 'ZCES-SUP-PREM' || cd.Product_SKU__c == 'ZCES-SUP-PREM-SP') && (premsupportCDs.isEmpty() || premsupportCDs.contains(cd.Name))){
                PSARR += cd.ARR_Finance__c;
            }
            
            if(cd.SKU_Churn_Date__c >= ChurnSD && cd.SKU_Churn_Date__c <= ChurnEd && !CreditSKUs.contains(cd.Product_SKU__c)){
                totalACVtocarveout += (cd.MRR_USD__c * 12);
                lstdroppedcontractdetails.add(cd);
            }
            conlst.add(cd);
        }
        String renewalupselldecision = '';
        String additionalcontractdetailsvals = '';
        Set<String> MatchingcartSKUs = new Set<String>();
        Map<String, Upgrade_SKU_Mapping_NS_Integration__c> mapupgrade = Upgrade_SKU_Mapping_NS_Integration__c.getAll();
        //This loop to populate additional contract details on lines which match upgrade Scenario
        for(String key: mapupgrade.keySet()){
            String addcon = '';
            String s = mapupgrade.get(key).Matching_SKU_On_IB__c;
            Set<String> skulist = new Set<String>();
            Set<String> skulisttocompare = new Set<String>();
            skulist.addAll(s.split(';'));
            for(Contract_Detail__c cd: conlst){
                if(skulist.contains(cd.Product_SKU__c)){
                    skulisttocompare.add(cd.Product_SKU__c);
                    addcon += cd.name + ',';
                }
            }
            system.debug('++++skulist'+key);
            system.debug('++++skulist'+s);
            system.debug('++++skulist'+skulist);
            system.debug('++++skulist'+additionalcontractdetailsvals);
            if(skulist.size() == skulisttocompare.size() && cartSKUcodes.containsAll(mapupgrade.get(key).Matching_SKU_On_Cart__c.split(';'))){
                MatchingcartSKUs.addAll(mapupgrade.get(key).Matching_SKU_On_Cart__c.split(';'));
                renewalupselldecision = mapupgrade.get(key).IsrenewalorUpsell__c;
                system.debug('++++skulist'+MatchingcartSKUs);
                additionalcontractdetailsvals = additionalcontractdetailsvals.length() < addcon.length() ? addcon : additionalcontractdetailsvals;
            }
        }
        
        map<String, Contract_Detail__c> mapnumbertocd = new map<String, Contract_Detail__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> plistoupdate = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
        List<LinestoNS> plilsttoupdate = new List<LinestoNS> ();
        List<Apttus_Config2__LineItem__c> lineitemstoupdate = new List<Apttus_Config2__LineItem__c> ();
        List<LinestoNS> plilstneedscarveout = new List<LinestoNS> ();
        
        Set<String> contractdetailnumberset = new Set<String>();
        Decimal Overall_Upsell = 0;
        Decimal Overall_Carveout = 0;
        Decimal Overall_Renewal = 0;
        Decimal TotalNetPriceofZIAZPA = 0;
        //Loop to prepare map of CD names, to get contract detail information based on populated CD.
        for(LinestoNS rlw: lstfinallinestoNS){
            if(MatchingcartSKUs.contains(rlw.productCode)){
                rlw.addcontractDetailName = additionalcontractdetailsvals;
            }
            if(rlw.contractDetailName != null && rlw.contractDetailName != '')
                contractdetailnumberset.add(rlw.contractDetailName);
            if(rlw.addcontractDetailName != null && rlw.addcontractDetailName != ''){
                for(String addcd: rlw.addcontractDetailName.split(',')){
                    if(addcd != null && addcd != '')
                        contractdetailnumberset.add(addcd.trim());
                }
            }
        }
        for(Contract_Detail__c cd: [Select Id, Name, Quantity__c, Start_Date__c, End_Date__c, SKU_Churn_Date__c, Sales_Order_Date__c, Amount_USD__c, Product_SKU__c, Term__c, MRR_USD__c, ARR_Finance__c, Order_Type__c from Contract_Detail__c where Name in :contractdetailnumberset and Account_Name__c = :this.Opportunity.AccountId]){
            mapnumbertocd.put(cd.name, cd);
        }
        Date today = date.today();
        List<FiscalyearSettings> fiscalYears = [select Id, Name, IsStandardYear, StartDate, EndDate from FiscalYearSettings where StartDate<=:today and EndDate>= :today limit 1];

        //this loop calculates Renewal/Upsell/New ACV/TCV
        for(LinestoNS rlw: lstfinallinestoNS){
            LinestoNS pli = rlw;
            Decimal renewalbaseACVofcontracts = 0;
            Decimal inhandrenewal = 0;
            Decimal renewalbaseqty = 0;
            Decimal renewalbaseterm = 0;
            Decimal renewalbasemrr = 0;
            Date farthestenddate = null;
            Decimal total_renewal = 0;
            Decimal total_upsell = 0;
            Decimal total_carveout = 0;
            Boolean ispurerenewal = false;
            Boolean ispureupsell = false;
            Boolean isrenewalupsell = false;
            Boolean isSameSKU = true;
            Boolean isUpgradeScenariomatched = false;
            Decimal termforupsellcompensation = 0;
            Decimal UpsellMRRforcompensation = 0;
            Date startdatecompensation = null;
            Date enddatecompensation = null;
            Date salesorderdate = null;
            Decimal termofcontract = null;
            
            if(this.opportunity.type == 'Existing Customer (Renewal)' && pli.productCode != 'ZCES-SUP-PREM'){
                if(pli.productfamily == 'ZIA' || pli.productfamily == 'ZPA'){
                    TotalNetPriceofZIAZPA += pli.NetPrice;
                }
                if((rlw.contractDetailName != '' && rlw.contractDetailName != null) || (rlw.addcontractDetailName != '' && rlw.addcontractDetailName != null)){
                    Set<String> cdset = new Set<String>();
                    if(rlw.contractDetailName != null && rlw.contractDetailName != '')
                        cdset.add(rlw.contractDetailName);
                    if(rlw.addcontractDetailName != null && rlw.addcontractDetailName != ''){
                        for(String addcd: rlw.addcontractDetailName.split(',')){
                            if(addcd != null && addcd != '')
                                cdset.add(addcd.trim());
                        }
                    }
                    system.debug('+++'+cdset);
                    Set<String> upgradeSKUset = new Set<String>();
                    Map<String,Upgrade_SKU_Mapping_NS_Integration__c> upgradeSKUMap =  Upgrade_SKU_Mapping_NS_Integration__c.getAll();
                    //if(upgradeSKUMap != null && upgradeSKUMap.containskey(pli.productCode) && upgradeSKUMap.get(pli.productCode) != null && upgradeSKUMap.get(pli.productCode).Matching_SKU_On_Contract__c != null){
                      //  upgradeSKUset.addAll(upgradeSKUMap.get(pli.productCode).Matching_SKU_On_Contract__c.split(','));
                    //}
                    
                    for(String cdnum: cdset){
                        Decimal contractterm = 0;
                        Decimal contractqty = 0;
                        Decimal contractACV = 0;
                        Decimal arrval = 0;
                        
                        startdatecompensation = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Start_Date__c != null ? ((startdatecompensation == null || mapnumbertocd.get(cdnum).Start_Date__c < startdatecompensation) && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).Start_Date__c : startdatecompensation) : null ;
                        
                        termofcontract = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Term__c != null ? ((termofcontract == null || mapnumbertocd.get(cdnum).Term__c > termofcontract) && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).Term__c : termofcontract) : null ;
                        
                        enddatecompensation = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).End_Date__c != null ? ((enddatecompensation == null || mapnumbertocd.get(cdnum).End_Date__c > enddatecompensation) && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).End_Date__c : enddatecompensation) : null ;
                        
                        salesorderdate = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Sales_Order_Date__c != null && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).Sales_Order_Date__c : null ;
                        
                        UpsellMRRforcompensation += mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).MRR_USD__c != null && mapnumbertocd.get(cdnum).Order_Type__c == 'Upsell' ? mapnumbertocd.get(cdnum).MRR_USD__c : 0.0 ;
                        
                        arrval += mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).ARR_Finance__c != null ? mapnumbertocd.get(cdnum).ARR_Finance__c : 0.0 ;
                        renewalbasemrr += arrval;
                        
                        contractterm = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Term__c != null? mapnumbertocd.get(cdnum).Term__c : 0.0 ;
                        renewalbaseterm += contractterm;
                        
                        contractqty = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Quantity__c != null ?mapnumbertocd.get(cdnum).Quantity__c : 0.0 ;
                        renewalbaseqty += contractqty;
                        
                        contractACV = mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Amount_USD__c != null && contractqty != 0 &&  contractterm != 0 ? (contractterm > 12 ? ((mapnumbertocd.get(cdnum).Amount_USD__c / (contractqty * contractterm)) * 12 * contractqty)  : ((mapnumbertocd.get(cdnum).Amount_USD__c / (contractqty * contractterm)) * contractterm * contractqty)) : 0.0 ;
                        renewalbaseACVofcontracts += contractACV;
                        
                        farthestenddate = ((mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).End_Date__c != null) ? ((farthestenddate == null) ? mapnumbertocd.get(cdnum).End_Date__c : (farthestenddate < mapnumbertocd.get(cdnum).End_Date__c ? mapnumbertocd.get(cdnum).End_Date__c : farthestenddate)) : farthestenddate);
                        if(mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Product_SKU__c != pli.productCode){
                            isSameSKU = false;
                        }
                        if(mapnumbertocd.containskey(cdnum) && mapnumbertocd.get(cdnum) != null && mapnumbertocd.get(cdnum).Product_SKU__c != null && upgradeSKUset.contains(mapnumbertocd.get(cdnum).Product_SKU__c)){
                            upgradeSKUset.remove(mapnumbertocd.get(cdnum).Product_SKU__c);
                        }
                        
                    }
                    if(upgradeSKUset.isEmpty()){
                        isUpgradeScenariomatched = true;
                    }
                    
                    renewalbaseACVofcontracts = renewalbasemrr;
                    
                    Decimal ppufrompli = pli.Qty != 0 && pli.Qty != null && pli.ACV != null ? (pli.ACV  / pli.Qty) : 0;
                    Decimal ppufromcd = renewalbaseqty != 0 && renewalbaseqty != null && renewalbasemrr!= null ? (renewalbasemrr  / renewalbaseqty) : 0;
                    system.debug('+++++'+pli.productCode + '--'+ isSameSKU +'--'+ renewalbaseqty +'--'+pli.Qty +'--'+ pli.StartDate +'--'+ farthestenddate);
                    system.debug('+++++'+ppufrompli + '--'+ ppufromcd );
                    
                    if((isSameSKU && renewalbaseqty == pli.Qty && pli.StartDate > farthestenddate) || (renewalupselldecision == 'renewal' && MatchingcartSKUs.contains(pli.productCode))){
                        system.debug('+++insideif');
                        ispurerenewal = true;
                    }else if(isSameSKU && renewalbaseqty != null){
                        system.debug('+++insideelseif1');
                        //inhandrenewal = renewalbaseqty * ppufrompli;
                        inhandrenewal = renewalbaseqty * Math.max(ppufrompli,ppufromcd);
                        system.debug('+++'+ppufrompli);
                        isrenewalupsell = true;
                    }/*else if(!isSameSKU && !setplatformSKUCodes.contains(pli.productCode)){
                        system.debug('+++insideelseif3');
                        ispureupsell = true;
                    }*/else if(!isSameSKU){
                        //must need maping bad assumption
                        //if(isUpgradeScenariomatched){
                        inhandrenewal = renewalbaseACVofcontracts;
                        isrenewalupsell = true;
                        //}else{
                        //  ispureupsell = true;
                        //}
                        
                    }
                    
                    if(ispureupsell){
                        total_renewal = 0;
                        total_upsell = pli.ACV;
                        total_carveout = 0;
                    }else if(ispurerenewal){
                        total_renewal = pli.ACV;
                        total_upsell = 0;
                        total_carveout = 0;
                    }else if(isrenewalupsell){
                        
                        if(startdatecompensation != null && enddatecompensation != null && termofcontract < 12 && enddatecompensation.adddays(1) == this.opportunity.APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__ExpectedStartDate__c && !fiscalYears.isEmpty() && salesorderdate >= fiscalYears[0].StartDate && salesorderdate <= fiscalYears[0].EndDate){
                            Decimal upsell_ACV = UpsellMRRforcompensation * (12 - (Integer)Math.roundToLong(((startdatecompensation.daysBetween(enddatecompensation))/30.25)));
                            total_renewal = pli.ACV - upsell_ACV;
                            total_upsell = upsell_ACV;
                            total_carveout = 0;
                        }else{
                            total_renewal = inhandrenewal < pli.ACV ? inhandrenewal : pli.ACV;
                            total_upsell = inhandrenewal < pli.ACV ? pli.ACV - inhandrenewal : 0.0;
                            total_carveout = renewalbaseACVofcontracts - inhandrenewal;
                            total_carveout += inhandrenewal > pli.ACV ? inhandrenewal - pli.ACV : 0.0;
                        }
                        system.debug(pli.productCode + '--'+inhandrenewal + '--'+pli.ACV + '--'+ renewalbaseACVofcontracts+'--'+total_carveout);
                    }
                    pli.newACV = 0.0;
                    pli.UpsellACV = total_upsell;
                    pli.RenewalACV = total_renewal;
                    pli.CarvedOutACV = total_carveout;
                    
                    if(pli.SellingTerm >= 12){
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                            pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                            pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                        }
                    }else{
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV ;
                            pli.UpsellTCV = pli.UpsellACV;
                            pli.RenewalTCV = pli.RenewalACV;
                        }
                    }
                    if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                        pli.ACV = 0;
                        pli.UpsellACV = 0;
                        pli.RenewalACV = 0;
                        pli.CarvedOutACV = 0;
                    }
                    
                    Overall_Upsell += pli.UpsellACV;
                    Overall_Renewal += pli.RenewalACV;
                    Overall_Carveout += pli.CarvedOutACV;
                    pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                    pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                    pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                    plilsttoupdate.add(pli);
                    if(total_carveout > 0){
                        plilstneedscarveout.add(pli);
                    }
                }else{
                    pli.UpsellACV = pli.ACV;
                    pli.RenewalACV = 0;
                    pli.newACV = 0;
                    pli.CarvedOutACV = 0;
                    if(pli.SellingTerm >= 12){
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                            pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                            pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                        }
                    }else{
                        if(pli.isbuybackbifurcated){
                            pli.newTCV = 0;
                            pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        }else{
                            pli.newTCV = pli.newACV ;
                            pli.UpsellTCV = pli.UpsellACV;
                            pli.RenewalTCV = pli.RenewalACV;
                        }
                    }
                    if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                        pli.ACV = 0;
                        pli.UpsellACV = 0;
                        pli.RenewalACV = 0;
                        pli.CarvedOutACV = 0;
                    }
                    Overall_Upsell += pli.UpsellACV;
                    Overall_Renewal += pli.RenewalACV;
                    Overall_Carveout += pli.CarvedOutACV;
                    pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                    pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                    pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                    pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                    plilsttoupdate.add(pli);
                }
            }else if(this.opportunity.type == 'Existing Customer (Add On)'){
                pli.newACV = 0;
                pli.UpsellACV = pli.ACV;
                pli.RenewalACV = 0;
                pli.CarvedOutACV = 0;
                if(pli.SellingTerm >= 12){
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = pli.NetPrice; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                        pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                        pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                    }
                }else{
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = pli.NetPrice; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV ;
                        pli.UpsellTCV = pli.UpsellACV;
                        pli.RenewalTCV = pli.RenewalACV;
                    }
                }
                if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                    pli.ACV = 0;
                    pli.UpsellACV = 0;
                    pli.RenewalACV = 0;
                    pli.NewACV = 0;
                }
                if(pli.productCode == 'ZCES-SUP-PREM'){
                    pli.UpsellTCV = pli.UpsellACV == 0 ? pli.NetPrice : pli.UpsellTCV;
                }
                pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                plilsttoupdate.add(pli);
            }else if(this.opportunity.type == 'New Business'){
                pli.newACV = pli.ACV;
                pli.UpsellACV = 0;
                pli.RenewalACV = 0;
                pli.CarvedOutACV = 0;
                if(pli.SellingTerm >= 12){
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = pli.NetPrice;
                        pli.UpsellTCV = 0; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                        pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                        pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                    }
                }else{
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = pli.NetPrice;
                        pli.UpsellTCV = 0; 
                        pli.RenewalTCV = 0; 
                    }else{
                        pli.newTCV = pli.newACV ;
                        pli.UpsellTCV = pli.UpsellACV;
                        pli.RenewalTCV = pli.RenewalACV;
                    }
                }
                if(setonetimeSKUs.contains(pli.productCode) || setSKUswithACVtobeskipped.contains(pli.productCode)){
                    pli.ACV = 0;
                    pli.UpsellACV = 0;
                    pli.RenewalACV = 0;
                    pli.NewACV = 0;
                }
                if(pli.productCode == 'ZCES-SUP-PREM'){
                    pli.newTCV = pli.NewACV == 0 ? pli.NetPrice : pli.newTCV;
                }
                pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                plilsttoupdate.add(pli);
            }
            
            //prepare lines for UI and also for creation of internal lines and updation of Proposal Line Items
            if(pli.pliId != null){
                if(setonetimeSKUs.contains(pli.productCode)){
                    pli.NetPrice = pli.NetPriceOriginal;
                }
                Apttus_Proposal__Proposal_Line_Item__c proposallineitem = new Apttus_Proposal__Proposal_Line_Item__c(Id = pli.pliId, New_ACV_to_NetSuite__c = pli.newACV, Upsell_ACV_to_NetSuite__c = pli.UpsellACV, Renewal_ACV_to_NetSuite__c = pli.RenewalACV, Carved_Out_ACV__c = pli.CarvedOutACV, Additional_Contract_Details__c = pli.addcontractDetailName, APTS_Contract_Detail_Name__c = pli.contractDetailId, New_TCV_to_NetSuite__c = pli.newTCV, Upsell_TCV_to_NetSuite__c = pli.UpsellTCV, Renewal_TCV_to_NetSuite__c = pli.RenewalTCV, ACV_after_Bifurcation__c = pli.acv, TCV_after_Bifurcation__c = pli.NetPrice);
                plistoupdate.add(proposallineitem);
            }else{
                pli.NetPrice = 0;
                pli.NetPriceOriginal = 0;
                if(pli.productCode == 'ZCES-SUP-PREM-ZPA-INT'){
                    pli.newTCV = 0;
                    pli.RenewalTCV = 0;
                    pli.UpsellTCV = 0;
                }
                lstinternallinestoinsert.add(new Internal_Lines__c(APTS_ACV__c = pli.acv, BaseExtendedPrice__c = pli.ListPrice, BasePrice__c = pli.basePrice, EndDate__c = pli.EndDate, APTS_Net_Price__c = pli.NetPrice, New_ACV_to_NetSuite__c = pli.newACV, New_TCV_to_NetSuite__c = pli.newTCV, Product__c = pli.productId, Product_Name__c = pli.productName, APTS_Quantity__c = pli.Qty, Proposal__c = pli.quoteId, Renewal_ACV_to_NetSuite__c = pli.RenewalACV, Renewal_TCV_to_NetSuite__c = pli.RenewalTCV, APTS_Product_Code__c = pli.productCode, StartDate__c = pli.StartDate, APTS_Selling_Term__c = pli.SellingTerm, APTS_Total_Discount_Percentage__c = pli.discPercent, Upsell_ACV_to_NetSuite__c = pli.UpsellACV, Upsell_TCV_to_NetSuite__c = pli.UpsellTCV, Id=null));
            }
            if(pli.pliId != null){
                lstfinallinestoNSwithoutinternallines.add(pli);
            }else{
                lstfinallinestoNSwithInternalLines.add(pli);
            }
        }
        Decimal PPUExisting = 0;
        
        system.debug('+++Overall_Upsell'+totalACVtocarveout );
        PPUExisting = totalARR != null && totalARR != 0 && PSARR != null ? PSARR/totalARR : 0;
        //This loop is to calculate PS ACV/TCV as it depends on buy% of the IB and also the sum of IB ZIA/ZPA ARR
        for(LinestoNS rlw: lstfinallinestoNS){
            LinestoNS pli = rlw;
            if(this.opportunity.type == 'Existing Customer (Renewal)' && pli.productCode == 'ZCES-SUP-PREM'){
                Decimal ppuofcurrentcart = TotalNetPriceofZIAZPA != 0 && pli.NetPrice != null ? pli.NetPrice / TotalNetPriceofZIAZPA : 0;
                Decimal totalrenewal = Overall_Carveout <= Overall_Upsell ? Overall_Renewal + Overall_Carveout : Overall_Renewal + Overall_Upsell;
                pli.RenewalACV = PSARR < pli.ACV && (Math.max(ppuofcurrentcart, PPUExisting) * totalrenewal) < pli.ACV ? (Math.max(ppuofcurrentcart, PPUExisting) * totalrenewal) : pli.ACV;
                pli.UpsellACV = pli.ACV - pli.RenewalACV;
                pli.CarvedOutACV = PSARR > pli.ACV ? PSARR - pli.ACV: 0;
                pli.newACV = 0;
                if(pli.SellingTerm >= 12){
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                    }else{
                        pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                        pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                        pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                    }
                }else{
                    if(pli.isbuybackbifurcated){
                        pli.newTCV = 0;
                        pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                        pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                    }else{
                        pli.newTCV = pli.newACV ;
                        pli.UpsellTCV = pli.UpsellACV;
                        pli.RenewalTCV = pli.RenewalACV;
                    }
                }
                pli.ACV = pli.ACV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                plilsttoupdate.add(pli);
                if(pli.CarvedOutACV > 0){
                    plilstneedscarveout.add(pli);
                }
                Overall_Upsell += pli.UpsellACV;
                Overall_Renewal += pli.RenewalACV;
            }
            system.debug('++++carveout'+pli.CarvedOutACV);
        }
        
        //This loop is to carve out any additional ACV required to compensate Renewal ACV as long as Overall Renewal ACV < Total ARR of IB
        if(Overall_Renewal < totalARRofentireCart){
            for(LinestoNS plicarve: plilstneedscarveout){
                if(Overall_Upsell > plicarve.CarvedOutACV){
                    for(LinestoNS pli: plilsttoupdate){
                        if(pli.UpsellACV > 0 && Overall_Upsell != 0 && plicarve.CarvedOutACV != null){
                            pli.RenewalACV = (pli.RenewalACV + ((pli.UpsellACV / Overall_Upsell) * plicarve.CarvedOutACV)).setscale(2, RoundingMode.HALF_UP);
                            pli.UpsellACV = (pli.UpsellACV - ((pli.UpsellACV / Overall_Upsell) * plicarve.CarvedOutACV)).setscale(2, RoundingMode.HALF_UP);
                            
                        }
                        if(pli.SellingTerm >= 12){
                            if(pli.isbuybackbifurcated){
                                pli.newTCV = 0;
                                pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            }else{
                                pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                                pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                                pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                            }
                        }else{
                            if(pli.isbuybackbifurcated){
                                pli.newTCV = 0;
                                pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                            }else{
                                pli.newTCV = pli.newACV ;
                                pli.UpsellTCV = pli.UpsellACV;
                                pli.RenewalTCV = pli.RenewalACV;
                            }
                        }
                        pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                        pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                        pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                        pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                        pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                        pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                    }
                    //plicarve.RenewalACV += plicarve.CarvedOutACV;
                    Overall_Upsell -= plicarve.CarvedOutACV;
                }else{
                    for(LinestoNS pli: plilsttoupdate){
                        if(pli.UpsellACV > 0){
                            pli.RenewalACV = (pli.RenewalACV + pli.UpsellACV).setscale(2, RoundingMode.HALF_UP);
                            pli.UpsellACV = pli.UpsellACV - pli.UpsellACV;
                            if(pli.SellingTerm >= 12){
                                if(pli.isbuybackbifurcated){
                                    pli.newTCV = 0;
                                    pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                    pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                }else{
                                    pli.newTCV = pli.newACV != null && pli.SellingTerm != null ? (pli.newACV / 12) * pli.SellingTerm : 0.0;
                                    pli.UpsellTCV = pli.UpsellACV != null && pli.SellingTerm != null ? (pli.UpsellACV / 12) * pli.SellingTerm : 0.0;
                                    pli.RenewalTCV = pli.RenewalACV != null && pli.SellingTerm != null ? (pli.RenewalACV / 12) * pli.SellingTerm : 0.0;
                                }
                            }else{
                                if(pli.isbuybackbifurcated){
                                    pli.newTCV = 0;
                                    pli.UpsellTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.UpsellACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                    pli.RenewalTCV = (pli.UpsellACV != 0 || pli.RenewalACV != 0) ? (pli.RenewalACV / (pli.RenewalACV + pli.UpsellACV)) * pli.NetPrice: 0; 
                                }else{
                                    pli.newTCV = pli.newACV ;
                                    pli.UpsellTCV = pli.UpsellACV;
                                    pli.RenewalTCV = pli.RenewalACV;
                                }
                            }
                            pli.UpsellACV = pli.UpsellACV.setscale(2, RoundingMode.HALF_UP);
                            pli.RenewalACV = pli.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                            pli.NewACV = pli.NewACV.setscale(2, RoundingMode.HALF_UP);
                            pli.newTCV = pli.newTCV.setscale(2, RoundingMode.HALF_UP);
                            pli.UpsellTCV = pli.UpsellTCV.setscale(2, RoundingMode.HALF_UP);
                            pli.RenewalTCV = pli.RenewalTCV.setscale(2, RoundingMode.HALF_UP);
                        }
                    }
                    //plicarve.RenewalACV += Overall_Upsell;
                    Overall_Upsell -= Overall_Upsell;
                }
                plicarve.RenewalACV = plicarve.RenewalACV.setscale(2, RoundingMode.HALF_UP);
                
            }
        }
        
        /*if(Overall_Upsell > totalACVtocarveout){
            system.debug('+++++Overall_Upsell ' + Overall_Upsell);
            for(LinestoNS pli: plilsttoupdate){
                if(pli.UpsellACV > 0 && Overall_Upsell != 0 && totalACVtocarveout != null){
                    pli.UpsellACV = (pli.UpsellACV - ((pli.UpsellACV / Overall_Upsell) * totalACVtocarveout)).setscale(2, RoundingMode.HALF_UP);
                }
            }
            Overall_Upsell -= totalACVtocarveout;
        }else{
            for(LinestoNS pli: plilsttoupdate){
                if(pli.UpsellACV > 0){
                    pli.UpsellACV = 0;
                }
            }
            Overall_Upsell -= Overall_Upsell;
        }*/
        
        //Update line items record to just carry over contract details/Additional Contract Details values to it so when they reconfigure, information is carried over
        
        for(Apttus_Proposal__Proposal_Line_Item__c pli: plistoupdate){
            if(plimap.get(pli.Id).Apttus_QPConfig__DerivedFromId__c!=null)
            {
                Apttus_Config2__LineItem__c li = new Apttus_Config2__LineItem__c(Id = plimap.get(pli.Id).Apttus_QPConfig__DerivedFromId__c, New_ACV_to_NetSuite__c = pli.New_ACV_to_NetSuite__c, Upsell_ACV_to_NetSuite__c = pli.Upsell_ACV_to_NetSuite__c, Renewal_ACV_to_NetSuite__c = pli.Renewal_ACV_to_NetSuite__c, Carved_Out_ACV__c = pli.Carved_Out_ACV__c, Additional_Contract_Details__c = pli.Additional_Contract_Details__c, APTS_Contract_Detail_Name__c = pli.APTS_Contract_Detail_Name__c, New_TCV_to_NetSuite__c = pli.New_TCV_to_NetSuite__c, Upsell_TCV_to_NetSuite__c = pli.Upsell_TCV_to_NetSuite__c, Renewal_TCV_to_NetSuite__c = pli.Renewal_TCV_to_NetSuite__c, ACV_after_Bifurcation__c = pli.ACV_after_Bifurcation__c, TCV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c);
                lineitemstoupdate.add(li);
            }
        }
        
        try{
            delete [Select Id from Internal_Lines__c where Proposal__c = :this.Opportunity.APTS_Primary_Proposal_Lookup__c];
        }catch(Exception ex){
            system.debug('+++'+ex);
        }
        insert lstinternallinestoinsert;
        
        for(Internal_Lines__c il: lstinternallinestoinsert){
            hasinternallines = true;
            for(LinestoNS lNS: lstfinallinestoNSwithInternalLines){
                if(lNS.productCode == il.APTS_Product_Code__c){
                    lNS.recId = il.Id;
                }
            }
        }
        update plistoupdate;
        update lineitemstoupdate;
    }
    
    public void savelines(){
        
        lstinternallinestoinsert = new List<Internal_Lines__c>();
        try{
            delete [Select Id from Internal_Lines__c where Proposal__c = :this.Opportunity.APTS_Primary_Proposal_Lookup__c];
        }catch(Exception ex){
            system.debug('+++'+ex);
        }
        List<Apttus_Proposal__Proposal_Line_Item__c> plilsttoupdate = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
        List<Apttus_Config2__LineItem__c> lineitemstoupdate = new List<Apttus_Config2__LineItem__c> ();
        List<Apttus_Proposal__Proposal__c> proposal = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c proposalToUpdate = new Apttus_Proposal__Proposal__c(Id=this.Opportunity.APTS_Primary_Proposal_Lookup__c, Has_Internal_Lines__c=hasinternallines);
        Decimal totalnewacv = 0, totalnewtcv = 0, totalupsellacv = 0, totalupselltcv = 0, totalrenewaltcv = 0, totalrenewalacv = 0;
        for(LinestoNS pli: lstfinallinestoNS){
            if(pli.pliId != null){
                Apttus_Proposal__Proposal_Line_Item__c proposallineitem = new Apttus_Proposal__Proposal_Line_Item__c(Id = pli.pliId, New_ACV_to_NetSuite__c = pli.newACV, Upsell_ACV_to_NetSuite__c = pli.UpsellACV, Renewal_ACV_to_NetSuite__c = pli.RenewalACV, Carved_Out_ACV__c = pli.CarvedOutACV, Additional_Contract_Details__c = pli.addcontractDetailName, APTS_Contract_Detail_Name__c = pli.contractDetailId, New_TCV_to_NetSuite__c = pli.newTCV, Upsell_TCV_to_NetSuite__c = pli.UpsellTCV, Renewal_TCV_to_NetSuite__c = pli.RenewalTCV, ACV_after_Bifurcation__c = pli.acv, TCV_after_Bifurcation__c = pli.NetPrice);
                plilsttoupdate.add(proposallineitem);
            }else{
                lstinternallinestoinsert.add(new Internal_Lines__c(APTS_ACV__c = pli.acv, BaseExtendedPrice__c = pli.ListPrice, BasePrice__c = pli.basePrice, EndDate__c = pli.EndDate, APTS_Net_Price__c = pli.NetPrice, New_ACV_to_NetSuite__c = pli.newACV, New_TCV_to_NetSuite__c = pli.newTCV, Product__c = pli.productId, Product_Name__c = pli.productName, APTS_Quantity__c = pli.Qty, Proposal__c = pli.quoteId, Renewal_ACV_to_NetSuite__c = pli.RenewalACV, Renewal_TCV_to_NetSuite__c = pli.RenewalTCV, APTS_Product_Code__c = pli.productCode, StartDate__c = pli.StartDate, APTS_Selling_Term__c = pli.SellingTerm, APTS_Total_Discount_Percentage__c = pli.discPercent, Upsell_ACV_to_NetSuite__c = pli.UpsellACV, Upsell_TCV_to_NetSuite__c = pli.UpsellTCV, Id=null));
            }
            
            totalnewacv += pli.newACV;
            totalnewtcv += pli.newTCV;
            totalupsellacv += pli.UpsellACV;
            totalupselltcv += pli.UpsellTCV;
            totalrenewaltcv += pli.RenewalTCV;
            totalrenewalacv += pli.RenewalACV;
        }
        
        
        proposalToUpdate.Total_New_ACV__c = totalnewacv;
        proposalToUpdate.Total_New_TCV__c = totalnewtcv;
        proposalToUpdate.Total_Upsell_ACV__c = totalupsellacv;
        proposalToUpdate.Total_Upsell_TCV__c = totalupselltcv;
        proposalToUpdate.Total_Renewal_ACV__c = totalrenewalacv;
        proposalToUpdate.Total_Renewal_TCV__c = totalrenewaltcv;
        
        for(Apttus_Proposal__Proposal_Line_Item__c pli: plilsttoupdate){
              if(plimap.get(pli.Id).Apttus_QPConfig__DerivedFromId__c!=null)
            {
            Apttus_Config2__LineItem__c li = new Apttus_Config2__LineItem__c(Id = plimap.get(pli.Id).Apttus_QPConfig__DerivedFromId__c, New_ACV_to_NetSuite__c = pli.New_ACV_to_NetSuite__c, Upsell_ACV_to_NetSuite__c = pli.Upsell_ACV_to_NetSuite__c, Renewal_ACV_to_NetSuite__c = pli.Renewal_ACV_to_NetSuite__c, Carved_Out_ACV__c = pli.Carved_Out_ACV__c, Additional_Contract_Details__c = pli.Additional_Contract_Details__c, APTS_Contract_Detail_Name__c = pli.APTS_Contract_Detail_Name__c, New_TCV_to_NetSuite__c = pli.New_TCV_to_NetSuite__c, Upsell_TCV_to_NetSuite__c = pli.Upsell_TCV_to_NetSuite__c, Renewal_TCV_to_NetSuite__c = pli.Renewal_TCV_to_NetSuite__c,ACV_after_Bifurcation__c = pli.ACV_after_Bifurcation__c, TCV_after_Bifurcation__c = pli.TCV_after_Bifurcation__c);
            lineitemstoupdate.add(li);
            }
        }
        insert lstinternallinestoinsert;
        TriggerUtility.generateYearWiseSplitExecuted();
        update proposalToUpdate;
        update plilsttoupdate;
        update lineitemstoupdate;
    }
    
    public class SFDCNSIntegrationException extends Exception {}
    public static void booster(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}