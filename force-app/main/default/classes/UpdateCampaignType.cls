/*
 * This class is just to update Campaign Type which is concatation of Custom Campaing Type and Activity Details. 
 * This is helpful for Bizible Integration
 */
public class UpdateCampaignType {

    @InvocableMethod
    public static void updateCampaigns(List<Id> campaigns)
    {
        List<Campaign> campaignList = [Select Id,Type,Activity_Details__c,Campaign_Type__c from Campaign where Id in :campaigns];
        for(Campaign cm : campaignList)
        {
            cm.Type = cm.Campaign_Type__c+'-'+cm.Activity_Details__c;
        }
        
        update campaignList;
    }
}