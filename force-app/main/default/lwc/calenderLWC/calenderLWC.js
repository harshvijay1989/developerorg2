import { LightningElement, track, wire, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';

import fetchEvents from '@salesforce/apex/FullCalendarService.fetchEvents';
import getManageExpenses from '@salesforce/apex/FullCalendarService.getManageExpenses';
import updateManageExpenses from '@salesforce/apex/FullCalendarService.updateManageExpenses';
import checkList from '@salesforce/apex/FullCalendarService.checkList';
import checkIn from '@salesforce/apex/FullCalendarService.checkIn';
import checkOut from '@salesforce/apex/FullCalendarService.checkOut';
import getEventData from '@salesforce/apex/FullCalendarService.getEventData';
import uploadFile from '@salesforce/apex/FullCalendarService.uploadFile'
import getRelatedFilesByRecordId from '@salesforce/apex/FullCalendarService.getRelatedFilesByRecordId'
import createNewEvent from '@salesforce/apex/FullCalendarService.createNewEvent';
import deleteEvent from '@salesforce/apex/FullCalendarService.deleteEvent';

import getTodayVisitedDealersOnDayEnd from '@salesforce/apex/ShowDealerLocationCtr.getTodayVisitedDealersOnDayEnd';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class CalenderLWC extends NavigationMixin(LightningElement) {
//export default class CalenderLWC extends LightningElement {
    //To avoid the recursion from renderedcallback
    fullCalendarJsInitialised = false;


 dayStartAddress;
    dayEndAddress;

    enableAllButton = true;
    form_factor = FORM_FACTOR;
    todayEndDayVisiDealerList = [];
    @track isMobile;
    openEndDayPopup = false;

    endDayHandler(event) {
      //  alert('test');
        this.openEndDayPopup = true;

        getTodayVisitedDealersOnDayEnd()
            .then((result) => {
             //   alert('test'+JSON.stringify(result));
                this.todayEndDayVisiDealerList = result;
               
            })
            .catch((error) => {
                this.error = error;
                this.allExpenses = undefined;
            });
    }


    onEndDayClick() {
        this.openEndDayPopup = false;
        const event = new ShowToastEvent({
            title: 'End Day',
            message: 'Your Day is Ended',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


    endDayPopup() {
        this.openEndDayPopup = false;

    }

    //Fields to store the event data -- add all other fields you want to add
    title;
    value;
    billingCity;
    startDate;
    endDate;
    @api recordId;
    filesList = []
    @track disableCheckIn = false;
    @track disableCheckOut = false;
    checkindateTimeValue;
    checkoutdateTimeValue;
    rotplnIdList = [];
    checkOutLog;
    checkOutLat;
    checkInLong;
    checkInLat;
    checkInDone;
    checkOutDone;
    amount;
    getfile;
     buTypeValidation = false;
    amountDone = false;
    eventsRendered = false;//To render initial events only once
    openSpinner = false; //To open the spinner in waiting screens
    showLoading = false;
    openModal = false; //To open form
    openModalDealer = false;//To open check-in and check-out 
    @track routPlaneId;
    rootplaneidforloockup;
    rootplaneidforloockupID;
    rootplaneidforlockupValue;
    rootplaneidforlockupValueID;
    @track events = []; //all calendar events are stored in this field
    getEventAllData;
    @track showLoadingSpinner = false;
    @api selectedRecordId;
    @api selectedAccountId;
    @api selectedRoutePlaneId;
    @api selectedRoutePlaneRecordId;

    showAllCalendar = false;
    @api name;
    dealerName;
    dealerStreet = '';
    dealerCity = '';
    visitDateDesable = true;
    Done;
    delervisitedDate;
    openmanagExpense = false;
    popup = true;
    getVisDate;
    upExpenses;
    dealVisitCmtMddt;
    checkINDate;
    @track toastMessage = '';

    //  dealr;
    //To store the orignal wire object to use in refreshApex method
    //@api recordId;

    expAllamount;
    fileData
    handleAccountSelection(event) {
        this.selectedAccountId = event.detail;
        console.log("the selected record id is" + event.detail);
    }

    /*
    Expense Detail Section 
    */
    @track index = 0;
    @track manageExpenseList = [];
    manageExpRecordIdList = [];
    desableAmt;
    desableCmt;
    @track idForFile;
    @track idForFile1;
    @track allExpenses = [];
    openFile = false;
    headerDate;
    Amount__c;
    Comment__c;
    Visit_Date__c;
    Id;
    currRowId;
  

    getExpAmount(event) {
        let foundelement = this.manageExpenseList.find(ele => ele.Id == event.target.dataset.id);
        foundelement.Amount__c = event.target.value;
        this.manageExpenseList = [...this.manageExpenseList];
    }

      getComment(event) {
        let foundelement = this.manageExpenseList.find(ele => ele.Id == event.target.dataset.id);
        foundelement.Comment__c = event.target.value;
        this.manageExpenseList = [...this.manageExpenseList];
    }
    /*
      @description open the modal by nullifying the inputs
     */
    addEvent(event) {
        this.startDate = null;
        this.endDate = null;
        this.title = null;
        this.openModal = true;
        this.popup = false;
        this.visitDateDesable = false;
        const body = document.body;
        body.style.height = '100vh';
        body.style.overflowY = 'hidden';
    }

     CancelShowFile() {
        this.openFile = false;
        this.openmanagExpense = true;


    }

 showFile(event) {
        this.idForFile1 = event.currentTarget.dataset.id;
        this.openFile = true;
        this.openmanagExpense = false;

        getRelatedFilesByRecordId({ recordId: this.idForFile1 })
            .then(result => {
                this.getfile = result;
                // alert('hello');
                console.log(this.getfile);
                // alert('hello');
                this.filesList = Object.keys(this.getfile).map(item => ({
                    "label": this.getfile[item],
                    "value": item,
                    "url": `/sfc/servlet.shepherd/document/download/${item}`
                }))
                console.log('file list' + this.filesList)
            })
            .catch(error => {
                this.error = error;
            });
    }
    managExpense1(event) {
        //this.openmanagExpense = true;
        // managExpense()
    }


    managExpense(event) {
        this.openmanagExpense = true;
        this.popup = false;
        const body = document.body;
        body.style.height = '100vh';
        body.style.overflowY = 'hidden';
        //alert(this.rootplaneidforlockupValueID);
        getManageExpenses({ rootID: this.rootplaneidforlockupValueID })
            .then((result) => {

                this.manageExpenseList = result;

                //this.allExpenses = JSON.parse(JSON.stringify(result));
                console.log('ManageExpense', JSON.parse(JSON.stringify(this.allExpenses)));
                const monthNames = ["January", "February", "March", "April", "May", "June",
                    "July", "August", "September", "October", "November", "December"
                ];

                //const d = new Date();
                //document.write("The current month is " + monthNames[d.getMonth()]);
                var currentdate = new Date();
                var dateHeader = " " + (monthNames[currentdate.getMonth()]) + " "
                    + currentdate.getFullYear() + " "

                this.headerDate = dateHeader;
                this.error = undefined;
            })

            .catch((error) => {
                this.error = error;
                this.allExpenses = undefined;
            });


    }
    cancleManageExpenses(event) {
        this.openmanagExpense = false;
        this.manageExpenseList = '';
        this.popup = true;


    }
    SaveManageExpenses(event) {
        console.log(this.manageExpenseList);
        updateManageExpenses({ toupdate: this.manageExpenseList })
            .then((result) => {
                this.upExpenses = result;
                this.openmanagExpense = false;
                this.popup = true;
                if (this.upExpenses = 'toupdateDone') {
                    window.location.reload();
                    this.showToast('Success', 'Successfully Saved.', 'Success', 'dismissable');
                }
                else if (this.upExpenses = 'toupdateNotDone') {
                     window.location.reload();
                    this.showToast('Error SomeThing Went Wrong', 'Record Not Saved.', 'Error', 'dismissable');

                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.upExpenses = undefined;
                this.showToast('Error SomeThing Went Wrong', error.body.pageErrors[0].message, 'Error', 'dismissable');

            });
    }
    getVisitdate(event) {
        this.getVisDate = event.target.value;
        console.log(this.getVisDate);

    }

    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.routPlaneId,
                'amount': this.expAllamount
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }

    expAmount(event) {
        this.expAllamount = event.target.value;
    }
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
    }

    handleUploadFinished(event) {

    }
  
    previewHandler(event) {
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }
    handleClickSubmit() {
        // this.casesSpinner = true;
        // alert(this.casesSpinner);
        const { base64, filename, recordId, amount } = this.fileData
        uploadFile({ base64, filename, recordId, amount }).then(result => {
            //  this.amount = '';
            this.amountDone = true;
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })

    }
    visitedDateEvent(event) {
        this.startDate = event.target.value;
        //alert(this.startDate);
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }
    eventOriginalData = [];
    connectedCallback() {
        this.handleEvents();
        //this.managExpense();
    }

    activeSections = ['tutorialW3web'];
    activeSectionsMessage = '';

    toggleSectionHandleW3web(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
    handleEvents() {
        fetchEvents()
            .then(result => {
                console.log('Result:-', result);
                this.eventOriginalData = result; //To use in refresh cache

                let eventss = [];
                this.eventOriginalData.forEach(lad => {
                     console.log('let string hoc 338===>',lad);
                    if (lad.Dealer_Name__c != '' && lad.Dealer_Name__c != null && lad.Dealer_Name__c !== undefined) {
                        console.log('let string hoc 340===>',lad);

                         if (lad.Route_Plan__r.Name != '' && lad.Route_Plan__r.Name != null && lad.Route_Plan__r.Name != undefined) {
                            this.rotplnIdList.push(JSON.parse(JSON.stringify({
                                rootplaneidforloockup: lad.Route_Plan__r.Name,
                                rootplaneidforloockupID: lad.Route_Plan__r.Id,
                            })))
                          
                        }
                        var holiday = false;
                       
                        console.log('holiday' + lad.Visit_Date__c);
                        var holiday = false;

                        if (lad.Visit_Date__c != null) {
                            const date2 = new Date(lad.Visit_Date__c);
                            holiday = date2.getDay() == 0 || date2.getDay() == 6;
                        }
                        if (holiday) {
                            this.events.push(JSON.parse(JSON.stringify({
                                id: lad.Id,
                                title: lad.Dealer_Name__r.Name,
                                start: lad.Visit_Date__c,
                                billingCity: lad.Dealer_Name__r.BillingCity,
                                billingStreet: lad.Dealer_Name__r.BillingStreet,
                                backgroundColor: "rgb(230,167,119)"
                            })))
                        } else if (lad.Ad_hoc_visit__c == true) {
                            console.log('let string hoc 367===>', lad);
                            this.events.push(JSON.parse(JSON.stringify({
                                id: lad.Id,
                                title: lad.Dealer_Name__r.Name,
                                start: lad.Visit_Date__c,
                                billingCity: lad.Dealer_Name__r.BillingCity,
                                billingStreet: lad.Dealer_Name__r.BillingStreet,
                                backgroundColor: "rgba(25, 39, 230, 0.774)"


                            })))
                        }
                        else {
                            this.events.push(JSON.parse(JSON.stringify({
                                id: lad.Id,
                                title: lad.Dealer_Name__r.Name,
                                start: lad.Visit_Date__c,
                                billingCity: lad.Dealer_Name__r.BillingCity,
                                billingStreet: lad.Dealer_Name__r.BillingStreet,
                                backgroundColor: " rgb(0, 128, 0)"

                            })))
                        }
                       
                    }
                })

                console.log(JSON.parse(JSON.stringify(this.events)));
                this.rootplaneidforlockupValue = this.rotplnIdList[0].rootplaneidforloockup;
                this.rootplaneidforlockupValueID = this.rotplnIdList[0].rootplaneidforloockupID;
                // alert(this.rootplaneidforlockupValueID);

                console.log('route', this.events[0].rootplaneidforloockup);
                //  console.log(this.events[0].title);
                // console.log(this.events[0].start);
                this.error = undefined;

                // if events are not rendered, try to remove this 'if' condition and add directly 
                if (!this.eventsRendered) {
                    //Add events to calendar
                    const ele = this.template.querySelector("div.fullcalendarjs");
                    $(ele).fullCalendar('renderEvents', JSON.parse(JSON.stringify(this.events)), true);
                    this.eventsRendered = true;
                }
            })
            .catch(error => {
                this.events = [];
                this.error = 'No events are found';
            });
    }

    /*
    Check List Section    
        */
    q1;
    q2;
    q3;
    question1;
    question2;
    question3
    checkListData;
    CheckData;

    checkListId;
    q1value(event) {
        this.q1 = event.target.value;
    }
    q2value(event) {
        this.q2 = event.target.value;
    }
    q3value(event) {
        this.q3 = event.target.value;
    }

    SaveCheckList(event) {
              console.log('CheeckinClicked');
               console.log('q1',this.q1);
                console.log('q2',this.q2);
                 console.log('q3',this.q3);
                  console.log('routPlaneId',this.routPlaneId);
        checkList({ q1: this.q1, q2: this.q2, q3: this.q3, routPlanActId: this.routPlaneId})
            .then((result) => {
                this.checkListData = result;
                this.openModalDealer = false;
                this.popup = true;
                console.log(this.checkListData);

                if (this.checkListData == 'checkListDone') {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Successfully Save',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else if (this.checkListData == 'checkListNotDone') {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Not Save',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);

                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.upExpenses = undefined;
            });
    }


    /**
     * Load the fullcalendar.io in this lifecycle hook method
     */
    renderedCallback() {
        // Performs this operation only on first render
        if (this.fullCalendarJsInitialised) {
            return;
        }
        this.fullCalendarJsInitialised = true;

        // Executes all loadScript and loadStyle promises
        // and only resolves them once all promises are done
        Promise.all([
            loadScript(this, FullCalendarJS + "/FullCalendarJS/jquery.min.js"),
            loadScript(this, FullCalendarJS + "/FullCalendarJS/moment.min.js"),
            loadScript(this, FullCalendarJS + "/FullCalendarJS/fullcalendar.min.js"),
            loadStyle(this, FullCalendarJS + "/FullCalendarJS/fullcalendar.min.css"),
        ])
            .then(() => {
                //initialize the full calendar
                this.initialiseFullCalendarJs();
            })
            .catch((error) => {
                console.error({
                    message: "Error occured on FullCalendarJS",
                    error,
                });
            });
    }

    initialiseFullCalendarJs() {
        const ele = this.template.querySelector("div.fullcalendarjs");
        const modal = this.template.querySelector('div.modalclass');
        console.log(FullCalendar);
        var self = this;

        //To open the form with predefined fields
        //TODO: to be moved outside this function
        function openActivityForm(startDate, endDate) {
            self.startDate = startDate;
            self.endDate = endDate;
            self.openModal = true;
            self.popup = false;
            const body = document.body;
            body.style.height = '100vh';
            body.style.overflowY = 'hidden';

        }

        //Actual fullcalendar renders here - https://fullcalendar.io/docs/v3/view-specific-options
        $(ele).fullCalendar({
            header: {
                left: " ",
                center: "title",
                right: " ",
            },
            //   defaultDate: new Date(), // default day is today - to show the current date
            defaultView: 'month', //To display the default view - as of now it is set to week view
            navLinks: false, // can click day/week names to navigate views
            // editable: true, // To move the events on calendar - TODO 
            selectable: true, //To select the period of time

            //To select the time period : https://fullcalendar.io/docs/v3/select-method
            select: function (startDate, endDate) {
                let stDate = startDate.format();
                let edDate = endDate.format();

                openActivityForm(stDate, edDate);
            },
            eventClick: function (event, jsEvent, view) {
                //alert('Event Clicked ' + event.id)
                self.routPlaneId = event.id;
                //alert(self.routPlaneId);
                self.checkindateTimeValue = null;
                self.checkoutdateTimeValue = null;
                self.showLoadingSpinner = true;

                getEventData({ routPlaneId: self.routPlaneId })
                    .then(result => {
                        //this.getEventAllData = result;
                        //console.log(this.getEventAllData);
                        result.forEach(wraperData => {
                            self.getEventAllData = wraperData.rotPlanActList;
                            self.CheckData = wraperData.rotPlanActList;
                            console.log(self.CheckData);
                            /*
                            console.log('RoutList', contact.rotPlanActList);
                            console.log('MDDT', contact.dealVisitCmtList);
                            */

                        })
                        self.CheckData.forEach(chList => {
                            if (chList.Question1__c != null && chList.Question1__c != '' && chList.Question1__c != undefined) {
                                self.question1 = chList.Question1__c;
                            }
                            if (chList.Question2__c != null && chList.Question2__c != '' && chList.Question2__c != undefined) {
                                self.question2 = chList.Question2__c;
                            }
                            if (chList.Question3__c != null && chList.Question3__c != '' && chList.Question3__c != undefined) {
                                self.question3 = chList.Question3__c;
                            }
                            if (chList.Id != null) {
                                self.checkListId = chList.Id;
                            }
                             if (chList.Activity_Done__c != null && chList.Activity_Done__c != '' && chList.Activity_Done__c != undefined) {
                                self.buTypeValidation = chList.Activity_Done__c;
                            }


                        })
                        self.getEventAllData.forEach(evtdata => {
                            //alert()
                            self.openModalDealer = true;
                            self.popup = false;
                            const body = document.body;
                            console.log('body', body)
                            body.style.height = '100vh';
                            body.style.overflowY = 'hidden';
                            // alert(evtdata.CheckInLocation__Longitude__s);
                            // alert(evtdata.CheckInLocation__Latitude__s);
                            self.showLoadingSpinner = false;
                            if (evtdata.Dealer_Name__r.Name != null && evtdata.Dealer_Name__r.Name != undefined && evtdata.Dealer_Name__r.Name != '') {
                                self.dealerName = evtdata.Dealer_Name__r.Name;
                                self.buTypeValidation = true;

                            } if (evtdata.Dealer_Name__r.BillingStreet != undefined && evtdata.Dealer_Name__r.BillingStreet != null && evtdata.Dealer_Name__r.BillingStreet != '') {
                                self.dealerStreet = evtdata.Dealer_Name__r.BillingStreet;
                                //alert(self.dealerStreet);
                            } if (evtdata.Dealer_Name__r.BillingCity != null && evtdata.Dealer_Name__r.BillingCity != undefined && evtdata.Dealer_Name__r.BillingCity != '') {
                                self.dealerCity = evtdata.Dealer_Name__r.BillingCity;
                                // alert(self.dealerCity);
                            } if (evtdata.Visit_Date__c != null && evtdata.Visit_Date__c != '' && evtdata.Visit_Date__c != undefined) {
                                self.delervisitedDate = evtdata.Visit_Date__c;
                                //alert(self.delervisitedDate);

                            }

                            if (evtdata.CheckInDateTime__c != '' && evtdata.CheckInLocation__Longitude__s != '' && evtdata.CheckInLocation__Latitude__s != '' && evtdata.CheckInDateTime__c != undefined) {
                                self.disableCheckIn = true;
                                self.checkInLat = evtdata.CheckInLocation__Latitude__s;
                                self.checkInLong = evtdata.CheckInLocation__Longitude__s
                                // alert(self.checkInLat);
                                self.checkInLog = evtdata.CheckInLocation__longitude__s;
                                if (evtdata.CheckInDateTime__c) {

                                    let dt = new Date(evtdata.CheckInDateTime__c);
                                    evtdata.CheckInDateTime__c = new Intl.DateTimeFormat('en-GB').format(dt);

                                }
                                //alert('i am checkINDate');
                                /* var currentdate = new date(evtdata.CheckInDateTime__c);
                                 // alert(currentdate);
                                 console.log('currentdate', currentdate);
                                 const datetimecheckin = " " + currentdate.getDate() + "/"
                                     + (currentdate.getMonth() + 1) + "/"
                                     + currentdate.getFullYear() + " "
                                 //alert(datetimecheckin);
                                 comsole.log('datetimecheckin', datetimecheckin);*/
                                // self.checkindateTimeValue = datetimecheckinData;
                                self.checkindateTimeValue = evtdata.CheckInDateTime__c;
                                //console.log('currentdate', self.checkindateTimeValue);

                            } if (evtdata.CheckOutDateTime__c != '' && evtdata.CheckOutLocation__Latitude__s != '' && evtdata.CheckOutLocation__Longitude__s != '' && evtdata.CheckOutDateTime__c != undefined) {
                                self.disableCheckOut = true;
                                self.checkoutdateTimeValue = evtdata.CheckOutDateTime__c;
                                self.checkOutLat = evtdata.CheckOutLocation__Latitude__s;
                                self.checkOutLog = evtdata.CheckOutLocation__Longitude__s;
                            } if (evtdata.Amount__c != '' && evtdata.Amount__c != undefined) {
                                //alert('hello');
                                self.amountDone = true;
                                self.amount = evtdata.Amount__c;

                            }
                        })

                    })

                    .catch(error => {
                        self.error = error;
                    });
            },
            eventLimit: true, // allow "more" link when too many events
            events: this.events, // all the events that are to be rendered - can be a duplicate statement here
        });
    }

    //TODO: add the logic to support multiple input texts
    handleKeyup(event) {
        this.title = event.target.value;
    }
    handleActivityName(event) {
        this.name = event.target.value;
    }
    handleValueSelctedRoutePlane(event) {
        this.selectedRoutePlaneRecordId = event.detail;
        console.log(this.selectedRoutePlaneRecordId);
    }
    //To close the modal form
    handleCancel(event) {
        this.openModal = false;
        this.popup = true;
        const body = document.body;
        const scrollY = body.style.top;
        body.style.position = '';
        body.style.top = '';
        body.style.height = '';
        body.style.overflowY = '';
        window.scrollTo(0, parseInt(scrollY || '0') * -1);
        this.visitDateDesable = true;
    }
    handleSaveEvent(event) {
        //alert(this.startDate);
        //alert(this.selectedRecordId);
        createNewEvent({ visitdate: this.startDate, delear: this.selectedAccountId, Name: this.name, routePlane: this.rootplaneidforlockupValueID })
            .then(result => {
                this.Done = result;
                this.openModal = false;
                if (this.Done == 'Done') {

                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Successfully Save',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    
                   
                    this.dispatchEvent(evt);
                    this.openModal = false;
                    this.popup = true;
                    const body = document.body;
                    const scrollY = body.style.top;
                    body.style.position = '';
                    body.style.top = '';
                    body.style.height = '';
                    body.style.overflowY = '';
                    window.scrollTo(0, parseInt(scrollY || '0') * -1);
                     //alert('ok2');
                     window.location.reload();
                    //this.updateRecordView();
                    //  refreshApex(this.eventOriginalData);
                } else if (this.Done == 'NotDone') {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Not Save',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                     window.location.reload();
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.Done = undefined;
            });
            

    }
    //To close the dealer modal form
    handleCancelDealer(event) {
        this.toastMessage = '';
        this.popup = true;
        this.disableCheckIn = false;
        this.openModalDealer = false;
        const body = document.body;
        const scrollY = body.style.top;
        body.style.position = '';
        body.style.top = '';
        body.style.height = '';
        body.style.overflowY = '';
        window.scrollTo(0, parseInt(scrollY || '0') * -1);
        this.disableCheckOut = false;
        this.checkInLat = null;
        this.checkInLong = null;
        this.checkOutLat = null;
        this.checkOutLog = null;
        this.amount = null;
        this.amountDone = false;
        this.filesList = null;
        this.dealerStreet = null;
        this.dealerCity = null;
        this.delervisitedDate = null;
        this.question1 = null;
        this.question2 = null;
        this.question3 = null;
        this.checkListId = null;

    }

     handleCheckIn(event) {
        this.showLoadingSpinner = true;
      
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                
                this.showLoading = true;
                checkIn({ routPlaneId: this.routPlaneId, lat: latitude, lng: longitude })
                    .then(result => {
                        this.checkInDone = result;
                       
                        this.error = undefined;
                        if (this.checkInDone == 'alreadyCheckIn') {
                            this.disableCheckIn = true;
                           
                        }
                        else if (this.checkInDone == 'checkInNotDone') {
                            this.disableCheckIn = true;
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'Already checkIn',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        } else if (this.checkInDone == 'DisWarning') {
                        this.toastMessage = 'You have not reached the dealer location.';
                            const evt = new ShowToastEvent({
                                title: 'Warning',
                                message: 'You have not reached the dealer location.',
                                variant: 'Warning'
                            });
                            this.dispatchEvent(evt);
                        } 
                        else if (this.checkInDone == 'checkInDone') {
                             this.toastMessage = null;
                            this.disableCheckIn = true;

                            let dt = new Date();
                            let datetimecheckin = new Intl.DateTimeFormat('en-GB').format(dt);

                            this.checkindateTimeValue = datetimecheckin;
                            this.checkInLat = latitude;
                            this.checkInLong = longitude
                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: 'Successfully checkIn',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                    })
                    .catch(error => {
                        this.error = error;
                        this.checkDone = undefined;
                    });
            })
        }
     this.showLoadingSpinner = false;
    }


    handleCheckInDMSOld(event) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
              
                this.showLoading = true;
                checkIn({ routPlaneId: this.routPlaneId, lat: latitude, lng: longitude })
                    .then(result => {
                        this.checkInDone = result;
                        
                        this.error = undefined;
                        if (this.checkInDone == 'alreadyCheckIn') {
                            this.disableCheckIn = true;
                            //alert(this.checkDone);
                        }
                        else if (this.checkInDone == 'checkInNotDone') {
                            this.disableCheckIn = true;
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'Already checkIn',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        } else if (this.checkInDone == 'checkInDone') {
                            this.disableCheckIn = true;
                            // alert('hello');
                            // refreshApex(this.getEventAllData);

                            let dt = new Date();
                            let datetimecheckin = new Intl.DateTimeFormat('en-GB').format(dt);

                            this.checkindateTimeValue = datetimecheckin;
                            this.checkInLat = latitude;
                            this.checkInLong = longitude
                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: 'Successfully checkIn',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }


                    })
                    .catch(error => {
                        this.error = error;
                        this.checkDone = undefined;
                    });

            })
        }
    }
    handleCheckOut(event) {
        // alert(this.routPlaneId);
        // alert('click');
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                //   alert('lat' + latitude);
                // alert('long' + longitude);
                checkOut({ routPlaneId: this.routPlaneId, lat: latitude, lng: longitude })
                    .then(result => {
                        this.checkOutDone = result;
                        //alert('i am in result');
                        this.error = undefined;
                        if (this.checkOutDone == 'checkOutDone') {
                            this.disableCheckOut = true;
                            //alert(this.checkDone);
                            var currentdate = new Date();

                            var datetimecheckout = " " + currentdate.getDate() + "-"
                                + (currentdate.getMonth() + 1) + "-"
                                + currentdate.getFullYear() + " "
                                + currentdate.getHours() + " : "
                                + currentdate.getMinutes() + " : "
                                + currentdate.getSeconds();
                          
                            this.checkoutdateTimeValue = datetimecheckout;
                            this.checkOutLat = latitude;
                            this.checkOutLog = longitude;
                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: 'Successfully checkOut',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                        else if (this.checkOutDone == 'checkOutNotDone') {
                            this.disableCheckOut = true;
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'Already checkOut',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                    })
                    .catch(error => {
                        this.error = error;
                        this.checkOutDone = undefined;
                    });
            })
        }
    }

    //To save the event
    handleSave(event) {
        let events = this.events;
        //get all the field values - as of now they all are mandatory to create a standard event
        //TODO- you need to add your logic here.
        this.template.querySelectorAll('lightning-input').forEach(ele => {
            if (ele.name === 'title') {
                this.title = ele.value;
            }
            if (ele.name === 'start') {
                this.startDate = ele.value.includes('.000Z') ? ele.value : ele.value + '.000Z';
            }
            if (ele.name === 'end') {
                this.endDate = ele.value.includes('.000Z') ? ele.value : ele.value + '.000Z';
            }
        });

        //format as per fullcalendar event object to create and render
        let newevent = { title: this.title, start: this.startDate, end: this.endDate };
        console.log(this.events);

        //Close the modal
        this.openModal = false;
        const body = document.body;
        const scrollY = body.style.top;
        body.style.position = '';
        body.style.top = '';
        body.style.height = '';
        body.style.overflowY = '';
        window.scrollTo(0, parseInt(scrollY || '0') * -1);
        //Server call to create the event
        createEvent({ 'event': JSON.stringify(newevent) })
            .then(result => {
                const ele = this.template.querySelector("div.fullcalendarjs");

                //To populate the event on fullcalendar object
                //Id should be unique and useful to remove the event from UI - calendar
                newevent.id = result;

                //renderEvent is a fullcalendar method to add the event to calendar on UI
                //Documentation: https://fullcalendar.io/docs/v3/renderEvent
                $(ele).fullCalendar('renderEvent', newevent, true);

                //To display on UI with id from server
                this.events.push(newevent);

                //To close spinner and modal
                this.openSpinner = false;

                //show toast message
                this.showNotification('Success!!', 'Your event has been logged', 'success');

            })
            .catch(error => {
                console.log(error);
                this.openSpinner = false;
                //show toast message - TODO 
                this.showNotification('Oops', 'Something went wrong, please review console', 'error');
            })
    }

    /**
     * @description: remove the event with id
     * @documentation: https://fullcalendar.io/docs/v3/removeEvents
     */
    removeEvent(event) {
        //open the spinner
        this.openSpinner = true;

        //delete the event from server and then remove from UI
        let eventid = event.target.value;
        deleteEvent({ 'eventid': eventid })
            .then(result => {
                console.log(result);
                const ele = this.template.querySelector("div.fullcalendarjs");
                console.log(eventid);
                $(ele).fullCalendar('removeEvents', [eventid]);

                this.openSpinner = false;

                //refresh the grid
                return refreshApex(this.eventOriginalData);

            })
            .catch(error => {
                console.log(error);
                this.openSpinner = false;
            });
    }


    /**
     *  @description open the modal by nullifying the inputs
     */
    addEvent(event) {
        this.startDate = null;
        this.endDate = null;
        this.title = null;
        this.openModal = true;
        this.popup = false;
        this.visitDateDesable = false;
        const body = document.body;
        body.style.height = '100vh';
        body.style.overflowY = 'hidden';
    }

    /**
     * @description method to show toast events
     */
    showNotification(title, message, variant) {
        console.log('enter');
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    updateRecordView() {
       setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 1000); 
    }
    showToast(title, message, variant, mode) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

     openMapDirectionsPopup = false;
    mapDirectionsHandler(event) {
        this.openMapDirectionsPopup = true;
    }
    mapDirectionsHandlerEnd(event) {
        this.openMapDirectionsPopup = false;
    }
}