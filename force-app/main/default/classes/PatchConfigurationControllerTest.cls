@isTest
public class PatchConfigurationControllerTest
{
    @isTest static void test()
    {
        PatchConfigurationController controller = new PatchConfigurationController();
        Boolean hasLeadEnabled = controller.hasLeadShareEnabled;
        Boolean hasAccEnabled = controller.hasAccountTeamEnabled;
        Boolean hasOppEnabled = controller.hasOpportunityTeamEnabled;
        controller.save();
    }
}