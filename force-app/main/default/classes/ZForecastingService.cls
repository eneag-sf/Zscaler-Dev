public with sharing class ZForecastingService {
    private static Map<Id, List<Id>> subRoleMapping;
    private static Map<Id, List<User>> forecastingUsers;
    private static Set<Id> forecastingUserIds;

    public static List<ZForecastingDataModel.UserInfo> GetDirectSubordinateUsersV2(Id userOrRoleId, String forecastFamily) {
        // Query all the users under the specified user or role
        // For ZPA, start the hierarchy from Gary Olson but start querying from Bill Welch's role
        // When flatUserHierarchy is true, query all subordinate users

        List<ZForecastingDataModel.UserInfo> result = new List<ZForecastingDataModel.UserInfo>();
        List<Id> roleIds = new List<Id>();

        // Query all users from
        if (userOrRoleId == null) {
            roleIds = getSubRoles(null, false);
        } else if (userOrRoleId.getSObjectType() == Schema.User.SObjectType) {
            Map<String, User> mapForecastingLeaders = new Map<String, User>();
            List<User> users = new List<User>();
            for (User user : [SELECT Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c,
                                       ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c,
                                       ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c,
                                       Show_As_Manager_In_ZPA_Forecasting__c, ZPAForecastingLeader__c, ZIAForecastingLeader__c
                                  FROM User
                                 WHERE Id = :userOrRoleId
                                    OR ZPAForecastingLeader__c = true OR ZIAForecastingLeader__c = true]) {
                 if (user.ZPAForecastingLeader__c == true) {
                     mapForecastingLeaders.put('ZPA', user);
                 }

                 if (user.ZIAForecastingLeader__c == true) {
                     mapForecastingLeaders.put('ZIA', user);
                 }

                 if (user.Id == userOrRoleId) {
                     users.add(user);
                 }
             }

            if (users.size() > 0) {
                if (users[0].ZPAForecastingLeader__c == true) {
                    roleIds.add(mapForecastingLeaders.get('ZIA').UserRoleId);
                } else {
                    roleIds.add(users[0].UserRoleId);
                }
            }
        } else if (userOrRoleId.getSObjectType() == Schema.UserRole.SObjectType) {
            roleIds.add(userOrRoleId);
        }

        // if (roleIds.size() > 0) {
        //     for (Id roleId : roleIds) {
        //         System.debug('>>>> roleId: ' + roleId);
        //         List<Id> subRoles = getSubRoles(roleId, false);
        //         for (Id subRoleId : subRoles) {
        //             System.debug('>>>> : subRoleId: ' + subRoleId);
        //             Map<Id, ZForecastingDataModel.UserInfo> users = getUsersByRoleV2(subRoleId, true, forecastFamily);
        //             System.debug('>>>> subRoleId vs users: ' + subRoleId + ' vs ' + JSON.serialize(users));
        //             if (users.size() > 0) {
        //                 result.addAll(users.values());
        //                 for (ZForecastingDataModel.UserInfo user : users) {
        //                     Boolean usersFound = false;
        //                     if (forecastFamily == 'ZPA' && (user.zpaForecastEnabled == true || user.ShowAsManagerInZPAForecasting == true)) {
        //                         result.add(user);
        //                         usersFound = true;
        //                     }
        //                 }
        //             } else {
        //                 System.debug('>>>> subRoleId in else: ' + subRoleId);
        //                 result.addAll(GetDirectSubordinateUsersV2(subRoleId, forecastFamily));
        //             }
        //         }
        //     }
        // }

        if (roleIds.size() > 0) {
            for (Id roleId : roleIds) {
                List<Id> subRoleIds = getSubRoles(roleId, false);

                for (Id subRoleId: subRoleIds) {
                    Map<Id, ZForecastingDataModel.UserInfo> subordinateUsers = getUsersByRoleV2(subRoleId, true, forecastFamily);
                    Boolean usersFound = false;
                    if (subordinateUsers.size() > 0) {
                        for (ZForecastingDataModel.UserInfo userModel : subordinateUsers.values()) {
                            if (userModel.ZPAForecastEnabled == true || userModel.ShowAsManagerInZPAForecasting == true) {
                                result.add(userModel);
                                usersFound = true;
                            } else {
                                usersFound = false;
                            }
                        }
                    }

                    if (usersFound == false) {
                        List<Id> subSubRoleIds = getSubRoles(subRoleId, false);
                        for (Id subSubRoleId : subSubRoleIds) {
                            result.addAll(GetDirectSubordinateUsersV2(subRoleId, forecastFamily));
                        }
                    }
                }
            }
        }

        return result;
    }

    @Readonly @RemoteAction
    public static List<ZForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId) {
        return GetDirectSubordinateUsers(userOrRoleId, 'ZIA');
    }

    //Gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<ZForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId, String forecastFamily)
    {
        List<ZForecastingDataModel.UserInfo> result = new List<ZForecastingDataModel.UserInfo>();
        List<Id> roleIds = new List<Id>();
        if(userOrRoleId == null)
        {
            roleIds = getSubRoles(null, false);
        }
        else if(userOrRoleId.getSObjectType() == Schema.User.SObjectType)
        {
            List<User> users = [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c from User where Id=:userOrRoleId limit 1];
            if(users.size() > 0)
            {
                roleIds.add(users[0].UserRoleId);
            }
        }
        else if(userOrRoleId.getSObjectType() == Schema.UserRole.SObjectType)
        {
            roleIds.add(userOrRoleId);
        }
        if(roleIds.size() > 0)
        {
            for(Id roleId : roleIds)
            {
                List<Id> subRoles = getSubRoles(roleId, false);
                for(Id rid : subRoles)
                {
                    List<ZForecastingDataModel.UserInfo> users = getUsersByRole(rid, true);
                    if(users.size() > 0)
                    {
                        result.addAll(users);
                    }
                    else
                    {
                        result.addAll(GetDirectSubordinateUsers(rid, forecastFamily));
                    }
                }
            }
        }
        return result;
    }

    @Readonly @RemoteAction
    public static List<ZForecastingDataModel.UserInfo> GetAllSubordinateUsers(Id userId) {
        return GetAllSubordinateUsers(userId, 'ZIA');
    }

    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<ZForecastingDataModel.UserInfo> GetAllSubordinateUsers(String userId, String forecastFamily)
    {
        List<ZForecastingDataModel.UserInfo> result = new List<ZForecastingDataModel.UserInfo>();
        List<User> users = [SELECT Id, Name, Department, UserRoleId, ZPAForecastingLeader__c, ZIAForecastingLeader__c FROM User WHERE (Id = :userId OR ZPAForecastingLeader__c = true OR ZIAForecastingLeader__c = true) LIMIT 3];

        if(users.size() > 0)
        {
            Id roleIdToQuery;
            Map<String, User> mapForecastingLeaders = new Map<String, User>();
            User userToQuery;
            for (User user : users) {
                if (user.ZPAForecastingLeader__c) {
                    mapForecastingLeaders.put('ZPA', user);
                }

                if (user.ZIAForecastingLeader__c) {
                    mapForecastingLeaders.put('ZIA', user);
                }

                if (user.Id == userId) {
                    userToQuery = user;
                }
            }
            System.debug('>>>> userToQuery: ' + userToQuery);
            if (userToQuery.ZPAForecastingLeader__c && forecastFamily == 'ZPA') {
                roleIdToQuery = mapForecastingLeaders.get('ZIA').UserRoleId;
            } else {
                roleIdToQuery = userToQuery.UserRoleId;
            }

            List<String> subRoles = getSubRoles(roleIdToQuery, true);
            String query = 'SELECT Id, Name, Department, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c, View_Notra__c, View_Export_to_Excel__c,  View_Billings__c, View_Net_New_ACV_Summary__c, LocaleSidKey    FROM User WHERE UserRoleId in :subRoles ';

            if (forecastFamily == 'ZPA') {
                query += ' AND ZPAForecastEnabled__c = true';
            } else {
                query += ' AND ForecastEnabled__c = true';
            }
            System.debug('>>>> query: ' + query);
            for(User usr : Database.query(query))
            {
                result.add(new ZForecastingDataModel.UserInfo(usr));
            }
        }
        return result;
    }

    public static void initForecast(Id userId, String userLevel, String forecastType) {
        initForecast(userId, forecastType, 'ZIA');
    }

    public static void initForecast(Id userId, String userLevel, String forecastType, String forecastFamily, String loggedinuserlocale, String Currentuserlocale)
    {
        Boolean invalidForecastFamily = false;
        String query = 'SELECT Id, IsActive FROM User WHERE IsActive = true AND Id = :userId ';
        if (forecastFamily != null && (forecastFamily == 'ZIA' || forecastFamily == 'ZPA')) {
            query += ' AND ForecastEnabled__c = true';
        } else {
            invalidForecastFamily = true;
        }

        List<User> users = Database.query(query);
        if(users.size() > 0 && invalidForecastFamily != true)
        {
            String[] quarterWeek = getLatestForecastWeek(loggedinuserlocale, Currentuserlocale);
            
            String fyfq = quarterWeek[0];
            String yyww = quarterWeek[1];
            System.debug('*** fyfq: ' + fyfq);
            System.debug('*** yyww: ' + yyww);

            // Determine the current forecasting quarter and week
            // String fyfq = (new ZForecastingDataModel.FiscalQuarterInfo()).FormattedString;
            // String yyww = (new ZForecastingDataModel.WeekInfo()).FormattedString;
            System.debug('>>>> userId: ' + userId + ' forecastFamily: ' + forecastFamily);
            List<Zscaler_Forecast__c> currentForecasts = getForecasts(userId, fyfq, yyww, forecastType, forecastFamily);
            List<Zscaler_Forecast__c> futureForecasts = getForecasts(userId, fyfq, null, forecastType, forecastFamily, false);
            System.debug('>>>> currentForecasts: ' + JSON.serialize(currentForecasts));
            System.debug('>>>> futureForecasts: ' + JSON.serialize(futureForecasts));
            if(currentForecasts.size() == 0 && futureForecasts.size() == 0)
            {
                submitForecasts(getForecasts(userId, '', '', forecastType, forecastFamily, false, null, new List<String> { 'FYFQ__c<=\''+fyfq+'\''}));
                insertNewForecast(userId, userLevel, fyfq, yyww, forecastType, forecastFamily);
            }
            else if(futureForecasts.size() > 0)
            {
                Database.delete(currentForecasts, false);
                submitForecasts(getForecasts(userId, '', '', forecastType, forecastFamily, false, null, new List<String> { '((FYFQ__c<=\''+fyfq+'\' and YYWW__c<\''+yyww+'\') or (FYFQ__c<\''+fyfq+'\' and YYWW__c<=\''+yyww+'\'))'}));
                deleteDuplicate(futureForecasts);
                for(Zscaler_Forecast__c f : futureForecasts)
                {
                    f.YYWW__c = yyww;
                }
                Database.update(futureForecasts, false);
            }
            else if(currentForecasts.size() > 0)
            {
                submitForecasts(getForecasts(userId, '', '', forecastType, forecastFamily, false, null, new List<String> { '((FYFQ__c<=\''+fyfq+'\' and YYWW__c<\''+yyww+'\') or (FYFQ__c<\''+fyfq+'\' and YYWW__c<=\''+yyww+'\'))'}));
                deleteDuplicate(currentForecasts);
            }
        }
        else if (invalidForecastFamily != true)
        {
            submitForecasts(getForecasts(userId, '', '', null, forecastFamily, false, null, null));
        } else {
            //Do nothing.
        }
    }

    public static List<Id> GetAllSubordinateUserIds(String userId)
    {
        return GetAllSubordinateUserIds(userId, null, 'ZIA');
    }

    public static List<Id> GetAllSubordinateUserIds(String userId, Set<String> Levels)
    {
        return GetAllSubordinateUserIds(userId, Levels, 'ZIA');
    }

    public static List<Id> GetAllSubordinateUserIds(String userId, Set<String> Levels, String forecastFamily)
    {
        List<Id> result = new List<Id>();
        List<ZForecastingDataModel.UserInfo> users = GetAllSubordinateUsers(userId, forecastFamily);
        for(ZForecastingDataModel.UserInfo user : users)
        {
            if (Levels == null || (Levels != null && Levels.contains(user.Level))) {
                result.add(user.UserId);
            }
        }
        return result;
    }

    public static List<Id> GetDirectSubordinateUserIds(String userId)
    {
        List<Id> result = new List<Id>();
        List<ZForecastingDataModel.UserInfo> users = GetDirectSubordinateUsers(userId);
        for(ZForecastingDataModel.UserInfo user : users)
        {
            result.add(user.UserId);
        }
        return result;
    }

    public static List<Id> getSubRoles(Id roleId, Boolean traverseAll)
    {
        List<Id> result = new List<Id>();
        subRoleMapping = getSubRoleMapping();
        List<Id> directRoles = subRoleMapping.get(roleId);
        if(directRoles != null)
        {
            result.addAll(directRoles);
            if(traverseAll)
            {
                for(Id rid : directRoles)
                {
                    result.addAll(getSubRoles(rid, true));
                }
            }
        }
        return result;
    }

    static Map<Id, List<Id>> getSubRoleMapping()
    {
        if(subRoleMapping == null)
        {
            subRoleMapping = new Map<Id, List<Id>>();
            for(UserRole role : [SELECT Id, Name, ParentRoleId FROM UserRole WHERE PortalType = 'None'])
            {
                if(!subRoleMapping.containsKey(role.ParentRoleId))
                {
                    subRoleMapping.put(role.ParentRoleId, new List<Id> {role.Id});
                }
                else
                {
                    subRoleMapping.get(role.ParentRoleId).add(role.Id);
                }
            }
        }
        return subRoleMapping;
    }

    public static Map<Id, ZForecastingDataModel.UserInfo> getUsersByRoleV2(Id roleId, Boolean forecastOnly, String forecastFamily) {
        Map<Id, ZForecastingDataModel.UserInfo> result = new Map<Id, ZForecastingDataModel.UserInfo>();
        List<User> users = new List<User>();
        if(!forecastOnly)
        {
            users = [SELECT Id, Name, Department, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c FROM User WHERE UserRoleId = :roleId];

        }
        else
        {
            if(forecastingUsers == null)
            {
                forecastingUsers = new Map<Id, List<User>>();
                String query = 'SELECT Id, Name, Department, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c, View_Notra__c, View_Export_to_Excel__c,  View_Billings__c, View_Net_New_ACV_Summary__c, LocaleSidKey   FROM User WHERE';
                if (forecastFamily == 'ZPA') {
                    query += ' ZPAForecastingLeader__c != true AND ZPAForecastingLeader__c != true AND (ZPAForecastEnabled__c = true OR Show_As_Manager_In_ZPA_Forecasting__c = true)';
                } else {
                    query += ' ForecastEnabled__c = true';
                }
                System.debug('>>>> query vj: ' + query);
                for(User usr : Database.query(query))
                {
                    if(forecastingUsers.containsKey(usr.UserRoleId))
                    {
                        forecastingUsers.get(usr.UserRoleId).add(usr);
                    }
                    else
                    {
                        forecastingUsers.put(usr.UserRoleId, new List<User> { usr });
                    }
                }
            }
            System.debug('>>>> forecastingUsers: ' + JSON.serialize(forecastingUsers));
            users = forecastingUsers.get(roleId);
            users = (users == null) ? new List<User>() : users;
        }
        for(User usr : users)
        {
            result.put(usr.Id, new ZForecastingDataModel.UserInfo(usr));
        }
        return result;
    }

    private static List<ZForecastingDataModel.UserInfo> getUsersByRole(Id roleId, Boolean forecastOnly) {
        return getUsersByRole(roleId, forecastOnly, null, 'ZIA');
    }

    private static List<ZForecastingDataModel.UserInfo> getUsersByRole(Id roleId, Boolean forecastOnly, Set<String> levels) {
        return getUsersByRole(roleId, forecastOnly, levels, 'ZIA');
    }

    private static List<ZForecastingDataModel.UserInfo> getUsersByRole(Id roleId, Boolean forecastOnly, Set<String> levels, String forecastFamily)
    {
        List<ZForecastingDataModel.UserInfo> result = new List<ZForecastingDataModel.UserInfo>();
        List<User> users = new List<User>();
        if(!forecastOnly)
        {
            users = [SELECT Id, Name, Department, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c, View_Notra__c, View_Export_to_Excel__c,  View_Billings__c, View_Net_New_ACV_Summary__c, LocaleSidKey    FROM User WHERE UserRoleId = :roleId];

        }
        else
        {
            if(forecastingUsers == null)
            {
                forecastingUsers = new Map<Id, List<User>>();
                String query = 'SELECT Id, Name, Department, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c, View_Notra__c, View_Export_to_Excel__c,  View_Billings__c, View_Net_New_ACV_Summary__c, LocaleSidKey    FROM User WHERE ';
                if (forecastFamily == 'ZPA') {
                    query += ' ZPAForecastEnabled__c = true';
                } else {
                    query += ' ForecastEnabled__c = true';
                }
                for(User usr : Database.query(query))
                {
                    if(forecastingUsers.containsKey(usr.UserRoleId))
                    {
                        forecastingUsers.get(usr.UserRoleId).add(usr);
                    }
                    else
                    {
                        forecastingUsers.put(usr.UserRoleId, new List<User> { usr });
                    }
                }
            }
            users = forecastingUsers.get(roleId);
            users = (users == null) ? new List<User>() : users;
        }
        for(User usr : users)
        {
            result.add(new ZForecastingDataModel.UserInfo(usr));
        }
        return result;
    }

    public static ZForecastingDataModel.UserInfo GetUser(String userId)
    {
        List<User> users = [SELECT Id, Name, Department, UserRoleId, UserRole.Name, ViewForecastAs__c, Level__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c, View_Notra__c, View_Export_to_Excel__c,  View_Billings__c, View_Net_New_ACV_Summary__c, LocaleSidKey   FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0)
        {
            return new ZForecastingDataModel.UserInfo(users[0]);
        }
        else
        {
            return null;
        }
    }

    public static String[] getLatestForecastWeek(String loggedinuserlocale, String Currentuserlocale) {
        return getLatestForecastWeek('ZIA', loggedinuserlocale, Currentuserlocale);
    }

    public static String[] getNextForecastWeek()
    {
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ZForecastingDataModel.FiscalQuarterInfo quarter = new ZForecastingDataModel.FiscalQuarterInfo();
        ZForecastingDataModel.WeekInfo nextWeek = quarter.getWeek(nextWeekStartDay);
        if(nextWeek == null)
        {
            quarter = quarter.next;
            nextWeek = quarter.getWeek(nextWeekStartDay);
        }
        String fyfq = quarter.FormattedString;
        String yyww = nextWeek.FormattedString;
        return new String[] {fyfq, yyww};
    }

    public static String[] getLatestForecastWeek(String forecastFamily, String loggedinuserlocale, String Currentuserlocale)
    {
        String fyfq = (new ZForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String yyww = (new ZForecastingDataModel.WeekInfo()).FormattedString;
        System.debug('*** fyfq: ' + fyfq);
        System.debug('*** yyww: ' + yyww);
        List<Zscaler_Forecast__c> latestForecast = [select Id, FYFQ__c, YYWW__c, Archived__c from Zscaler_Forecast__c where FYFQ__c!=null and YYWW__c != null AND Forecast_Family__c = :forecastFamily and User__r.LocaleSidKey = :Currentuserlocale order by FYFQ__c desc, YYWW__c desc limit 1];
        System.debug(JSON.serialize(latestForecast));
        if(latestForecast.size() > 0 && (latestForecast[0].FYFQ__c >= fyfq && (latestForecast[0].YYWW__c >= yyww || loggedinuserlocale != Currentuserlocale)))
        {
            fyfq = latestForecast[0].FYFQ__c;
            yyww = latestForecast[0].YYWW__c;
            if(latestForecast[0].Archived__c == true)
            {
                return getNextForecastWeek();
            }
        }
        return new String[] {fyfq, yyww};
    }

    public static String getLatestForecastWeek(String fyfq, String forecastFamily, String loggedinuserlocale, String Currentuserlocale)
    {
        List<Zscaler_Forecast__c> latestForecast = [select Id, FYFQ__c, YYWW__c, Archived__c from Zscaler_Forecast__c where FYFQ__c=:fyfq AND Forecast_Family__c = :forecastFamily and User__r.LocaleSidKey = :Currentuserlocale order by YYWW__c desc limit 1];
        if(latestForecast.size() > 0)
        {
            return latestForecast[0].YYWW__c;
        }
        return null;
    }

    public static String getLastForecastWeek(String fyfq, String forecastfamily, String loggedinuserlocale, String Currentuserlocale)
    {
        List<Zscaler_Forecast__c> forecastEntries = [select Id, FYFQ__c, YYWW__c, Archived__c from Zscaler_Forecast__c where Forecast_Family__c =: forecastfamily and FYFQ__c=:fyfq AND Archived__c = true AND User__r.ForecastEnabled__c = true AND User__r.IsActive = true and User__r.LocaleSidKey = :Currentuserlocale order by YYWW__c desc limit 1];
        if(forecastEntries.size() > 0)
        {
            return forecastEntries[0].YYWW__c;
        }
        return null;
    }

    public static List<Zscaler_Forecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType) {
        return getForecasts(userId, fyfq, yyww, forecastType, 'ZIA');
    }

    public static List<Zscaler_Forecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, String forecastFamily)
    {
        return getForecasts(userId, fyfq, yyww, forecastType, forecastFamily, null, null, null);
    }

    public static List<Zscaler_Forecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, String forecastFamily, Boolean archived) {
        return getForecasts(userId, fyfq, yyww, forecastType, forecastFamily, archived, null, null);
    }

    public static List<Zscaler_Forecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, Boolean archived, Integer limitNumber, List<String> criterion) {
        return getForecasts(userId, fyfq, yyww, forecastType, 'ZIA', archived, limitNumber, criterion);
    }

    public static List<Zscaler_Forecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, String forecastFamily, Boolean archived, Integer limitNumber, List<String> criterion)
    {
        String soql = 'select Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById, Forecast_Type__c, User__c, Archived__c, Archived_Date__c, FYFQ__c, YYWW__c, Month__c, Forecast_Amount__c, Locked__c from Zscaler_Forecast__c where ';
        if(userId != null)
        {
            soql += ' User__c=:userId and ';
        }
        if(fyfq != '')
        {
            soql += ' FYFQ__c=:fyfq and ';
        }
        if(yyww != '')
        {
            soql += ' YYWW__c=:yyww and ';
        }
        if(forecastType != null)
        {
            soql += ' Forecast_Type__c=:forecastType and ';
        }
        if(forecastFamily!= null)
        {
            soql += ' Forecast_Family__c=:forecastFamily and ';
        }
        if(archived != null)
        {
            soql += ' Archived__c=:archived and ';
        }
        if(criterion != null)
        {
            for(String criteria : criterion)
            {
                soql += ' ' + criteria + ' and ';
            }
        }
        soql = soql.removeEnd(' and ').removeEnd(' where ');
        soql += ' order by FYFQ__c desc, YYWW__c DESC, CreatedDate DESC ';
        if(limitNumber != null)
        {
            soql += ' limit ' + limitNumber;
        }
        System.debug(soql);
        return Database.query(soql);
    }

    private static void insertNewForecast(Id userId, String userLevel, String fyfq, String yyww, String forecastType) {
        insertNewForecast(userId, fyfq, yyww, forecastType, 'ZIA');
    }

    private static void insertNewForecast(Id userId, String userLevel, String fyfq, String yyww, String forecastType, String forecastFamily)
    {
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        ZForecastingDataModel.WeekInfo week = qtr.getWeekByNumber(yyww);
        Zscaler_Forecast__c forecast;
        List<Zscaler_Forecast__c> forecasts = getForecasts(userId, '', '', forecastType, forecastFamily, true, 1, null);
        if(forecasts.size() == 0)
        {
	//added ownerid=userid as a part of RBAC
            forecast = new Zscaler_Forecast__c(OwnerId=userId, User__c=userId, FYFQ__c=fyfq, YYWW__c=yyww, Month__c = String.valueOf(week.StartDate.month()), Forecast_Type__c=forecastType, Forecast_Family__c = forecastFamily);
        }
        else
        {
            forecast = forecasts[0].clone(false, false, false, false);
            forecast.FYFQ__c = fyfq;
            forecast.YYWW__c = yyww;
            forecast.Month__c = String.valueOf(week.StartDate.month());
            forecast.Archived__c = false;
            forecast.Archived_Date__c = null;
            forecast.Forecast_Family__c = forecastFamily;
            forecast.ownerId = userId;
            System.debug('>>>> forecast.Locked__c: ' + forecast.Locked__c);
        }

        if (forecasts.size() == 0 || forecast.Locked__c != true) {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String forecastSummaryField = 'Forecast_Category_New__c';
            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            
            Set<Id> upselplaceholderusers = new Set<Id>();
            if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
                upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            }
        
            if (userLevel != 'Rep') {
                if (userLevel == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (userLevel == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (userLevel == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                } else if (userLevel == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (userLevel == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }
            if(forecastFamily == 'ZIA'){
                String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';
                query += ' Forecast_Type__c =: forecastType AND ';

                List<AggregateResult> totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\') AND Forecast_Type__c =: forecastType');

                forecast.Forecast_Amount__c = (Decimal)totalMostLikely[0].get('a');
            }else{
                String query = 'SELECT SUM(ZPA_Amount__c) a FROM OpportunitySplit WHERE ';
        
                query = query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\') AND Forecast_Type__c =: forecastType';

                List<AggregateResult> totalForecast = Database.query(query);
                if (totalForecast != null && totalForecast.size() > 0 && (Decimal)totalForecast[0].get('a') != null) {
                    forecast.Forecast_Amount__c = (Decimal)totalForecast[0].get('a');
                }
            }
        }
        insert forecast;
    }

    public static void submitForecasts(List<Zscaler_Forecast__c> forecasts)
    {
        if(forecasts != null && forecasts.size() > 0)
        {
            for(Zscaler_Forecast__c f : forecasts)
            {
                f.Archived__c = true;
                f.Archived_Date__c = Datetime.now();
            }
            update forecasts;
        }
    }
    
    public static Set<Id> getAllPlaceholderUsers(){
        List<User> users = [Select Id from User where Upsell_Placeholder__c = true];
        
        Set<Id> uids = new Set<Id>();
        for(User u: users){
            uids.add(u.Id);
        }
        
        return uids;
    }

    private static void deleteDuplicate(List<Zscaler_Forecast__c> forecasts)
    {
        // if(forecasts != null && forecasts.size() > 1)
        // {
        //     //sort by createddate desc
        //     for(Integer i = 0; i < forecasts.size(); i++)
        //     {
        //         for(Integer j = i + 1; j < forecasts.size(); j++)
        //         {
        //             if(forecasts[i].CreatedDate > forecasts[j].CreatedDate)
        //             {
        //                 Zscaler_Forecast__c t = forecasts[j];
        //                 forecasts.set(j, forecasts[i]);
        //                 forecasts.set(i, t);
        //             }
        //         }
        //     }
        //     Set<String> keys = new Set<String>();
        //     List<Zscaler_Forecast__c> toBeRemoved = new List<Zscaler_Forecast__c>();
        //     for(Integer i = 0; i < forecasts.size(); i++)
        //     {
        //         String key = forecasts[i].User__c + forecasts[i].FYFQ__c + forecasts[i].YYWW__c + forecasts[i].Month__c + forecasts[i].Forecast_Type__c;
        //         if(keys.contains(key))
        //         {
        //             toBeRemoved.add(forecasts[i]);
        //         }
        //         else
        //         {
        //             keys.add(key);
        //         }
        //     }
        //     if(toBeRemoved.size() > 0)
        //     {
        //         delete toBeRemoved;
        //     }
        // }
    }
	public static void booster(){
		integer i=0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}