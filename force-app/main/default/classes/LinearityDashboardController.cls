public class LinearityDashboardController {
    public PerformanceDataModel.UserInfo CurrentViewingUser { get; private set; }
    public ForecastingDataModel.FiscalQuarterInfo CurrentFiscalQuarter { get; private set; }
    public String ForecastType { get; private set; }
    public String currentFiscalYear { get; private set; }
    public String currentQtr { get; private set; }
    public String firstQtr { get; private set; }
    public String secondQtr { get; private set; }
    public String thirdQtr { get; private set; }
    public String fourthQtr { get; private set; }
    public String currentMonth { get; private set; }
    public String selectedQtr { get; private set; }
    public String nextMonth { get; private set; }
    public String prevMonth { get; private set; }
    
    public String currentRole { get; private set; }
    public String nextRole { get; private set; }
    public String prevRole { get; private set; }
    
    
   
    public List<PerformanceDataModel.UserInfo> UserNavPath { get; set; }
    
    public String UserPath{
        get{
            String result = '';
            for(PerformanceDataModel.UserInfo usr : UserNavPath){
                if(usr != null){
                    result += '/' + usr.UserId;
                }
            }
            return result;
        }
    }
    
    public linearityDashboardController(){
        ForecastType = ApexPages.currentPage().getParameters().get('type');
        if(ForecastType != 'new'  && ForecastType != 'upsell'){
            ForecastType = 'all';
        }
        
        
        
        map<string, string> nextMonthMap = new map<string, string>();
        nextMonthMap.put('Month 1','Month 2');
        nextMonthMap.put('Month 2','Month 3');
        nextMonthMap.put('Month 3','None');
        
        map<string, string> prevMonthMap = new map<string, string>();
        prevMonthMap.put('Month 1','None');
        prevMonthMap.put('Month 2','Month 1');
        prevMonthMap.put('Month 3','Month 2');
        
        
        map<integer, string> currentMonthMap = new map<integer, String>();
        currentMonthMap.put(8, 'Month 1');
        currentMonthMap.put(9, 'Month 2');
        currentMonthMap.put(10, 'Month 3');
        
        currentMonthMap.put(11, 'Month 1');
        currentMonthMap.put(12, 'Month 2');
        currentMonthMap.put(1, 'Month 3');
        
        currentMonthMap.put(2, 'Month 1');
        currentMonthMap.put(3, 'Month 2');
        currentMonthMap.put(4, 'Month 3');
        
        currentMonthMap.put(5, 'Month 1');
        currentMonthMap.put(6, 'Month 2');
        currentMonthMap.put(7, 'Month 3');
        
        currentMonth = ApexPages.currentPage().getParameters().get('month');
        if(currentMonth == null || currentMonth == ''){
            currentMonth = currentMonthMap.get(system.today().month());
        }
        
        nextMonth = nextMonthMap.get(currentMonth);
        prevMonth = prevMonthMap.get(currentMonth);
        
        
        currentRole = ApexPages.currentPage().getParameters().get('role');
        if(currentRole == null || currentRole == ''){
            currentRole = 'All';
        }
        
        map<string, string> nextRoleMap = new map<string, string>();
        nextRoleMap.put('All','VP');
        nextRoleMap.put('VP','Manager');
        nextRoleMap.put('Manager','Rep');
        nextRoleMap.put('Rep','None');
        map<string, string> prevRoleMap = new map<string, string>();
        prevRoleMap.put('All','None');
        prevRoleMap.put('VP','All');
        prevRoleMap.put('Manager','VP');
        prevRoleMap.put('Rep','Manager');
        nextRole = nextRoleMap.get(currentRole);
        prevRole = prevRoleMap.get(currentRole);
        
        CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo();
        selectedQtr  = ApexPages.currentPage().getParameters().get('qtr');
        if(selectedQtr == null || selectedQtr == ''){
            selectedQtr = CurrentFiscalQuarter.FormattedString;
        }
          
    
        String p = ApexPages.currentPage().getParameters().get('path');
        UserNavPath = GetUserNavPath(p);
        if(UserNavPath.size() > 0){
            CurrentViewingUser = PerformanceService.GetUser(UserNavPath[UserNavPath.size() - 1].UserId);
        }else{
            PerformanceDataModel.UserInfo user = PerformanceService.GetUser(UserInfo.getUserId());
            CurrentViewingUser = (user.ForecastEnabled) ? user : user.ViewForecastAs;
            UserNavPath.add(CurrentViewingUser);
        }
        
       
       integer fsicalYear = system.Today().Year();
       if( system.Today().Month() > 7 ){
           fsicalYear += 1;
       }
       
       
       firstQtr = fsicalYear + 'Q1';
       secondQtr = fsicalYear + 'Q2';
       thirdQtr = fsicalYear + 'Q3';
       fourthQtr = fsicalYear + 'Q4';
       currentFiscalYear = ''+fsicalYear;
    }
    
    public static List<PerformanceDataModel.UserInfo> GetUserNavPath(String path){
        List<PerformanceDataModel.UserInfo> result = new List<PerformanceDataModel.UserInfo>();
        if(isValidPath(path)){
            PerformanceDataModel.UserInfo usr;
            for(String pathEntry : path.split('/')){
                if(String.isNotBlank(pathEntry)){
                    usr = PerformanceService.GetUser(pathEntry);
                    if(usr != null){
                        result.add(usr);
                    }
                }
            }
        }
        return result;
    }
    
    private static Boolean isValidPath(String path){
        return String.isNotBlank(path) && Pattern.matches('/?(\\w{18}|\\w{15})(/(\\w{18}|\\w{15}))*', path);
    }
    
    
    //Gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<PerformanceDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId){
        return PerformanceService.GetDirectSubordinateUsers(userOrRoleId);
    }
    
    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<PerformanceDataModel.UserInfo> GetAllSubordinateUsers(String userId, string userLevel){
        return PerformanceService.GetAllSubordinateUsersWithLevel(userId,userLevel);
    }
    
        

}