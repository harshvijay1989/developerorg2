import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getContactAccountName from '@salesforce/apex/OrderController.getContactAccountName';
import createOrder from '@salesforce/apex/OrderController.createOrder';

export default class Dms_createOrderCmp extends NavigationMixin(LightningElement) {

    @track stage = '';
    @track orderDate = '';
    @track account = '';
    @api schemeid;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.schemeId = currentPageReference.state?.id;
        }
    }


    @wire(getContactAccountName)
    wiredContactAccountName({ error, data }) {
        if (data) {
            console.log('data: ' + data);
            this.account = data;
        } else if (error) {
            console.log('error: ' + JSON.stringify(error));
            //  alert(this.account);
            // Handle error if necessary
        }
    }

    connectedCallback() {
        console.log('this.account.Id: ' + this.schemeid);
    }

    handleSaveClick() {
        // Call Apex method to create a new record

        createOrder({ accountId: this.account.Id, schemeId: this.schemeid })
            .then(result => {
                console.log('result: ' + result);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Order__c',
                        actionName: 'view'
                    },
                });
                // Handle success (e.g., show confirmation message)
            })
            .catch(error => {
                // Handle errors (e.g., display error message)
            });
    }
}