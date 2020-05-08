public without sharing class MasterCaseFlow{
    @AuraEnabled
    public static void saveCaseComment(Id caseId, String pushComments, String pushEmails, String comment, Boolean ispublic, List<String> contDocIds){
        system.debug('saveCaseComment method');
        system.debug('ispublic '+ispublic);
        Case cs = new Case(Id=caseId);
        //cs.Share_with_Customer__c = pushEmails;
        //cs.Push_comment_to_child_cases__c = pushComments;
        
        if(pushEmails=='' || pushEmails==null){
            system.debug('inside if as pushemails is null');
            cs.Share_with_Customer__c = 'No';
        }else{
            cs.Share_with_Customer__c = pushEmails;
        }
        if(pushComments=='' || pushComments==null){
        system.debug('inside if as pushcomments is null');
            cs.Push_comment_to_child_cases__c='No';
        }else{
            cs.Push_comment_to_child_cases__c = pushComments;
        }
        
        update cs;
        
        system.debug('comments'+comment);
        FeedItem cc = new FeedItem(parentId = caseId);
        String CaseCmnt=comment;
        CaseCmnt=CaseCmnt.replace('<br>',' <p>&nbsp;</p> ');

        system.debug('CaseCmnt  '+CaseCmnt);
        cc.Body = CaseCmnt;
        cc.IsRichText = true;
        //if(ispublic){
            cc.Visibility = 'AllUsers';
            //cc.IsRichText = true;
       // }else{
          //  cc.Visibility = 'Internal';
           // cc.IsRichText = false;
        //}
        TriggerUtility.SkipFeedItemTriggerExecuted();
        insert cc;
        PushCommentstoChildCase Q1= new PushCommentstoChildCase(Caseid);
        ID jobID = System.enqueueJob(Q1);   
    }
    
    /* @AuraEnabled
    public static void PushCommentstoChildCases(id Caseid){
        system.debug('inside PushCommentstoChildCases method');
        List<Case> MasterCaseList= new List<Case>();
        Set<id> CCEmailidlist= new Set<id>();
        List<String> CCEmaillist= new List<String>();
        MasterCaseList=[Select id,Share_with_Customer__c,Push_comment_to_child_cases__c FROM Case where id=:Caseid Limit 1];
        system.debug('Mstrcase '+MasterCaseList[0] +', Share with Customers :'+MasterCaseList[0].Share_with_Customer__c+', Push Comments to Child Cases'+MasterCaseList[0].Push_comment_to_child_cases__c);
        if(MasterCaseList[0].Push_comment_to_child_cases__c=='Yes'){
            system.debug('inside PUsh the comments to Child case');
            if(Caseid!=null){           
                Map<id,Case> CaseMap= new Map<id,Case>([Select id,Master_Case__c,ContactId,Contact.email,Case_CC_List__c from Case where Master_Case__c=:Caseid]);
                system.debug('CaseMap '+CaseMap);
                
                //Insert Feed Item for Child Cases :Start
                FeedItem fi=[Select id,Body,ParentId,Status,Title,Type,Visibility FROM FeedItem where ParentId=:Caseid order by CreatedDate Desc Limit 1];
                system.debug('feeditem '+fi);
                String CaseCmnt=fi.body.removeStart('<p>');
                CaseCmnt=CaseCmnt.removeEnd('</p>');
                system.debug('CaseCmnt '+CaseCmnt);
                List<feeditem> FeedListtoInsert= new List<feeditem>();
                for(Id Cid:CaseMap.keyset()){
                    FeedItem newFI= new FeedItem(ParentId=Cid,body=CaseCmnt,Visibility='AllUsers');
                    FeedListtoInsert.add(newFI);
                }
                
                TriggerUtility.SkipFeedItemTriggerExecuted();
                insert FeedListtoInsert;
                system.debug('FeedListtoInsert  '+FeedListtoInsert);
                //Insert Feed Item for Child Cases :End
                
                //Send Email Notifications to Customers: Start
                if(MasterCaseList[0].Share_with_Customer__c=='Yes'){
                    for(Case cs:CaseMap.values()){
                        CCEmaillist.add(cs.Contact.email);                       
                        if(cs.Case_CC_List__c!=null && cs.Case_CC_List__c!=''){
                            CCEmaillist.addall(cs.Case_CC_List__c.split(','));
                        }
                    }
                    system.debug('CCEmaillist  '+CCEmaillist);
                    CCEmaillist.add('manngurjinder2@gmail.com');
                    String [] ListOfStates = new List<string>();
                    //OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
                    
                    list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] sendingToAdd = new String[]{'kgupta@zscaler.com','gmann@zscaler.com'};
                    mail.setToAddresses(sendingToAdd);
                    
                    //String[] sendingToBccAdd = new String[]{'manngurjinder2@gmail.com'};

                    //if ( owea.size() > 0 ) {
                        //mail.setOrgWideEmailAddressId(owea[0].Id);
                   // }else{ 
                    mail.setsenderDisplayName('Zscaler Case Support Testing');
                    //}
                    mail.setbccAddresses(CCEmaillist);
                    mail.setSubject('Master Case Testing ');
                    mail.setPlainTextBody('Hi All \n' + 'Please find the Latest Comments Added for your Case:- \n' +CaseCmnt +'\n' +'Thank You');
                    messageList.add(mail);
                    system.debug('before sending email');
                    //Messaging.sendEmail(messageList);
                    system.debug('after sending email');                    
                }                
                //Send Email Notifications to Customers: End
            }
        }else{
            system.debug('inside else ');
        }
    } */
}