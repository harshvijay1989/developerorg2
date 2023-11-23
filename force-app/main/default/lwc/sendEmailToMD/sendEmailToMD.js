import { LightningElement, track, api, wire } from 'lwc';
import sendMailWithPdf from '@salesforce/apex/SendEmailToMDController.sendEmailWithPDF';
import Validationcheck from '@salesforce/apex/SendEmailToMDController.checkValidations';
import modal from "@salesforce/resourceUrl/custommodalcss1";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class SendEmailToMD extends LightningElement {
    @api recordId;
    vfPageUrllink;
    showComponent = true;
    @track isLoading = false;
    @track showDocument = false;


    connectedCallback() {

        //this.checkValidations();  
        setTimeout(() => {
            this.checkValidations();
        }, 700);
    }


    checkValidations() {
        Validationcheck({ recordId: this.recordId })
            .then(result => {
                if (result == 'Customer invalid') {
                    const closeAction = new CloseActionScreenEvent();
                    this.dispatchEvent(closeAction);
                    this.showToast('Error', 'Customer should be agreed before sending mail to MD', 'Error');

                }
                else if (result == 'Generate Document') {
                    const closeAction = new CloseActionScreenEvent();
                    this.dispatchEvent(closeAction);
                    this.showToast('Error', 'Generate document before sending mail to MD', 'Error');

                } else if (result == 'Invalid Stage') {
                    const closeAction = new CloseActionScreenEvent();
                    this.dispatchEvent(closeAction);
                    this.showToast('Error', 'Quote Status must be Needs Review before sending mail to MD', 'Error');

                } else if (result == 'Not approved') {
                    const closeAction = new CloseActionScreenEvent();
                    this.dispatchEvent(closeAction);
                    this.showToast('Error', 'You must take approval from RSM before sending mail to MD', 'Error');

                }
                else {
                    this.showDocument = true;
                }


            })
            .catch(error => {
                alert('hiii error' + JSON.stringify(error));
                this.showToast('Error', 'Error sending email', 'error');
                //const closeAction = new CloseActionScreenEvent();
                //this.dispatchEvent(closeAction);
            });
    }



    sendmail() {
        this.isLoading = true;
        sendMailWithPdf({ recordId: this.recordId })
            .then(result => {
                setTimeout(() => {
                    window.location.reload();
                }, 700);
                this.showToast('Success', 'Email sent successfully', 'success');
                const closeAction = new CloseActionScreenEvent();
                this.dispatchEvent(closeAction);
            })

            .catch(error => {

                this.showToast('Error', 'Error sending email', 'error');
                const closeAction = new CloseActionScreenEvent();
                this.dispatchEvent(closeAction);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }











   renderedCallback() {
        setTimeout(() => {

            this.vfPgaeUrl();

        }, 1000);

    }

    vfPgaeUrl() {
        const recordId = this.recordId;
        console.log("dynamic content version id ", recordId);

        this.vfPageUrllink = `https://3dboost2--dev2--c.sandbox.vf.force.com//apex/SendMdPage?conVirId=${recordId}`;
        //alert('vfPageUrl : '+vfPageUrl);
        if (recordId == undefined) {
            console.log("vf page ", vfPageUrl);
            this.noContent = true;

            return vfPageUrl;

        } else {
            console.log("not null vf page", vfPageUrl);
            //    this.noContent=true;
            return vfPageUrl;
        }
        console.log('vfPageUrl', vfPageUrl);
        //return "https://crmlandingsoftwareprivatelimited--dev2--c.sandbox.vf.force.com/apex/DocumentPreview?id=${contentVersionId}";
    }

}