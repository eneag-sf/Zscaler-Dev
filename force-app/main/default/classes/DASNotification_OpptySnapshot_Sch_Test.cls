@istest
public class DASNotification_OpptySnapshot_Sch_Test{
    static testmethod void test1(){
        DASNotification_OpptySnapshot_Sch m = new DASNotification_OpptySnapshot_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test das notification', sch, m);
    }
}