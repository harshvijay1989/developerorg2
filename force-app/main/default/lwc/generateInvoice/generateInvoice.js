import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import generatePDF from '@salesforce/apex/GenerateInvoiceCls.generatePDF';
import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GenerateInvoice extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showLoading = false;
    fileId;
    connectedCallback() {
        this.showLoading = true;
        setTimeout((data) => {
            if (this.recordId != undefined) {
                this.handleGeneratePDF();
                
                
            } else {
                setTimeout((data) => {
                    alert('2');
                    this.handleGeneratePDF();
                }, 20)
            }
        }, 20)
    }


    previewHandler() {
        
       
       this.showLoading=false;
        console.log('File Id '+this.fileId);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: this.fileId
            }
        })

    }
    handleGeneratePDF() {
        generatePDF({ recordId: this.recordId })
            .then((res) => {

                this.fileId = res;
            
                console.log('Id '+res);
               this.previewHandler();
               this.showSuccessToast();
                //this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((error) => {
                console.log('error: ', error);
            })
    }

    showSuccessToast() {
    const evt = new ShowToastEvent({
        title: 'Invoice Generated',
        message: 'Invoice Generated Sucsessfully',
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}
}