import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import IMAGES from "@salesforce/resourceUrl/FIveDiscount";
import getschemedetail from '@salesforce/apex/SchemeRecordDisplayController.getschemedetail';
export default class SchemesDetails extends LightningElement {

    @track isShowModel = false;
    @track scheme;
    error;
    urlId;

    companyLogo = IMAGES;
    get showDetails() {
        return this.scheme != undefined ? true : false;
    }

    _currentPageReference
    currentpageid

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlId = currentPageReference.state?.id;
        }
    }

    connectedCallback() {
        this.handleData();
    }

    handleData() {
        getschemedetail({ searchKey: this.urlId })
            .then((result) => {
                this.scheme = JSON.parse(result);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    closeDetails() {
        history.go(-1);
    }

    handleOrderModal() {
        this.isShowModel = !this.isShowModel;
    }

    handlePlaceOrder() {
        this.template.querySelector('c-dms_-Place-Order').handlePlaceOrder();
        setTimeout(() => {
            this.isShowModel = false;
        }, 1500);
    }
}