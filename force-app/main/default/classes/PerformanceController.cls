public with sharing class PerformanceController{
    
    public PerformanceDataModel.UserInfo CurrentViewingUser { get; private set; }
    public ForecastingDataModel.FiscalQuarterInfo CurrentFiscalQuarter { get; private set; }
    public String ForecastType { get; private set; }
    public String firstQtr { get; private set; }
    public String secondQtr { get; private set; }
    public String thirdQtr { get; private set; }
    public String fourthQtr { get; private set; }
    public String currentQtr { get; private set; }
    
    public String dashboardType { get; private set; }
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
    
   public PerformanceController(){
       
        dashBoardType  = ApexPages.currentPage().getParameters().get('dashboard');
        if(dashBoardType != 'Performance' && dashBoardType != 'Activity' && dashBoardType != 'Stack'){
            dashBoardType = 'funnel';
        }
        ForecastType = ApexPages.currentPage().getParameters().get('type');
        if(ForecastType != 'all' && ForecastType != 'renewal' && ForecastType != 'upsell'){
            ForecastType = 'new';
        }
         //Set Fiscal Quarter
        String q = ApexPages.currentPage().getParameters().get('quarter');
        if(String.isNotBlank(q)){
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo(q);
        }else{
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo();
        }
          
           //Set User Nav Path
        String p = ApexPages.currentPage().getParameters().get('path');
        UserNavPath = GetUserNavPath(p);
        if(UserNavPath.size() > 0){
            CurrentViewingUser = PerformanceService.GetUser(UserNavPath[UserNavPath.size() - 1].UserId);
        }else
        {
            PerformanceDataModel.UserInfo user = PerformanceService.GetUser(UserInfo.getUserId());
            CurrentViewingUser = (user.ForecastEnabled) ? user : user.ViewForecastAs;
            UserNavPath.add(CurrentViewingUser);
        }
       
       map<integer, integer> qtrMap = new map<integer, integer>(); 
       for(Integer i = 1; i <=12; i++){
           if(i ==8 || i == 9 || i == 10){
               qtrMap.put(i, 10);
           }else if(i ==11 || i == 12 || i == 1){
               qtrMap.put(i, 1);
           }else if(i ==2 || i == 3 || i == 4){
               qtrMap.put(i, 4);
           }else if (i ==5 || i == 6 || i == 7){
               qtrMap.put(i, 7);
           }
       }
       
       integer fsicalYear = system.Today().Year();
       if( system.Today().Month() == 11 || system.Today().Month() == 12){
           fsicalYear += 1;
       }
       
       date lastMonthDateQtr = date.newInstance(fsicalYear, qtrMap.get(system.Today().Month()), 1);
       
       currentQtr = PerformanceService.getQtrString(lastMonthDateQtr, 0);
       firstQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(3), 0);
       secondQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(6), 0);
       thirdQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(9), 0);
       fourthQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(12), 0);
       
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
    public static List<PerformanceDataModel.UserInfo> GetAllSubordinateUsers(String userId){
        return PerformanceService.GetAllSubordinateUsers(userId);
    }
    
    
    
}