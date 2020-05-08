public class DealRegToConvert{
    public Id dealtoconvert{get;set;}
    private Map<Id, Deal_Reg__c> mapdealreg;
    public String urltonavigate{get;set;}
    public List<Deal_Reg__c> dealregmap { 
        get{
            mapdealreg = new Map<Id, Deal_Reg__c>([Select Id, Name, Status__c, Estimated_Amount__c, Expected_Close_Date__c, End_Customer_Name__c, Partner_Account__c, Partner_Account__r.Name, SCI__c, Territory_Type__c, Market_Segment__c,Approved_Date__c from Deal_Reg__c where OwnerId = :UserInfo.getUserId() and Status__c = 'Approved']); //Added Approved_Date__c as a part of CR# 289 :Gurjinder
            return mapdealreg.values();
        } set;
    }

    public Pagereference checkconvert(){
        List<Profile> prf = [Select Id, name from Profile where Id = :Userinfo.getProfileId()];
        if(dealtoconvert!= null && mapdealreg.containskey(dealtoconvert)){
            if(mapdealreg.get(dealtoconvert).SCI__c || mapdealreg.get(dealtoconvert).Territory_Type__c == 'ALL' || mapdealreg.get(dealtoconvert).Territory_Type__c == 'General Business' || mapdealreg.get(dealtoconvert).Territory_Type__c == 'Commercial' || mapdealreg.get(dealtoconvert).Market_Segment__c == 'Commercial' || mapdealreg.get(dealtoconvert).Market_Segment__c == 'SOHO' || mapdealreg.get(dealtoconvert).Market_Segment__c == 'SMB' || (!prf.isEmpty() && (prf[0].Name == 'System Administrator' || prf[0].name == 'Sales Ops Admin'))){
                urltonavigate = '/apex/DealRegConversion?id='+dealtoconvert;
            }else{
                String s = 'Cannot convert the deal registration <a href="/' +  mapdealreg.get(dealtoconvert).Id + '" target="_blank">' + mapdealreg.get(dealtoconvert).Name + '</a> as there is no SCI present. Create a new SCI on this deal registration, then convert to an opportunity.';
                urltonavigate = '';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,s);
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        return null;
    }
}