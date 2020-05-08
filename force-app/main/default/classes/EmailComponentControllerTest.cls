@istest
public class EmailComponentControllerTest {
    static testMethod void ContactthatMattersTest1() { 
    	EmailComponentController et = new EmailComponentController();
        et.lingeringC = false;
        et.getcases();
        et.lingeringC = true;
        et.getcases();
    }
}