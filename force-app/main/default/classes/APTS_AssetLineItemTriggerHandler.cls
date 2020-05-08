/**
* APTTUS
* @author           Shishir Bose
* Project:          ZScaler
* Description:      Class that will manage Asset Line Item trigger evernts
* Changes (Version)
* -------------------------------------
*           No.                       Autor                   Descripci�n
*           -----   ----------      --------------------    ---------------
* @version   1.0    07-Nov-2016     Shishir Bose            Creating trigger Class
* @version   2.0    25-Jul-2017     Vijay Prakash           Changed the logic to calculate the platform quantity for FY18 pricebook.
*                                                           New logic: Calculate the quantity based on ZSC-SIP, ZIA-PRO-BUNDLE,
*                                                           ZIA-BUS-BUNDLE, ZIA-TRANS-BUNDLE and ZIA-ELA-BUNDLE.
* @version   3.0    01-Aug-2018     Vijay Prakash           Fixed the No of Platform Seats issue
*************************************************************************************************************/
public class APTS_AssetLineItemTriggerHandler
{
    public void handleAfterInsertEvents(list<Apttus_Config2__AssetLineItem__c> lstAssets)
    {
        Set<Id> accountIdSetZIA = new Set<Id>();
        Set<Id> accountIdSetZPA = new Set<Id>();
        Set<String> setSKUCodes = new Set<String> {
                                        APTS_CONSTANTS.PROD_SKU_SIP,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU,
                                        APTS_CONSTANTS.PROD_SKU_ZPA_PRO,
                                        APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU,
                                        APTS_CONSTANTS.PROD_SKU_ZPA_ENT,
                                        APTS_CONSTANTS.PROD_SKU_ZPA_BUS,
                                        APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU
                                    };

        Set<Id> setProductIdsZIA = new Set<Id>();
        Set<Id> setProductIdsZPA = new Set<Id>();

        for (Product2 product : [select Id, Name,ProductCode from Product2 where ProductCode IN :setSKUCodes]) {
            if(product.ProductCode == APTS_CONSTANTS.PROD_SKU_SIP || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE  || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU  || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU){
                setProductIdsZIA.add(product.Id);
            }
            if(product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_PRO || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_ENT || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_BUS || product.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU){
                setProductIdsZPA.add(product.Id);
            }
        }

        for(Apttus_Config2__AssetLineItem__c asset: lstAssets)
        {
            if(setProductIdsZIA != null && setProductIdsZIA.size() > 0 && setProductIdsZIA.contains(asset.Apttus_Config2__ProductId__c))
            {
                if(!accountIdSetZIA.contains(asset.Apttus_Config2__AccountId__c))
                {
                    accountIdSetZIA.add(asset.Apttus_Config2__AccountId__c);
                }
            }

            if(setProductIdsZPA != null && setProductIdsZPA.size() > 0 && setProductIdsZPA.contains(asset.Apttus_Config2__ProductId__c))
            {
                if(!accountIdSetZPA.contains(asset.Apttus_Config2__AccountId__c))
                {
                    accountIdSetZPA.add(asset.Apttus_Config2__AccountId__c);
                }
            }
        }

        if(accountIdSetZIA.size() > 0)
        {
            updateAccountPlatformSeats(accountIdSetZIA, setProductIdsZIA);
        }

        if(accountIdSetZPA.size() > 0)
        {
            updateAccountPlatformSeatsZPA(accountIdSetZPA, setProductIdsZPA);
        }


    }

    private void updateAccountPlatformSeats(Set<Id> accountIdSet, Set<Id> productIdSet)
    {
        Apttus_Config2__AssetLineItem__c[] assetsofAccount;
        List<Apttus_Config2__AssetLineItem__c> latestAssets = null;
        List<Account> accountsToBeUpdated = new List<Account>();
        Date latestDate;
        for(Account account: [select Id, APTS_No_of_Platform_Seats__c, APTS_Platform_Subscription_End_Date__c from Account where Id in : accountIdSet])
        {
            assetsofAccount = [select Id, Apttus_Config2__EndDate__c, Apttus_Config2__AccountId__c, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__Quantity__c,
                Apttus_Config2__DeltaQuantity__c, Apttus_Config2__AssetStatus__c, Apttus_QPConfig__ProposalId__r.Has_New_Price_List__c from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c =: account.Id and Apttus_Config2__ProductId__c IN :productIdSet
                and Apttus_Config2__AssetStatus__c = 'Activated'
                ];
            latestAssets = null;
            latestDate = null;
            if(assetsofAccount != null && !assetsofAccount.isEmpty())
            {
                for(Apttus_Config2__AssetLineItem__c asset : assetsofAccount )
                {
                    if(!asset.Apttus_QPConfig__ProposalId__r.Has_New_Price_List__c
                        && asset.Apttus_Config2__ProductId__r.ProductCode != APTS_CONSTANTS.PROD_SKU_SIP) {
                        continue;
                    }
                    if(latestAssets != null)
                    {
                        if(latestDate < asset.Apttus_Config2__EndDate__c)
                        {
                            latestAssets = new List<Apttus_Config2__AssetLineItem__c>();
                            latestDate = asset.Apttus_Config2__EndDate__c;
                            latestAssets.add(asset);
                        }
                        else if(latestDate == asset.Apttus_Config2__EndDate__c)
                        {
                            latestDate = asset.Apttus_Config2__EndDate__c;
                            latestAssets.add(asset);
                        }
                    }
                    else
                    {
                        latestAssets = new List<Apttus_Config2__AssetLineItem__c>();
                        latestDate = asset.Apttus_Config2__EndDate__c;
                        latestAssets.add(asset);
                    }
                }

                if(latestAssets != null && latestAssets.size() > 0)
                {
                    account.APTS_No_of_Platform_Seats__c = 0;

                    for(Apttus_Config2__AssetLineItem__c ast : latestAssets)
                    {
                        account.APTS_No_of_Platform_Seats__c += ast.Apttus_Config2__Quantity__c;
                    }
                    account.APTS_Platform_Subscription_End_Date__c = latestDate;
                    accountsToBeUpdated.add(account);

                }
            }
        }

        if(accountsToBeUpdated.size() > 0)
        {
            update accountsToBeUpdated;
        }
    }

