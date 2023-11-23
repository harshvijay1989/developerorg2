import { LightningElement, track, api, wire } from 'lwc';
import getDTRecords from '@salesforce/apex/ConfigrationPageCMP_Handler.getDocumentTemplate';
import jsPDF from '@salesforce/resourceUrl/jsFile';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getObjectName from '@salesforce/apex/ConfigrationPageCMP_Handler.getObjectName';
import getDocumentData from '@salesforce/apex/PreviewDocument.getDocumentData';
import getDocuContentBody from '@salesforce/apex/ConfigrationPageCMP_Handler.getDocuContentBody';
import saveDataURL from '@salesforce/apex/UserSignCtrl.saveDataURL';
import pdf from '@salesforce/resourceUrl/pdf';
import doc from '@salesforce/resourceUrl/doc';
import getUsers from '@salesforce/apex/PreviewDocument.getUsers';
import CheckStatus from '@salesforce/apex/PreviewDocument.CheckStatus';

import { publish, MessageContext } from "lightning/messageService";
import Record_Selected from "@salesforce/messageChannel/Record_Selected__c";

import quickActionModalCss from "@salesforce/resourceUrl/quickActionModalCss";
import { loadStyle } from "lightning/platformResourceLoader";

export default class ShowInvoiceInPDF extends NavigationMixin(LightningElement) {
    @track value;
    @track options = [];
    @track showAsPDF = false;
    @track selectedId;
    objApi = 'Opportunity';
    @api recordId;
    signIsTrue;
    mainModal = true;
    showSignaturePad = false;
    @track matchedData;
    data;
    attachementId;
    currentUserProfileId;
    isWordAndPdf = false;
    pdf = pdf;
    doc = doc;
    @track showDocument = false;
    @track isShowProceed = true;
    @track showConfiguration = false;
    @track showLeftPanel = false;
    @track showContainerFull = true;
    @track showContainer5 = false;
    @track showDocumentTemplate = '';
    @track progress = 0;
    @track processStatus = 'In Progress';
    @track convertedData;
    @track contentDocumentId;
    @api isLoaded = false;
    @track finalRslt;
    @track message;
    @track showpdfChildObject = false;
    @track contentVersionId;
    @track showImageSignature = false;
    @api isLoaded1 = false;


    isCanvasSigned = true;
    isShowImg = false;

    canvas;
    ctx;
    isDrawing = false;
    //     @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.recordId = currentPageReference.state.recordId;
    //     }
    // }
    // context = messageContext
    @wire(MessageContext)
    messageContext;


 
    connectedCallback() {
         setTimeout(() => {
        this.CheckStatusReview();
        }, 500);
        console.log('@@@@ ' + this.recordId);
        loadStyle(this, quickActionModalCss); 
    }


