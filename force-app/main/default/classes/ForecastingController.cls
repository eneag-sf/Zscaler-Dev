/**
 * This class is the controller of page Forecasting.
 */

public class ForecastingController
{
    public ForecastingController()
    {

        ForecastFamily = ApexPages.currentPage().getParameters().get('family') != null ? ApexPages.currentPage().getParameters().get('family').toUpperCase() : '';
        if(ForecastFamily != 'ZIA' && ForecastFamily != 'ZPA')
        {
            ForecastingDataModel.UserInfo LoggedInUserInfo = ForecastingService.GetUser(UserInfo.getUserId());
            ForecastFamily = LoggedInUserInfo.DefaultForecastFamily;
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
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo(q);
        }
        else
        {
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo();
        }

        //Set User Nav Path
        String p = ApexPages.currentPage().getParameters().get('path');
        UserNavPath = GetUserNavPath(p);
        if(UserNavPath.size() > 0)
        {
            CurrentViewingUser = ForecastingService.GetUser(UserNavPath[UserNavPath.size() - 1].UserId);
            ForecastingDataModel.UserInfo LoggedInUserInfo = ForecastingService.GetUser(UserInfo.getUserId());

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
            ForecastingDataModel.UserInfo user = ForecastingService.GetUser(UserInfo.getUserId());

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
        if(ForecastType != 'all' && ForecastType != 'renewal' && ForecastType != 'upsell')
        {
            ForecastType = 'new';
        }

        CurrentWeek = new ForecastingDataModel.WeekInfo();
    }

    public ForecastingDataModel.FiscalQuarterInfo CurrentFiscalQuarter { get; private set; }
    public ForecastingDataModel.WeekInfo CurrentWeek { get; private set; }
    public ForecastingDataModel.UserInfo CurrentViewingUser { get; private set; }
    public String ForecastType { get; private set; }
    public String ForecastFamily { get; private set; }
    public List<ForecastingDataModel.UserInfo> UserNavPath { get; set; }
    public Boolean impersonateViewAsUser { get; set; }
    public String viewAsUserName { get; set; }
    public Boolean showForecastFamilySwitch {
        get {
            ForecastingDataModel.UserInfo LoggedInUserInfo = ForecastingService.GetUser(UserInfo.getUserId());
            if ((LoggedInUserInfo.ForecastEnabled == true || LoggedInUserInfo.ViewForecastAs != null) && (LoggedInUserInfo.ZPAForecastEnabled == true || LoggedInUserInfo.ViewZPAForecastAs != null)) {
                return true;
            } else {
                return false;
            }
        }
    }
    public String UserPath
    {
        get
        {
            String result = '';
            for(ForecastingDataModel.UserInfo usr : UserNavPath)
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
            return CurrentFiscalQuarter.FormattedString < (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString && CurrentFiscalQuarter.EndDate.addDays(1) < Date.today();
        }
    }
    public Boolean canImpersonate {
        get {
            ForecastingDataModel.UserInfo LoggedInUserInfo = ForecastingService.GetUser(UserInfo.getUserId());
            if (viewAsUserName != null && (LoggedInUserInfo.ForecastEnabled == true && ForecastFamily == 'ZIA') || (LoggedInUserInfo.ZPAForecastEnabled == true && ForecastFamily == 'ZPA')) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    public String InlineEditingState{
        get {
            return ForecastingService.getInlineEdittingState( CurrentFiscalQuarter.FormattedString , UserInfo.getUserId(), ForecastFamily);
        }
    }
    
    public String OppListEditingPicklists
    {
        get
        {
            return JSON.serialize( new String[] {'StageName'} );
        }
    }
    
    public String getOpportunityPicklistFieldsValues()
    {
        return JSON.serialize( ForecastingService.getOpportunityPicklistFieldsValues(new String[]{'StageName', 'Validation_Stage__c', 'ForecastCategoryName'}) );
    }

    public PageReference init()
    {
        if(CurrentViewingUser != null)
        {
            ForecastingService.initForecast(CurrentViewingUser.UserId, 'New', ForecastFamily);
            ForecastingService.initForecast(CurrentViewingUser.UserId, 'Upsell', ForecastFamily);
            ForecastingService.initForecast(CurrentViewingUser.UserId, 'Renewal', ForecastFamily);
        }
        return null;
    }

    public PageReference toggleImpersonation() {
        impersonateViewAsUser = (impersonateViewAsUser == null || impersonateViewAsUser == false) ? true : false;

        ForecastingDataModel.UserInfo user = ForecastingService.GetUser(UserInfo.getUserId());
        UserNavPath.clear();
        // if (impersonateViewAsUser) {
        //     CurrentViewingUser = user.ViewForecastAs;
        //     UserNavPath.add(CurrentViewingUser);
        //     viewAsUserName = user.Username;
        // } else if (user.ForecastEnabled) {
        //     CurrentViewingUser = user;
        //     UserNavPath.add(CurrentViewingUser);
        //     viewAsUserName = user.ViewForecastAsName;
        // } else if (user.ZPAForecastEnabled) {
        //     CurrentViewingUser = user;
        //     UserNavPath.add(CurrentViewingUser);
        //     viewAsUserName = user.ViewZPAForecastAsName;
        // } else {
        //     CurrentViewingUser = user.ViewForecastAs;
        //     UserNavPath.add(CurrentViewingUser);
        // }

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

    public static List<ForecastingDataModel.UserInfo> GetUserNavPath(String path)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        if(isValidPath(path))
        {
            ForecastingDataModel.UserInfo usr;
            for(String pathEntry : path.split('/'))
            {
                if(String.isNotBlank(pathEntry))
                {
                    usr = ForecastingService.GetUser(pathEntry);
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
    public static List<ForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId, String forecastFamily)
    {
        return ForecastingService.GetDirectSubordinateUsers(userOrRoleId, forecastFamily);
    }

    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetAllSubordinateUsers(String userId, String forecastFamily)
    {
        return ForecastingService.GetAllSubordinateUsers(userId, forecastFamily);
    }

    @ReadOnly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetDirectSubordinateUsersV2(Id userOrRoleId, String forecastFamily) {
        return ForecastingService.GetDirectSubordinateUsersV2(userOrRoleId, forecastFamily);
    }
}