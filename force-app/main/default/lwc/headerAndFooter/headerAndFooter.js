import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modal from "@salesforce/resourceUrl/customModal";
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
import uploadLogo from '@salesforce/apex/headerAndFooterController.uploadLogo';
import saveHeaderFooterTemplateConfig from '@salesforce/apex/headerAndFooterController.saveHeaderFooterTemplateConfig';
import getTemplateNames from '@salesforce/apex/headerAndFooterController.getTemplateNames';

// import getLogoImag from '@salesforce/apex/headerAndFooterController.getLogoImag';
export default class HeaderAndFooter extends LightningElement {

    //for default value set variables
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
    @track isApplyLogo;
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
    @track progressValue="";


    //for css dynamic
    headerTextStyle;
    footerTextStyle;
    headerText;
    footerText;
    isOpenModal = false;
    imgPosition;
    footerConatinerCSS;


    connectedCallback() {
        loadStyle(this, modal);
        getTemplateNames().then(result => {
            for (let i = 0; i < result.length; i++) {
                this.templates.push(result[i].Template_Name__c);
            }
        }).catch(e => {
        });
    }

    handleImageFile() {
        this.template.querySelector('.image-file').click();
    }
    logoPopUp = false;
    isOpenNamePopUp = false;
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
        }).catch(e => {
        });
    }
    headerBorderColorBox = false;
    footerBorderColorBox = false;
    isApplyLogoVisvibleButton = false;

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
    closeLogoPopUp() {
        const checkbox = this.template.querySelector('.is-apply-logo');
        alert('checkbox'+checkbox);
        this.logoPopUp = false;
        this.template.querySelector('.is-apply-logo').checked = false;
      
        this.fileData = [];
          console.log('file', this.fileData); 
          this.logoSelectedIMG = '';
          this.imageShow = false;
          this.imageHideForPopUp = false;
          this.isApplyButtonVisible = true;
        let fields =   this.template.querySelectorAll('.logo-fields');
        fields.forEach(currentItem => {
          currentItem.value = null;
          console.log(' currentItem.value',  currentItem.value)
        });

    }

    logoFieldData = {};

    handleLogoLayOut() {
        let data = {};
        [...this.template.querySelectorAll('.logo-fields')].forEach(input => {
            data[input.dataset.field] = input.value;
        });
        this.logoFieldData = data;
        console.log('logoFieldData', this.logoFieldData.Logo_Height__c);
        this.logHeightDefaultValue = this.logoFieldData.Logo_Height__c;
        this.logoPositionOptionsValue = this.logoFieldData.Logo_Position__c;
        this.logWidthDefaultValue = this.logoFieldData.Logo_Width__c;
        console.log('complete');

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


        this.isSpinner = true;
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

            const existingTemplates = [...this.templates];
            if (existingTemplates.includes(templateName)) {
                var errorShow = this.template.querySelector('.errorDuplicate');
                errorShow.innerHTML = 'Name already exists. Please choose a different name';
                errorShow.style = 'color:red;';

            }
            else {

                headerFieldData['Template_Name__c'] = templateName;
                footerFieldData['Template_Name__c'] = templateName;

                headerFieldData['UId__c'] = uId;
                footerFieldData['UId__c'] = uId;

                headerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;
                footerFieldData['is_Apply_Logo__c'] = this.isApplyLogo;

                headerFieldData['is_Header_Border_Apply__c'] = this.isApplyHeaderBorder;
                footerFieldData['is_Footer_Border_Apply__c'] = this.isApplyFooterBorder;


                headerFieldData['Logo_Height__c'] = this.logoFieldData.Logo_Height__c;
                headerFieldData['Logo_Position__c'] = this.logoFieldData.Logo_Position__c;
                headerFieldData['Logo_Width__c'] = this.logoFieldData.Logo_Width__c;


                const { base64, filename, recordId } = this.fileData;

                saveHeaderFooterTemplateConfig({ base64, filename, headerData: headerFieldData, footerData: footerFieldData })
                    .then(result => {
                        this.progressValue=true;
                        this.showNotification('Success', 'Configuration saved successfully!', 'success');
                        const selectedEvent = new CustomEvent("progressvaluechange", {
                            detail: this.progressValue

                        });

                        // Dispatches the event.
                        this.dispatchEvent(selectedEvent);

                        this.isSpinner = false;
                        this.isOpenNamePopUp = false;

                    })
                    .catch(error => {
                        let message = (error.body.message || error.message)
                        this.showNotification('Error', message, 'error');
                        this.isSpinner = false;
                    });
            }
        } catch (error) {
            this.showNotification('Info', 'Please Select Your Company Logo', 'Info');
            this.isSpinner = false;
        }
    }

    handleClickSave() {
        this.isOpenNamePopUp = true;

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
            { label: '15mm', value: '15mm'},
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
            { label: 'center', value: 'center' },
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

    get PageNumberFormatOptions(){
        return[
        { label: 'Number', value: 'number' },
        { label: 'Roman Number', value: 'roman-upper' },
    
        ];
    }



}