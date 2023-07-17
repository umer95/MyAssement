public with sharing class SouthAfricanIdSearchController {

    private static final String API_KEY = 'f04506bf5142ae0b3ac1b0cc3b9741c20e9074d5'; 

    @AuraEnabled
    public static Response searchForHolidayWRTID(String southAfricanID, Integer birthDay, Integer birthMonth, Integer birthYear, String gender, String citizenship) {
        Response responseWrapper = new Response();
        PublicHolidayDetails publicHolidayDetailsObj = new PublicHolidayDetails();
        String countryCode = 'ZA';
        String responseFromCalendarific; 
        
        //Upserting the record of Identification Detail based in the South African ID Number
        //Identification Detail object store the information extracted from the South African ID Number(Date of Birth, Citizenship, Gender) and counter of Calendarific API calls
        IdentificationDetailHelper.upsertRecordOfIdentificationDetail(southAfricanID, Date.newInstance(birthYear, birthMonth, birthDay), gender, citizenship);

        //Calling the Calendarific API using the Birth Year extracted from the South African ID Number and hard-coded country code
        responseFromCalendarific = CalendarificAPIHelper.sendGetRequestToCalendarificAPI(String.valueOf(birthYear), countryCode);
        //Typed-Parsing is used to parse the json so we have replaced the variable name 
        //with "date" -> "dateVar" and "datetime" -> "datetimeVar" because "date" and "datetime" are reserved by system
        responseFromCalendarific = responseFromCalendarific.replaceAll('date', 'dateVar').replaceAll('datetime', 'datetimeVar').replace('"response":[]', '"response":{}');
        
        //JSON will be typed-parsed using the CalendarificAPIResponseWrapper class
        CalendarificAPIResponseWrapper calendarificAPIResponseWrapperObj = CalendarificAPIResponseWrapper.parse(responseFromCalendarific);

        //If the is any error message in the meta tag
        if(calendarificAPIResponseWrapperObj?.meta?.code == null || calendarificAPIResponseWrapperObj?.meta?.code != 200) {
            responseWrapper.errorMsg = calendarificAPIResponseWrapperObj?.meta?.error_detail;
            return responseWrapper;
        }
        //if there is any holiday data in the json
        else if(calendarificAPIResponseWrapperObj?.response?.holidays == null || calendarificAPIResponseWrapperObj?.response?.holidays.isEmpty()) {
            responseWrapper.errorMsg = 'No Holidays found for the combination ' + birthYear + ' and ' + countryCode +'!';
            return responseWrapper;
        }
        else {
            //extracting only the relevant information from the "holidays" tag in the JSON, so minimal information is passed to the model
            for(CalendarificAPIResponseWrapper.cls_holidays holiday : calendarificAPIResponseWrapperObj.response.holidays) {
                publicHolidayDetailsObj = new PublicHolidayDetails();
                publicHolidayDetailsObj.holidayName = holiday.name;
                publicHolidayDetailsObj.holidayDate = holiday.dateVar.iso;
                publicHolidayDetailsObj.holidayDesc = holiday.description;
                publicHolidayDetailsObj.holidayType = String.join(holiday.type, ',');
                responseWrapper.publicHolidays.add(publicHolidayDetailsObj);
            }
        }
        return responseWrapper;
    }
    
    public class Response {
        @AuraEnabled
        public List<PublicHolidayDetails> publicHolidays {get;set;}
        @AuraEnabled
        public String errorMsg {get;set;}
        
        public Response() {
            this.publicHolidays = new List<PublicHolidayDetails>();
            this.errorMsg = null;
        }
    }
    public class PublicHolidayDetails {
        @AuraEnabled
        public String holidayName {get;set;}
        @AuraEnabled
        public String holidayDate {get;set;}
        @AuraEnabled
        public String holidayDesc {get;set;}
        @AuraEnabled
        public String holidayType {get;set;}
    }
}