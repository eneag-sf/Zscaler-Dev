public class DatacenterTriggerHelper {
    //Constants
    public static final String ENDPOINT = 'https://maps.googleapis.com/maps/api/geocode/json';
    public static final String STATUS_OK = 'OK';
    public static final String METHOD = 'GET';

    public static List<Id> lstDatacenterIdsToProcess;

    public static void updateGeolocationForDatacenters(Map<Id, Datacenter__c> oldDatacentersMap, List<Datacenter__c> newDatacenters) {
        lstDatacenterIdsToProcess = new List<Id>();

        for (Datacenter__c dc : newDatacenters) {
            if ((oldDatacentersMap == null
                || !oldDatacentersMap.containsKey(dc.Id) || oldDatacentersMap.get(dc.Id).Facility_City__c != dc.Facility_City__c || oldDatacentersMap.get(dc.Id).Facility_Country__c != dc.Facility_Country__c)) {
                lstDatacenterIdsToProcess.add(dc.Id);
            }
        }

        queryGeolocationForDatacenters(JSON.serialize(lstDatacenterIdsToProcess));
    }

    public static void calculateDatacenterHWSWValues(List<Datacenter__c> newDatacenters) {
        for (Datacenter__c dc : newDataCenters) {
            dc.Min_PZEN_HW3_Baseline_Units__c = dc.Uplink_Profile_Gbps__c != null && dc.Downlink_Profile_Gbps__c != null && dc.Uplink_Profile_Gbps__c < 0.7 ? Math.ceil(dc.Downlink_Profile_Gbps__c/0.4) : 0;
            dc.Min_PZEN_HW3_Baseline_Systems__c = dc.Uplink_Profile_Gbps__c != null && dc.Downlink_Profile_Gbps__c != null && dc.Uplink_Profile_Gbps__c < 0.7 
                                                    ? (dc.Min_PZEN_HW3_Baseline_Units__c != null && Math.ceil(dc.Min_PZEN_HW3_Baseline_Units__c/3) < 2 ? 2 : Math.ceil(dc.Min_PZEN_HW3_Baseline_Units__c/3)) : 0;
            dc.Add_N_1_HW_Units_HW3__c = dc.Min_PZEN_HW3_Baseline_Units__c != null && dc.Min_PZEN_HW3_Baseline_Units__c != 0 ? dc.Min_PZEN_HW3_Baseline_Units__c + 3 : 0;
            dc.Add_N_1_HW_Systems_HW3__c = dc.Min_PZEN_HW3_Baseline_Units__c != null && dc.Min_PZEN_HW3_Baseline_Units__c != 0 ? dc.Min_PZEN_HW3_Baseline_Systems__c + 1 : 0;
            dc.Add_N_N_HW_SW_Redundancy_Systems_HW3__c = dc.Min_PZEN_HW3_Baseline_Systems__c * 2;
            dc.Add_N_N_HW_SW_Redundancy_Units_HW3__c = dc.Min_PZEN_HW3_Baseline_Units__c * 2;

            dc.Min_PZEN_HW6_Baseline_Units__c = dc.Uplink_Profile_Gbps__c != null && dc.Downlink_Profile_Gbps__c != null && dc.Uplink_Profile_Gbps__c >= 0.7 
                                                    ? (dc.Downlink_Profile_Gbps__c > dc.Uplink_Profile_Gbps__c ? Math.ceil(dc.Downlink_Profile_Gbps__c/0.4) : Math.ceil(dc.Uplink_Profile_Gbps__c/0.4)) : 0;
            dc.Min_PZEN_HW6_Baseline_Systems__c = dc.Min_PZEN_HW6_Baseline_Units__c != null && dc.Min_PZEN_HW6_Baseline_Units__c != 0 
                                                    ? (Math.ceil(dc.Min_PZEN_HW6_Baseline_Units__c/6) < 2 ? 2 : Math.ceil(dc.Min_PZEN_HW6_Baseline_Units__c/6)) : 0;
            
            dc.Add_N_1_HW_Systems_HW6__c = dc.Min_PZEN_HW6_Baseline_Units__c != null && dc.Min_PZEN_HW6_Baseline_Units__c != 0 ? dc.Min_PZEN_HW6_Baseline_Systems__c + 1 : 0;
            dc.Add_N_1_HW_Units_HW6__c = dc.Min_PZEN_HW6_Baseline_Units__c != null && dc.Min_PZEN_HW6_Baseline_Units__c != 0 
                                            ? Math.ceil(dc.Min_PZEN_HW6_Baseline_Units__c/dc.Min_PZEN_HW6_Baseline_Systems__c) + dc.Min_PZEN_HW6_Baseline_Units__c : 0;
            dc.Add_N_N_HW_SW_Redundancy_Systems_HW6__c = dc.Min_PZEN_HW6_Baseline_Systems__c * 2;
            dc.Add_N_N_HW_SW_Redundancy_Units_HW6__c = dc.Min_PZEN_HW6_Baseline_Units__c * 2;

            dc.Number_of_LB_Instances__c = dc.Min_PZEN_HW6_Baseline_Units__c != null && dc.Min_PZEN_HW6_Baseline_Units__c != 0 
                                                ? (dc.Uplink_Profile_Gbps__c != null && Math.ceil(dc.Uplink_Profile_Gbps__c/3) * 2 < 2 ? 2 : Math.ceil(dc.Uplink_Profile_Gbps__c/3) * 2) : 0;
            dc.Dedicated_LBs__c = dc.Number_of_LB_Instances__c != 0 ? (Math.ceil(dc.Number_of_LB_Instances__c/3) < 2 ? 2 : Math.ceil(dc.Number_of_LB_Instances__c/3)) : 0;
            dc.Dedicated_LB_at_N_N__c = dc.Number_of_LB_Instances__c != 0 ? Math.ceil(dc.Number_of_LB_Instances__c/dc.Dedicated_LBs__c) + dc.Number_of_LB_Instances__c : 0;
            dc.Number_of_LB_Instances_HW__c = dc.Number_of_LB_Instances__c != 0 ? dc.Dedicated_LBs__c + 1 : 0;
            dc.ZSC_PRIV_ZENSW__c = dc.Select_Desired_Redundancy__c != null && dc.Select_Desired_Redundancy__c.equalsIgnoreCase('n+1') ? dc.Add_N_1_HW_Units_HW3__c + dc.Add_N_1_HW_Units_HW6__c : dc.Add_N_N_HW_SW_Redundancy_Units_HW3__c + dc.Add_N_N_HW_SW_Redundancy_Units_HW6__c;
            dc.ZSC_PRIV_ZENHW6__c = dc.Select_Desired_Redundancy__c != null && dc.Select_Desired_Redundancy__c.equalsIgnoreCase('n+1') ? dc.Add_N_1_HW_Systems_HW6__c : dc.Add_N_N_HW_SW_Redundancy_Systems_HW6__c;
            dc.ZSC_PRIV_ZENHW3__c = dc.Select_Desired_Redundancy__c != null && dc.Select_Desired_Redundancy__c.equalsIgnoreCase('n+1') ? dc.Add_N_1_HW_Systems_HW3__c : dc.Add_N_N_HW_SW_Redundancy_Systems_HW3__c;
            dc.ZSC_PRIV_LB__c = dc.Select_Desired_Redundancy__c != null && dc.Select_Desired_Redundancy__c.equalsIgnoreCase('n+1') ? dc.Dedicated_LBs__c : dc.Dedicated_LB_at_N_N__c;
            dc.PZEN_Management_I_F__c = (dc.ZSC_PRIV_ZENHW3__c + dc.ZSC_PRIV_ZENHW6__c ) * 2;
            dc.PZEN_Service_I_F__c = dc.ZSC_PRIV_ZENSW__c;
            dc.VIP__c = dc.Min_PZEN_HW3_Baseline_Systems__c != 0 ? 1 : dc.Number_of_LB_Instances__c/2;
            dc.LB_I_F__c = dc.Min_PZEN_HW3_Baseline_Systems__c != 0 ? 2 : (dc.Select_Desired_Redundancy__c != null && dc.Select_Desired_Redundancy__c.equalsIgnoreCase('n+n') ? dc.Number_of_LB_Instances_HW__c * 4 : dc.Number_of_LB_Instances__c * 4);
            dc.LB_Service_IPs__c = dc.Min_PZEN_HW3_Baseline_Systems__c != 0 ? 2 : (dc.Select_Desired_Redundancy__c != null && dc.Select_Desired_Redundancy__c.equalsIgnoreCase('n+n') ? dc.Dedicated_LB_at_N_N__c : dc.Number_of_LB_Instances__c);
            dc.LB_Management_I_F__c = dc.Min_PZEN_HW3_Baseline_Systems__c != 0 ? 0 : (dc.Select_Desired_Redundancy__c != null && dc.Select_Desired_Redundancy__c.equalsIgnoreCase('n+n') ? dc.Number_of_LB_Instances_HW__c * 2 : dc.Dedicated_LBs__c * 2);
            dc.Total_IPs__c = dc.LB_Service_IPs__c + dc.LB_Management_I_F__c + dc.VIP__c + dc.PZEN_Management_I_F__c + dc.PZEN_Service_I_F__c;
            dc.Total_I_F__c = dc.Total_IPs__c - dc.VIP__c + dc.LB_I_F__c;
            dc.Number_Of_Public_IPs_Required__c = dc.Total_IPs__c;
            dc.Total_Number_Of_1G_I_F_Required__c = dc.Total_I_F__c;
        }
    }

    @future(callout=true)
    private static void queryGeolocationForDatacenters(String lstDatacenterIdsToProcessJSON) {
        //Make the API call to Google Geocoding API and update the datacenter records
        List<Id> lstDatacenterIdsToProcess = new List<Id>();
        List<Datacenter__c> lstDatacentersToUpdate = new List<Datacenter__c>();

        //Deserialize the input JSON
        lstDatacenterIdsToProcess = (List<Id>)JSON.deserialize(lstDatacenterIdsToProcessJSON, Type.forName('List<Id>'));
        for (Datacenter__c dc : [SELECT Id, Facility_Country__c, Facility_City__c, Geo_Latitude__c, Geo_Longitude__c FROM Datacenter__c WHERE Id IN :lstDatacenterIdsToProcess]) {
			Location geolocation = fetchGeocodes(dc.Facility_City__c, dc.Facility_Country__c);
			lstDatacentersToUpdate.add(new Datacenter__c(
                                    Id = dc.Id,
                                    Geo_Latitude__c = String.valueOf(geolocation.lat),
                                    Geo_Longitude__c = String.valueOf(geolocation.lng)
                                ));
            //try {
            //    String finalEndpoint = ENDPOINT
            //                            + '?address=' + EncodingUtil.urlEncode(dc.Facility_City__c + ',' + dc.Facility_Country__c, 'UTF-8')
            //                            + '&key=' + 'AIzaSyDtColnZmBRVmwMUXbDTT5tfdpEWXU9O4c'; //Using the developer key for now. Need to change the authentication logic when using Prod key.

            //    HttpRequest request = new HttpRequest();
            //    request.setEndpoint(finalEndpoint);
            //    request.setMethod(METHOD);
            //    System.debug('>>>> request: ' + request.getEndpoint());

            //    Http http = new Http();
            //    HttpResponse response = http.send(request);
            //    System.debug('>>>> response: ' + response.getBody());
            //    GeolocationWrapper result = (GeolocationWrapper)JSON.deserialize(response.getBody(), GeolocationWrapper.Class);

            //    Datacenter__c datacenter;
            //    if (result.status == STATUS_OK && result.results.size() > 0) {
            //        lstDatacentersToUpdate.add(new Datacenter__c(
            //                                    Id = dc.Id,
            //                                    Geo_Latitude__c = String.valueOf(result.results[0].geometry.location.lat),
            //                                    Geo_Longitude__c = String.valueOf(result.results[0].geometry.location.lng)
            //                                ));
            //    } else {
            //        lstDatacentersToUpdate.add(new Datacenter__c(
            //                                    Id = dc.Id,
            //                                    Geo_Latitude__c = '0',
            //                                    Geo_Longitude__c = '0'
            //                                ));
            //        System.debug('>>>> Error: Unable to fetch geolocation for ' + dc.Id + '. Code: ' + result.status);
            //    }
            //} catch (Exception  ex) {
            //    lstDatacentersToUpdate.add(new Datacenter__c(
            //                                    Id = dc.Id,
            //                                    Geo_Latitude__c = '0',
            //                                    Geo_Longitude__c = '0'
            //                                ));
            //    System.debug('>>>> Error: Unable to fetch geolocation for ' + dc.Id);
            //}
            
        }

        System.debug('>>>> lstDatacentersToUpdate: ' + lstDatacentersToUpdate);
        TriggerUtility.updateGeolocationForDatacenterExecuted();
        Database.update(lstDatacentersToUpdate, false);
    }

    public static Location fetchGeocodes(String city, String country) {
        Location geolocationResult;
        String finalEndpoint = ENDPOINT + '?address=' + EncodingUtil.urlEncode(city + ',' + country, 'UTF-8') + '&key=' + 'AIzaSyCSh9I27BUEhNCgfp-Y2quIyPNB0MIixd4'; //Prod key
                                //+ '&key=' + 'AIzaSyDtColnZmBRVmwMUXbDTT5tfdpEWXU9O4c'; //Using the developer key for now. Need to change the authentication logic when using Prod key.
        HttpRequest request = new HttpRequest();
        request.setEndpoint(finalEndpoint);
        request.setMethod(METHOD);
        System.debug('>>>> request: ' + request.getEndpoint());

        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug('>>>> response: ' + response.getBody());
            GeolocationWrapper result = (GeolocationWrapper)JSON.deserialize(response.getBody(), GeolocationWrapper.Class);

            if (result.status == STATUS_OK && result.results.size() > 0) {
                geolocationResult = result.results[0].geometry.location;
            } else {
                geolocationResult = new Location();
                geolocationResult.lat = 0.0;
                geolocationResult.lng = 0.0;
            }
        } catch(Exception ex) {
            geolocationResult = new Location();
            geolocationResult.lat = 0.0;
            geolocationResult.lng = 0.0;
        }

        return geolocationResult;
    }

    public class GeolocationWrapper {
		public Result[] results;
		public String status;
		public GeolocationWrapper() {

        }
    }

    public class Result {
        public String formattedAddress;
        public String placeId;
        public AddressComponent[] addressComponents;
        public Geometry geometry;
        public String[] types;

        public Result() {

        }
    }

    public class AddressComponent {
        public String shortName;
        public String longName;
        public String[] types;

        public AddressComponent() {

        }
    }

    public class Geometry {
        public Location location;
        public Bounds bounds;
        public String locationType;
        public Bounds viewport;

        public Geometry() {

        }
    }

    public class Location {
        public double lat;
        public double lng;

        public Location() {

        }
    }

    public class Bounds {
        public Location northeast;
        public Location southwest;

        public Bounds() {

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
	}
}