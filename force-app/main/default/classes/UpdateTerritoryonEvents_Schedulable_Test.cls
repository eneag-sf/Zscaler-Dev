@istest
public class UpdateTerritoryonEvents_Schedulable_Test{
    /* static testmethod void test1(){
        UpdateTerritoryonEvents_Schedulable m = new UpdateTerritoryonEvents_Schedulable(date.today(),date.today());
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test update ter  tasks 2', sch, m);
    } */
    
    static testmethod void test2(){
        Date sd;
        date ed;
        UpdateTerritoryonEvents_Schedulable m = new UpdateTerritoryonEvents_Schedulable(sd, ed);
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test update ter  tasks 1', sch, m);
    }
}