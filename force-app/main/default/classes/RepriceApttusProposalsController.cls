public class RepriceApttusProposalsController {

    
    public String query;
    // public static List<Id> lstProposalIdsToReprice;
    public static Id proposalId { get; set; }

    public RepriceApttusProposalsController() {
        query = 'SELECT Id, Reprice_And_Finalize_Quote__c FROM Apttus_Proposal__Proposal__c WHERE Reprice_And_Finalize_Quote__c = true';
        Map<String,string> urlparams = ApexPages.currentPage().getParameters();
        System.debug('*** JSON.serialize(urlparams): ' + JSON.serialize(urlparams));
    }

    @RemoteAction
    public static List<Id> getAllProposalIdsToReprice(List<Id> proposalIdsToReprice) {
        List<Id> proposalIds = new List<Id>();

        for (Apttus_Proposal__Proposal__c proposal : [SELECT Id, Reprice_And_Finalize_Quote__c FROM Apttus_Proposal__Proposal__c WHERE Id IN :proposalIdsToReprice]) {
            proposalIds.add(proposal.Id);
        }

        return proposalIds;
    }

    @RemoteAction
    public static Id createCartForProposal(Id proposalId) {
        return APTSCU_CreateProposalUtility.createCartForProposal(proposalId);
    }

    @RemoteAction
    public static Boolean updateCartLinesPricingStatus(Id cartId) {
        List<Apttus_Config2__LineItem__c> lstLineItemsToUpdate = new List<Apttus_Config2__LineItem__c>();

        for (Apttus_Config2__LineItem__c lineItem : [SELECT Id, Apttus_Config2__PricingStatus__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = :cartId]) {
            lstLineItemsToUpdate.add(new Apttus_Config2__LineItem__c(Id = lineItem.Id, Apttus_Config2__PricingStatus__c = 'Pending'));
        }

        try {
            update lstLineItemsToUpdate;
        } catch (Exception ex) {
            System.debug('>>>> Error occurred while updating pricing status: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
            return false;
        }

        return true;
    }

    @RemoteAction
    public static Boolean updatePricingFields(Id cartId) {
        // create the update price request
        Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
        objUpdatePriceRequestDO.CartId = cartId;
        System.debug('>>>> objUpdatePriceRequestDO.CartId: ' + objUpdatePriceRequestDO.CartId);
        Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
        Boolean hasPendingItems = result.IsPricePending;
        System.debug('>>>> hasPendingItems: ' + hasPendingItems);
        return hasPendingItems;
    }

    @RemoteAction
    public static Boolean repriceCart(Id cartId) {
        return APTSCU_CreateProposalUtility.repriceCart(cartId);
    }

    @RemoteAction
    public static void finalizeCart(Id cartId) {
        TriggerUtility.opportunityOwnershipChangeExecuted();
        TriggerUtility.overrideACVValuesResetExecuted();
        TriggerUtility.opportunitySplitsAfterUpdateExecuted();
        TriggerUtility.revisitOpportunitySplitsSalesTerritoryExecuted();
        TriggerUtility.ERNotificationExecuted();
        TriggerUtility.architectureHistoryExecuted();
        TriggerUtility.updateTechValHistoryExecuted();
        TriggerUtility.updateOppNextStepHistoryExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.updateSEManagerEmailExecuted();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.oppPatchManagerAfterUpdateExecuted();
        Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
       // add request parameters
       request.CartId = cartId;
       system.debug('####'+cartid);
       // finalize the cart
       Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request);
       // APTSCU_CreateProposalUtility.finalizeCartRemote(cartId, null);
    }

    public Pagereference navigatetoURL() {
        Map<String,string> urlparams = ApexPages.currentPage().getParameters();
        System.debug('*** JSON.serialize(urlparams): ' + JSON.serialize(urlparams));

        Id quoteId = urlparams.containsKey('proposalIds') && urlparams.get('proposalIds') != null ? urlparams.get('proposalIds') : null;
        if (quoteId != null) {
            Apttus_Proposal__Proposal__c prop =  new Apttus_Proposal__Proposal__c (id = quoteid, Needs_Repricing__c = false, Co_Sell_Partner_Modified__c = false);
            update prop;
        }

        if(urlparams != null && urlparams.containskey('retURL') && urlparams.get('retURL') != null){
            String returl = urlparams.get('retURL');
            urlparams.remove('retURL');
            for(String s: urlparams.keyset()){
                if(s != null && urlparams.get(s) != null && !s.contains('com.salesforce'))
                    returl += '&'+s+'=' + urlparams.get(s);
            }
            system.debug('++++'+returl);
            return new Pagereference(returl);
        }else{
            String url = '/' + quoteId != null ? quoteId : '';
            return new Pagereference('/'+url);
        }
    }
}