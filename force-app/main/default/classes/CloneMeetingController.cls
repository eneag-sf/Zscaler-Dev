public class CloneMeetingController {
	@AuraEnabled
    public static Case cloneCase(String caseId){
        System.debug('here.........'+caseId);
        if(caseId != null && caseId != ''){
            case cs = [select id, RecordTypeId, Product_New__c, Priority, Case_Type__c, OwnerId ,AccountId, ContactId,Requestor_s_Email__c   from Case where id =: caseId ];
            Case cloneCase = new Case();
            cloneCase.RecordTypeId = cs.RecordTypeId;
            cloneCase.Product_New__c = cs.Product_New__c;
            cloneCase.Priority = cs.Priority;
            cloneCase.Case_Type__c = cs.Case_Type__c;
            cloneCase.OwnerId = cs.OwnerId;
            cloneCase.AccountId = cs.AccountId;
            cloneCase.ContactId = cs.ContactId;
            insert cloneCase;
            List<CaseTeamMember> ctList = [select id, MemberId, TeamRoleId from CaseTeamMember where parentId =: caseId];
            if(ctList.size()>0){
                List<CaseTeamMember> newCtList = new List<CaseTeamMember>();
                for(CaseTeamMember ct:ctList){
                    CaseTeamMember cseMember = null;
                    cseMember = new CaseTeamMember();
                    cseMember.MemberId = ct.MemberId;
                    cseMember.ParentId = cloneCase.Id;
                    cseMember.TeamRoleId = ct.TeamRoleId;
                    newCtList.add(cseMember);
                }
                if(newCtList.size()>0){
                    insert newCtList;
                }
            }
            return cloneCase;
        }
        return null;
    }
}