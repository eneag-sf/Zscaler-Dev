public class ExecutiveBriefingApprovalController {
    
    @AuraEnabled
    public static Map<String,string> SubmitForApproval(string ExecutiveReqRecId){
        
        
        Map<String,string> ResultMap = new Map<String,string>();
        
        if(ExecutiveReqRecId != null){
            Executive_Briefing_Request__c ExecutiveReqRec = [select   Id,Name,Internal_Attendees__c,Approval_Status__c 
                                                             from Executive_Briefing_Request__c Where
                                                             Id=:ExecutiveReqRecId limit 1];
            
            if(ExecutiveReqRec.Internal_Attendees__c == null || String.isBlank(ExecutiveReqRec.Internal_Attendees__c)){
                ResultMap.put('State', 'Error');
                ResultMap.put('Message', 'Unable to Submit for Approval, Please add Internal attendees.');
            }else if(ExecutiveReqRec.Approval_Status__c == 'Approved'){
                ResultMap.put('State', 'Error');
                ResultMap.put('Message', 'Unable to submit for approval, this request was already approved.');
            }else{
                try{
                    Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
                    appReq.setComments('Submitting request');
                    appReq.setObjectId(ExecutiveReqRecId);
                    Approval.ProcessResult result = Approval.process(appReq);
                    ResultMap.put('State', 'Success');
                    ResultMap.put('Message', 'Executive Request Submitted for Approval');
                    
                }catch(Exception exp){
                    ResultMap.put('State', 'Error');
                    if(exp.getMessage().contains('ALREADY_IN_PROCESS')){
                        ResultMap.put('Message', 'Unable to Submit for Approval, Request is already in approval process.'); 
                    }else{
                        ResultMap.put('Message', exp.getMessage()); 
                    }
                } 
            }
        }
        return ResultMap;
    }
}