             CheckStatusReview() {
        CheckStatus({ recordId: this.recordId })
            .then(result => {
                if (result == 'Error') {
                    const closeAction = new CloseActionScreenEvent();
                    this.dispatchEvent(closeAction);
                    this.showToast('Error', 'Quote Status must be Needs Review before Generate document', 'Error');

                }
                else {
                    this.showDocument = true;
                }


            })
            .catch(error => {
                alert('hiii error' + JSON.stringify(error));
                this.showToast('Error', 'Error sending email', 'error');
               
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
        console.log("record id", this.recordId);
        if (this.canvas) {
            return; 
        }
        this.canvas = this.template.querySelector('.signature-canvas');
        this.ctx = this.canvas.getContext('2d');

        this.template.querySelector('.signature-canvas').addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.querySelector('.signature-canvas').addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.querySelector('.signature-canvas').addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.querySelector('.signature-canvas').addEventListener('mouseout', this.handleMouseOut.bind(this));
    }

    handleSave() {
        const base64Signature = this.canvas.toDataURL();
        saveDataURL({ base64Signature })
            .then(result => {
            })
            .catch(error => {
            });
    }
    isSignatureProvided;
    message;
    message2;
    updateMessage(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Signature Created successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.message = event.detail.message;

        const payload = {
            recordIdHistory : this.recordId,
            recordIdwe: this.selectedId,
            content: this.contentVersionId,
        };
        publish(this.messageContext, Record_Selected, payload);

        this.showSignaturePad = false;
        this.showConfiguration = false;
        this.closeQuickAction();
        this.navigateToFilesClone(event);
    }

    updateMessage2(event) {
        console.log("update mssage ");
        this.message2 = event.detail.message;
        this.mainModal = false;//this.message2;
        this.showSignaturePad = false;
        this.showConfiguration = false;
        this.pdfURL = false;
        this.closeQuickAction();
        this.navigateToFilesClone(event);
    }

    handleClear() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
    handleCancel() {
        this.showConfiguration = false;

    }
    handleMouseDown(event) {
        this.isDrawing = true;
        const x = event.clientX - this.canvas.getBoundingClientRect().left;
        const y = event.clientY - this.canvas.getBoundingClientRect().top;
        this.ctx.beginPath();
        this.ctx.moveTo(x, y);
    }
    handleMouseMove(event) {
        if (this.isDrawing) {
            const x = event.clientX - this.canvas.getBoundingClientRect().left;
            const y = event.clientY - this.canvas.getBoundingClientRect().top;
            this.ctx.lineTo(x, y);
            this.ctx.stroke();
        }
    }
    handleMouseUp() {
        this.isDrawing = false;
    }
    handleMouseOut() {
        this.isDrawing = false;
    }
    showImg = false;
    handleByImageSign(event) {
        this.uploadImg = true;
        console.log("handle by Signature ");
        let selectedFile = event.target.files[0];
        this.inputFiles = selectedFile ? selectedFile.name : '';
        if (selectedFile) {
            this.showImg = true;
            this.selectedFileName = selectedFile.name;
            const reader = new FileReader();
            reader.onload = () => {
                this.headerSelectedIMG = reader.result;
                this.showImg = reader.result;
            };
            reader.readAsDataURL(selectedFile);
        } else {
            this.selectedFileName = '';
            this.showImg = null;
            this.headerSelectedIMG = null;
        }
    }
    jsPdfInitialized = false;
    renderedCallback() {
        loadScript(this, jsPDF).then(() => { });
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;
    }
    _objectName;
    _allRecords;
    _allRecordForSelectedObj = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.handleObject();
            //this.handleGetData();
            this.fetchReocrdsAccordingObjectName();
        } else {
        }
    }

