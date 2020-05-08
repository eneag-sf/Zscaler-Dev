@istest
public class UpdateRollupDetailsonCampaigns_Sch_Test{
    static testmethod void test1(){
        UpdateRollupDetailsonCampaigns_Sch m = new UpdateRollupDetailsonCampaigns_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test rollup up Campaign fields', sch, m);
    }
}