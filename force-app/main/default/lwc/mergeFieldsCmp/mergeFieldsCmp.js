import { LightningElement, api, track, wire } from 'lwc';
import getObjectFields from '@salesforce/apex/ObjectNameController.getObjectFields'; // Replace "ObjectNameController" with your Apex class name
import getApiName from '@salesforce/apex/ObjectNameController.getApiName';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getParentObjects from '@salesforce/apex/ObjectNameController.getParentObjects'; // Replace "ObjectNameController" with your Apex class name
import getChildObjects from '@salesforce/apex/ObjectNameController.getChildObjects'; // Replace "ObjectNameController" with your Apex class name
export default class MergeFieldsCmp extends LightningElement {
    objectFields = [];
    objectFields1 = [];
    objectFields2 = [];
    objectFields3 = [];
    objectFields4 = [];
    allData = [];
    contactUpdateList = [];
    contactFields = [];
    accountFields = [];
    contactList = [];
    objectOptions = [];

    @track refreshComponent = false;

    @api selectedObjectName;
    @track draggedData = 'Table';
    @track dropTargetData = '';
    @track isModalVisible = false;
    @track isModalOpen = false;

    @track ShowComboBox = true;
    @track ShowComboBox2 = false;
    @track ShowComboBox3 = false;
    @track ShowComboBox4 = false;
    @track ShowComboBox5 = false;
    @track showTableBox = false;

    @track copyField = false
    @track isLookup = false;
    @track showDialogBox1 = false;
    @track showObjects = true;
    @track isChildInput = false;
    @track isParentInput = false;
    @track buttonDisbaled = false;
    @track buttonParentDisabled = false;

    @track disableButton = true;
    @track isDisable = true;
    @track showButtons = true;
    @track showChildFields = false;
    @track showParentObjects = true;
    @track parentObject = "";
    @track childObject = ""
    @track optionsPicklist = [];


    @track isComboBoxVisible = true;
    @track isComboBoxVisible1 = true
    @track isComboBoxVisible2 = true
    @track isComboBoxVisible3 = true
    @track isComboBoxVisible4 = true
    @track isComboBoxVisible5 = true
    @track filteredOptions = [];
    @track options = [];
    @track relatedObjects = [];
    @track relatedObjects1 = [];


    @track isItemSelected = false;
    @track isItemSelected1 = false;
    @track isItemSelected2 = false;
    @track isItemSelected3 = false;
    @track isItemSelected4 = false;
    @track isItemSelected5 = false;

    @track boxIcon = false;
    @track boxOneIcon = false;
    @track boxTwoIcon = false;
    @track boxThreeIcon = false;
    @track boxFourIcon = false;


    @track objectApi1;
    @track objectApi2;
    @track objectApi3;
    @track objectApi4;
    @track selectedFieldApi0;
    @track selectedFieldApi1;
    @track selectedFieldApi2;
    @track selectedFieldApi3;
    @track selectedFieldApi4;
    @track showValueBox = ""
    @track paramString;
    @track endLevel = "";
    @track isLoaded = true;


    @api objectApi;
    @api recordId;


    selectedField = '';
    selectedFieldAccount = '';
    selectedValue = '';
    selectedValue1 = '';
    selectedValue2 = '';
    selectedValue3 = '';
    selectedValue4 = '';
    selectedValue5 = '';
    selectedValueBox = '';

    @track searchKey = '';
    @track searchTerm = '';
    @track searchTerm1 = '';
    @track searchResults = [];
    @track searchResults1 = [];
    @track searchResultsVisible = false;
    @track searchResultsVisibleChild = false;
    @track showCancelButton = false;
    @track selectRelationObject = "";
    @track finalSearchData = [];
    @track tempDuplicateData = [];
    @track tempDuplicateData1 = [];

    selectedRecord = null;
    _selected = [];
    htmlTableBody = '';
    @track showContentBox = false;
    @track allObject = {};
    mergedString = "";
    allCombobox1 = [];
    @track disablePreview = true;
    @track showMainObject = true
    @track selectedValues = [];

    connectedCallback() {
        console.log("object name api", this.selectedObjectName);
        this.doSearch();
        this.callChild();

        getObjectFields({ objectName: this.selectedObjectName })
            .then((data) => {
                console.log("conneced call back object ", this.selectedObjectName);
                // console.log('parent block', data);
                this.allData = data;
                console.log("all data ", this.allData);
                this.objectFields = data.map((fieldName) => ({
                    label: fieldName.label,
                    value: fieldName.value
                }));
                this.optionsPicklist = this.removeGreaterThanSymbol(data);
                this.objectApi = this.selectedObjectName;
            })
            .catch((error) => {
            });


        if (this.searchTerm == null && this.searchTerm1 == null) {
            console.log("both string is null");
            this.showButtons = true;
        }
    }

    startResize(event) {
        window.addEventListener('mousemove', this.resize);
        window.addEventListener('mouseup', this.stopResize);
        this.initialX = event.clientX;
        this.initialWidth = this.template.querySelector('.resizable-container').offsetWidth;
    }

