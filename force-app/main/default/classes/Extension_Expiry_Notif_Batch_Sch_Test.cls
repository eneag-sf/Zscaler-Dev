@istest
public class Extension_Expiry_Notif_Batch_Sch_Test{
    static testmethod void test1(){
        Extension_Expiry_Notification_Batch_Sch m = new Extension_Expiry_Notification_Batch_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test ren notification exp rem', sch, m);
    }
}