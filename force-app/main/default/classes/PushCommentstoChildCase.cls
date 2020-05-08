public class PushCommentstoChildCase implements Queueable {
    
    private ID Caseid;
    
    public PushCommentstoChildCase(ID id) {
        this.Caseid = id;
    }
    public void execute(QueueableContext context) {
        system.debug('inside PushCommentstoChildCases method');
        List<Case> MasterCaseList= new List<Case>();
       
        MasterCaseList=[Select id,Share_with_Customer__c,Push_comment_to_child_cases__c FROM Case where id=:Caseid Limit 1];
        system.debug('Mstrcase '+MasterCaseList[0] +', Share with Customers :'+MasterCaseList[0].Share_with_Customer__c+', Push Comments to Child Cases'+MasterCaseList[0].Push_comment_to_child_cases__c);
        if(MasterCaseList[0].Push_comment_to_child_cases__c=='Yes'){
            system.debug('inside PUsh the comments to Child case');
            if(Caseid!=null){           
                Map<id,Case> CaseMap= new Map<id,Case>([Select id,Master_Case__c,ContactId,Contact.email,Case_CC_List__c from Case where Master_Case__c=:Caseid]);
                system.debug('CaseMap '+CaseMap);
                
                //Insert Feed Item for Child Cases :Start
                FeedItem fi=[Select id,Body,ParentId,Status,Title,Type,Visibility,IsRichText FROM FeedItem where ParentId=:Caseid order by CreatedDate Desc Limit 1];
                system.debug('feeditem '+fi);
                String CaseCmnt=fi.body;
                /*
                .removeStart('<p>');
                CaseCmnt=CaseCmnt.removeEnd('</p>');
                CaseCmnt=CaseCmnt.replace('</p><p>','&nbsp;');
                */
                // &lt;br/&gt;    <br/>   /n
                system.debug('CaseCmnt '+CaseCmnt);
                String Visibilitylevel='';
                if(MasterCaseList[0].Share_with_Customer__c=='Yes'){
                    Visibilitylevel='AllUsers';
                }else{
                    Visibilitylevel='InternalUsers';
                }
                List<feeditem> FeedListtoInsert= new List<feeditem>();
                for(Id Cid:CaseMap.keyset()){
                    FeedItem newFI= new FeedItem(ParentId=Cid,body=CaseCmnt,Visibility=Visibilitylevel,IsRichText=fi.IsRichText);
                    FeedListtoInsert.add(newFI);
                }
                
                TriggerUtility.SkipFeedItemTriggerExecuted();
                insert FeedListtoInsert;
                system.debug('FeedListtoInsert  '+FeedListtoInsert);
                //Insert Feed Item for Child Cases :End
                
                //Send Email Notifications to Customers: Start
                if(MasterCaseList[0].Share_with_Customer__c=='Yes'){
                    SendEmailstoCustomers Q2= new SendEmailstoCustomers(Caseid,CaseCmnt);
                    Q2.sendEmail();
                   // ID jobID = System.enqueueJob(Q2);                   
                }                
                //Send Email Notifications to Customers: End
            }
        }else{
            system.debug('inside else ');
        }
    }
}