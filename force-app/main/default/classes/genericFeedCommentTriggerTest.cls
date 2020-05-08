@isTest
public class genericFeedCommentTriggerTest {
    public static testMethod void genericFeedComment(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
		Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
        Contact ct = new Contact();
        ct.LastName ='test';
        ct.Email ='test@test.com';
        insert ct;
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case cs = new Case();
        cs.Status = 'New';
        cs.AccountId = acct.Id;
        cs.Subject = 'tetes sub';
        cs.RecordTypeId = RecordTypeIdCase;
        insert cs;
        FeedItem fi = new FeedItem();
        fi.ParentId = cs.Id;
        fi.Body = 'teste';
        insert fi;
        TriggerUtility.skipFRTandCustomerNote = false;
        FeedComment fc = new FeedComment();
        fc.FeedItemId = fi.Id;
        fc.CommentBody='test body';
        insert fc;
		FeedCommentTriggerUtility.booster();
        System.debug('inserted by:-'+fc.InsertedById);
    }
}