/*****************************************************************************************
Name: AmberRoadService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to screen accounts with Amber Road database
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     23-Sep-2016    Initial Development
1.1            Vijay Prakash P J     31-Mar-2017    Added logic to send / receive 15 digit SF Id as Partner Id
******************************************************************************************/
public class AmberRoadService {
    /*
    Constants Section - Start
     */
    public static final String START_DELIMITER = '[';
    public static final String END_DELIMITER = ']';
    public static final String ORG_CODE = 'ZSCALER_SF';
    public static final String COMPANY_CODE = 'ZSCALER';

    public static final Map<String, String> mapAccountFieldsMapping = new Map<String, String>{
                                                                        'Name' => 'name',
                                                                        'BillingStreet' => 'address1',
                                                                        'BillingCity' => 'city',
                                                                        'BillingState' => 'state',
                                                                        'BillingCountry' => 'country', 
                                                                        'BillingPostalCode' => 'postalCode',
                                                                        'Fax' => 'fax',
                                                                        'Phone' => 'phone',
                                                                        'Id' => 'partnerId'
                                                                    };
    /*
    Constants Section - End
     */
    
    public static String inboundXML = '<?xml version="1.0" encoding="UTF-8"?>'
                                    + '<PartnerRecord version="2"'
                                    + ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
                                    + ' xsi:noNamespaceSchemaLocation="PartnerXml.xsd">'
                                    + '<PartnerId>[partnerId]</PartnerId>'
                                    + '<OrgCode>' + ORG_CODE + '</OrgCode>'
                                    + '<CompanyCode>' + COMPANY_CODE + '</CompanyCode>'
                                    + '<Name>[name]</Name>'
                                    + '<Address1>[address1]</Address1>'
                                    + '<City>[city]</City>'
                                    + '<StateCode>[stateCode]</StateCode>'
                                    + '<State>[state]</State>'
                                    + '<PostalCode>[postalCode]</PostalCode>'
                                    + '<Country>[country]</Country>'
                                    + '<CountryCode>[countryCode]</CountryCode>'
                                    + '<Fax>[fax]</Fax>'
                                    + '<Phone>[phone]</Phone>'
                                    + '<SkipNewDpl>[skipNewDpl]</SkipNewDpl>'
                                    + '<ForceRescreen>[forceRescreen]</ForceRescreen>'
                                    + '</PartnerRecord>';
    
    ////Currently not in use - To be used as a reference
    //public static String inboundXMLFullyGrown = '<?xml version="1.0" encoding="UTF-8"?>'
    //                                          + '<PartnerRecord version="2"'
    //                                          + ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
    //                                          + ' xsi:noNamespaceSchemaLocation="PartnerXml.xsd">'
    //                                          + '<PartnerId>[partnerId]</PartnerId>'
    //                                          + '<OrgCode>' + ORG_CODE + '</OrgCode>'
    //                                          + '<CompanyCode>' + COMPANY_CODE + '</CompanyCode>'
    //                                          + '<Name>[name]</Name>'
    //                                          + '<PrimaryContact>[primaryContact]</PrimaryContact>'
    //                                          + '<SecondaryContact>[secondaryContact]</SecondaryContact>'
    //                                          + '<PrimaryContactTitle>[primaryContactTitle]</PrimaryContactTitle>'
    //                                          + '<SecondaryContactTitle>[secondaryContactTitle]</SecondaryContactTitle>'
    //                                          + '<Address1>[address1]</Address1>'
    //                                          + '<Address2>[address2]</Address2>'
    //                                          + '<Address3>[address3]</Address3>'
    //                                          + '<Address4>[address4]</Address4>'
    //                                          + '<City>[city]</City>'
    //                                          + '<County>[county]</County>'
    //                                          + '<StateCode>[stateCode]</StateCode>'
    //                                          + '<State>[state]</State>'
    //                                          + '<PostalCode>[postalCode]</PostalCode>'
    //                                          + '<CountryCode>[countryCode]</CountryCode>'
    //                                          + '<Country>[country]</Country>'
    //                                          + '<IMO>[imo]</IMO>'
    //                                          + '<Fax>[fax]</Fax>'
    //                                          + '<Phone>[phone]</Phone>'
    //                                          + '<Email>[email]</Email>'
    //                                          + '<Ein>[ein]</Ein>'
    //                                          + '<DoNotScreen>[doNotScreen]</DoNotScreen>'
    //                                          + '<ManualHold>[manualHold]</ManualHold>'
    //                                          + '<SkipNewDpl>[skipNewDpl]</SkipNewDpl>'
    //                                          + '<RedFlag>[redFlag]</RedFlag>'
    //                                          + '<RelatedParty>[relatedParty]</RelatedParty>'
    //                                          + '<AutoCreatePartnerTypes>[autoCreatePartnerTypes]</AutoCreatePartnerTypes>'
    //                                          + '</PartnerRecord>';
    
