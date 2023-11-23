import { LightningElement, track, wire, api } from 'lwc';
import getObjectNames from '@salesforce/apex/ObjectNameController.getObjectNames';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveTemplateWithoutHeaderFooter from '@salesforce/apex/ObjectNameController.saveTemplateWithoutHeaderFooter';
import temSaveDataForPDF from '@salesforce/apex/ObjectNameController.temSaveDataForPDF';
import updateTemplate from '@salesforce/apex/ObjectNameController.updateTemplate';
import getOrgBaseUrl from '@salesforce/apex/ObjectNameController.getOrgBaseUrl';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';
import objectName from '@salesforce/messageChannel/objectName__c';
import getVFBaseURL from '@salesforce/apex/ProxyController.getVFBaseURL';
import getAllProfiles from '@salesforce/apex/ProfileController.getAllProfiles';
import { NavigationMixin } from "lightning/navigation";
import uploadDocument from '@salesforce/apex/extractTextFromDocxCtrl.uploadDocument';
import { loadScript } from 'lightning/platformResourceLoader';
import MAMMOTH_JS from '@salesforce/resourceUrl/mammothJs';
export default class DsignDashboard extends NavigationMixin(LightningElement) {

    @wire(MessageContext)
    messageContext;
    isLoading = false;
    selObjName = '';
    @api selectedObjectName;
    subscription = null;
    @track myVal = {};
    @track orgBaseUrl = '';
    formats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'clean',
        'table',
        'header',
        'color',
    ];
    @track selectedHeaderFooterConfigName = '';



    @track isShowMergeFields = false;
    @track isShowEditPermission = false;
    @track headerFooterConfig = false;
    @track disabledSaveButton = true;
    @track showSignaturePad = false;
    @track isShowModal = false;
    @track isShowModalProfile = false;
    @track isKeywordOpen = false;
    @track profileFromParent = "";
    @track sendDataInChild = "";
    @track showFileUpload = false;
    @track documentTemplatesRecordId = null;

    openGetObjectNamePopUp = false;
    isShowSaveAsHeading = false;
    isShowNewTemplateHeading = false;
    dataToSendAgain = '';

    selectedNav = 'default_recent';
    saveAsButtonVisible = false;
    disabledSaveAsButton = true;
    isShowSaveAsModal = false;
    isTemplateSavingPopUp = false;
    openSaveAsPopUp = false;
    saveAsTemplate = false;
    newVersion = false;
    newTemplate = false;
    ObjectNameOnEditTime;

    isLoaded = false;
    isLoadedToggle = false;

    //profile and permission 
    @track isModalOpen = false;
    @track isReadAllSelected = false;
    @track isEditAllSelected = false;
    @track selectAllChecked = false;
    @track profiles = [];
    @track selectedPermissions = [];
    @track allProfilesList = [];
    @track allProfilesList1 = [];
    @track checkdValue = [];
    @track resultProfile = "";
    @track showFileName = "";
    @track profileName = '';
    @api childData;
    @track headerFooterNone = false;
    @track withHeaderFooter = true;
    @track selectedObject;
    @track disableProfile = true;


    @track vfRoot;
    // Owner Name : Roshina Azmat
    // purpose :  ck Editor
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.documentTemplatesRecordId = currentPageReference.state?.c__recordId;
            this.selectedObjectName = currentPageReference.state?.c__object;
            console.log('object-----------', this.selectedObject);
            if (this.documentTemplatesRecordId) {
                this.saveAsButtonVisible = true;
                this.NextButtonVisible = false;

            } else {
                this.saveAsButtonVisible = false;
                this.NextButtonVisible = true;
            }
        }
    }

    @track uploadedFileName;
    @track error;

    @track showSpinner = false;
    @track showSpinner2 = false;
    fileContent;
    fileContent2 = false;
    showTextArea = false;
    extractedText;
    iframeIsVsbl = false;


    // Owner Name : Roshina Azmat
    // purpose :  ck Editor
    connectedCallback() {
        this.handleSubscribe();
        this.fetchVFBaseURL();
    }

    // renderedCallback() {
    //     if (!this.isLoadedToggle) {
    //         this.togglePanel();
    //         this.isLoadedToggle = true;
    //     }
    // }

    fetchVFBaseURL() {
        getVFBaseURL()
            .then(result => {
                this.vfRoot = result;
                var VfOrigin = this.vfRoot;
                window.addEventListener("message", (message) => {
                    if (message.origin !== VfOrigin) {
                        return; //Not the expected origin
                    }
                    //handle the message
                    if (message.data.name === "CKEDITOR_VALUE_EVENT") {
                        this.ckEditorData = message.data.payload.htmlData;
                        this.plainCkEditorData = message.data.payload.plainText


                    }
                    if (message.data.name === "MASSAGE") {
                        if (message.data.payload) {
                            this.showSignaturePad = false;
                        }

                    }
                });
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }


    get isURLNotBlank() {
        return (this.vfRoot && this.vfRoot != null && this.vfRoot != '');
    }

    get ckEditoriframeUrl() {
        return this.vfRoot + "/apex/OpportunityTable" + (this.documentTemplatesRecordId != null ? `?recordId=${this.documentTemplatesRecordId}` : "");
    }


    // Owner Name : Roshina Azmat
    // purpose : handle final preview
    handleFinalPreview() {
        this.callVFPage();
        this.finalPreview = true;
        this.disabledSaveAsButton = false;

    }
    // Owner Name : Roshina Azmat
    // purpose :  vf page for ck Editor
    callVFPage() {
        let vfWindow = this.template.querySelector("iframe").contentWindow;
        vfWindow.postMessage(this.message, this.vfRoot); //fire event
    }

    setEmptyValueCKEditor() {
        let vfWindow = this.template.querySelector("iframe").contentWindow;
        vfWindow.postMessage('CKEDIOR_EMPTY', this.vfRoot); //fire event
    }


    handleSelectAllChange(event) {

        this.selectAllChecked = event.target.checked;
        this.profiles = this.profiles.map(profile => {
            return { ...profile, HasReadPermission: this.selectAllChecked };
        });
        

        for (var i = 0; i < this.profiles.length; i++) {
            this.profileName = this.profiles[i].Name;
            this.allProfilesList = [...this.allProfilesList, this.profileName];
            console.log("this.allprofile list length ", this.allProfilesList);

            this.resultProfile = this.allProfilesList.join(', ');
        }
        

        if (this.selectAllChecked == false) {
            this.allProfilesList = "";
        }


        this.allProfilesList1 = this.allProfilesList;
        if (this.allProfilesList1.length > 0) {
            this.disableProfile = false;
        } else {
            this.disableProfile = true;
        }
        console.log("all profile list selecte all ", this.allProfilesList1);

    }


    @wire(getAllProfiles)
    wiredProfiles({ data, error }) {
        if (data) {
            this.profiles = data.map(profile => ({
                Id: profile.Id,
                Name: profile.Name,
                HasReadPermission: false,
            }));
            for (var i = 0; i < this.profiles.length; i++) {
                this.profileName = [...this.profileName, this.profiles[i].Name];
            }
            let array1 = [];
            console.log("profile final list is ", JSON.stringify(this.profiles));
            let array = [];
            this.profileName.forEach(currentItem => {
                currentItem.split(',');
                array.push(currentItem);
            });

        } else if (error) {
            console.error('Error retrieving profiles:', error);
        }
    }

    handleReadChange(event) {
        if (this.allProfilesList != null) {
            this.allProfilesList = "";
        }
        console.log("read change all profile lsit ", this.allProfilesList1);
        const profileId = event.target.dataset.profileId;
        const checked = event.target.checked;
        const permission = event.target.value;
        this.checkdValue = checked;
        const profileIndex = this.profiles.findIndex(profile => profile.Id === profileId);
        if (checked) {

            this.profiles[profileIndex].HasReadPermission = event.target.checked;
            for (var i = 0; i < this.profiles.length; i++) {
                if (profileId == this.profiles[i].Id && this.profiles[profileIndex].HasReadPermission) {
                    this.profileName = this.profiles[i].Name;
                    this.allProfilesList1 = [...this.allProfilesList1, this.profileName];
                    if (this.allProfilesList1.length > 0) {
                        this.disableProfile = false;
                    }

                }
            }
        } else {
            this.allProfilesList1 = this.allProfilesList1.filter(profile => profile.Id !== profileId);
            this.allProfilesList1.splice(this.allProfilesList1.indexOf(profileId), 1);
            console.log("all profile list deleted ", JSON.stringify(this.allProfilesList1));
            this.profiles[profileIndex].HasReadPermission = false;
            this.disableProfile = true;
        }


        this.resultProfile = this.allProfilesList1;
        this.resultProfile = this.removeDuplicates(this.resultProfile);
        console.log("resulr profile 555 ", JSON.stringify(this.resultProfile));
        this.resultProfile = this.resultProfile.join(",");
        this.selectedPermissions = [...this.selectedPermissions, permission];
        console.log("read change length ", this.resultProfile.length);


    }



    removeDuplicates(arr) {
        return arr.filter((item,
            index) => arr.indexOf(item) === index);
    }

    isSpinnerShow = false;
    selectedNoneHeaderFooter(event) {
        this.headerFooterNone = event.detail;
        console.log('this.none-------->', JSON.parse(JSON.stringify(this.headerFooterNone)));
        if (this.headerFooterNone.value == true) {
            this.headerConatinerCSS = null;
            this.attachmentBase64 = null;
            this.headerTextStyle = null;
            this.headerText = null;
            this.imgPosition = null;
            this.footerConatinerCSS = null;
            this.footerText = null;
            this.footerTextStyle = null;
        }
        this.disabledFinalPreviewButton = false;
    }
    saveWithoutHeaderFooter() {
        this.isLoaded = true;
        let saveData1 = {};
        let documentName = this.template.querySelector('.template-Name').value;
        if (documentName === '') {
            const event = new ShowToastEvent({
                message: 'Please Enter Template Name!',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;
        }
        let body = this.ckEditorData;
        saveData1['Name'] = documentName;
        saveData1['Object_Name__c'] = this.selectedObjectName;
        saveData1['IsActive__c'] = this.checkBoxValue;
        saveTemplateWithoutHeaderFooter({
            documentTemplateRecord: saveData1,
            body,
            profileData: JSON.stringify(this.resultProfile)
        }).then(result => {
            if (result == 'SUCCESS') {
                this.setEmptyValueCKEditor();
                this.disabledSaveButton = true;
                this.openSaveAsPopUp = false;
                this.navigateToObject();
                this.isLoaded = false;
                const event = new ShowToastEvent({
                    message: 'saved Successfully..!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }
        })
    }


    handleFileModal() {
        if (this.showFileUpload == true) {
            this.showFileUpload = false;
        } else {
            this.showFileUpload = true;
        }

    }

    handleTemplateSave() {
        if (this.documentTemplatesRecordId && this.newVersion == true) {
            if (this.headerFooterNone.value == true) {
                this.withHeaderFooter = false;
                this.saveWithoutHeaderFooter();
            } else {
                let documentName = this.template.querySelector('.template-Name').value;
                if (documentName === '') {
                    const event = new ShowToastEvent({
                        message: 'Please Enter Template Name!',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    return;
                }
                this.isLoaded = true;
                let headerBase64 = [...this._headerAndFooterBase64].filter(item => {
                    return item.id == 'header';
                });
                let footerBase64 = [...this._headerAndFooterBase64].filter(item => {
                    return item.id == 'footer';
                });

                let preHtml = "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'><head><meta charset='utf-8'><title>Doc</title></head><body>";
                let htmlContant = `${preHtml}<div><img src="${headerBase64[0].base64}" ></div>
            <div>${this.ckEditorData}</div> 
            <div>
                <img src="${footerBase64[0].base64}">
            </div>
            ${postHtml}`;
                let footer = footerBase64[0].html;
                let header = headerBase64[0].base64.split(',')[1];
                let pdfBody = this.ckEditorData;
                updateTemplate({
                    recordId: this.documentTemplatesRecordId,
                    documentName,
                    objectName: this.selectedObjectName,
                    isActive: this.checkBoxValue,
                    body: htmlContant,
                    footer,
                    profileData: JSON.stringify(this.resultProfile),
                    DocumentStoreAttachementHeader: header,
                    pdfBody
                }).then(result => {
                    if (result == 'SUCCESS') {
                        this.isLoaded = false;
                        this.setEmptyValueCKEditor();
                        this.disabledSaveAsButton = true;
                        this.openSaveAsPopUp = false;
                        this.navigateToObject();

                        const event = new ShowToastEvent({
                            message: 'New Version Created  Successfully!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);

                    }

                }).catch(error => {
                    console.log('update-->', error);
                })

            }

        } else {

            console.log('this.none', JSON.parse(JSON.stringify(this.headerFooterNone)));
            if (this.headerFooterNone.value == true) {

                this.saveWithoutHeaderFooter();
            } else {
                this.handleObjectSave();

            }
        }
        this.isSpinnerShow = false;
    }
    handleObjectSave() {
        console.log('with header footer');
        let saveData1 = {};
        this.isLoaded = true;
        let documentName = this.template.querySelector('.template-Name').value;
        console.log('with header footer', documentName);
        if (documentName === '') {
            const event = new ShowToastEvent({
                message: 'Please Enter Template Name!',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        } else if (documentName != '') {
            this.isLoaded = true;
            console.log('with name  footer');
        }
        console.log('with header footer');

        let headerBase64 = [...this._headerAndFooterBase64].filter(item => {
            return item.id == 'header';
        });
        let footerBase64 = [...this._headerAndFooterBase64].filter(item => {
            return item.id == 'footer';
        });
        console.log('footerBase64', footerBase64);
        console.log('headerBase64', headerBase64);



        let preHtml = "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'><head><meta charset='utf-8'><title>Doc</title></head><body>";

        let postHtml = "</body></html>";
        let htmlContant = `${preHtml}<div><img src="${headerBase64[0].base64}" ></div>
         <div>${this.ckEditorData}</div> 
         <div>
            <img src="${footerBase64[0].base64}">
         </div>
         ${postHtml}`;

        saveData1['Name'] = documentName;
        saveData1['Object_Name__c'] = this.selectedObjectName;
        saveData1['IsActive__c'] = this.checkBoxValue;
        console.log('htmlContant', htmlContant);

        let footer = footerBase64[0].html;
        let header = headerBase64[0].base64.split(',')[1];
        let pdfBody = this.ckEditorData;
        temSaveDataForPDF({ body: htmlContant, profileData: JSON.stringify(this.resultProfile), documentTemplateRecord: saveData1, footer, DocumentStoreAttachementHeader: header, pdfBody })
            .then(result => {
                this.setEmptyValueCKEditor();
                this.disabledSaveButton = true;
                this.openSaveAsPopUp = false;
                this.navigateToObject();
                const event = new ShowToastEvent({
                    message: 'saved Successfully..!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);

            })
            .catch(error => {
                console.log('saving-->', error);
            });

        this.isSpinnerShow = false;
    }
    navigateToObject() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Document_Template__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    handlSaveAs() {
        console.log("all profile list length save ");
        if (this.allProfilesList1.length < 1) {
            const event = new ShowToastEvent({
                message: 'Please Select Profile',
                variant: 'Warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        else {
            this.newVersion = true;
            this.openSaveAsPopUp = true;
            this.saveAsButtonVisible = true;
            this.isShowNewTemplateHeading = false;;
            this.isShowSaveAsHeading = true;
            this.handleSelectedObject();
        }


    }
    handleSelectedObject() {
        var objectNameOptionsSet = new Set();
        let data = JSON.parse(JSON.stringify(this.objectOptions));
        for (let i = 0; i < data.length; i++) {
            if (data[i] == 'OpportunityLineItem' || data[i] == 'Contact' || data[i] == 'Opportunity' || data[i] == 'Contract' || data[i] == 'Account' || data[i] == 'Order') {
                objectNameOptionsSet.add(data[i]);

            }
        }
        objectNameOptionsSet.forEach(items => {
            this.objectNameOptions.push({
                label: items,
                value: items
            });
        });
    }

    handleChangeObjectNameForEdit(event) {
        this.ObjectNameOnEditTime = event.target.value;
    }
    isTemplateVisible
    closeSaveAsPopUp() {
        this.openSaveAsPopUp = false;
    }
    handleNewVersion() {
        this.isTemplateVisible = true;
        this.saveAsTemplate = true;
        this.newVersion = true;
        this.newTemplate = false;
    }
    handleNewTemplate() {
        this.isTemplateVisible = true;
        this.saveAsTemplate = true;
        this.newVersion = false;
        this.newTemplate = true;
    }



    //----------------------------------------VF PAGE EDIT--------------------



    togglePanel() {
        let leftPanel = this.template.querySelector("div[data-my-id=leftPanel]");
        let rightPanel = this.template.querySelector("div[data-my-id=rightPanel]");

        if (leftPanel.classList.contains('slds-is-open')) {
            leftPanel.classList.remove("slds-is-open");
            leftPanel.classList.remove("open-panel");
            leftPanel.classList.add("slds-is-closed");
            leftPanel.classList.add("close-panel");
            rightPanel.classList.add("expand-panel");
            rightPanel.classList.remove("collapse-panel");
        } else {
            leftPanel.classList.add("slds-is-open");
            leftPanel.classList.add("open-panel");
            leftPanel.classList.remove("slds-is-closed");
            leftPanel.classList.remove("close-panel");
            rightPanel.classList.remove("expand-panel");
            rightPanel.classList.add("collapse-panel");
        }
    }
    handleSignatureModal() {
        this.showSignaturePad = !this.showSignaturePad;
    }
    handleHeaderAndFooter() {
        console.log('headerFooterConfig', this.headerFooterConfig);
        if (this.headerFooterConfig == true) {
            this.headerFooterConfig = false;
        } else {
            this.headerFooterConfig = true;
        }
        this.showFileUpload = false;
        this.isShowMergeFields = false;
        this.showSignaturePad = false;
        this.isKeywordOpen = false;
    }

    handleChange(event) {
        this.myVal = event.target.value;
    }

    handleKeywordTemplate() {
        if (this.isKeywordOpen == true) {
            this.isKeywordOpen = false;
        } else {
            this.isKeywordOpen = true;
        }

        this.headerFooterConfig = false;
        this.showFileUpload = false;
        this.isShowMergeFields = false;
        this.showSignaturePad = false;

    }

    getSignComdisabledSaveButtononent(event) {
        this.headerFooterConfig = false;
        this.isShowMergeFields = false;
    }

    getShowMergeFields(event) {
        if (this.isShowMergeFields == true) {
            this.isShowMergeFields = false;
        } else {
            this.isShowMergeFields = true;
        }
        this.showFileUpload = false;
        this.headerFooterConfig = false;
        this.showSignaturePad = false;
        this.isModalOdisabledSaveButtonen = true;
        this.isKeywordOpen = false;
    }

    getShowAddress(event) {
        this.isShowMergeFields = false;
        this.headerFooterConfig = false;
    }

    divElementvalue;
    imageShow = false;
    headerDivHtml;
    footerDivHtml;

    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
        this.checkdValue = "";
    }

    selectedValueBox = '';
    _getSelectedData = {};
    footerText;
    footerText
    imgPosition;
    footerConatinerCSS;
    headerConatinerCSS;
    footerTextStyle;
    headerTextStyle;

    // Owner Name : Roshina Azmat
    // purpose :  vf page
    message = "";
    messageFromVF;
    ckEditorData;
    @track plainCkEditorData;

    // purpose :  headerFooter
    attachmentBase64;
    _headerAndFooterBase64;
    showRadio;
    finalPreview = false;





    handleSelect(event) {
        const selected = event.detail.name;
        this.selectedNav = selected;
    }


    handlePermissionModal(event) {
        this.isShowModal = true;

        this.isKeywordOpen = false;
        this.showSignaturePad = false;
        this.headerFooterConfig = false;
        this.showFileUpload = false;
        this.isShowMergeFields = false;

        if (this.isShowMergeFields == true) {
            console.log("yes merze true ");
            this.isShowMergeFields = true;
        }
        else if (this.headerFooterConfig == true) {
            console.log("yes header true ");
            this.headerFooterConfig = true;
        }
        else if (this.showFileUpload == true) {
            console.log("yes file true ");
            this.showFileUpload = true;
        }
        else if (this.showSignaturePad == true) {
            console.log("yes sign true ");
            this.showSignaturePad = true;
        }
        else if (this.isKeywordOpen) {
            this.isKeywordOpen = true;
        }
        else {
            console.log("else part");
        }


    }

    handleConfigName(event) {
        this.selectedHeaderFooterConfigName = event.detail.name;
    }



    pageNumberFormat;
    disabledFinalPreviewButton = true;
    // Owner Name : Roshina Azmat
    // purpose :  for getting header footer record from child component
    handleHeaderAndFooterEvent(event) {
        try {
            this._headerAndFooterBase64 = event.detail.mainConfig;
            this._getSelectedData = event.detail.config;

            this.disabledFinalPreviewButton = false;
            let data = JSON.parse(JSON.stringify(this._getSelectedData));

            let headerRecord = data.filter(item => {
                return item.record.RecordType.Name == 'Document Header';
            });
            let footerRecord = data.filter(item => {
                return item.record.RecordType.Name == 'Document footer';
            });

            let base64 = (headerRecord.length > 0) ? headerRecord[0].attachmentBase64 : "";
            headerRecord = (headerRecord.length > 0) ? headerRecord[0].record : headerRecord;
            footerRecord = (footerRecord.length > 0) ? footerRecord[0].record : footerRecord;

            this.attachmentBase64 = 'data:image/png;base64,' + base64;

            this.headerText = headerRecord.Header_Text__c;
            this.footerText = footerRecord.Footer_Text__c;
            this.pageNumberFormat = footerRecord.Page_Number_Formate__c;

            //common for header and footer
            let fontStyle = headerRecord.Font_Family__c;
            let fontSize = headerRecord.Font_Size__c;

            let headerBorderColor = headerRecord.Header_Border_Color__c;
            let headerTextColor = headerRecord.Header_Text_Color__c;
            let headerTextPosition = headerRecord.Header_Text_Position__c;
            let horizontalMargin = headerRecord.Horizontal_Margin__c;
            //  let logoPosition = data.Logo_Position__c;
            let verticalMargin = headerRecord.Vertical_Margin__c;
            let isHeaderBorderApply = headerRecord.is_Header_Border_Apply__c;

            let logoHeight = headerRecord.Logo_Height__c;
            let logoPosition = headerRecord.Logo_Position__c;
            let logoWidth = headerRecord.Logo_Width__c;


            this.imgPosition = `width: ${logoWidth};
            height: ${logoHeight};
            background-size: contain;
            background-size: 100% 100%;
            background-size: contain;
            background-repeat: no-repeat;
            background-position : ${logoPosition};`;

            let headerBorder;
            if (isHeaderBorderApply == true && headerBorderColor != '') {
                headerBorder = `1px solid`;

            }

            this.headerConatinerCSS = `display: flex;
        border: ${headerBorder} ${headerBorderColor};
        flex-direction: ${logoPosition == 'left' ? 'row' : 'row-reverse'};
        width: initial;
        justify-content: flex-start;
        align-items: center;`;

            this.headerTextStyle = `font-family: ${fontStyle};
                            font-size: ${fontSize}; 
                            color : ${headerTextColor};
                            text-align  : ${headerTextPosition};
                            margin-left: ${horizontalMargin};
                            margin-right: ${horizontalMargin};
                            margin-top: ${verticalMargin};
                            margin-bottom: ${verticalMargin};`;


            //for footer
            let footerfontStyle = footerRecord.Font_Family__c;
            let footerfontSize = footerRecord.Font_Size__c;
            let footerTextColor = footerRecord.Footer_Text_Color__c;
            let footerTextPosition = footerRecord.Footer_Text_Position__c;
            let footerHorizontalMargin = footerRecord.Horizontal_Margin__c;
            let footerVerticalMargin = footerRecord.Vertical_Margin__c;
            let footerBorderApply = footerRecord.is_Footer_Border_Apply__c;


            let footerBorder;
            if (footerBorderApply == true) {
                footerBorder = `1px solid`;

            }

            this.footerConatinerCSS = `display: flex;
                border: ${footerBorder};
                width: initial;
                justify-content: flex-start;
                align-items: center;`;



            this.footerTextStyle = `font-family: ${footerfontStyle};
                            font-size: ${footerfontSize}; 
                            color : ${footerTextColor};
                            text-align : ${footerTextPosition};
                            margin-left: ${footerHorizontalMargin};
                            margin-right: ${footerHorizontalMargin};
                            margin-top: ${footerVerticalMargin};
                            margin-bottom: ${footerVerticalMargin};`;


        } catch (error) {
        }
    }

    // Owner Name : Roshina Azmat
    // purpose : getting all Object
    @wire(getObjectNames)
    wiredObjectNames({ error, data }) {
        if (data) {
            this.objectOptions = data;
            var tempData = data;

        } else if (error) {

        }
    }
    saveAsButtonVisible = false;
    // Owner Name : Roshina Azmat modified by karishma
    // purpose :  getting selected Object 
    saveDocTemplateRecords(event) {
        console.log("click on next");
        this.isTemplateVisible = true
        console.log("resut profile length ", this.allProfilesList1.length);
        if (this.allProfilesList1.length < 1) {
            const event = new ShowToastEvent({
                message: 'Please Select Profile',
                variant: 'Warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        else {
            console.log("click on next else part");
            this.isShowModal = false;
            this.isShowNewTemplateHeading = true;
            this.isShowSaveAsHeading = false;
            this.isLoaded = false;
            this.objectNameOptions = [];
            this.callVFPage();
            this.imageShow = true;
            this.openSaveAsPopUp = true;
            this.saveAsTemplate = true;
            this.saveAsButtonVisible = false;
            this.newTemplate = true;
            this.newVersion = false;
            var objectNameOptionsSet = new Set();

            let data = JSON.parse(JSON.stringify(this.objectOptions));
            for (let i = 0; i < data.length; i++) {
                if (data[i] == 'OpportunityLineItem' || data[i] == 'Contact' || data[i] == 'Opportunity' || data[i] == 'Contract' || data[i] == 'Account' || data[i] == 'Order') {
                    objectNameOptionsSet.add(data[i]);

                }
            }
            objectNameOptionsSet.forEach(items => {
                this.objectNameOptions.push({
                    label: items,
                    value: items
                });
            });
        }
    }
    objectNameOptions = [];
    isLoaded = false;
    checkBoxValue = false;

    // Owner Name : Roshina Azmat
    // purpose : preview header and footer 
    handlePreviewSave() {
        if (this.headerFooterNone.value == true) {
            this.finalPreview = false;
            this.disabledSaveButton = false;
        } else {
            this.headerDivHtml = this.template.querySelector('.header').innerHTML;
            this.footerDivHtml = this.template.querySelector('.footer').innerHTML;
            this.finalPreview = false;
            this.disabledSaveButton = false;
        }

    }

    handleChildData(event) {
        const dataFromChild = event.detail.dataToSend;
        this.profileFromParent = dataFromChild;
        if (this.profileFromParent != null) {
            this.dataToSendAgain = this.profileFromParent;
        }
    }

    handleChildDataOkButton(event) {
        this.isShowModal = false;
    }

    // Owner Name : Roshina Azmat
    // purpose : getting checkBox value
    handleCheckBox(event) {
        this.checkBoxValue = event.target.checked;
    }

    handleIconRemove(event) {
        const divElement = this.template.querySelector('.removeDiv');
        divElement.remove();
    }

    hideModel() {
        this.finalPreview = false;
    }

    handleObjectName(event) {
        this.ObjectNameValue = event.target.value;
        let dataInput = this.template.querySelector('lightning-input');
        this.saveButton = true;
    }
    cancelOpenGetObjectNamePopUp() {
        this.openGetObjectNamePopUp = false;

    }

    downloadTextFile() {
        const divElement = this.template.querySelector('.word');
        const textContent = this.myVal;
        const downloadLink = document.createElement('a');
        downloadLink.href = `data:text/plain;charset=utf-8,${encodeURIComponent(textContent)}`;
        downloadLink.download = 'document.txt';
    }
    handleSubscribe() {
        this.subscription = subscribe(this.messageContext, objectName, (message) => {
            this.selObjName = message.selObjName;

        });

    }

    userSignature = '{{{User_Signature}}}';
    copyTextToClipboard() {
        const textToCopy = this.userSignature;
        const textarea = document.createElement('textarea');
        textarea.value = textToCopy;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);

        this.showToast('Success', 'Text copied to clipboard!', 'success');
    }

    cancelCopy() {
        this.showSignaturePad = false;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    //Ravi Code here 
    //MAMMOTH_JS Liabrary Used for Generate Html

    mammothJsInitialized = false;
    modifiedHtml = '';
    async initializeMammothJs() {
        if (this.mammothJsInitialized) {
            return;
        }

        try {
            await loadScript(this, MAMMOTH_JS);
            this.mammothJsInitialized = true;
        } catch (error) {
            console.error('Error loading Mammoth.js:', error);
        }
    }

    async handleFileChange(event) {
        this.handleFileChange = true;
        const fileInput = event.target;
        if (fileInput.files.length > 0) {
            //alert(this.showSpinner2);
            this.showSpinner2 = true;
            await this.initializeMammothJs();
            const reader = new FileReader();
            reader.onload = async () => {
                try {
                    const fileName = fileInput.files[0].name.toLowerCase();
                    this.showFileName = fileName;

                    let html = '';
                    if (fileName.endsWith('.docx')) {
                        if (window.mammoth && typeof window.mammoth.convertToHtml === 'function') {
                            const result = await window.mammoth.convertToHtml({ arrayBuffer: reader.result });
                            html = result.value;
                        } else {
                            throw new Error('Mammoth.js is not loaded or does not provide the convertToHtml function.');
                        }
                    } else if (fileName.endsWith('.doc')) {
                        alert('You can\'t upload DOC files directly. Please upload DOCX files.');
                        // Handle the case when a DOC file is uploaded
                    } else {
                        alert('Please upload DOCX files.');
                        // Handle other unsupported file formats or provide feedback to the user
                    }

                    // Add table border styles to the generated HTML
                    html = html.replace(/<table/g, '<table style="border-collapse: collapse; width: 100%;"');
                    html = html.replace(/<th/g, '<th style="border: 1px solid #000; padding: 8px;"');
                    html = html.replace(/<td/g, '<td style="border: 1px solid #000; padding: 8px;"');

                    // Set the modified HTML content to display in the component
                    this.modifiedHtml = html;
                    this.displayFileContent2();
                } catch (error) {
                    this.showSpinner2 = false;
                    const toastEvent = new ShowToastEvent({
                        title: 'Error!',
                        message: `Please upload again : ${error}`,
                        variant: 'Error',
                    });
                    this.dispatchEvent(toastEvent);
                }
            };
            reader.readAsArrayBuffer(fileInput.files[0]);
        } else {
        }

    }
    displayFileContent2() {
        this.iframeIsVsbl = false;
        //this.modifiedHtml = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta http-equiv="Content-Style-Type" content="text/css" /><meta name="generator" content="Aspose.Words for .NET 23.9.0" /><title></title><style type="text/css">body { line-height:108%; font-family:Rockwell; font-size:11pt }h1, h2, h3, h4, h5, h6, p { margin:0pt }li, table { margin-top:0pt; margin-bottom:0pt }h1 { margin-top:3pt; margin-bottom:2pt; text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family: Gothic Demi; font-size:25pt; font-weight:normal; text-transform:uppercase; color:#000000 }h2 { text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family: Gothic Demi; font-size:11pt; font-weight:normal; text-transform:uppercase; color:#000000 }h3 { page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:16pt; font-weight:normal; text-transform:uppercase; color:#000000 }h4 { margin-top:10pt; page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:11pt; font-weight:normal; font-style:normal; text-transform:uppercase; color:#000000 }h5 { margin-top:2pt; page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:11pt; font-weight:normal; color:#d01818 }h6 { margin-top:2pt; page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:11pt; font-weight:normal; color:#8a1010 }.Heading7 { margin-top:2pt; page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:11pt; font-weight:normal; font-style:italic; color:#8a1010; -aw-style-name:heading7 }.Heading8 { margin-top:2pt; page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:11pt;';
        //this.modifiedHtml += 'font-weight:normal; color:#272727; -aw-style-name:heading8 }.Heading9 { margin-top:2pt; page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:11pt; font-weight:normal; font-style:italic; color:#272727; -aw-style-name:heading9 }.BalloonText { line-height:normal; font-family:Segoe UI; font-size:11pt }.Bibliography { line-height:108%; font-size:11pt }.BlockText { margin-right:57.6pt; margin-left:57.6pt; line-height:108%; border:0.75pt solid #ea4e4e; padding:10pt; font-size:11pt; font-style:italic; color:#d01818; -aw-border:0.25pt single }.BodyText { margin-bottom:6pt; line-height:108%; font-size:11pt }.BodyText2 { margin-bottom:6pt; line-height:200%; font-size:11pt }.BodyText3 { margin-bottom:6pt; line-height:108%; font-size:11pt }.BodyTextFirstIndent { margin-bottom:0pt; text-indent:18pt; line-height:108%; font-size:11pt }.BodyTextFirstIndent2 { margin-left:18pt; margin-bottom:0pt; text-indent:18pt; line-height:108%; font-size:11pt }.BodyTextIndent { margin-left:18pt; margin-bottom:6pt; line-height:108%; font-size:11pt }.BodyTextIndent2 { margin-left:18pt; margin-bottom:6pt; line-height:200%; font-size:11pt }.BodyTextIndent3 { margin-left:18pt; margin-bottom:6pt; line-height:108%; font-size:11pt }.Caption { margin-bottom:10pt; line-height:normal; font-size:11pt; font-style:italic; color:#44546a }.Closing { margin-left:216pt; line-height:normal; font-size:11pt }.CommentSubject { line-height:normal; font-size:11pt; font-weight:bold }.CommentText { line-height:normal; font-size:11pt }.Date { line-height:108%; font-size:11pt }.DocumentMap { line-height:normal; font-family:Segoe UI; font-size:11pt }.E-mailSignature { line-height:normal; font-size:11pt }.EndnoteText { line-height:normal; font-size:11pt }.EnvelopeAddress { margin-left:144pt; line-height:normal; font-family: Gothic Demi; font-size:12pt }.EnvelopeReturn { line-height:normal; font-family: Gothic Demi; font-size:11pt }.Footer { text-align:center; line-height:normal; font-family: Gothic Demi; font-size:11pt;';
        //this.modifiedHtml += 'text-transform:uppercase }.FootnoteText { line-height:normal; font-size:11pt }.HTMLAddress { line-height:normal; font-size:11pt; font-style:italic }.HTMLPreformatted { line-height:normal; font-family:Consolas; font-size:11pt }.Header { line-height:normal; font-size:11pt }.Index1 { margin-left:11pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index2 { margin-left:22pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index3 { margin-left:33pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index4 { margin-left:44pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index5 { margin-left:55pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index6 { margin-left:66pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index7 { margin-left:77pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index8 { margin-left:88pt; text-indent:-11pt; line-height:normal; font-size:11pt }.Index9 { margin-left:99pt; text-indent:-11pt; line-height:normal; font-size:11pt }.IndexHeading { line-height:108%; font-family: Gothic Demi; font-size:11pt; font-weight:bold }.Initials { text-align:center; line-height:normal; font-family: Gothic Demi; font-size:55pt; text-transform:uppercase; color:#ea4e4e }.IntenseQuote { margin:18pt 43.2pt; text-align:center; line-height:108%; border-top:0.75pt solid #ea4e4e; border-bottom:0.75pt solid #ea4e4e; padding-top:10pt; padding-bottom:10pt; font-size:11pt; font-style:italic; color:#d01818; -aw-border-bottom:0.5pt single; -aw-border-top:0.5pt single }.List { margin-left:18pt; text-indent:-18pt; line-height:108%; font-size:11pt }.List2 { margin-left:36pt; text-indent:-18pt; line-height:108%; font-size:11pt }.List3 { margin-left:54pt; text-indent:-18pt; line-height:108%; font-size:11pt }.List4 { margin-left:72pt; text-indent:-18pt; line-height:108%; font-size:11pt }.List5 { margin-left:90pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListBullet { margin-left:18pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListBullet2 { margin-left:36pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListBullet3 { margin-left:54pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListBullet4 { margin-left:72pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListBullet5 { margin-left:90pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListContinue { margin-left:18pt; margin-bottom:6pt; line-height:108%; font-size:11pt }.ListContinue2 { margin-left:36pt; margin-bottom:6pt; line-height:108%; font-size:11pt }.ListContinue3 { margin-left:54pt; margin-bottom:6pt; line-height:108%; font-size:11pt }.ListContinue4 { margin-left:72pt; margin-bottom:6pt; line-height:108%; font-size:11pt }.ListContinue5 { margin-left:90pt; margin-bottom:6pt; line-height:108%; font-size:11pt }.ListNumber { margin-left:18pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListNumber2 { margin-left:36pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListNumber3 { margin-left:54pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListNumber4 { margin-left:72pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListNumber5 { margin-left:90pt; text-indent:-18pt; line-height:108%; font-size:11pt }.ListParagraph { margin-left:36pt; line-height:108%; font-size:11pt }.Macro { line-height:108%; font-family:Consolas; font-size:11pt }.MessageHeader { margin-left:54pt; text-indent:-54pt; line-height:normal; border:0.75pt solid #000000; padding:1pt; font-family: Gothic Demi; font-size:12pt; background-color:#cccccc }.NoSpacing { line-height:normal; font-size:11pt }.NormalWeb { line-height:108%; font-family:Times New Roman; font-size:12pt }.NormalIndent { margin-left:36pt; line-height:108%;';
        //this.modifiedHtml += 'font-size:11pt }.NoteHeading { line-height:normal; font-size:11pt }.PlainText { line-height:normal; font-family:Consolas; font-size:11pt }.Quote { margin:10pt 43.2pt 8pt; text-align:center; line-height:108%; font-size:11pt; font-style:italic; color:#404040 }.Salutation { line-height:108%; font-size:11pt }.Signature { margin-left:216pt; line-height:normal; font-size:11pt }.Subtitle { margin-bottom:8pt; line-height:108%; font-size:11pt; color:#5a5a5a }.TOAHeading { margin-top:6pt; line-height:108%; font-family: Gothic Demi; font-size:12pt; font-weight:bold }.TOC1 { margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC2 { margin-left:11pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC3 { margin-left:22pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC4 { margin-left:33pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC5 { margin-left:44pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC6 { margin-left:55pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC7 { margin-left:66pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC8 { margin-left:77pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOC9 { margin-left:88pt; margin-bottom:5pt; line-height:108%; font-size:11pt }.TOCHeading { margin-top:12pt; margin-bottom:0pt; text-align:left; page-break-inside:avoid; page-break-after:avoid; line-height:108%; font-family: Gothic Demi; font-size:16pt; text-transform:none; color:#d01818 }.TableofAuthorities { margin-left:11pt; text-indent:-11pt; line-height:108%; font-size:11pt }.TableofFigures { line-height:108%; font-size:11pt }.Title { line-height:normal; font-family: Gothic Demi; font-size:28pt }span.BalloonTextChar { font-family:Segoe UI }span.BookTitle { font-weight:bold; font-style:italic; letter-spacing:0.25pt }span.CommentReference { font-size:11pt }span.CommentSubjectChar { font-weight:bold }span.DocumentMapChar { font-family:Segoe UI }span.Emphasis { font-style:italic; -aw-style-name:emphasis }span.EndnoteReference { vertical-align:super }span.FollowedHyperlink { text-decoration:underline; color:#954f72 }span.FooterChar { font-family: Gothic Demi; text-transform:uppercase }span.FootnoteReference { vertical-align:super }span.HTMLAddressChar { font-style:italic }span.HTMLCite { font-style:italic }span.HTMLCode { font-family:Consolas; font-size:11pt }span.HTMLDefinition { font-style:italic }span.HTMLKeyboard { font-family:Consolas; font-size:11pt }span.HTMLPreformattedChar { font-family:Consolas }span.HTMLSample { font-family:Consolas; font-size:12pt }span.HTMLTypewriter { font-family:Consolas; font-size:11pt }span.HTMLVariable { font-style:italic }span.Heading1Char { font-family: Gothic Demi; font-size:25pt; text-transform:uppercase; color:#000000 }span.Heading2Char { font-family: Gothic Demi; text-transform:uppercase; color:#000000 }span.Heading3Char {';
        //this.modifiedHtml += ' font-family: Gothic Demi; font-size:16pt; text-transform:uppercase }span.Heading4Char { font-family: Gothic Demi; text-transform:uppercase }span.Heading5Char { font-family: Gothic Demi; color:#d01818 }span.Heading6Char { font-family: Gothic Demi; color:#8a1010 }span.Heading7Char { font-family: Gothic Demi; font-style:italic; color:#8a1010 }span.Heading8Char { font-family: Gothic Demi; color:#272727 }span.Heading9Char { font-family: Gothic Demi; font-style:italic; color:#272727 }span.Hyperlink { text-decoration:underline; color:#0563c1; -aw-style-name:hyperlink }span.IntenseEmphasis { font-style:italic; color:#d01818 }span.IntenseQuoteChar { font-style:italic; color:#d01818 }span.IntenseReference { font-weight:bold; font-variant:small-caps; text-transform:none; letter-spacing:0.25pt; color:#d01818 }span.MacroTextChar { font-family:Consolas }span.MessageHeaderChar { font-family: Gothic Demi; font-size:12pt; background-color:#cccccc }span.PlaceholderText { color:#595959 }span.PlainTextChar { font-family:Consolas }span.QuoteChar { font-style:italic; color:#404040 }span.Strong { font-weight:bold; -aw-style-name:strong }span.SubtitleChar { font-size:11pt; color:#5a5a5a }span.SubtleEmphasis { font-style:italic; color:#404040 }span.SubtleReference { font-variant:small-caps; color:#5a5a5a }span.TitleChar { font-family: Gothic Demi; font-size:28pt }.ColorfulGrid {  }.ColorfulGridAccent1 {  }.ColorfulGridAccent2 {  }.ColorfulGridAccent3 {  }.ColorfulGridAccent4 {  }.ColorfulGridAccent5 {  }.ColorfulGridAccent6 {  }.ColorfulList {  }.ColorfulListAccent1 {  }.ColorfulListAccent2 {  }.ColorfulListAccent3 {  }.ColorfulListAccent4 {  }.ColorfulListAccent5 {  }.ColorfulListAccent6 {  }.ColorfulShading {  }.ColorfulShadingAccent1 {  }.ColorfulShadingAccent2 {  }.ColorfulShadingAccent3 {  }.ColorfulShadingAccent4 {  }.ColorfulShadingAccent5 {  }.ColorfulShadingAccent6 {  }.DarkList {  }.DarkListAccent1 {  }.DarkListAccent2 {  }.DarkListAccent3 {  }.DarkListAccent4 {  }.DarkListAccent5 {  }.DarkListAccent6 {  }.GridTable1Light {  }.GridTable1LightAccent1 {  }.GridTable1LightAccent2 {  }.GridTable1LightAccent3 {  }.GridTable1LightAccent4 {  }.GridTable1LightAccent5 {  }.GridTable1LightAccent6 {  }.GridTable2 {  }.GridTable2Accent1 {  }.GridTable2Accent2 {  }.GridTable2Accent3 {  }.GridTable2Accent4 {  }.GridTable2Accent5 {  }.GridTable2Accent6 {  }.GridTable3 {  }.GridTable3Accent1 {  }.GridTable3Accent2 {  }.GridTable3Accent3 {  }.GridTable3Accent4 {  }.GridTable3Accent5 {  }.GridTable3Accent6 {  }.GridTable4 {  }.GridTable4Accent1 {  }.GridTable4Accent2 {  }.GridTable4Accent3 {  }.GridTable4Accent4 {  }.GridTable4Accent5 {  }.GridTable4Accent6 {  }.GridTable5Dark {  }.GridTable5DarkAccent1 {  }.GridTable5DarkAccent2 {  }.GridTable5DarkAccent3 {  }.GridTable5DarkAccent4 {  }.GridTable5DarkAccent5 {  }.GridTable5DarkAccent6 {  }.GridTable6Colorful {  }.GridTable6ColorfulAccent1 {  }.GridTable6ColorfulAccent2 {  }.GridTable6ColorfulAccent3 {  }.GridTable6ColorfulAccent4 {  }.GridTable6ColorfulAccent5 {  }.GridTable6ColorfulAccent6 {  }.GridTable7Colorful {  }.GridTable7ColorfulAccent1 {  }.GridTable7ColorfulAccent2 {  }.GridTable7ColorfulAccent3 {  }.GridTable7ColorfulAccent4 {  }.GridTable7ColorfulAccent5 {  }.GridTable7ColorfulAccent6 {  }.GridTableLight {  }.LightGrid {  }.LightGridAccent1 {  }.LightGridAccent2 {  }.LightGridAccent3 {  }.LightGridAccent4 {  }.LightGridAccent5 {  }.LightGridAccent6 {  }.LightList {  }.LightListAccent1 {  }.LightListAccent2 {  }.LightListAccent3 {  }.LightListAccent4 {  }.LightListAccent5 {  }.LightListAccent6 {  }.LightShading {  }.LightShadingAccent1 {  }.LightShadingAccent2 {  }.LightShadingAccent3 {  }.LightShadingAccent4 {  }.LightShadingAccent5 {  }.LightShadingAccent6 {  }.ListTable1Light {  }.ListTable1LightAccent1 {  }.ListTable1LightAccent2 {  }.ListTable1LightAccent3 {  }.ListTable1LightAccent4 {  }.ListTable1LightAccent5 {  }.ListTable1LightAccent6 {  }.ListTable2 {  }.ListTable2Accent1 {  }.ListTable2Accent2 {  }.ListTable2Accent3 {  }.ListTable2Accent4 {  }.ListTable2Accent5 {  }.ListTable2Accent6 {  }.ListTable3 {  }.ListTable3Accent1 {  }.ListTable3Accent2 {  }.ListTable3Accent3 {  }.ListTable3Accent4 {  }.ListTable3Accent5 {  }.ListTable3Accent6 {  }.ListTable4 {  }.ListTable4Accent1 {  }.ListTable4Accent2 {  }.ListTable4Accent3 {  }.ListTable4Accent4 {  }.ListTable4Accent5 {  }.ListTable4Accent6 {  }.ListTable5Dark {  }.ListTable5DarkAccent1 {  }.ListTable5DarkAccent2 {  }.ListTable5DarkAccent3 {  }.ListTable5DarkAccent4 {  }.ListTable5DarkAccent5 {  }.ListTable5DarkAccent6 {  }.ListTable6Colorful {  }.ListTable6ColorfulAccent1 {  }.ListTable6ColorfulAccent2 {  }.ListTable6ColorfulAccent3 {  }.ListTable6ColorfulAccent4 {  }.ListTable6ColorfulAccent5 {  }.ListTable6ColorfulAccent6 {  }.ListTable7Colorful {  }.ListTable7ColorfulAccent1 {  }.ListTable7ColorfulAccent2 {  }.ListTable7ColorfulAccent3 {  }.ListTable7ColorfulAccent4 {  }.ListTable7ColorfulAccent5 {  }.ListTable7ColorfulAccent6 {  }.MediumGrid1 {  }.MediumGrid1Accent1 {  }.MediumGrid1Accent2 {  }.MediumGrid1Accent3 {  }.MediumGrid1Accent4 {  }.MediumGrid1Accent5 {  }.MediumGrid1Accent6 {  }.MediumGrid2 {  }.MediumGrid2Accent1 {  }.MediumGrid2Accent2 {  }.MediumGrid2Accent3 {  }.MediumGrid2Accent4 {  }.MediumGrid2Accent5 {  }.MediumGrid2Accent6 {  }.MediumGrid3 {  }.MediumGrid3Accent1 {  }.MediumGrid3Accent2 {  }.MediumGrid3Accent3 {  }.MediumGrid3Accent4 {  }.MediumGrid3Accent5 {  }.MediumGrid3Accent6 {  }.MediumList1 {  }.MediumList1Accent1 {  }.MediumList1Accent2 {  }.MediumList1Accent3 {  }.MediumList1Accent4 {  }.MediumList1Accent5 {  }.MediumList1Accent6 {  }.MediumList2 {  }.MediumList2Accent1 {  }.MediumList2Accent2 {  }.MediumList2Accent3 {  }.MediumList2Accent4 {  }.MediumList2Accent5 {  }.MediumList2Accent6 {  }.MediumShading1 {  }.MediumShading1Accent1 {  }.MediumShading1Accent2 {  }.MediumShading1Accent3 {  }.MediumShading1Accent4 {  }.MediumShading1Accent5 {  }.MediumShading1Accent6 {  }.MediumShading2 {  }.MediumShading2Accent1 {  }.MediumShading2Accent2 {  }.MediumShading2Accent3 {  }.MediumShading2Accent4 {  }.MediumShading2Accent5 {  }.MediumShading2Accent6 {  }.PlainTable1 {  }.PlainTable2 {  }.PlainTable3 {  }.PlainTable4 {  }.PlainTable5 {  }.Table3Deffects1 {  }.Table3Deffects2 {  }.Table3Deffects3 {  }.TableClassic1 {  }.TableClassic2 {  }.TableClassic3 {  }.TableClassic4 {  }.TableColorful1 {  }.TableColorful2 {  }.TableColorful3 {  }.TableColumns1 {  }.TableColumns2 {  }.TableColumns3 {  }.TableColumns4 {  }.TableColumns5 {  }.TableContemporary {  }.TableElegant {  }.TableGrid {  }.TableGrid1 {  }.TableGrid2 {  }.TableGrid3 {  }.TableGrid4 {  }.TableGrid5 {  }.TableGrid6 {  }.TableGrid7 {  }.TableGrid8 {  }.TableList1 {  }.TableList2 {  }.TableList3 {  }.TableList4 {  }.TableList5 {  }.TableList6 {  }.TableList7 {  }.TableList8 {  }.TableProfessional {  }.TableSimple1 {  }.TableSimple2 {  }.TableSimple3 {  }.TableSubtle1 {  }.TableSubtle2 {  }.TableTheme {  }.TableWeb1 {  }.TableWeb2 {  }.TableWeb3 {  }</style></head><body border="1"><div><p class="NoSpacing"><span style="height:0pt; display:block; position:absolute; z-index:-1"></span><span style="-aw-import:ignore">&#xa0;</span></p><table cellspacing="0" cellpadding="0" style="border-collapse:collapse"><tr style="height:12.95pt"><td colspan="2" style="width:153pt; vertical-align:middle"><p class="Initials"><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>CA</span></span><span> </span></p></td><td style="width:31.5pt; vertical-align:middle"><p class="NoSpacing" style="text-align:center"><span style="-aw-import:ignore">&#xa0;</span></p></td><td style="width:328.5pt; vertical-align:middle"><h1><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>Chela Arapelli</span></span></h1><h2><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>beauty blogger</span></span><span> | </span><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>www.interestingsite.com</span></span></h2></td><td style="width:12.6pt; vertical-align:middle"><p class="NoSpacing" style="text-align:right"><span style="-aw-import:ignore">&#xa0;</span></p></td></tr><tr style="height:0pt"><td style="width:131.4pt"></td><td style="width:21.6pt"></td><td style="width:31.5pt"></td><td style="width:328.5pt"></td><td style="width:12.6pt"></td></tr></table><p class="NoSpacing"><span style="-aw-import:ignore">&#xa0;</span></p></div><hr/></body></html>';
        uploadDocument({ documentStoreId: this.modifiedHtml })
            .then(result => {
                //alert(result);
                this.iframeIsVsbl = result;
                // Display a success toast message
                const toastEvent = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Document Successfully Uploaded',
                    variant: 'success',
                });
                this.dispatchEvent(toastEvent);
                this.showSpinner2 = false;
            })
            .catch(error => {
                console.error(error);
            });
    }
}