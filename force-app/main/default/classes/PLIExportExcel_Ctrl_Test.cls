@isTest
public class PLIExportExcel_Ctrl_Test{
    static testmethod void test1(){
        
        ApexPages.currentPage().getParameters().put('payload','abcd');
        PLIExportExcel_Ctrl ctrl = new PLIExportExcel_Ctrl();

    }

}