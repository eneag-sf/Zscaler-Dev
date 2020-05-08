/*
 * Trigger on Survey Object
 *  Author              Version     Description
 *  Raghu Manchiraju    v1.0        Initial Trigger Helper. 
 * 
 */ 
public class SurveyTriggerHelper 
{
    public static boolean skipTrigger = false;
    
    public void OnBeforeInsert(List<Survey__c> newSurveys)
    {
        /*for(Survey__c sv : newSurveys)
        {
            Date currentDate = date.newinstance(sv.CreatedDate.year(), sv.CreatedDate.month(), sv.CreatedDate.day());
            sv.Reminder_1_Sent_Date__c = currentDate.addDays(5);
            sv.Reminder_2_Sent_Date__c = currentDate.addDays(8);
        }*/
    }
    
    public void OnAfterInsert(List<Survey__c> newSurveys)
    {
        
    }
    
    public void OnBeforeUpdate(Map<Id,Survey__c> oldSurveys,Map<Id,Survey__c> newSurveys)
    {
        List<Survey__c> dsatneededlst = new List<Survey__c>();
        for(Survey__c sury : newSurveys.values())
        {
            Date currentDate = date.newinstance(sury.CreatedDate.year(), sury.CreatedDate.month(), sury.CreatedDate.day());
            sury.Reminder_1_Sent_Date__c = currentDate.addDays(5);
            sury.Reminder_2_Sent_Date__c = currentDate.addDays(8);
            
            if(sury.Will_you_recommend_Zscaler__c != null) //&& oldSurveys.get(sury.Id).Will_you_recommend_Zscaler__c == null
            {
                sury.Survey_Response_Received__c = true;
                sury.Survey_Status__c = 'Response Received';
                
                //NPS
                if(sury.Will_you_recommend_Zscaler__c <=6)
                {
                    sury.NPS_Category__c='Detractor';
                }
                else if(sury.Will_you_recommend_Zscaler__c == 7 || sury.Will_you_recommend_Zscaler__c ==8)
                {
                    sury.NPS_Category__c= 'Passive';
                }
                else
                {
                    sury.NPS_Category__c= 'Promoter';
                }
                
                //CES
                if(sury.Easy_to_handle_Issue__c == '1 - Strongly Disagree' ||sury.Easy_to_handle_Issue__c == '2 - Disagree'
                   || sury.Easy_to_handle_Issue__c == '3 - Somewhat Disagree' || sury.Easy_to_handle_Issue__c == '4 - Neutral')
                {
                    sury.CES_Category__c = 'Detractor';
                }
                else if(sury.Easy_to_handle_Issue__c == '5 - Somewhat Agree')
                {
                    sury.CES_Category__c = 'Passive';
                }
                else
                {
                    sury.CES_Category__c = 'Promoter';
                }
                
                //CSAT
                if(sury.Rate_your_experience__c <=3)
                {
                    sury.CSAT_Category__c = 'Not Satisfied';
                    
                }
                else if(sury.Rate_your_experience__c >3 && sury.Rate_your_experience__c <=5)
                {
                    sury.CSAT_Category__c = 'Satisfied';
                }
                
                if((sury.Will_you_recommend_Zscaler__c >= 8 || sury.Rate_your_experience__c >3 || 
                  sury.Easy_to_handle_Issue__c == '6 - Agree' || sury.Easy_to_handle_Issue__c == '7 - Strongly Agree') &&
                   (sury.Survey_Outcome__c != 'DSAT Ticket Needed' && sury.Survey_Outcome__c != 'DSAT Ticket Created'))
                {
                    sury.Survey_Outcome__c = 'Positive Survey';
                }
                
                if((sury.Will_you_recommend_Zscaler__c <=6 || sury.Easy_to_handle_Issue__c == '1 - Strongly Disagree' ||sury.Easy_to_handle_Issue__c == '2 - Disagree'
                   || sury.Easy_to_handle_Issue__c == '3 - Somewhat Disagree' || sury.Easy_to_handle_Issue__c == '4 - Neutral'
                  ||sury.Rate_your_experience__c <=3) &&
                   sury.DSAT_Ticket_Number__c == null)
                {
                    sury.Survey_Outcome__c = 'DSAT Ticket Needed';
                    dsatneededlst.add(sury);
                }
            }
        }

        if(!dsatneededlst.isEmpty() && !TriggerUtility.isDSATCaseCreationExecuted()){
            createDSATCases(dsatneededlst);
            TriggerUtility.DSATCaseCreationExecuted();
        }
    }

    public void createDSATCases(List<Survey__c> surlst){
        Id caseDSATRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DSAT_Ticket').getRecordTypeId();
        List<Case> cslst = new List<Case>();
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        
        String SurveyDefaultowner= ZscalerCustomSetting__c.getInstance('SurveyDefaultowner')!=null && ZscalerCustomSetting__c.getInstance('SurveyDefaultowner').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SurveyDefaultowner').Value__c:'0050g00000665LtAAI';
        
        for(Survey__c sur: surlst){
            if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('SurveyCaseDefaults')){
                DefaultData__c dd = ddmap.get('SurveyCaseDefaults');
                Case cs = new Case(RecordTypeId = caseDSATRT);
                cs.Case_Category__c = dd.Category__c;
                cs.Subject = 'Customer : ' + sur.Account_Name__c + ' is completely Dissatisfied.';
                cs.Status = dd.Stage_Status__c;
                cs.Priority = dd.Priority__c;
                cs.AccountId = dd.Account_Id__c;
                cs.Product_New__c = sur.Case_Product__c;
                cs.ParentId = sur.Case__c;
                if(sur.Case_Owner_Manager__c!=null){
                    cs.OwnerId = sur.Case_Owner_Manager__c; 
                }else{
                    cs.OwnerId = id.valueof(SurveyDefaultowner);
                }                
                cs.ContactId = sur.Contact__c;
                cs.Survey__c = sur.Id;
                //cs.DSAT_Survey_Reference__c = sur.id;
                cslst.add(cs);
            }
        }
        insert cslst;
        Map<Id,Id> surIdMap = new Map<Id,Id>();
        for(Case cs:cslst){
            surIdMap.put(cs.Survey__c, cs.Id);
        }
        for(Survey__c s:surlst){
            if(surIdMap.containsKey(s.Id)){
                s.DSAT_Case_Reference__c = surIdMap.get(s.id);
            }
        }
        //update surlst;
    }
    
    public void onAfterUpdate(Map<Id,Survey__c> oldSurveys,Map<Id,Survey__c> newSurveys)
    {
        
    }
    
    public void onBeforeDelete(Map<Id,Survey__c> oldSurveys)
    {
        
    }
    
    public void onAfterDelete(Map<Id,Survey__c> oldSurveys)
    {
        
    }
    
    public void onAfterUndelete(Map<Id,Survey__c> newSurveys)
    {
        
    }

}