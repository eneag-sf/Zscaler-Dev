/* APTS_CONSTANTS
 * Class to hold hardcoded values like picklists and record types.
 *
 * Developer: Harish Emmadi, APTTUS - 10/31/2016
 * Business Owner:
 *
 * Scenario:
 *
 *
 *
 * History:
 * Harish Emmadi, APTTUS - 11/18/2016 - Added ACC_NAME_ZSCALER, LI_FREQUENCY_ONETIME.
 * Harish Emmadi, APTTUS - 12/14/2016 - Added DAS SKU codes. - [ZSCAL-203]
 * Harish Emmadi, APTTUS - 12/27/2016 - Added More sku codes and line item related.
 * Harish Emmadi, APTTUS - 12/29/2016 - Added LI_APPROVALSTATUS_APPROVED.
 * Harish Emmadi, APTTUS - 01/03/2017 - Added LI_PRICINGSTATUS_PENDING.
 * Vijay Prakash P J, Zscaler - 01/31/2017 - Added PROD_SKU_Z_CREDIT.
 */
public with sharing class APTS_CONSTANTS {

    // product related
    public static final String PROD_SKU_ZIA_FED             =   'ZIA-ZFED-MODERATE';
    public static final String PROD_SKU_ZPA_FED             =   'ZPA-ZFED-MODERATE';
    public static final String PROD_SKU_FED_DAS1            =   'ZCES-DAS-FED1';
    public static final String PROD_SKU_FED_DAS2            =   'ZCES-DAS-FED2';
    public static final String PROD_SKU_FED_DAS3            =   'ZCES-DAS-FED3';
    public static final String PROD_SKU_DAS_ESSENTIAL       =   'ZCES-DEP-ESS';
    public static final String PROD_SKU_DAS_ADVANCED        =   'ZCES-DEP-ADV';
    public static final String PROD_SKU_DAS_ENTERPRISE      =   'ZCES-DEP-ENT';
    public static final String PROD_SKU_DAS_ENTERPRISE_PLUS =   'ZCES-DEP-ENTPLUS';
    public static final String PROD_SKU_HEALTH_CHECK        =   'ZCES-PRO-HEALTH';

    public static final String PROD_SKU_SIP                 =   'ZSC-SIP';
    public static final String PROD_SKU_SIP_LOC             =   'ZSC-SIP-LOC';
    public static final String PROD_SKU_ZBUSINESSSUITE      =   'ZSUITE-WEBBUS';
    public static final String PROD_SKU_ZPROSUITE           =   'ZSUITE-WEBPRO';
    public static final String PROD_SKU_ZENTSUITE           =   'ZSUITE-WEBENT';
    public static final String PROD_SKU_NSS                 =   'Z-LOGFEED';
    public static final String PROD_SKU_PSUPPORT            =   'ZCES-SUP-PREM';
    public static final String PROD_SKU_MPSUPPORT           =   'ZCES-SUP-PREM-SP';
    public static final String PROD_SKU_DLP                 =   'ZDLP-WEB';
    public static final String PROD_SKU_ULIFTY4             =   'ZCR-UPY4';
    public static final String PROD_SKU_ULIFTY5             =   'ZCR-UPY5';
    public static final String PROD_SKU_TAMTOP              =   'ZCES-SUP-TAMT';
    public static final String PROD_SKU_ONE8TAMTOP          =   'ZCES-ONE8TH-TAM';
    public static final String PROD_SKU_BUYBACK             =   'ZCR-BuyBack';
    public static final String PROD_SKU_ZPA_BUYBACK         =   'Z-ZPA-BuyBack';
    public static final String PROD_SKU_DAS0                =   'ZCES-DAS-PKG0';
    public static final String PROD_SKU_DAS1                =   'ZCES-DAS-PKG1';
    public static final String PROD_SKU_DAS2                =   'ZCES-DAS-PKG2';
    public static final String PROD_SKU_DAS3                =   'ZCES-DAS-PKG3';
    public static final String PROD_SKU_DAS4                =   'ZCES-DAS-PKG4';
    public static final String PROD_SKU_DAS6                =   'ZCES-DAS-PKG6';
    public static final String PROD_SKU_CS8D                =   'ZCES-PRO-SVC';
    public static final String PROD_SKU_OTAM                =   'ZCES-SUP-OTAM';
    public static final String PROD_SKU_LEXTSUBS            =   'ZSC-LOG-EXTSUBS';
    public static final String PROD_SKU_NFRWEB              =   'ZSC-NFR-WEB';
    public static final String PROD_SKU_NFRZPA              =   'ZPA-NFR';
    public static final String PROD_SKU_EDUCREDIT           =   'ZCES-EDU-CREDIT';
    public static final String PROD_SKU_EDULABCREDIT        =   'ZCES-EDU-LABCREDIT';
    public static final String PROD_SKU_Z_CREDIT            =   'Z-CREDIT';
    public static final String PROD_SKU_CLOUD_FIREWALL      =   'ZFW-NG-WITH-LOG';
    public static final String PROD_SKU_CLOUD_SANDBOX       =   'ZSEC-WEB-ABA';
    public static final String PROD_SKU_CLOUD_PROMO         =   'Z-CFWCSB-PROMO';
    public static final String PROD_SKU_CFWZPA_PROMO        =   'Z-CFWZPA-Credit';
    public static final String PROD_SKU_ZPA_PRO             =   'ZPA-PRO';
    public static final String PROD_SKU_ZPA_ENT             =   'ZPA-ENT';
    public static final String PROD_SKU_ZPA_BUS             =   'ZPA-BUS';
    public static final String PROD_SKU_ZPA_PRO_LU          =   'ZPA-PRO-LU';
    public static final String PROD_SKU_ZPA_BUS_LU          =   'ZPA-BUS-LU';
    public static final String PROD_SKU_ZPA_AAC             =   'ZPA-AAC-M1';
    public static final String PROD_SKU_ZPA_CUSTCERT        =   'ZPA-CUSTPKI';
    public static final String PROD_SKU_ZIA_BWBUNDLE        =   'ZIA-BWBUNDLE-BUS';
    public static final String PROD_SKU_ZSC_PZENHW2         =   'ZSC-PRIV-ZENHW2-5YL';
    public static final String PROD_SKU_ZSC_PZENSW          =   'ZSC-PRIV-ZENSW-5YL';
    public static final String PROD_SKU_ZSC_PRIVLB          =   'ZSC-PRIV-LB-5YL';
    public static final String PROD_SKU_ZSC_PRIVNANOHA      =   'ZSC-PRIV-NANO-HA-5YL';
    public static final String PROD_SKU_ZSC_PRIVPORTAL      =   'ZSC-PRIVPORTAL-5YL';
    public static final String PROD_SKU_ZSC_SWITCH          =   'ZSC-SWITCH-5YL';
    public static final String PROD_SKU_ZIA_PROBUNDLE       =   'ZIA-PRO-BUNDLE';
    public static final String PROD_SKU_ZIA_BUSBUNDLE       =   'ZIA-BUS-BUNDLE';
    public static final String PROD_SKU_ZIA_TRANSBUNDLE     =   'ZIA-TRANS-BUNDLE';
    public static final String PROD_SKU_ZIA_ELABUNDLE       =   'ZIA-ELA-BUNDLE';
    public static final String PROD_SKU_ZIA_PROBUNDLE_LU    =   'ZIA-PRO-BUNDLE-LU';
    public static final String PROD_SKU_ZIA_BUSBUNDLE_LU    =   'ZIA-BUS-BUNDLE-LU';
    public static final String PROD_SKU_ZIA_TRANSBUNDLE_LU  =   'ZIA-TRANS-BUNDLE-LU';
    public static final String PROD_SKU_ZIA_ELABUNDLE_LU    =   'ZIA-ELA-BUNDLE-LU';
    public static final String PROD_SKU_STDFWLOGING         =   'ZFW-STD-LOG';
    public static final String PROD_SKU_BWCTRL              =   'ZMAN-WEB-BAND';
    public static final String PROD_SKU_ENCVPN              =   'ZSC-ENC-VPN';
    public static final String PROD_SKU_SSLINT              =   'ZSSL-WEB';
    public static final String PROD_SKU_ZWEB2_0             =   'ZMAN-WEB-2_0';
    public static final String PROD_SKU_ZWAC                =   'ZSEC-WEB-WAC';
    public static final String PROD_SKU_THREATLABZ          =   'Z-TLZ-TI-PRE';
    public static final String PROD_SKU_ZPA_PROMO           =   'ZPA-PRO-PROMO';
    public static final String PROD_SKU_ZLIVE_GEN_US        =   'ZLIVE-GEN-US';
    public static final String PROD_SKU_ZLIVE_TRAIN_US      =   'ZLIVE-TRAIN-US';
    public static final String PROD_SKU_ZLIVE_GEN_EU        =   'ZLIVE-GEN-EU';
    public static final String PROD_SKU_ZLIVE_TRAIN_EU      =   'ZLIVE-TRAIN-EU';
    public static final String PROD_SKU_ZLIVE_VIPC          =   'ZLIVE-VIPC';
    public static final String PROD_SKU_ZLIVE_SPG           =   'ZLIVE-SPG';
    public static final String PROD_SKU_ZLIVE_TEAM          =   'ZLIVE-TEAM';
    public static final String PROD_SKU_ZLIVE_WOMENINTECH   =   'ZLIVE-WOMENINTECH';
    public static final String PROD_SKU_ZLIVE_EARLYBIRD     =   'ZLIVE-EARLYBIRD';
    public static final String PROD_SKU_ZPA_100SEATS_PROMO  =   'ZPA-100Seats-Promo';
    public static final String PROD_SKU_WFH_PROMO           =   'WFH_PROMO'; //added by minkesh patel

    public static final String PROD_FAMILY_ZIA              =   'ZIA';
    public static final String PROD_FAMILY_ZPA              =   'ZPA';

    public static final String PROD_CHARGETYPE_SFEE         =   'Subscription Fee';
    public static final String PROD_PRICETYPE_RECURRING     =   'Recurring';
    public static final String PROD_PRICETYPE_ONETIME       =   'One Time';
    
    
    //CR# 238 - Minkesh  - Start
    public static final String PROD_SKU_ZB2B_PRO_PRE          =   'ZB2B-PRO-PRE';
    public static final String PROD_SKU_ZB2B_BUS_PRE          =   'ZB2B-BUS-PRE';
    //CR# 238 - Minkesh  - End
    
    
    //Added New Pre Sku : Gurjinder : Start
    public static final String DATA_PROTECTION_BUNDLE       =   'ZDATA-PROT-BUNDLE-PRE';
    public static final String SAAS_CASB_API                =   'ZCASB-SAAS-API-PRE';
    //Added New Pre Sku : Gurjinder : End
    
    //CR# 223 - Abhishek V - Early_Adopter - Start
    public static final String ISO_5_PRE                    =   'ZIA-ISO-5-PRE';
    public static final String ISO_25_PRE                   =   'ZIA-ISO-25-PRE';
    public static final String ISO_100_PRE                  =   'ZIA-ISO-100-PRE';
    public static final String ISO_EXTRA_PRE                =   'ISO-EXTRAGB-PRE';
    public static final String SVC_EDGE_V_PRE               =   'ZPA-SVC-EDGE-V-PRE';
    public static final String PRO_ON_PREM_PRE              =   'ZPA-PRO-ON-PREM-PRE';//CR#35
    public static final String SVC_RI_2_PRE              =   'ZIA-SVC-RI-2-PRE';//CR#35
    public static final String BUS_ON_PREM_PRE              =   'ZPA-BUS-ON-PREM-PRE';//CR#35

    public static final String EARLY_ADOPTER                =   'EARLY_PROMO';
    //CR# 223 - Abhishek V - Early_Adopter - End
    

    
    //Changes by Gurjinder for New Opt SKU:Start
    public static final String Optimize_Advanced            =   'ZCES-PRO-OPTADV';
    public static final String Optimize_Essential           =   'ZCES-PRO-OPTESS';
    public static final String Optimize_Enterprise          =   'ZCES-PRO-OPTENT';
    //Changes by Gurjinder for New Opt SKU:End
    
    // asset line item related
    public static final String ALI_STATUS_ACTIVATED         =   'Activated';


    // Line Item(Apttus_Config2__LineItem__c) related.
    public static final String LI_STATUS_NEW                =   'New';
    public static final String LI_STATUS_AMENDED            =   'Amended';
    public static final String LI_STATUS_UPGRADED           =   'Upgraded';
    public static final String LI_STATUS_RENEWED            =   'Renewed';
    public static final String LI_STATUS_CANCELLED          =   'Cancelled';

    public static final String LI_APPROVALSTATUS_REQUIRED   =   'Approval Required';
    public static final String LI_APPROVALSTATUS_APPROVED   =   'Approved';
    public static final String LI_APPROVALSTATUS_NONE       =   'None';

    public static final String LI_FREQUENCY_ONETIME         =   'One Time';

    public static final String LI_PRICINGSTATUS_PENDING     =   'Pending';
    public static final String LI_MARKUP_PERCENT    =   '% Markup';
    public static final String LI_MARKUP_AMOUNT    =   'Markup Amount';

    // Prposal/Quote related
    public static final String P_RT_UPSELL                  =   'Upsell';
    public static final String P_RT_RENEWAL                 =   'Renewal';
    public static final String P_RT_NBUSINESS               =   'New Business';
    public static final String P_APPROVALSTATUS_REQUIRED    =   'Approval Required';
    public static final String P_APPROVALSTATUS_NONE        =   'None';


    // Product Attribute Value related
    public static final String PAV_PST_ZSCALER              =   'Zscaler';
    public static final String PAV_PST_PQSUPPORT            =   'Partner Qualified Support';
    public static final Decimal PAV_PERCENT_GSA              =   15;

    // Account related
    public static final String ACC_SUPPORTSOURCE_LIST       =   'List';
    public static final String ACC_SUPPORTSOURCE_NET        =   'Net';
    public static final String ACC_NAME_ZSCALER             =   'Zscaler';
    public static final String P_PARTNERPRG_LEGACY          =   'Legacy'; //Added for partnerSummit & used in APTS_PricingHelper
    public static final String P_PARTNERPRG_PARTSUMMIT      =   'Partner Summit'; //Added for partnerSummit
    public static final String LI_ADJUSTMENT_PRICEOVERRIDE  =   'Price Override'; //Added for partnerSummit
    public static final String LI_ADJUSTMENT_DISCOUNT       =   '% Discount'; //Added for partnerSummit
    public static final String PROD_SUPPORT_FAMILY          =   'Support'; 
    public static final String PROD_DEPLOYMENT_FAMILY       =   'Deployment';

}