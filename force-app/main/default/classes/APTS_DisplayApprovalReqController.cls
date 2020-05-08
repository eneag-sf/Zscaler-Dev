Public class APTS_DisplayApprovalReqController {
    public List<Apttus_Approval__Approval_Request__c> approvalReqList{get; set;} 
    public string queryString;
    public string approvalReqId{get; set;}
    public APTS_DisplayApprovalReqController () {
        string id = UserInfo.getUserId();
        string status = 'Assigned';
        approvalReqList = new List<Apttus_Approval__Approval_Request__c>();
        system.debug('Id: '+id);
        queryString = getQueryStringWithAllFields('Apttus_Approval__Approval_Request__c', 'Apttus_Approval__Assigned_To_Id__c=:id AND Apttus_Approval__Approval_Status__c =:status',' ORDER BY APTS_Submitted_Date__c DESC' );
        approvalReqList = Database.query(queryString);
 
    }
    public pagereference deleteReq() {
        Apttus_Approval__Approval_Request__c approvalReqToDelete = new Apttus_Approval__Approval_Request__c();
        approvalReqToDelete = [select id from Apttus_Approval__Approval_Request__c where id=:approvalReqId];
        delete approvalReqToDelete;
        PageReference returnpage = new PageReference('/');
        returnpage.setRedirect(true);
        return returnpage;
   
    }
    
    public pagereference editReq() {
        PageReference returnpage = new PageReference('/'+approvalReqId+'/e');
        returnpage.setRedirect(true);
        return returnpage;
    }
    
     public static string getQueryStringWithAllFields(String objectName, String whereClause, String orderClause){
        String selects = '';
     
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                //if (fd.isCreateable() && !fd.isUnique()){ // field is creatable
                    selectFields.add(fd.getName());
                //}
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        
        if (whereClause != null) {
            return 'SELECT ' + selects + ', Apttus_QPApprov__ProposalId__r.Name,Apttus_QPApprov__ProposalId__r.APTS_Proposal_Net_Price__c,Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c, Apttus_QPApprov__ProposalId__r.APTS_ACV__c,Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Opportunity__c,Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Opportunity__r.Name, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Opportunity__r.CloseDate,  Apttus_QPApprov__ProposalLineItemId__r.Name, Apttus_Approval__Related_Agreement__r.Name, Apttus_Approval__Initial_Submitter__r.Name,Apttus_Approval__Backup_From_User__r.Name'+' FROM ' + objectName + ' WHERE ' + whereClause + orderClause;
        }
        else {
            return 'SELECT ' + selects + ' FROM ' + objectName ;
        }
        
          
    }

}