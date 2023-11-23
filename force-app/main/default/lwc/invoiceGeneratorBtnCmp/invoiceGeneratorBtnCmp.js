import { LightningElement, wire, api, track } from 'lwc';
import getContentVersionTitle from '@salesforce/apex/PreviewDocument.getContentVersionTitle';
import getPdfName from '@salesforce/apex/PreviewDocument.getPdfName';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from "lightning/messageService";
import Record_Selected from "@salesforce/messageChannel/Record_Selected__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCheckApproved from '@salesforce/apex/PreviewDocument.getCheckApproved';

export default class InvoiceGeneratorButton extends LightningElement {
    @track mapValueConVerId;
    @track contentTitle = 'None'; // Id of the record where you want to check for ContentVersion
    @track dateTime = '';
    @api   recordId;
    @track isButtonDisabled = true;
    @track buttonLabel = 'View Document';
    iframeSpnr = true;
    @track lmsDataShow = "";
    @api messageFromParent;
    noContent = false;
    @track sendEmailActButton = true;
    @track buttonDisable = true;
    spinner1 = true;
    disable = true;

    @wire(MessageContext)
    messageContext;

    subscription = null;

    connectedCallback() {
        //alert('Hey');
        //var buttonValue = this.template.querySelector('.buttonColor');
        //buttonValue.style.backgroundColor = 'grey';
        this.subscriptionToMessageChannel();
    }
    
   
    subscriptionToMessageChannel() {
        console.log("in handle subscribe");
        this.subscription = subscribe(
            this.messageContext,
            Record_Selected,
            (message) => {
                console.log(' Message123 is : ', message);
                this.lmsDataShow = message.recordIdwe;
                this.mapValueConVerId = message.content;
                this.handleShowPdfName();
            }
        )
    }

    //@api recordId;
    mapFromApex
    @wire(getPdfName, { recordId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            //alert(JSON.stringify(data));
            console.log('Data is', data);
            this.mapFromApex = data;
            this.disable = false;
            this.processData();
        } else if (error) {
            console.error('Error:', error);
        }
    }
    @track mapValueOfGetValue;
    @track mapValueOfObjRecName;
    processData(event) {
        this.mapValueConVerId = this.mapFromApex['Content_Version__c'];
        this.contentTitle = this.mapFromApex['Document_Name__c'];
        this.dateTime = this.mapFromApex['Document_Generate_Date_Time__c'];
        this.buttonDisable = false;
        //var buttonValue = this.disabletemplate.querySelector('.buttonColor');
        //alert(this.contentTitle);
        if (this.contentTitle == 'None') {
            console.log("none part");
            //buttonValue.style.backgroundColor = 'grey';
            //this.disable = true;

        } else {
            console.log("not none ");
            //buttonValue.style.backgroundColor = 'green';
        }
        
        this.buttonDisable = false;
        console.log("content title ", this.contentTitle);
    }

    @track disableBtn = false;
    handleShowPdfName(event) {
        var rId = this.lmsDataShow;
        console.log("lmsDataShow ", JSON.stringify(rId));
        getContentVersionTitle({ recordId: this.lmsDataShow, conVerId: rId})
            .then(result => {
                console.log("result is ", result);
                //alert(result);
                this.contentTitle=Object.keys(result)[0] ;// key
                this.dateTime= Object.values(result)[0];
                console.log("this content ",this.contentTitle); 

                //var buttonValue = this.template.querySelector('.buttonColor');
                if (this.contentTitle == 'None') {
                    //this.disableBtn = true;
                    //alert('true');
                    console.log("none $$$");
                    //buttonValue.style.backgroundColor = 'black';
                    //buttonValue.style.color = 'red';
                } else {
                    console.log("not none $$$");
                    //buttonValue.style.backgroundColor = 'green';
                }
                this.disable = false;
                //var buttonValue = this.template.querySelector('.buttonColor');
                // if (button) {
                //     button.style.backgroundColor = 'green';
                // }

                //console.log("value is ", button);

                //this.buttonDisable = false;
                //console.log("content title ", this.contentTitle);
            })
            .catch(error => {
                console.log("error is ", error);
            });
    }
    @track conRolSpnr = false;
    sendEmailAct = false;
    vfPgaeUrl3 = false;
    titleName = 'Preview Document';
    handleClickSendEmail(event) {
        //this.spinner = true;
        this.conRolSpnr = true;
        this.titleName = 'Select Contact';
        this.vfPgaeUrl3   = false;
        this.vfPgaeUrl2   = false;
        this.sendEmailAct = true;
        this.spinner1     = false;
        this.iframeSpnr   = true;

        const payload = {
            recordIdHistory: this.recordId,
            recordIdwe: this.selectedId,
            content: this.contentVersionId,
        };
        publish(this.messageContext, Record_Selected, payload);
        console.log("send document payload ",payload);
      //  this.spinner = false;
    }
    handleClickCancel() {

    }
    iconClosed(event) {
        this.iframeSpnr = true;
    }
    hideModalBox() {
        this.vfPgaeUrl2 = false;
        this.sendEmailAct = false;
        this.iframeSpnr = true;
    }

    handleIframeLoad(event) {
        this.iframeSpnr = false;
    }

    handleButtonClick() {
        if (this.contentVersionRecord.data.fields.Title.value) {
            this.isButtonDisabled = false;
            //this.buttonLabel = 'Invoice Generator';
            this.navigateToVFPage();
        } else {
            this.isButtonDisabled = true;
        }
    }
    vfPgaeUrl2 = false;
    get vfPgaeUrl() {
        const recordId = this.mapValueConVerId;
        console.log("dynamic content version id ", recordId);
        
        const vfPageUrl = `https://3dboost2--dev2--c.sandbox.vf.force.com//apex/DocumentPreview?conVirId=${recordId}`;
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
    spinner = false;
    navigateToVFPage(event) {

        //alert('1 '+ this.recordId);
        getCheckApproved({ detailPageRecId : this.recordId })
            .then(result => {
                //alert(result);
                if(result == false){
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Document is not Approved',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    console.log("click on button ");
                    this.titleName = 'Preview Document  : ' + this.contentTitle;
                    this.vfPgaeUrl2 = true;
                    this.spinner = true;
                    this.vfPgaeUrl3 = true;
                }
        })
        .catch(error => {
            console.log("error is ", error);
        });
    }
    @track progressValue = false;
    hanldeProgressValueChange(event) {
        this.progressValue = event.detail.message;
        if(this.progressValue == false){
            this.conRolSpnr = this.progressValue;
        }
        if(this.progressValue == true){
            this.hideModalBox();
        }
    }
    falseSpinner(event){
        this.conRolSpnr = event.detail.message;
    }
}