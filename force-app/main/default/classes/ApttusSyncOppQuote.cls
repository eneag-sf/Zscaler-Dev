/**
 *  Apttus Config & Pricing
 *  ApttusSyncOppSupport
 *
 *  @2012 Apttus Inc. All rights reserved.
 */
public abstract class ApttusSyncOppQuote {

    // business object type
    private static final String CATEGORY_QUOTE_OR_PROPOSAL = 'Proposal';

    // summary group types
    private static final String GROUPTYPE_PRODUCT = 'Product';

    // status
    private static final String STATUS_NEW = 'New';
    private static final String STATUS_FINALIZED = 'Finalized';

    // record types
    private static final String RECORDTYPE_PROPOSAL = 'Proposal';
    private static final String RECORDTYPE_RFP = 'RFP';

    // value types
    private static final String VALUETYPE_DEFAULT = 'Default';
    private static final String VALUETYPE_PRODUCT = 'Product';

    // guided interview types
    private static final String INTERVIEWNAME_DEFAULT = 'Default';

    // global default record name
    private static final String GLOBAL_DEFAULT_NAME = 'All';

    // max name field size
    private static final Integer MAX_NAME_SIZE = 80;

    // limit query fields
    public static final Integer LIMIT_ROWS = 1000;

    // lineitem types
    public static final String LINETYPE_PRODUCT = 'Product/Service';
    public static final String LINETYPE_OPTION = 'Option';
    public static final String LINETYPE_MISC = 'Misc';
    public static final String LINETYPE_ASSET = 'Asset';

    // custom exception class
    public class ApttusSyncOppQuoteException extends Exception {}