    showNotification(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    handleObject() {
        getObjectName({ recordIdOrPrefix: this.recordId }).then(result => {
            this._objectName = result;
        });
        //this.handleGetData();

    }
    //owner name: roshina
    fetchReocrdsAccordingObjectName() {
        console.log('---->recordId', this.recordId);
        getDTRecords({ recordId: this.recordId }).then(result => {
            console.log("this show document ", result);

            var tempOptions = [];
            this._allRecords = result;
            for (let i = 0; i < result.length; i++) {

                if (result[i].documentTemplate.isActive__c == true) {
                    if (result[i].documentTemplate.Object_Name__c == this._objectName) {
                        this._allRecordForSelectedObj.push({ records: result[i].documentTemplate, files: result[i].files });
                        tempOptions.push({ label: result[i].documentTemplate.Name, value: result[i].documentTemplate.Id });
                    }
                }
            }
            this.options = tempOptions;
            //  }
        })
            .catch(error => {
                this.error = error;
            });
    }
    closeModel(event) {
        this.showAsPDF = false;
    }
    closeQuickAction() {
        const opportunityId = this.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: opportunityId,
                actionName: 'view',
            },
        });
    }

    @track files = [];
    handleChange(event) {
        let data = JSON.parse(JSON.stringify(this._allRecordForSelectedObj));
        this.selectedId = event.detail.value;

        console.log("selectedId ", this.selectedId);
        let newArray = data.filter(item => {
            return this.selectedId == item.records.Id;
        });

        this.files = newArray[0].files;


        if (newArray[0].files) {
            this.isShowProceed = false;
            this.attachementId = newArray[0].files[0];

        } else {
            this.showNotification('Info', 'There is no Atttachement in this record for Preview', 'Info');
        }
    }
    navigateToFiles(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/showPreviewDocument?parameter='
            }
        });
    }
    openASPDF(event) {
        this.showAsPDF = true;
    }
    openModal() {
        this.showAsPDF = true;
    }
    closeModal() {
        this.showAsPDF = false;
    }
    getDocPreview(event) {
        getDocuContentBody({ recId: this.recordId, contentDId: this.selectedId })
            .then((res) => {
            })
            .catch((error) => {
            })
    }


    sendEmailAct = false;
    handleClick() {
        this.openPDFAndWordPreview = false;
        this.pdfURL = false;
        this.mainModal = false;
        this.sendEmailAct = true;
    }
    handleClickCancel(event) {
        const opportunityId = this.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: opportunityId,
                actionName: 'view',
            },
        });

    }
    customeSignature = false;
    handleShowBox(event) {
        this.showConfiguration = true;
        this.customeSignature = true;
        this.uploadImg = false;
    }
    showCustomSignature(event) {
        this.customeSignature = true;
        console.log("custom sign ");
        this.uploadImg = false;

    }
    uploadImg = false;
    handleAllclick() {
        this.customeSignature = false;
        this.showConfiguration = true;
        this.uploadImg = true;
    }

    hideCustomSigntaure(event) {
        console.log("hide custoom sign");
        this.customeSignature = false;
        this.uploadImg = true;
    }
    //--------------------------------------------------------

    handleClickSendEmail(event) {
        this.sendEmailAct = true;
        this.mainModal = false;
        this.pdfURL = false;
        this.openPDFAndWordPreview = false;
    }
    isUserFetched = false;
    handleProceedClick() {
        getUsers()
            .then(result => {
                console.log("click on save button @@@@@@@22");
                this.isUserFetched = result;
                console.log("isUserFetched ", this.isUserFetched);
                if (this.isUserFetched == true) {
                    this.isUserFetched == true;
                    console.log("heloo one ");
                    this.showpdfChildObject = true;
                    this.navigateToFilesClone();
                } else if (this.isUserFetched == false) {
                    this.isUserFetched == false;
                    const evt = new ShowToastEvent({
                        title: 'Toast Info',
                        message: 'You must create the first user signature',
                        variant: 'info',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.openPDFAndWordPreview = false;
                    this.showSignaturePad = true;
                    this.mainModal = false;
                    this.customeSignature = true;


                }
                console.log("content versio id ", this.contentVersionId);
                console.log("show data 3####", this.selectedId);
            })
            .catch(error => {
                this.error = error; // Handle any errors
            });
    }

    handleIframeLoad() {
        this.isLoaded1 = true;
    }

    handleIframeLoad() {
        console.log('helo ddd');
        this.isLoaded1 = true;
    }

    //--------------------------------------------------------

    vfPgaeUrl2 = false;
    get vfPgaeUrl() {
        console.log("heloo spinner");

        return "https://crmlandingsoftwareprivatelimited--dev2--c.sandbox.vf.force.com/apex/testingVFPage";
    }

    openPDFAndWordPreview = false;
    @track fileType1 = '';
    isLoaded2 = false;
    isLoaded3 = false;
    @track showProgressBar = false;
    @track showProgressBar1 = false;
    pdfURL
    iframeSpnr = true;
    @track iframeLoading = true;

    handleIframeLoad(event) {
        this.iframeLoading = false;
    }

    @track contentTitle;
    navigateToFilesClone(event) {
        if (this.isWord == true) {
            this.isPdf = false;
            this.isLoaded2 = true;
            this.fileType1 = 'Word';
            this.isLoaded3 = true;
        }
        if (this.isPdf == true) {
            this.isWord = false;
            this.isLoaded2 = true;
            this.fileType1 = 'pdf';
            this.isLoaded3 = true;
        }
        this.getDocPreview(event);
        let contentDocId;
        this.isLoaded = true;
        this.fileType1 = 'Word';
        getDocumentData({ docId: this.selectedId, recordId: this.recordId, objApi: this._objectName, contentId: contentDocId, docTemplateId: this.selectedId, fileType: this.fileType1 })
            .then((res) => {
                console.log("content version id is %%%%%%%%%%%%%%%%%%%%%%%%% ",res);
                this.contentVersionId = res;
                this.iframeSpnr = true;
                console.log("result of success is ", res);
                this.isLoaded3 = false;
                this.isLoaded2 = false;
                this.isWordAndPdf = false;
                this.iframeSpnr = false;
                if (this.contentVersionId.includes('Error,')) {
                    this.callErrorMethod();
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Document saved successfully ... ',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    console.log('selectedId',this.selectedId)
                    //recrodhistory opportunity id 
                    // recordIdwe document id 
                    // contentversion content version id 
                    const payload = {
                        recordIdHistory : this.recordId,
                        recordIdwe: this.selectedId,
                        content:this.contentVersionId,
                    };
                    publish(this.messageContext, Record_Selected, payload);
                }


                window.history.back();
                //window.location.reload();
                //pdfUrl = '/apex/testingVFPage';

                //alert(this.pdfUrl);
                //window.open(this.isResult, '_blank');

                //const previewURL = `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${this.isResult}`;
                //window.open(previewURL, '_blank');


                // else if (this.isWord == true || this.isPdf == true) {
                //     this[NavigationMixin.Navigate]({
                //         type: 'standard__namedPage',
                //         attributes: {
                //             pageName: 'filePreview'
                //         },
                //         state: {
                //             selectedRecordId: res
                //         }
                //     })
                //     //this.progressBarIsTrue = false;
                //     //this.fileType1 = '';
                // }
                //}

            })
            .catch((error) => {
            })
    }

    callErrorMethod() {
      //  alert(this.contentVersionId);
        const opportunityId = this.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: opportunityId,
                actionName: 'view',
            },
        });
        //window.history.back();    
    }

    navigateToVFPage() {
        // Replace 'Your_VF_Page_Name' with the name of your VF page
        window.location.href = '/apex/Your_VF_Page_Name?id=' + this.recordId;
    }
    // Pdf And Word File Preview

    @track isPreviewModalOpen = false;
    @track selectedPreview = null;
    isPdf = false;
    isWord = false;
    previewOptions = [
        { label: 'PDF Preview', value: 'pdf' },
        { label: 'Word Preview', value: 'word' }
    ];


    navigateToPDFFiles() {
        let pdfFile = [];
        for (let i = 0; i < this.files.length; i++) {
            if (this.files[i].FileType == 'PDF') {
                pdfFile.push(this.files[i]);
            }
        }
        let pdf = JSON.parse(JSON.stringify(pdfFile));
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: pdf[0].ContentDocumentId
            }
        })
    }

    handlePreviewTypeChange(event) {
        this.isWordAndPdf = true;
        this.isPdf = true;
        this.isWord = false;
        this.handlePreview();

    }
    handlePreviewTypeChangeWord(event) {
        this.isWord = true;
        this.isPdf = false;
        this.handlePreview();

    }

    handlePreview() {
        this.percentageValue = 25;
        if (this.isWord == true) {
            this.isPdf = false;
            //this.fileType1 = 'Word';
            this.isLoaded2 = true;
            /*this.progressBarIsTrue = true;
            this.showProgressBar = true;
            this.isLoaded2 = true;
            this.isPreviewModalOpen = false;
            this.percentageValue = 50;

            this._interval = setInterval(() => {
                this.progress = this.progress + 20;
                this.processStatus = 'Processing . . .  ' + this.progress + '/100';
                if (this.progress == '100') {
                    this.processStatus = 'Completed';
                    clearInterval(this._interval);
                    this.showProgressBar1 = true;
                    this.progress = 0;
                    //this.navigateToFilesClone(event);
                }
            }, 300);*/

            this.isPreviewModalOpen = false;
            this.navigateToFilesClone(event);
        }
        if (this.isPdf == true) {
            this.isWord = false;
            //this.fileType1 = 'pdf';
            /*this.progressBarIsTrue = true;
            this.showProgressBar = true;
            this.isLoaded2 = true;
            this.isPreviewModalOpen = false;
            this.percentageValue = 50;

            this._interval = setInterval(() => {
                this.progress = this.progress + 20;
                this.processStatus = 'Processing . . .  ' + this.progress + '/100';
                if (this.progress == '100') {
                    this.processStatus = 'Completed';
                    clearInterval(this._interval);
                    this.showProgressBar1 = true;
                    this.progress = 0;
                    //this.navigateToFilesClone(event);
                }
            }, 300)*/

            this.isPreviewModalOpen = false;
            this.navigateToFilesClone(event);
        }
    }

    handleCancel() {
        this.isPreviewModalOpen = false;
        this.mainModal = false;
    }

    handleModalClose() {
        this.isPreviewModalOpen = false;
    }
}