    resize(event) {
        const container = this.template.querySelector('.resizable-container');
        const width = this.initialWidth + (event.clientX - this.initialX);
        container.style.width = `${width}px`;
    }

    stopResize() {
        window.removeEventListener('mousemove', this.resize);
        window.removeEventListener('mouseup', this.stopResize);
    }

    @track searchData = [];
    handelSearchKey(event) {
        this.searchTerm = event.target.value;
        this.showChildFields = false;
        let userList2 = [];
        this.relatedObjects = this.tempDuplicateData;
        if (this.searchTerm.length > 0) {
            userList2 = this.relatedObjects.filter(user => {
                return (
                    user.value.toLowerCase().includes(this.searchTerm.toLowerCase())
                );
            });
            this.relatedObjects = userList2;
        }
        else if (this.searchTerm.length == 0) {
            this.relatedObjects = this.tempDuplicateData;
        }
        this.searchResults = this.relatedObjects;
    }

    handelSearchKeyChild(event) {
        this.searchTerm1 = event.target.value;
        console.log("search term 1", this.searchTerm1);
        let userList2 = [];
        this.relatedObjects1 = this.tempDuplicateData1;
        if (this.searchTerm1.length > 0) {
            userList2 = this.relatedObjects1.filter(user => {
                return (
                    user.value.toLowerCase().includes(this.searchTerm1.toLowerCase())
                );
            });
            this.relatedObjects1 = userList2;

        }
        else if (this.searchTerm1.length == 0) {
            this.relatedObjects1 = this.tempDuplicateData1;

        }
        this.searchResults1 = this.relatedObjects1;
        if (this.searchTerm1.length < 1) {
            console.log("hahahah");
            this.showChildFields = false;
            console.log("searchResultsVisibleChild @@", this.searchResultsVisibleChild);
        }
    }

    handleInputFocus() {
        this.isChildInput = true;
        this.searchResultsVisible = true;
        this.ShowComboBox = false;
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.isComboBoxVisible = false;
        this.isComboBoxVisible1 = false;
        this.isComboBoxVisible2 = false;
        this.isComboBoxVisible3 = false;
        this.isComboBoxVisible4 = false;
        this.isComboBoxVisible5 = false;
    }
    handleInputFocusChild() {
        this.isParentInput = true;
        this.searchResultsVisibleChild = true;

    }

    handleBlur(event) {
        setTimeout(() => {
            this.searchResultsVisible = false;
        }, 300);

    }
    handleChildBlur(event) {
        this.showChildFields = false;
        setTimeout(() => {
            this.searchResultsVisibleChild = false;
        }, 200);

    }

    handleCancelPreview(event) {
        this.paramString = "";
        this.showChildFields = false;
        this.buttonParentDisabled = false;
        this.isModalOpen = false;
        this.ShowComboBox = true;
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.showObjects = true;
        this.isComboBoxVisible1 = true;
        this.endLevel = "";
        this.boxOneIcon = false;
        this.isItemSelected1 = false;
        this.isDisable = true;
        this.buttonDisbaled = false;
        this.selectedValue1 = false;
        this.searchTerm = "";
        this.searchTerm1 = "";
        this.connectedCallback();
        console.log("connected");
        // this.showChildFields = false;
        // this.buttonParentDisabled = false;
        // this.searchTerm1 = "";
    }

    handleResultClick(event) {
        this.isChildInput = false;
        const selectedId = event.currentTarget.dataset.label;
        this.selectRelationObject = selectedId;
        this.searchTerm = selectedId;
        console.log("parent search term", this.searchTerm);
        this.parentObject = selectedId;
        console.log("parent object ius @@@ " + this.parentObject);
        const ShowObjectName = event.currentTarget.dataset.objectname;

        if (ShowObjectName == 'Parent') {
            this.showParentObjects = true;
            this.showChildFields = false;

        } else {
            this.showChildFields = true;
            this.showParentObjects = false;
        }
        const selectedObjectName1 = this.searchTerm;
        console.log("object name ", selectedObjectName1);
        this.selectedValue = event.target.value;
        console.log("selected value 121 " + this.selectedValue);
        this.objectApi = selectedObjectName1;

        getObjectFields({ objectName: selectedObjectName1 })
            .then((data) => {
                console.log('parent block', data);
                this.allData = data;
                this.objectFields = data.map((fieldName) => ({
                    label: fieldName.label,
                    value: fieldName.value
                }));
                this.optionsPicklist = this.removeGreaterThanSymbol(data);

            })
            .catch((error) => {
            });

        this.ShowComboBox = true;
        this.selectedValue1 = '';
        this.isItemSelected = true;
        this.isComboBoxVisible1 = true;
        this.isComboBoxVisible = false;
        this.boxIcon = true;
        this.boxOneIcon = false;
        this.buttonDisbaled = true;
        this.showCancelButton = true;
        this.searchResultsVisible = false;
        this.searchResultsVisibleChild = false;
        this.showButtons = true;

    }

