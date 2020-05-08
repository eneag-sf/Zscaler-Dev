@isTest
private class CaseAttachmentControllerTest {

	private static testMethod void test() {
        
        Account Acc = creatAccount ();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
         
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
         
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = Acc.id;
        contentlink.ContentDocumentId = cdList[0].Id;
        contentlink.Visibility = 'AllUsers';  
        contentlink.ShareType = 'V';  
        insert contentlink;
        
        CaseAttachmentController CastAttachment = new CaseAttachmentController();
        CaseAttachmentController.fetchCaseFiles(Acc.Id);
        
	}
	
	private static Account creatAccount () {
        Account acc = new Account ();
        acc.Name = 'Test Account';
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        insert acc;
        return acc;
    }

}