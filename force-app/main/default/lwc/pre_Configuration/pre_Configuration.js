import { LightningElement, track, api, wire } from 'lwc';
import getHeaderAndFooterData from '@salesforce/apex/pre_configurationController.getHeaderAndFooterData';
import { NavigationMixin } from 'lightning/navigation';
import updateConfigRecords from '@salesforce/apex/pre_configurationController.updateConfigRecords';
import getVFBaseURL from '@salesforce/apex/ProxyController.getVFBaseURL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modal from "@salesforce/resourceUrl/customModal";
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
import uploadLogo from '@salesforce/apex/headerAndFooterController.uploadLogo';
import deleteHeaderFooters from '@salesforce/apex/pre_configurationController.deleteHeaderFooters';
import getTemplateNames from '@salesforce/apex/headerAndFooterController.getTemplateNames';
import getAllStandardHeaders from '@salesforce/apex/pre_configurationController.getAllStandardHeaders';
import saveHeaderFooterTemplateConfig from '@salesforce/apex/headerAndFooterController.saveHeaderFooterTemplateConfig';

export default class Pre_Configuration extends NavigationMixin(LightningElement) {

    @api selectedConfigName;

    configRecords = [];
    _allRecordReference = {};
    openPreview = false;
    openPreConfig = false;
    isOpenModal = false;
    @track isLoaded = true;
    @track isModalOpen = false;

    @track checkedValue = false;
    @track selecteRadioButton = false;
    @track selecteRadioButtonValue;
    @track radio;
    @track isCancelled = false;
    isSpinner = false;
    @track standardHeaders;
    headerBorderColorBox = false;
    footerBorderColorBox = false;
    isApplyLogoVisvibleButton = false;
    editableVisible = false;




    //for dynamic css
    headerText;
    footerText;
    headerTextStyle;
    imgPosition;
    imageShow
    footerConatinerCSS;

    @track vfRoot;
    //vfRoot = "https://crmlandingsoftwareprivatelimited--dev2--c.sandbox.vf.force.com";

    //for default value set variables header footer
    horizontalMarginOptionsvalue = '0mm';
    verticalMarginOptionsvalue = '0mm';
    fontFamilyOptionsvalue = 'serif';
    fontSizeOptionsvalue = '10pt';
    defaultHeaderBorderColorValue = '#9A2B2B';
    defaultFooterTextColorValue = '#080808';
    defaultHeaderTextColorValue = '#080808';
    logoPositionOptionsValue = 'left';
    footerTextPositionOptionsValue = 'center';
    headerTextPositionOptionsValue = 'left';

    isSpinner = false;
    //for data saving variables    
    @track storeHeaderDataForSave = {};
    @track storeFooterDataForSave = {};
    @track isApplyLogo = false;
    @track isApplyHeaderBorder;
    @track isApplyFooterBorder;

    @track horizontalMargin;
    @track verticalMargin;
    @track fontStyle;
    @track fontSize;
    @track logoPosition;
    headerConatinerCSS;
    isApplyButtonVisible = true;

    //for files var
    @track recordId = 'a0j1y000000rPzzAAE';
    @track fileData;
    @track logoUrl;
    templates = [];
    isDisable = true;
    @track progressValue = "";


    //for css dynamic
    headerTextStyle;
    footerTextStyle;
    headerText;
    footerText;
    isOpenModal = false;
    imgPosition;
    footerConatinerCSS;
    isOpenStandardHeaderModal = false;

    defaultFooterText
    defaultHeaderText
    checkBoxValue = false;
    _selectedRecordTemporary = [];
    disableCheckBox = false;
    disabledLogoCancelButton = false;
    editableVisible = false;
    hideSaveButton = false;
    disabledLogoCheckbox = false;

    //end header footer

    connectedCallback() {
        //for header footer
        loadStyle(this, modal);
        this.vfPage();//don't remove this function becouse it's EventListener of vf page
        let templateArr = [];
        getTemplateNames().then(result => {
            for (let i = 0; i < result.length; i++) {
                templateArr.push(result[i].Template_Name__c);
            }
            this.templates = templateArr;
        }).catch(e => {
        });
        this.fetchHeaderFooterRecords();

    }
    @wire(getAllStandardHeaders)
    wiredData({ error, data }) {
        if (data) {

            this.standardHeaders = data;
            console.log('getAllStandardHeaders', this.standardHeaders);
            let options = [];
            data.forEach(currentItem => {
                let value = currentItem.Logo__c.split("src=")[1];
                //let final  = currentItem.Logo__c.split("alt=")[1]; 
                const final = value.replace('alt="start-logo.png"></img></p>', '');
                console.log('currentItem.Logo__c', currentItem.Logo__c);
                console.log('value', value);
                console.log('final', final);
                //options.push({currentItem})
            });
        } else if (error) {
            console.error('Error:', error);
        }
    }

