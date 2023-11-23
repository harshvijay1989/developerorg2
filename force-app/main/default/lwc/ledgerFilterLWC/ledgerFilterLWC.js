import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLedgerData from '@salesforce/apex/LedgerHelperClass.getLedgerData';
import getLedgerFilterData from '@salesforce/apex/LedgerHelperClass.getLedgerFilterData';
export default class LedgerFilterLWC extends LightningElement {


    @track columns = [
        { label: 'Customer Name', fieldName: 'Name', sortable: true, initialWidth: 150 },
        { label: 'Customer Code', fieldName: 'Customer__c', sortable: true, initialWidth: 150 },
        {
            label: 'Posting Date', fieldName: 'Posting_Date__c', sortable: true, type: 'date', typeAttributes: {
                day: "numeric",
                month: "numeric",
                year: "numeric"
            }, initialWidth: 150
        },
        {
            label: 'Document Date', fieldName: 'Document_Date__c', sortable: true, type: 'date', typeAttributes: {
                day: "numeric",
                month: "numeric",
                year: "numeric"
            }, initialWidth: 150
        },


        { label: 'Sales Organisation', fieldName: 'Sales_Organisation__c', sortable: true, initialWidth: 150 },

        { label: 'Profit Center', fieldName: 'Profit_Center__c', sortable: true, initialWidth: 150 },

        { label: 'Document Type', fieldName: 'Document_Type__c', sortable: true, initialWidth: 150 },

        { label: 'Document Number', fieldName: 'Document_Number__c', sortable: true },
        { label: 'Description(Narration)', fieldName: 'Description_Narration__c', sortable: true, initialWidth: 150 },

        { label: 'Invoice/Dr/Cr Number', fieldName: 'Invoice_Dr_Cr_Number__c', sortable: true, initialWidth: 150 },

        // { label: 'Amount', fieldName: 'Amount_in_local_Currency__c', sortable: true,  },
        { label: 'Dr.', fieldName: 'Debit_Note__c', sortable: true, initialWidth: 150 },
        { label: 'Cr.', fieldName: 'Credit_Note__c', sortable: true, initialWidth: 150 },

        { label: 'Accumulated Balance', fieldName: 'Accumulated_Balance__c', sortable: true, initialWidth: 150 },
        // { label: 'Local Currency', fieldName: 'Local_Currency__c', sortable: true,  },
        // { label: 'Text', fieldName: 'Text__c', sortable: true,  },

    ];
    @track amountTypeClosing;
    @track amountTypeOpening;
    @track startDateTime;
    @track endDateTime;
    @track ledgerList;
    @track dealerNameOptions;
    @track subDealersLoaded = false;
    @track openingBalance = 0;
    @track closingBalance = 0;
    @track debitNote = 0;
    @track creditNote = 0;
    @track isLoaded = false;
    @track noRecordsMessage = false;
    //@track showDMSUser = false;
    @track showSalesRepresentativeUser = false;
    //@track dmsAndSalesRepreName;
    @track salesRepresentativeSelectDealer = '';
    @track subdealerNameOptions;
    @track subDealerdisableButton = true;
    @track optionsOrganisation;
    @track allCustomerCode;
    @track optionvalue = '';
    @track subDealerCustomerCode = '';
    @track lastSelectedDealer;
    @track salesOrgnisationSelected = 'All';
    @track dealerOnChangeAll;
    accumulatedBalanceSecondRecord = 0;

    value = 'All';

