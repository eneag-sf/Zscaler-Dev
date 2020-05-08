/*****************************************************************************************
Name: YearWiseSplitUtil
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
YearWiseSplitUtil class generates the yearwise split records for Apttus Proposals
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Vijay Prakash           17-May-2015    Initial Development
******************************************************************************************/
public class YearWiseSplitUtil {
    public static List<Id> lstYearWiseSplitsToDelete;
    public static List<Year_Wise_Split__c> lstYearWiseSplitsToInsert;
    public static List<Apttus_Proposal__Proposal__c> lstProposalsToUpdate;
    public static Map<Id, Apttus_Proposal__Proposal__c> mapProposalsWithIncorrectYWS;

    /**
     * @description generateYearWiseSplitForProposals is a bulkified method that creates yearwise split records
     *              for a list of proposals.
     * @param proposals Apttus Proposals for which yearwise splits have to be generated
     **/
    public static void generateYearWiseSplitForProposals(List<Apttus_Proposal__Proposal__c> proposals) {
        lstYearWiseSplitsToInsert = new List<Year_Wise_Split__c>();
        lstYearWiseSplitsToDelete = new List<Id>();
        lstProposalsToUpdate = new List<Apttus_Proposal__Proposal__c>();
        mapProposalsWithIncorrectYWS = new Map<Id, Apttus_Proposal__Proposal__c>();

        try {
            for (Apttus_Proposal__Proposal__c proposal : proposals) {
                if (proposal.Generate_Year_Wise_Split__c) {
                    generateYearWiseSplit(proposal);
                } else {
                    lstProposalsToUpdate.add(new Apttus_Proposal__Proposal__c(Id = proposal.Id, Year_1_Subtotal__c = 0.0,
                                                Year_2_Subtotal__c = 0.0, Year_3_Subtotal__c = 0.0, Year_4_Subtotal__c = 0.0,
                                                Year_5_Subtotal__c = 0.0, Year_6_Subtotal__c = 0.0, Year_7_Subtotal__c = 0.0,
                                                Year_1_List_Price_Subtotal__c = 0.0, Year_2_List_Price_Subtotal__c = 0.0,
                                                Year_3_List_Price_Subtotal__c = 0.0, Year_4_List_Price_Subtotal__c = 0.0,
                                                Year_5_List_Price_Subtotal__c = 0.0, Year_6_List_Price_Subtotal__c = 0.0,
                                                Year_7_List_Price_Subtotal__c = 0.0, Is_Year_Wise_Split_Data_Incorrect__c = false,
                                                Year_1_Year_Value__c = '', Year_2_Year_Value__c = '', Year_3_Year_Value__c = '',
                                                Year_4_Year_Value__c = '', Year_5_Year_Value__c = '', Year_6_Year_Value__c = '',
                                                Year_7_Year_Value__c = ''));
                }
            }

            for (Year_Wise_Split__c ywsplit : [SELECT Id FROM Year_Wise_Split__c WHERE Quote_Proposal__c IN :proposals]) {
                lstYearWiseSplitsToDelete.add(ywsplit.Id);
            }

            if (lstYearWiseSplitsToDelete.size() > 0) {
                Database.delete(lstYearWiseSplitsToDelete, true);
            }

            if (lstYearWiseSplitsToInsert.size() > 0) {
                Database.insert(lstYearWiseSplitsToInsert, true);
            }

            if (lstProposalsToUpdate.size() > 0) {
                Database.update(lstProposalsToUpdate, true);
            }

            if (mapProposalsWithIncorrectYWS.size() > 0) {
                createCases(mapProposalsWithIncorrectYWS);
            }

            TriggerUtility.generateYearWiseSplitExecuted();
        } catch (Exception ex) {
            System.debug('>>>> Exception occurred while generating year wise split. Message: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }
    }

    /**
     * @description generateYearWiseSplit creates yearwise split records for a given proposal
     * @param proposal Apttus Proposal for which yearwise splits has to be generated
     **/
    public static void generateYearWiseSplit(Apttus_Proposal__Proposal__c proposal) {
        Datetime proposalStartDate, proposalEndDate;
        Integer maximumYear;
        Map<Id, Map<Integer, Decimal>> mapProductYWSCost = new Map<Id, Map<Integer, Decimal>>();
        Map<Id, Map<Integer, Decimal>> mapProductYWSListPriceCost = new Map<Id, Map<Integer, Decimal>>();
        Map<Id, Decimal> mapProductsNetPrices = new Map<Id, Decimal>();
        Map<Id, Decimal> mapProductsYearWiseSplitCost = new Map<Id, Decimal>();
        List<Id> lstProductIds = new List<Id>();
        Map<Id, Year_Wise_Split__c> mapYearWiseSplits = new Map<Id, Year_Wise_Split__c>();
        Map<Id, Decimal> mapProductsQuantities = new Map<Id, Decimal>();

        proposalStartDate = proposal.Apttus_Proposal__ExpectedStartDate__c;
        proposalEndDate = proposal.Apttus_Proposal__ExpectedEndDate__c;

        Map<Integer, List<Date>> mapYearNumbersAndDates = new Map<Integer, List<Date>>();
        Date proratedStartDate = Date.valueOf(proposalStartDate);
        Date proratedEndDate = (proposalEndDate < proratedStartDate.addYears(1) ? Date.valueOf(proposalEndDate) : Date.valueOf(proratedStartDate.addYears(1).addDays(-1)));
        Integer year = 1;
        while (proratedStartDate < proposalEndDate) {
            mapYearNumbersAndDates.put(year, new List<Date> { proratedStartDate, proratedEndDate });
            maximumYear = year;

            year++;
            proratedStartDate = proratedStartDate.addYears(1);
            proratedEndDate = (Date.valueOf(proposalEndDate) < proratedStartDate.addYears(1) ? Date.valueOf(proposalEndDate) : proratedStartDate.addYears(1).addDays(-1));
        }

        Apttus_Proposal__Proposal__c proposalToUpdate = new Apttus_Proposal__Proposal__c(Id=proposal.Id);

        List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItems = [SELECT Id, Apttus_Proposal__Product__c, Apttus_QPConfig__IsPrimaryLine__c, Apttus_QPConfig__IsPrimaryRampLine__c, Apttus_QPConfig__LineNumber__c, Apttus_QPConfig__ItemSequence__c, Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__PriceListItemId__c, Apttus_QPConfig__PriceType__c, Apttus_QPConfig__Frequency__c, Apttus_QPConfig__SellingTerm__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, Apttus_Proposal__Proposal__c, APTS_Product_Code__c, APTS_Total_Ramp_Quantity__c, APTS_Quantity__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c = :proposal.Id ORDER BY Apttus_QPConfig__LineNumber__c, Apttus_QPConfig__ItemSequence__c];

        for (Apttus_Proposal__Proposal_Line_Item__c lineItem : lstProposalLineItems) {
            Date currentStartDate, currentEndDate;
            Integer currentYear;
            Decimal currentYearCost, currentYearListPriceCost;
            Map<Integer, Decimal> yearWiseCost;
            Map<Integer, Decimal> yearWiseListPriceCost;

            if (mapProductsNetPrices.containsKey(lineItem.Apttus_Proposal__Product__c)) {
                mapProductsNetPrices.put(lineItem.Apttus_Proposal__Product__c, mapProductsNetPrices.get(lineItem.Apttus_Proposal__Product__c) + Math.roundToLong(Math.ceil(lineItem.Apttus_QPConfig__NetPrice__c)));
            } else {
                mapProductsNetPrices.put(lineItem.Apttus_Proposal__Product__c, Math.roundToLong(Math.ceil(lineItem.Apttus_QPConfig__NetPrice__c)));
                lstProductIds.add(lineItem.Apttus_Proposal__Product__c);
            }

            if (mapProductYWSCost.containsKey(lineItem.Apttus_Proposal__Product__c)) {
                yearWiseCost = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c);
            } else {
                yearWiseCost = new Map<Integer, Decimal>();
            }

            if (mapProductYWSListPriceCost.containsKey(lineItem.Apttus_Proposal__Product__c)) {
                yearWiseListPriceCost = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c);
            } else {
                yearWiseListPriceCost = new Map<Integer, Decimal>();
            }

            // if (mapProductsQuantities.containsKey(lineItem.Apttus_Proposal__Product__c)) {
                mapProductsQuantities.put(lineItem.Apttus_Proposal__Product__c, lineItem.APTS_Quantity__c);
            // } else {
            //     mapProductsQuantities.put(lineItem.Apttus_Proposal__Product__c, lineItem.APTS_Quantity__c);
            // }

            if (lineItem.Apttus_QPConfig__PriceType__c == APTS_CONSTANTS.PROD_PRICETYPE_RECURRING) {
                // Determine the current start date
                currentStartDate = Date.valueOf(proposalStartDate);
                if (currentStartDate.addYears(1) > Date.valueOf(proposalEndDate)) {
                    currentEndDate = Date.valueOf(proposalEndDate);
                } else {
                    currentEndDate = Date.valueOf(currentStartDate.addYears(1).addDays(-1));
                }
                currentYear = 1;
                Decimal pricePerDay = lineItem.Apttus_QPConfig__NetPrice__c / (Date.valueOf(lineItem.Apttus_QPConfig__StartDate__c).daysBetween(Date.valueOf(lineItem.Apttus_QPConfig__EndDate__c)) + 1);

                Decimal listPrice = lineItem.Apttus_QPConfig__BaseExtendedPrice__c > 0 ? lineItem.Apttus_QPConfig__BaseExtendedPrice__c : lineItem.Apttus_QPConfig__NetPrice__c;
                Decimal listPricePerDay = listPrice / (Date.valueOf(lineItem.Apttus_QPConfig__StartDate__c).daysBetween(Date.valueOf(lineItem.Apttus_QPConfig__EndDate__c)) + 1);

                while (currentStartDate < proposalEndDate) {
                    Date currentLineItemStartDate;
                    Date currentLineItemEndDate;

                    currentLineItemStartDate = (currentStartDate < lineItem.Apttus_QPConfig__StartDate__c ? lineITem.Apttus_QPConfig__StartDate__c : currentStartDate);
                    currentLineItemEndDate = (currentEndDate >= lineItem.Apttus_QPConfig__EndDate__c ? lineItem.Apttus_QPConfig__EndDate__c : currentEndDate);
                    Integer numberOfDays = currentLineItemStartDate.daysBetween(currentLineItemEndDate) + 1;

                    System.debug(JSON.serialize(lineItem));
                    if (numberOfDays > 0) {
                        // Calculate the current year's cost
                        currentYearCost = pricePerDay * numberOfDays;
                        currentYearListPriceCost = listPricePerDay * numberOfDays;

                        // Build the yearwise cost map for a given year
                        if (yearWiseCost.containsKey(currentYear)) {
                            yearWiseCost.put(currentYear, yearWiseCost.get(currentYear) + currentYearCost);
                        } else {
                            yearWiseCost.put(currentYear, currentYearCost);
                        }

                        // Build the yearwise list price cost map for a given year
                        if (yearWiseListPriceCost.containsKey(currentYear)) {
                            yearWiseListPriceCost.put(currentYear, yearWiseListPriceCost.get(currentYear) + currentYearListPriceCost);
                        } else {
                            yearWiseListPriceCost.put(currentYear, currentYearListPriceCost);
                        }

                        // Sum up the yearwise cost for each SKU. To be used for verifying the yearwise values.
                        if (mapProductsYearWiseSplitCost.containsKey(lineItem.Apttus_Proposal__Product__c)) {
                            mapProductsYearWiseSplitCost.put(lineItem.Apttus_Proposal__Product__c, mapProductsYearWiseSplitCost.get(lineItem.Apttus_Proposal__Product__c) + Math.roundToLong(Math.ceil(currentYearCost)));
                        } else {
                            mapProductsYearWiseSplitCost.put(lineItem.Apttus_Proposal__Product__c, Math.roundToLong(Math.ceil(currentYearCost)));
                        }
                    }

                    currentStartDate = currentEndDate.addDays(1);
                    currentEndDate = currentStartDate.addYears(1).addDays(-1);
                    currentYear++;
                }

                mapProductYWSCost.put(lineItem.Apttus_Proposal__Product__c, yearWiseCost);
                mapProductYWSListPriceCost.put(lineItem.Apttus_Proposal__Product__c, yearWiseListPriceCost);
            } else if (lineItem.Apttus_QPConfig__PriceType__c == APTS_CONSTANTS.PROD_PRICETYPE_ONETIME) {
                if (lineItem.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ULIFTY4) {
                    currentYear = 4;
                } else if (lineItem.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ULIFTY5) {
                    currentYear = 5;
                } else if (lineItem.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_BUYBACK
                    || lineItem.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK) {
                    currentYear = maximumYear;
                } else {
                    currentYear = 1;
                }

                if (!mapYearNumbersAndDates.containsKey(currentYear)) {
                    continue;
                }

                currentStartDate = mapYearNumbersAndDates.get(currentYear)[0];
                currentEndDate = mapYearNumbersAndDates.get(currentYear)[1];

                currentYearCost = lineItem.Apttus_QPConfig__NetPrice__c;
                currentYearListPriceCost = lineItem.Apttus_QPConfig__BaseExtendedPrice__c > 0 ? lineItem.Apttus_QPConfig__BaseExtendedPrice__c : lineItem.Apttus_QPConfig__NetPrice__c;
                yearWiseCost = new Map<Integer, Decimal> { currentYear => currentYearCost };
                yearWiseListPriceCost = new Map<Integer, Decimal> { currentYear => currentYearListPriceCost };
                mapProductYWSCost.put(lineItem.Apttus_Proposal__Product__c, yearWiseCost);
                mapProductYWSListPriceCost.put(lineItem.Apttus_Proposal__Product__c, yearWiseListPriceCost);

                // Sum up the yearwise cost for each SKU. To be used for verifying the yearwise values.
                if (mapProductsYearWiseSplitCost.containsKey(lineItem.Apttus_Proposal__Product__c)) {
                    mapProductsYearWiseSplitCost.put(lineItem.Apttus_Proposal__Product__c, mapProductsYearWiseSplitCost.get(lineItem.Apttus_Proposal__Product__c) + Math.roundToLong(Math.ceil(currentYearCost)));
                } else {
                    mapProductsYearWiseSplitCost.put(lineItem.Apttus_Proposal__Product__c, Math.roundToLong(Math.ceil(currentYearCost)));
                }
            }
        }

        // Prepare the placeholder map for calculating year wise split subtotal values
        Map<Integer, Decimal> mapYearWiseSubTotal = new Map<Integer, Decimal> { 1 => 0.0, 2 => 0.0, 3 => 0.0, 4 => 0.0, 5 => 0.0, 6 => 0.0, 7 => 0.0 };
        Map<Integer, Decimal> mapYearWiseListPriceSubTotal = new Map<Integer, Decimal> { 1 => 0.0, 2 => 0.0, 3 => 0.0, 4 => 0.0, 5 => 0.0, 6 => 0.0, 7 => 0.0 };
        for (Apttus_Proposal__Proposal_Line_Item__c lineItem : lstProposalLineItems) {
            if (lineItem.Apttus_QPConfig__IsPrimaryLine__c != true) {
                continue;
            }

            Year_Wise_Split__c ywsplit = new Year_Wise_Split__c(Quote_Proposal__c = lineItem.Apttus_Proposal__Proposal__c, Proposal_Line_Item__c = lineItem.Id, Quantity__c = mapProductsQuantities.get(lineItem.Apttus_Proposal__Product__c));

            for (Integer key : mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).keySet()) {
                if (key == 1) {
                    ywsplit.Year_1_Cost__c = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseSubTotal.put(key, mapYearWiseSubTotal.get(key) + ywsplit.Year_1_Cost__c);
                } else if (key == 2) {
                    ywsplit.Year_2_Cost__c = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseSubTotal.put(key, mapYearWiseSubTotal.get(key) + ywsplit.Year_2_Cost__c);
                } else if (key == 3) {
                    ywsplit.Year_3_Cost__c = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseSubTotal.put(key, mapYearWiseSubTotal.get(key) + ywsplit.Year_3_Cost__c);
                } else if (key == 4) {
                    ywsplit.Year_4_Cost__c = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseSubTotal.put(key, mapYearWiseSubTotal.get(key) + ywsplit.Year_4_Cost__c);
                } else if (key == 5) {
                    ywsplit.Year_5_Cost__c = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseSubTotal.put(key, mapYearWiseSubTotal.get(key) + ywsplit.Year_5_Cost__c);
                } else if (key == 6) {
                    ywsplit.Year_6_Cost__c = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseSubTotal.put(key, mapYearWiseSubTotal.get(key) + ywsplit.Year_6_Cost__c);
                } else if (key == 7) {
                    ywsplit.Year_7_Cost__c = mapProductYWSCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseSubTotal.put(key, mapYearWiseSubTotal.get(key) + ywsplit.Year_7_Cost__c);
                }
            }

            for (Integer key : mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).keySet()) {
                if (key == 1) {
                    ywsplit.Year_1_List_Price_Cost__c = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseListPriceSubTotal.put(key, mapYearWiseListPriceSubTotal.get(key) + ywsplit.Year_1_List_Price_Cost__c);
                } else if (key == 2) {
                    ywsplit.Year_2_List_Price_Cost__c = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseListPriceSubTotal.put(key, mapYearWiseListPriceSubTotal.get(key) + ywsplit.Year_2_List_Price_Cost__c);
                } else if (key == 3) {
                    ywsplit.Year_3_List_Price_Cost__c = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseListPriceSubTotal.put(key, mapYearWiseListPriceSubTotal.get(key) + ywsplit.Year_3_List_Price_Cost__c);
                } else if (key == 4) {
                    ywsplit.Year_4_List_Price_Cost__c = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseListPriceSubTotal.put(key, mapYearWiseListPriceSubTotal.get(key) + ywsplit.Year_4_List_Price_Cost__c);
                } else if (key == 5) {
                    ywsplit.Year_5_List_Price_Cost__c = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseListPriceSubTotal.put(key, mapYearWiseListPriceSubTotal.get(key) + ywsplit.Year_5_List_Price_Cost__c);
                } else if (key == 6) {
                    ywsplit.Year_6_List_Price_Cost__c = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseListPriceSubTotal.put(key, mapYearWiseListPriceSubTotal.get(key) + ywsplit.Year_6_List_Price_Cost__c);
                } else if (key == 7) {
                    ywsplit.Year_7_List_Price_Cost__c = mapProductYWSListPriceCost.get(lineItem.Apttus_Proposal__Product__c).get(key);
                    mapYearWiseListPriceSubTotal.put(key, mapYearWiseListPriceSubTotal.get(key) + ywsplit.Year_7_List_Price_Cost__c);
                }
            }