    handleResultChildClick(event) {
        this.isParentInput = false;
        const selectedId = event.currentTarget.dataset.label;
        this.selectRelationObject = selectedId;
        this.searchTerm1 = selectedId;
        console.log("search term 1 %%%%%" + this.searchTerm1)
        const ShowObjectName = event.currentTarget.dataset.objectname;

        if (ShowObjectName == 'Parent') {
            this.showParentObjects = true;
            this.showChildFields = false;

        } else {
            this.showChildFields = true;
            this.showParentObjects = false;
        }
        const selectedObjectName1 = this.searchTerm1;
        this.selectedValue = event.target.value;
        this.objectApi = selectedObjectName1;

        getObjectFields({ objectName: selectedObjectName1 })
            .then((data) => {
                this.allData = data;
                this.objectFields = data.map((fieldName) => ({
                    label: fieldName.label,
                    value: fieldName.value
                }));
                this.optionsPicklist = this.removeGreaterThanSymbol(data);

            })
            .catch((error) => {
                console.error(error);
            });

        this.ShowComboBox = true;
        this.selectedValue1 = '';
        this.isItemSelected = true;
        this.isComboBoxVisible1 = true;
        this.isComboBoxVisible = false;
        this.boxIcon = true;
        this.boxOneIcon = false;
        this.buttonParentDisabled = true;
        this.searchResultsVisible = false;
        this.searchResultsVisibleChild = false;
        if (this.searchTerm1.length < 1) {
            console.log("no value");
            this.searchResultsVisibleChild = false;
        }
        else {
            console.log("value");
            this.searchResultsVisibleChild = true;
        }
        this.showButtons = true;

    }

    removeGreaterThanSymbol(data) {
        return data.map(item => {
            const cleanedItem = { ...item };

            // Remove '>' from the label property
            if (cleanedItem.label && cleanedItem.label.includes(' >')) {
                cleanedItem.label = cleanedItem.label.replace(' >', '');
            }

            // Remove '>' from the value property
            if (cleanedItem.value && cleanedItem.value.includes(' >')) {
                cleanedItem.value = cleanedItem.value.replace(' >', '');
            }

            return cleanedItem;
        });
    }

