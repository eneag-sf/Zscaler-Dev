global Class APTS_AssetExpPartnerNotfController
{
    Public String accntId{get; set;}
    Public String billToId{get; set;}
    Public String noOfDays{get; set;}
    Public Address billToAddress{get; set;}
    Public String BillingStreet{get; set;}
      Public String BillingCountry{get; set;}
      Public String BillingPostalCode{get; set;}
      Public String BillingState{get; set;}
      Public String BillingCity{get; set;}
    Public decimal totalAmount{get; set;}
    public List<Apttus_Config2__AssetLineItem__c> lstAssetExpiring = new List<Apttus_Config2__AssetLineItem__c>();
    public Map<Id, Apttus_Config2__AssetLineItem__c> mapAssetExpiring = new Map<Id, Apttus_Config2__AssetLineItem__c>();
    
    public List<Apttus_Config2__AssetLineItem__c> GetlstAssetExpiring (){
    
        integer level_1_Notification = null;
        integer level_2_Notification = null;
        integer level_3_Notification = null;
        integer level_4_Notification = null;
        integer level_1_Notification_AfterExpiry = null;
        
        date dateOnLevel_1_Notification = null;     
        date dateOnLevel_2_Notification = null;     
        date dateOnLevel_3_Notification = null;
        date dateOnLevel_4_Notification = null;     
        date dateOnlevel_1_Notification_AfterExpiry = null;
        date todaysDate = date.today();      
        totalAmount = 0;
        for(Apttus__APTS_Admin__c adLevel : [select IsDeleted, Name, Apttus__Value__c from Apttus__APTS_Admin__c where IsDeleted = false])
        {
            if(adLevel.Name == 'APTS_Level1_Notification')
            {
                level_1_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_1_Notification = date.today().addDays(level_1_Notification);
            }
            else if(adLevel.Name == 'APTS_Level2_Notification')
            {
                level_2_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_2_Notification = date.today().addDays(level_2_Notification);
            }
            else if(adLevel.Name == 'APTS_Level3_Notification')
            {
                level_3_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_3_Notification = date.today().addDays(level_3_Notification);
            }
            else if(adLevel.Name == 'APTS_Level4_Notification')
            {
                level_4_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_4_Notification = date.today().addDays(level_4_Notification);
            }
            else if(adLevel.Name == 'APTS_Level1_Notification_On_Expire')
            {
                level_1_Notification_AfterExpiry = integer.valueof(adLevel.Apttus__Value__c);
                dateOnlevel_1_Notification_AfterExpiry = date.today().addDays(-level_1_Notification_AfterExpiry);
            }
        }
        
        
        for(Apttus_Config2__AssetLineItem__c assetLineItem : [select Id, Apttus_Config2__ProductId__r.ProductCode, 
            Apttus_Config2__ProductId__r.Description, Apttus_Config2__BasePrice__c, Apttus_Config2__NetPrice__c,  Apttus_Config2__NetUnitPrice__c,  APTS_Total_Discount_Percentage__c, Apttus_Config2__AccountId__c, 
            Apttus_Config2__AssetStatus__c, Apttus_Config2__BillToAccountId__c, Apttus_Config2__EndDate__c,Apttus_Config2__Quantity__c from Apttus_Config2__AssetLineItem__c 
            where Apttus_Config2__AccountId__c =: accntId and Apttus_Config2__AssetStatus__c = 'Activated' and Apttus_Config2__BillToAccountId__c =: billToId])
        {
            if(noOfDays == string.valueof(level_1_Notification))
            {
               
                if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_1_Notification)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                        
                    }

                }
            }
            else if(noOfDays == string.valueof(level_2_Notification))
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_2_Notification)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                        
                    }
                }
            }
            else if(noOfDays == string.valueof(level_3_Notification))
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_3_Notification)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                        
                    }
                }
            }
            else if(noOfDays == string.valueof(level_4_Notification))
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_4_Notification)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                        
                    }
                }
            }
            else if(noOfDays == '0')
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == todaysDate)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                        
                    }
                }
            }
            else if(noOfDays == ('-' + string.valueof(level_1_Notification_AfterExpiry)))
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == dateOnlevel_1_Notification_AfterExpiry)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                        
                    }
                }
            }
        }
        
        if(billToId != null)
        {
            Account billToAccnt = [SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                                   BillingCountry, BillingLatitude, BillingLongitude
                                                            FROM Account where Id =: billToId];
        
         
            BillingStreet = billToAccnt.BillingStreet;
            BillingCountry = billToAccnt.BillingCountry;
            BillingPostalCode = billToAccnt.BillingPostalCode ;
            BillingState = billToAccnt.BillingState ;
            BillingCity = billToAccnt.BillingCity ;
        }
        lstAssetExpiring = mapAssetExpiring.Values();
        
        for(Apttus_Config2__AssetLineItem__c ast : lstAssetExpiring )
        {
            totalAmount = totalAmount + ast.Apttus_Config2__NetPrice__c;
        }
        
        return lstAssetExpiring;
    
    }
}