global Class APTS_AssetLineItemComponentController
{
    Public String accntId{get; set;}
    Public String noOfDays{get; set;}
    public List<Apttus_Config2__AssetLineItem__c> lstAssetExpiring = new List<Apttus_Config2__AssetLineItem__c>();
    public Map<Id, Apttus_Config2__AssetLineItem__c> mapAssetExpiring = new Map<Id, Apttus_Config2__AssetLineItem__c>();
    
    public List<Apttus_Config2__AssetLineItem__c> GetlstAssetExpiring (){
    
        date dateAfter90Days = date.today().addDays(90);
        date dateAfter60Days = date.today().addDays(60);
        date dateAfter30Days = date.today().addDays(30);
        date dateAfter7Days = date.today().addDays(7);       
        
        
        
        for(Apttus_Config2__AssetLineItem__c assetLineItem : [select Id, Apttus_Config2__ProductId__r.Name, 
            Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__AccountId__c, Apttus_Config2__AssetStatus__c from Apttus_Config2__AssetLineItem__c 
            where Apttus_Config2__AccountId__c =: accntId and Apttus_Config2__AssetStatus__c = 'Activated'])
        {
                    System.debug('Bose  assetLineItem  ' + assetLineItem );
            if(noOfDays == '90')
            {
               
                if(assetLineItem.Apttus_Config2__EndDate__c == dateAfter90Days)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                    }

                }
            }
            else if(noOfDays == '60')
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == dateAfter60Days)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                    }
                }
            }
            else if(noOfDays == '30')
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == dateAfter30Days)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                    }
                }
            }
            else if(noOfDays == '7')
            {
                if(assetLineItem.Apttus_Config2__EndDate__c == dateAfter7Days)
                {
                    if(!mapAssetExpiring.containsKey(assetLineItem.Id))
                    {
                        mapAssetExpiring.put(assetLineItem.Id,assetLineItem);
                    }
                }
            }
        }
        
        lstAssetExpiring = mapAssetExpiring.Values();
        return lstAssetExpiring;
    
    }
}