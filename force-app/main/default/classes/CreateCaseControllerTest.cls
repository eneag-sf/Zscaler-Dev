@isTest
public class CreateCaseControllerTest {
    public static testMethod void CreateCaseTest(){
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        
        test.startTest();
        CreateCaseController.saveCaseRecord(c, new List<String>());
        CreateCaseController.getPortalContent('partners');
        CreateCaseController.getPortalContent('customers');
        CreateCaseController.fetchPreferredFields();
        CreateCaseController.saveFile(c.Id, 'strFileName', 'base64Data');
        test.stopTest();
    }
}