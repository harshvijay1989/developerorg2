import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { RefreshEvent } from 'lightning/refresh';
import beatMatrixRecord from '@salesforce/apex/BeatMatrixGroupMembCreationCtrl.gpmemberCreation';
import createGrpMember from '@salesforce/apex/BeatMatrixGroupMembCreationCtrl.saveGroupmemberRecord';
import fetchDealer from '@salesforce/apex/BeatMatrixGroupMembCreationCtrl.fetchDealer';

export default class BeatMatrixGroupMembCreation extends LightningElement {
    @api recordId;
    beatGroupId = '';
    groupmemRecordTypeId = '';
    beatgrp = true;
    @track dealerNameLst = [];
    selectedDealer ;


    @wire(beatMatrixRecord, { recordId: '$recordId' })
    wireRecord({ error, data }) {
        if (data) {
            console.log('data-->', data);
            this.beatGroupId = data.beatGroupRecord.Id;
            this.groupmemRecordTypeId = data.beatGroupMemRecordTypeId;
        } else if (error) {
            //alert(JSON.stringify(error));
            this.showToast('Error SomeThing Went Wrong', error.body.pageErrors[0].message, 'Error', 'dismissable');
            this.error = error;
        }
    };
    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting the Record Edit form.
        this.handleSave();
    }

    handleSave() {
        if (!this.dealerNameLst || this.dealerNameLst.length === 0) {
            this.showToast('Error', 'Dealer Name List is blank or empty', 'Error', 'dismissable');
            return;
        }
        createGrpMember({ beatGroupMembLst: this.dealerNameLst })
            .then(result => {
                // alert('Successfully created.');
                this.showToast('Success', 'Beat Group Member Created Successfully', 'Success', 'dismissable');
                // this.updateRecordView(this.recordId);
                  this.closeAction();


                // this.handleRefresh();
                //this.updateRecordView();
                // this.dispatchEvent(new CloseActionScreenEvent());
                // this.dispatchEvent(new RefreshEvent());
            })
            .catch(error => {
                this.showToast('Error SomeThing Went Wrong', error.body.pageErrors[0].message, 'Error', 'dismissable');
                // alert(error);
            });
    }
    handleDealers(event) {
        var dealer = event.detail.value[0];
        console.log(dealer);
        if (dealer != undefined) {
            this.selectedDealer = event.detail.value[0]
            this.fetchDealerRecord(event);
        }

    }

    handleRemovePill(event) {
        console.log(event.target.name);
        var removeDealerId = event.target.name;
        if (removeDealerId != undefined) {
            var dealerData = this.dealerNameLst;
            var inx = dealerData.findIndex(dlr => dlr.Dealer__c == removeDealerId);
            console.log('inx', inx);
            dealerData = dealerData.splice(inx, 1);
        }
    }

    fetchDealerRecord(event) {
        fetchDealer({ delearId: event.detail.value[0] })
            .then(result => {
                var dealerData = this.dealerNameLst;
                console.log('dealerData--->', dealerData.length);
                var dealerRecord = dealerData.find(dlr => dlr.Dealer__c == result.Id);
                console.log('dealerRecord--->', dealerRecord);
                if (dealerRecord != null) {
                    //alert(result.Name + ' is already present.')
                    this.showToast('Warning!', result.Name + ' is already present.', 'Warning', 'dismissable');
                } else {
                    dealerData.push({
                        'sObjectType': 'Beat_Matrix__c', 'Dealer__c': result.Id, 'Name': result.Name,
                        'RecordTypeId': this.groupmemRecordTypeId, Beat_Group__c: this.beatGroupId
                    });
                    this.dealerNameLst = dealerData;
                    console.log('>>>>>', JSON.stringify(this.dealerNameLst));
                    //const inputField = this.template.querySelector('lightning-input-field[field-name="Dealer__c"]');
                    //inputField.value = '';
                }
                 this.selectedDealer =  null
            })
            .catch(error => {
                this.showToast('Error SomeThing Went Wrong', error.body.pageErrors[0].message, 'Error', 'dismissable');
                // alert(error);
            });
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        setTimeout(() => {
            location.reload(true);
        }, 2000);


    }
    handleRefresh() {
        // refresh the standard related list
        this.dispatchEvent(new RefreshEvent());
    }
    updateRecordView() {
        eval("$A.get('e.force:refreshView').fire()");
    }

}