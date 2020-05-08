@istest
public class DealRegToConvert_Test{
    static testmethod void testmethod1(){
        
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();

        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = system.today() + 30;
        deal.Market_Segment__c = 'ABC';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Approved';
        dealRegInsertList.add(deal);
        
        insert dealRegInsertList;
        deal = [Select Id,Market_Segment__c, Territory_Type__c from Deal_Reg__c where Id = :deal.Id];
        system.assertequals(deal.Market_Segment__c, 'ABC');
        system.assertequals(deal.Territory_Type__c, null);
        DealRegToConvert ctrl = new DealRegToConvert();
        system.debug(ctrl.dealregmap);
        ctrl.dealtoconvert = deal.Id;
        ctrl.checkconvert();
    }
    static testmethod void testmethod2(){
        User u1 = [Select Id from User where isActive = true and Profile.Name != 'System Administrator' and Profile.Name != 'Sales Ops Admin' limit 1];
        System.RunAs(u1){
            Campaign camp = new Campaign();
            camp.Name = 'Deal Registration';
            camp.EndDate = system.today() + 30;
            camp.IsActive = true;
            insert camp;
            ZscalerSetting__c zs = new ZscalerSetting__c();
            zs.Name = 'DealRegCampaign';
            zs.Value__c = ''+camp.Id;
            insert zs;
            System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
            ZscalerSetting__c zs1 = new ZscalerSetting__c();
            zs1.Name = 'DealRegCaseReviewOwnerId';
            zs1.Value__c = ''+userInfo.getuserId();
            insert zs1;
            
            list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
    
            Deal_Reg__c deal = new Deal_Reg__c();
            deal.End_Customer_Contact_Name__c = 'Test';
            deal.End_Customer_Contact_Last_Name__c= 'Test';
            deal.End_Customer_Country__c = 'US';
            deal.End_Customer_Domain__c = 'abc.com';
            deal.End_Customer_Email__c  = 'Test@abc.com';
            deal.End_Customer_Name__c = 'ABC Inc';
            deal.End_Customer_Phone__c = '123456789';
            deal.End_Customer_State__c = 'US';
            deal.DS_Review_Status__c = 'Pending Review';
            deal.Estimated_Amount__c = 1234567;
            deal.Expected_Close_Date__c = system.today() + 30;
            deal.Market_Segment__c = 'ABC';
            deal.Number_of_Users__c = 1234567;
            deal.Partner_Company_Name__c = 'Test partner';
            deal.Partner_Contact_Email__c = 'Test@partner.com';
            deal.Partner_Contact_Name__c = 'Test';
            deal.Partner_Contact_Last_Name__c  = 'Partner';
            deal.Partner_Country__c  = 'US';
            deal.Partner_Domain__c  = 'partner.com';
            deal.Source__c = 'Deal Reg';
            deal.Status__c = 'Approved';
            dealRegInsertList.add(deal);
            
            insert dealRegInsertList;
            deal = [Select Id,Market_Segment__c, Territory_Type__c from Deal_Reg__c where Id = :deal.Id];
            system.assertequals(deal.Market_Segment__c, 'ABC');
            system.assertequals(deal.Territory_Type__c, null);
            DealRegToConvert ctrl = new DealRegToConvert();
            system.debug(ctrl.dealregmap);
            ctrl.dealtoconvert = deal.Id;
            ctrl.checkconvert();
        }
    }
}