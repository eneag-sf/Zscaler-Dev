/*****************************************************************************************
Name: DealRegistrationModel
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Wrapper class to hold Deal Registration information
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     31-Aug-2016    Initial Development
******************************************************************************************/

global class DealRegistrationModel {

    public String customerCompanyName;
    public String customerContactFirstName;
    public String customerContactLastName;
    public String customerContactEmail;
    public String customerContactAddress;
    public String customerContactCity;
    public String customerContactPostalCode;
    public String customerContactCountry;
    public String customerContactState;
    public String customerContactPhone;
    public String customerRoleAndTitle;
    public String partnerCompanyName;
    public String partnerContactFirstName;
    public String partnerContactLastName;
    public String partnerContactEmail;
    public String partnerPhone;
    public String partnerAlternateEmail1;
    public String partnerAlternateEmail2;
    public String partnerAlternateEmail3;
    public String partnerISAName;
    public String partnerISAEmail;
    public Integer numberOfSeats;
    public String dealDescription;
    public Decimal estimatedAmount;
    public Date expectedCloseDate;
    public String dealRegId;
    public String dealSource;
    public String productAreas;
    public String status;

    /**
     * Default constructor
     */
    public DealRegistrationModel() {

    }
}