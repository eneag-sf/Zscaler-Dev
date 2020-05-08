trigger genericDatacenterTrigger on Datacenter__c (after Insert, after Update) {
    //Commenting the below code as the geolocation will be updated through record detail page UI
    // //When the record is inserted or the City / Country is updated, hit the Google Geocoding API
    // //and update the Datacenter record Latitude and Longitude fields.
    // if ((Trigger.isInsert || Trigger.isUpdate)
    //     && !TriggerUtility.isUpdateGeolocationForDatacenterExecuted())  {
    //     DatacenterTriggerHelper.updateGeolocationForDatacenters(Trigger.oldMap, Trigger.new);
    // }
}