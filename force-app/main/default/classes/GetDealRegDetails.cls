@RestResource(urlMapping='/GetDealRegDetails/*')
global with sharing class GetDealRegDetails{
    global static Boolean avoidtriggers = false;
    @HttpGet
    global static Map<String, String> doGet() {
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        Map<String,String> parmap = new Map<String, String>();
        if(req != null && req.params!= null && req.params.containskey('type') && EncodingUtil.urlDecode(req.params.get('type'),'UTF-8') == 'get_leads'){
            if(req.params.containskey('Start_Date') && EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8') != '' && req.params.containskey('End_Date') && EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8') != '' && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))){
                List<DealRegDeatails> dealreglst = new List<DealRegDeatails>();
                List<Deal_Reg__c> drlst = new List<Deal_Reg__c>();
                for(Deal_Reg__c ld: [Select Id, Send_to_FedRAMP__c, Send_to_FedRAMP_Date__c, Federal_Deal_Approved_OP__c, End_Customer_Email__c, End_Customer_Name__c , Partner_Role__c, Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c , Lead__c, Contact__c, Contact__r.AccountId, OwnerId, End_Customer_Domain__c, End_Customer_Street_Address__c, End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c  from Deal_Reg__c where Federal_Change__c >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and Federal_Change__c <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and Send_to_FedRAMP__c != 'Done']){
                    dealreglst.add(new DealRegDeatails(ld));
                    drlst.add(ld);
                }
                system.debug(dealreglst);
                if(!dealreglst.isEmpty()){
                    result.put('dealRegDetails', JSON.serialize(dealreglst));
                    System.enqueueJob(new ProcessDealReginPROD(drlst));
                }
            }
        }
        return result;
    }
    
    public class DealRegDeatails{
        public Id deaRegId;
        public String endCustomerName;
        public String partnerRole;
        public Id partnerAccId;
        public Decimal amount;
        public Date closeDate;
        public Id leadId;
        public Id contactId;
        public Id contactAccId;
        public Id ownerId;
        public String endCustomerDomain;
        public String endCustomerAddress;
        public String endCustomerCity;
        public String endCustomerState;
        public String endCustomerCountry;
        public String endCustomerPostalCode;
        public String endCustomerEmail;
        public boolean fedDealApproved;
        public DealRegDeatails(Deal_Reg__c dr){
            deaRegId = dr.Id;
            endCustomerName = dr.End_Customer_Name__c;
            partnerRole = dr.Partner_Role__c;
            partnerAccId = dr.Partner_Account__c;
            amount = dr.Estimated_Amount__c;
            closeDate = dr.Expected_Close_Date__c;
            leadId = dr.Lead__c;
            contactId = dr.Contact__c;
            contactAccId = dr.Contact__r.AccountId;
            ownerId = dr.OwnerId;
            endCustomerDomain = dr.End_Customer_Domain__c;
            endCustomerAddress = dr.End_Customer_Street_Address__c;
            endCustomerCity = dr.End_Customer_City__c;
            endCustomerState = dr.End_Customer_State__c;
            endCustomerCountry = dr.End_Customer_Country__c;
            endCustomerPostalCode = dr.End_Customer_Postal_Code__c;
            endCustomerEmail = dr.End_Customer_Email__c;
            fedDealApproved = dr.Federal_Deal_Approved_OP__c;
        }
        
    }
    
    public class ProcessDealReginPROD implements Queueable{
        List<Deal_Reg__c> drlst = new List<Deal_Reg__c>();
        public ProcessDealReginPROD(List<Deal_Reg__c> dl){
            drlst.addAll(dl);
        }
        public void execute(QueueableContext context) {
            for(Deal_Reg__c dr: drlst){
                dr.Status__c = 'Converted';
                dr.Send_to_FedRAMP__c = 'Done';
                dr.Send_to_FedRAMP_Date__c = system.now();
            }
            update drlst;
        }
    }
}