/**
 * This class contains remote actions of Forecasting page.
 */

public class ForecastingService
{
    private static Map<Id, List<Id>> subRoleMapping;
    private static Map<Id, List<User>> forecastingUsers;
    private static Set<Id> forecastingUserIds;

    public static List<ForecastingDataModel.UserInfo> GetDirectSubordinateUsersV2(Id userOrRoleId, String forecastFamily) {
        // Query all the users under the specified user or role
        // For ZPA, start the hierarchy from Gary Olson but start querying from Bill Welch's role
        // When flatUserHierarchy is true, query all subordinate users

        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        List<Id> roleIds = new List<Id>();

        // Query all users from
        if (userOrRoleId == null) {
            roleIds = getSubRoles(null, false);
        } else if (userOrRoleId.getSObjectType() == Schema.User.SObjectType) {
            Map<String, User> mapForecastingLeaders = new Map<String, User>();
            List<User> users = new List<User>();
            for (User user : [SELECT Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c,
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
        //             Map<Id, ForecastingDataModel.UserInfo> users = getUsersByRoleV2(subRoleId, true, forecastFamily);
        //             System.debug('>>>> subRoleId vs users: ' + subRoleId + ' vs ' + JSON.serialize(users));
        //             if (users.size() > 0) {
        //                 result.addAll(users.values());
        //                 for (ForecastingDataModel.UserInfo user : users) {
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
                    Map<Id, ForecastingDataModel.UserInfo> subordinateUsers = getUsersByRoleV2(subRoleId, true, forecastFamily);
                    Boolean usersFound = false;
                    if (subordinateUsers.size() > 0) {
                        for (ForecastingDataModel.UserInfo userModel : subordinateUsers.values()) {
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
    public static List<ForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId) {
        return GetDirectSubordinateUsers(userOrRoleId, 'ZIA');
    }

    //Gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId, String forecastFamily)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        List<Id> roleIds = new List<Id>();
        if(userOrRoleId == null)
        {
            roleIds = getSubRoles(null, false);
        }
        else if(userOrRoleId.getSObjectType() == Schema.User.SObjectType)
        {
            List<User> users = [select Id, Name, UserRoleId, UserRole.Name, Level__c, ViewForecastAs__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c from User where Id=:userOrRoleId limit 1];
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
                    List<ForecastingDataModel.UserInfo> users = getUsersByRole(rid, true);
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
    public static List<ForecastingDataModel.UserInfo> GetAllSubordinateUsers(Id userId) {
        return GetAllSubordinateUsers(userId, 'ZIA');
    }

    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetAllSubordinateUsers(String userId, String forecastFamily)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        List<User> users = [SELECT Id, Name, UserRoleId, ZPAForecastingLeader__c, ZIAForecastingLeader__c FROM User WHERE (Id = :userId OR ZPAForecastingLeader__c = true OR ZIAForecastingLeader__c = true) LIMIT 3];

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
            if (userToQuery != null && userToQuery.ZPAForecastingLeader__c && forecastFamily == 'ZPA') {
                roleIdToQuery = mapForecastingLeaders.get('ZIA').UserRoleId;
            } else if(userToQuery != null) {
                roleIdToQuery = userToQuery.UserRoleId;
            }

            List<String> subRoles = getSubRoles(roleIdToQuery, true);
            String query = 'SELECT Id, Name, UserRoleId, UserRole.Name, Level__c, ViewForecastAs__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c  FROM User WHERE UserRoleId in :subRoles ';

            if (forecastFamily == 'ZPA') {
                query += ' AND ZPAForecastEnabled__c = true';
            } else {
                query += ' AND ForecastEnabled__c = true';
            }
            System.debug('>>>> query: ' + query);
            for(User usr : Database.query(query))
            {
                result.add(new ForecastingDataModel.UserInfo(usr));
            }
        }
        return result;
    }

    public static void initForecast(Id userId, String forecastType) {
        initForecast(userId, forecastType, 'ZIA');
    }

    public static void initForecast(Id userId, String forecastType, String forecastFamily)
    {
        Boolean invalidForecastFamily = false;
        String query = 'SELECT Id, IsActive FROM User WHERE IsActive = true AND Id = :userId ';
        if (forecastFamily != null && forecastFamily == 'ZPA') {
            query += ' AND ZPAForecastEnabled__c = true';
        } else if (forecastFamily != null && forecastFamily == 'ZIA') {
            query += ' AND ForecastEnabled__c = true';
        } else {
            invalidForecastFamily = true;
        }

        List<User> users = Database.query(query);
        if(users.size() > 0 && invalidForecastFamily != true)
        {
            String[] quarterWeek = getLatestForecastWeek(forecastFamily);
            String fyfq = quarterWeek[0];
            String yyww = quarterWeek[1];
            System.debug('>>>> userId: ' + userId + ' forecastFamily: ' + forecastFamily);
            List<CustomForecast__c> currentForecasts = getForecasts(userId, fyfq, yyww, forecastType, forecastFamily);
            List<CustomForecast__c> futureForecasts = getForecasts(userId, fyfq, null, forecastType, forecastFamily, false);
            if(currentForecasts.size() == 0 && futureForecasts.size() == 0)
            {
                submitForecasts(getForecasts(userId, '', '', forecastType, forecastFamily, false, null, new List<String> { 'FYFQ__c<=\''+fyfq+'\''}));
                insertNewForecast(userId, fyfq, yyww, forecastType, forecastFamily);
            }
            else if(futureForecasts.size() > 0)
            {
                Database.delete(currentForecasts, false);
                submitForecasts(getForecasts(userId, '', '', forecastType, forecastFamily, false, null, new List<String> { '((FYFQ__c<=\''+fyfq+'\' and YYWW__c<\''+yyww+'\') or (FYFQ__c<\''+fyfq+'\' and YYWW__c<=\''+yyww+'\'))'}));
                ForecastingService.deleteDuplicate(futureForecasts);
                for(CustomForecast__c f : futureForecasts)
                {
                    f.YYWW__c = yyww;
                }
                Database.update(futureForecasts, false);
            }
            else if(currentForecasts.size() > 0)
            {
                submitForecasts(getForecasts(userId, '', '', forecastType, forecastFamily, false, null, new List<String> { '((FYFQ__c<=\''+fyfq+'\' and YYWW__c<\''+yyww+'\') or (FYFQ__c<\''+fyfq+'\' and YYWW__c<=\''+yyww+'\'))'}));
                ForecastingService.deleteDuplicate(currentForecasts);
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
        return GetAllSubordinateUserIds(userId, 'ZIA');
    }

    public static List<Id> GetAllSubordinateUserIds(String userId, String forecastFamily)
    {
        List<Id> result = new List<Id>();
        List<ForecastingDataModel.UserInfo> users = GetAllSubordinateUsers(userId, forecastFamily);
        for(ForecastingDataModel.UserInfo user : users)
        {
            result.add(user.UserId);
        }
        return result;
    }

    public static List<Id> GetDirectSubordinateUserIds(String userId)
    {
        List<Id> result = new List<Id>();
        List<ForecastingDataModel.UserInfo> users = GetDirectSubordinateUsers(userId);
        for(ForecastingDataModel.UserInfo user : users)
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

    public static Map<Id, ForecastingDataModel.UserInfo> getUsersByRoleV2(Id roleId, Boolean forecastOnly, String forecastFamily) {
        Map<Id, ForecastingDataModel.UserInfo> result = new Map<Id, ForecastingDataModel.UserInfo>();
        List<User> users = new List<User>();
        if(!forecastOnly)
        {
            users = [SELECT Id, Name, UserRoleId, UserRole.Name, Level__c, ViewForecastAs__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c FROM User WHERE UserRoleId = :roleId];

        }
        else
        {
            if(forecastingUsers == null)
            {
                forecastingUsers = new Map<Id, List<User>>();
                String query = 'SELECT Id, Name, UserRoleId, UserRole.Name, Level__c, ViewForecastAs__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c  FROM User WHERE';
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
            result.put(usr.Id, new ForecastingDataModel.UserInfo(usr));
        }
        return result;
    }

    private static List<ForecastingDataModel.UserInfo> getUsersByRole(Id roleId, Boolean forecastOnly) {
        return getUsersByRole(roleId, forecastOnly, 'ZIA');
    }

    private static List<ForecastingDataModel.UserInfo> getUsersByRole(Id roleId, Boolean forecastOnly, String forecastFamily)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        List<User> users = new List<User>();
        if(!forecastOnly)
        {
            users = [SELECT Id, Name, UserRoleId, UserRole.Name, Level__c, ViewForecastAs__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c  FROM User WHERE UserRoleId = :roleId];

        }
        else
        {
            if(forecastingUsers == null)
            {
                forecastingUsers = new Map<Id, List<User>>();
                String query = 'SELECT Id, Name, UserRoleId, UserRole.Name, Level__c, ViewForecastAs__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c  FROM User WHERE ';
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
            result.add(new ForecastingDataModel.UserInfo(usr));
        }
        return result;
    }

    public static ForecastingDataModel.UserInfo GetUser(String userId)
    {
        List<User> users = [SELECT Id, Name, UserRoleId, UserRole.Name, Level__c, ViewForecastAs__c, ForecastEnabled__c, ViewForecastAs__r.Name, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, DefaultForecastFamily__c, Show_As_Manager_In_ZPA_Forecasting__c, Forecast_Inline_Editing__c FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0)
        {
            return new ForecastingDataModel.UserInfo(users[0]);
        }
        else
        {
            return null;
        }
    }

    public static String[] getLatestForecastWeek() {
        return getLatestForecastWeek('ZIA');
    }

    public static String[] getLatestForecastWeek(String forecastFamily)
    {
        String fyfq = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String yyww = (new ForecastingDataModel.WeekInfo()).FormattedString;
        List<CustomForecast__c> latestForecast = [select Id, FYFQ__c, YYWW__c, Locked__c from CustomForecast__c where FYFQ__c!=null and YYWW__c != null AND Forecast_Family__c = :forecastFamily order by FYFQ__c desc, YYWW__c desc limit 1];
        if(latestForecast.size() > 0 && latestForecast[0].FYFQ__c >= fyfq && latestForecast[0].YYWW__c >= yyww)
        {
            fyfq = latestForecast[0].FYFQ__c;
            yyww = latestForecast[0].YYWW__c;
            if(latestForecast[0].Locked__c == true)
            {
                return getNextForecastWeek();
            }
        }
        return new String[] {fyfq, yyww};
    }

    public static String getLatestForecastWeek(String fyfq, String forecastFamily)
    {
        List<CustomForecast__c> latestForecast = [select Id, FYFQ__c, YYWW__c, Locked__c from CustomForecast__c where FYFQ__c=:fyfq AND Forecast_Family__c = :forecastFamily order by YYWW__c desc limit 1];
        if(latestForecast.size() > 0)
        {
            return latestForecast[0].YYWW__c;
        }
        return null;
    }

    public static List<CustomForecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType) {
        return getForecasts(userId, fyfq, yyww, forecastType, 'ZIA');
    }

    public static List<CustomForecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, String forecastFamily)
    {
        return getForecasts(userId, fyfq, yyww, forecastType, forecastFamily, null, null, null);
    }

    public static List<CustomForecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, String forecastFamily, Boolean locked) {
        return getForecasts(userId, fyfq, yyww, forecastType, forecastFamily, locked, null, null);
    }

    public static List<CustomForecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, Boolean locked, Integer limitNumber, List<String> criterion) {
        return getForecasts(userId, fyfq, yyww, forecastType, 'ZIA', locked, limitNumber, criterion);
    }

    public static List<CustomForecast__c> getForecasts(Id userId, String fyfq, String yyww, String forecastType, String forecastFamily, Boolean locked, Integer limitNumber, List<String> criterion)
    {
        String soql = 'select Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById, ForecastType__c, Forecast_Family__c, User__c, LastEdited__c, Locked__c, FYFQ__c, YYWW__c, MonthCommit__c, QuarterCommit__c, QuarterPipeline__c, QuarterUpside__c, WeekCommit__c from CustomForecast__c where ';
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
            soql += ' ForecastType__c=:forecastType and ';
        }
        if (forecastFamily != null) {
            soql += ' Forecast_Family__c = :forecastFamily and ';
        }
        if(locked != null)
        {
            soql += ' Locked__c=:locked and ';
        }
        if(criterion != null)
        {
            for(String criteria : criterion)
            {
                soql += ' ' + criteria + ' and ';
            }
        }
        soql = soql.removeEnd(' and ').removeEnd(' where ');
        soql += ' order by CreatedDate desc';
        if(limitNumber != null)
        {
            soql += ' limit ' + limitNumber;
        }
        System.debug(soql);
        return Database.query(soql);
    }

    private static void insertNewForecast(Id userId, String fyfq, String yyww, String forecastType) {
        insertNewForecast(userId, fyfq, yyww, forecastType, 'ZIA');
    }

    private static void insertNewForecast(Id userId, String fyfq, String yyww, String forecastType, String forecastFamily)
    {
        List<CustomForecast__c> forecasts = getForecasts(userId, '', '', forecastType, forecastFamily, true, 1, null);
        if(forecasts.size() == 0)
        {
            insert new CustomForecast__c(User__c=userId, FYFQ__c=fyfq, YYWW__c=yyww, ForecastType__c=forecastType, Forecast_Family__c = forecastFamily);
        }
        else
        {
            CustomForecast__c forecast = forecasts[0].clone(false, false, false, false);
            forecast.FYFQ__c = fyfq;
            forecast.YYWW__c = yyww;
            forecast.Locked__c = false;
            forecast.LastEdited__c = DateTime.now();
            forecast.SubmittedOn__c = null;
            forecast.Forecast_Family__c = forecastFamily;
            insert forecast;
        }
    }

    public static void submitForecasts(List<CustomForecast__c> forecasts)
    {
        if(forecasts != null && forecasts.size() > 0)
        {
            for(CustomForecast__c f : forecasts)
            {
                f.Locked__c = true;
                f.LastEdited__c = DateTime.now();
                f.SubmittedOn__c = DateTime.now();
            }
            update forecasts;
        }
    }

    private static void deleteDuplicate(List<CustomForecast__c> forecasts)
    {
        if(forecasts != null && forecasts.size() > 1)
        {
            //sort by createddate desc
            for(Integer i = 0; i < forecasts.size(); i++)
            {
                for(Integer j = i + 1; j < forecasts.size(); j++)
                {
                    if(forecasts[i].CreatedDate > forecasts[j].CreatedDate)
                    {
                        CustomForecast__c t = forecasts[j];
                        forecasts.set(j, forecasts[i]);
                        forecasts.set(i, t);
                    }
                }
            }
            Set<String> keys = new Set<String>();
            List<CustomForecast__c> toBeRemoved = new List<CustomForecast__c>();
            for(Integer i = 0; i < forecasts.size(); i++)
            {
                String key = forecasts[i].User__c + forecasts[i].FYFQ__c + forecasts[i].YYWW__c + forecasts[i].ForecastType__c + forecasts[i].Forecast_Family__c;
                if(keys.contains(key))
                {
                    toBeRemoved.add(forecasts[i]);
                }
                else
                {
                    keys.add(key);
                }
            }
            if(toBeRemoved.size() > 0)
            {
                delete toBeRemoved;
            }
        }
    }

    public static String[] getNextForecastWeek()
    {
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo quarter = new ForecastingDataModel.FiscalQuarterInfo();
        ForecastingDataModel.WeekInfo nextWeek = quarter.getWeek(nextWeekStartDay);
        if(nextWeek == null)
        {
            quarter = quarter.next;
            nextWeek = quarter.getWeek(nextWeekStartDay);
        }
        String fyfq = quarter.FormattedString;
        String yyww = nextWeek.FormattedString;
        return new String[] {fyfq, yyww};
    }

    /**
     * @description: This method populate if this user allowed to
     * Qtr is current or future AND
     * User is not viewing ZPA AND
     * User is forecast enabled OR has the Forecast Inline Editing (checkbox on user) enabled
     **/
    public static String allowInlineEdting(ForecastingStatsService.SaveOppListItemRequest request)
    {
        String state = 'FORBIDDEN';
        //
        if(request.params == null || request.params.size() == 0 ){ return state; }

        //
        String formattedReqQtr = (String)request.params.get('FiscalQtr');
        String userId = (String)request.params.get('UserId');
        String forecastFamily = (String)request.params.get('ForecastFamily');

        return getInlineEdittingState(formattedReqQtr, userId, forecastFamily);

    }
    
    public static String allowInlineEdting(ZForecastingStatsService.SaveOppListItemRequest request)
    {
        String state = 'FORBIDDEN';
        //
        if(request.params == null || request.params.size() == 0 ){ return state; }

        //
        String formattedReqQtr = (String)request.params.get('FiscalQtr');
        String userId = (String)request.params.get('UserId');
        String forecastFamily = (String)request.params.get('ForecastFamily');

        return getInlineEdittingState(formattedReqQtr, userId, forecastFamily);

    }

    public static String getInlineEdittingState(String formattedReqQtr, String userId, String forecastFamily)
    {
        String state = 'FORBIDDEN';
        System.debug('getInlineEdittingState: '+forecastFamily);
        System.debug('getInlineEdittingState: '+userId);
        System.debug('getInlineEdittingState: '+formattedReqQtr);
        //
        if(String.isBlank(formattedReqQtr) || String.isBlank(userId) || String.isBlank(forecastFamily)){ return state; }

        //
        ForecastingDataModel.FiscalQuarterInfo currQtr = new ForecastingDataModel.FiscalQuarterInfo(formattedReqQtr);

        System.debug('getInlineEdittingState: '+currQtr);
        //
        ForecastingDataModel.UserInfo viewingUser = GetUser(userId);
        Boolean qtrInCurrOrFuture = Date.today().daysBetween(currQtr.EndDate) >= 0;

        System.debug('getInlineEdittingState: '+viewingUser);

        if(forecastFamily != 'ZPA' &&  qtrInCurrOrFuture == true && ( viewingUser.ForecastEnabled == true || viewingUser.OppInlineEdittingEnabled == true ))
        {
            state = 'ALLOWED';
        }

        //state = 'FORBIDDEN';

        return state;
    }

    public static Map<String, List<Schema.PicklistEntry>> GetPickliskEntriesForSObject(String objName, List<String> fields)
    {
          Map<String, List<Schema.PicklistEntry>> entries = new Map<String, List<Schema.PicklistEntry>>();
          List<Schema.DescribeSObjectResult> sobjDescribe = Schema.describeSObjects(new String[] { objName });
          Map<String, Schema.SObjectField> allFields = sobjDescribe[0].fields.getMap();

          for(String f : fields)
          {
              entries.put(f, allFields.get(f).getDescribe().getPickListValues());
          }

          return entries;
    }

    public static List<ForecastingStatsService.SelectOptionWrapper> convertEntriesToStringMap(List<Schema.PicklistEntry> toConvert)
    {
        List<ForecastingStatsService.SelectOptionWrapper> result = new List<ForecastingStatsService.SelectOptionWrapper>();
        for(Schema.PicklistEntry entry : toConvert)
        {
            if(entry.isActive())
            {
                result.add(new ForecastingStatsService.SelectOptionWrapper(entry));
            }
        }
        return result;
    }

    public static Map<String, List<ForecastingStatsService.SelectOptionWrapper>> wrapPicklistEntriesToMap(Map<String, List<Schema.PicklistEntry>> source)
    {
        Map<String, List<ForecastingStatsService.SelectOptionWrapper>> result = new Map<String, List<ForecastingStatsService.SelectOptionWrapper>>();
        for(String f : source.keySet())
        {
            result.put( f, convertEntriesToStringMap( source.get(f) ) );
        }
        return result;
    }

    public static Map<String, List<ForecastingStatsService.SelectOptionWrapper>> getOpportunityPicklistFieldsValues(List<String> fields)
    {
        Map<String, List<ForecastingStatsService.SelectOptionWrapper>> result = new Map<String, List<ForecastingStatsService.SelectOptionWrapper>>();
        result.putAll(wrapPicklistEntriesToMap( GetPickliskEntriesForSObject('Opportunity', fields) ));
        result.putAll(wrapPicklistEntriesToMap( GetPickliskEntriesForSObject('OpportunitySplit', new String[]{'Deal_Path__c'})));
        return result;
    }

}