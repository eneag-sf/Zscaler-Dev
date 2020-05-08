@istest
public class ContractDetail_AssetLISync_Sch_Test{
    static testmethod void test1(){
        ContractDetail_AssetLISync_Sch m = new ContractDetail_AssetLISync_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test contract asset batch', sch, m);
    }
}