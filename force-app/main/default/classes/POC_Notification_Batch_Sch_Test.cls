@istest
public class POC_Notification_Batch_Sch_Test{
    static testmethod void test1(){
        POC_Notification_Batch_Sch m = new POC_Notification_Batch_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test poc notification', sch, m);
    }
}