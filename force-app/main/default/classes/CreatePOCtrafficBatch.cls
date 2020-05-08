global class CreatePOCtrafficBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    private Integer count = 0;
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([select Id, Org_ID_with_cloud__c from Provisioning_Request__c where Org_ID_with_cloud__c != null and Opportunity__r.IsClosed=false and RecordType.DeveloperName='SHIFT_Evaluation']);
    }
    
    global void execute (Database.BatchableContext context, List<sObject> provisioningRequests)
    {
        for(sObject provisioningRequest : provisioningRequests)
        {
            Provisioning_Request__c thisProvisioningRequest = (Provisioning_Request__c)provisioningRequest;
            Date eightDaysAgo = Date.today().addDays(-8);
            Date oneDayAgo = Date.today().addDays(-1);
            DateTime weekStart = DateTime.newInstance(eightDaysAgo.year(), eightDaysAgo.month(), eightDaysAgo.day(), 0, 0, 0);
            DateTime weekEnd = DateTime.newInstance(oneDayAgo.year(), oneDayAgo.month(), oneDayAgo.day(), 23, 59, 59);
            HttpResponse httpresponse = ProvisioningSHIFTPOCHelper.createPOCtraffic(thisProvisioningRequest.Org_ID_with_cloud__c, weekStart, weekEnd);
            if(httpresponse != null)
            {
                String responseBody = httpresponse.getBody().replace('[', '').replace(']','');
                Map<String,String> responseMap = (Map<String,String>)JSON.deSerialize(responseBody,Map<String,String>.class);
                System.debug('*******');
                System.debug(responseMap);
                if(responseMap.containsKey('block') || responseMap.containsKey('total'))
                {
                    Integer block = parseInteger(responseMap.get('block'));
                    Integer total = parseInteger(responseMap.get('total'));
                    if(block != null || total != null)
                    {
                        POC_Traffic__c poctraffic = new POC_Traffic__c(Provisioning_Request__c = thisProvisioningRequest.Id, Upload_Date__c=Date.today(), Blocks__c = block, Transactions__c = total);
                        insert poctraffic;
                        count++;
                    }
                }
            }
        }
                
    }
    
    private Integer parseInteger(Object value)
    {
        if(value == null)
        {
            return null;
        }
        if(value instanceOf Integer)
        {
            return (Integer)value;
        }
        else
        {
            try
            {
                return Integer.valueOf(value);
            }
            catch(Exception ex) {}
        }
        return null;
    }
    
    global void finish(Database.BatchableContext context)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> {'rsrinivasan@zscaler.com', 'HChikarsal@zscaler.com'});
        mail.setSenderDisplayName('zscaler');
        mail.setSubject('Weekly Job of Provisioning Traffic Finished');
        mail.setPlainTextBody('There are ' + count + ' traffic record(s) created for last week.');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
    }
}