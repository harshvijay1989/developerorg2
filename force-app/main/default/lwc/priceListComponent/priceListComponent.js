import { LightningElement, wire, track, api } from 'lwc';
import getPriceListName from '@salesforce/apex/PriceListCtrl.getPriceListName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getAttachmentUrl from '@salesforce/apex/PriceListCtrl.getAttachmentUrl';
export default class PriceListComponent extends LightningElement {

    @track attachmentOptions = [];
    @track selectedAttachmentId;
    @track pdfUrl ='';
    @track isSpinner = false;
    @track priceList = [];
    get showOptions() {
        return this.attachmentOptions != undefined && this.attachmentOptions.length != 0;
    }

    get showPriceList(){
        return this.attachmentOptions != undefined && this.attachmentOptions.length != 0;
    }

    @wire(getPriceListName)
    wiredAttachments({ error, data }) {
        if (data) {
            console.log('data===>', JSON.stringify(data));
            this.priceList = data;

            data.forEach(attachment => {
                this.attachmentOptions = [...this.attachmentOptions, {
                    label: attachment.Name,
                    value: attachment.Id
                }];
            });

            console.log('this.attachmentOptions: ' + JSON.stringify(this.attachmentOptions));

            // if (this.attachmentOptions.length > 0) {
            //     console.log('this.attachmentOptions====>', this.attachmentOptions);
            //     this.selectedAttachmentId = this.attachmentOptions[0].value;
            // }
        } else if (error) {
            console.error(error);
        }
        //console.log('attachmentOptions====>',attachmentOptions);
    }

    handleAttachmentSelection(event) {
        //this.isSpinner = true;
        this.selectedAttachmentId = event.detail.value;
        //alert(event.detail.value);
        console.log('this.priceList=44===>', JSON.stringify(this.priceList));
        if (this.selectedAttachmentId) {
            
            for (let price in this.priceList) {
                if (this.priceList[price].Id == this.selectedAttachmentId && this.priceList[price].Content_Link__c != null ) {
                    this.isSpinner = true;
                    this.pdfUrl = this.priceList[price].Content_Link__c;
                    this.isSpinner = false;
                }
                
              
            }
            if(this.pdfUrl == ''){
                
                    this.isSpinner = true;
                    this.pdfUrl = null;
                    this.isSpinner = false;
                    this.showErrorToast();
                    console.log('error--->',error);
                    this.error = error;
                
            }
        }
    }
    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'PDF Not Found',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }
}