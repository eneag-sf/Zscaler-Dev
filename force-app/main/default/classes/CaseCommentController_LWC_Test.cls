@isTest
public class CaseCommentController_LWC_Test {
    @IsTest
    static void test1(){
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)');
        TriggerUtility.isSkipCaseTriggerExecuted();
        insert cs;
        Id caseId = cs.Id;
        FeedItem cc = new FeedItem(parentId = caseId);
        cc.Body = 'abcd';
        cc.Visibility = 'AllUsers';
        cc.IsRichText = false;
        insert cc;
        Casecomment cc1 = new Casecomment(parentId = caseId);
        cc1.CommentBody = 'abcd';
        cc1.isPublished = true;
        insert cc1;
        EmailMessage em = new EmailMessage(parentId = caseId);
        em.HTMLBody = 'abcd';
        insert em;
        Test.startTest();
        System.runAs(new User(id=Userinfo.getUserId())){
            CaseCommentController_LWC.saveCaseComment(cs.Id, 'abcd', true, new List<String>());
            CaseCommentController_LWC.getCaseComments(cs.Id, 10, 'ASC', 'customers');
        }
        Test.stopTest();
    }
    @IsTest
    static void test2(){
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)');
        TriggerUtility.isSkipCaseTriggerExecuted();
        insert cs;
        Id caseId = cs.Id;
        FeedItem cc = new FeedItem(parentId = caseId);
        cc.Body = 'abcd';
        cc.Visibility = 'AllUsers';
        cc.IsRichText = false;
        insert cc;
        Casecomment cc1 = new Casecomment(parentId = caseId);
        cc1.CommentBody = 'abcd';
        cc1.isPublished = true;
        insert cc1;
        EmailMessage em = new EmailMessage(parentId = caseId);
        em.HTMLBody = 'abcd';
        insert em;
        User ur = [Select Id from User where ContactId != null and isActive = true limit 1];
        Test.startTest();
        System.runAs(ur){
            CaseCommentController_LWC.getCaseComments(cs.Id, 10, 'ASC', 'customers');
        }
        Test.stopTest();
    }
    @IsTest
    static void test3(){
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)');
        TriggerUtility.isSkipCaseTriggerExecuted();
        insert cs;
        Id caseId = cs.Id;
        FeedItem cc = new FeedItem(parentId = caseId);
        cc.Body = 'abcd';
        cc.Visibility = 'AllUsers';
        cc.IsRichText = false;
        insert cc;
        Casecomment cc1 = new Casecomment(parentId = caseId);
        cc1.CommentBody = 'abcd';
        cc1.isPublished = true;
        insert cc1;
        EmailMessage em = new EmailMessage(parentId = caseId);
        em.HTMLBody = 'abcd';
	em.toaddress = 'abhishek1avk@gmail.com;gmann@zscaler.com';
	em.ccaddress = 'abhishek1avk@gmail.com;gmann@zscaler.com';
        insert em;
        Test.startTest();
        System.runAs(new User(id=Userinfo.getUserId())){
            CaseCommentController_LWC.saveCaseComment(cs.Id, 'abcd', true, new List<String>());
            CaseCommentController_LWC.getCaseComments(cs.Id, 10, 'DESC', 'customers');
        }
        Test.stopTest();
    }
    @IsTest
    static void test4(){
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)');
        TriggerUtility.isSkipCaseTriggerExecuted();
        insert cs;
        Id caseId = cs.Id;
        FeedItem cc = new FeedItem(parentId = caseId);
        cc.Body = 'abcd';
        cc.Visibility = 'AllUsers';
        cc.IsRichText = false;
        insert cc;
        Casecomment cc1 = new Casecomment(parentId = caseId);
        cc1.CommentBody = 'abcd';
        cc1.isPublished = true;
        insert cc1;
        EmailMessage em = new EmailMessage(parentId = caseId);
        em.HTMLBody = 'abcd';
	em.toaddress = 'abhishek1avk@gmail.com;gmann@zscaler.com';
	em.ccaddress = 'abhishek1avk@gmail.com;gmann@zscaler.com';
        insert em;
        User ur = [Select Id from User where ContactId != null and isActive = true limit 1];
        Test.startTest();
        System.runAs(ur){
            CaseCommentController_LWC.getCaseComments(cs.Id, 10, 'DESC', 'customers');
        }
        Test.stopTest();
    }
}