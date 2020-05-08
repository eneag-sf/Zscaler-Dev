@isTest
private class DatacenterGeocodingControllerExtTest {

    @isTest static void testDatacenterGeocoding() {
        DatacenterTriggerHelperHTTPCalloutMock httpMock = new DatacenterTriggerHelperHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"San Jose",'
                                                    + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                                                    + '"Legacy_Entry__c":false,"Name":"Testing encoding",'
                                                    + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                                                    + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                                                    + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                                                    + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);

        Test.setCurrentPage(Page.DatacenterGeocoding);
        ApexPages.currentPage().getParameters().put('id', dc.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(dc);
        DatacenterGeocodingControllerExt controller = new DatacenterGeocodingControllerExt(stdController);
        controller.fetchGeolocation();
        controller.cancel();

        System.debug('>>>> after:' + dc);

        Test.stopTest();
    }

    @isTest static void testDatacenterGeocodingError() {
        DatacenterTriggerHelperHTTPCalloutMock httpMock = new DatacenterTriggerHelperHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"RequestInvalid",'
                                                    + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                                                    + '"Legacy_Entry__c":false,"Name":"Testing encoding",'
                                                    + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                                                    + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                                                    + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                                                    + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);

        Test.setCurrentPage(Page.DatacenterGeocoding);
        ApexPages.currentPage().getParameters().put('id', dc.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(dc);
        DatacenterGeocodingControllerExt controller = new DatacenterGeocodingControllerExt(stdController);
        controller.fetchGeolocation();

        Test.stopTest();
    }

    @isTest static void testDatacenterViewLocation() {
        DatacenterTriggerHelperHTTPCalloutMock httpMock = new DatacenterTriggerHelperHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"AuthError",'
                                                    + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                                                    + '"Legacy_Entry__c":false,"Name":"Testing encoding","Geo_Latitude__c": 12.02323, "Geo_Longitude__c": 70.23212,'
                                                    + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                                                    + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                                                    + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                                                    + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);

        Test.setCurrentPage(Page.DatacenterGeocoding);
        ApexPages.currentPage().getParameters().put('id', dc.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(dc);
        DatacenterGeocodingControllerExt controller = new DatacenterGeocodingControllerExt(stdController);
        controller.cancel();
        Test.stopTest();
    }

    @isTest static void testNegativeScenarios() {
        DatacenterTriggerHelperHTTPCalloutMock httpMock = new DatacenterTriggerHelperHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"AuthError",'
                                                    + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                                                    + '"Legacy_Entry__c":false,"Name":"Testing encoding","Geo_Latitude__c": 12.02323, "Geo_Longitude__c": 70.23212,'
                                                    + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                                                    + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                                                    + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                                                    + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);

        Test.setCurrentPage(Page.DatacenterGeocoding);
        ApexPages.currentPage().getParameters().put('id', dc.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(dc);
        DatacenterGeocodingControllerExt controller = new DatacenterGeocodingControllerExt(stdController);
        controller.validateGeolocation();

        Test.setCurrentPage(Page.DatacenterGeocoding);
        ApexPages.currentPage().getParameters().put('id', dc.Id);
        delete dc;
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(dc);
        DatacenterGeocodingControllerExt controller1 = new DatacenterGeocodingControllerExt(stdController);
        controller.validateGeolocation();

        Test.stopTest();
    }

    @isTest static void testDatacenterGeocodingWrappers() {
        Test.startTest();
        DatacenterGeocodingControllerExt controller = new DatacenterGeocodingControllerExt();

        DatacenterTriggerHelper.GeolocationWrapper wrapper = new DatacenterTriggerHelper.GeolocationWrapper();
        DatacenterTriggerHelper.Result results = new DatacenterTriggerHelper.Result();
        DatacenterTriggerHelper.AddressComponent address = new DatacenterTriggerHelper.AddressComponent();
        DatacenterTriggerHelper.Geometry geometry = new DatacenterTriggerHelper.Geometry();
        DatacenterTriggerHelper.Location location = new DatacenterTriggerHelper.Location();
        DatacenterTriggerHelper.Bounds bounds = new DatacenterTriggerHelper.Bounds();

        Test.stopTest();
    }
}