    public void updateAccountPlatformSeatsZPA(Set<Id> accountIdSet, Set<Id> productIdSet)
    {
        Apttus_Config2__AssetLineItem__c[] assetsofAccount;
        List<Apttus_Config2__AssetLineItem__c> latestAssets = null;
        Integer noOfEntitledZPAConnectors;
        List<Account> accountsToBeUpdated = new List<Account>();
        Date latestDate;
        for(Account account: [select Id, No_of_Platform_Seats_ZPA__c, Platform_Subscription_End_Date_ZPA__c from Account where Id in : accountIdSet])
        {
            assetsofAccount = [select Id, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__AccountId__c, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__Quantity__c,
                Apttus_Config2__DeltaQuantity__c, Apttus_Config2__AssetStatus__c, Apttus_QPConfig__ProposalId__r.Has_New_Price_List__c from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c =: account.Id and Apttus_Config2__ProductId__c IN :productIdSet
                and Apttus_Config2__AssetStatus__c = 'Activated'
                ];
            latestAssets = null;
            latestDate = null;
            noOfEntitledZPAConnectors = 0;
            if(assetsofAccount != null && !assetsofAccount.isEmpty())
            {
                for(Apttus_Config2__AssetLineItem__c asset : assetsofAccount )
                {
                    if(latestAssets != null)
                    {
                        if(latestDate < asset.Apttus_Config2__EndDate__c)
                        {
                            latestAssets = new List<Apttus_Config2__AssetLineItem__c>();
                            latestDate = asset.Apttus_Config2__EndDate__c;
                            latestAssets.add(asset);
                        }
                        else if(latestDate == asset.Apttus_Config2__EndDate__c)
                        {
                            latestDate = asset.Apttus_Config2__EndDate__c;
                            latestAssets.add(asset);
                        }
                    }
                    else
                    {
                        latestAssets = new List<Apttus_Config2__AssetLineItem__c>();
                        latestDate = asset.Apttus_Config2__EndDate__c;
                        latestAssets.add(asset);
                    }

                    // Number of Entitled ZPA Connnectors logic
                    if (asset.Apttus_Config2__BaseExtendedPrice__c != null
                        && asset.Apttus_Config2__StartDate__c != null
                        && asset.Apttus_Config2__EndDate__c != null) {
                        Integer subscriptionTerm = (Integer)Math.roundToLong(((asset.Apttus_Config2__StartDate__c.daysBetween(asset.Apttus_Config2__EndDate__c))/30.25));
                        Decimal annualSpend = (subscriptionTerm >= 12 ? asset.Apttus_Config2__BaseExtendedPrice__c/subscriptionTerm * 12 : asset.Apttus_Config2__BaseExtendedPrice__c/subscriptionTerm * subscriptionTerm);
                        Integer entitledConnectors = (Integer)Math.round((annualSpend / 6000));
                        noOfEntitledZPAConnectors += (entitledConnectors >= 2 ? entitledConnectors : 2);
                    }
                }
                
                if(latestAssets != null && latestAssets.size() > 0)
                {
                    account.No_of_Platform_Seats_ZPA__c = 0;

                    for(Apttus_Config2__AssetLineItem__c ast : latestAssets)
                    {
                        account.No_of_Platform_Seats_ZPA__c += ast.Apttus_Config2__Quantity__c;
                    }
                    account.Platform_Subscription_End_Date_ZPA__c = latestDate;

                }
                account.Number_Of_Entitled_ZPA_Connectors__c = noOfEntitledZPAConnectors;
                accountsToBeUpdated.add(account);
            }
        }

        if(accountsToBeUpdated.size() > 0)
        {
            update accountsToBeUpdated;
        }
    }
}