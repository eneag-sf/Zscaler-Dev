@RestResource(urlMapping='/GetFederalCampaigns/*')
global with sharing class GetFederalCampaigns{
    global static Boolean avoidtriggers = false;

    /* Do Get
    *
    * Gets Campaigns, CampaignMembers, and CampaignMemberStatuses that
    * are eligible to be pushed to FedRAMP
    *
    * @returns Map<String, String> - Campaign/members/status data to return to FedRAMP
    */
    @HttpGet
    global static Map<String, String> doGet() {
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();

        //validate request params for type, dates etc...
        if(req.params!= null && req.params.containskey('type') && EncodingUtil.urlDecode(req.params.get('type'),'UTF-8') == 'get_camps'){
            if(req.params.containskey('Start_Date') && EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8') != '' && req.params.containskey('End_Date') && EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8') != '' && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))){
                System.debug('running test...');
                
                //query campaigns who are marked with Push_to_FedRAMP->TRUE and fall within the desired date range, also create a list of their IDs
                List<Campaign> campaignsToReturn = [SELECT Id, OwnerId, Department__c, Name, ParentId, StartDate, EndDate, Campaign_Theme__c, Product_Type__c, Campaign_Type__c, Activity_Details__c, IsActive, Status, Geo__c, Area__c, Fiscal_Year__c, Quarter__c FROM Campaign WHERE Push_to_FedRAMP__c = true AND LastModifiedDate >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and LastModifiedDate <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))];
                List<Id> campaignsToReturnIds = new List<Id>();
                for(Campaign campaignToReturn: campaignsToReturn){
                    campaignsToReturnIds.add(campaignToReturn.Id);
                }

                //if we got campaigns to return
                if(!campaignsToReturn.isEmpty()){
                    //get campaign members related to campaigns
                    List<CampaignMember> relatedCampaignMembers = [SELECT Id, CampaignId, LeadId, Status FROM CampaignMember WHERE CampaignId IN :campaignsToReturnIds AND CampaignId != '' AND LeadId != ''];
                    
                    //get member lead ids
                    Set<Id> memberLeadIds = new Set<Id>();
                    for(CampaignMember member : relatedCampaignMembers){
                        memberLeadIds.add(member.LeadId);
                    }

                    //get Federal leads related to campaign members
                    Set<Id> federalLeadIds = new Set<Id>();
                    for(Lead fedLead : [SELECT Id FROM Lead WHERE Area__c = 'US Federal' AND Id IN :memberLeadIds]){
                        federalLeadIds.add(fedLead.Id);
                    }
                    System.debug('federalLeadIds->' + federalLeadIds);

                    //only return campaign members that are Federal leads
                    List<CampaignMember> campaignMembersToReturn = new List<CampaignMember>();
                    for(CampaignMember memberToReturn : relatedCampaignMembers){
                        if(federalLeadIds.contains(memberToReturn.LeadId)){
                            campaignMembersToReturn.add(memberToReturn);
                        }
                    }
                    System.debug('campaignMembersToReturn->' + campaignMembersToReturn);

                    //get campaign members statuses
                    List<CampaignMemberStatus> campaignMemberStatusesToReturn = [SELECT Id, CampaignId, Label, HasResponded, IsDefault FROM CampaignMemberStatus WHERE CampaignId IN :campaignsToReturnIds];

                    //add all data to 'result' map to be returned
                    result.put('campaigns', JSON.serialize(campaignsToReturn));
                    result.put('campaignMembers', JSON.serialize(campaignMembersToReturn));
                    result.put('campaignMemberStatuses', JSON.serialize(campaignMemberStatusesToReturn));
                }
            }
        }

        return result;
    }
}