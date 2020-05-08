@istest
public class Renewal_Notification_Batch_Sch_Test{
    static testmethod void test1(){
        Renewal_Notification_Batch_Sch m = new Renewal_Notification_Batch_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test ren notification', sch, m);
    }
}