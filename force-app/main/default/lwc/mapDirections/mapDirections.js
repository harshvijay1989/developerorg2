import { LightningElement, wire,api } from 'lwc';
import getTodayCreatedAccounts from '@salesforce/apex/MapDirectionsController.getTodayCreatedAccounts';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class MapDirections extends LightningElement {
    form_factor = FORM_FACTOR

    accounts;
    error;
    latVal;
    longVal;
    acclat;
    acclong;
    @api closePopup;
    @wire(getTodayCreatedAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
            this.error = null;
        } else if (error) {
            this.accounts = null;
            this.error = 'There are no plans available today'+error;
        }
    }

    constructor() {
        super();
        console.log('get current location in constructor');
        this.myCurrentLocationOnGoogleMap();

    }

    redirectToGoogleMaps(event) {
         
      
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                this.latVal = position.coords.latitude;
                this.longVal = position.coords.longitude;
            });
        }
        const account = event.target.value;
        this.acclat = account.BillingLatitude.substring(0, 8);;
        this.acclong = account.BillingLongitude.substring(0, 8);;

        if (this.acclat && this.acclong) {
            const url = 'https://www.google.com/maps/dir/?api=1&origin=' + this.latVal + ',' + this.longVal + '&destination=' + this.acclat + ',' + this.acclong + '&travelmode=Two-wheeler';
            window.open(url);
        }


        if(this.form_factor != 'Large'){
          window.location.reload();
        }
    }
    myCurrentLocationOnGoogleMap() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                this.latVal = position.coords.latitude;
                this.longVal = position.coords.longitude;
            });
        }
    }

}