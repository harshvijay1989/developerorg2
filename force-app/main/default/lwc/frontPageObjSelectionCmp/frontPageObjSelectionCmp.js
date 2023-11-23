import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getObjectNames from '@salesforce/apex/SearchableComboObjectSelection_Handler.getObjectNames';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';

import quickActionModalCss from "@salesforce/resourceUrl/quickActionModalCss";
import { loadStyle } from "lightning/platformResourceLoader";


export default class frontPageObjSelectionCmp extends NavigationMixin(LightningElement) {
    picklistOrdered;
    @track searchResults = '';
    @track selectedSearchResult = '';
    @track selectedObjectName;
    wiredObjectNamesResult;

    @track isShowModal = true;

    // Variable to hold the timeout reference
    searchTimeout;


    documentTemplatesRecordId = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.documentTemplatesRecordId = currentPageReference.state?.c__recordId;
        }
    }

    // showModalBox() {
    //     this.isShowModal = true;
    // }
    // Inside your component class
    handleRefreshData() {
        return refreshApex(this.wiredData);
    }

    hideModalBox() {
        const inputField = this.template.querySelector('lightning-input');
        //alert(inputField);
        if (inputField) {
            inputField.value = '';
        }
        this.selectedObjectName = '';
        this.selectedSearchResult = '';
        this.searchResults = '';

        // Navigate to the list view
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
    get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.label : null;  
    }

    connectedCallback() {
        console.log('connected callback');
        loadStyle(this, quickActionModalCss);
        // getObjectNames()
        //     .then((result) => {
        //         console.log("connected");
        //         var temp = [];
        //         for (var i = 0; i < result.length; i++) {
        //             temp.push({ label: result[i].label, value: result[i].value });
        //         }
        //         this.picklistOrdered = temp;
        //         this.picklistOrdered = this.picklistOrdered.sort((a, b) => {
        //             if (a.label < b.label) {
        //                 return -1
        //             }
        //         })
        //     })
    }


    @wire(getObjectNames)
    wiredObjectNames(result) {
        try {
            this.wiredObjectNamesResult = result;
            console.log("wiredObjectNamesResult ", this.wiredObjectNamesResult);
            if (result.data) {
                this.picklistOrdered = result.data.map(item => ({ label: item.label, value: item.value }));
                this.picklistOrdered.sort((a, b) => a.label.localeCompare(b.label));
                this.refreshData();
            } else if (result.error) {
                // Handle error if needed
                console.error('error :', result.error);
            }
        } catch (e) {
            console.log('error------>', e);
        }

    }

    // Function to manually refresh the wired data
    refreshData() {
        console.log("refersh data ");
        return refreshApex(this.wiredObjectNamesResult);
    }

    search(event) {
        // Clear any previous timeouts
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout);
        }
        const input = event.detail.value.toLowerCase();

        // Set a new timeout to execute the search after a delay (e.g., 500 milliseconds)
        this.searchTimeout = setTimeout(() => {
            const result = this.picklistOrdered.filter((picklistOption) =>
                picklistOption.label.toLowerCase().includes(input)
            );
            this.searchResults = result;
        }, 200); // Adjust the delay time as needed
    }

    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedObjectName = selectedValue;
        this.selectedSearchResult = this.picklistOrdered.find(
            (picklistOption) => picklistOption.value === selectedValue
        );
        this.clearSearchResults();
    }

    clearSearchResults() {
        this.searchResults = null;
    }

    showPicklistOptions() {
        if (!this.searchResults) {
            this.searchResults = this.picklistOrdered;
        }
    }

    handleNextClick() {
        if (this.selectedObjectName == '' || this.selectedObjectName == null || this.selectedObjectName == undefined) {
            const event = new ShowToastEvent({
                message: 'Please Select Object',
                variant: 'Warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);

        } else {
            // this.isShowModal = false;
            // this.isEditorCmp = true; 
            this.handleNavigate();
        }
    }



    handleNavigate() {
        console.log('calling------------------');
        let state = {
            c__object: this.selectedObjectName
        } 

        if (this.documentTemplatesRecordId) {
            state['c__recordId'] = this.documentTemplatesRecordId;
        }
        console.log('tabing------------------');
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'ck_editor',
            },
            state
        });
        this.nullCombo();

    }


    nullCombo() {
        const inputField = this.template.querySelector('lightning-input');
        console.log('inputField', inputField);
        // alert(inputField);
        if (inputField) {
            inputField.value = '';
        }
    }
}