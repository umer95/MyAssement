public inherited sharing class IdentificationDetailHelper {

    public static void upsertRecordOfIdentificationDetail(String identificationNumber, Date dateOfBirth, String gender, String citizenship) {
        
        //Getting any previous record with the same South African ID Number, so we can get the previous counter value
        List<Identification_Detail__c> identificationDetailList = new List<Identification_Detail__c>([SELECT Id,Number_of_time_Calendarific_API_called__c FROM Identification_Detail__c WHERE Identification_Number__c =:identificationNumber WITH SECURITY_ENFORCED]);

        //generating the instance of the record using the External Unique ID (Identification_Number__c)
        Identification_Detail__c identificationDetailToUpsert = new Identification_Detail__c(Identification_Number__c=identificationNumber);
        identificationDetailToUpsert.Identification_Number__c = identificationNumber;
        identificationDetailToUpsert.Date_of_Birth__c = dateOfBirth;
        identificationDetailToUpsert.Gender__c = gender;
        identificationDetailToUpsert.Citizenship__c = citizenship;
        
        //If insert case, then put counter as 1
        if(identificationDetailList.isEmpty()) {
            identificationDetailToUpsert.Number_of_time_Calendarific_API_called__c = 1;
        }
        //If update case, then put counter as previous value + 1
        else {
            identificationDetailToUpsert.Number_of_time_Calendarific_API_called__c = identificationDetailList[0].Number_of_time_Calendarific_API_called__c + 1;
        }

        //upsert on the basis of the Identification_Number__c (External Unique ID)
        upsert identificationDetailToUpsert Identification_Number__c;
    }
        
    
}