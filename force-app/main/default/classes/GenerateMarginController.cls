public with sharing class GenerateMarginController {
    public list<Opportunity_Partner__c> opppart { get; set; }
    public Opportunity opp { get; set; }
    public String selectedPartner {get;set;}
    public List<ProposalLineItemWrapper> proposalLIList {get;set;}
    public ProposalLineItemWrapper PLIWrapperObj {get;set;}
    public string proposalId {get;set;}
    public List<Apttus_Proposal__Proposal__c> propList {get;set;}
    public Apttus_Proposal__Proposal__c prop {get;set;}
    public Map<Id,Opportunity_Partner__c> opptyPartnerList {get;set;}
    public Map<Id,Opportunity_Partner__c> accIdVsopptyPartnerMap {get;set;}
    public Static string DEAL_REG = 'Deal Reg';
    public Static string AW = 'Architecture Workshop';
    public Static string POV = 'POV';
    public Decimal totalDealRegMargin = 0;
    public Decimal totalAWMargin = 0;
    public Decimal totalPOVMargin = 0;
    public String selectedPartnerTitle {get;set;}
    public Boolean isDealRegHasToShow {get;set;}
    public Boolean isAWHasToShow {get;set;}
    public Boolean isPOVHasToShow {get;set;}
    public Decimal grandTotalMargin {get;set;}
    public Map<Id,Opportunity_Partner__c> mapForUseUniqueAccount {get;set;}
    List<Apttus_Proposal__Proposal_Line_Item__c> pliList {get;set;}
    
    // Constructor
    public GenerateMarginController() {
        proposalId = '';
        selectedPartnerTitle = '';
        grandTotalMargin = 0;
        proposalId = ApexPages.CurrentPage().getParameters().get('id');
        proposalLIList = new List<ProposalLineItemWrapper>();
        PLIWrapperObj = new ProposalLineItemWrapper();
        // Get Proposal
        propList = new List<Apttus_Proposal__Proposal__c>();
        propList = [SELECT  id,
                            Apttus_Proposal__Opportunity__c,
                            Deal_Reg_Margin__c,
                            POV_Margin__c,
                            AW__c,
                            Apttus_Proposal__Proposal_Name__c,
                            Distributor__c,
                            Apttus_QPConfig__BillToAccountId__c,
                            Distributor__r.Name,
                            Distributor__r.AW_Margin__c,
                            Total_Partner_AW_Margin__c,
                            Total_Partner_Deal_Reg_Margin__c,
                            Total_Partner_POV_Margin__c,
                            APTS_Selected_Partner_Name__c,
                            APTS_Related_Activities__c,
                            APTS_Total_Partner_Margin__c,
                            APTS_Total_Margin_Amount__c,
                            RecordType.Name
                        FROM Apttus_Proposal__Proposal__c
                        WHERE id =: proposalId LIMIT 1];
        if(propList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No proposal found! Please try again later.'));
        }else{
            // Set Proposal Variable
            prop = propList[0];
            // Get Proposal Line Item
            pliList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            pliList = [SELECT Id,
                                Apttus_Proposal__Proposal__c,
                                Apttus_Proposal__Product__c,
                                Apttus_Proposal__Product__r.Name,
                                Apttus_Proposal__Product__r.ProductCode,
                                Apttus_Proposal__Product__r.AW__c,
                                Apttus_Proposal__Product__r.PS_Deal_Reg__c,
                                Apttus_Proposal__Product__r.Fulfilment_Margin__c,
                                Apttus_Proposal__Product__r.POV__c,
                                Apttus_QPConfig__NetPrice__c,
                                Partner_Deal_Reg_Margin__c,
                                Partner_POV_Margin__c,
                                Partner_AW_Margin__c,
                                Apttus_QPConfig__LineStatus__c
                            FROM Apttus_Proposal__Proposal_Line_Item__c
                            WHERE Apttus_Proposal__Proposal__c =: prop.Id];
            if(pliList.isEmpty()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Proposal Line Items found for selected proposal! Please try again later.'));
            }else{
                // Get Opportunity Partners
                opptyPartnerList = new Map<Id,Opportunity_Partner__c>([SELECT  id,
                                            Name,
                                            Opportunity__c,
                                            Account__c,
                                            Account__r.Name,
                                            Account__r.AW_Margin__c,
                                            Account__r.Partner_Summit_Deg_Reg_Margin__c,
                                            Account__r.POV_Margin__c,
                                            Account__r.Fulfilment_Margin__c,
                                            Account__r.Allow_Margin_Override__c,
                                            Partner_Type__c
                                    FROM Opportunity_Partner__c
                                    WHERE Opportunity__c =: prop.Apttus_Proposal__Opportunity__c]);
                if(opptyPartnerList.isEmpty()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There aren\'t any partner associated with an opportunity! Please try again later.'));
                }else{
                    accIdVsopptyPartnerMap = new Map<Id,Opportunity_Partner__c>();
                    for(Opportunity_Partner__c prtner : opptyPartnerList.values()){
                        accIdVsopptyPartnerMap.put(prtner.Account__c,prtner);
                    }
                }
                System.debug('opptyPartnerList --> ' + opptyPartnerList);
                System.debug('accIdVsopptyPartnerMap --> ' + accIdVsopptyPartnerMap);
                
                // Popuate Option to Show
                mapForUseUniqueAccount = new Map<Id,Opportunity_Partner__c>();
                for(Opportunity_Partner__c oppPartObj : opptyPartnerList.Values()){
                    if((oppPartObj.Partner_Type__c == DEAL_REG && prop.Deal_Reg_Margin__c == false)
                        || (oppPartObj.Partner_Type__c == POV && prop.POV_Margin__c == false)
                        || (oppPartObj.Partner_Type__c == AW && prop.AW__c == false)
                        && oppPartObj.Account__c != prop.Distributor__c
                        && oppPartObj.Account__c != prop.Apttus_QPConfig__BillToAccountId__c){
                        if(mapForUseUniqueAccount.get(oppPartObj.Account__c) == null){
                            mapForUseUniqueAccount.put(oppPartObj.Account__c,oppPartObj);
                        }
                    }
                }
                if(mapForUseUniqueAccount.isEmpty()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There aren\'t any partner associated with an opportunity! Please try again later.'));
                }
            }
        }
    }
    
    public void selectedAccAction(){
        try{
            // New Logic
            // Check for --Select--
            selectedPartnerTitle = '';
            if(selectedPartner == '' || selectedPartner == null){
                proposalLIList = new List<ProposalLineItemWrapper>();
            }else{
                selectedPartnerTitle = 'Activity : ';
                isPOVHasToShow = false;
                isAWHasToShow = false;
                isDealRegHasToShow = false;
                grandTotalMargin = 0;
                // Now found all the partner account with relevant oppty partner account
                System.debug('selectedPartner --> '+ selectedPartner);
                List<Opportunity_Partner__c> opptyPartnerList_TEMP = new List<Opportunity_Partner__c>();
                for(Opportunity_Partner__c partner : opptyPartnerList.values()){
                    if(partner.Account__c == selectedPartner){
                        opptyPartnerList_TEMP.add(partner);
                        // Set Description
                        if(partner.Partner_Type__c == DEAL_REG){
                            isDealRegHasToShow = true;
                            selectedPartnerTitle = selectedPartnerTitle + 'Deal registration (Margin : '+ (partner.Account__r.Partner_Summit_Deg_Reg_Margin__c == null ? 0 : partner.Account__r.Partner_Summit_Deg_Reg_Margin__c) +'%),';
                        } else if(partner.Partner_Type__c == AW){
                            isAWHasToShow = true;
                            selectedPartnerTitle = selectedPartnerTitle + 'Architectural workshop (Margin : '+ (partner.Account__r.AW_Margin__c == null ? 0 : partner.Account__r.AW_Margin__c) +'%),';
                        } else if(partner.Partner_Type__c == POV){
                            isPOVHasToShow = true;
                            selectedPartnerTitle = selectedPartnerTitle + 'Proof of value (Margin : '+ (partner.Account__r.POV_Margin__c == null ? 0 : partner.Account__r.POV_Margin__c) +'%),';
                        }
                    }
                }
                prop.APTS_Related_Activities__c = '';
                if(isDealRegHasToShow){
                    prop.APTS_Related_Activities__c  = (prop.APTS_Related_Activities__c == null || prop.APTS_Related_Activities__c  == '' ? 'Deal Registration' : prop.APTS_Related_Activities__c + ', ' + 'Deal Registration');
                }
                if(isPOVHasToShow){
                    prop.APTS_Related_Activities__c  = (prop.APTS_Related_Activities__c == null || prop.APTS_Related_Activities__c  == '' ? 'Proof of Value' : prop.APTS_Related_Activities__c + ', ' + 'Proof of Value');
                }
                if(isAWHasToShow){
                    prop.APTS_Related_Activities__c  = (prop.APTS_Related_Activities__c == null || prop.APTS_Related_Activities__c  == '' ? 'Architectural Workshop' : prop.APTS_Related_Activities__c + ', ' + 'Architectural Workshop');
                }
                System.debug('prop.APTS_Related_Activities__c -->' + prop.APTS_Related_Activities__c);
                selectedPartnerTitle = selectedPartnerTitle + ' Selected partner is going to get:';
                System.debug('opptyPartnerList_TEMP --> '+ opptyPartnerList_TEMP);
                
                // Get Selected Account
                if(!opptyPartnerList_TEMP.isEmpty()){
                    totalAWMargin = 0;
                    totalDealRegMargin = 0;
                    totalPOVMargin = 0;
                    
                    // Populating totals
                    ProposalLineItemWrapper grandTotalLIWrpr = new ProposalLineItemWrapper();
                    grandTotalLIWrpr.product = 'Grand Total';
                    
                    // Margin Calculations
                    Decimal dealRegMarginPercentage = 0;
                    Decimal AWMarginPercentage = 0;
                    Decimal POVMarginPercentage = 0;
                    
                    for(Opportunity_Partner__c partner : opptyPartnerList_TEMP){
                        if(partner.Partner_Type__c == DEAL_REG){
                            dealRegMarginPercentage = partner.Account__r.Partner_Summit_Deg_Reg_Margin__c;
                        }else if(partner.Partner_Type__c == AW){
                            AWMarginPercentage = partner.Account__r.AW_Margin__c;
                        }else if(partner.Partner_Type__c == POV){
                            POVMarginPercentage = partner.Account__r.POV_Margin__c;
                        }
                    }
                    // Check for Null for each variables
                    if(dealRegMarginPercentage == null){
                        dealRegMarginPercentage = 0;
                    }
                    if(AWMarginPercentage == null){
                        AWMarginPercentage = 0;
                    }
                    if(POVMarginPercentage == null){
                        POVMarginPercentage = 0;
                    }
                    prop.APTS_Total_Partner_Margin__c = dealRegMarginPercentage + AWMarginPercentage + POVMarginPercentage;
                    System.debug('dealRegMarginPercentage --> ' + dealRegMarginPercentage);
                    System.debug('AWMarginPercentage --> ' + AWMarginPercentage);
                    System.debug('POVMarginPercentage --> ' + POVMarginPercentage);
                    
                    // Now Create Wrapper class list to showcase the margin and product list
                    proposalLIList = new List<ProposalLineItemWrapper>();
                    for(Apttus_Proposal__Proposal_Line_Item__c pli : pliList){
                        PLIWrapperObj = new ProposalLineItemWrapper();
                        PLIWrapperObj.product = pli.Apttus_Proposal__Product__r.Name;
                        PLIWrapperObj.SKU = pli.Apttus_Proposal__Product__r.ProductCode;
                        System.debug('pli.Apttus_QPConfig__NetPrice__c --> '+ pli.Apttus_Proposal__Product__r.Name + ' - ' + pli.Apttus_QPConfig__NetPrice__c);
                        
                        // Now loop through opptyPartnerList_TEMP to populate values for multiple partner type
                        for(Opportunity_Partner__c partner : opptyPartnerList_TEMP){
                            System.debug('pli.Apttus_Proposal__Product__r.PS_Deal_Reg__c --> ' + pli.Apttus_Proposal__Product__r.PS_Deal_Reg__c);
                            if(partner.Partner_Type__c == DEAL_REG 
                                && pli.Apttus_Proposal__Product__r.PS_Deal_Reg__c){
                                    if(dealRegMarginPercentage != null){
                                        if(prop.RecordType.Name == 'Renewal' && pli.Apttus_QPConfig__LineStatus__c != 'New' && pli.Apttus_QPConfig__LineStatus__c != 'Upgraded'){
                                            PLIWrapperObj.dealRegMarginPrice = 0;
                                            pli.Partner_Deal_Reg_Margin__c = 0;
                                        }else{
                                            PLIWrapperObj.dealRegMarginPrice = pli.Apttus_QPConfig__NetPrice__c * (dealRegMarginPercentage/100);
                                            pli.Partner_Deal_Reg_Margin__c = PLIWrapperObj.dealRegMarginPrice;
                                        }
                                        totalDealRegMargin += PLIWrapperObj.dealRegMarginPrice;
                                    }
                            }
                            System.debug('pli.Apttus_Proposal__Product__r.AW__c --> ' + pli.Apttus_Proposal__Product__r.AW__c);
                            if(partner.Partner_Type__c == AW 
                                && pli.Apttus_Proposal__Product__r.AW__c){
                                    if(AWMarginPercentage != null){
                                        if(prop.RecordType.Name == 'Renewal' && pli.Apttus_QPConfig__LineStatus__c != 'New' && pli.Apttus_QPConfig__LineStatus__c != 'Upgraded'){
                                            PLIWrapperObj.AWMarginPrice = 0;
                                            pli.Partner_AW_Margin__c = 0;
                                        }else{
                                            PLIWrapperObj.AWMarginPrice = pli.Apttus_QPConfig__NetPrice__c * (AWMarginPercentage/100);
                                            pli.Partner_AW_Margin__c = PLIWrapperObj.AWMarginPrice;                                        
                                        }
                                        totalAWMargin += PLIWrapperObj.AWMarginPrice;
                                    }
                            }
                            System.debug('pli.Apttus_Proposal__Product__r.POV__c --> ' + pli.Apttus_Proposal__Product__r.POV__c);
                            if(partner.Partner_Type__c == POV 
                                && pli.Apttus_Proposal__Product__r.POV__c){
                                    if(POVMarginPercentage != null){
                                        if(prop.RecordType.Name == 'Renewal' && pli.Apttus_QPConfig__LineStatus__c != 'New' && pli.Apttus_QPConfig__LineStatus__c != 'Upgraded'){
                                            PLIWrapperObj.POVMarginPrice = 0;
                                            pli.Partner_POV_Margin__c = 0;
                                        }else{
                                            PLIWrapperObj.POVMarginPrice = pli.Apttus_QPConfig__NetPrice__c * (POVMarginPercentage/100);
                                            pli.Partner_POV_Margin__c = PLIWrapperObj.POVMarginPrice;
                                        }
                                        totalPOVMargin += PLIWrapperObj.POVMarginPrice;
                                    }
                            }
                            // Calculate Total Margin for each PLI
                            PLIWrapperObj.TotalMarginPrice = 0;
                            if(PLIWrapperObj.dealRegMarginPrice != null){
                                PLIWrapperObj.TotalMarginPrice += PLIWrapperObj.dealRegMarginPrice;
                            }
                            if(PLIWrapperObj.AWMarginPrice != null){
                                PLIWrapperObj.TotalMarginPrice += PLIWrapperObj.AWMarginPrice;
                            }
                            if(PLIWrapperObj.POVMarginPrice != null){
                                PLIWrapperObj.TotalMarginPrice += PLIWrapperObj.POVMarginPrice;
                            }
                            
                            System.debug('totalPOVMargin inner --> ' + totalPOVMargin);
                            System.debug('PLIWrapperObj.POVMarginPrice inner --> ' + PLIWrapperObj.POVMarginPrice);
                        }
                        
                        proposalLIList.add(PLIWrapperObj);
                    }
                    // Update PLI
                    update pliList;
                    System.debug('totalDealRegMargin --> '+ totalDealRegMargin);
                    System.debug('totalAWMargin --> '+ totalAWMargin);
                    System.debug('totalPOVMargin --> '+ totalPOVMargin);
                    // Calculate grandTotalMargin
                    if(totalDealRegMargin != null){
                        grandTotalLIWrpr.dealRegMarginPrice = totalDealRegMargin;
                        grandTotalLIWrpr.TotalMarginPrice += totalDealRegMargin;
                    }
                    if(totalPOVMargin != null){
                        grandTotalLIWrpr.POVMarginPrice = totalPOVMargin;
                        grandTotalLIWrpr.TotalMarginPrice += totalPOVMargin;
                    }
                    if(totalAWMargin != null){
                        grandTotalLIWrpr.AWMarginPrice = totalAWMargin;
                        grandTotalLIWrpr.TotalMarginPrice += totalAWMargin;
                    }
                    System.debug('grandTotalLIWrpr --> ' + grandTotalLIWrpr);
                    proposalLIList.add(grandTotalLIWrpr);
                    
                    // Update total value on proposal header using opptyPartnerList_TEMP
                    for(Opportunity_Partner__c partner : opptyPartnerList_TEMP){
                        if(totalAWMargin != null && partner.Partner_Type__c == AW)
                            prop.Total_Partner_AW_Margin__c = totalAWMargin;
                        if(totalDealRegMargin != null && partner.Partner_Type__c == DEAL_REG)
                            prop.Total_Partner_Deal_Reg_Margin__c = totalDealRegMargin;
                        if(totalPOVMargin != null && partner.Partner_Type__c == POV)
                            prop.Total_Partner_POV_Margin__c = totalPOVMargin;
                    }
                    // Set newly created field for proposal
                    prop.APTS_Selected_Partner_Name__c = selectedPartner;
                    prop.APTS_Total_Margin_Amount__c = grandTotalLIWrpr.TotalMarginPrice;
                    update prop;
                }
            }
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception occure: ' +  ex.getMessage() + ' @ Line #' + ex.getLineNumber()));
        }
    }
    
    public class ProposalLineItemWrapper{
        public String product {get;set;}
        public String SKU {get;set;}
        public Decimal marginPrice {get;set;}
        public Decimal dealRegMarginPrice {get;set;}
        public Decimal AWMarginPrice {get;set;}
        public Decimal POVMarginPrice {get;set;}
        public Decimal TotalMarginPrice {get;set;}
        public ProposalLineItemWrapper(){
            this.product = '';
            this.marginPrice = 0;
            this.dealRegMarginPrice = 0;
            this.AWMarginPrice = 0;
            this.POVMarginPrice = 0;
            this.TotalMarginPrice = 0;
            this.SKU = '';
        }
    }
}