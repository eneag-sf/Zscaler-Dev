public class CaseEscalationcontroller{  
    
    public ApexPages.StandardController sc; 
    Id recordId;
    public Case CaseNew {get;set;}
    public Boolean showCaseEscalationPopup {get;set;}
    public Boolean showfieldifOwner {get;set;}
    public string currentDetailedReasonforContractExtension {get;set;}
    public string EscalationReason {get;set;}
    public string defconlevel {get;set;}
    public Boolean custBasedEsc {get;set;}
    public Map<string, DEFCON_Ranking__c> defconrankmap = DEFCON_Ranking__c.getAll();
    public CaseEscalationcontroller(ApexPages.StandardController stdController) {
        recordId = stdController.getId();
        showCaseEscalationPopup = true;
        showfieldifOwner = false;
        custBasedEsc=false;
        EscalationReason='';
        CaseNew = [SELECT Id,Escalation_reason__c,Defcon_Level__c,isEscalated,OwnerId,Escalation_on_behalf_of_Customer__c,Escalation_Stage__c,Escalation_Start_Time__c,Escalated_By__c from Case WHERE Id =: recordId];
        system.debug('CaseNew  '+CaseNew);
        system.debug('Userinfo.getuserid()  '+Userinfo.getuserid());
        if(CaseNew!=null && CaseNew.OwnerId==Userinfo.getuserid()){
            showfieldifOwner=true;
        }
                
    }
    public PageReference SubmitforCaseEscalation() {
        try{
            boolean noErrors = false;
            if(!string.isBlank(EscalationReason) && string.valueof(EscalationReason)!=null){
                noErrors = true; 
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in the reason for Escalation');
                ApexPages.addMessage(myMsg);
                noErrors = false;
            }
            
            if(noErrors){
                
                //CaseEscalationController_LWC.escalateCs(String recId, String reason, String typeofEscalation, String deflevel,Boolean custBasedEsc);
                system.debug('recordId  '+recordId);
                system.debug('EscalationReason  '+EscalationReason);
                system.debug('defconlevel  '+defconlevel);
                system.debug('custBasedEsc  '+custBasedEsc);
                if(defconlevel=='None'){
                    defconlevel=null;
                }
                String returnmessage = CaseEscalationController_LWC.escalateCs(recordId, EscalationReason, null,defconlevel,custBasedEsc);
                
                /* Boolean defconassigned = false;             
                Boolean oldEscalatedVal;
                String olddefconval;
                if(CaseNew!=null){
                    oldEscalatedVal = CaseNew.isEscalated;
                    olddefconval = CaseNew.Defcon_Level__c;
                }
        
                List<User> usrinfo = [Select Id, Level__c, Service_Level__c, Profile.name from User where id = :UserInfo.getUserId()];
                if(!usrinfo.isEmpty()){
                    for(DEFCON_User_Mapping__c dum: DEFCON_User_Mapping__c.getAll().values()){
                        System.debug(dum);
                        if((dum.Level__c != null && usrinfo[0].Level__c != null && dum.Level__c.contains(usrinfo[0].Level__c)) || (dum.Profile_Name__c != null && dum.Profile_Name__c.contains(usrinfo[0].Profile.Name))){
                            if(olddefconval == null || (defconrankmap != null && defconrankmap.containsKey(dum.name) && defconrankmap.containsKey(olddefconval) && defconrankmap.get(dum.name).Rank__c > defconrankmap.get(olddefconval).Rank__c)){
                                CaseNew.Defcon_Level__c = dum.name;
                            }
                            defconassigned = true;
                        }
                        
                        if(defconassigned){
                            if(CaseNew.Defcon_Level__c != '5'){
                                CaseNew.isEscalated = true;
                            }
                            break;
                        }
                    }
                }
                
                //CaseNew.Escalation_reason__c = 'Purge Stopped';
                system.debug('before update '+CaseNew);
                if(CaseNew!=null && !oldEscalatedVal){
                    CaseNew.Escalated_By__c = UserInfo.getUserId();
                    List<User> usrlst = [Select Id, Name, ManagerId from User where Id = :CaseNew.OwnerId];
                    CaseNew.Escalation_Owner__c = !usrlst.isEmpty() && usrlst[0].ManagerId != null ? usrlst[0].ManagerId: !usrlst.isEmpty() ? usrlst[0].Id : null;
                    CaseNew.Escalation_Stage__c = 'Open';
                    CaseNew.Escalation_Start_Time__c = System.now();
                }
                CaseNew.Escalation_reason__c=EscalationReason;
                update CaseNew;
                system.debug('after update '+CaseNew);
                String reason= 'Customer Escalation reason: ' + CaseNew.Escalation_reason__c;
                FeedItem cc = new FeedItem(parentId = CaseNew.id);
                cc.Body = reason;
                cc.Visibility = 'AllUsers';
                cc.IsRichText = false;
                TriggerUtility.CaseBeforeInsertExecuted();
                TriggerUtility.CaseAfterInsertExecuted();
                TriggerUtility.CaseBeforeUpdateExecuted();
                TriggerUtility.CaseAfterUpdateExecuted();
                TriggerUtility.SkipFeedItemTriggerExecuted();
                TriggerUtility.SkipCaseCommentTriggerExecuted();
                insert cc; */
                system.debug('recordId  '+recordId);
                system.debug('returnmessage  '+returnmessage);
                
                if(returnmessage=='Success'){
                    PageReference pf = new PageReference('/' + recordId);pf.setRedirect(true);return pf;
    
                }else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, returnmessage);ApexPages.addMessage(myMsg);
                }
            }else{return null;
            }
        }
        catch(Exception exp){ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage());ApexPages.addMessage(myMsg);
        }
        return null;
    }
    public List<SelectOption> getDefconlevels() {
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('4','4'));
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('2','2'));
        options.add(new SelectOption('1','1'));
        options.add(new SelectOption('None','None'));
        return options;
    }
        
    public PageReference cancelCaseEscalationPopup(){
        PageReference pf = new PageReference('/' + recordId);
        pf.setRedirect(true);
        return pf;
    }
    
    public void ChangeDefcon(){
        system.debug('inside ChangeDefcon level '+custBasedEsc);
        if(custBasedEsc){defconlevel='4';
        }
        else{
            defconlevel='5';
        }
    }
}