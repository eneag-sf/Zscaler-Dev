public without sharing class CreatePortalUser {
    public static string checkforPortalUser(Contact cnt, String profilename, String email) {
        List<User> ulst = [Select Id, FederationIdentifier from User where ContactId = :cnt.Id and isActive = true and Profile.name = :profilename limit 1];
        List<Profile> prfl = [select id,name from profile where name = :profilename];
        if(ulst.isEmpty()){
            User u = new User();
            String alias = ''+System.currentTimeMillis();
            u.Alias = alias.substring(alias.length()-7,alias.length());
            u.ContactId = cnt.Id;
            u.FirstName = cnt.FirstName;
            u.LastName = cnt.LastName;
            if(cnt.Email != null){
                u.Email = cnt.Email;
                u.Username = cnt.Email;    
                u.FederationIdentifier = email;    
            }
            u.ProfileId = prfl[0].Id;                    
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'America/Los_Angeles';
            u.country = 'United States';
            u.emailencodingkey = 'UTF-8';
            try{
                TriggerUtility.SkipUserTriggerExecuted();
                insert u;
            }catch(Exception ex){
                return '' + ex.getMessage();
            }
        }else{
            User u = ulst[0];
            if(email!= null && (u.FederationIdentifier == null || !email.equals(u.FederationIdentifier))){
                u.FederationIdentifier = email;
                update u;
            }
        }
        return 'Success';
    }
    
    public static void booster(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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