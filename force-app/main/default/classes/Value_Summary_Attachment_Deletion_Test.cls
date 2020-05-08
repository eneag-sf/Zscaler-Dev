@istest
public class Value_Summary_Attachment_Deletion_Test{
    static testmethod void test1(){
        Value_Summary_Attachment_Deletion_Sch m = new Value_Summary_Attachment_Deletion_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test delete vsa', sch, m);
    }
}