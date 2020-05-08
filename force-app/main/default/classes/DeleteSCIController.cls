/*****************************************************************************************
Name: DeleteSCIController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to handle Delete custom button in SCI detail page
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     13-Jan-2017    Initial Development
******************************************************************************************/
public with sharing class DeleteSCIController {
    SObject record { get; set; }

    /**
     * Default controller
     */
    public DeleteSCIController() {

    }

    /**
     * Constructor
     * @param  con StandardController parameter
     */
    public DeleteSCIController(ApexPages.StandardController con) {
        record = con.getRecord();
    }

    /**
     * Page load method
     * @return PageReference
     */
    public PageReference deleteSCI() {
        PageReference reference;
        System.debug('>>> ' + record);
        try {
            if (null != record) {
                delete record;
                reference = new PageReference('/home/home.jsp');
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
            reference = new PageReference('/' + record.Id);
        }

        return reference;
    }
}