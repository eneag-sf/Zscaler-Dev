public class UserTriggerUtility {
    public static void afterInsert(List<User> newList){
        /*Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_User_Skill_Assignment') && tsmap.get('Execute_User_Skill_Assignment') != null && tsmap.get('Execute_User_Skill_Assignment').Execute__c && !TriggerUtility.isUserSkillAssignmentInsertExecuted()){
            createSkillforUser(newList);
        }
        TriggerUtility.UserAfterInsertExecuted();*/
    }
    public static void beforeInsert(List<User> newList){
        //assignnickname(newList, null);
        TriggerUtility.UserBeforeInsertExecuted();
    }
    public static void beforeUpdate(List<User> newList, map<Id, User> oldmap){
        //assignnickname(newList, oldmap);
        TriggerUtility.UserBeforeUpdateExecuted();
    }
    /*public static void assignnickname(List<User> newlist, Map<Id, USer> oldmap){
        if(oldmap == null){
            for(User u: newlist){
                u.CommunityNickname = u.firstname == null ? (u.LastName.length() > 40 ? u.CommunityNickname : u.LastName) : ((u.firstName + ' ' + u.LastName).length() > 40 ? (u.LastName.length() > 40 ? u.CommunityNickname : u.LastName) : u.firstName + ' ' + u.LastName);
            }
        }else{
            for(User u: newlist){
                if(u.firstname != oldmap.get(u.Id).firstname || u.LastName != oldmap.get(u.Id).LastName){
                    u.CommunityNickname = u.firstname == null ? (u.LastName.length() > 40 ? u.CommunityNickname : u.LastName) : ((u.firstName + ' ' + u.LastName).length() > 40 ? (u.LastName.length() > 40 ? u.CommunityNickname : u.LastName) : u.firstName + ' ' + u.LastName);
                }
            }
        }
    }*/

    public static void afterUpdate(List<User> newList, Map<Id, User> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_User_Skill_Assignment') && tsmap.get('Execute_User_Skill_Assignment') != null && tsmap.get('Execute_User_Skill_Assignment').Execute__c && !TriggerUtility.isUserSkillAssignmentUpdateExecuted()){
            updateSkillsforUsers(newList, oldmap);
        }
        TriggerUtility.UserAfterUpdateExecuted();
    }

    /*public static void createSkillforUser(List<User> newList){
        Map<Id, User> serviceUsers = new Map<Id, User>();
        Map<String, ServiceResource> srmap = new Map<String, ServiceResource>();
        for(User u: newList){
            if(u.Service_Level__c != null && u.UserPermissionsSupportUser == true){
                serviceUsers.put(u.Id, u);
            }
        }

        if(!serviceUsers.isEmpty()){
            srmap = ServicecreateServiceResources(serviceUsers);
            if(srmap != null && !srmap.isEmpty()){
                createserviceResourceSkill(serviceUsers, srmap);
            }
        }
        TriggerUtility.UserSkillAssignmentInsertExecuted();
    }*/

    public static void updateSkillsforUsers(List<User> newlist, Map<Id, User> oldmap){
        Map<Id, User> serviceUsers = new Map<Id, User>();
        Map<String, ServiceResource> srmap = new Map<String, ServiceResource>();
        Map<String, ServiceResource> srmapinactive = new Map<String, ServiceResource>();
        Set<Id> skillstodelete = new set<Id>();
        Map<Id,User> usersneedsnewSkillResource = new Map<Id,User>();
        for(ServiceResource sr: [Select Id, RelatedRecordId, isActive from ServiceResource where RelatedRecordId in :newlist]){
            srmap.put(sr.RelatedRecordId, sr);
            if(!sr.isActive){
                srmapinactive.put(sr.RelatedRecordId, sr);
            }
        }
        for(USer u: newlist){
            if((u.UserPermissionsSupportUser && u.UserPermissionsSupportUser != oldmap.get(u.Id).UserPermissionsSupportUser) || (u.Service_Level__c != null && u.Service_Level__c != oldmap.get(u.Id).Service_Level__c)){
                serviceUsers.put(u.id, u);
                if(srmap.containsKey(u.Id)){
                    skillstodelete.add(u.Id);
                }else{
                    usersneedsnewSkillResource.put(u.Id, u);
                }
            }
        }
        if(!skillstodelete.isEmpty()){
            deleteSkillsforUsers(skillstodelete);
        }
        if(!usersneedsnewSkillResource.isEmpty()){
            Map<String, ServiceResource> srmapnew = ServicecreateServiceResources(usersneedsnewSkillResource);
            if(srmapnew != null && !srmapnew.isEmpty()){
                srmap.putall(srmapnew);
            }
        }
        if(!srmapinactive.isEmpty()){
            updateSRtoActive(srmapinactive);
        }
        if(srmap != null && !srmap.isEmpty()){
            createserviceResourceSkill(serviceUsers, srmap);
        }
        TriggerUtility.UserSkillAssignmentUpdateExecuted();
    }

    public static Map<String, ServiceResource> ServicecreateServiceResources(Map<Id, User> usermap){
        Map<String, Service_Team_to_Skill_Map__c> tsmap = Service_Team_to_Skill_Map__c.getAll();
        Map<String, ServiceResource> srmap = new Map<String, ServiceResource>();
        for(User u: usermap.values()){
            if(tsmap != null && u.Service_Level__c != null && tsmap.containsKey(u.Service_Level__c) && tsmap.get(u.Service_Level__c).Skill__c != null){
                ServiceResource sr = new ServiceResource(IsActive = true);
                sr.Name = 'Agent - ' + u.FirstName + ' ' + u.LastName;
                sr.RelatedRecordId = u.Id;
                sr.ResourceType = 'A';
                srmap.put(u.Id, sr);
            }
        }
        insert srmap.values();
        return srmap;

    }
    public static void updateSRtoActive(Map<String, ServiceResource> srmap){
        for(ServiceResource sr: srmap.values()){
            sr.isActive = true;
        }
        update srmap.values();
    }

    public static void createserviceResourceSkill(Map<Id, User> usrmap, Map<String, ServiceResource> srmap){
        Map<String, Service_Team_to_Skill_Map__c> tsmap = Service_Team_to_Skill_Map__c.getAll();
        Map<String, Id> skillmap = new Map<String, Id>();
        for(Skill sk: [Select Id, DeveloperName from Skill]){
            skillmap.put(sk.DeveloperName, sk.id);
        }
        List<ServiceResourceSkill> srslst = new List<ServiceResourceSkill>();
        for(user u: usrmap.values()){
            if(tsmap != null && u.Service_Level__c != null && tsmap.containsKey(u.Service_Level__c) && tsmap.get(u.Service_Level__c).Skill__c != null){
                for(String skill: tsmap.get(u.Service_Level__c).Skill__c.split(';')){
                    ServiceResourceSkill srs = new ServiceResourceSkill(EffectiveStartDate = date.today().adddays(-1));
                    srs.ServiceResourceId = u.Id != null && srmap.containsKey(u.Id) && srmap.get(u.Id) != null? srmap.get(u.Id).Id : null;
                    srs.SkillId = skill != null && skillmap.containsKey(skill) ? skillmap.get(skill): null;
                    srslst.add(srs);
                }
            }
        }
        insert srslst;
    }
    public static void deleteSkillsforUsers(Set<Id> userids){
        if(!userids.isEmpty()){
            delete [Select Id from serviceResourceSkill where ServiceResource.RelatedRecordId in :userids];
        }
    }
}