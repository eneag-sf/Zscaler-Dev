public class LegacyCaseCommentsController {
	public List<Legacy_Case_Comment__c> lstT {get;set;}
    public Boolean showCommentType {get;set;}
    public LegacyCaseCommentsController(ApexPages.StandardController stdController)  {
        String visibility = 'AllUsers';
        showCommentType = false;
        String isCommunityUser = apexpages.currentpage().getparameters().get('isCommunityUser');
        if(isCommunityUser != null && isCommunityUser == 'true' )  {
            lstT = [select Cases__c,Comment_Body__c,CreatedBy.FirstName,CreatedBy.LastName ,Createddate,Visibility__c, Legacy_Author__c, Created_At__c FROM Legacy_Case_Comment__c where Cases__c = :apexpages.currentpage().getparameters().get('Id') and Visibility__c  = 'AllUsers' order by Created_At__c  desc];
        }else  {
            showCommentType = true;
          lstT = [select Cases__c,Comment_Body__c,CreatedById,CreatedBy.FirstName,CreatedBy.LastName,CreatedDate,Visibility__c, Legacy_Author__c, Created_At__c FROM Legacy_Case_Comment__c where Cases__c = :apexpages.currentpage().getparameters().get('Id')  order by Created_At__c desc];
        }
    }

}