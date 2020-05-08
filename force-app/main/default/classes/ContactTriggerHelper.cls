public class ContactTriggerHelper{

        public static boolean skipTrigger = false;
        public static void changeContactOwnership( list<Contact> newCintactList ){
            set<Id> accIdSet = new set<Id>();
            map<Id, Id> accIdOwnerIdMap = new map<id,id>();
            for(Contact con : newCintactList){
                if(con.AccountId != null)
                    accIdSet.add(con.AccountId);
            }

            for(Account acc: [select Id, OwnerId from Account where Id IN: accIdSet AND Owner.isActive =: true]){
                accIdOwnerIdMap.put(acc.Id, acc.OwnerId);
            }

            for(Contact con : newCintactList){
                if(accIdOwnerIdMap.keyset().Contains(con.AccountId))
                    con.OwnerId = accIdOwnerIdMap.get(con.AccountId);

            }
            TriggerUtility.contactOwnerShipExecuted();
        }
        //Added by Gurjinder to update the Head fields.
        public static void updateHeadfieldsonContact(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
            for (Contact contact : newContacts) {                   
                if(contact.Active__c && mapOldContacts!=null && mapOldContacts.containskey(contact.Id) && contact.Active__c!=mapOldContacts.get(contact.Id).Active__c ){
                    contact.Head_of_IT__c=false;
                    contact.Head_of_Networking__c=false;
                    contact.Head_of_Security__c=false;
                }   
            }
        }
        public static void updateContactWhiteSpace(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setContactIdsToExclude = new Set<Id>();
            List<Contact> lstContactsToUpdate = new List<Contact>();
            List<Account> AccounttoUpdate= new List<Account>();
            Map<Id, Map<String, Id>> mapAccountContactRole = new Map<Id, Map<String, Id>>();
            Map<Id, Map<String, Id>> mapAccountContactRoleExisting = new Map<Id, Map<String, Id>>();

            for (Contact contact : newContacts) {
                if (contact.AccountId != null
                    && (mapOldContacts == null
                        || !mapOldContacts.containsKey(contact.Id)
                        || (/* contact.Head_of_IT__c  &&*/ contact.Head_of_IT__c != mapOldContacts.get(contact.Id).Head_of_IT__c)
                        || (/* contact.Head_of_Networking__c && */ contact.Head_of_Networking__c != mapOldContacts.get(contact.Id).Head_of_Networking__c)
                        || (/* contact.Head_of_Security__c && */ contact.Head_of_Security__c != mapOldContacts.get(contact.Id).Head_of_Security__c)
                        || (contact.Budget_Authority__c && contact.Budget_Authority__c != mapOldContacts.get(contact.Id).Budget_Authority__c)
                        || (contact.Service_Owner__c && contact.Service_Owner__c != mapOldContacts.get(contact.Id).Service_Owner__c) || contact.Active__c!=mapOldContacts.get(contact.Id).Active__c)) {
                    setAccountIds.add(contact.AccountId);
                    setContactIdsToExclude.add(contact.Id);

                    if (!mapAccountContactRole.containsKey(contact.AccountId)) {
                        mapAccountcontactRole.put(contact.AccountId, new Map<String, Id>());
                        mapAccountContactRoleExisting.put(contact.AccountId, new Map<String, Id>());                        
                    }
                    if (contact.Head_of_IT__c  && !contact.Active__c ) {
                        mapAccountContactRole.get(contact.AccountId).put('HeadOfIT', contact.Id);
                        mapAccountContactRoleExisting.get(contact.AccountId).put('HeadOfIT', contact.Id);
                    }

                    if (contact.Head_of_Networking__c  && !contact.Active__c ) {
                        mapAccountContactRole.get(contact.AccountId).put('HeadOfNetworking', contact.Id);
                        mapAccountContactRoleExisting.get(contact.AccountId).put('HeadOfNetworking', contact.Id);
                    }

                    if (contact.Head_of_Security__c  && !contact.Active__c ) {
                        mapAccountContactRole.get(contact.AccountId).put('HeadOfSecurity', contact.Id);
                        mapAccountContactRoleExisting.get(contact.AccountId).put('HeadOfSecurity', contact.Id);
                    }

                    if (contact.Budget_Authority__c) {
                        mapAccountContactRole.get(contact.AccountId).put('BudgetAuthority', contact.Id);
                    }

                    if (contact.Service_Owner__c) {
                        mapAccountContactRole.get(contact.AccountId).put('ServiceOwner', contact.Id);
                    }
                }
            }
            for (Contact dbContact : [SELECT Id, Head_of_IT__c, Head_of_Networking__c, Head_of_Security__c,
                                        Budget_Authority__c, Service_Owner__c, AccountId,Active__c
                                      FROM Contact WHERE AccountId IN :setAccountIds AND Id NOT IN :setContactIdsToExclude
                                       AND (Head_of_IT__c = True OR Head_of_Networking__c = True OR Head_of_Security__c = True OR
                                            Budget_Authority__c = True OR Service_Owner__c = True)]) {
                Map<String, Id> mapContactRoles = mapAccountContactRole.containsKey(dbContact.AccountId) ? mapAccountContactRole.get(dbContact.AccountId) : new Map<String, Id>();
                Boolean needToUpdate = false;
                
                //Added by Gurjinder:Update Heads of Account:Start
                if(dbContact.Head_Of_IT__c && !dbContact.Active__c && mapAccountContactRoleExisting.get(dbContact.AccountId)!=null && !mapAccountContactRoleExisting.get(dbContact.AccountId).containskey('HeadOfIT')){
                    mapAccountContactRoleExisting.get(dbContact.AccountId).put('HeadOfIT',dbContact.id);
                }
                if(dbContact.Head_of_Networking__c && !dbContact.Active__c && mapAccountContactRoleExisting.get(dbContact.AccountId)!=null && !mapAccountContactRoleExisting.get(dbContact.AccountId).containskey('HeadOfNetworking')){
                    mapAccountContactRoleExisting.get(dbContact.AccountId).put('HeadOfNetworking',dbContact.id);
                }
                if(dbContact.Head_of_Security__c && !dbContact.Active__c && mapAccountContactRoleExisting.get(dbContact.AccountId)!=null && !mapAccountContactRoleExisting.get(dbContact.AccountId).containskey('HeadOfSecurity')){
                    mapAccountContactRoleExisting.get(dbContact.AccountId).put('HeadOfSecurity',dbContact.id);
                }
                //Added by Gurjinder:Update Heads of Account:End
                
                if (dbContact.Head_Of_IT__c
                    && mapContactRoles.containsKey('HeadOfIT')
                    && mapContactRoles.get('HeadOfIT') != dbContact.Id) {
                    dbContact.Head_Of_IT__c = false;
                    needToUpdate = true;
                }
                
                if (dbContact.Head_of_Networking__c
                    && mapContactRoles.containsKey('HeadOfNetworking')
                    && mapContactRoles.get('HeadOfNetworking') != dbContact.Id) {
                    dbContact.Head_of_Networking__c = false;
                    needToUpdate = true;
                }

                if (dbContact.Head_of_Security__c
                    && mapContactRoles.containsKey('HeadOfSecurity')
                    && mapContactRoles.get('HeadOfSecurity') != dbContact.Id) {
                    dbContact.Head_of_Security__c = false;
                    needToUpdate = true;
                }

                if (dbContact.Budget_Authority__c
                    && mapContactRoles.containsKey('BudgetAuthority')
                    && mapContactRoles.get('BudgetAuthority') != dbContact.Id) {
                    dbContact.Budget_Authority__c = false;
                    needToUpdate = true;
                }

                if (dbContact.Service_Owner__c
                    && mapContactRoles.containsKey('ServiceOwner')
                    && mapContactRoles.get('ServiceOwner') != dbContact.Id) {
                    dbContact.Service_Owner__c = false;
                    needToUpdate = true;
                }

                if (needToUpdate) {
                    lstContactsToUpdate.add(dbContact);
                }
                                
            }
            
            //Changes to update Head of It,head of Networking & Head of Security on Account:Gurjinder:Start
                
                for(String str:mapAccountContactRoleExisting.keyset()){
                    Map<String, Id> mapContactRoles = mapAccountContactRoleExisting.containsKey(str) ? mapAccountContactRoleExisting.get(str) : new Map<String, Id>();
                    Account Acc= new Account(id=id.valueof(str));
                    if(mapContactRoles.containsKey('HeadOfIT') && mapContactRoles.get('HeadOfIT')!=null){
                        Acc.HeadOfIT__c=mapContactRoles.get('HeadOfIT');
                    }else{
                        Acc.HeadOfIT__c=null;
                    }
                    
                    if(mapContactRoles.containsKey('HeadOfNetworking') && mapContactRoles.get('HeadOfNetworking')!=null){
                        Acc.HeadOfNetworking__c=mapContactRoles.get('HeadOfNetworking');
                    }else{
                        Acc.HeadOfNetworking__c=null;
                    }
                    if(mapContactRoles.containsKey('HeadOfSecurity') && mapContactRoles.get('HeadOfSecurity')!=null){
                        Acc.HeadOfSecurity__c=mapContactRoles.get('HeadOfSecurity');
                    }else{
                        Acc.HeadOfSecurity__c=null;
                    }           
                    AccounttoUpdate.add(acc);
                }
            //Changes to update Head of It,head of Networking & Head of Security on Account:Gurjinder:End
            
            
            try {
                if (lstContactsToUpdate.size() > 0) {
                    Database.update(lstContactsToUpdate, true);
                }
                //Changes to update Head of It,head of Networking & Head of Security on Account:Gurjinder:Start
                if (AccounttoUpdate.size() > 0) {
                    //TriggerUtility.SkipAccTriggerExecuted();
                    Database.update(AccounttoUpdate, false);
                }               
                //Changes to update Head of It,head of Networking & Head of Security on Account:Gurjinder:End
                TriggerUtility.conWhiteSpaceUpdateExecuted();
                    
            } catch(Exception ex) {
                System.debug('>>>> Exception occurred while updating contacts whitespace roles. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            }
        }

        // Vijay - 03/26/2018: Commenting the below as updateContactWhiteSpace() replaces this logic.
        // public static void updateAccountWhiteSpace(list<Contact> newConList, map<id,Contact> oldConMap){
        //     TriggerUtility.accContactWhiteSpaceUpdateExecuted();
        //     map<id, Account> accUpdateMap = new map<Id, Account>();
        //     set<id> accIdSet = new set<Id>();
        //     map<id, Id> accIdConIdMap = new map<id, Id>();
        //     map<id, Account> accMap = new map<Id, Account>();
        //     for(Contact con : newConList){
        //         if(con.AccountId != null)
        //             accIdSet.add(con.AccountId);
        //
        //     }
        //
        //
        //     for(Account acc : [Select Id, HeadOfIT__c, HeadOfNetworking__c, HeadOfSecurity__c, BudgetAuthority__c, ProcurementContact__c from Account Where Id IN: accIdSet]){
        //         accMap.put(acc.Id, acc);
        //     }
        //
        //     map<id, Contact> conUpdateMap = new map<id, contact>();
        //     Account tempAcc = new Account();
        //     Contact tempCon = new Contact();
        //     if(oldConMap != null){
        //         for(Contact con : newConList){
        //             tempAcc = new Account();
        //             tempCon = new Contact();
        //             if(con.AccountId != null){
        //                 if(con.Budget_Authority__c && !oldConMap.get(con.id).Budget_Authority__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.BudgetAuthority__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //
        //                     if(accMap.get(con.AccountId).BudgetAuthority__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).BudgetAuthority__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).BudgetAuthority__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).BudgetAuthority__c;
        //                         tempCon.Budget_Authority__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //
        //                 }else if(!con.Budget_Authority__c && oldConMap.get(con.id).Budget_Authority__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.BudgetAuthority__c = null;
        //                 }
        //
        //                 if(con.Procurement_Contact__c && !oldConMap.get(con.id).Procurement_Contact__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.ProcurementContact__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //
        //                     if(accMap.get(con.AccountId).ProcurementContact__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).ProcurementContact__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).ProcurementContact__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).ProcurementContact__c;
        //                         tempCon.Procurement_Contact__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }else if(!con.Procurement_Contact__c && oldConMap.get(con.id).Procurement_Contact__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.ProcurementContact__c = null;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                 }
        //
        //                 if(con.Head_of_IT__c && !oldConMap.get(con.id).Head_of_IT__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfIT__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //
        //                     if(accMap.get(con.AccountId).HeadOfIT__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).HeadOfIT__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).HeadOfIT__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).HeadOfIT__c;
        //                         tempCon.Head_of_IT__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }else if(!con.Head_of_IT__c && oldConMap.get(con.id).Head_of_IT__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfIT__c = null;
        //                 }
        //
        //                 if(con.Head_of_Networking__c && !oldConMap.get(con.id).Head_of_Networking__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfNetworking__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                     if(accMap.get(con.AccountId).HeadOfNetworking__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).HeadOfNetworking__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).HeadOfNetworking__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).HeadOfNetworking__c;
        //                         tempCon.Head_of_Networking__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }else if(!con.Head_of_Networking__c && oldConMap.get(con.id).Head_of_Networking__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfNetworking__c = null;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                 }
        //
        //                 if(con.Head_of_Security__c && !oldConMap.get(con.id).Head_of_Security__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfSecurity__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //
        //                     if(accMap.get(con.AccountId).HeadOfSecurity__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).HeadOfSecurity__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).HeadOfSecurity__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).HeadOfSecurity__c;
        //                         tempCon.Head_of_Security__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }else if(!con.Head_of_Security__c && oldConMap.get(con.id).Head_of_Security__c){
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfSecurity__c = null;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                 }
        //
        //             }
        //         }
        //     }else{
        //         tempAcc = new Account();
        //
        //         for(Contact con : newConList){
        //             if(con.AccountId != null){
        //                 if(con.Budget_Authority__c){
        //                     tempCon = new Contact();
        //                     tempAcc = new Account();
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.BudgetAuthority__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //
        //                     if(accMap.get(con.AccountId).BudgetAuthority__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).BudgetAuthority__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).BudgetAuthority__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).BudgetAuthority__c;
        //                         tempCon.Budget_Authority__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }
        //
        //                 if(con.Procurement_Contact__c ){
        //                     tempCon = new Contact();
        //                     tempAcc = new Account();
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.ProcurementContact__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                     if(accMap.get(con.AccountId).ProcurementContact__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).ProcurementContact__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).ProcurementContact__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).ProcurementContact__c;
        //                         tempCon.Procurement_Contact__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }
        //
        //                 if(con.Head_of_IT__c){
        //                     tempCon = new Contact();
        //                     tempAcc = new Account();
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfIT__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                     if(accMap.get(con.AccountId).HeadOfIT__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).HeadOfIT__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).HeadOfIT__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).HeadOfIT__c;
        //                         tempCon.Head_of_IT__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }
        //
        //                 if(con.Head_of_Networking__c){
        //                      tempCon = new Contact();
        //                     tempAcc = new Account();
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadofNetworking__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                     if(accMap.get(con.AccountId).HeadofNetworking__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).HeadofNetworking__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).HeadofNetworking__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).HeadofNetworking__c;
        //                         tempCon.Head_of_Networking__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }
        //
        //                 if(con.Head_of_Security__c ){
        //                     tempCon = new Contact();
        //                     tempAcc = new Account();
        //                     if(accUpdateMap.keySet().Contains(con.AccountId))
        //                         tempAcc = accUpdateMap.get(con.AccountId);
        //                     else
        //                         tempAcc.Id = con.AccountId;
        //                     tempAcc.HeadOfSecurity__c = con.Id;
        //                     accUpdateMap.put(con.AccountId, tempAcc);
        //                     if(accMap.get(con.AccountId).HeadofSecurity__c != null){
        //                         if(conUpdateMap.keySet().Contains(accMap.get(con.AccountId).HeadofSecurity__c))
        //                             tempCon = conUpdateMap.get(accMap.get(con.AccountId).HeadofSecurity__c);
        //                         else
        //                             tempCon.Id = accMap.get(con.AccountId).HeadofSecurity__c;
        //                         tempCon.Head_of_Security__c = false;
        //                         conUpdateMap.put(tempCon.Id, tempCon);
        //                     }
        //                 }
        //             }
        //
        //         }
        //     }
        //
        //     // if(accUpdateMap != null && !accUpdateMap.values().isEmpty())
        //     //     database.update(accUpdateMap.Values(), false);
        //
        //     TriggerUtility.conWhiteSpaceUpdateExecuted();
        //
        //     if(conUpdateMap != null && !conUpdateMap.values().isEmpty())
        //         database.update(conUpdateMap.Values(), false);
        //
        // }

        public static void dealRegValidation(Map<Id, Contact> conOldMap){
           set<id> conIdSet  = new set<Id>();

           for(Deal_Reg__c deal : [Select Id, Contact__c from Deal_Reg__c Where Contact__c IN: conOldMap.keySet()] )
               conIdSet.add(deal.Contact__c);

           for(Contact con : conOldMap.Values()){
               if(conIdSet.contains(con.id))
                   con.addError('Deal is associated to this contact and cannot be deleted.');
           }


        }
        
        //Added By Gurjinder
        public static void ZCloudIDContactInsert(List<Contact> conList){
            List<Contact> UpdateconList= new List<Contact>();
            Set<String> SendCIOReportstatus= new Set<String>();
            String ContactSendCIOReportstatus= ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus')!=null && ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c:'Send,Send delayed';
            SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));
            for(Contact con:conList){
                if(con.Contacts_that_matter__c && SendCIOReportstatus.contains(con.Send_CIO_Report__c)){
                    UpdateconList.add(new Contact(Id = con.Id,accountid=con.accountid));
                }
            }
            if(!UpdateconList.isempty() && UpdateconList.size()>0){
                ContactTriggerHelper.InsertZcloudIDContact(UpdateconList);              
            }
        }
        
        public static void ZCloudIDContactUpdate(List<Contact> Conlist,Map<Id, Contact> conOldMap){
            
            TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            
            Set<id>  AccountId =new Set<id>();
            Set<String> SendCIOReportstatus= new Set<String>();
            List<Contact>  ListtocreateZCIDContacts= new List<Contact>();
            List<Contact>  ListtoRemoveZCIDContacts= new List<Contact>();
            Map<id,Contact>  MaptoRemoveZCIDContacts= new Map<id,Contact>();
            String ContactSendCIOReportstatus= ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus')!=null && ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c:'Send,Send delayed';
            SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));
            
            for(Contact Con:Conlist){                
                if((con.Contacts_that_matter__c && conOldMap.get(con.id).Contacts_that_matter__c==false && con.Send_CIO_Report__c!=null && SendCIOReportstatus.contains(con.Send_CIO_Report__c) && !SendCIOReportstatus.contains(conOldMap.get(con.id).Send_CIO_Report__c))  || (con.Contacts_that_matter__c && conOldMap.get(con.id).Contacts_that_matter__c==false && con.Send_CIO_Report__c!=null && SendCIOReportstatus.contains(con.Send_CIO_Report__c) /*&& !SendCIOReportstatus.contains(conOldMap.get(con.id).Send_CIO_Report__c)*/) ){
                    ListtocreateZCIDContacts.add(con);              
                }else if(con.Contacts_that_matter__c && con.Send_CIO_Report__c!=null && !con.Send_CIO_Report__c.equalsignorecase(conOldMap.get(con.id).Send_CIO_Report__c) && SendCIOReportstatus.contains(con.Send_CIO_Report__c) && !SendCIOReportstatus.contains(conOldMap.get(con.id).Send_CIO_Report__c)  ){
                    ListtocreateZCIDContacts.add(con);
                }
                else if((!con.Contacts_that_matter__c && conOldMap.get(con.id).Contacts_that_matter__c==true) || (/* !con.Send_CIO_Report__c.equalsignorecase(conOldMap.get(con.id).Send_CIO_Report__c) && */ con.Send_CIO_Report__c!=null && !SendCIOReportstatus.contains(con.Send_CIO_Report__c))  || (con.Send_CIO_Report__c==null && conOldMap.get(con.id).Send_CIO_Report__c!=null) ){
                    MaptoRemoveZCIDContacts.put(con.id,con);
                    ListtoRemoveZCIDContacts.add(con);
                }
            }
            
            if(!ListtocreateZCIDContacts.isempty() && ListtocreateZCIDContacts.size()>0){
                ContactTriggerHelper.InsertZcloudIDContact(ListtocreateZCIDContacts);
                
            }
            
            if(!ListtoRemoveZCIDContacts.isempty() && ListtoRemoveZCIDContacts.size()>0){
                ContactTriggerHelper.ZCloudIDContactDelete(ListtoRemoveZCIDContacts);
                
            }
        }
        
        public static void ZCloudIDContactDelete(List<Contact> conOldList){
            List<String> errorlst = new List<String>();
            Set<id> ContactIdSet =new Set<id>();        
            for(Contact Con:conOldList){
                ContactIdSet.add(con.id);   
            }
            if(!ContactIdSet.isempty() && ContactIdSet.size()>0){
                List<Zscaler_Cloud_ID_Contact__c> ZCloudIDCncttoDelete=[Select id,Account__c,Contact__c,Zscaler_Cloud_ID__c from Zscaler_Cloud_ID_Contact__c where Contact__c IN:ContactIdSet];
                
                TriggerUtility.ZCloudIDcontactDeletetriggersettrue();
                try{
                    database.delete(ZCloudIDCncttoDelete);
                }catch(DmlException e){
                    
                } 
            }
            
        }
        
    public static void InsertZcloudIDContact(List<Contact> conList){
        List<String> errorlst = new List<String>();
        Set<id> AccountidSet = new Set<id>();
        Set<id> ContactidSet = new Set<id>();
        List<Zscaler_Cloud_ID_Contact__c> ZCloud_IDContactList= new List<Zscaler_Cloud_ID_Contact__c>();
        Map<id,List<Zscaler_Cloud_ID__c>> AccwithOrgIdMap= new Map<id,List<Zscaler_Cloud_ID__c>>();
        for(Contact Con:conList)
        {
            AccountidSet.add(Con.Accountid);
            ContactidSet.add(Con.id);
        }
        for(Zscaler_Cloud_ID__c ZC:[Select id,Name,Account__c from Zscaler_Cloud_ID__c where Account__c IN:AccountidSet]){
            if(!ZC.Name.contains('beta')){
                if(AccwithOrgIdMap!=null && AccwithOrgIdMap.containskey(ZC.Account__c)){
                    AccwithOrgIdMap.get(ZC.Account__c).add(ZC);             
                }else{
                    List<Zscaler_Cloud_ID__c> TempZCloudidlist= new List<Zscaler_Cloud_ID__c>();
                    TempZCloudidlist.add(ZC);
                    AccwithOrgIdMap.put(ZC.Account__c,TempZCloudidlist);
                }
            }
        }
        for(Contact Con:conList){
            if(Con.ZCloudID_Org_IDs__c!=null && Con.ZCloudID_Org_IDs__c!=''){
                Set<String> ZCloudidSet= new Set<String>();
                ZCloudidSet.addall(Con.ZCloudID_Org_IDs__c.split(','));
                for(String str:ZCloudidSet){
                    Zscaler_Cloud_ID_Contact__c ZCC= new Zscaler_Cloud_ID_Contact__c();
                    ZCC.Account__c=Con.Accountid;
                    ZCC.Contact__c=Con.id;
                    ZCC.Zscaler_Cloud_ID__c=id.valueof(str);
                    ZCloud_IDContactList.add(ZCC);
                }               
            }
            else if(AccwithOrgIdMap !=null && AccwithOrgIdMap.containskey(Con.AccountId) && AccwithOrgIdMap.get(Con.AccountId)!=null){
                String OrGIDs='';
                for(Zscaler_Cloud_ID__c ZCloudid:AccwithOrgIdMap.get(Con.AccountId)){
                    Zscaler_Cloud_ID_Contact__c ZCC= new Zscaler_Cloud_ID_Contact__c();
                    ZCC.Account__c=Con.Accountid;
                    ZCC.Contact__c=Con.id;
                    ZCC.Zscaler_Cloud_ID__c=ZCloudid.id;
                    ZCloud_IDContactList.add(ZCC);
                    OrGIDs=OrGIDs+ZCloudid.id+',';
                }
                    con.ZCloudID_Org_IDs__c=OrGIDs;
                                
            }   
        }
        TriggerUtility.ZCloudIDcontactAfterInserttriggersettrue();
        database.insert(ZCloud_IDContactList, false);
        if(trigger.isinsert){
            TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            update conList;
        }  
        
    }
}