@isTest
public class Lookup_Test{
    static testmethod void test1(){
        Lookup.searchDB('User','Name','Id',1, 'Profile.Name','System Admin','','Email');
    }
}