    /**
     * Creates a quote/proposal using the given opportunity
     * @param opptySO the opportunity to create the quote for
     * @param recordTypeName the name of the quote record type to create
     * @param priceListName the name of the price list to associate with the proposal
     * @return the id of the created quote/proposal
     */
    public static ID createQuoteOrProposal(
        Opportunity opptySO,
        String recordTypeName,
        String priceListName)
    {
        // get the proposal record type id
        if(opptySO.type=='Existing Customer (Add On)')
        {
            recordTypeName='Upsell';

        }
        else if(opptySO.type=='Existing Customer (Renewal)')
        {
            recordTypeName='Renewal';
        }
        else if(opptySO.type=='New Business')
        {
            recordTypeName='New Business';
        }
        else if (opptySO.type == 'NFR (Not For Resale)')
        {
            recordTypeName = 'NFR (Not For Resale)';
        }

        ID recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), recordTypeName);
        if (recordTypeId == null) {
            recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), RECORDTYPE_PROPOSAL);
            recordTypeName=RECORDTYPE_PROPOSAL;
        }

        // get the price list id
        ID priceListId = null;
        try {
            if(priceListName <> null){
                System.debug('>>>> priceListName: ' + priceListName);
                Apttus_Config2__PriceList__c priceListSO = [select Id,Name from Apttus_Config2__PriceList__c where Name=:priceListName limit 1];
                if (priceListSO != null) {
                    priceListId = priceListSO.Id;
                }
            } else {
                // Pass the default price list
                Apttus__APTS_Admin__c adminSetting = [SELECT Id, Name, Apttus__Value__c FROM Apttus__APTS_Admin__c WHERE Name = 'APTS_DefaultPriceList' LIMIT 1];
                if (adminSetting != null) {
                    priceListName = adminSetting.Apttus__Value__c;
                    Apttus_Config2__PriceList__c priceListSO = [select Id,Name from Apttus_Config2__PriceList__c where Name=:priceListName limit 1];
                    if (priceListSO != null) {
                        priceListId = priceListSO.Id;
                    }
                }
            }
        }
        catch(Exception ex) {
            throw new ApttusSyncOppQuoteException('Price list name \'' + priceListName + '\' not found.');
        }

        // create a new quote/proposal object from the opportunity
        Apttus_Proposal__Proposal__c proposalSO = createProposalFromOpportunity(opptySO, recordTypeId, priceListId,recordTypeName);
        TriggerUtility.updateProposalPriceListExecuted();
        insert proposalSO;
        TriggerUtility.updateProposalPriceListReset();

        // query the object again so we refresh formula field values
      //  proposalSO = getProposalSO(proposalSO.Id);
       // list<Proposal_Facility__c> facilitySO = new list<Proposal_Facility__c>();
        //Vrajesh has added to add facility object from opp to quote
        /**  Commented out for new MHS CPQ design
        facilitySO = createFacilitySO(proposalSO,opptySO);
        insert facilitySO;
        **/
        // get the quote/proposal id
        return proposalSO.Id;
    }

    /**
     * Creates a new proposal from the given opportunity
     * @param opptySO the opportunity to create the proposal for
     * @param recordTypeId the record type id for the proposal
     * @param priceListId the price list for the proposal
     * @return the created proposal
     */
    public static Apttus_Proposal__Proposal__c createProposalFromOpportunity(
        Opportunity opptySO,
        ID recordTypeId,
        ID priceListId, String recordTypeName)
    {
        // STEP I - create a new proposal sobject
        Apttus_Proposal__Proposal__c proposalSO = new Apttus_Proposal__Proposal__c();

        // initialize the proposal from the opportunity

        // STEP II - copy known opportunity fields
        // record type id
        if (recordTypeId != null) {
            proposalSO.RecordTypeId = recordTypeId;
        }
        else
        {
            //add logic to get record type
        }
        // proposal name (max length = 50)
        String opptyName = opptySO.Name;
        if (opptyName != null && opptyName.length() > 50) {
            opptyName = opptyName.substring(0, 50);
        }




        // base fields
        proposalSO.Apttus_Proposal__Proposal_Name__c = opptyName+' - '+recordTypeName;
        proposalSO.Apttus_Proposal__Opportunity__c = opptySO.Id;
        proposalSO.Apttus_Proposal__Account__c = opptySO.AccountId;
        proposalSO.Apttus_QPConfig__AutoActivateOrder__c=true;
        proposalSO.Apttus_Proposal__Primary__c = false;
        proposalSO.Apttus_QPConfig__PriceListId__c = priceListId;
        proposalSO.Apttus_QPConfig__PricingDate__c = Datetime.now();
        proposalSO.Apttus_Proposal__ExpectedStartDate__c = opptySO.CloseDate.addDays(1);
        proposalSO.Apttus_Proposal__ExpectedEndDate__c = proposalSO.Apttus_Proposal__ExpectedStartDate__c.addYears(3);
        //get created date
        Datetime dt=Datetime.now().addDays(30);
        proposalSO.Apttus_Proposal__Proposal_Expiration_Date__c =date.newinstance(dT.year(), dT.month(), dT.day()) ;
        proposalSO.Model_Type_Partner__c = opptySO.Primary_Partner_Program__c == null ? 'Legacy' : opptySO.Primary_Partner_Program__c;
      //  proposalSO.Apttus_Proposal__Proposal_Expiration_Date__c = Datetime.now().addDays(30);
       // proposalSO.Apttus_Proposal__Valid_Until_Date__c = Date.today().addDays(30);
      //  proposalSO.Apttus_Proposal__Payment_Term__c = true;
      //  proposalSO.APTS_CPQ_Billing_Frequency__c = true;
        proposalSO.Apttus_Proposal__ReadyToPresent__c = true;
        proposalSO.OwnerId = opptySO.OwnerId;



        return proposalSO;
    }



     /**
     * Gets the record type id associated with the given sobject name and record type name
     * @param sObjectName the sobject name
     * @param recordTypeName the record type name to get the record type for
     * @return the record type id
     */
    public static ID getRecordTypeIdForName(String sObjectName, String recordTypeName) {
        try {
            // get the record type
            List<RecordType> recordTypes = [SELECT Id
                                            FROM RecordType
                                            WHERE SobjectType = :sObjectName AND
                                                  (Name = :recordTypeName OR
                                                   DeveloperName = :recordTypeName)
                                            LIMIT 1];

            return (!recordTypes.isEmpty() ? recordTypes[0].Id : null);
        }
        catch(Exception ex) {
            return null;
        }
    }


    /**
     * Checks if the given string value is null or empty.
     * @param strValue the string to check
     * @return <code>true</code> if the string value is null or empty, <code>false</code> otherwise
     */
    public static Boolean nullOrEmpty(String strValue) {

        // check if null or zero length string
        return (strValue == null || strValue.trim().length() == 0);
    }
      /**
     * Gets the opportunity sobject for the given opportunity id
     * @param opptyId the opportunity id to retrieve
     * @return the opportunity sobject
     */
    public static Opportunity getOpportunitySO(ID opptyId) {
        try {
            // get the opportunity
            List<Opportunity> opportunities = [select Id,Name,
                                                    Type,
                                                    StageName,
                                                    Probability,
                                                    Pricebook2Id,
                                                    OwnerId,
                                                    NextStep,
                                                    LeadSource,
                                                    Primary_Partner_Program__c,
                                                    IsWon,
                                                    IsClosed,
                                                    HasOpportunityLineItem,
                                                    Description,
                                                   // Opportunity_ID__c,
                                                    CloseDate,
                                                    CampaignId,
                                                   // Contract_Term_months__c,
                                                    Apttus_Proposal__Discount_Percent__c,
                                                    Amount,
                                                    AccountId
                                               from Opportunity
                                               where Id = :opptyId limit 1];

            return (!opportunities.isEmpty() ? opportunities[0] : null);
        }
        catch(Exception ex) {
            return null;
        }
    }



}