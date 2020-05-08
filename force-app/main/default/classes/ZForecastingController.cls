/**
 * This class is the controller of page Forecasting.
 */

public class ZForecastingController
{
    //Commened line no.11 and make it public to reduce Soql Query for Forecasting issue in RBAC
    public ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
    public ZForecastingController()
    {
        //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
        system.debug('LoggedInUserInfo   '+LoggedInUserInfo);
        ForecastFamily = ApexPages.currentPage().getParameters().get('family') != null ? ApexPages.currentPage().getParameters().get('family').toUpperCase() : '';
        if(ForecastFamily != 'ZIA' && ForecastFamily != 'ZPA')
        {
            // ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            //ForecastFamily = LoggedInUserInfo.DefaultForecastFamily;
            ForecastFamily = 'ZIA';
        }

        //Set impersonation state to false;
        if (ApexPages.currentPage().getParameters().containsKey('impersonate')) {
            impersonateViewAsUser = (ApexPages.currentPage().getParameters().get('impersonate').toLowerCase() == 'true') ? true : false;
        } else {
            impersonateViewAsUser = false;
        }

        //Set Fiscal Quarter
        String q = ApexPages.currentPage().getParameters().get('quarter');
        if(String.isNotBlank(q))
        {
            CurrentFiscalQuarter = new ZForecastingDataModel.FiscalQuarterInfo(q);
        }
        else
        {
            CurrentFiscalQuarter = new ZForecastingDataModel.FiscalQuarterInfo();
        }

        //Set User Nav Path
        String p = ApexPages.currentPage().getParameters().get('path');
        UserNavPath = GetUserNavPath(p);
        if(UserNavPath.size() > 0)
        {
            CurrentViewingUser = ZForecastingService.GetUser(UserNavPath[UserNavPath.size() - 1].UserId);
            // ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());

            if (null != LoggedInUserInfo.ViewForecastAsName
                && LoggedInUserInfo.ForecastEnabled
                && ForecastFamily == 'ZIA') {
                viewAsUserName = (impersonateViewAsUser == true) ? LoggedInUserInfo.Username : LoggedInUserInfo.ViewForecastAsName;
            } else if (null != LoggedInUserInfo.ViewZPAForecastAsName
                && LoggedInUserInfo.ZPAForecastEnabled
                && ForecastFamily == 'ZPA') {
                    viewAsUserName = (impersonateViewAsUser == true) ? LoggedInUserInfo.Username : LoggedInUserInfo.ViewZPAForecastAsName;
            } else {
                viewAsUserName = null;
            }
        }
        else
        {
            ZForecastingDataModel.UserInfo user = ZForecastingService.GetUser(UserInfo.getUserId());

            // if (user.ForecastEnabled == true && impersonateViewAsUser == false) {
            //     CurrentViewingUser = user;
            //     UserNavPath.add(CurrentViewingUser);
            // } else if (user.ViewForecastAs != null) {
            //     CurrentViewingUser = user.ViewForecastAs;
            //     UserNavPath.add(CurrentViewingUser);
            // } else {
            //     CurrentViewingUser = user;
            //     UserNavPath.add(CurrentViewingUser);
            // }

            if (ForecastFamily == 'ZPA') {
                if (user.zpaForecastEnabled == true && impersonateViewAsUser == false) {
                    CurrentViewingUser = user;
                    UserNavPath.add(CurrentViewingUser);
                } else if (user.ViewZPAForecastAs != null) {
                    CurrentViewingUser = user.ViewZPAForecastAs;
                    UserNavPath.add(CurrentViewingUser);
                } else {
                    CurrentViewingUser = user;
                    UserNavPath.add(CurrentViewingUser);
                }
            } else {
                if (user.ForecastEnabled == true && impersonateViewAsUser == false) {
                    CurrentViewingUser = user;
                    UserNavPath.add(CurrentViewingUser);
                } else if (user.ViewForecastAs != null) {
                    CurrentViewingUser = user.ViewForecastAs;
                    UserNavPath.add(CurrentViewingUser);
                } else {
                    CurrentViewingUser = user;
                    UserNavPath.add(CurrentViewingUser);
                }
            }

            //CurrentViewingUser = (user.ForecastEnabled && impersonateViewAsUser == false) ? user : (null != user.ViewForecastAs) ? user.ViewForecastAs : user;

            if (null != CurrentViewingUser.ViewForecastAsName && ForecastFamily == 'ZIA') {
                viewAsUserName = CurrentViewingUser.ViewForecastAsName;
            } else if (null != CurrentViewingUser.ViewZPAForecastAsName && ForecastFamily == 'ZPA') {
                viewAsUserName = CurrentViewingUser.ViewZPAForecastAsName;
            } else {
                viewAsUserName = null;
            }
        }

        ForecastType = ApexPages.currentPage().getParameters().get('type');
        if(ForecastType != 'all' && ForecastType != 'renewal' && ForecastType != 'upsell' && ForecastType != 'new' && ForecastType != 'billings')
        {
            ForecastType = 'new-upsell';
        }

        CurrentWeek = new ZForecastingDataModel.WeekInfo();
    }

