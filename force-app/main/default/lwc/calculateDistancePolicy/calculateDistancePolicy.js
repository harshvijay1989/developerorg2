import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Lead.HMC_Distance_approval_reason__c'];
import { NavigationMixin } from 'lightning/navigation';
import getApprovalStatus from '@salesforce/apex/AccountCurrentApprovalController.getApprovalStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CalculateDistancePolicy extends NavigationMixin(LightningElement) {

    @api recordId;
    ak;
    accountCustomFieldValue;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    accountRecord({ error, data }) {
        if (data) {
            this.accountCustomFieldValue = data.fields.HMC_Distance_approval_reason__c.value;
        } else if (error) {
            console.error('Error loading account data', error);
        }
    }
    redirectToApproval() {
        if (this.ak != null && this.ak != undefined) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.ak,
                    actionName: 'view'
                }
            });
        }else {
                const evt = new ShowToastEvent({
                    title: 'Info',
                    message: 'No approval available.',
                    variant: 'info',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
        }
    }
    retrieveApprovalStatus() {
        getApprovalStatus({ recordId: this.recordId })
            .then(result => {
                this.ak = result;
            })
            .catch(error => {
                console.error('Error fetching approval status', error);
            });
    }
    connectedCallback() {
        this.retrieveApprovalStatus();
    }
}