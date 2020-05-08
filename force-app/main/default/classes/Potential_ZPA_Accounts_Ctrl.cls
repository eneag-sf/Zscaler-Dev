public class Potential_ZPA_Accounts_Ctrl{
    
    public Id userId{get; set;}
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}

    public List<AccountWrapper> accwrp{
        get{
            if(userId != null){
                accwrp = new List<AccountWrapper>();
                String Stage1 = label.Stage_7_Closed_Lost;
                String Stage2 = label.Stage_6_Closed_Won;
                
                List<String> StageList = new List<String>(); 
                StageList.add(Stage1);
                StageList.add(Stage2);
                //Map<Id, Account> accmap = new Map<Id, Account>([Select Id, Name,No_of_Platform_Seats__c, CSM_Name_New__r.Name from Account where (Users_ZPA_Platform__c = 0 or Users_ZPA_Platform__c = null) and Id not in (Select AccountId from Opportunity where Recordtype.Name in ('Renewal Opportunity','Upsell Opportunity') and Stagename not in ('11 - Closed Lost', '12 - Closed With No Decision', '13 - Closed & Approved By Finance', '14 - Closed: Delete Duplicate') and Total_ZPA_ACV__c > 0 and Account.OwnerId = :userId) and ownerId = :userId and type = 'Customer' and Do_not_tag_as_Propensity_to_Buy_ZPA__c = false]);
                Map<Id, Account> accmap = new Map<Id, Account>([Select Id, Name,No_of_Platform_Seats__c, CSM_Name_New__r.Name from Account where (Users_ZPA_Platform__c = 0 or Users_ZPA_Platform__c = null) and Id not in (Select AccountId from Opportunity where Recordtype.Name in ('Renewal Opportunity','Upsell Opportunity') and Stagename not IN:StageList and Total_ZPA_ACV__c > 0 and Account.OwnerId = :userId) and ownerId = :userId and type = 'Customer' and Do_not_tag_as_Propensity_to_Buy_ZPA__c = false]);
                
                
                Set<Id> accIdsforoldermonth = new Set<Id>();
                if(!accmap.isEmpty()){
                    accIdsforoldermonth.addAll(accmap.keyset());
                }
                Map<Id, Decimal> mapacctoTotalDevices = new Map<Id, Decimal>();
                Date startdate = date.today().addmonths(-1).toStartOfMonth();
                Date enddate = date.today().toStartOfMonth().adddays(-1);
                
                for(AggregateResult aggr : [select Cloud_ID__r.Account__c accId, sum(Total_registered_Devices__c) a from BWC_Data__c where Z_App_ZIA_Enabled__c = 'Enabled' and Cloud_ID__r.Account__c in :accIdsforoldermonth and Monthly_Usage__c >= :startdate and Monthly_Usage__c <= :enddate group by Cloud_ID__r.Account__c]){
                    if((Decimal)aggr.get('a') != null && (Decimal)aggr.get('a') != 0){
                        accIdsforoldermonth.remove((Id)aggr.get('accId'));
                        mapacctoTotalDevices.put((Id)aggr.get('accId'), (Decimal)aggr.get('a'));
                    }
                }
                system.debug(accIdsforoldermonth);
                startdate = date.today().addmonths(-2).toStartOfMonth();
                enddate = date.today().addmonths(-1).toStartOfMonth().adddays(-1);
                
                for(AggregateResult aggr : [select Cloud_ID__r.Account__c accId, sum(Total_registered_Devices__c) a from BWC_Data__c where Z_App_ZIA_Enabled__c = 'Enabled' and Cloud_ID__r.Account__c = :accIdsforoldermonth and Monthly_Usage__c >= :startdate and Monthly_Usage__c <= :enddate group by Cloud_ID__r.Account__c]){
                    if((Decimal)aggr.get('a') != null && (Decimal)aggr.get('a') != 0){
                        mapacctoTotalDevices.put((Id)aggr.get('accId'), (Decimal)aggr.get('a'));
                    }
                }
                system.debug(mapacctoTotalDevices);
                if(!mapacctoTotalDevices.isEmpty()){
                    for(Id accId: mapacctoTotalDevices.keyset()){
                        if(mapacctoTotalDevices.get(accId) != null && accmap.get(accId) != null && accmap.get(accId).No_of_Platform_Seats__c != null && accmap.get(accId).No_of_Platform_Seats__c != 0 && (((mapacctoTotalDevices.get(accId) / 2) / accmap.get(accId).No_of_Platform_Seats__c) * 100 > 10)){
                            accwrp.add(new AccountWrapper(accmap.get(accId), mapacctoTotalDevices.get(accId), mapacctoTotalDevices.get(accId)));
                        }
                    }
                }
                return accwrp;
            }
            return null;
        } set;
    }
    public User us{
        get{
            if(userId != null){
                return [Select Id, name, email from User where id = :userId];
            }
            return null;
        } set;
    }
    
    public class AccountWrapper{
        public Account acc{get; set;}
        public Decimal zappDeployed{get;set;}
        public Integer regDevice{get;set;}
        
        public AccountWrapper(Account acc1, Decimal zappDep, Decimal regDev){
            acc = acc1;
            zappDeployed = zappDep;
            regDevice = (Integer)regDev;
        }
        
    }
}