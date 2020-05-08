global class CreateCommunityUser implements Database.Batchable<sObject> {
    public String query;
    public CreateCommunityUser(String query){
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = 'select id,email,name,lastname,firstname,AccountId,Account.Name,Account.OwnerId,Account.Owner.UserRoleId,Account.Owner.UserRole.Name from contact where email !=null and accountid !=null  and Account.OwnerId !=null and Account.Owner.UserRoleId !=null and Converted_to_community_user__c = null and ZENDESK__ZENDESK_ID__C != null';
        this.query = query; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> lstcnt){
        Community_Settings__c cmSettings = Community_Settings__c.getValues('Community Prefix');
        if(cmSettings == null)  {
            cmSettings = new Community_Settings__c();
            cmSettings.value__c = '.zscalerdev1';
        }
      //  String unamePrefix = cmSettings.value__c;
        List<String> lstCntEmails = new List<String>();
        List<User> lstUser = new List<User>();
        if(lstcnt.size() >0){
            for(Contact c : lstcnt){
                c.Convert_to_user__c = false;
                c.Error_Message__c = '';
                c.Converted_to_community_user__c = 'Created community user';
                if(c.email != null && c.Email != ''){                    
                    lstCntEmails.add(c.email);
                }
            }
            
            map<String,User> mapUserToCheck = new map<String,User>();
            
            List<User> lstExstUsers = [select id,username,Name,Alias from user];
            Set<String> setNickNames = new Set<String>();
            if(lstExstUsers.size() > 0){
                for(User usr:lstExstUsers){
                    if(usr.Username != null){
                        mapUserToCheck.put(usr.Username,usr);
                        
                    }
                    setNickNames.add(usr.Alias);
                }
            }
            
            Profile prfl = [select id,name from profile where name ='Customer Community User Profile'];
            Integer count = 100;
            for(Contact cnt : lstcnt){
                if(mapUserToCheck.get(cnt.Email) == null){
                    User u = new User();
                    /*String alias = '';
						if(cnt.LastName.length() > 4)  {
						alias = cnt.LastName.subString(0,4);
						}else  {
						alias = cnt.LastName;
						}*/
                    String alias = ''+System.currentTimeMillis();
                    u.Alias = alias.substring(alias.length()-7,alias.length());
                    /*
					if(setNickNames.add(alias))  {
						u.Alias =  alias;
						}else {
						u.Alias = alias+count++;
						}*/
                    setNickNames.add(u.Alias);
                    u.ContactId = cnt.Id;
                    u.FirstName = cnt.FirstName;
                    u.LastName = cnt.LastName;
                    if(cnt.Email != null){
                        u.Email = cnt.Email;
                        u.Username = cnt.Email;    
                    }
                    u.ProfileId = prfl.Id;                    
                    u.LanguageLocaleKey = 'en_US';
                    u.LocaleSidKey = 'en_US';
                    u.TimeZoneSidKey = 'America/Los_Angeles';
                    u.country = 'United States';
                    u.emailencodingkey = 'UTF-8';
                    u.FederationIdentifier =cnt.Email;
                    lstUser.add(u);
                }else{
                    cnt.Error_Message__c = 'User is already present for this contact.User\'s name is ' + mapUserToCheck.get(cnt.Email).Name;
                    
                    /*        Log__c lg = new log__c();
lg.New_Contact__c = cnt.Id;
lg.Existing_User__c = mapUserToCheck.get(cnt.Email+unamePrefix).Id;
lg.Description__c = 'User is already present for this contact.';
lstLog.add(lg);*/
                }                
            }
            System.debug('lstUser='+lstUser);
            try{
                update lstcnt;
                Database.insert(lstUser,false);
                //  insert lstLog;
            }catch (Exception ex){
                System.debug('Exception='+ex);
            }  
        }
        
    }
    global void finish(Database.BatchableContext BC){}
}