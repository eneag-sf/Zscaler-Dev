@istest
public class Exec_Briefing_Notification_Sch_Test{
    static testmethod void test1(){
        Exec_Briefing_Notification_Sch m = new Exec_Briefing_Notification_Sch ();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test eb notification', sch, m);
    }
}