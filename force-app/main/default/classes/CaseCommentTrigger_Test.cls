@istest
public class CaseCommentTrigger_Test {
    @IsTest
    static void test1(){
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        Test.startTest();
        System.runAs(new User(id=Userinfo.getUserId())){
            Casecomment cc1 = new Casecomment(parentId = cs.Id);
            cc1.CommentBody = 'abcd';
            cc1.isPublished = true;
            insert cc1;
			CaseCommentTriggerUtility.booster();
        }
        Test.stopTest();
        
    }
    /*@IsTest
    static void test2(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        User ur = [Select Id from User where ContactId != null and isActive = true limit 1];
        System.runAs(ur){
            Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
            
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
            TriggerUtility.SkipCaseTriggerExecuted();
            insert cs;
            Test.startTest();
            Casecomment cc1 = new Casecomment(parentId = cs.Id);
            cc1.CommentBody = 'abcd';
            cc1.isPublished = true;
            insert cc1;
        }
        Test.stopTest();
        
    }*/
	
}