@isTest
public class Event2SCIAutocreationBatch_Test{
    static testmethod void test1(){
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
        insert con;
        
        List<Event> events = new List<Event>();
        events.add(new Event(
        ActivityDate = Date.today().addDays(7),
        ActivityDateTime = Date.today().addDays(7),
        Subject='meeting',
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(), 
        DurationInMinutes = 90/**,DaScoopComposer__Is_Created_By_Groove__c=true,This_is_a_SCI__c='Create SCI'**/)
        );
		events.add(new Event(
        ActivityDate = Date.today().addDays(7),
        ActivityDateTime = Date.today().addDays(7),
        Subject='meeting',
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(), 
        DurationInMinutes = 90/**,DaScoopComposer__Is_Created_By_Groove__c=true,This_is_a_SCI__c='No SCI Required'**/)
        );
		events.add(new Event(
        ActivityDate = Date.today().addDays(7),
        ActivityDateTime = Date.today().addDays(7),
        Subject='meeting',
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(), 
        DurationInMinutes = 90/**,DaScoopComposer__Is_Created_By_Groove__c=true,This_is_a_SCI__c='SCI needs to be updated'**/)
        );
      /*   events.add(new Event(
        ActivityDate = Date.today().addDays(7),
        ActivityDateTime = Date.today().addDays(7),
        Subject='call',
        WhoId = lead.Id,
        OwnerId = UserInfo.getUserId(),
        DurationInMinutes = 90)); */
        insert events;
        
        
        Event2SCIAutocreationBatch batch;
        batch = new Event2SCIAutocreationBatch();
        Database.executeBatch(batch,200);
    }

}