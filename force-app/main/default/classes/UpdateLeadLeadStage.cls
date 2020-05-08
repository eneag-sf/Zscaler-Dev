public class UpdateLeadLeadStage {

    @InvocableMethod
    public static void updateLeadLeadStage(List<Id> leadIds) {
        Map<String, OnOffSwitch__c> switchmap = OnOffSwitch__c.getAll();
        if(switchmap != null && switchmap.containskey('UpdateLeadLeadStage') && OnOffSwitch__c.getInstance('UpdateLeadLeadStage').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('UpdateLeadLeadStage').Deactivate_Component__c==False){
            system.debug('run the code ');
            List<Lead> leadsToUpdate = new List<Lead>();

            for (Lead lead : [SELECT Id, MKTO71_Lead_Score__c, First_Lead_Date__c, Geo__c, LeadSource, Territory_Type__c,
                                (SELECT Id, Campaign.Type, CampaignId FROM CampaignMembers WHERE Campaign.Type LIKE '%Opedational%'),
                                (SELECT Id FROM Tasks) FROM Lead
                              WHERE ID IN :leadIds AND First_Lead_Date__c = null AND Geo__c <> 'Channel' AND LeadSource <> 'Sales Generated'
                                AND Lead_Stage__c NOT IN ('SAL', 'SQL', 'MQL')]) {
                if ((lead.MKTO71_Lead_Score__c >= 5
                    || (lead.CampaignMembers.isEmpty()
                        && !lead.Tasks.isEmpty()))
                    && lead.First_Lead_Date__c == null
                    && (lead.LeadSource != null && !lead.LeadSource.equalsIgnoreCase('sales generated'))
                    && (lead.Territory_Type__c != null && !lead.Territory_Type__c.equalsIgnoreCase('channel') && !lead.Territory_Type__c.equalsIgnoreCase('catch all') && !lead.Territory_Type__c.equalsIgnoreCase('row'))
                    && (lead.Geo__c != null && !lead.Territory_Type__c.equalsIgnoreCase('channel'))) {
                    leadsToUpdate.add(new Lead(Id = lead.Id, Lead_Stage__c = 'Lead'));
                }
            }

            try {
                if (!leadsToUpdate.isEmpty()) {
                    Database.update(leadsToUpdate, false);
                }
            } catch (Exception ex) {
                System.debug('>>>> Error occurred while updating the Lead Stage in Lead: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            }
    
        }else{
            system.debug('do not run the code as UpdateLeadLeadStage is deactivated');
        }  
        
    }
    
}