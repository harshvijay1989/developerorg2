import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedAccounts from '@salesforce/apex/ChildRecordsController.getRelatedAccounts';
import getAccountDetailUrl from '@salesforce/apex/ChildRecordsController.getAccountDetailUrl';

export default class CustomTable extends NavigationMixin(LightningElement) {
    @api recordId;
    @track accountList;
    @track accountId;

    @wire(getRelatedAccounts, { recordId: '$recordId'})
    wiredAccountData({ error, data }) {
        if (data) {
            this.accountList = data;
        } else if (error) {
            console.error(error);
        }
    }

    navigateToAccount(event){
         this.accountId = event.currentTarget.dataset.id;
         console.log('accountId',this.accountId);
        this.sendAccount();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountId,
                actionName: 'view',
            },
        });


    }
    sendAccount(){
        getAccountDetailUrl({ AccountId: this.accountId })
        .then(result => {
            
        })
        .catch(error => {
            this.error = error;
            
        });
    }
}