/* APTS_UtilityFns
 * Utility/static methods.
 *
 * Developer: Harish Emmadi, APTTUS
 * Business Owner: 
 *
 * Scenario:
 * 
 * 
 *
 * History:
 *
 * //  flattenSet                          : Takes Set<String> and flattens to a string
   //  splitString_toset                   : Takes String, endStr and Returns a set that contains each substring of the String that is terminated by the end of the String.
 */
public with sharing class APTS_UtilityFns {
	//  --------------------------------------------------------
    // flattenSet: Takes Set<String>, separator and flattens to a string.
    //  --------------------------------------------------------
    public static String flattenSet(Set<String> strSet, String separator) {
        String res = '';
        System.Debug('APTPS_UtilityFns - strSet: ' + strSet);
        if(strSet == null
            || strSet.isEmpty())
            return res;
        for(String s : strSet)
        {
            res += String.isNotBlank(s) ? s+separator : '';
        }
        res = res.removeEnd(separator);// remove extra separator added at the end.
        return res;
    }

    //  --------------------------------------------------------
    // splitString_toset: Takes String, endStr and Returns a set that contains each substring of the String that is terminated by the end of the String.
    //  --------------------------------------------------------
    public static Set<String> splitString_toset(String flatString, String endStr) {
        Set<String> res = new Set<String>();
        if(String.isBlank(flatString))
        	return res;

        List<String> stringList = String.isNotBlank(flatString) ? flatString.split(endStr) : new List<String>();
		for(String s : stringList)
        {
            if(String.isNotBlank(s))
                res.add(s);
        }
        return res;
    }
}