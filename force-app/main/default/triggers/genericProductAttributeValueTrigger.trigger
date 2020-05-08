trigger genericProductAttributeValueTrigger on Apttus_Config2__ProductAttributeValue__c (before insert, before update) {
    List<Id> lineItemIds = new List<Id>();
    Boolean isFedSKUpresent = false;
    Map<Id, Apttus_Config2__LineItem__c> mapPremiumSupportDetails = new Map<Id, Apttus_Config2__LineItem__c>();
    for (Apttus_Config2__ProductAttributeValue__c att : Trigger.new) {
        lineItemIds.add(att.Apttus_Config2__LineItemId__c);
    }

    for (Apttus_Config2__LineItem__c li : [SELECT Id, Apttus_Config2__ConfigurationId__r.Premium_Support_Source__c, Apttus_Config2__ConfigurationId__r.Premium_Support_Percentage__c,
                                                  Apttus_Config2__ConfigurationId__r.Managed_Premium_Support_Source__c, Apttus_Config2__ConfigurationId__r.Managed_Premium_Support_Percentage__c,
                                                  APTS_ProductCode__c, Apttus_Config2__ConfigurationId__r.Has_New_Price_List__c,
                                                  Apttus_Config2__ConfigurationId__r.Apttus_Config2__BillToAccountId__r.Has_Contracted_Support_Pricing__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apply_GSA_Schedule__c, Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c, Apttus_Config2__ConfigurationId__r.Contains_FED_Platform_SKUs__c
                                             FROM Apttus_Config2__LineItem__c
                                            WHERE Id IN :lineItemIds]) {

        if(li.Apttus_Config2__ConfigurationId__r.Contains_FED_Platform_SKUs__c > 0){
            isFedSKUpresent = true;
        }
        mapPremiumSupportDetails.put(li.Id, li);
    }

    if (Trigger.isInsert) {


        for (Apttus_Config2__ProductAttributeValue__c att : Trigger.new) {
            if (mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT) {
                att.Premium_Support_Percentage__c = mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Premium_Support_Percentage__c;
                att.Premium_Support_Source__c = mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Premium_Support_Source__c;
                att.Managed_Premium_Support_Percentage__c = mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Managed_Premium_Support_Percentage__c;
                att.Managed_Premium_Support_Source__c = mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Managed_Premium_Support_Source__c;
                if(mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apply_GSA_Schedule__c!= null && mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c != null && !mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apply_GSA_Schedule__c && !mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c && !isFedSKUpresent){
                    att.Support_Source__c = mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Premium_Support_Source__c;
                    att.Support_Percent__c = mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Premium_Support_Percentage__c;
                }else if(mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apply_GSA_Schedule__c!= null || mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c != null || isFedSKUpresent){
                    att.Support_Source__c = APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
                    att.Support_Percent__c = APTS_CONSTANTS.PAV_PERCENT_GSA;
                }
            }
        }
    }

    if (Trigger.isUpdate) {
        for (Apttus_Config2__ProductAttributeValue__c att: Trigger.new) {
            if(mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c != null && mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apply_GSA_Schedule__c!= null && !mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apply_GSA_Schedule__c && !mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c  && !isFedSKUpresent){
                if (att.APTS_Premium_Support_Type__c != Trigger.oldMap.get(att.Id).APTS_Premium_Support_Type__c) {
                    if (att.APTS_Premium_Support_Type__c.toLowerCase() == 'zscaler') {
                        att.Support_Source__c = att.Premium_Support_Source__c;
                        att.Support_Percent__c = att.Premium_Support_Percentage__c;
                    } else {
                        att.Support_Source__c = att.Managed_Premium_Support_Source__c;
                        att.Support_Percent__c = att.Managed_Premium_Support_Percentage__c;
                    }
                }
            }else if(isFedSKUpresent || mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apply_GSA_Schedule__c!= null || mapPremiumSupportDetails.get(att.Apttus_Config2__LineItemId__c).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c != null){
                att.Support_Source__c = APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
                att.Support_Percent__c = APTS_CONSTANTS.PAV_PERCENT_GSA;
            }
        }
    }
}