    openStandardHeaderModal() {
        this.isOpenStandardHeaderModal = true;

    }
    isCancelStandardHeaderModal() {
        this.isOpenStandardHeaderModal = false;

    }

    get htmlHeaderFooterIframeUrl() {
        console.log('this.vfRoot----->', this.vfRoot)
        return this.vfRoot + "/apex/html2canvas";
    }

    vfPage() {
        getVFBaseURL().then(result => {
            this.vfRoot = result;
            window.addEventListener("message", (message) => {
                if (message.origin !== this.vfRoot) {
                    return;
                }

                if (message.data.name == "HTML_2_CANVAS_CONVERT_VF") {
                    const selectedEvent = new CustomEvent('selected', { detail: { config: this.selectData, mainConfig: message.data.payload, selectRadio: this.selecteRadioButtonValue } });
                    console.log("selected event ===========> ", selectedEvent);
                    this.dispatchEvent(selectedEvent);
                    this.isOpenModal = false;
                    this.showLoading = false;
                }
            });
        });
    }


    handleChildCancel(event) {

        console.log("child cancel button");
        this.isCancelled = true;
        if (this.isCancelled == true) {
            console.log("false model");
            this.isModalOpen = false;
        }
    }

    navigateToHeaderAndFooterPae() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'pre_config_header_footer' // Replace with your desired tab's API name
            }
        });
    }
    @track progressValue = 0;
    hanldeProgressValueChange(event) {
        this.progressValue = event.detail;
        if (this.progressValue == true) {
            this.selecteRadioButton = true;
            this.isModalOpen = false;
            if (this.selecteRadioButton == true) {
                this.connectedCallback();
            }
        }
    }



    fetchHeaderFooterRecords() {
        getHeaderAndFooterData().then(result => {
            this._allRecordReference = result;
            console.log('result', result);

            let data = JSON.parse(JSON.stringify(result));
            let records = [];
            Object.keys(data).forEach((key, ) => {
                records.push({ name: key, value: data[key], isChecked: (this.selectedConfigName == key) });
            });
            this.configRecords = JSON.parse(JSON.stringify(records));
            this.isLoaded = false;

        }).catch(error => {
            console.log('error', error.message);
        })

    }

    closeLogoPopUp() {

        this.template.querySelector('.is-apply-logo').checked = false;
        console.log('checkBoxValue----------------->', this.checkBoxValue);
        this.logoPopUp = false;
        this.editableVisible = false;
        this.disableCheckBox = false;
        // this.template.querySelector('.is-apply-logo').checked = false;

        this.fileData = [];
        console.log('file', this.fileData);
        this.logoSelectedIMG = '';
        this.imageShow = false;
        this.imageHideForPopUp = false;
        this.isApplyButtonVisible = true;
        this.logWidthDefaultValue = null;
        this.logHeightDefaultValue = null;
        this.logoPositionOptionsValue = null;
         
        let fields = this.template.querySelectorAll('.logo-fields');
        fields.forEach(currentItem => {
            currentItem.value = null;
            console.log(' currentItem.value', currentItem.value)
        });
        //for edit
        console.log('_selectedRecordTemporary', this._selectedRecordTemporary);
        if (this._selectedRecordTemporary) {
            console.log('enyter edit**********');
            //  this.imageHideForPopUp = true;
            this.logoSelectedIMG = this.attachmentBase64;
            //  this.checkBoxValue = true;

        }
    }
    headerRecordId;
    footerRecordId
    handleDelete(event) {
        console.log('delete');
        let selectedUID = event.currentTarget.dataset.id;
        let recordIds = [];
        let data = this._allRecordReference[selectedUID];
        data.forEach(currentItem => {
            recordIds.push(currentItem.record.Id);
        });
        deleteHeaderFooters({ recordIds }).then(result => {
            if (result != null && result == 'SUCCESS') {
                this.fetchHeaderFooterRecords();
                this.showNotification('Success', 'Header & Footer Configuration Delete successfully!', 'success');
                console.log('result---------->', result);
            }else{
               this.showNotification('error', 'Internal Error!', 'error'); 
            }
        })

        console.log('recordIds', recordIds);
    }
    handleEdit(event) {
        this.hideSaveButton = true;
        this.isModalOpen = true;
        this.checkBoxValue = true;
        let selectedUID = event.currentTarget.dataset.id;
        let data = this._allRecordReference[selectedUID];
        console.log('this.data', data);
        this.headerRecordId = data[0].record.Id;
        this.footerRecordId = data[1].record.Id;

        this._selectedRecordTemporary = data;
        let headerRecord = data.filter(item => {
            return item.record.RecordType.Name == 'Document Header';
        });

        let footerRecord = data.filter(item => {
            return item.record.RecordType.Name == 'Document footer';
        });

        let base64 = (headerRecord.length > 0) ? headerRecord[0].attachmentBase64 : "";
        headerRecord = (headerRecord.length > 0) ? headerRecord[0].record : headerRecord;
        footerRecord = (footerRecord.length > 0) ? footerRecord[0].record : footerRecord;

        console.log('headerRecord----------------->', headerRecord.Header_Text__c);

        if (base64) {
            this.attachmentBase64 = 'data:image/png;base64,' + base64;
            this.imageHideForPopUp = true;

        } else {
            this.attachmentBase64 = null;
            this.checkBoxValue = false;
            this.imageHideForPopUp = false;
            console.log('visibleAttachmentBase64', this.attachmentBase64);
        }





        //  imageHideForPopUp
        // this.logoSelectedIMG = base64;              
        console.log('headerRecord', headerRecord.Horizontal_Margin__c);
        this.horizontalMarginOptionsvalue = headerRecord.Horizontal_Margin__c;
        this.verticalMarginOptionsvalue = headerRecord.Vertical_Margin__c;
        this.fontFamilyOptionsvalue = headerRecord.Font_Family__c;
        this.fontSizeOptionsvalue = headerRecord.Font_Size__c;
        this.defaultFooterTextColorValue = footerRecord.Footer_Text_Color__c;
        this.defaultHeaderTextColorValue = headerRecord.Header_Text_Color__c;
        this.logoPositionOptionsValue = headerRecord.Logo_Position__c;
        this.footerTextPositionOptionsValue = footerRecord.Footer_Text_Position__c;
        this.headerTextPositionOptionsValue = headerRecord.Header_Text_Position__c;
        this.logWidthDefaultValue = headerRecord.Logo_Width__c;
        this.logHeightDefaultValue = headerRecord.Logo_Height__c;
        this.defaultHeaderText = headerRecord.Header_Text__c


        this.defaultFooterText = footerRecord.Footer_Text__c
        this.logoSelectedIMG = this.attachmentBase64;

        console.log('data', data);
    }
    handleUpdateHeaderFooter() {
        console.log('selectedHeaderFooterId', this.selectedHeaderFooterId);
        //let templateName = this.template.querySelector('.template-name').value;
        this.showLoading = true;
        let uId = 'Document-' + Math.random().toString(16).slice(2);

        try {
            let headerFieldData = {}, footerFieldData = {};


            [...this.template.querySelectorAll('.header-fields')].forEach(input => {
                headerFieldData[input.dataset.field] = input.value;
            });

            [...this.template.querySelectorAll('.footer-fields')].forEach(input => {
                footerFieldData[input.dataset.field] = input.value;
            });
            //Loop
            [...this.template.querySelectorAll('.common-fields')].forEach(input => {
                headerFieldData[input.dataset.field] = input.value;
                footerFieldData[input.dataset.field] = input.value;
            });

            // const existingTemplates = [...this.templates];
            // if (existingTemplates.includes(templateName)) {
            //     var errorShow = this.template.querySelector('.errorDuplicate');
            //     errorShow.innerHTML = 'Name already exists. Please choose a different name';
            //     errorShow.style = 'color:red;';
            //     this.showLoading = false;
            //     return;

            // }
            // else {

            //headerFieldData['Template_Name__c'] = templateName;
            //footerFieldData['Template_Name__c'] = templateName;

            headerFieldData['Id'] = this.headerRecordId;
            footerFieldData['Id'] = this.footerRecordId;

            console.log('this.headerRecordId', this.headerRecordId);
            console.log('this.footerRecordId', this.footerRecordId);

            headerFieldData['UId__c'] = uId;
            footerFieldData['UId__c'] = uId;

            headerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;
            footerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;

            headerFieldData['is_Header_Border_Apply__c'] = this.isApplyHeaderBorder;
            footerFieldData['is_Footer_Border_Apply__c'] = this.isApplyFooterBorder;


            headerFieldData['Logo_Height__c'] = this.logoFieldData.Logo_Height__c;
            headerFieldData['Logo_Position__c'] = this.logoFieldData.Logo_Position__c;
            headerFieldData['Logo_Width__c'] = this.logoFieldData.Logo_Width__c;

            console.log('headerFieldData', headerFieldData);
            console.log('footerFieldData', footerFieldData);
            console.log('this.fileData', this.fileData);
            let base64 = '';
            if (this.fileData) {
                console.log('file data available')
                // base64 = this.fileData;
                console.log('fileBase64', base64);
            }
            // } else {
            //       console.log('file data not available');
            //       if()
            //     base64 = this.attachmentBase64.split('base64,')[1];
            //     console.log('base641--->', base64);
            // }
            //file: { ...this.fileData }
              var tempFileData = { ...this.fileData };
               console.log('data: '+JSON.stringify(tempFileData));
               var tempFileDataString = JSON.stringify(tempFileData);
              
            updateConfigRecords({ headerData: headerFieldData, footerData: footerFieldData,  filedata: tempFileDataString}).then(result => {
                console.log('result*************', result);
                if (result == 'SUCCESS') {
                    this.showNotification('Success', 'Header & Footer Configuration Update successfully!', 'success');
                    this.isModalOpen = false;
                    this.showLoading = false;
                    this.isOpenNamePopUp = false;
                    this.fetchHeaderFooterRecords();
                }
            })



            return;


            // }
        } catch (e) {
            console.error('Error'.e);
        }
    }
    previouseBase64;
    handleNoneHeaderFooter(event) {
        this.noneHeaderFooter = event.target.checked;
        if (this.noneHeaderFooter) {
            let records = [];
            Object.keys(this._allRecordReference).forEach((key, ) => {
                records.push({ name: key, value: this._allRecordReference[key], isChecked: this.checkedValue });
            });
            let selectedUID = event.currentTarget.dataset.id;
            console.log("selectedUID @@@@@", selectedUID);

            for (let i = 0; i < records.length; i++) {
                if (records[i].name == selectedUID) {
                    records[i].isChecked = true;
                    console.log("records[i]", records[i]);
                    records[i].checked = false;
                    console.log(" update records [i] is ", records[i]);
                }
            }
            this.configRecords = records;

        }
        console.log('noneHeaderFooter', this.noneHeaderFooter);
        const eventToSend = new CustomEvent('blanckselectedheader', {
            detail: { value: this.noneHeaderFooter }
        });
        this.dispatchEvent(eventToSend);
    }
    visibleAttachmentBase64 = true;
    handlePreview(event) {
        this.noneHeaderFooter = false;
        this.isOpenModal = true;
        this.selecteRadioButtonValue = event.target.getAttribute('data-id');
        console.log("selected radio button value  #### ", this.selecteRadioButtonValue);

        const eventToSend = new CustomEvent('selectedconfig', {
            detail: { name: this.selecteRadioButtonValue }
        });
        this.dispatchEvent(eventToSend);


        let records = [];
        Object.keys(this._allRecordReference).forEach((key, ) => {
            records.push({ name: key, value: this._allRecordReference[key], isChecked: this.checkedValue });
        });
        let selectedUID = event.currentTarget.dataset.id;
        console.log("selectedUID @@@@@", selectedUID);

        for (let i = 0; i < records.length; i++) {
            if (records[i].name == selectedUID) {
                records[i].isChecked = true;
                console.log("records[i]", records[i]);
                records[i].checked = true;
                console.log(" update records [i] is ", records[i]);
            }
        }
        this.configRecords = records;

        let data = this._allRecordReference[selectedUID];
        this.selectData = data;
        console.log('selecte data $$$', this.selectData);

        let headerRecord = data.filter(item => {
            return item.record.RecordType.Name == 'Document Header';
        });
        let footerRecord = data.filter(item => {
            return item.record.RecordType.Name == 'Document footer';
        });

        let base64 = (headerRecord.length > 0) ? headerRecord[0].attachmentBase64 : "";
        this.previouseBase64 = (headerRecord.length > 0) ? headerRecord[0].attachmentBase64 : "";
        headerRecord = (headerRecord.length > 0) ? headerRecord[0].record : headerRecord;
        footerRecord = (footerRecord.length > 0) ? footerRecord[0].record : footerRecord;


        console.warn('OUTPUT_____---base64 : ', base64);
        if (base64) {
            this.attachmentBase64 = 'data:image/png;base64,' + base64;

        } else {
            this.attachmentBase64 = null;
            //this.checkBoxValue = false;
            console.log('visibleAttachmentBase64', this.attachmentBase64);
        }


        this.headerText = headerRecord.Header_Text__c
;
        this.footerText = footerRecord.Footer_Text__c;

        //common for header and footer
        let fontStyle = headerRecord.Font_Family__c;
        let fontSize = headerRecord.Font_Size__c;

        let headerBorderColor = headerRecord.Header_Border_Color__c;
        let headerTextColor = headerRecord.Header_Text_Color__c;
        let headerTextPosition = headerRecord.Header_Text_Position__c;
        let horizontalMargin = headerRecord.Horizontal_Margin__c
;
        let verticalMargin = headerRecord.Vertical_Margin__c;
        let isHeaderBorderApply = headerRecord.is_Header_Border_Apply__c;

        let logoHeight = headerRecord.Logo_Height__c;
        let logoPosition = headerRecord.Logo_Position__c;
        let logoWidth = headerRecord.Logo_Width__c;



        this.imgPosition = `width: ${logoWidth};
        height: 4rem; `; //${logoHeight};


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
        let footerHorizontalMargin = footerRecord.Horizontal_Margin__c
;
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

    }

    attachmentBase64;
    selectData = {};

    openHeaderFooterTemplate() {
        this.hideSaveButton = false;
        this.horizontalMarginOptionsvalue = null;
        this.verticalMarginOptionsvalue = null;
        this.fontFamilyOptionsvalue = null;
        this.fontSizeOptionsvalue = null;
        // this.defaultFooterTextColorValue = null;
        //this.defaultHeaderTextColorValue = null;
        this.logoPositionOptionsValue = null;
        this.footerTextPositionOptionsValue = null;
        // this.headerTextPositionOptionsValue = null;
        this.logWidthDefaultValue = null;
        this.logHeightDefaultValue = null;
        
         
        this.defaultHeaderText = null;

        this.defaultFooterText = null;
        this.logoSelectedIMG = null;
        this.imageHideForPopUp = false; //img show
        this.checkBoxValue = false;
        this.isModalOpen = true;
    }
    openModal() {
        this.isModalOpen = true;
    }
    closeHeaderFooterModal() {
        console.log('close');
        this.isModalOpen = false;
        this.logoPopUp = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }

    ShowToastEvent() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Header & Footer Selected successfully !!!..',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    callHTML2CanvasVFPage(header, footer) {
        let vfWindow = this.template.querySelector("iframe").contentWindow;
        let paramData = { header, footer };
        vfWindow.postMessage(paramData, this.vfRoot);
    }

    @track showLoading = false;
    handleSelectedData() {
        this.showLoading = true;

        let headerHTML = this.template.querySelector('.header-config').innerHTML;
        let footerHTML = this.template.querySelector('.footer-config').innerHTML;
        this.callHTML2CanvasVFPage(headerHTML, footerHTML);

    }



    handleClick() {
        this.openPreConfig = true;
    }
    handleModelHide() {
        this.isOpenModal = false;
    }

    // header footer work start

    handleImageFile() {
        this.template.querySelector('.image-file').click();
    }
    logoPopUp = false;
    isOpenNamePopUp = false;
    // opneImgPopUp(){
    //     this.logoPopUp = true;
    // }
    logoSelectedIMG;
    inputFiles;
    imageShow = false;


    handleCancelClick() {
        const cancelEvent = new CustomEvent('cancelclick', {
            bubbles: true // This makes the event bubble up to parent components
        });
        this.dispatchEvent(cancelEvent);
    }

    handleFilesChange(event) {
        this.isApplyButtonVisible = false;
        const file = event.target.files[0];
        this.inputFiles = file ? file.name : '';
        if (file) {
            var reader = new FileReader()
            reader.onload = () => {
                this.logoSelectedIMG = reader.result;
                this.imageShow = true;
                var base641 = reader.result.split(',')[1]
                this.fileData = {
                    'filename': file.name,
                    'base64': base641,
                    'recordId': this.recordId

                }

            }
            reader.readAsDataURL(file)
        }

    }
    handleClickFileSave() {
        const { base64, filename, recordId } = this.fileData;
        uploadLogo({ base64, filename, recordId }).then(result => {
            this.fileData = null
            this.urlShow();
            // let title = `${filename} uploaded successfully!!`
            // this.toast(title)
        }).catch(e => {
        });
    }

    handleHeaderApplyCheckBox(event) {
        let value = event.target.checked;
        if (value == true) {
            this.headerBorderColorBox = true;
        } else if (value == false) {
            this.headerBorderColorBox = false;
        }
        this.isApplyHeaderBorder = value;

    }
    handleFooterApplyCheckBox(event) {
        let value = event.target.checked;
        if (value == true) {
            this.footerBorderColorBox = true;
        } else if (value == false) {
            this.footerBorderColorBox = false;
        }
        this.isApplyFooterBorder = value;

    }


    logoFieldData = {};
    handleDeleteIconClick(){
        this.disabledLogoCheckbox = false;
        this.template.querySelector('.is-apply-logo').checked = false;
        console.log('checkBoxValue----------------->', this.checkBoxValue);
        this.logoPopUp = false;
        this.editableVisible = false;
        this.disableCheckBox = false;
        this.disabledLogoCancelButton = false;
        // this.template.querySelector('.is-apply-logo').checked = false;

        this.fileData = [];
        console.log('file', this.fileData);
        this.logoSelectedIMG = '';
        this.imageShow = false;
        this.imageHideForPopUp = false;
        this.isApplyButtonVisible = true;
        this.logWidthDefaultValue = null;
        this.logHeightDefaultValue = null;
        this.logoPositionOptionsValue = null;
         
        let fields = this.template.querySelectorAll('.logo-fields');
        fields.forEach(currentItem => {
            currentItem.value = null;
            console.log(' currentItem.value', currentItem.value)
        });
    }

    handleLogoLayOut() {
        this.editableVisible = true;
        this.disabledLogoCheckbox = true;//disabled checkbox
        this.disabledLogoCancelButton = true;//disabled cancel button
        let data = {};
        [...this.template.querySelectorAll('.logo-fields')].forEach(input => {
            data[input.dataset.field] = input.value;
        });
        this.logoFieldData = data;
        console.log('logoFieldData', this.logoFieldData.Logo_Height__c);
        this.logHeightDefaultValue = this.logoFieldData.Logo_Height__c;
        this.logoPositionOptionsValue = this.logoFieldData.Logo_Position__c;
        this.logWidthDefaultValue = this.logoFieldData.Logo_Width__c;
        console.log('compplete');

        if (this.fileData) {
            this.imageHideForPopUp = true;
        } else {
            this.showNotification('Info', 'Please Select Your Company Logo', 'Info');
            return;
        }
        this.logoPopUp = false;



    }
    handleLogoPopUp() {
        this.imageHideForPopUp = false;
        this.logoPopUp = true;
    }
    handlePopUpForIconClick() {
        this.imageHideForPopUp = false;
        this.logoPopUp = true;
    }
    handleLogo(event) {
        this.isApplyLogo = event.target.checked;
        if (event.target.checked == true) {
            this.isApplyLogoVisvibleButton = true;

            this.imageHideForPopUp = false;
            this.logoPopUp = true;


        } else {
            this.isApplyLogoVisvibleButton = false;
            this.logoPopUp = false;
        }
    }
    errorMessage = '';
    showError;
    handleSave() {
        let templateName = this.template.querySelector('.template-name').value;
        this.showLoading = true;
        let uId = 'Document-' + Math.random().toString(16).slice(2);
        let headerFieldData = {}, footerFieldData = {};

     //   try {
        
            [...this.template.querySelectorAll('.header-fields')].forEach(input => {
                headerFieldData[input.dataset.field] = input.value;
            });
             
            [...this.template.querySelectorAll('.footer-fields')].forEach(input => {
                footerFieldData[input.dataset.field] = input.value;
            });
            //Loop
            [...this.template.querySelectorAll('.common-fields')].forEach(input => {
                headerFieldData[input.dataset.field] = input.value;
                footerFieldData[input.dataset.field] = input.value;
            });
             console.log('footerFieldData***', JSON.stringify(footerFieldData));
             console.log('headerFieldData**',JSON.stringify(headerFieldData));

            const existingTemplates = [...this.templates];
            if (existingTemplates.includes(templateName)) {
                var errorShow = this.template.querySelector('.errorDuplicate');
                errorShow.innerHTML = 'Name already exists. Please choose a different name';
                errorShow.style = 'color:red;';
                this.showLoading = false;

            }
            else {
                console.log('test 2----------------',templateName);
                headerFieldData['Template_Name__c'] = templateName;
                footerFieldData['Template_Name__c'] = templateName;

                // headerFieldData['Template_Name__c'] = templateName;
                // footerFieldData['Template_Name__c'] = templateName;

                headerFieldData['UId__c'] = uId;
                footerFieldData['UId__c'] = uId;
                console.log(' this.isApplyLogo', this.isApplyLogo);

                if (this.isApplyLogo == true) {
                    headerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;
                    footerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;
                    headerFieldData['Logo_Height__c'] = this.logoFieldData.Logo_Height__c;
                    headerFieldData['Logo_Position__c'] = this.logoFieldData.Logo_Position__c;
                    headerFieldData['Logo_Width__c'] = this.logoFieldData.Logo_Width__c;


                } else {
                    this.attachmentBase64 = null;
                }
                console.log('headerFieldData', JSON.stringify(headerFieldData));
                console.log('test---footerFieldData-------------',JSON.parse(JSON.stringify(footerFieldData)));
                console.log('fileData--', JSON.stringify({...this.fileData }));
                var tempFileData = { ...this.fileData };
                console.log('data: '+JSON.stringify(tempFileData));
                var tempFileDataString = JSON.stringify(tempFileData);
                if(templateName){                                
                saveHeaderFooterTemplateConfig({headerData: headerFieldData, footerData: footerFieldData, filedata: tempFileDataString })
                    .then(result => {
                        console.log("result");
                        this.progressValue = true;
                        this.isModalOpen = false;
                        this.showLoading = false;

                        this.showNotification('Success','Header & Footer Configuration saved successfully!', 'success');
                        this.selecteRadioButton = true;
                        if (this.selecteRadioButton == true) {
                            console.log("saved scucesss ");
                            this.connectedCallback();

                        }
                        const selectedEvent = new CustomEvent("progressvaluechange", {
                            detail: this.progressValue

                        });
                        // Dispatches the event.
                        this.dispatchEvent(selectedEvent);

                        this.isSpinner = false;
                        this.isOpenNamePopUp = false;

                    })
                    .catch(error => {
                        let message = (error.body.message || error.message);
                        this.progressValue = true;
                        this.isModalOpen = false;
                        this.showLoading = false;
                        console.log('ERROR---', error.body.message);
                        this.showNotification('Error', message, 'error');
                        this.showLoading = false;
                    });
                    
                }else{
                    console.log('enter &&&&&&&&');
                     this.showLoading = false;
                    var errorShow = this.template.querySelector('.errorDuplicate');
                    errorShow.innerHTML = 'Name Should not be blank. Please Enter Template Name';
                    errorShow.style = 'color:red;';
                   // this.showNotification('Info', 'Please Enter Template Name', 'Info');
                }

            }
     //   } catch (error) {
       //     console.log('error', error.message);
        //    this.showNotification('Info', 'Please Select Your Company Logo', 'Info');
        //    this.showLoading = false;
       // }
    }

   
    handleClickSave() {
        var errorShow = this.template.querySelector('.headerText');
        let headerFieldData = {};
        [...this.template.querySelectorAll('.header-fields')].forEach(input => {
            headerFieldData[input.dataset.field] = input.value;
        });
        console.log('headerFieldData', JSON.stringify(headerFieldData));
        if (headerFieldData.Header_Text__c) {
            this.isOpenNamePopUp = true;
            errorShow.innerHTML = '';

        } else {

            errorShow.innerHTML = 'Please Enter Header Text';
            errorShow.style = 'color:red;';
        }

    }

    handlePerview() {
        let headerFieldData = {}, footerFieldData = {};

        [...this.template.querySelectorAll('.header-fields')].forEach(input => {
            headerFieldData[input.dataset.field] = input.value;
        });

        [...this.template.querySelectorAll('.footer-fields')].forEach(input => {
            footerFieldData[input.dataset.field] = input.value;
        });

        [...this.template.querySelectorAll('.common-fields')].forEach(input => {
            headerFieldData[input.dataset.field] = input.value;
            footerFieldData[input.dataset.field] = input.value;
        });

        headerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;
        footerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;

        headerFieldData['is_Header_Border_Apply__c'] = this.isApplyHeaderBorder;
        footerFieldData['is_Footer_Border_Apply__c'] = this.isApplyFooterBorder;



        this.isOpenModal = true;
        let data = JSON.parse(JSON.stringify(headerFieldData));
        let footerData = JSON.parse(JSON.stringify(footerFieldData));

        // for footer
        this.footerText = footerData.Footer_Text__c;

        this.headerText = data.Header_Text__c;

        let footerfontStyle = footerData.Font_Family__c;
        let footerfontSize = footerData.Font_Size__c;
        let footerTextColor = footerData.Footer_Text_Color__c;
        let footerTextPosition = footerData.Footer_Text_Position__c;
        let footerHorizontalMargin = footerData.Horizontal_Margin__c;
        let footerVerticalMargin = footerData.Vertical_Margin__c;
        let footerBorderApply = footerData.is_Footer_Border_Apply__c;

        let fontStyle = data.Font_Family__c;
        let fontSize = data.Font_Size__c;
        let headerBorderColor = data.Header_Border_Color__c;
        let headerTextColor = data.Header_Text_Color__c;
        let headerTextPosition = data.Header_Text_Position__c;
        let horizontalMargin = data.Horizontal_Margin__c;
        let verticalMargin = data.Vertical_Margin__c;
        let isHeaderBorderApply = data.is_Header_Border_Apply__c;


        let footerBorder;
        if (footerBorderApply == true && headerBorderColor != '') {
            footerBorder = `1px solid`;
        }

        this.footerConatinerCSS = `display: flex;
        border: ${footerBorder} ${headerBorderColor};
            width: initial;
            justify-content: flex-start;
            align-items: center;`;
        //&& footerBorderColor != ''


        this.footerTextStyle = `font-family: ${footerfontStyle};
                                font-size: ${footerfontSize}; 
                                color : ${footerTextColor};
                                text-align : ${footerTextPosition};
                                margin-left: ${footerHorizontalMargin};
                                margin-right: ${footerHorizontalMargin};
                                margin-top: ${footerVerticalMargin};
                                margin-bottom: ${footerVerticalMargin};`;

        let logoData = JSON.parse(JSON.stringify(this.logoFieldData));
        let logoFilter = logoData.Logo_Filter__c;
        let logoHeight = logoData.Logo_Height__c;
        let logoPosition = logoData.Logo_Position__c;
        let logoWidth = logoData.Logo_Width__c;



        this.imgPosition = `width: ${logoWidth};
        background-image: url(${this.logoSelectedIMG});
        height: 10vh;
        background-size: contain;
        background-size: 100% 100%;
        background-size: contain;
        background-repeat: no-repeat;
        background-position : ${logoPosition};
        margin-top: ${verticalMargin};`;


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

        this.isSpinner = false;
    }

    showNotification(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }


    handleModelHide() {
        this.isOpenModal = false;
        this.isOpenNamePopUp = false;
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    get horizontalMarginOptions() {
        return [
            { label: '0mm', value: '0mm' },
            { label: '5mm', value: '5mm' },
            { label: '10mm', value: '10mm' },
            { label: '15mm', value: '15mm' },
        ];
    }

    get verticalMarginOptions() {
        return [
            { label: '0mm', value: '0mm' },
            { label: '5mm', value: '5mm' },
        ];
    }
    get fontFamilyOptions() {
        return [
            { label: 'serif', value: 'serif' },
            { label: 'monospace', value: 'monospace' },
            { label: 'cursive', value: 'cursive' },
            { label: 'fantasy', value: 'fantasy' },
            { label: 'system-ui', value: 'system-ui' },
            { label: 'ui-serif', value: 'ui-serif' },
        ];
    }
    get fontSizeOptions() {
        return [
            { label: '5pt', value: '5pt' },
            { label: '10pt', value: '10pt' },
            { label: '15pt', value: '15pt' },
        ];
    }
    get headerTextPositionOptions() {
        return [
            { label: 'Left', value: 'left' },
        ];
    }

    get footerTextPositionOptions() {
        return [
            { label: 'Left', value: 'left' },
            { label: 'None', value: 'center' },
        ];
    }

    get logoPositionOptions() {
        return [
            { label: 'Top Left', value: 'left' },
            { label: 'Top right', value: 'right' },
        ];
    }

    logWidthDefaultValue = '20%';
    logHeightDefaultValue = '10vh';
    get logoWidth() {
        return [
            { label: '10%', value: '10%' },
            { label: '15%', value: '15%' },
            { label: '20%', value: '20%' },


        ];
    }

    get logoHeight() {
        return [
            { label: '10vh', value: '10vh' },
            { label: '15vh', value: '15vh' },
            { label: '20vh', value: '20vh' },

        ];
    }

    get PageNumberFormatOptions() {
        return [
            { label: 'Number', value: 'number' },
            { label: 'Roman Number', value: 'roman-upper' },

        ];
    }

    // Ravi code here 
    @track htmlCode = 'htmlCode';
    @track htmlCode1 = 'htmlCode1';
    @track showModal = false;
    @track htmlContent = '';

    openStandardTemplate() {
        //alert('call');
        this.htmlCode = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta http-equiv="Content-Style-Type" content="text/css" /><meta name="generator" content="Aspose.Words for .NET 23.9.0" /><title></title><style type="text/css">body { line-height:108%; font-family:Rockwell; font-size:11pt }h1, h2, h3, h4, h5, h6, p { margin:0pt }li, table { margin-top:0pt; margin-bottom:0pt }h1 { margin-top:3pt; margin-bottom:2pt; text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family:Franklin Gothic Demi; font-size:25pt; font-weight:normal; text-transform:uppercase; color:#000000 }h2 { text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family:Franklin Gothic Demi; font-size:11pt; font-weight:normal; text-transform:uppercase; color:#000000 }h3 { page-break-inside:avoid; page-break-after:avoid; line-height:108%;  font-size:11pt }.IndexHeading { line-height:108%; font-family:Franklin Gothic Demi; font-size:11pt; font-weight:bold }.Initials { text-align:center; line-height:normal; font-family:Franklin Gothic Demi; font-size:55pt; text-transform:uppercase; color:# }.IntenseQuote { margin:18pt 43.2pt; text-align:center; line-height:108%; border-top:0.75pt solid #; border-bottom:0.75pt solid #; padding-top:10pt; padding-bottom:10pt; font-size:11pt; font-style:italic; color:#d01818; -aw-border-bottom:0.5pt single; -aw-border-top:0.5pt single }.List { margin-left:18pt; text-indent:-18pt; line-height:108%; </style></head><body border="1"><div><p class="NoSpacing"><span style="height:0pt; display:block; position:absolute; z-index:-1"></span><span style="-aw-import:ignore">&#xa0;</span></p><table cellspacing="0" cellpadding="0" style="border-collapse:collapse"><tr style="height:12.95pt"><td colspan="2" style="width:153pt; vertical-align:middle"><p class="Initials"><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>RJ</span></span><span> </span></p></td><td style="width:31.5pt; vertical-align:middle"><p class="NoSpacing" style="text-align:center"><span style="-aw-import:ignore">&#xa0;</span></p></td><td style="width:328.5pt; vertical-align:middle"><h1><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>Chela Arapelli</span></span></h1><h2><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>beauty blogger</span></span><span> | </span><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>www.interestingsite.com</span></span></h2></td><td style="width:12.6pt; vertical-align:middle"><p class="NoSpacing" style="text-align:right"><span style="-aw-import:ignore">&#xa0;</span></p></td></tr></table><p class="NoSpacing"><span style="-aw-import:ignore">&#xa0;</span></p></div><hr/></body></html>';
        yourApexMethod({ htmlCode: this.htmlCode, htmlCode1: this.htmlCode1 })
            .then(result => {
                this.htmlContent = result;
                this.showModal = true;
            })
            .catch(error => {
                //alert('error');
                // Handle any errors here
            });
    }
    closeModal() {
        this.showModal = false;
    }
}