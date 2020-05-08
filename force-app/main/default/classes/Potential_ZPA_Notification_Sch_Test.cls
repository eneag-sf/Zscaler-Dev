@istest
public class Potential_ZPA_Notification_Sch_Test{
    static testmethod void test1(){
        Potential_ZPA_Notification_Sch m = new Potential_ZPA_Notification_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test potential ZPA notification', sch, m);
    }
}