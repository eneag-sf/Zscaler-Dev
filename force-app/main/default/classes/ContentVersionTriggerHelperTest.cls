@isTest
public class ContentVersionTriggerHelperTest {

     @testSetup
    static void createDummyData()
    {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact ct = new Contact(LastName='Test', email='Testemail@tests.com');
        insert ct;
        
        Contact ct1 = new Contact(LastName='Test1', email='Testemail2@tests.com');
        insert ct1;
    }
    
    @isTest static void testContentVersion()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        //evnt.This_is_a_SCI__c ='Create SCI';
        //evnt.DaScoopComposer__Is_Created_By_Groove__c = true;
        evnt.Description = 'Test SCI from Groove';
        //evnt.Interaction_With__c = 'Prospect';
        //evnt.Primary_Topic_Covered__c = 'Demo';
        evnt.Meeting_Next_Steps__c ='Test Meeting Next Steps';
        evnt.StartDateTime = DateTime.now();
        evnt.DurationInMinutes = 90;
        insert evnt;
        
        Contact ct1 = [select Id,email,lastName from Contact where email ='Testemail2@tests.com' limit 1];
        
        EventRelation evntRelation = new EventRelation();
        
        evntRelation.EventId = evnt.Id;
        evntRelation.RelationId = ct1.Id;
        evntRelation.IsInvitee = true;
        evntRelation.isParent = false;
        evntRelation.IsWhat = false;
        evntRelation.Status = 'New';
        insert evntRelation;
        
        //Database.SaveResult[] results = Database.insert(new SObject[]{evnt,evntRelation});
        
        System.assert(evntRelation.Id != null);
        
        evntRelation.Status = 'Accepted';
        evntRelation.Response ='Will join the meeting';
        evntRelation.RespondedDate = DateTime.now();
        update evntRelation;
        
        TriggerUtility.isGroove2SCIcodeexecuted =false;
        update evnt;
        
        ContentVersion cv=new Contentversion();
		cv.title='ABC';
		cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
		cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = evnt.Id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        update cv;
    }
}