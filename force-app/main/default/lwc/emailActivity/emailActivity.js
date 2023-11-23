import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getConRole from '@salesforce/apex/emailToCustomerCtrl.getContactRole';
import getAttachment from '@salesforce/apex/emailToCustomerCtrl.getAttachment';
import SendEmail from '@salesforce/apex/emailToCustomerCtrl.SendEmail';
import getContactEmail from '@salesforce/apex/emailToCustomerCtrl.getContactEmail';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class EmailActivity extends LightningElement {
    columns = [
        { label: 'Name', fieldName: 'Name', type: "text" },
        { label: 'Role', fieldName: 'Role', type: "text" },
        { label: 'IsPrimary', fieldName: 'IsPrimary', type: "boolean" },
        { label: 'Email', fieldName: 'Email', type: "text" }
    ];

    @api recordId;// = '0061y000009SyNUAA0';
    //@api sendRecordId;
    @track relatedContactRole = [];
    @track contactId;
    @track toEmailAddress = '';
    @track mailBody = 'Dear sir, <br/><br/>Anirudh Sharma Asm sent you a document to review and sign. <br/><br/><b>Truecaller team.</b>';
    @track isEmailModalShow = false;
    @track isModalOpen = true;
    @track selectedContactIds = [];
    @track ContactEmails = [];
    @track attachmentArray = [];
    @track subject = '';
    @track isEmailSuccess = false;
    @track isLoaded = false;
    @track opptyName = '';
    @track attachmentName = '';
    @track relatedContactRolefalse = false;
    @track relatedContactRoletrue = false;
    currentPageReference = null;
    urlStateParameters = null;

    /*@wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log('===@',currentPageReference);
          this.recordId = currentPageReference.state.recordId || null;
          console.log('recordidsss'+this.recordId)
       }
    }*/

    /*@wire(getConRole, { recId: this.recordId })
    wiredRecordsMethod({ error, data }) {
        console.log('Hello'+data);
        console.log('recordId##'+this.recordId);
        if (data) {
            console.log('Record Id: ' + this.recordId);
            this.relatedContactRole = data;
            this.opptyName = this.relatedContactRole[0].OppName; 
            console.log('this.opptyName '+this.opptyName);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data  = undefined;
        }
    }*/

    connectedCallback() {
        //setTimeout(() => {
            //this.handlegetContact();
        //}, 3000);
        this.fetchAttachment();
    }

    handlegetContact() {
        getConRole({ recId: this.recordId })
            .then(result => {
                this.relatedContactRole = result;
                if (this.relatedContactRole.length == 0) {
                    this.relatedContactRolefalse = true;
                    const event = new CustomEvent('increasecount', {
                        detail: {
                            message: false
                        }
                    });
                    this.dispatchEvent(event);
                } else {
                    this.relatedContactRoletrue = true;
                    const event = new CustomEvent('increasecount', {
                        detail: {
                            message: false
                        }
                    });
                    this.dispatchEvent(event);
                }
                this.opptyName = this.relatedContactRole[0].OppName;
                console.log('this.opptyName ' + this.opptyName);
                this.error = undefined;
            })
    }

    handleContactChange(event) {
        this.contactId = event.detail.value;
    }

    handleToSubject(event) {
        this.subject = event.target.value;
    }

    handleMailBodyChange(event) {
        this.mailBody = event.target.value;
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleCancel() {
        this.sendFalseMoadlParameter();
        // window.history.back();
        //    this.isModalOpen = true;
    }
    handleBack() {
        this.isEmailModalShow = false;
        this.ContactEmails = [];
    }

    handleFunction(event) {
        this.selectedContactIds = [];
        var selectedRowsArray = event.detail.selectedRows;
        console.log('selectedRowsArray' + selectedRowsArray);
        selectedRowsArray.forEach(currentItem => {
            this.selectedContactIds.push(currentItem.Id);
        });
        console.log('IDS' + this.selectedContactIds)

    }
    fetchContactEmail() {
        getContactEmail({ conRecIds: this.recordId })
            .then(result => {
                //alert(JSON.stringify(result));
                this.ContactEmails.push(result);
                /*result.forEach(currentItem => {
                    this.ContactEmails.push(currentItem.account.HMC_Contact_Email__c);
                });*/
                console.log('this.ContactEmails ' + JSON.stringify(this.ContactEmails));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error.message || 'Unknown error';
                this.ContactEmails = undefined;
            });
    }
    handleToEmailChange(event) {
        this.ContactEmails = event.target.value;
        console.log('#### ' + this.ContactEmails)
    }
    handleNext() {
        //this.isLoaded = true;
        setTimeout(() => {
            this.isEmailModalShow = true;
            const event = new CustomEvent('increasecount', {
                        detail: {
                            message: false
                        }
                    });
                    this.dispatchEvent(event);
            //this.isLoaded = false;
        }, 1000);
        this.fetchContactEmail();
    }
    fetchAttachment() {
        getAttachment({ recId: this.recordId })
            .then(result => {
                //this.relatedContactRoletrue = true;
                    

                this.attachmentArray = result;
                console.log('this.attachmentArray ' + JSON.stringify(this.attachmentArray));
                const dtTime = this.attachmentArray[0].ContentDocument.CreatedDate;
                console.log('dtTime ' + dtTime);
                const dateObj = new Date(dtTime);
                const dateCreate = dateObj.toISOString().split('T')[0];
                this.subject = this.attachmentArray[0].LinkedEntity.Name;
                this.attachmentName = this.attachmentArray[0].LinkedEntity.Name + '.' + dateCreate + ' ' + this.attachmentArray[0].ContentDocument.Title + '.' + this.attachmentArray[0].ContentDocument.FileType;
                this.error = undefined;
                this.handleNext();
            })
            .catch(error => {
                this.error = error.message || 'Unknown error';
                this.attachmentArray = undefined;
            });
    }
    isLoaded2 = false;
    sendEmailMtd() {
        this.isLoaded2 = true;
        SendEmail({ Emails: this.ContactEmails, Body: this.mailBody, recId: this.recordId, subj: this.subject, contactIds: this.selectedContactIds })
            .then(result => {
                this.isEmailSuccess = result;
                // console.log('result@@@ ',result);
                if (this.isEmailSuccess) {
                    this.showToast();
                }
                if (this.isEmailSuccess == false) {
                    this.errorToast();
                }
                this.error = undefined;
                //this.sendFalseMoadlParameter();
                // const opportunityId = this.recordId;
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__recordPage',
                //     attributes: {
                //         recordId: opportunityId,
                //         actionName: 'view',
                //     },
                // });
                //window.history.back();
            })
            .catch(error => {
                this.error = error.message || 'Unknown error';
                this.ContactEmails = undefined;
            });
    }
    showToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Email Sent Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        this.sendFalseMoadlParameter();
    }
    errorToast() {
        const event = new ShowToastEvent({
            title: 'Failed',
            message: 'Email Sent Failed',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        this.sendFalseMoadlParameter();
    }
    @track progressValue = false;
    sendFalseMoadlParameter() {
        //alert('call');
        this.progressValue = true;
        // Creates the event with the data.
        const event = new CustomEvent('increasecount', {
            detail: {
                message: this.progressValue
            }
        });
        this.dispatchEvent(event);
    }
}