    @future(callout=true)
    public static void screenAccountFuture(String accountJson, Boolean isTransactionalScreening, Boolean forceRescreen) {
        Account accountToBeScreened = (Account)JSON.deserialize(accountJson, Type.forName('Account'));
        screenAccount(accountToBeScreened, isTransactionalScreening, forceRescreen);
    }

    /**
     * Screens the account provided as input. This does transactional screening by default.
     * @param  accountObj - Account to be screened
     * @return            - Account details with screened data
     */
    public static AmberRoadAccountModel screenAccount(Account accountObj) {
        return screenAccount(accountObj, true);
    }

    /**
     * Screens the account provided as input
     * @param  accountObj               Account to be screened
     * @param  isTransactionalScreening - Type of screening (Active / Transaction)
     * @return                          - Returns the account details with screened data
     */
    public static AmberRoadAccountModel screenAccount(Account accountObj, Boolean isTransactionalScreening) {
        return screenAccount(accountObj, isTransactionalScreening, (!isTransactionalScreening));
    }

    /**
     * Screens the account provided as input
     * @param  accountObj               Account to be screened
     * @param  isTransactionalScreening - Type of screening (Active / Transaction)
     * @param  forceRescreen            - Forcefully rescreen the account
     * @return                          - Returns the account details with screened data
     */
    public static AmberRoadAccountModel screenAccount(Account accountObj, Boolean isTransactionalScreening, Boolean forceRescreen) {
        AmberRoadAccountModel accountModel = new AmberRoadAccountModel();
        String xmlResponse = '';
        
        //Iterate through all the fields
        for (String field : mapAccountFieldsMapping.keySet()) {
            String value = (accountObj.get(field) != null) ? String.valueOf(accountObj.get(field)) : '';
            String xmlNode = mapAccountFieldsMapping.get(field);

            //Replace the correct Country name to send to Amber Road
            if ('country' == xmlNode) {
                if (API_Country_Mapping__c.getInstance(value.toLowerCase()) != null
                    && API_Country_Mapping__c.getInstance(value.toLowerCase()).Amber_Road_Country_Code__c != null) {
                    addValueForNode('countryCode', API_Country_Mapping__c.getInstance(value.toLowerCase()).Amber_Road_Country_Code__c);
                } else {
                    addValueForNode('countryCode', '');
                }
                
                value = (API_Country_Mapping__c.getInstance(value.toLowerCase()) != null ? API_Country_Mapping__c.getInstance(value.toLowerCase()).Amber_Road_Country_Name__c : value);
            } else if ('state' == xmlNode) {
                if (API_States_Mapping__c.getInstance(value.toLowerCase()) != null
                    && API_States_Mapping__c.getInstance(value.toLowerCase()).Amber_Road_State_Code__c != null) {
                    addValueForNode('stateCode', API_States_Mapping__c.getInstance(value.toLowerCase()).Amber_Road_State_Code__c);
                } else {
                    addValueForNode('stateCode', '');
                }
            } else if ('partnerId' == xmlNode) {
                addValueForNode('partnerId', value.substring(0, 15));
            }

            addValueForNode(xmlNode, value);
        }

        addValueForNode('skipNewDpl', (true == isTransactionalScreening ? 'Y' : 'N'));
        
        //Setting the forceRescreen value as BLANK to stop Amber Road from expecting approval of the account again.
        //addValueForNode('forceRescreen', (true == forceRescreen ? 'Y' : 'N'));
        addValueForNode('forceRescreen', '');
        System.debug('inboundXML: ' +  inboundXML);

        try {
            //Make callout to Amber Road API 
            xmlResponse = AmberRoadRequestService.screenAccount(inboundXML);
            deserializeXML(xmlResponse, accountModel);

            //Check for status code value
            if ('1000' == accountModel.integrationStatus.statusCode) {
                //Update the status into Salesforce account record
                Account accountToUpdate = new Account(Id = accountObj.Id, Amber_Road_Status__c = accountModel.status);
                update accountToUpdate;
            } else {
                //Update the failure status in Account
                Database.DMLOptions options = new Database.DMLOptions();
                options.AllowFieldTruncation = true;
                Account accountToUpdate = new Account(Id = accountObj.Id, Amber_Road_Status__c = 'Failed To Screen', Amber_Road_Integration_Status__c = accountModel.integrationStatus.statusCode + ' - ' + accountModel.integrationStatus.statusDescription);
                Database.update(accountToUpdate, options);
            }
        } catch (Exception ex) {
            //Update the failure status in Account
            Account accountToUpdate = new Account(Id = accountObj.Id, Amber_Road_Status__c = 'Failed To Screen', Amber_Road_Integration_Status__c = 'Exception occurred');
            update accountToUpdate;

            throw new AmberRoadServiceException('Exception occurred: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }

        return accountModel;
    }

    /**
     * Method to deserialize the input XML from Amber Road service into AmberRoadAccountModel
     * @param xmlDocument XML Document in String
     * @param model       Model wrapper to be used for deserialization
     */
    public static void deserializeXML(String xmlDocument, AmberRoadAccountModel model) {
        Dom.Document xmlDom = new Dom.Document();
        xmlDom.load(xmlDocument);

        Dom.XmlNode rootNode = xmlDom.getRootElement();
        parseXML(rootNode.getName(), rootNode.getChildElements(), model);
    }

    /**
     * Method to parse the XML response from Amber Road and populate it in the AmberRoadData
     * @param  xmlDocument - XML String returned by Amber Road API
     * @return             Returns the parsed account details
     */
    private static void parseXML(String rootNodeName, List<Dom.XmlNode> lstXmlNodes, AmberRoadAccountModel model) {
        //Return if the rootNodeName is invalid or there are no child nodes to parse
        if (null == rootNodeName
            || '' == rootNodeName
            || null == lstXmlNodes
            || lstXmlNodes.isEmpty()) {
            return;
        }
        
        for (Dom.XmlNode node : lstXmlNodes) {
            String nodeName = node.getName();
            String nodeText = node.getText();
            Dom.XmlNodeType nodeType = node.getNodeType();

            if ('PartnerRecord' == rootNodeName) {
                if ('PartnerId' == nodeName) {
                    model.partnerId = unescapeSpecialCharacters(nodeText);
                } else if ('Name' == nodeName) {
                    model.name = unescapeSpecialCharacters(nodeText);
                } else if ('Address1' == nodeName) {
                    model.address1 = unescapeSpecialCharacters(nodeText);
                } else if ('City' == nodeName) {
                    model.city = unescapeSpecialCharacters(nodeText);
                } else if ('State' == nodeName) {
                    model.state = unescapeSpecialCharacters(nodeText);
                } else if ('Country' == nodeName) {
                    model.country = unescapeSpecialCharacters(nodeText);
                } else if ('PostalCode' == nodeName) {
                    model.postalCode = unescapeSpecialCharacters(nodeText);
                } else if ('Fax' == nodeName) {
                    model.fax = unescapeSpecialCharacters(nodeText);
                } else if ('Phone' == nodeName) {
                    model.phone = unescapeSpecialCharacters(nodeText);
                } else if ('Status' == nodeName) {
                    model.status = unescapeSpecialCharacters(nodeText);
                } else if ('IntegrationStatus' == nodeName) {
                    parseXML(nodeName, node.getChildElements(), model);
                } else if ('SkipNewDpl' == nodeName) {
                    model.skipNewDpl = unescapeSpecialCharacters(nodeText);
                }
            } else if ('IntegrationStatus' == rootNodeName) {
                if (null == model.integrationStatus) {
                    model.integrationStatus = new AmberRoadAccountModel.IntegrationStatus();
                }

                if ('StatusCode' == nodeName) {
                    model.integrationStatus.statusCode = unescapeSpecialCharacters(nodeText);
                } else if ('StatusDescription' == nodeName) {
                    model.integrationStatus.statusDescription = unescapeSpecialCharacters(nodeText);
                }
            }
        }
    }
    
    /**
     * Method to add value for Amber Road XML node
     * @param nodeName - Name of the node
     * @param value    - Value for the node
     */
    private static void addValueForNode(String nodeName, String value) {
        inboundXML = inboundXML.replace(START_DELIMITER + nodeName + END_DELIMITER, escapeSpecialCharacters(value));
    }

    /**
     * Method to escape special characters to be passed to Amber Road API
     * @param  value - Value to be escaped
     * @return       - Value with escaped characters
     */
    private static String escapeSpecialCharacters(String value) {
        return value.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('\'', '&apos;').replace('"', '&quot;');
    }

    /**
     * Method to unescape the special characters from Amber Road API
     * @param  value - Value to be unescaped
     * @return       - Value with unescaped special characters
     */
    private static String unescapeSpecialCharacters(String value) {
        return value.replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>').replace('&apos;', '\'').replace('&quot;', '"');
    }

    /**
     * Custom exception class for AmberRoadService
     */
    public class AmberRoadServiceException extends Exception {

    }
}