    get salesOrgoptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'APL Apollo Tubes Limited', value: 'AATL' },
            { label: 'Apollo Metalex Private Limited', value: 'AMPL' },
            { label: 'Apollo Building Products Limited', value: 'ABPL' },
        ];
    }

    connectedCallback() {

        // var currentUrl = window.location.href;
        // console.log('currentUrl ==> ', currentUrl);
        //if (currentUrl.includes('site.com')) {
        //this.showDMSUser = true;
        this.isLoaded = true;
        //this.dmsAndSalesRepreName = 'DMS User';
        this.setDateFirstTime();
        this.showledgerRecords();
        //} 
        // else {
        //     this.isLoaded = true;
        //     this.dmsAndSalesRepreName = 'Sales Representative User';
        //     this.showSalesRepresentativeUser = true;
        //     this.setDateFirstTime();
        //     this.showledgerRecords();
        // }
    }

    setDateFirstTime() {
        var currentDate = new Date();
        var year = currentDate.toLocaleString("default", { year: "numeric" });
        var month = currentDate.toLocaleString("default", { month: "2-digit" });
        var day = currentDate.toLocaleString("default", { day: "2-digit" });

        var formattedDate = year + "-" + month + "-" + day;
        this.endDateTime = formattedDate;

        console.log('this.endDateTime =33=> ', this.endDateTime);

        var recDate = new Date(this.endDateTime);
        console.log('93--->' + recDate);

        var newDate = new Date(recDate.setDate(recDate.getDate() - 90));
        console.log('New Date 97-->' + newDate);
        var year = newDate.toLocaleString("default", { year: "numeric" });
        var month = newDate.toLocaleString("default", { month: "2-digit" });
        var day = newDate.toLocaleString("default", { day: "2-digit" });

        var formattedDate = year + "-" + month + "-" + day;
        this.startDateTime = formattedDate;
        console.log('this.startDateTime 46 => ', this.startDateTime);
    }
    @track countlength;
    showledgerRecords() {
      
        getLedgerData({ startDate: this.startDateTime, endDate: this.endDateTime })//, dmsAndSalesRepreName: this.dmsAndSalesRepreName })
            .then(result => {
               
                var openingBalanceCurrentUser = result.openingBalance;

                if (result.ledgerDataList != null || result.ledgerDataList != '') {
                    this.noRecordsMessage = false;
                    this.ledgerList = result.ledgerDataList;

                    //result.ledgerDataList[0].Accumulated_Balance__c = 0;

                    var accumulatedBalance = openingBalanceCurrentUser;
                    for (var key in result.ledgerDataList) {
                        console.log('result.ledgerDataList[key].Accumulated_Balance__c@@129', result.ledgerDataList[key].Accumulated_Balance__c);
                        if (result.ledgerDataList[key].Accumulated_Balance__c === undefined) {



                            console.log('accumulatedBalance 130 ==> ', accumulatedBalance);
                            if (result.ledgerDataList[key].Credit_Note__c != null) {
                                accumulatedBalance = parseFloat(accumulatedBalance) - parseFloat(result.ledgerDataList[key].Credit_Note__c);
                                console.log('openingBalanceCurrentUser@137==>', openingBalanceCurrentUser);
                                console.log('result.ledgerDataList[key].Credit_Note__c@@138==>', result.ledgerDataList[key].Credit_Note__c);
                                console.log('accumulatedBalance@139@@', accumulatedBalance);
                            }
                            if (result.ledgerDataList[key].Debit_Note__c != null) {
                                accumulatedBalance = parseFloat(accumulatedBalance) + parseFloat(result.ledgerDataList[key].Debit_Note__c);
                                console.log('openingBalanceCurrentUser@143==>', openingBalanceCurrentUser);
                                console.log('result.ledgerDataList[key].Credit_Note__c@@144==>', result.ledgerDataList[key].Debit_Note__c);
                                console.log('accumulatedBalance@118@@', accumulatedBalance);
                            }

                        }
                        result.ledgerDataList[key].Accumulated_Balance__c = accumulatedBalance;
                        console.log('accumulatedBalance@@@139', accumulatedBalance);
                        console.log('result.ledgerDataList[key].Accumulated_Balance__c@@140', result.ledgerDataList[key].Accumulated_Balance__c);
                        this.closingBalance = accumulatedBalance;
                        // if(accumulatedBalanc > 0){
                        //     console.log('accumulatedBalance@@@148', accumulatedBalance);
                        //     result.ledgerDataList[key].Accumulated_Balance__c = result.ledgerDataList[key].Accumulated_Balance__c - result.ledgerDataList[key].Credit_Note__c;
                        // }


                    }


                    console.log('this.ledgerList ===> ', JSON.stringify(this.ledgerList));
                }
                if (result.openingBalance != null && result.openingBalance != '' && result.openingBalance != undefined) {
                    this.openingBalance = result.openingBalance;
                } else {
                    this.openingBalance = 0;
                }
                //this.closingBalance = result.closingBalance;
                try {
                    let options = [];
                    // options.push({ label: '--None--',value: ''});
                    var customercode = 'undefined';
                    if (result.accDealerList.length > 1) {
                        for (var key in result.accDealerList) {

                            if (customercode != 'undefined') {
                                customercode += result.accDealerList[key].Customer_Code__c + '/';
                            }
                            else {
                                customercode = result.accDealerList[key].Customer_Code__c + '/';
                            }

                        }
                    } else {
                        for (var key in result.accDealerList) {

                            if (customercode != 'undefined') {
                                customercode += result.accDealerList[key].Customer_Code__c;
                            }
                            else {
                                customercode = result.accDealerList[key].Customer_Code__c;
                            }

                        }
                    }
                    this.allCustomerCode = customercode;
                    console.log('this.allCustomerCode ==> ', this.allCustomerCode);
                    console.log('customercode ==> ', customercode);
                    this.accDealerId = customercode;
                    this.dealerOnChangeAll = customercode;
                    console.log('this.accDealerId ==?> ', this.accDealerId);
                    options.push({ label: 'All', value: '' });
                     //console.log('result.accDealerList==233=>',result.accDealerList.length);
                    // if (result.accDealerList.length > 0 ) {
                    //     console.log('result.accDealerList==234=>',result.accDealerList);
                    //     console.log('dealer  found=====>');
                    //     for (var key in result.accDealerList) {
                            
                    //         this.subDealersLoaded = true;
                    //         console.log('hii ');

                    //         options.push({ label: result.accDealerList[key].Name, value: result.accDealerList[key].Customer_Code__c });
                    //         console.log('options =211=> ', JSON.stringify(options));

                    //     }
                    // }
                    // else{
                    //     console.log('result.accDealerList247=====>',result.accDealerList);
                    //     console.log('dealer not found=====>');
                    // }

                    this.dealerNameOptions = options;

                    console.log('this.dealerNameOptions ===> ', JSON.stringify(this.dealerNameOptions));
                    if (this.closingBalance > 0)
                        this.amountTypeClosing = 'Dr'
                    else {
                        this.amountTypeClosing = 'Cr';
                    }
                    if (this.openingBalance > 0)
                        this.amountTypeOpening = 'Dr'
                    else {
                        this.amountTypeOpening = 'Cr';
                    }

                } catch (error) {
                    console.error('check error here', error);
                }
                let tempRecords = JSON.parse(JSON.stringify(result.ledgerDataList));
                console.log('tempRecords', tempRecords);
                tempRecords = tempRecords.map(row => {
                    return { ...row, Name: row.Account__r.Name };
                })

                console.log('tempRecords', tempRecords);
                this.ledgerList = tempRecords;
                this.isLoaded = false;
            }).catch(error => {
                this.error = error;
                this.isLoaded = false;
            });

    }

    onStartDate(event) {
        // financialYearStartDate = new Date(new Date().getFullYear(), 0, 1);
        // console.log('financialYearStartDate====>',financialYearStartDate);
        console.log('####+==> ', event.detail.value);
        const selectedDate = event.target.value;

        if (selectedDate) {
            const inputDate = new Date(selectedDate);
            const aprilFirst = new Date(new Date().getFullYear(), 3, 1); // Month is 0-based (3 for April)

            if (inputDate < aprilFirst) {
                event.target.value = ''; // Reset the input value
                this.showErrorToast('Invalid Date', 'Please select a date on or after April 1st of current year');
            } else {
                this.startDateTime = event.detail.value;
            }
        }


    }
    onEndDate(event) {
        console.log('####+==> ', event.detail.value);
        this.endDateTime = event.detail.value;
    }
    handleSearchClick() {
      
        debugger;
        this.isLoaded = true;
     
        getLedgerFilterData({ startDate: this.startDateTime, endDate: this.endDateTime, accDealerId: '', customerIsAll: 'All', salesRepresentativeSelectDealer: this.salesRepresentativeSelectDealer, salesOrganisation: 'All'})
            .then(result => {
                console.log('result ==> ', result);
                console.log('result ==> 217', result.openingBalance);

                var openingBalanceCurrentUser = result.openingBalance;
                console.log('openingBalanceCurrentUser@@221', openingBalanceCurrentUser);

                if (result.ledgerDataList != null || result.ledgerDataList != '') {
                    this.ledgerList = result.ledgerDataList;

                    var accumulatedBalance = openingBalanceCurrentUser;
                    for (var key in result.ledgerDataList) {

                        console.log('result.ledgerDataList[key].Accumulated_Balance__c@@2222', result.ledgerDataList[key].Accumulated_Balance__c);
                        if (result.ledgerDataList[key].Accumulated_Balance__c === undefined) {

                            console.log('accumulatedBalance 225 ==> ', accumulatedBalance);
                            if (result.ledgerDataList[key].Credit_Note__c != null) {
                                accumulatedBalance = parseFloat(accumulatedBalance) - parseFloat(result.ledgerDataList[key].Credit_Note__c);
                                console.log('openingBalanceCurrentUser@228==>', openingBalanceCurrentUser);
                                console.log('result.ledgerDataList[key].Credit_Note__c@@229==>', result.ledgerDataList[key].Credit_Note__c);
                                console.log('accumulatedBalance@230@@', accumulatedBalance);
                            }
                            if (result.ledgerDataList[key].Debit_Note__c != null) {
                                accumulatedBalance = parseFloat(accumulatedBalance) + parseFloat(result.ledgerDataList[key].Debit_Note__c);
                                console.log('openingBalanceCurrentUser@234==>', openingBalanceCurrentUser);
                                console.log('result.ledgerDataList[key].Credit_Note__c@@235==>', result.ledgerDataList[key].Debit_Note__c);
                                console.log('accumulatedBalance@236@@', accumulatedBalance);
                            }

                        }
                        result.ledgerDataList[key].Accumulated_Balance__c = accumulatedBalance;
                        console.log('accumulatedBalance@@@241', accumulatedBalance);
                        console.log('result.ledgerDataList[key].Accumulated_Balance__c@@242', result.ledgerDataList[key].Accumulated_Balance__c);
                        this.closingBalance = accumulatedBalance;
                        // if(accumulatedBalanc > 0){
                        //     console.log('accumulatedBalance@@@148', accumulatedBalance);
                        //     result.ledgerDataList[key].Accumulated_Balance__c = result.ledgerDataList[key].Accumulated_Balance__c - result.ledgerDataList[key].Credit_Note__c;
                        // }


                    }
                }
                console.log('this.ledgerList 250 ===> ', JSON.stringify(this.ledgerList));
                if (this.ledgerList == null || this.ledgerList == '') {
                    console.log('hii');
                    this.noRecordsMessage = true;

                } else {
                    console.log('hii else');
                    this.noRecordsMessage = false;
                }

                this.openingBalance = result.openingBalance;
                //this.closingBalance = result.closingBalance;
                console.log('result.accSubDealerList 133 => ', result.accSubDealerList);
                // this.subdealerNameOptions = result.accSubDealerList;
                if (result.accSubDealerList != null) {
                    try {
                        let options = [];
                        options.push({ label: '--None--', value: '' });
                        var customercode = 'undefined';
                        for (var key in result.accSubDealerList) {
                            if (customercode != 'undefined') {
                                console.log('Second');
                                customercode += result.accSubDealerList[key].Customer_Code__c + '/';
                            }
                            else {
                                console.log('First');
                                customercode = result.accSubDealerList[key].Customer_Code__c + '/';
                            }
                        }
                        this.allCustomerCode = customercode
                        console.log('customercode ==> ', JSON.stringify(customercode));
                        options.push({ label: 'All', value: customercode });
                        for (var key in result.accSubDealerList) {

                            console.log('hii ');

                            options.push({ label: result.accSubDealerList[key].Name, value: result.accSubDealerList[key].Customer_Code__c });
                            console.log('options ==> ', options);

                        }
                        this.subdealerNameOptions = options;
                        console.log('this.dealerNameOptions ===> ', JSON.stringify(this.dealerNameOptions));
                        if (this.closingBalance > 0)
                            this.amountTypeClosing = 'Dr'
                        else {
                            this.amountTypeClosing = 'Cr';
                        }
                        if (this.openingBalance > 0)
                            this.amountTypeOpening = 'Dr'
                        else {
                            this.amountTypeOpening = 'Cr';
                        }

                    } catch (error) {
                        console.error('check error here', error);
                    }
                }
                let tempRecords = JSON.parse(JSON.stringify(result.ledgerDataList));
                console.log('tempRecords', tempRecords);
                tempRecords = tempRecords.map(row => {
                    return { ...row, Name: row.Account__r.Name };
                })

                console.log('tempRecords', tempRecords);
                this.ledgerList = tempRecords;
                this.isLoaded = false;
            }).catch(error => {
                this.error = error;
                this.isLoaded = false;
            });

    }

    handleSalesOrganisationChange(event) {
        this.salesOrgnisationSelected = event.target.value;
        this.handleSearchClick();
    }

    selectedOptions = [];

    handleDealerChange(event) {

        console.log('Dealer Name Id ==> ', JSON.stringify(event.detail));
        this.selectedOptions = event.detail;

        //this.accDealerId = event.detail;
        for (const key in this.selectedOptions) {
            console.log('394===>', `${key}: ${JSON.stringify(this.selectedOptions[key].value)}`);
            if (this.selectedOptions[key].value == "") {

                console.log('All All All');
                this.isLoaded = true;
                this.accDealerId = this.dealerOnChangeAll;
                this.customerIsAll = 'All';
                this.handleSearchClick();
                // alert(402)
            }
            else if (this.selectedOptions[key].value !== "") {
                //  alert(405)
                var result = this.selectedOptions.map(a => a.value);

                console.log('result==398==>' + JSON.stringify(result));
                this.accDealerId = result;
                console.log('this.accDealerId===403==>', this.accDealerId);
                this.isLoaded = true;

                this.customerIsAll = '';
                this.handleSearchClick();
            }
        }

        this.lastSelectedDealer = event.detail;



        // if (this.accDealerId) {

        //     this.isLoaded = true;
        //     // this.salesRepresentativeSelectDealer = '';
        //     this.customerIsAll = '';
        //     this.handleSearchClick();

        // }
        // else {

        //     console.log('All All All');
        //     this.isLoaded = true;
        //     this.accDealerId = this.dealerOnChangeAll;
        //     this.customerIsAll = 'All';
        //     // this.isLoaded = true;
        //     // this.subDealerdisableButton = true;
        //     this.handleSearchClick();
        // }
    }
    handleSubDealerChange(event) {
        console.log('Sub dealer customer code => ', event.detail.value);

        this.accDealerId = event.detail.value;
        if (this.accDealerId == '') {
            this.accDealerId = this.lastSelectedDealer;
        }
        console.log('this.accDealerId ==> ' + this.accDealerId);
        this.salesRepresentativeSelectDealer = '';
        this.handleSearchClick();
        //this.handleSearchClick() ;
    }
    showErrorToast(title, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(toastEvent);
    }

}