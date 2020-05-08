@istest
public class Rollup_Key_Fields_To_Account_Sch_Test{
    static testmethod void test1(){
        Rollup_Key_Fields_To_Account_Sch m = new Rollup_Key_Fields_To_Account_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test rollup up account fields', sch, m);
    }
}