@isTest
public class UpdateRollupDetailsonCampaigns_Test{
    
    
    static void testdatamethod1(){
        List<ZscalerSetting__c> zsclist= new List<ZscalerSetting__c>();
        ZscalerSetting__c zsc1=new ZscalerSetting__c(Name='CampaignExceptions1',value__c='70170000000cGzmAAE;7010g0000016Ox3AAE;7010g0000016OwwAAE');
        zsclist.add(zsc1);
        ZscalerSetting__c zsc2=new ZscalerSetting__c(Name='CampaignExceptions2',value__c='7010g0000016OxPAAU;7010g0000016OxeAAE');
        zsclist.add(zsc2);
        insert zsclist;
        List<Campaign> CmpgnList= new List<Campaign>();
        List<lead> LeadList= new List<Lead>();
        
        for(Integer i=0;i<1;i++){
            Campaign cm = new Campaign();
            cm.name='ZPA Interactive' + i;
            cm.Department__c = '5000-Corporate Marketing';
            cm.Geo__c = 'GLOBAL';
            cm.StartDate = Date.today();
            cm.EndDate = Date.today()+30;
            cm.Fiscal_Year__c = 'All Time';
            cm.Type = 'Default';
            cm.Campaign_Type__c = 'Assets';
            cm.Activity_Details__c = 'ebook';
            cm.Count_of_MCI_s__c =0;
            cm.Count_of_SCI_s__c =0;
            
            CmpgnList.add(cm);
        }
        if(CmpgnList.size()>0){
            insert CmpgnList;
        }   
        
        for(Integer i=0;i<3;i++){
            Lead lead = new Lead(FirstName = 'Test'+i, LastName = 'Lead'+i, First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
            LeadList.add(lead);
        }
        insert LeadList;
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        for(Campaign cmpg:CmpgnList){
            for(Lead lead:Leadlist){
                CampaignMember CM= new CampaignMember(Campaignid=cmpg.id,Leadid=lead.id,Status='Sent');
                CmpgnMemList.add(CM);
            }
            
        }
        insert CmpgnMemList;
        
    }
            
    static testmethod void test1(){
        test.starttest();
        testdatamethod1();
        UpdateRollupDetailsonCampaigns batch= new UpdateRollupDetailsonCampaigns();
        Database.executeBatch(batch,1);
        test.stoptest();
    }
}