    public ZForecastingDataModel.FiscalQuarterInfo CurrentFiscalQuarter { get; private set; }
    public ZForecastingDataModel.WeekInfo CurrentWeek { get; private set; }
    public ZForecastingDataModel.UserInfo CurrentViewingUser { get; private set; }
    public String ForecastType { get; private set; }
    public String ForecastFamily { get; private set; }
    public List<ZForecastingDataModel.UserInfo> UserNavPath { get; set; }
    public Boolean impersonateViewAsUser { get; set; }
    public String viewAsUserName { get; set; }
    public Boolean showForecastFamilySwitch {
        get {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            if ((LoggedInUserInfo.ForecastEnabled == true || LoggedInUserInfo.ViewForecastAs != null) && (LoggedInUserInfo.ZPAForecastEnabled == true || LoggedInUserInfo.ViewZPAForecastAs != null)) {
                return true;
            } else {
                return false;
            }
        }
    }
    Public Boolean ViewNetNewACV
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.ViewNetNewACV;
        }
    }
    
    Public Boolean ViewExportToExcel
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.ViewExportToExcel;
        }
    }
    
    Public String ViewNOTRA
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.ViewNotra;
        }
    }
    
    Public String ViewBillings
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.ViewBillings;
        }
    }
    Public String UserLevel
    {
        get
        {
            // ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            // if (impersonateViewAsUser) {
            //     return LoggedInUserInfo.ViewForecastAs.Level;
            // } else {
            //     return LoggedInUserInfo.Level;
            // }
            return CurrentViewingUser.Level;
        }
    }



    Public String CurrentUserLevel
    {
        get
        {
            // ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            // if (impersonateViewAsUser) {
            //     return LoggedInUserInfo.ViewForecastAs.Level;
            // } else {
            //     return LoggedInUserInfo.Level;
            // }
            return CurrentViewingUser.Level;
        }
    }

    Public String MyUserLevel
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            if ((impersonateViewAsUser || LoggedInUserInfo.ForecastEnabled != true) && LoggedInUserInfo != null && LoggedInUserInfo.ViewForecastAs != null) {
                return LoggedInUserInfo.ViewForecastAs.Level;
            } else {
                return LoggedInUserInfo.Level;
            }
        }
    }
    
    Public String LoggedInUserLevel
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.Level;
            
        }
    }
    
    Public String LoggedInUserLocale
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.UserLocale;
            
        }
    }

    Public String MyUserId
    {
        get
        {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            if (impersonateViewAsUser || LoggedInUserInfo.ForecastEnabled != true) {
                return LoggedInUserInfo.ViewForecastAsId;
            } else {
                return LoggedInUserInfo.UserId;
            }
        }
    }

    public Boolean showMyRollupSection {
        get {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            if ((impersonateViewAsUser || LoggedInUserInfo.ForecastEnabled != true) && LoggedInUserInfo != null && LoggedInUserInfo.ViewForecastAs != null) {
                return LoggedInUserInfo.ViewForecastAsId != CurrentViewingUser.UserId && LoggedInUserInfo.ViewForecastAs.Level != 'Rep';
            } else {
                return LoggedInUserInfo.UserId != CurrentViewingUser.UserId && LoggedInUserInfo.Level != 'Rep';
            }
        }
    }

    public Boolean showMyForecastSection {
        get {
            return CurrentViewingUser.Level != 'Rep' && CurrentViewingUser.Level != 'N/A';
        }
    }
    public String UserPath
    {
        get
        {
            String result = '';
            for(ZForecastingDataModel.UserInfo usr : UserNavPath)
            {
                if(usr != null)
                {
                    result += '/' + usr.UserId;
                }
            }
            return result;
        }
    }
    public Boolean IsAdmin
    {
        get
        {
            User currentUser = [select Id, Profile.PermissionsAuthorApex, Profile.PermissionsModifyAllData from User where Id=:UserInfo.getUserId() limit 1];
            return currentUser.Profile.PermissionsAuthorApex == true && currentUser.Profile.PermissionsModifyAllData == true;
        }
    }
    public Boolean canEditPlan
    {
        get
        {
            List<PermissionSetAssignment> psa = [select Id from PermissionSetAssignment where PermissionSet.Name='Forecast_Quota' and AssigneeId=:UserInfo.getUserId() limit 1];
            return psa.size() > 0;
        }
    }
    public Boolean IsViewingHistory
    {
        get
        {
            return CurrentFiscalQuarter.FormattedString < (new ZForecastingDataModel.FiscalQuarterInfo()).FormattedString && CurrentFiscalQuarter.EndDate.addDays(1) <= Date.today();
        }
    }
    public Boolean canImpersonate {
        get {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            if (viewAsUserName != null && (LoggedInUserInfo.ForecastEnabled == true && ForecastFamily == 'ZIA') || (LoggedInUserInfo.ZPAForecastEnabled == true && ForecastFamily == 'ZPA')) {
                return true;
            } else {
                return false;
            }
        }
    }

    public Boolean forecastEnabledForLoggedInUser {
        get {
            //ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.ForecastEnabled;
        }

        set;
    }

    public String InlineEditingState{
        get {
            return ForecastingService.getInlineEdittingState( CurrentFiscalQuarter.FormattedString , UserInfo.getUserId(), ForecastFamily);
        }
    }

    public String getOpportunityPicklistFieldsValues()
    {
        return JSON.serialize( ForecastingService.getOpportunityPicklistFieldsValues(new String[]{'StageName', 'Validation_Stage__c', 'ForecastCategoryName', 'Forecast_Category__c', 'DM_Forecast_Category__c', 'AD_Forecast_Category__c', 'RVP_Forecast_Category__c', 'VP_Forecast_Category__c', 'CRO_Forecast_Category__c'}) ); //, 'ForecastCategoryName'
    }

    public String getGeoAndRegionPicklistValues() {
        Map<String, Set<String>> mapGeoAndRegionValues = new Map<String, Set<String>>();
        for (AggregateResult ar : [SELECT Theater__c, Region__c FROM PatchTeam__c WHERE Theater__c != null AND Region__c != null AND Theater__c != 'CHANNEL' GROUP BY Theater__c, Region__c]) {
            if (!mapGeoAndRegionValues.containsKey((String)ar.get('Theater__c'))) {
                if ((String)ar.get('Theater__c') == (String)ar.get('Region__c')) {
                    mapGeoAndRegionValues.put((String)ar.get('Theater__c'), new Set<String> { 'All' });
                } else {
                    mapGeoAndRegionValues.put((String)ar.get('Theater__c'), new Set<String> { (String)ar.get('Region__c') });
                }
            } else {
                if ((String)ar.get('Theater__c') == (String)ar.get('Region__c')) {
                    mapGeoAndRegionValues.get((String)ar.get('Theater__c')).add('All');
                } else {
                    mapGeoAndRegionValues.get((String)ar.get('Theater__c')).add((String)ar.get('Region__c'));
                }
            }
        }

        mapGeoAndRegionValues.put('All', new Set<String>{ 'All' });
        for (String key : mapGeoAndRegionValues.keySet()) {
            mapGeoAndRegionValues.get('All').addAll(mapGeoAndRegionValues.get(key));
        }

        return JSON.serialize(mapGeoAndRegionValues);
    }

    public PageReference init()
    {
        Set<Id> allUserIds = new Set<Id>();
        allUserIds.add(UserInfo.getUserId());
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(UserInfo.getUserId()));
        if(CurrentViewingUser != null && allUserIds.contains(CurrentViewingUser.UserId))
        {
            ZForecastingService.initForecast(CurrentViewingUser.UserId, UserLevel, 'New', ForecastFamily, LoggedInUserLocale, CurrentViewingUser.UserLocale );
            ZForecastingService.initForecast(CurrentViewingUser.UserId, UserLevel, 'Upsell', ForecastFamily, LoggedInUserLocale, CurrentViewingUser.UserLocale );
            ZForecastingService.initForecast(CurrentViewingUser.UserId, UserLevel, 'Renewal', ForecastFamily, LoggedInUserLocale, CurrentViewingUser.UserLocale);
            if(ForecastFamily != 'ZPA'){
                ZForecastingService.initForecast(CurrentViewingUser.UserId, UserLevel, 'New', 'ZPA', LoggedInUserLocale, CurrentViewingUser.UserLocale );
                ZForecastingService.initForecast(CurrentViewingUser.UserId, UserLevel, 'Upsell', 'ZPA', LoggedInUserLocale, CurrentViewingUser.UserLocale );
                ZForecastingService.initForecast(CurrentViewingUser.UserId, UserLevel, 'Renewal', 'ZPA', LoggedInUserLocale, CurrentViewingUser.UserLocale);
            }
        }
        return null;
    }

    public PageReference toggleImpersonation() {
        impersonateViewAsUser = (impersonateViewAsUser == null || impersonateViewAsUser == false) ? true : false;

        ZForecastingDataModel.UserInfo user = ZForecastingService.GetUser(UserInfo.getUserId());
        UserNavPath.clear();

        if (impersonateViewAsUser) {
            if (forecastFamily == 'ZPA') {
                CurrentViewingUser = user.ViewZPAForecastAs;
                UserNavPath.add(CurrentViewingUser);
                viewAsUserName = user.Username;
            } else {
                CurrentViewingUser = user.ViewForecastAs;
                UserNavPath.add(CurrentViewingUser);
                viewAsUserName = user.Username;
            }
        } else {
            if (forecastFamily == 'ZPA') {
                CurrentViewingUser = user;
                UserNavPath.add(CurrentViewingUser);
                viewAsUserName = user.ViewZPAForecastAsName;
            } else {
                CurrentViewingUser = user;
                UserNavPath.add(CurrentViewingUser);
                viewAsUserName = user.ViewForecastAsName;
            }
        }
        
        init();

        return null;
    }

    public static List<ZForecastingDataModel.UserInfo> GetUserNavPath(String path)
    {
        List<ZForecastingDataModel.UserInfo> result = new List<ZForecastingDataModel.UserInfo>();
        if(isValidPath(path))
        {
            ZForecastingDataModel.UserInfo usr;
            for(String pathEntry : path.split('/'))
            {
                if(String.isNotBlank(pathEntry))
                {
                    usr = ZForecastingService.GetUser(pathEntry);
                    if(usr != null)
                    {
                        result.add(usr);
                    }
                }
            }
        }
        return result;
    }

    private static Boolean isValidPath(String path)
    {
        return String.isNotBlank(path) && Pattern.matches('/?(\\w{18}|\\w{15})(/(\\w{18}|\\w{15}))*', path);
    }

    //Gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<ZForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId, String forecastFamily)
    {
        return ZForecastingService.GetDirectSubordinateUsers(userOrRoleId, forecastFamily);
    }

    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<ZForecastingDataModel.UserInfo> GetAllSubordinateUsers(String userId, String forecastFamily)
    {
        return ZForecastingService.GetAllSubordinateUsers(userId, forecastFamily);
    }

    @ReadOnly @RemoteAction
    public static List<ZForecastingDataModel.UserInfo> GetDirectSubordinateUsersV2(Id userOrRoleId, String forecastFamily) {
        return ZForecastingService.GetDirectSubordinateUsersV2(userOrRoleId, forecastFamily);
    }

    @RemoteAction @Readonly
    public static ZForecastingDataModel.UserInfo GetUser(String userId) {
        return ZForecastingService.GetUser(userId);
    }
}