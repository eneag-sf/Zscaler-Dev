public class PerformanceDataModel{
    
    public class userInfo{
        public String UserId { get; set; }
        public String Username { get; set; }
        public String RoleId { get; set; }
        public String RoleName { get; set; }
        public Boolean ForecastEnabled { get; set; }
        public Id ViewForecastAsId { get; set; }
    
        public userInfo(user usr){
             this.UserId = usr.Id;
             this.Username = usr.Name;
             this.RoleId = usr.UserRoleId;
             this.RoleName = usr.UserRole.Name;
             this.ForecastEnabled = usr.ForecastEnabled__c;
             this.ViewForecastAsId = usr.ViewForecastAs__c;
        }
        
        public UserInfo ViewForecastAs{
            get{
                    return (ViewForecastAsId != null) ? PerformanceService.getUser(viewForecastAsId) : null;
            }
        }
        
        
    }
    
}