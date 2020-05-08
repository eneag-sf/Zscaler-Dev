public class MonthlyPolicyConfigsListController {
    public Id accountId { get; set; }
    public Integer limitValue { get; set; }
    public Integer recordCount { get; set; }
    public Id focusAccountId { get; set; }
    public Focus_Accounts__c focusAccount { get; set; }

    public MonthlyPolicyConfigsListController(ApexPages.StandardController ctrlr) {
        limitValue = 5;
        recordCount = 0;

        focusAccountId = ApexPages.currentPage().getParameters().get('id');

        if (focusAccountId != null) {
            focusAccount = [SELECT Id, Account_Name__c FROM Focus_Accounts__c WHERE Id = :focusAccountId];
            accountId = focusAccount.Account_Name__c;
        }
    }

    public List<MonthlyPolicyConfigWrapper> getConfigs() {
        List<MonthlyPolicyConfigWrapper> ticketsList = new List<MonthlyPolicyConfigWrapper>();
        if (accountId != null) {
            for (Monthly_Policy_Configurations__c config : [SELECT Id, Name, O365_One_Click__c, Number_of_GRE_Tunnels__c,
                                                                   Number_of_IP__c, Max__c, IPs_without_Location__c,
                                                                   Authentication_Frequency__c
                                                        FROM Monthly_Policy_Configurations__c
                                                       WHERE Account__c = :accountId
                                                       ORDER BY CreatedDate DESC
                                                       LIMIT :limitValue]) {
                ticketsList.add(new MonthlyPolicyConfigWrapper(
                    config.Id,
                    config.Name,
                    config.O365_One_Click__c,
                    Integer.valueOf(config.Number_of_GRE_Tunnels__c),
                    Integer.valueOf(config.Number_of_IP__c),
                    Integer.valueOf(config.Max__c),
                    Integer.valueOf(config.IPs_without_Location__c),
                    config.Authentication_Frequency__c
                ));
                recordCount = recordCount + 1;
            }

            return ticketsList;
        } else {
            return new List<MonthlyPolicyConfigWrapper>();
        }
    }

    public PageReference showMore() {
        limitValue += limitValue;

        return null;
    }

    public class MonthlyPolicyConfigWrapper {
        public Id configId { get; set; }
        public String name { get; set; }
        public String O365OneClick { get; set; }
        public Integer numberOfGRETunnels { get; set; }
        public Integer numberOfIPTunnels { get; set; }
        public Integer maxLicenses { get; set; }
        public Integer ipsWithoutLocation { get; set; }
        public String authenticationFrequency { get; set; }

        public MonthlyPolicyConfigWrapper(Id configId, String name, String o365OneClick, Integer numberOfGRETunnels, Integer numberOfIPTunnels,
                                            Integer maxLicenses, Integer ipsWithoutLocation, String authenticationFrequency) {
            this.configId = configId;
            this.name = name;
            this.O365OneClick = O365OneClick;
            this.numberOfGRETunnels = numberOfGRETunnels;
            this.numberOfIPTunnels = numberOfIPTunnels;
            this.maxLicenses = maxLicenses;
            this.ipsWithoutLocation = ipsWithoutLocation;
            this.authenticationFrequency = authenticationFrequency;
        }
    }
}