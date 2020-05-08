@isTest
public class PatchRuleHelperTest
{
    @isTest static void test()
    {
        System.assertEquals(true, PatchRuleHelper.IsAdmin);
        Long l = PatchRuleHelper.LastDeploymentDate;
        String u = PatchRuleHelper.getSalesforceBaseUrl();
    }
    
    @isTest static void testSplitCsv()
    {
        String[] s1 = PatchRuleHelper.splitCsv('us, usa, america, united states of america');
        System.assertEquals(4, s1.size());
        System.assertEquals('us', s1[0]);
        System.assertEquals('usa', s1[1]);
        System.assertEquals('america', s1[2]);
        System.assertEquals('united states of america', s1[3]);
        
        String[] s2 = PatchRuleHelper.splitCsv('taiwan, tw, "taiwan, province of china,"');
        System.assertEquals(3, s2.size());
        System.assertEquals('taiwan', s2[0]);
        System.assertEquals('tw', s2[1]);
        System.assertEquals('taiwan, province of china,', s2[2]);
    }
}