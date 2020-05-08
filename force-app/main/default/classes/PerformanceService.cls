public class PerformanceService{
    
    private static Map<Id, List<Id>> subRoleMapping;
    private static Map<Id, List<User>> forecastingUsers;

     public static performanceDataModel.UserInfo GetUser(String userId){
        List<User> users = [SELECT Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0){
            return new performanceDataModel.UserInfo(users[0]);
        }else{
            return null;
        }
    }
    
    //Gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<PerformanceDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId){
        List<PerformanceDataModel.UserInfo> result = new List<PerformanceDataModel.UserInfo>();
        List<Id> roleIds = new List<Id>();
        List<User> userList = new List<User>();
        if(userOrRoleId == null){
            roleIds = getSubRoles(null, false);
        }else if(userOrRoleId.getSObjectType() == Schema.User.SObjectType){
            userList = [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c from User where Id=:userOrRoleId limit 1];
            if(userList.size() > 0){
                roleIds.add(userList[0].UserRoleId);
                result.add(new PerformanceDataModel.UserInfo(userList[0]));
            }
        }else if(userOrRoleId.getSObjectType() == Schema.UserRole.SObjectType){
            roleIds.add(userOrRoleId);
        }
        if(roleIds.size() > 0){
            for(Id roleId : roleIds){
                List<Id> subRoles = getSubRoles(roleId, false);
                for(Id rid : subRoles){
                    List<PerformanceDataModel.UserInfo> users = getUsersByRole(rid, true);
                    if(users.size() > 0){
                        result.addAll(users);
                    }else{
                        result.addAll(GetDirectSubordinateUsers(rid));
                    }
                }
            }
        }
        system.debug(' # result : '+result);
        return result;
    }
    
     public static List<Id> getSubRoles(Id roleId, Boolean traverseAll){
        List<Id> result = new List<Id>();
        subRoleMapping = getSubRoleMapping();
        List<Id> directRoles = subRoleMapping.get(roleId);
        if(directRoles != null){
            result.addAll(directRoles);
            if(traverseAll){
                for(Id rid : directRoles){
                    result.addAll(getSubRoles(rid, true));
                }
            }
        }
        return result;
    }
    
    static Map<Id, List<Id>> getSubRoleMapping(){
        if(subRoleMapping == null){
            subRoleMapping = new Map<Id, List<Id>>();
            for(UserRole role : [SELECT Id, Name, ParentRoleId FROM UserRole WHERE PortalType = 'None']){
                if(!subRoleMapping.containsKey(role.ParentRoleId)){
                    subRoleMapping.put(role.ParentRoleId, new List<Id> {role.Id});
                }else{
                    subRoleMapping.get(role.ParentRoleId).add(role.Id);
                }
            }
        }
        return subRoleMapping;
    }
    
    private static List<PerformanceDataModel.UserInfo> getUsersByRole(Id roleId, Boolean forecastOnly){
        List<PerformanceDataModel.UserInfo> result = new List<PerformanceDataModel.UserInfo>();
        List<User> users = new List<User>();
        if(!forecastOnly){
            users = [SELECT Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c FROM User WHERE UserRoleId = :roleId];
            
        }else{
            if(forecastingUsers == null){
                forecastingUsers = new Map<Id, List<User>>();
                for(User usr : [SELECT Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c FROM User WHERE ForecastEnabled__c=true]){
                    if(forecastingUsers.containsKey(usr.UserRoleId)){
                        forecastingUsers.get(usr.UserRoleId).add(usr);
                    }else{
                        forecastingUsers.put(usr.UserRoleId, new List<User> { usr });
                    }
                }
            }
            users = forecastingUsers.get(roleId);
            users = (users == null) ? new List<User>() : users;
        }for(User usr : users){
            result.add(new PerformanceDataModel.UserInfo(usr));
        }
        return result;
    }
    
    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<PerformanceDataModel.UserInfo> GetAllSubordinateUsers(String userId)
    {
        List<PerformanceDataModel.UserInfo> result = new List<PerformanceDataModel.UserInfo>();
        List<User> users = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0)
        {
            List<String> subRoles = getSubRoles(users[0].UserRoleId, true);
            for(User usr : [SELECT Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c FROM User WHERE UserRoleId in :subRoles and ForecastEnabled__c=true ])
            {
                result.add(new PerformanceDataModel.UserInfo(usr));
            }
        }
        return result;
    }
    
    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<PerformanceDataModel.UserInfo> GetAllSubordinateUsersWithLevel(String userId, string userLevel){
        set<string> userLevelSet = new set<string>();
        system.debug('# userLevel : '+userLevel);
        if(userLevel == 'All'){
            userLevelSet.add('VP');
            userLevelSet.add('Manager');
            userLevelSet.add('Rep');
        }else{
            userLevelSet.add(userLevel);
        }
        system.debug('# userLevel : '+userLevelSet);
        List<PerformanceDataModel.UserInfo> result = new List<PerformanceDataModel.UserInfo>();
        List<User> users = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :userId  LIMIT 1];
        if(users.size() > 0)
        {
            List<String> subRoles = getSubRoles(users[0].UserRoleId, true);
            for(User usr : [SELECT Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c FROM User WHERE UserRoleId in :subRoles and ForecastEnabled__c=true AND Level__c IN: userLevelSet AND Department != 'Customer Advocacy'])
            {
                result.add(new PerformanceDataModel.UserInfo(usr));
            }
        }
        system.debug('# result :'+result);
        return result;
    }
    
    public static List<Id> GetAllSubordinateUserIds(String userId){
        List<Id> result = new List<Id>();
        List<PerformanceDataModel.UserInfo> users = GetAllSubordinateUsers(userId);
        for(PerformanceDataModel.UserInfo user : users){
            result.add(user.UserId);
        }
        return result;
    }
    
    
    public static string getQtrString(Date fiscalDate, integer k){
       map<integer, String> qtrMap = new map<integer, String>(); 
       for(integer i = 1; i <=12; i++){
           if(i ==8 || i == 9 || i == 10){
               qtrMap.put(i, 'Q1');
           }else if(i ==11 || i == 12 || i == 1){
               qtrMap.put(i, 'Q2');
           }else if(i ==2 || i == 3 || i == 4){
               qtrMap.put(i, 'Q3');
           }else if (i ==5 || i == 6 || i == 7){
               qtrMap.put(i, 'Q4');
           }
       } 
       
       integer j = 0;
       if(fiscalDate.Month() > 7){
           j = 1;
       }
       
       if(k == 1)
           return ''+(fiscalDate.Year()+j) + qtrMap.get(fiscalDate.Month());
       else if(k == 2)
           return ''+qtrMap.get(fiscalDate.Month()+1)  + (fiscalDate.Year()+j);
       else
           return ''+(fiscalDate.Year()+j) +qtrMap.get(fiscalDate.Month());     
       
   
   }
    

}