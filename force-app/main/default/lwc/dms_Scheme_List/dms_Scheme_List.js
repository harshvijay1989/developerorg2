import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// import Community_Url from '@salesforce/label/c.Community_Url';
import getAllScheme from "@salesforce/apex/SchemeRecordDisplayController.getAllScheme";
export default class SchemeRecordDispaly extends NavigationMixin(LightningElement) {
    @track selectedSchemeId;
    @track schemesRecord;
    @track error;
    // customLabelUrl = Community_Url;

    @wire(getAllScheme)
    getAllScheme({ error, data }) {
        if (data) {
            var newData = JSON.parse(JSON.stringify(data))

            newData.forEach(item => {
                item.Start_Date__c = this.formatDate(item.Start_Date__c);
                item.End_Date__c = this.formatDate(item.End_Date__c);
            });

            this.schemesRecord = newData;
            // console.log('data@@14', JSON.stringify(this.schemesRecord));

        } else if (error) {
            console.log(error);
            this.error = error;
            // alert('error');
        }
    }
    handleOrder(event) {

        this.selectedSchemeId = event.target.value;
        console.log('line 25 ' + this.selectedSchemeId);


        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'schemedetail__c'


            },
            state: {
                id: this.selectedSchemeId
            }
        });



        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: this.customLabelUrl+'schemedetailpage?c__recordId=' + this.selectedSchemeId

        //     }

        // }

        // );


    }

    leftSliderBtn() {
        this.template.querySelector('.scrollmenu').scrollLeft -= 300;
    }

    rightSliderBtn() {
        this.template.querySelector('.scrollmenu').scrollLeft += 300;
    }

    formatDate(date) {
        const dateTimeString = date;

        // Create a Date object by parsing the string
        const dateTime = new Date(dateTimeString);

        // Extract the date components
        const year = dateTime.getFullYear();
        const month = dateTime.getMonth() + 1; // Months are 0-indexed, so add 1
        const day = dateTime.getDate();

        // Create a simple date string in the format YYYY-MM-DD
        const simpleDateString = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;

        console.log('simpleDateString ===========>', simpleDateString); // Output: "2023-09-30"
        return simpleDateString;

    }
}