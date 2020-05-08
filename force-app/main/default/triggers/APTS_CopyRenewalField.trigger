trigger APTS_CopyRenewalField on Apttus_Proposal__Proposal_Line_Item__c (before insert, before update) {
    List<Apttus_Proposal__Proposal_Line_Item__c> propLitemList = Trigger.New;
    system.debug('Trigger Executed');
    Map<string,Apttus_Proposal__Proposal_Line_Item__c> propLitemMap = new Map<string,Apttus_Proposal__Proposal_Line_Item__c>();
    Set<id> proposalIdSet = new Set<id> ();
    for(Apttus_Proposal__Proposal_Line_Item__c  prli: Trigger.New) {
        proposalIdSet.add(prli.Apttus_Proposal__Proposal__c);
    }
    List<Apttus_Proposal__Proposal_Line_Item__c> allpropLitemList = new  List<Apttus_Proposal__Proposal_Line_Item__c> ();
    allpropLitemList = [select id,Apttus_QPConfig__DerivedFromId__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in :proposalIdSet];
    for(Apttus_Proposal__Proposal_Line_Item__c propLitem : allpropLitemList ) {
        if(propLitem.Apttus_QPConfig__DerivedFromId__c != null) {
            propLitemMap.put(string.valueof(propLitem.Apttus_QPConfig__DerivedFromId__c).substring(0,15),propLitem );
        }
    }
    
    
    system.debug('Trigger Executed1--'+propLitemMap);
    if(propLitemMap.size() > 0) {
        List<Apttus_Config2__LineItem__c> lineitemlist = new list<Apttus_Config2__LineItem__c> ();
        lineitemlist = [select id,Apttus_Config2__ConfigurationId__c,APTS_ACV__c,APTS_Upsell_Corp_ACV__c,Apttus_Config2__AssetLineItemId__c, Apttus_Config2__LineStatus__c,   APTS_Upsell_Carve__c,APTS_Renewal_Corp_ACV__c, APTS_Renewal_Gap__c,APTS_Renewal_Base__c  
        from Apttus_Config2__LineItem__c where id IN:propLitemMap.keyset()];
        
        
        Map<string,List<Apttus_Config2__LineItem__c>> configLItemMap = new Map<string,List<Apttus_Config2__LineItem__c>>();
        Map<string,decimal> configRenewData = new Map<string,decimal>();
        Map<string,decimal> configUpsellData = new Map<string, decimal>();
        Map<string,decimal> configRenewDataclone = new Map<string,decimal>();
        Map<string,decimal> configUpsellDataclone = new  Map<string, decimal>();
        
        system.debug('!!!--'+lineitemlist);
        List<Apttus_Config2__LineItem__c> litemList;
        for(Apttus_Config2__LineItem__c litem : lineitemlist) {
            Decimal renewData = 0;
            Decimal upselldata = 0;
            litemList = new List<Apttus_Config2__LineItem__c>();
            if(configLItemMap.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) != null) {
                litemList = configLItemMap.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
            }
            if(configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) != null) {
                renewData = configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
            }
            if(configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) != null) {
                upselldata = configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
            }
            if(litem.Apttus_Config2__LineStatus__c == 'Renewed' && litem.APTS_Renewal_Gap__c != null) {
                
                renewData = renewData + (-1 * litem.APTS_Renewal_Gap__c);
                configRenewData.put(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15),renewData);
                configRenewDataclone.put(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15),renewData);
            }
            if(litem.Apttus_Config2__LineStatus__c != 'Renewed' && litem.APTS_ACV__c != null && litem.APTS_ACV__c > 0) {
                upselldata = upselldata + litem.APTS_ACV__c ;
                configUpsellData.put(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15),upselldata);
                configUpsellDataclone.put(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15),upselldata);
            }
        }
     
        system.debug('!!!--'+configRenewDataclone);
        system.debug('!!!--'+configUpsellDataclone);
        List<Apttus_Config2__LineItem__c> lineItemsToUpdate = new List<Apttus_Config2__LineItem__c>();
        for(Apttus_Config2__LineItem__c litem : lineitemlist) {
            system.debug('litem.APTS_Renewal_Gap__c'+litem.APTS_Renewal_Gap__c);
            system.debug('litem.APTS_Renewal_Gap__c'+litem.Apttus_Config2__LineStatus__c);
            system.debug('#######---'+string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
            system.debug('litem.APTS_Renewal_Gap__c--1'+configRenewData.containskey(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
            if(configRenewData.containskey(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) == true) {
                system.debug('litem.Apttus_Config2__LineStatus__c '+litem.Apttus_Config2__LineStatus__c);
                system.debug('litem.APTS_Renewal_Gap__c=='+litem.APTS_Renewal_Gap__c);
                if(litem.Apttus_Config2__LineStatus__c == 'Renewed' ) {
                    system.debug('@@'+configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                    system.debug('@@'+configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                    if(configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) > 0) {
                        if(configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) >  0) {
                            if(configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) <= configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15))) {
                                system.debug('in 1');
                                litem.APTS_Renewal_Corp_ACV__c = litem.APTS_Renewal_Base__c ;
                                litem.APTS_Upsell_Carve__c = litem.APTS_Renewal_Gap__c;
                                lineItemsToUpdate.add(litem);
                                Decimal renewdata = configUpsellDataclone.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
                                renewdata = renewdata + litem.APTS_Renewal_Gap__c;
                                configUpsellDataclone.put(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15),renewdata);
                            }   else {
                                
                                Decimal percentage = ((litem.APTS_Renewal_Gap__c * -1) * configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)))/configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
                                system.debug('in 2' + percentage);
                                system.debug('in 2' + (litem.APTS_Renewal_Gap__c * -1));
                                system.debug('in 2' + configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                                system.debug('in 2' + configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                                litem.APTS_Renewal_Corp_ACV__c = litem.APTS_ACV__c + percentage;
                                litem.APTS_Upsell_Carve__c =  percentage;
                                lineItemsToUpdate.add(litem);
                                Decimal renewdata = configUpsellDataclone.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
                                renewdata = renewdata - litem.APTS_Upsell_Carve__c ;
                                configUpsellDataclone.put(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15),renewdata);
                            }
                        } 
                    } else {
                        litem.APTS_Renewal_Corp_ACV__c = litem.APTS_ACV__c ;
                        
                        lineItemsToUpdate.add(litem);
                    }
                }
            } else {
                   if(litem.Apttus_Config2__LineStatus__c == 'Renewed') { 
                    litem.APTS_Renewal_Corp_ACV__c = litem.APTS_ACV__c;
                     lineItemsToUpdate.add(litem);
                     }
                }
        }
        
        for(Apttus_Config2__LineItem__c litem : lineitemlist) {
            if(litem.Apttus_Config2__LineStatus__c != 'Renewed' && litem.APTS_ACV__c != null && litem.APTS_ACV__c > 0) {
                
                if(!configRenewData.containsKey(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15))) {
                    system.debug('$$$-'+configRenewData.containsKey(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                    litem.APTS_Upsell_Corp_ACV__c = litem.APTS_ACV__c;
                    litem.APTS_Renewal_Corp_ACV__c = 0;
                    lineItemsToUpdate.add(litem);
                } else {
                    system.debug('$$$-'+configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                    if(configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) > 0) {
                        if(configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) >  0) {
                            if(configRenewData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)) <= configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15))) {
                                system.debug('$$1--'+litem.APTS_ACV__c);
                                system.debug('$$2--'+configUpsellDataclone.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                                system.debug('$$3--'+configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)));
                                litem.APTS_Upsell_Corp_ACV__c = (litem.APTS_ACV__c * configUpsellDataclone.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15)))/configUpsellData.get(string.valueof(litem.Apttus_Config2__ConfigurationId__c).substring(0,15));
                                litem.APTS_Renewal_Corp_ACV__c = 0;
                                lineItemsToUpdate.add(litem);
                            }   else {
                                litem.APTS_Upsell_Corp_ACV__c = 0;
                                litem.APTS_Renewal_Corp_ACV__c = 0;
                                lineItemsToUpdate.add(litem);
                            }
                        }
                    } else {
                        litem.APTS_Upsell_Corp_ACV__c = litem.APTS_ACV__c;
                        litem.APTS_Renewal_Corp_ACV__c = 0;
                        lineItemsToUpdate.add(litem);
                    }
                }
            }
        } 
        system.debug('@@@--lineItemsToUpdate-'+lineItemsToUpdate);
        if(lineItemsToUpdate.size() > 0) {
            update lineItemsToUpdate;
            
        }
     }
}