public class UpdateMasterCaseKeyfields implements Queueable {
    
    private List<id> CaseidList;
    
    public UpdateMasterCaseKeyfields(List<id> Caseidlist) {
        this.CaseidList = Caseidlist;
    }
    public void execute(QueueableContext context) {
        List<String> errorlst = new List<String>();
        List<String> successlst = new List<String>();       
        system.debug('inside PushCommentstoChildCases method');
        List<Case> MasterCaseList= new List<Case>();
        
        Id MasterCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Master_Case').getRecordTypeId();
        Map<id,Case> MasterCasemap= new Map<id,Case>([Select id,CaseNumber,Total_ARR__c,Median_Score__c,of_Cases__c,of_Top_Customers__c,Share_with_Customer__c,Push_comment_to_child_cases__c FROM Case where id=:CaseidList and recordtypeid=:MasterCaseRT]);
                
        //MasterCasemap=[];
        system.debug('MasterCasemap  '+MasterCasemap);
        Map<id,Case> ChildCaseMap= new Map<id,Case>([Select id,Median_Score__c,Master_Case__c,Accountid,Account.Current_ARR__c from Case where Master_Case__c=:CaseidList]);
        system.debug('ChildCaseMap '+ChildCaseMap.size());
            
        if(MasterCasemap!=null){
            for(Case mstrCase:MasterCasemap.values()){
                decimal Casecount=0;
                decimal TotalARR=0;
                decimal CustomerCount=0;
                decimal MedianScore=0;
                Set<id> AccidSet= new Set<id>();
                
                for(Case CS:ChildCaseMap.values()){
                    if(CS.Master_Case__c==mstrCase.id){
                        Casecount=Casecount+1;
                        if(CS.Median_Score__c!=null){
                            MedianScore=MedianScore+CS.Median_Score__c;
                        }
                        if(CS.Account.Current_ARR__c!=null){
                        TotalARR=TotalARR+CS.Account.Current_ARR__c;
                        }
                        AccidSet.add(CS.Accountid);
                    }
                    
                }
                CustomerCount=decimal.valueof(AccidSet.size());
                mstrCase.Total_ARR__c=TotalARR;
                mstrCase.of_Cases__c=Casecount;
                mstrCase.of_Top_Customers__c=CustomerCount;
                mstrCase.Median_Score__c=MedianScore;
            
            }
                    
            system.debug('MasterCasemap '+MasterCasemap);
            try{
                update MasterCasemap.values();
                successlst.add(MasterCasemap.values().Id);
            }catch(Exception e){ errorlst.add('Exception on Master Case:' + MasterCasemap.values().Id + '. Exception is ' + e);
            }
        }else{
            system.debug('inside else ');
        }
    }
}