    handleSelectionChange(event) {

      //  this.selectedValues = event.detail.value;
        //console.log("selected value ",this.selectedValue);
     //   this.disablePreview = this.selectedValues.length === 0;

        this._selected = event.detail.value;
        console.log("this selected ",this._selected);

        if(this._selected.length > 0){
            this.disablePreview=false;
        }else{
            this.disablePreview=true;
        }
        let selectlabels = [];
        var htmlBody = '{{{TableStarted' + '___' + this.selectRelationObject + '}}}';
        htmlBody += '<table border="1" cellpadding="1" cellspacing="1" style="width:700px"><thead><tr>';
        this._selected.forEach(option => {
            let currentOption = this.optionsPicklist.find(o => o.value === option);
            selectlabels.push(currentOption.label);
        });
        for (var i = 0; i < selectlabels.length; i++) {
            htmlBody += '<td><span style="font-size:12.0pt"><span style="font-family:&quot;Times New Roman&quot;,&quot;serif&quot;">' + selectlabels[i] + '</span></span></td>';
        }
        htmlBody += '</tr></thead><tbody><tr>';
        selectlabels = [];
        this._selected.forEach(option => {
            let currentOption = this.optionsPicklist.find(o => o.value === option);
            selectlabels.push(currentOption.value);
        });
        for (var i = 0; i < selectlabels.length; i++) {
            htmlBody += '<td><span style="font-size:12.0pt"><span style="font-family:&quot;Times New Roman&quot;,&quot;serif&quot;">{{{' + selectlabels[i] + '}}}</span></span></td>';
        }
        htmlBody += '</tr></tbody></table>{{{TableEnd' + '___' + this.selectRelationObject + '}}}';
        this.htmlTableBody = htmlBody;
    }
    copyHtmlBodyContent() {
        const bodyHtml = document.body.innerHTML;
        var urlField = this.template.querySelector('.my-class');
        var range = document.createRange();
        range.selectNode(urlField);

        this.showContentBox = false;
        const event = new ShowToastEvent({
            message: 'Child Object Fields Copied Successfully..!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        //  this.showContentBox = false;
        this.showChildFields = false;
        this.searchTerm1 = "";
        window.getSelection().removeAllRanges();
        window.getSelection().addRange(range);
        document.execCommand('copy');

        window.getSelection().removeAllRanges();
        window.getSelection().addRange(selectedRange);
        window.alert("helloooo");


    }
    handlePreview(event) {
        this.showContentBox = true;
    }
    hideModalBox(event) {
        this.showContentBox = false;
    }
    doSearch() {
        console.log("do search $$$$")
        getParentObjects({ obj: this.selectedObjectName })
            .then(result => {
                console.log("do search", result);
                // if (this.selectedObjectName == 'Opportunity') {
                //     var tempdata = [{ label: 'Opportunity', value: 'Opportunity', objectName: 'Parent' }];
                // }
                // else {
                var tempdata = [];
                // }
                for (var i = 0; i < result.length; i++) {
                    tempdata.push({ label: result[i], value: result[i], objectName: 'Parent' });
                }
                tempdata = tempdata.filter(item => item.label !== this.selectedObjectName);

                this.relatedObjects = tempdata;
                this.tempDuplicateData = this.relatedObjects;
                this.searchResults = this.relatedObjects;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
                console.log('error-->', this.error);
            });

    }

    callChild() {
        getChildObjects({ obj: this.selectedObjectName })
            .then(result => {
                console.log("child");
                var tempdata1 = [];
                for (var i = 0; i < result.length; i++) {
                    tempdata1.push({ label: result[i], value: result[i], objectName: 'child' });
                }
                this.relatedObjects1 = tempdata1;
                this.tempDuplicateData1 = this.relatedObjects1;

                this.searchResults1 = this.relatedObjects1;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
            });
    }

    handleIconRemove(event) {
        const divElement = this.template.querySelector('.removeDiv');
        divElement.remove();
    }

    handleSelectedItemClick() {
        this.isItemSelected = false;
        this.isComboBoxVisible = true;
        this.ShowComboBox = false;
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.boxIcon = false;
        this.disableButton = true;
        this.paramString = "";
        this.endLevel = "";
    }
    handleFieldChange(event) {
        console.log("first combo box");

        this.selectedField = event.target.value;
        console.log("selected first field ", this.selectedField);
        this.selectedValue1 = event.target.value;
        this.showValueBox = this.selectedField;

        for (var i = 0; i < this.allData.length; i++) {

            if (this.allData[i].value == this.selectedField) {
                this.selectedFieldApi0 = this.allData[i].value;
                console.log("selectedFieldApi0 $ ", this.selectedFieldApi0);
            }
            if (this.allData[i].value == this.selectedField && this.allData[i].datatype == 'lookup') {
                this.isLookup = true;
                if (this.selectedFieldApi0 != '') {
                    console.log("this.selectedFieldApi0 ", this.selectedFieldApi0);
                    if (!this.selectedFieldApi0.endsWith('__c')) {
                        console.log("selectedFieldApi0 after replace ", this.selectedFieldApi0);
                    }
                    if (this.searchTerm.length > 0) {
                        console.log("yes ")
                        if (this.searchTerm.endsWith('__c'))
                            this.searchTerm = this.searchTerm.replace('__c', '__r');
                        console.log("search term __c", this.searchTerm);
                        this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0;
                    }
                    else {
                        console.log("no");
                        this.mergedString = this.selectedFieldApi0;
                        console.log("merzed first time", this.mergedString);
                    }

                    console.log("search term ", this.searchTerm);
                    if (this.searchTerm == 'User' && this.selectedObjectName != 'User') {
                        this.searchTerm = this.searchTerm.replace('User', 'Owner');
                        this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0;
                        console.log("Find user in field", this.selectedFieldApi0);
                    }

                    this.paramString = '{{{' + this.mergedString + '}}}';
                    console.log("param string ### ", this.paramString);
                    this.isDisable = false;
                }
            }
            else {
                this.objectFields2 = '';
                this.ShowComboBox3 = false;
                this.objectFields3 = '';
                this.ShowComboBox4 = false;
                this.objectFields4 = '';
                this.ShowComboBox5 = false;

                if (this.searchTerm.length > 0) {
                    console.log("no lokup reltion");
                    this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0;
                }
                else {
                    console.log("no lokup ", this.parentObject);
                    this.mergedString = this.selectedFieldApi0;

                }

                if (this.searchTerm == 'User' && this.selectedObjectName != 'User') {
                    this.searchTerm = this.searchTerm.replace('User', 'Owner');
                    this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0;
                    console.log("Find user in field", this.selectedFieldApi0);
                }

                if (this.selectedFieldApi0 != '') {
                    this.paramString = '{{{' + this.mergedString + '}}}';
                }
            }
        }
        if (this.isLookup == true) {
            getApiName({ objNameAPI: this.objectApi, objLabel: this.selectedField })
                .then(result => {
                    this.objectApi1 = result;
                    getObjectFields({ objectName: this.objectApi1 })
                        .then(result => {
                            this.objectFields1 = result;
                            this.ShowComboBox2 = true;
                            this.isComboBoxVisible2 = true;
                            this.boxOneIcon = true
                            this.boxTwoIcon = false;
                            this.boxThreeIcon = false;
                            this.boxFourIcon = false;
                            this.disableButton = true;
                            this.isDisable = false;
                        })
                })
                .catch(error => {
                })
        }
        if (this.isLookup == false) {
            this.boxOneIcon = false;
            this.disableButton = false;
            this.isDisable = false;
        }
        this.isLookup = false;
        this.isItemSelected1 = true;
        this.isComboBoxVisible1 = false;
        this.selectedValue2 = null;
        this.boxTwoIcon = true;
        this.boxOneIcon = false;
        this.boxThreeIcon = false;
        this.boxFourIcon = false;
        this.showButtons = true;
    }
    handleSelectedItemClick1() {
        this.isItemSelected1 = false;
        this.isComboBoxVisible1 = true;
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.selectedValue2 = null;
        this.boxOneIcon = false;
        this.disableButton = true;
        this.paramString = "";
        this.endLevel = "";
    }

    handleFieldAccount(event) {
        this.selectedFieldAccount = event.target.value;
        this.selectedValue2 = event.target.value;

        for (var i = 0; i < this.objectFields1.length; i++) {

            if (this.objectFields1[i].value == this.selectedFieldAccount) {
                this.selectedFieldApi1 = this.objectFields1[i].value;
            }
            if (this.objectFields1[i].value == this.selectedFieldAccount && this.objectFields1[i].datatype == 'lookup') {
                this.isLookup = true;


                if (this.selectedFieldApi1 != '') {
                    if (!this.selectedFieldApi1.endsWith('__c')) {
                    }

                    if (this.searchTerm.length > 0) {
                        console.log("yes ")
                        if (this.selectedFieldApi0.endsWith('__c')) {
                            this.selectedFieldApi0 = this.selectedFieldApi0.replace('__c', '__r');
                            console.log("selectedFieldApi0 ", this.selectedFieldApi0);
                        }
                        console.log(" selection lookup this.selectedFieldApi0 ", this.selectedFieldApi0);
                        this.selectedFieldApi0 = this.selectedFieldApi0.replace('Id', '');
                        console.log("after replacement ", this.selectedFieldApi0);

                        this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0 + '.' + this.selectedFieldApi1;
                    }
                    else {
                        console.log("no  2 cmbo box ");
                        console.log(" selection lookup this.selectedFieldApi0 ", this.selectedFieldApi0);

                        if (this.selectedFieldApi0.endsWith('__c')) {
                            console.log("enter custome c");
                            this.selectedFieldApi0 = this.selectedFieldApi0.replace('__c', '__r');
                        }

                        if (this.selectedFieldApi0.endsWith('Id')) {
                            if (this.selectedFieldApi0 = this.selectedFieldApi0.replace('Id', '')) { }
                            console.log("after replacement ", this.selectedFieldApi0);
                        }


                        this.mergedString = this.selectedFieldApi0 + '.' + this.selectedFieldApi1;
                        console.log("merzed first  @@@@@ time", this.mergedString);
                    }

                    this.paramString = '{{{' + this.mergedString + '}}}';
                }

            }
            else {
                this.objectFields2 = '';
                this.ShowComboBox4 = false;
                this.objectFields3 = '';
                this.ShowComboBox5 = false;

                if (this.searchTerm.length > 0) {
                    console.log("yes ");

                    console.log(" no lookup #### this.selectedFieldApi0 ", this.selectedFieldApi0);
                    this.selectedFieldApi0 = this.selectedFieldApi0.replace('Id', '');

                    if (this.selectedFieldApi0.endsWith('__c')) {
                        console.log("combo 2 __c");
                        this.selectedFieldApi0 = this.selectedFieldApi0.replace('__c', '__r');
                    }
                    console.log("search selectedFieldApi0 __c", this.selectedFieldApi0);
                    console.log("after replacement ", this.selectedFieldApi0);

                    this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0 + '.' + this.selectedFieldApi1;
                }
                else {
                    console.log("no");

                    if (this.selectedFieldApi0.endsWith('__c')) {
                        console.log("enter custome c");
                        this.selectedFieldApi0 = this.selectedFieldApi0.replace('__c', '__r');
                    }

                    if (this.selectedFieldApi0.endsWith('Id')) {
                        console.log("yes id >>>>>>>>>>>");
                        this.selectedFieldApi0 = this.selectedFieldApi0.replace('Id', '');
                    }

                    this.mergedString = this.selectedFieldApi0 + '.' + this.selectedFieldApi1;
                    console.log("merzed first time", this.mergedString);
                }
                if (this.selectedFieldApi0 != '') {
                    this.paramString = '{{{' + this.mergedString + '}}}';
                }
            }
        }
        if (this.isLookup == true) {
            getApiName({ objNameAPI: this.objectApi1, objLabel: this.selectedFieldAccount })
                .then(result => {
                    this.objectApi1 = result;
                    getObjectFields({ objectName: this.objectApi1 })
                        .then(result => {
                            this.objectFields2 = result;

                            this.ShowComboBox3 = true;
                            this.isComboBoxVisible3 = true;
                            this.boxTwoIcon = true
                            this.disableButton = true;
                        })
                })
                .catch(error => {
                    console.log('=====> error in creating records: ' + JSON.stringify(error));
                })
        }
        if (this.isLookup == false) {
            this.boxTwoIcon = false;
            this.disableButton = false;
        }
        this.isLookup = false;
        this.isItemSelected2 = true;
        this.isComboBoxVisible2 = false;
        this.selectedValue3 = null;
        this.boxThreeIcon = false;
        this.boxFourIcon = false;

    }
    handleSelectedItemClick2() {
        this.isItemSelected2 = false;
        this.isComboBoxVisible2 = true;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.selectedValue3 = null;
        this.boxTwoIcon = false;
        this.disableButton = true;
        this.paramString = "";
        this.endLevel = "";

    }
    handleCombo3(event) {
        this.selectedFieldAccount = event.target.value;
        this.selectedValue3 = event.target.value

        for (var i = 0; i < this.objectFields2.length; i++) {
            if (this.objectFields2[i].value == this.selectedFieldAccount) {
                this.selectedFieldApi2 = this.objectFields2[i].value;
                console.log("this.selected api 2 ", this.selectedFieldApi2);
            }
            if (this.objectFields2[i].value == this.selectedFieldAccount && this.objectFields2[i].datatype == 'lookup') {
                this.isLookup = true;

                if (this.selectedFieldApi2 != '') {
                    if (!this.selectedFieldApi2.endsWith('__c')) {
                    }
                    if (this.searchTerm.length > 0) {
                        console.log("yes ")

                        if (this.selectedFieldApi1.endsWith('__c')) {
                            console.log("combo 3 __c");
                            this.selectedFieldApi1 = this.selectedFieldApi1.replace('__c', '__r');
                        }
                        console.log("search combo 3 selectedFieldApi1 __c", this.selectedFieldApi1);
                        console.log("after replacement ", this.selectedFieldApi1);

                        console.log(" selection lookup combo 3 this.selectedFieldApi1 ", this.selectedFieldApi1);
                        this.selectedFieldApi1 = this.selectedFieldApi1.replace('Id', '');
                        console.log("after replacement ", this.selectedFieldApi1);

                        this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2;
                    }
                    else {
                        console.log("no @@@");

                        if (this.selectedFieldApi1.endsWith('__c')) {
                            console.log("enter custome c");
                            this.selectedFieldApi1 = this.selectedFieldApi1.replace('__c', '__r');
                        }

                        if (this.selectedFieldApi1.endsWith('Id')) {
                            console.log("yes id combo box 3 >>>>>>>>>>>");
                            this.selectedFieldApi1 = this.selectedFieldApi1.replace('Id', '');
                        }
                        this.mergedString = this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2;
                        console.log("merzed first time", this.mergedString);
                    }

                    this.paramString = '{{{' + this.mergedString + '}}}';
                }
            }
            else {
                this.objectFields3 = '';
                this.ShowComboBox5 = false;

                if (this.searchTerm.length > 0) {
                    console.log("yes ");

                    if (this.selectedFieldApi1.endsWith('__c')) {
                        console.log("combo 3 # __c");
                        this.selectedFieldApi1 = this.selectedFieldApi1.replace('__c', '__r');
                    }

                    console.log(" selection lookup  combo 3 this.selectedFieldApi1 ", this.selectedFieldApi1);
                    this.selectedFieldApi1 = this.selectedFieldApi1.replace('Id', '');
                    console.log("after replacement ", this.selectedFieldApi1);

                    this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2;
                }
                else {
                    console.log("no lookup");

                    if (this.selectedFieldApi1.endsWith('__c')) {
                        console.log("enter custome c");
                        this.selectedFieldApi1 = this.selectedFieldApi1.replace('__c', '__r');
                    }

                    if (this.selectedFieldApi1.endsWith('Id')) {
                        console.log("yes id combo box 3 >>>>>>>>>>>");
                        this.selectedFieldApi1 = this.selectedFieldApi1.replace('Id', '');
                    }

                    this.mergedString = this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2;
                    console.log("merzed first time", this.mergedString);
                }
                this.paramString = '{{{' + this.mergedString + '}}}';
            }
        }
        if (this.isLookup == true) {
            getApiName({ objNameAPI: this.objectApi1, objLabel: this.selectedFieldAccount })
                .then(result => {
                    this.objectApi2 = result;
                    getObjectFields({ objectName: this.objectApi2 })
                        .then(result => {
                            this.objectFields3 = result;

                            this.ShowComboBox4 = true;
                            this.isComboBoxVisible4 = true;
                            this.boxThreeIcon = true;
                            this.disableButton = true;
                        })
                })
                .catch(error => {
                    console.log('=====> error in creating records: ' + JSON.stringify(error));
                })
        }
        if (this.isLookup == false) {
            this.boxThreeIcon = false;
            this.disableButton = false;
        }
        this.isLookup = false;
        this.isItemSelected3 = true;
        this.isComboBoxVisible3 = false;
        this.selectedValue4 = null;


    }
    handleSelectedItemClick3() {
        this.isItemSelected3 = false;
        this.isComboBoxVisible3 = true;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.boxThreeIcon = false;
        this.boxFourIcon = false;
        this.disableButton = true;
        this.paramString = "";
        this.endLevel = "";
        this.selectedValue4 = null;

    }

    handlecombo4(event) {
        this.selectedFieldAccount = event.target.value;
        this.selectedValue4 = event.target.value;

        for (var i = 0; i < this.objectFields3.length; i++) {
            if (this.objectFields3[i].value == this.selectedFieldAccount) {
                this.selectedFieldApi3 = this.objectFields3[i].value;

            }
            if (this.objectFields3[i].value == this.selectedFieldAccount && this.objectFields3[i].datatype == 'lookup') {
                this.isLookup = true;

                if (this.selectedFieldApi3 != '') {
                    if (!this.selectedFieldApi3.endsWith('__c')) {
                        // this.selectedFieldApi3 = this.selectedFieldApi3.replace('Id', '');
                    }

                    if (this.searchTerm.length > 0) {
                        console.log("yes ");

                        if (this.selectedFieldApi2.endsWith('__c')) {
                            console.log("combo 4 # __c");
                            this.selectedFieldApi2 = this.selectedFieldApi2.replace('__c', '__r');
                        }

                        console.log(" selection lookup combo 4 this.selectedFieldApi2 ", this.selectedFieldApi2);
                        this.selectedFieldApi2 = this.selectedFieldApi2.replace('Id', '');
                        console.log("after replacement ", this.selectedFieldApi2);

                        this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2 + '.' + this.selectedFieldApi3;
                    }
                    else {
                        console.log("no");

                        if (this.selectedFieldApi2.endsWith('__c')) {
                            console.log("enter custome c");
                            this.selectedFieldApi2 = this.selectedFieldApi2.replace('__c', '__r');
                        }

                        if (this.selectedFieldApi2.endsWith('Id')) {
                            console.log("yes id combo box 3 >>>>>>>>>>>");
                            this.selectedFieldApi2 = this.selectedFieldApi2.replace('Id', '');
                        }

                        this.mergedString = this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2 + '.' + this.selectedFieldApi3;
                        console.log("merzed first time", this.mergedString);
                    }

                    this.paramString = '{{{' + this.mergedString + '}}}';
                }
            }
            else {
                this.objectFields4 = '';

                if (this.searchTerm.length > 0) {
                    console.log("yes ")

                    if (this.selectedFieldApi2.endsWith('__c')) {
                        console.log("combo 4 # __c");
                        this.selectedFieldApi2 = this.selectedFieldApi2.replace('__c', '__r');
                    }

                    console.log(" selection lookup combo 4this.selectedFieldApi2 ", this.selectedFieldApi2);
                    this.selectedFieldApi2 = this.selectedFieldApi2.replace('Id', '');
                    console.log("after replacement ", this.selectedFieldApi2);

                    this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2 + '.' + this.selectedFieldApi3;
                }
                else {
                    console.log("no");

                    if (this.selectedFieldApi2.endsWith('__c')) {
                        console.log("enter custome c");
                        this.selectedFieldApi2 = this.selectedFieldApi2.replace('__c', '__r');
                    }

                    if (this.selectedFieldApi2.endsWith('Id')) {
                        console.log("yes id combo box 4 >>>>>>>>>>>");
                        this.selectedFieldApi2 = this.selectedFieldApi2.replace('Id', '');
                    }

                    this.mergedString = this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2 + '.' + this.selectedFieldApi3;
                    console.log("merzed first time", this.mergedString);
                }

                this.paramString = '{{{' + this.mergedString + '}}}';
            }
        }

        if (this.isLookup == true) {
            getApiName({ objNameAPI: this.objectApi2, objLabel: this.selectedFieldAccount })
                .then(result => {
                    this.objectApi3 = result;
                    getObjectFields({ objectName: this.objectApi3 })
                        .then(result => {
                            this.objectFields4 = result;
                            this.ShowComboBox5 = true;
                            this.isComboBoxVisible5 = true;
                            this.boxFourIcon = true;
                            this.disableButton = true;
                        })
                })
                .catch(error => {
                    console.log('=====> error in creating records: ' + JSON.stringify(error));
                })
        }
        if (this.isLookup == false) {
            this.boxFourIcon = false;
            this.disableButton = false;
        }
        this.isLookup = false;
        this.isItemSelected4 = true;
        this.isComboBoxVisible4 = false;
        this.ShowComboBox5 = false;
        this.selectedValue5 = null;
    }
    handleSelectedItemClick4() {
        this.isItemSelected4 = false;
        this.isComboBoxVisible4 = true;
        this.ShowComboBox5 = false;
        this.selectedValue5 = null;
        this.boxFourIcon = false;
        this.disableButton = true;
        this.paramString = "";
        this.endLevel = "";

    }

    handleCombo5(event) {
        this.selectedValue5 = event.target.value;
        console.log("value 5", this.selectedValue5)
        this.isItemSelected5 = true;
        this.isComboBoxVisible5 = false;
        this.disableButton = false;

        this.endLevel = "You  Cannot Select More Than 5 Level !!!! "

        if (this.searchTerm.length > 0) {
            console.log("yes ")

            console.log(" selection lookup this.selectedFieldApi3 ", this.selectedFieldApi2);
            this.selectedFieldApi3 = this.selectedFieldApi3.replace('Id', '');
            console.log("after replacement ", this.selectedFieldApi3);

            this.mergedString = this.searchTerm + '.' + this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2 + '.' + this.selectedFieldApi3 + '.' + this.selectedValue5;
        }
        else {
            console.log("no");

            if (this.selectedFieldApi3.endsWith('__c')) {
                console.log("enter custome c");
                this.selectedFieldApi3 = this.selectedFieldApi3.replace('__c', '__r');
            }

            if (this.selectedFieldApi3.endsWith('Id')) {
                console.log("yes id combo box 3 >>>>>>>>>>>");
                this.selectedFieldApi3 = this.selectedFieldApi3.replace('Id', '');
            }

            this.mergedString = this.selectedFieldApi0 + '.' + this.selectedFieldApi1 + '.' + this.selectedFieldApi2 + '.' + this.selectedFieldApi3 + '.' + this.selectedValue5;
            console.log("merzed first time", this.mergedString);
        }

        this.paramString = '{{{' + this.mergedString + '}}}';

    }
    handleSelectedItemClick5() {
        this.isItemSelected5 = false;
        this.isComboBoxVisible5 = true;
        this.disableButton = true;
        this.paramString = "";

    }

    CloseDialogBox1(event) {
        this.showDialogBox1 = false;
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.paramString = "";
        this.isModalOpen = false;
        this.ShowComboBox = false;
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.showObjects = true;
        this.isComboBoxVisible1 = true;
        this.endLevel = "";
        this.boxOneIcon = false;
        this.isItemSelected1 = false;
        this.isDisable = true;
        this.buttonDisbaled = false;
        this.selectedValue1 = false;
        this.searchTerm = "";
        this.searchTerm1 = "";

    }

    resetModal() {
        console.log("reset mode");
        this.paramString = "";
        this.isModalOpen = false;
        this.showParentObjects = true;
        this.buttonParentDisabled = false;
        this.ShowComboBox = true;
        console.log("reset child", this.ShowComboBox);
        this.showChildFields = false;
        console.log("showChildFields", this.showChildFields);
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.showObjects = true;
        this.isComboBoxVisible1 = true;
        this.endLevel = "";
        this.boxOneIcon = false;
        this.isItemSelected1 = false;
        this.isDisable = true;
        this.buttonDisbaled = false;
        this.selectedValue1 = false;
        this.searchTerm = "";
        this.searchTerm1 = "";
        this.connectedCallback();
        console.log("connected");

    }

    submitDetails() {

        let data = this.template.querySelectorAll('.selectedValue');
        var comValues = [];
        var strValues = '';

        for (var i = 0; i < data.length; i++) {
            console.log(" data length -----> ", data.length);
            if (data[i].innerText != 'undefined')
                if (i == data.length - 1) {
                    strValues += data[i].innerText;
                } else {
                    strValues += data[i].innerText + '.';
                }
            comValues[i] = strValues;

        }

        let modifiedStatement = strValues.replace(/Id/g, '');

        this.contactUpdateList.push(modifiedStatement);

        this.showTableBox = true;
        this.isModalOpen = false;
        this.ShowComboBox = false;
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.showObjects = true;
        this.selectedValue = null;
        this.isComboBoxVisible = true;
        this.boxIcon = false;
        this.isItemSelected = false;
    }


    copyFields() {

        let msg = this.paramString;

        if (navigator.clipboard && window.isSecureContext) {
            return navigator.clipboard.writeText(msg);
        } else {
            const event = new ShowToastEvent({
                message: 'Field copied successfully!',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            let textArea = document.createElement("textarea");
            textArea.value = msg;
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            textArea.style.top = "-999999px";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();

            return new Promise((res, rej) => {
                document.execCommand("copy") ? res() : rej();
                textArea.remove();
            });


        }
    }

    handleClick(event) {
        this.disableButton = true;
        this.ShowComboBox = false;
        this.ShowComboBox2 = false;
        this.ShowComboBox3 = false;
        this.ShowComboBox4 = false;
        this.ShowComboBox5 = false;
        this.showObjects = true;
        this.isComboBoxVisible = true;
        this.boxIcon = false;
        this.isItemSelected = false;
        this.paramString = "";



        if (this.allCombobox1.length === 0) {
        }
        else {
            this.allCombobox1 = [];
            this.allCombobox = [];
        }
        this.isModalOpen = true;

    }
    handleIconClick(event) {
        this.ShowComboBox = true;
    }

}