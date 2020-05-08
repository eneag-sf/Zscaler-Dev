/*****************************************************************************************
Name: AmberRoadAccountModel
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Wrapper class for Amber Road XML
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     23-Sep-2016    Initial Development
******************************************************************************************/
public class AmberRoadAccountModel {

    public String partnerId;
    public String orgCode;
    public String companyCode;
    public String name;
    public String primaryContact;
    public String secondaryContact;
    public String primaryContactTitle;
    public String secondaryContactTitle;
    public String address1;
    public String address2;
    public String address3;
    public String address4;
    public String city;
    public String county;
    public String stateCode;
    public String state;
    public String postalCode;
    public String countryCode;
    public String country;
    public String imo;
    public String fax;
    public String phone;
    public String email;
    public String ein;
    public String doNotScreen;
    public String manualHold;
    public String skipNewDpl;
    public String redFlag;
    public String embargoHold;
    public String relatedParty;
    public String status;
    public List<Extension> extension;
    public List<PartnerTypeRecord> partnerTypeRecord;
    public List<Entity> entities;
    public List<AdditionalAttribute> additionalAttributes;
    public List<Embargo> embargoes;
    public IntegrationStatus integrationStatus;

    public class PartnerTypeRecord {
        public String partnerId;
        public String orgCode;
        public String partnerType;
        public String primaryContact;
        public String primaryContactTitle;
        public String secondaryContact;
        public String secondaryContactTitle;
        public String fax;
        public String phone;
        public String email;
        public List<Extension> extenion;

    }

    public class Extension {
        public String extensionTemplate;
        public List<ExtensionField> extensionField;
    }

    public class ExtensionField {
        public String name;
    }

    public class Entity {
        public String entityId;
        public String rplType;
        public String rplCtryCode;
        public String matchScore;
        public List<Phrase> phrases;
    }

    public class Phrase {
        public String phraseType;
        public String phraseId;
        public String matchScore;
        public String decision;
        public String name;
        public String address;
        public String city;
        public String state;
        public String postal;
        public String countryId;
        public String country;
    }

    public class AdditionalAttribute {
        public String entityId;
        public String rplType;
        public String attributeName;
        public String attributeValue;
        public String decision;
    }

    public class Embargo {
        public String partnerCountry;
        public String type;
        public String issuingCountry;
        public String conditional;
        public String listName;
        public String embargoText;
    }

    public class IntegrationStatus {
        public String statusCode;
        public String statusDescription;
    }
}