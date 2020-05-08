@isTest
private class DatacenterTriggerHelperTest {
	
	@isTest static void testDatacenterGeocoding() {
        DatacenterTriggerHelperHTTPCalloutMock httpMock = new DatacenterTriggerHelperHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"San Jose",'
                              + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                              + '"Legacy_Entry__c":false,"Name":"Testing encoding","Override_Geolocation__c":false,'
                              + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                              + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                              + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                              + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);

        dc.Facility_City__c = 'Bengaluru';
        dc.Facility_Country__c = 'India';
        update dc;
        Test.stopTest();
	}
	
	@isTest static void testDatacenterGeocodingError() {
		DatacenterTriggerHelperHTTPCalloutMock httpMock = new DatacenterTriggerHelperHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"RequestInvalid",'
                              + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                              + '"Legacy_Entry__c":false,"Name":"Testing encoding","Override_Geolocation__c":false,'
                              + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                              + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                              + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                              + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);
        Test.stopTest();
	}
	
    @isTest static void testDatacenterGeocodingAuthError() {
        DatacenterTriggerHelperHTTPCalloutMock httpMock = new DatacenterTriggerHelperHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"AuthError",'
                              + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                              + '"Legacy_Entry__c":false,"Name":"Testing encoding","Override_Geolocation__c":false,'
                              + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                              + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                              + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                              + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
		Map<id,Datacenter__c> dcmap= new Map<id,Datacenter__c>();
		//dcmap.put(dc.id,dc);
		List<Datacenter__c> dclist=new List<Datacenter__c>();
		dclist.add(dc);
		DatacenterTriggerHelper.updateGeolocationForDatacenters(dcmap,dclist);
		String City='San Jose';
		String Country='US';
		//Location geolocationRes=DatacenterTriggerHelper.fetchGeocodes(City,Country);
        System.debug(dc);
        Test.stopTest();
    }

    @isTest static void testDatacenterGeocodingWrappers() {
        Test.startTest();
        DatacenterTriggerHelper.GeolocationWrapper wrapper = new DatacenterTriggerHelper.GeolocationWrapper();
        DatacenterTriggerHelper.Result results = new DatacenterTriggerHelper.Result();
        DatacenterTriggerHelper.AddressComponent address = new DatacenterTriggerHelper.AddressComponent();
        DatacenterTriggerHelper.Geometry geometry = new DatacenterTriggerHelper.Geometry();
        DatacenterTriggerHelper.Location location = new DatacenterTriggerHelper.Location();
        DatacenterTriggerHelper.Bounds bounds = new DatacenterTriggerHelper.Bounds();
        DatacenterTriggerHelper.booster();

        Test.stopTest();
    }
}