/**
 * This class is the controller of page Forecasting.
 */

public with sharing class ForecastingQuotaController 
{
    public Map<Id, SalesQuota__c> userId2Quota;
    public UserQuota UserQuota { get; set; }
    public String ForecastType { get; set; }
    public ForecastingDataModel.FiscalQuarterInfo CurrentFiscalQuarter { get; private set; }
    
    public ForecastingQuotaController() 
    {
        String q = ApexPages.currentPage().getParameters().get('quarter');
        if(String.isNotBlank(q))
        {
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo(q);
        }
        else
        {
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo();
        }
        
        ForecastType = ApexPages.currentPage().getParameters().get('type');
        if(ForecastType != 'new' && ForecastType != 'renewal' && ForecastType != 'upsell')
        {
            ForecastType = 'new';
        }
    }
    
    public String RootUsers 
    {
        get
        {
            List<UserQuota> result = GetDirectSubUserQuota(null, CurrentFiscalQuarter.FormattedString, ForecastType);
            return JSON.serialize(result);
        }
    }

    @Readonly @RemoteAction
    public static List<UserQuota> GetDirectSubUserQuota(Id userId, String fiscalQuarter, String forecastType)
    {
        List<ForecastingDataModel.UserInfo> subUsers = ForecastingService.GetDirectSubordinateUsers(userId);
        List<Id> userIds = new List<Id>();
        for(ForecastingDataModel.UserInfo u : subUsers)
        {
            if(u.ForecastEnabled == true && u.ViewForecastAsId == null)
            {
                userIds.add(u.UserId);
            }
        }
        return loadUserQuota(userIds, fiscalQuarter, forecastType);
    }
    
    @RemoteAction
    public static void SaveUserQuota(List<UserQuota> quotas)
    {
        Map<Id, Decimal> quotaMap = new Map<Id, Decimal>();
        String fiscalQuarter = '';
        String forecastType = '';
        for(UserQuota q : quotas)
        {
            quotaMap.put(q.UserId, q.QuotaAmount);
            fiscalQuarter = q.FiscalQuarter;
            forecastType = q.ForecastType;
        }
        if(quotaMap.keyset().size() > 0)
        {
            List<SalesQuota__c> updatingQuota = new List<SalesQuota__c>();
            List<SalesQuota__c> qs = [SELECT Id, User__c, QuotaAmount__c, ForecastType__c FROM SalesQuota__c WHERE User__c IN :quotaMap.keyset() and FYFQ__c=:fiscalQuarter and ForecastType__c = :forecastType];
            for(Id userId : quotaMap.keyset())
            {
                Boolean found = false;
                for(SalesQuota__c q : qs)
                {
                    if(userId == q.User__c)
                    {
                        q.QuotaAmount__c = quotaMap.get(userId);
                        updatingQuota.add(q);
                        found = true;
                        break;
                    }
                }
                if(!found) 
                {
                    updatingQuota.add(new SalesQuota__c(User__c=userId, QuotaAmount__c=quotaMap.get(userId), FYFQ__c=fiscalQuarter, ForecastType__c=forecastType));
                }
            }
            upsert updatingQuota;
        }
    }
    
    private static List<UserQuota> loadUserQuota(List<Id> userIds, String fiscalQuarter, String forecastType)
    {
        List<UserQuota> result = new List<UserQuota>();
        for(User usr : [select Id, Name, UserRoleId, UserRole.Name from User where Id in :userIds])
        {
            UserQuota q = new UserQuota(usr.Id, usr.Name, usr.UserRole.Name, forecastType, fiscalQuarter);
            q.HasSubordinate = ForecastingService.getSubRoles(usr.UserRoleId, false).size() > 0;
            result.add(q);
        }
        for(SalesQuota__c quota : [SELECT Id, User__c, QuotaAmount__c FROM SalesQuota__c WHERE User__c IN :userIds and FYFQ__c=:fiscalQuarter AND ForecastType__c = :forecastType])
        {
            for(UserQuota user : result)
            {
                if(user.UserId == quota.User__c)
                {
                    user.QuotaAmount = quota.QuotaAmount__c;
                    break;
                }
            }
        }
        String previousQuarter = (new ForecastingDataModel.FiscalQuarterInfo(fiscalQuarter)).Previous.FormattedString;
        for(SalesQuota__c quota : [SELECT Id, User__c, QuotaAmount__c FROM SalesQuota__c WHERE User__c IN :userIds and FYFQ__c=:previousQuarter AND ForecastType__c = :forecastType])
        {
            for(UserQuota user : result)
            {
                if(user.UserId == quota.User__c)
                {
                    user.PreviousQuota = quota.QuotaAmount__c;
                    break;
                }
            }
        }
        return result;
    }
    
    public class UserQuota
    {
        public Id UserId { get; set; }
        public String UserName { get; set; }
        public String RoleName { get; set; }
        public Decimal QuotaAmount { get; set; }
        public Decimal PreviousQuota { get; set; }
        public String FiscalQuarter { get; set; }
        public String ForecastType { get; set; }
        public Boolean HasSubordinate { get; set; }
        
        public UserQuota(Id userId, String username, String roleName, String forecastType, String qtr)
        {
            this.UserId = userId;
            this.UserName = username;
            this.RoleName = roleName;
            this.ForecastType = forecastType;
            this.FiscalQuarter = qtr;
        }
        public UserQuota(Id userId, String username, String roleName, String forecastType)
        {
            this(userId, username, roleName, forecastType, null);
        }
    }
}