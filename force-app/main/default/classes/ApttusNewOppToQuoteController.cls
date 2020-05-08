/**
 *  Apttus Config & Pricing
 *  ApttusSyncOppToProposalController
 *   
 *  @2012 Apttus Inc. All rights reserved.
 */
public with sharing class ApttusNewOppToQuoteController {
    
    // page parameters
    public static final String PARAM_ID = 'id';
    public static final String PARAM_RECORDTYPE_ID = 'recordTypeId';
    public static final String PARAM_RECORDTYPE_NAME = 'recordType';
    public static final String PARAM_PRICELIST_NAME = 'pricelistid';
    
    // opportunity
    private ID opptyId = null;
    
    // proposal id
    private ID proposalId = null;
    
    // record type
    private ID recordTypeId = null;
    private String recordTypeName = null;
    
    // price list
    private ID priceListId = null;
    private String priceListName = null;
    
    // error indicator
    private Boolean hasErrors = false;
    List<Opportunity_Partner__c> OppPartnerList;
    
    /**
     * Class Constructor specifying initial values
     * @param stdController the standard controller
     */
    public ApttusNewOppToQuoteController(ApexPages.StandardController stdController) {
        
        // get the opportunity id
        this.opptyId = stdController.getId();
        
        // read parameters
        // record type id
        OppPartnerList = new List<Opportunity_Partner__c>();
        if(opptyId != null){
            OppPartnerList = [Select Id, Name, Is_Primary__c, Opportunity__c,  Partner_Type__c from Opportunity_Partner__c where Opportunity__c = :opptyId and Partner_Type__c = 'Reseller' And Is_Primary__c = true]; 
        }  
        
        String strValue = ApexPages.currentPage().getParameters().get(PARAM_RECORDTYPE_ID);
        if (!ApttusSyncOppQuote.nullOrEmpty(strValue)) {
            this.recordTypeId = String.escapeSingleQuotes(strValue);
        }
        
        // get record type
        strValue = ApexPages.currentPage().getParameters().get(PARAM_RECORDTYPE_NAME);
        if (!ApttusSyncOppQuote.nullOrEmpty(strValue)) {
            this.recordTypeName = String.escapeSingleQuotes(strValue);
        }
        
        // get price list
        strValue = ApexPages.currentPage().getParameters().get(PARAM_PRICELIST_NAME);
        if (!ApttusSyncOppQuote.nullOrEmpty(strValue)) {
            this.priceListName = String.escapeSingleQuotes(strValue);
        }
        
    }
    
    /**
     * Callback invoked when the page is loaded
     * @return the page reference 
     */
     
     /**
    	Updated BY : Sateesh U 
    	This method is used To create quote only when primary reseller partner exists.
    **/
    public PageReference onLoad() {
        
        PageReference pageRef = null;
        Savepoint sp = null;
        
        try {
            if(OppPartnerList.size()>0){
                // get the database savepoint
                sp = Database.setSavepoint();
                
                // get the opportunity sobject
                Opportunity opptySO = ApttusSyncOppQuote.getOpportunitySO(opptyId);
                
                // create the quote/proposal
                this.proposalId = ApttusSyncOppQuote.createQuoteOrProposal(opptySO, this.recordTypeName, this.priceListName);
                
                // navigate to the quote/proposal detail page
                //pageRef = new PageReference('/' + proposalId +'/e?retURL=%2F'+ proposalId);
                pageRef = new PageReference('/' + proposalId +'/e?retURL=/apex/APTS_CancelProposalCreation?id='+ proposalId);
                pageRef.setRedirect(true);
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Primary Reseller Partner is required to create quote'));
                hasErrors = true;
                return null;
            }
            
        }
        catch (Exception ex) {
            // report error
            ApexPages.addmessages(ex);  
            hasErrors = true;
            
            // if a savepoint was set, rollback updates
            if (sp != null) {
                Database.rollback(sp);
            }
            
            return null;
        }
        
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    /**
     * Performs the cancel action
     * @return the next page reference 
     */
    public PageReference doCancel() {
        // navigate to the opportunity 
        return new PageReference('/' + opptyId);
    }
    
    /**
     * Checks if there were errors in loading the page
     * @return <code>true</code> if there were errors, <code>false</code> otherwise
     */
    public Boolean getHasErrors() {
        return hasErrors;
    }
    
   
}