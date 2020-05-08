@isTest
public class EventTriggerHelperTest {

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
    
    @isTest static void createEvent()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        //evnt.This_is_a_SCI__c = 'Create SCI';
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
        
    }
    
    @isTest static void updateNoDataEvent()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        //evnt.This_is_a_SCI__c = 'Create SCI';
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
      
    }
    @isTest static void updateEvent()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        //evnt.This_is_a_SCI__c = 'Create SCI';
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
        //evnt.This_is_a_SCI__c = 'Create SCI';
        
        update evnt;
      
    }
    
    @isTest static void updateEventAgain()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Contact ct4 = new Contact(LastName='Test3', email='Testemail3@tests.com');
        insert ct4;
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        //evnt.This_is_a_SCI__c = 'No SCI Required';
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
        
        EventRelation evntRelation4 = new EventRelation();
        
        evntRelation4.EventId = evnt.Id;
        evntRelation4.RelationId = ct4.Id;
        evntRelation4.IsInvitee = true;
        evntRelation4.isParent = false;
        evntRelation4.IsWhat = false;
        evntRelation4.Status = 'New';
        insert evntRelation4;
        
        TriggerUtility.isGroove2SCIcodeexecuted =false;
        //evnt.Primary_Topic_Covered__c = 'Technical Discussion';
        evnt.Description ='Fixing the description';
        update evnt;
        
        delete evntRelation4;
        update evnt;
      
    }
    
    @isTest static void updateEventAgainNow()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Contact ct4 = new Contact(LastName='Test3', email='Testemail3@tests.com');
        insert ct4;
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        //evnt.This_is_a_SCI__c = 'Create SCI';
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
        
        EventRelation evntRelation4 = new EventRelation();
        
        evntRelation4.EventId = evnt.Id;
        evntRelation4.RelationId = ct4.Id;
        evntRelation4.IsInvitee = true;
        evntRelation4.isParent = false;
        evntRelation4.IsWhat = false;
        evntRelation4.Status = 'New';
        insert evntRelation4;
        
        TriggerUtility.isGroove2SCIcodeexecuted =false;
        
        //evnt.Primary_Topic_Covered__c = 'Technical Discussion';
        evnt.Description ='Fixing the description';
        update evnt;
        
        //evnt.This_is_a_SCI__c = 'No SCI Required';
        update evnt;
      
    }
    @isTest static void deleteEvent()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        //evnt.This_is_a_SCI__c = 'No SCI Required';
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
        
        delete evnt;
      
    }
}