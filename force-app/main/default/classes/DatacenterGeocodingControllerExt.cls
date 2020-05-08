public class DatacenterGeocodingControllerExt {
    public Boolean isGeolocationInvalid { get; set; }
    public Boolean showManualGeolocationOverridePanel { get; set; }
    public Datacenter__c record { get; set; }

	public DatacenterGeocodingControllerExt() {

	}

    public DatacenterGeocodingControllerExt(ApexPages.StandardController stdController) {
        Id recordId = ApexPages.currentPage().getParameters().get('Id');
        List<Datacenter__c> lstDatacenter = [SELECT Id, Name, Account__c, Account__r.Name, Facility_Address__c, Facility_City__c,
                                                    Facility_State__c, Facility_ZIP_Code__c, Facility_Country__c,
                                                    Geo_Latitude__c, Geo_Longitude__c, Status__c, RecordType.Name
                                               FROM Datacenter__c WHERE Id = :recordId LIMIT 1];

        if (lstDatacenter != null
            && !lstDatacenter.isEmpty()) {
            record = lstDatacenter[0];
        } else {
            record = null;
        }

        isGeolocationInvalid = false;
        if (record == null
            || String.isBlank(record.Geo_Latitude__c)
            || String.isBlank(record.Geo_Latitude__c)
            || record.Geo_Latitude__c == '0'
            || record.Geo_Longitude__c == '0'
            || record.Geo_Latitude__c == '0.0'
            || record.Geo_Longitude__c == '0.0') {
            isGeolocationInvalid = true;
        }
    }

    public PageReference fetchGeolocation() {
        try {
            DatacenterTriggerHelper.Location geolocation = DatacenterTriggerHelper.fetchGeocodes(record.Facility_City__c, record.Facility_Country__c);
            record.Geo_Latitude__c = String.valueOf(geolocation.lat);
            record.Geo_Longitude__c = String.valueOf(geolocation.lng);
            System.debug('>>>>' + record.Geo_Latitude__c + ' ' + record.Geo_Longitude__c);
            //throw new DmlException('test');
            saveGeolocation();
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occurred while fetching/updating the Geolocation. Please update the geolocation manually.'));
            System.debug('>>>> Error occurred while fetching/updating the Geolocation: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            isGeolocationInvalid = true;
            showManualGeolocationOverridePanel = true;
        }

        return null;
    }

    public PageReference cancel() {
        PageReference ref = new PageReference('/' + record.Id);
        return ref;
    }

    public PageReference saveGeolocation() {
        try {
            update record;
            validateGeolocation();
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occurred while fetching/updating the Geolocation. Please update the geolocation manually.'));
            System.debug('>>>> Error occurred while fetching/updating the Geolocation: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            isGeolocationInvalid = true;
            showManualGeolocationOverridePanel = true;
        }

        return null;
    }

    @testvisible private void validateGeolocation() {
        if (String.isBlank(record.Geo_Latitude__c)
            || String.isBlank(record.Geo_Latitude__c)
            || record.Geo_Latitude__c == '0'
            || record.Geo_Longitude__c == '0'
            || record.Geo_Latitude__c == '0.0'
            || record.Geo_Longitude__c == '0.0') {
            isGeolocationInvalid = true;
            showManualGeolocationOverridePanel = true;
        } else {
            isGeolocationInvalid = false;
            showManualGeolocationOverridePanel = false;
        }
    }
}