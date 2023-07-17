public inherited sharing class CalendarificAPIHelper {
	
    private static final String ENDPOINT_URL = 'https://calendarific.com/api/v2/holidays';
    private static final String API_KEY = 'f04506bf5142ae0b3ac1b0cc3b9741c20e9074d5'; 
    
    public static String sendGetRequestToCalendarificAPI(String year, String countryCode) {
        
        //generating endpoint from the URL, API KEY, Year and Country Code
        String endpointURL = ENDPOINT_URL + '?&api_key='+API_KEY+'&country='+countryCode+'&year='+year;
        String responseString;
        
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HTTPResponse();
        Http http = new Http();
        
        req.setEndpoint(endpointURL);
        req.setMethod('GET');

        res = http.send(req);
        
        responseString = res.getBodyAsBlob().toString();
        
        System.debug('responseString::: ' + responseString);
        
        return responseString;
    }
}