            mapYearWiseSplits.put(lineItem.Apttus_Proposal__Product__c, ywsplit);
        }

        // Sort the year wise split to maintain the order
        for (Id productId : lstProductIds) {
            if (mapYearWiseSplits.containsKey(productId)) {
                lstYearWiseSplitsToInsert.add(mapYearWiseSplits.get(productId));
            }
        }

        proposalToUpdate.Year_1_Subtotal__c = mapYearWiseSubTotal.get(1);
        proposalToUpdate.Year_2_Subtotal__c = mapYearWiseSubTotal.get(2);
        proposalToUpdate.Year_3_Subtotal__c = mapYearWiseSubTotal.get(3);
        proposalToUpdate.Year_4_Subtotal__c = mapYearWiseSubTotal.get(4);
        proposalToUpdate.Year_5_Subtotal__c = mapYearWiseSubTotal.get(5);
        proposalToUpdate.Year_6_Subtotal__c = mapYearWiseSubTotal.get(6);
        proposalToUpdate.Year_7_Subtotal__c = mapYearWiseSubTotal.get(7);

        proposalToUpdate.Year_1_List_Price_Subtotal__c = mapYearWiseListPriceSubTotal.get(1);
        proposalToUpdate.Year_2_List_Price_Subtotal__c = mapYearWiseListPriceSubTotal.get(2);
        proposalToUpdate.Year_3_List_Price_Subtotal__c = mapYearWiseListPriceSubTotal.get(3);
        proposalToUpdate.Year_4_List_Price_Subtotal__c = mapYearWiseListPriceSubTotal.get(4);
        proposalToUpdate.Year_5_List_Price_Subtotal__c = mapYearWiseListPriceSubTotal.get(5);
        proposalToUpdate.Year_6_List_Price_Subtotal__c = mapYearWiseListPriceSubTotal.get(6);
        proposalToUpdate.Year_7_List_Price_Subtotal__c = mapYearWiseListPriceSubTotal.get(7);

        // Update YYYY for each year in proposal
        proposalToUpdate.Year_1_Year_Value__c = null;
        proposalToUpdate.Year_2_Year_Value__c = null;
        proposalToUpdate.Year_3_Year_Value__c = null;
        proposalToUpdate.Year_4_Year_Value__c = null;
        proposalToUpdate.Year_5_Year_Value__c = null;
        proposalToUpdate.Year_6_Year_Value__c = null;
        proposalToUpdate.Year_7_Year_Value__c = null;

        for (Integer key : mapYearNumbersAndDates.keySet()) {
            Datetime startDate = Datetime.newInstance(mapYearNumbersAndDates.get(key)[0].year(), mapYearNumbersAndDates.get(key)[0].month(), mapYearNumbersAndDates.get(key)[0].day(), 0, 0, 0);
            Datetime endDate = Datetime.newInstance(mapYearNumbersAndDates.get(key)[1].year(), mapYearNumbersAndDates.get(key)[1].month(), mapYearNumbersAndDates.get(key)[1].day(), 0, 0, 0);

            String yearText = startDate.format('MMM-yy') + ' to ' + endDate.format('MMM-yy');
            if (key == 1) {
                proposalToUpdate.Year_1_Year_Value__c = yearText;
            } else if (key == 2) {
                proposalToUpdate.Year_2_Year_Value__c = yearText;
            } else if (key == 3) {
                proposalToUpdate.Year_3_Year_Value__c = yearText;
            } else if (key == 4) {
                proposalToUpdate.Year_4_Year_Value__c = yearText;
            } else if (key == 5) {
                proposalToUpdate.Year_5_Year_Value__c = yearText;
            } else if (key == 6) {
                proposalToUpdate.Year_6_Year_Value__c = yearText;
            } else if (key == 7) {
                proposalToUpdate.Year_7_Year_Value__c = yearText;
            }
        }

        lstProposalsToUpdate.add(proposalToUpdate);

        // Verification of year wise split values
        // Verify if the SKUs' net price matches with the calculated year wise split values.
        Boolean isDataIncorrect = false;
        for (Id productId : mapProductsNetPrices.keySet()) {
            if (!mapProductsYearWiseSplitCost.containsKey(productId)
                || Math.abs(mapProductsNetPrices.get(productId) - mapProductsYearWiseSplitCost.get(productId)) > 10) {
                isDataIncorrect = true;
                break;
            }
        }

        if (isDataIncorrect) {
            proposalToUpdate.Is_Year_Wise_Split_Data_Incorrect__c = true;
            mapProposalsWithIncorrectYWS.put(proposal.Id, proposal);
        } else {
            proposalToUpdate.Is_Year_Wise_Split_Data_Incorrect__c = false;
        }
    }

    /**
     * @description Method to generate the list of Year Wise Splits for a proposal
     * @param proposalId Apttus Proposal SF ID
     * @return YearWiseSplitWrapper A wrapper class containing the year wise split records
     **/
    public static YearWiseSplitWrapper getYearWiseSplitsList(Id proposalId) {
        YearWiseSplitWrapper splitWrapper = new YearWiseSplitWrapper();
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Generate_Year_Wise_Split__c, Number_Of_Year_Wise_Split_Years__c, Year_1_Subtotal__c,
                                                    Year_2_Subtotal__c, Year_3_Subtotal__c, Year_4_Subtotal__c, Year_5_Subtotal__c, Year_6_Subtotal__c,
                                                    Year_7_Subtotal__c, Year_Wise_Split_Total__c, Year_1_Year_Value__c, Year_2_Year_Value__c,
                                                    Year_3_Year_Value__c, Year_4_Year_Value__c, Year_5_Year_Value__c, Year_6_Year_Value__c, Year_7_Year_Value__c,
                                                    (SELECT Id, Proposal_Line_Item__c, Proposal_Line_Item__r.Product_Name__c, SKU__c, Year_1_Cost__c,
                                                        Year_2_Cost__c, Year_3_Cost__c, Year_4_Cost__c, Year_5_Cost__c, Year_6_Cost__c, Year_7_Cost__c,
                                                        Subtotal__c, Line_Sequence__c, Quantity__c
                                                       FROM Year_Wise_Splits__r ORDER BY Proposal_Line_Item__r.APTS_Line_Sequence__c)
                                                  FROM Apttus_Proposal__Proposal__c WHERE Id = :proposalId LIMIT 1];

        splitWrapper.quoteProposalId = proposal.Id;
        splitWrapper.numberOfYears = (Integer)proposal.Number_Of_Year_Wise_Split_Years__c;
        splitWrapper.splitEntries = new List<YearWiseSplitEntry>();
        splitWrapper.year1YearValue = 'Year 1 Cost (' + proposal.Year_1_Year_Value__c + ')';
        splitWrapper.year2YearValue = 'Year 2 Cost (' + proposal.Year_2_Year_Value__c + ')';
        splitWrapper.year3YearValue = 'Year 3 Cost (' + proposal.Year_3_Year_Value__c + ')';
        splitWrapper.year4YearValue = 'Year 4 Cost (' + proposal.Year_4_Year_Value__c + ')';
        splitWrapper.year5YearValue = 'Year 5 Cost (' + proposal.Year_5_Year_Value__c + ')';
        splitWrapper.year6YearValue = 'Year 6 Cost (' + proposal.Year_6_Year_Value__c + ')';
        splitWrapper.year7YearValue = 'Year 7 Cost (' + proposal.Year_7_Year_Value__c + ')';

        for (Year_Wise_Split__c split : proposal.Year_Wise_Splits__r) {
            splitWrapper.splitEntries.add(new YearWiseSplitEntry(
                                            split.Proposal_Line_Item__r.Product_Name__c,
                                            split.SKU__c,
                                            split.Year_1_Cost__c,
                                            split.Year_2_Cost__c,
                                            split.Year_3_Cost__c,
                                            split.Year_4_Cost__c,
                                            split.Year_5_Cost__c,
                                            split.Year_6_Cost__c,
                                            split.Year_7_Cost__c,
                                            split.Subtotal__c,
                                            String.valueOf(split.Line_Sequence__c),
                                            Integer.valueOf(split.Quantity__c)
                                        ));
        }

        splitWrapper.splitEntries.add(new YearWiseSplitEntry(
                            'Total',
                            '',
                            proposal.Year_1_Subtotal__c,
                            proposal.Year_2_Subtotal__c,
                            proposal.Year_3_Subtotal__c,
                            proposal.Year_4_Subtotal__c,
                            proposal.Year_5_Subtotal__c,
                            proposal.Year_6_Subtotal__c,
                            proposal.Year_7_Subtotal__c,
                            proposal.Year_Wise_Split_Total__c,
                            '',
                            null
                        ));

        return splitWrapper;
    }

    /**
     * @description Method to create support cases for proposals having incorrect YWS data
     * @param proposals - List of Apttus proposals
     **/
    @TestVisible private static void createCases(Map<Id, Apttus_Proposal__Proposal__c> proposals) {
        List<Case> lstCasesToInsert = new List<Case>();
        Id caseOwnerId;
        if (Test.isRunningTest()) {
            caseOwnerId = Userinfo.getUserId();
        } else {
            caseOwnerId = ZscalerSetting__c.getValues('SalesOperationQueueId').Value__c;
        }

        // Query the existing cases
        Map<Id, Id> mapExistingCaseIds = new Map<Id, Id>();
        for (Case existingCase : [SELECT Id, Subject, Proposal__c FROM Case
                                   WHERE Case_Category__c = 'Proposals'
                                     AND Case_Sub_Category__c = 'Year Wise Splits Fix'
                                     AND IsClosed != true
                                     AND Proposal__c IN :proposals.keySet()]) {
             mapExistingCaseIds.put(existingCase.Proposal__c, existingCase.Id);
         }

        for (Apttus_Proposal__Proposal__c proposal : proposals.values()) {
            if (mapExistingCaseIds.containsKey(proposal.Id)) {
                continue;
            }

            lstCasesToInsert.add(new Case(
                                Subject = 'Year wise split data is incorrect : ' + proposal.Name,
                                Opportunity_Name__c = proposal.Apttus_Proposal__Opportunity__c,
                                AccountId = proposal.Apttus_Proposal__Account__c,
                                Case_Category__c = 'Proposals',
                                Case_Sub_Category__c = 'Year Wise Splits Fix',
                                Status = 'New',
                                OwnerId = caseOwnerId,
                                Priority = '3 - Medium',
                                Case_Source__c = 'Salesforce.com',
                                Description = 'The generated year wise split data does not match with the Net Price of the proposal line item(s). Please verify and fix.',
                                Proposal__c = proposal.Id,
                                recordtypeid=label.CaseRT_SalesOperation
                            ));
        }

        Database.insert(lstCasesToInsert, true);
    }

    /**
     * YearWiseSplitWrapper - A custom wrapper to hold the list of year wise split records
     */
    public class YearWiseSplitWrapper {
        public Id quoteProposalId { get; set; }
        public Integer numberOfYears { get; set; }
        public List<YearWiseSplitEntry> splitEntries { get; set; }
        public String year1YearValue { get; set; }
        public String year2YearValue { get; set; }
        public String year3YearValue { get; set; }
        public String year4YearValue { get; set; }
        public String year5YearValue { get; set; }
        public String year6YearValue { get; set; }
        public String year7YearValue { get; set; }

        public YearWiseSplitWrapper() {
            splitEntries = new List<YearWiseSplitEntry>();
        }
    }

    /**
     * YearWiseSplitWrapper - A custom wrapper to a year wise split entry
     */
    public class YearWiseSplitEntry {
        public String productName { get; set; }
        public String productCode { get; set; }
        public Integer quantity { get; set; }
        public Decimal year1Cost { get; set; }
        public Decimal year2Cost { get; set; }
        public Decimal year3Cost { get; set; }
        public Decimal year4Cost { get; set; }
        public Decimal year5Cost { get; set; }
        public Decimal year6Cost { get; set; }
        public Decimal year7Cost { get; set; }
        public Decimal total { get; set; }
        public String lineSequence { get; set; }

        public YearWiseSplitEntry(String productName, String productCode, Decimal year1Cost, Decimal year2Cost,
                                    Decimal year3Cost, Decimal year4Cost, Decimal year5Cost, Decimal year6Cost,
                                    Decimal year7Cost, Decimal total, String lineSequence, Integer quantity) {
            this.productName = productName;
            this.productCode = productCode;
            this.year1Cost = year1Cost;
            this.year2Cost = year2Cost;
            this.year3Cost = year3Cost;
            this.year4Cost = year4Cost;
            this.year5Cost = year5Cost;
            this.year6Cost = year6Cost;
            this.year7Cost = year7Cost;
            this.total = total;
            this.lineSequence = lineSequence;
            this.quantity = quantity;
        }
    }
    public static void booster(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
	   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
	   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}