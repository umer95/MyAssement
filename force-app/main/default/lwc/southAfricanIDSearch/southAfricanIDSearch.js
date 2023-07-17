import { LightningElement, track, api } from 'lwc';
import searchForHolidayWRTID from '@salesforce/apex/SouthAfricanIdSearchController.searchForHolidayWRTID';

export default class SouthAfricanIDSearch extends LightningElement {

    @track southAfricaIDValue;
    @track disableSearchButton = true;
    @track errorMsg = 'Please enter a valid South African Id Number';
    @track showHolidayTable = false;
    @track showErrorMsg = true;
    @track showSpinner = false;
    publicHolidaysColumns = [
        { label: 'Holiday Name', fieldName: 'holidayName' },
        { label: 'Holiday Date', fieldName: 'holidayDate' },
        { label: 'Holiday Type', fieldName: 'holidayType' },
        { label: 'Holiday Description', fieldName: 'holidayDesc', wrapText: true }
    ];
    publicHolidaysData = [];

    handleClick() {
        this.showSpinner = true;

        //from first 2 digit we can't predict which year is this. So if the year value is less than current year then
        //put current century value(20) otherwise put previous century value (19)
        var currentYearTwoDigits = parseInt(new Date().getFullYear().toString().substring(2, 4), 10);
        var inputYear = parseInt(this.southAfricaIDValue.substring(0, 2), 10);
        var bestGuessYear = (inputYear <= currentYearTwoDigits ? '20' : '19') + inputYear;

        //Extracting the Date of Birth, Gender and Citizenship from substring the South African ID Number
        var birthDay = parseInt(this.southAfricaIDValue.substring(4, 6), 10);
        var birthMonth = parseInt(this.southAfricaIDValue.substring(2, 4), 10);
        var birthYear = parseInt(bestGuessYear, 10);
        var gender = parseInt(this.southAfricaIDValue.substring(6, 10)) < 5000 ? "Female" : "Male";
        var citizenship = parseInt(this.southAfricaIDValue.substring(10, 11)) == 0 ? "SA citizen" : "Permanent Resident";

        //validation is already on the onchange event of the input field, so the data is already validated. So we fire the backend
        searchForHolidayWRTID({
            southAfricanID: this.southAfricaIDValue,
            birthDay: birthDay,
            birthMonth: birthMonth,
            birthYear: birthYear,
            gender: gender,
            citizenship: citizenship
        })
            .then((result) => {
                this.showSpinner = false;
                console.log('result:::' + JSON.stringify(result));
                //if error, then show error message on the screen
                if (result.errorMsg) {
                    this.showErrorMsg = true;
                    this.errorMsg = result.errorMsg;
                }
                else {
                    //otherwise, show public holiday on the lighting data table 
                    this.publicHolidaysData = result.publicHolidays;
                    this.showHolidayTable = true;
                    //disable the search button and input button, as we have recieved the response
                    this.disableSearchButton = true;
                    this.template.querySelector('lightning-input').disabled = true;
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log(JSON.stringify(error));
                this.showErrorMsg = true;
                this.errorMsg = error.body.message;
            });
    }

    southAfricaIDValueChange(event) {
        this.showSpinner = true;
        const regexForSouthAfricanID = /(([0-9]{2})(0|1)([0-9])([0-3])([0-9]))([ ]?)(([0-9]{4})([ ]?)([0-1][8]([ ]?)[0-9]))/gm;
        const southAfricanID = event.target.value;
        this.disableSearchButton = true;
        this.showErrorMsg = true;

        //using the regex to check the format of the South African ID Number
        const found = southAfricanID.match(regexForSouthAfricanID);

        //checking the checksum using the Luhn formula
        //if regex and checksum are correct then the South African ID Number is valid
        if (found && this.checkLuhnValue(southAfricanID)) {
            this.southAfricaIDValue = event.target.value;
            this.disableSearchButton = false;
            this.showErrorMsg = false;
        }

        this.showSpinner = false;
    }

    checkLuhnValue(saID) {
        let nDigits = saID.length;
        let nSum = 0;
        let isSecond = false;

        for (let i = nDigits - 1; i >= 0; i--) {

            let d = saID[i].charCodeAt() - '0'.charCodeAt();

            if (isSecond == true) {
                d = d * 2;
            }

            nSum += parseInt(d / 10, 10);
            nSum += d % 10;

            isSecond = !isSecond;
        }
        return (nSum % 10 == 0);
    }
}