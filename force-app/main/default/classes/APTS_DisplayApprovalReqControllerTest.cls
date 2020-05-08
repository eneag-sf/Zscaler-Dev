@isTest
public class APTS_DisplayApprovalReqControllerTest {
    public static Account acc;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    public static  Apttus_Proposal__Proposal__c primaryprop;
    public static string newProposalId;
    public static string cartId;
    public static list<Apttus_Config2__AssetLineItem__c> assetList;
    public static string prdId;
    
   @isTest static void init () {
         Test.startTest();
        
        APTS_DisplayApprovalReqController cntrl = new APTS_DisplayApprovalReqController ();
        Apttus_Approval__Approval_Request__c approvalReq = new Apttus_Approval__Approval_Request__c();
        insert approvalReq;
        cntrl.approvalReqId = approvalReq.id;
        cntrl.deleteReq();
        cntrl.editReq();
        APTS_DisplayApprovalReqController.getQueryStringWithAllFields('Account',NULL,NULL);
        Test.stopTest();
   }
}