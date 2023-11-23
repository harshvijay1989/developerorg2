import { LightningElement, track, wire, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import fetchEvents from '@salesforce/apex/FullCalendarService2.fetchEvents';

import checkIn from '@salesforce/apex/FullCalendarService2.checkIn';
import checkOut from '@salesforce/apex/FullCalendarService2.checkOut';
import getEventData from '@salesforce/apex/FullCalendarService2.getEventData';
import deleteRouteplan from '@salesforce/apex/FullCalendarService2.deleteRouteplan';
import uploadFile from '@salesforce/apex/FullCalendarService2.uploadFile'
import getRelatedFilesByRecordId from '@salesforce/apex/FullCalendarService2.getRelatedFilesByRecordId'
import createTask from '@salesforce/apex/ManageRoutePlanActivities.createTask';
import updateBeatPlan from '@salesforce/apex/ManageRoutePlanActivities.updateBeatPlan';
import getTasks from '@salesforce/apex/ManageRoutePlanActivities.getTasks';
import getRoutePlanDetails from '@salesforce/apex/ManageRoutePlanActivities.getRoutePlanDetails';
import getBeatPlanMatrix from '@salesforce/apex/ManageRoutePlanActivities.getBeatPlanMatrix';
import getBeatGroup from '@salesforce/apex/ManageRoutePlanActivities.getBeatGroup';
import { NavigationMixin } from 'lightning/navigation';
import UserId from '@salesforce/user/Id';
//Added by Uday
import saveRoutePlans from '@salesforce/apex/ManageRoutePlanActivities.saveRoutePlans';
import saveForGroup from '@salesforce/apex/ManageRoutePlanActivities.saveForGroup';


//import createEvent from '@salesforce/apex/FullCalendarService2.createEvent';
import createNewEvent from '@salesforce/apex/FullCalendarService2.createNewEvent';
import deleteEvent from '@salesforce/apex/FullCalendarService2.deleteEvent';
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

/**
 * @description: FullcalendarJs class with all the dependencies
 */
export default class Calendar2 extends NavigationMixin(LightningElement) {
    //To avoid the recursion from renderedcallback
    fullCalendarJsInitialised = false;

    //Fields to store the event data -- add all other fields you want to add
    title;
    value;
    startDate;
    endDate;
    @api recordId;
    filesList = []
    @track disableCheckIn = false;
    @track disableCheckOut = false;
    checkindateTimeValue;
    checkoutdateTimeValue;
    checkOutLog;
    checkOutLat;
    checkInLong;
    checkInLat;
    checkInDone;
    checkOutDone;
    eventsRendered = false;//To render initial events only once
    openSpinner = false; //To open the spinner in waiting screens
    showLoading = false;
    openModal = false; //To open form
    openModalDealer = false;//To open check-in and check-out 
    @track routPlaneId;
    events = []; //all calendar events are stored in this field
    getEventAllData;
    @track showLoadingSpinner = false;
    @api selectedRecordId;
    @api selectedAccountId;
    @api selectedRoutePlaneId;
    @api selectedRoutePlaneRecordId;
    @api name;
    Done;
    status;
    openmodelConfirmation = false;
    disabled = false;
    showError = false;
    comments;
    @track finalmsgDisplay = [];
    ismodeforError = false;
    showSubmit = false;
    showWaitingMsg = false;

    showApproveReject = false;
    defaultdatetoset;
    userId = UserId;
    //Added by Uday
    @track disablecomments = true;
    lstDealers = [];
    isshow = false;
    inputdate;
    beatPlans = [];
    BeatGroup = [];
    selectedChecks = [];
    matricCheck = false;
    @track isModalOpen = false;
    @track isModalOpenForGrp = false;
    @api month;
    @api year;
    //  dealr;
    //To store the orignal wire object to use in refreshApex method
    //@api recordId;

    expAllamount;
    fileData

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {

        if (currentPageReference) {
            //alert(JSON.stringify(currentPageReference.state));
            // this.urlStateParameters = currentPageReference.state;
            //this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        //alert('before param : ' + this.recordId);
        //this.recordId = this.urlStateParameters.c__recordId || null;
        //this.month = this.urlStateParameters.c__Month || null;
        //this.year = this.urlStateParameters.c__Year || null;
    }

    handleAccountSelection(event) {
        this.selectedAccountId = event.detail;
        console.log("the selected record id is" + event.detail);
    }
    handleRoutePlaneSelection(event) {
        this.selectedRoutePlaneId = event.detail;
        console.log("the selected record id is" + event.detail);
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
    @wire(getRelatedFilesByRecordId, { recordId: '$routPlaneId' })
    wiredResult({ data, error }) {
        if (data) {
            console.log(data)
            this.filesList = Object.keys(data).map(item => ({
                "label": data[item],
                "value": item,
                "url": `/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList)
        }
        if (error) {
            console.log(error)
        }
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
            this.value = '';
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
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

        getTasks({ recordId: this.recordId }).then(result => {
            this.disabled = result;
        })
            .catch(error => { });

        //alert(this.recordId);
        getRoutePlanDetails({ recordId: this.recordId }).then(result => {
            if (result.Month__c != undefined && result.Year__c != undefined) {
                this.defaultdatetoset = result.Year__c + '-' + result.Month__c + '-01';
            }
            console.log('this.defaultdatetoset' + this.defaultdatetoset);
            console.log('result.Approval_Status__c' + result.Approval_Status__c);
           // alert(result.Approval_Status__c);
            if (result.Approval_Status__c == '' || result.Approval_Status__c == 'Update Needed' || result.Approval_Status__c == undefined || result.Approval_Status__c == 'Draft') {
                this.showSubmit = true;
            } else if (result.Approval_Status__c == 'Submitted') {
                this.showSubmit = false;
                //alert(result.ASM__c +' - '+this.userId)
                if (result.ASM__c == this.userId) {
                    this.showApproveReject = false;
                    this.showWaitingMsg = true;
                } else {
                    this.showWaitingMsg = false;
                    this.showApproveReject = true;
                }
            }
           
        })
            .catch(error => { console.log('error' + error); console.log('error1', error); });
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
        fetchEvents({ recordId: this.recordId })
            .then(result => {
                console.log('Result:-',result);
                this.events = [];
                this.eventOriginalData = result; //To use in refresh cache
                //console.log('Result Referse:-', this.eventOriginalData);
                let eventss = [];
                console.log('handle events ==> ',this.eventOriginalData);
                this.eventOriginalData.forEach(lad => {
                    console.log('lad.Dealer_Name__r ==> '+lad.Dealer_Name__r);
                    console.log('lad ==> ',lad);
                    
                    if (lad.Dealer_Name__r != '' && lad.Dealer_Name__r != null && lad.Dealer_Name__r !== undefined) {
                       console.log('Innnnn ==> ');
                        var holiday = false;
                       
                        console.log('holiday' + lad.Visit_Date__c);
                        var holiday = false;
                        if (lad.Visit_Date__c != null) {
                            const date2 = new Date(lad.Visit_Date__c);
                            holiday = date2.getDay() == 0 || date2.getDay() == 6;
                        }
                        console.log('holiday value ==>' + holiday);
                        console.log('lad==>' + lad);
                        console.log('lad.Ad_hoc_visit__c ==>' + lad.Ad_hoc_visit__c);
                        if (holiday) {
                            this.events.push(JSON.parse(JSON.stringify({
                                id: lad.Id,
                                title: lad.Dealer_Name__r.Name,
                                start: lad.Visit_Date__c,
                                backgroundColor: "rgb(230,167,119)",
                                billingCity: lad.Dealer_Name__r.BillingCity,
                                billingStreet: lad.Dealer_Name__r.BillingStreet
                            })))
                            console.log('Final Event If ==>'+JSON.parse(JSON.stringify(this.events))); 
                        } else if (lad.Ad_hoc_visit__c == true) {
                            this.events.push(JSON.parse(JSON.stringify({
                                id: lad.Id,
                                title: lad.Dealer_Name__r.Name,
                                start: lad.Visit_Date__c,
                                backgroundColor: "rgba(25, 39, 230, 0.774)",
                                billingCity: lad.Dealer_Name__r.BillingCity,
                                billingStreet: lad.Dealer_Name__r.BillingStreet

                            })))
             console.log('Final Event if Else 2 ==>'+JSON.parse(JSON.stringify(this.events))); 
                        }
                        else {
                            this.events.push(JSON.parse(JSON.stringify({
                                id: lad.Id,
                                title: lad.Dealer_Name__r.Name,
                                start: lad.Visit_Date__c,
                                backgroundColor: " rgb(0, 128, 0)",
                                billingCity: lad.Dealer_Name__r.BillingCity,
                                billingStreet: lad.Dealer_Name__r.BillingStreet
                            })))
          console.log('Final Event Else ==>'+JSON.parse(JSON.stringify(this.events)));  
                        }
                    }
                })
                console.log('Final Event Value==>'+JSON.parse(JSON.stringify(this.events)));
                console.log(this.events[0].id);
                console.log(this.events[0].title);
                console.log(this.events[0].start);
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
            //('openActivityForm');
            console.log('this.showSubmit' + self.showSubmit);
            self.startDate = startDate;
            self.endDate = endDate;
            //self.openModal = true;

            //alert('open popup');
            //alert('openActivityForm1'+self.showSubmit);
            if (self.showSubmit == true) {
                self.openModal = true;
            }
        }
        //Actual fullcalendar renders here - https://fullcalendar.io/docs/v3/view-specific-options

        $(ele).fullCalendar({
            header: {
                left: "",
                center: "title",
                right: "",
            },

            defaultDate: new Date(self.year + '-' + self.month + '-01'), // default day is today - to show the current date
            defaultView: 'month', //To display the default view - as of now it is set to week view
            navLinks: false, // can click day/week names to navigate views
            // editable: true, // To move the events on calendar - TODO 
            selectable: true, //To select the period of time
            longPressDelay: 1,
            //gotoDate :  new Date('2022-10-10') ,
            //To select the time period : https://fullcalendar.io/docs/v3/select-method
            select: function (startDate, endDate) {
                let stDate = startDate.format();
                let edDate = endDate.format();

                openActivityForm(stDate, edDate);
            },
            eventClick: function (event, jsEvent, view) {
                //alert('Event Clicked ' + event.id)
                self.routPlaneId = event.id;
                //  alert(self.routPlaneId);
                self.checkindateTimeValue = null;
                self.checkoutdateTimeValue = null;
                //self.showLoadingSpinner = true;
                getEventData({ routPlaneId: self.routPlaneId })
                    .then(result => {
                        this.getEventAllData = result;
                        console.log(this.getEventAllData);
                        result.forEach(evtdata => {
                            //alert('getEventData');
                            if (self.showSubmit == true) {
                                self.openModalDealer = true;
                            }

                            // alert(evtdata.CheckInLocation__Longitude__s);
                            // alert(evtdata.CheckInLocation__Latitude__s);
                            //self.showLoadingSpinner = false;
                            if (evtdata.CheckInDateTime__c != '' && evtdata.CheckInLocation__Longitude__s != '' && evtdata.CheckInLocation__Latitude__s != '' && evtdata.CheckInDateTime__c != undefined) {
                                self.disableCheckIn = true;
                                self.checkindateTimeValue = evtdata.CheckInDateTime__c;
                                self.checkInLat = evtdata.CheckInLocation__Latitude__s;
                                self.checkInLong = evtdata.CheckInLocation__Longitude__s
                                // alert(self.checkInLat);
                                self.checkInLog = evtdata.CheckInLocation__longitude__s;
                                // alert('i am ');
                            } if (evtdata.CheckOutDateTime__c != '' && evtdata.CheckOutLocation__Latitude__s != '' && evtdata.CheckOutLocation__Longitude__s != '' && evtdata.CheckOutDateTime__c != undefined) {
                                self.disableCheckOut = true;
                                self.checkoutdateTimeValue = evtdata.CheckOutDateTime__c;
                                self.checkOutLat = evtdata.CheckOutLocation__Latitude__s;
                                self.checkOutLog = evtdata.CheckOutLocation__Longitude__s;
                            }
                        })

                    })

                    .catch(error => {
                        this.error = error;
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
        this.openmodelConfirmation = false;
    }
    handleSaveEvent(event) {
        //alert(this.startDate);
        //alert(this.selectedRecordId);
        createNewEvent({ visitdate: this.startDate, delear: this.selectedAccountId, Name: this.name, routePlane: this.selectedRoutePlaneId })
            .then(result => {
                this.Done = result;
                if (this.Done == 'Done') {

                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Successfully Save',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.openModal = false;
                    //  refreshApex(this.eventOriginalData);
                } else if (this.Done == 'NotDone') {
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
            .catch(error => {
                this.error = error;
                this.Done = undefined;
            });

    }
    //To close the dealer modal form
    handleCancelDealer(event) {
        this.disableCheckIn = false;
        this.openModalDealer = false;
        this.disableCheckOut = false;
        this.checkInLat = null;
        this.checkInLong = null;
        this.checkOutLat = null;
        this.checkOutLog = null;

    }
    handleCheckIn(event) {
        //alert('click');
        // this.showLoading = true;
        // this.showLoadingSpinner = true;
        //alert(this.showLoading);
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                //  alert('lat' + latitude);
                //alert('long' + longitude);
                this.showLoading = true;
                checkIn({ routPlaneId: this.routPlaneId, lat: latitude, lng: longitude })
                    .then(result => {
                        this.checkInDone = result;
                        //  this.showLoadingSpinner=false;
                        // alert(this.checkInDone);
                        //alert('data');
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
                            var currentdate = new Date();
                           
                            this.checkindateTimeValue = currentdate;
                            this.checkInLat = latitude;
                            this.checkInLong = longitude


                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: 'Successfully checkIn',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);

                            // return refreshApex(this.);


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
                     
                            this.checkoutdateTimeValue = currentdate;
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

    SubmitRoutePlan() {
        //beatplans = [];
        var i = 0;
        this.finalmsgDisplay = [];
        getBeatPlanMatrix({ recordId: this.recordId })
            .then(result => {
                //beatplans = [];
                console.log('in method1111' + JSON.stringify(result));
                //beatplans = result;
                result.forEach(record => {
                    if (record.ActivityDates == undefined) {

                        if (record.Category == undefined) {
                            //this.finalmsgDisplay.push('Category is missing '+record.Name);
                        } else {
                            i = i + 1;
                            if (record.Category == 'Platinum') {
                                this.finalmsgDisplay.push(record.DealerName + ' is ' + record.Category + ' Category. Please add atleast 3 activities.');
                            } else if (record.Category == 'Gold') {
                                this.finalmsgDisplay.push(record.DealerName + ' is ' + record.Category + ' Category. Please add atleast 2 activities.');
                            } else if (record.Category == 'Silver') {
                                this.finalmsgDisplay.push(record.DealerName + ' is ' + record.Category + ' Category. Please add atleast 1 activities.');
                            }
                        }
                    } else if (record.Category == undefined) {
                        // i = i + 1;
                        //this.finalmsgDisplay.push('Category is missing '+record.Name);
                    }
                    else {
                        var dates = record.ActivityDates;
                        var str_array = (dates || '').split(';');
                        //var str_array = record.lstDates;
                        if (record.Category == 'Platinum') {
                            if (str_array.length < 3) {
                                i = i + 1;
                                this.finalmsgDisplay.push(record.DealerName + ' is ' + record.Category + ' Category. Please add atleast 3 activities.');
                            }
                        } else if (record.Category == 'Gold') {
                            if (str_array.length < 2) {
                                i = i + 1;
                                this.finalmsgDisplay.push(record.DealerName + ' is ' + record.Category + ' Category. Please add atleast 2 activities.');
                            }
                        } else if (record.Category == 'Silver') {
                            if (str_array.length < 1) {
                                i = i + 1;
                                this.finalmsgDisplay.push(record.DealerName + ' is ' + record.Category + ' Category. Please add atleast 1 activities.');
                            }
                        }
                        debugger;
                    }


                });

                getBeatGroup({ recordId: this.recordId })
                    .then(result => {
                        if (result != null && result != undefined) {
                            console.log('in method' + JSON.stringify(result));
                            result.forEach(record => {
                                var gp = JSON.stringify(record.beatGroupMem);
                                for (let key in record.beatGroupMem) {
                                    var check = record.beatGroupMem[key].ActivityDates;
                                    console.log('record.beatGroupMem[key].Category -->' + record.beatGroupMem[key].Category);

                                    if (check == undefined) {
                                        //i = i + 1;
                                        if (record.beatGroupMem[key].Category == undefined) {
                                            // this.finalmsgDisplay.push(' Please fill the Category '+record.beatGroupMem[key].DealerName );
                                        } else {
                                            i = i + 1;
                                            if (record.beatGroupMem[key].Category == 'Platinum') {
                                                this.finalmsgDisplay.push(record.beatGroupMem[key].DealerName + ' is ' + record.beatGroupMem[key].Category + ' Category. Please add atleast 3 activities.');
                                            } else if (record.beatGroupMem[key].Category == 'Gold') {
                                                this.finalmsgDisplay.push(record.beatGroupMem[key].DealerName + ' is ' + record.beatGroupMem[key].Category + ' Category. Please add atleast 2 activities.');
                                            } else if (record.beatGroupMem[key].Category == 'Silver') {
                                                this.finalmsgDisplay.push(record.beatGroupMem[key].DealerName + ' is ' + record.beatGroupMem[key].Category + ' Category. Please add atleast 1 activities.');
                                            }
                                        }
                                    } else if (record.beatGroupMem[key].Category == undefined) {
                                        console.log('finalmsg -- category');
                                        //i = i + 1;
                                        //this.finalmsgDisplay.push(' Please fill the Category '+record.beatGroupMem[key].DealerName );
                                    } else {
                                        var str_array = record.beatGroupMem[key].lstDates;
                                        if (record.beatGroupMem[key].Category == 'Platinum') {
                                            if (str_array.length < 3) {
                                                i = i + 1;
                                                this.finalmsgDisplay.push(record.beatGroupMem[key].DealerName + ' is ' + record.beatGroupMem[key].Category + ' Category. Please add atleast 3 activities.');
                                            }
                                        } else if (record.beatGroupMem[key].Category == 'Gold') {
                                            if (str_array.length < 2) {
                                                i = i + 1;
                                                this.finalmsgDisplay.push(record.beatGroupMem[key].DealerName + ' is ' + record.beatGroupMem[key].Category + ' Category. Please add atleast 2 activities.');
                                            }
                                        } else if (record.beatGroupMem[key].Category == 'Silver') {
                                            if (str_array.length < 1) {
                                                i = i + 1;
                                                this.finalmsgDisplay.push(record.beatGroupMem[key].DealerName + ' is ' + record.beatGroupMem[key].Category + ' Category. Please add atleast 1 activities.');
                                            }
                                        }
                                    }
                                }

                            });

                        }
                        console.log('in check undefined kfjk' + i);
                        console.log('in check undefined fkgjdf' + this.finalmsgDisplay);
                        if (i == 0) {
                            console.log('in task c');
                            createTask({ recordId: this.recordId }).then(result => {
                                //this.showApproveReject = true;
                                this.showSubmit = false;
                                this.showWaitingMsg = true;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Route Plan submitted for Approval.',
                                        variant: 'success'
                                    })
                                );
                            })
                                .catch(error => { });
                        } else {
                            //this.finalmsgDisplay = finalmsg;
                            this.ismodeforError = true;
                        }
                    })
                    .catch(error => {
                        console.log('error' + error);
                    });
            })
            .catch(error => { console.log('error' + error); });
    }

    Approve(event) {
        //var status = '';
        if (event.target.name === 'Approve') {
            this.status = 'Approved';
        } else if (event.target.name === 'Reject') {
            this.status = 'Rejected';
        } else if (event.target.name === 'update') {
            this.status = 'Update Needed';
        }
        this.openmodelConfirmation = true;
        
    }

    ApproveSubmit(event) {
        updateBeatPlan({ recordId: this.recordId, status: this.status, comments: this.comments })
            .then(result => {
                console.log('in method');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Status Updated',
                        variant: 'success'
                    })
                );
            })
            .catch(error => { });

        this.openmodelConfirmation = false;
        this.showApproveReject = false;
        //this.closeQuickAction();
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handlecomments(event) {
        var rowIndex = event.currentTarget.dataset.index;
        var value = event.detail.value;
        this.comments = value;
    }

    handledeleterecord(event) {
        deleteRouteplan({ routPlaneId: this.routPlaneId })
            .then(result => {
                this.openModalDealer = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Route Plan Delete Successfully',
                        variant: 'success'
                    })
                );
                window.location.reload();
            })
            .catch(error => {
                this.error = error;
                this.checkDone = undefined;
            });
    }

    handleclose() {
        this.openModalDealer = false;
    }
    /* closeModal(){
        this.ismodeforError = false;
    } */
    //////////////////////////////////////////////////////////////////Added by Uday ///////////////////////////////////
    getDealersLst() {
        this.isshow = true;
        getBeatPlanMatrix({ recordId: this.recordId }).then(result => {
            this.beatPlans = result;
            //this.matricCheck = false;
            console.log('beatPlans' + JSON.stringify(this.beatPlans));
            console.log('this.matricCheck-->' + this.matricCheck);
        })
            .catch(error => { });

        getBeatGroup({ recordId: this.recordId })
            .then(result => {
                this.BeatGroup = result;
                console.log('BeatGroupBeatGroup' + JSON.stringify(this.BeatGroup));
            })
            .catch(error => { });
        console.log('this.startDate-->' + this.startDate);
        

    }
    openpopup(event) {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.ismodeforError = false;

    }
    openpopupGRP(event) {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpenForGrp = true;
    }
    closeModalGRP() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpenForGrp = false;

    }

    nameChange(event) {

        this.startDate = event.target.value;

    }

    handleCheckBoxChange(event) {
        var rowIndex = event.currentTarget.dataset.id;
        if (event.target.checked) {
            this.selectedChecks.push(rowIndex);
        } else {
            try {
                var index = this.selectedChecks.indexOf(rowIndex);
                this.selectedChecks.splice(index, 1);
            } catch (err) {
                //error message
            }
        }
        console.log('this.selectedChecks single--> ' + this.selectedChecks);
    }

    SaveSelectedDealers(event) {
        console.log('this.selectedChecks--> ' + this.selectedChecks);
        console.log('ininininini' + this.startDate);
        if (this.startDate != null) {
            var inputdt = this.startDate;
            var dates = this.selectedChecks;
            saveRoutePlans({ recordId: this.recordId, selectedDate: inputdt, plans: dates })
            .then(result => {
                this.beatPlans = result;
                console.log('result--?' + JSON.stringify(result));
                var checkboxes = this.template.querySelectorAll('[data-id="nvfvfhvbfh"]');//this.querySelectorAll()
                var btnsArr = Array.from(checkboxes);
                console.log('checkboxes--> ' + btnsArr);
                checkboxes.forEach(box =>
                    box.checked = false
                );
            })
            .catch(error => {
                    console.log('error ' + error);
            });
            /*
            saveForGroup({ recordId: this.recordId, selectedDate: inputdt, plans: dates })
            .then(result => {
                this.BeatGroup = result;
                console.log('BeatGroupBeatGroup' + JSON.stringify(this.BeatGroup));
            })
            .catch(error => {
                    console.log('error group ' + error);
            });
            */
            //this.startDate = null;
            this.selectedChecks = [];
            var checkboxessingle = this.template.querySelectorAll('[data-id]');//this.querySelectorAll()
            var btnsArr = Array.from(checkboxessingle);
            console.log('checkboxes--> ' + btnsArr);
            checkboxessingle.forEach(box =>
                box.checked = false
            );
           window.location.reload();
        } else {
            alert('Please enter date.');
        }

    }

    allSelectedMatrix(event) {
        try {
            var CHECK = event.detail.checked;
            //alert(CHECK);
            var records = [];
            if (CHECK) {
                /*  for(i=0;i<this.beatPlans.length;i++){
                        this.selectedChecks.push(this.beatPlans[i].id);
                        this.beatPlans[i].checked = true;
                    } */
                for (let key in this.beatPlans) {
                    console.log(key);
                    if (!this.selectedChecks.includes(this.beatPlans[key].Id)) {
                        this.selectedChecks.push(this.beatPlans[key].Id);
                    }

                    let record = {};
                    record.checked = CHECK;
                    record.Name = this.beatPlans[key].Name;
                    record.Id = this.beatPlans[key].Id;
                    record.Pincode = this.beatPlans[key].Pincode;
                    record.Dealer = this.beatPlans[key].Dealer;
                    record.DealerName = this.beatPlans[key].DealerName;
                    record.ActivityDates = this.beatPlans[key].ActivityDates;
                    record.Category = this.beatPlans[key].Category;
                    record.lstDates = this.beatPlans[key].lstDates;
                    record.Address = this.beatPlans[key].Address;
                    records.push(record);
                }
                this.beatPlans = records;
            } else {
                for (let key in this.beatPlans) {

                    var index = this.selectedChecks.indexOf(this.beatPlans[key].id);
                    this.selectedChecks.splice(index, 1);

                    let record = {};
                    record.checked = CHECK;
                    record.Name = this.beatPlans[key].Name;
                    record.Id = this.beatPlans[key].Id;
                    record.Pincode = this.beatPlans[key].Pincode;
                    record.Dealer = this.beatPlans[key].Dealer;
                    record.DealerName = this.beatPlans[key].DealerName;
                    record.ActivityDates = this.beatPlans[key].ActivityDates;
                    record.Category = this.beatPlans[key].Category;
                    record.lstDates = this.beatPlans[key].lstDates;
                    record.Address = this.beatPlans[key].Address;
                    records.push(record);
                }
                this.beatPlans = records;
            }
            console.log('this.selectedChecks-->' + this.selectedChecks);
        } catch (error) {
            console.log('error-->' + error);
        }
    }

    allSelectedGroup(event) {
        try {
            var CHECK = event.detail.checked;
            var groupId = event.currentTarget.dataset.id;
            console.log(groupId);
            var groups = [];
            if (CHECK) {
                for (let key in this.BeatGroup) {
                    let gp = {};
                    gp.Id = this.BeatGroup[key].Id;
                    gp.Name = this.BeatGroup[key].Name;
                    gp.beatGroupMem = [];
                    if (this.BeatGroup[key].Id == groupId) {
                        console.log('if for');
                        console.log('this.BeatGroup[key].beatGroupMem++' + this.BeatGroup[key].beatGroupMem);
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');
                            if (!this.selectedChecks.includes(this.BeatGroup[key].beatGroupMem[gro].Id)) {
                                this.selectedChecks.push(this.BeatGroup[key].beatGroupMem[gro].Id);
                            }

                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.Address = this.BeatGroup[key].beatGroupMem[gro].Address;
                            groupmem.checked = true;
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    } else {
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');

                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.checked = this.BeatGroup[key].beatGroupMem[gro].checked;
                            groupmem.Address = this.BeatGroup[key].beatGroupMem[gro].Address;
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    }
                    console.log('gp-->' + JSON.stringify(gp));
                    groups.push(gp);
                    console.log('groups-->' + groups);
                }
            } else {
                for (let key in this.BeatGroup) {
                    let gp = {};
                    gp.Id = this.BeatGroup[key].Id;
                    gp.Name = this.BeatGroup[key].Name;
                    gp.beatGroupMem = [];
                    if (this.BeatGroup[key].Id == groupId) {
                        console.log('if for');
                        console.log('this.BeatGroup[key].beatGroupMem++' + this.BeatGroup[key].beatGroupMem);
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');

                            var index = this.selectedChecks.indexOf(this.BeatGroup[key].beatGroupMem[gro].Id);
                            this.selectedChecks.splice(index, 1);

                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.Address = this.BeatGroup[key].beatGroupMem[gro].Address;
                            groupmem.checked = false;
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    } else {
                        console.log('else');
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');

                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.checked = this.BeatGroup[key].beatGroupMem[gro].checked;
                            groupmem.Address = this.BeatGroup[key].beatGroupMem[gro].Address;
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    }
                    console.log('gp-->' + JSON.stringify(gp));
                    groups.push(gp);
                    console.log('groups-->' + groups);
                }
            }
            this.BeatGroup = groups;
            console.log('this.BeatGroup-->' + this.BeatGroup);
            console.log('this.selectedChecks-->' + this.selectedChecks);
        } catch (e) {
            console.log('skjfnvkjfnvfjv' + e);
        }

    }

    allSelectedMatrixSub(event) {
        try {
            var CHECK = event.detail.checked;
            alert(CHECK);
            var records = [];
            if (CHECK) {
                /*  for(i=0;i<this.beatPlans.length;i++){
                        this.selectedChecks.push(this.beatPlans[i].id);
                        this.beatPlans[i].checked = true;
                    } */
                for (let key in this.beatPlans) {
                    alert('Inside first for');
                    if (!this.selectedChecks.includes(this.beatPlans[key].Id)) {
                        this.selectedChecks.push(this.beatPlans[key].Id);
                    }

                    let record = {};
                    record.checked = CHECK;
                    record.Name = this.beatPlans[key].Name;
                    record.Id = this.beatPlans[key].Id;
                    record.Pincode = this.beatPlans[key].Pincode;
                    record.Dealer = this.beatPlans[key].Dealer;
                    record.DealerName = this.beatPlans[key].DealerName;
                    record.ActivityDates = this.beatPlans[key].ActivityDates;
                    record.Category = this.beatPlans[key].Category;
                    record.lstDates = this.beatPlans[key].lstDates;
                    record.subRouteWrap = [];
                    //records.push(record);

                    for (let keys in this.beatPlans[key].subRouteWrap) {
                        alert('Inside Second for');

                        console.log(keys);
                        if (!this.selectedChecks.includes(this.beatPlans[key].subRouteWrap[keys].Id)) {
                            this.selectedChecks.push(this.beatPlans[key].subRouteWrap[keys].Id);
                        }
                        alert('this.beatPlans[key].subRouteWrap[keys].Id' + this.beatPlans[key].subRouteWrap[keys].Id);
                        let Subrecord = {};
                        Subrecord.checked = CHECK;
                        // record.Name = this.beatPlans[key].Name;
                        Subrecord.Id = this.beatPlans[key].subRouteWrap[keys].Id;
                        //record.Pincode = this.beatPlans[key].Pincode;
                        Subrecord.Dealer = this.beatPlans[key].subRouteWrap[keys].Dealer;
                        Subrecord.DealerName = this.beatPlans[key].subRouteWrap[keys].DealerName;
                        Subrecord.ActivityDates = this.beatPlans[key].subRouteWrap[keys].ActivityDates;
                        Subrecord.Category = this.beatPlans[key].subRouteWrap[keys].Category;
                        Subrecord.lstDates = this.beatPlans[key].subRouteWrap[keys].lstDates;
                        alert(Subrecord.lstDates);
                        alert(Subrecord.Dealer);
                        alert(Subrecord.DealerName);
                        alert(Subrecord.Id);
                        record.subRouteWrap.push(Subrecord);
                    }
                    records.push(record);
                }

                // this.beatPlans.subRouteWrap = records;
            } else {
                for (let key in this.beatPlans) {
                    var index = this.selectedChecks.indexOf(this.beatPlans[key].id);
                    this.selectedChecks.splice(index, 1);

                    let record = {};
                    record.checked = CHECK;
                    record.Name = this.beatPlans[key].Name;
                    record.Id = this.beatPlans[key].Id;
                    record.Pincode = this.beatPlans[key].Pincode;
                    record.Dealer = this.beatPlans[key].Dealer;
                    record.DealerName = this.beatPlans[key].DealerName;
                    record.ActivityDates = this.beatPlans[key].ActivityDates;
                    record.Category = this.beatPlans[key].Category;
                    record.lstDates = this.beatPlans[key].lstDates;
                    record.subRouteWrap = [];
                    //  records.push(record);

                    for (let keys in this.beatPlans[key].subRouteWrap) {
                        var index = this.selectedChecks.indexOf(this.beatPlans[key].subRouteWrap[keys].id);
                        this.selectedChecks.splice(index, 1);

                        let Subrecord = {};
                        Subrecord.checked = CHECK;
                        // record.Name = this.beatPlans[key].Name;
                        Subrecord.Id = this.beatPlans[key].subRouteWrap[keys].Id;
                        //   record.Pincode = this.beatPlans[key].Pincode;
                        Subrecord.Dealer = this.beatPlans[key].subRouteWrap[keys].Dealer;
                        Subrecord.DealerName = this.beatPlans[key].subRouteWrap[keys].DealerName;
                        Subrecord.ActivityDates = this.beatPlans[key].subRouteWrap[keys].ActivityDates;
                        Subrecord.Category = this.beatPlans[key].subRouteWrap[keys].Category;
                        Subrecord.lstDates = this.beatPlans[key].subRouteWrap[keys].lstDates;
                        record.subRouteWrap.push(Subrecord);
                    }
                    records.push(record);
                }

                //this.beatPlans.subRouteWrap = records;
            }
            this.beatPlans = records;
            console.log('this.selectedChecks-->' + this.selectedChecks);
        } catch (error) {
            alert('error');
            console.log('error-->' + error);
        }
    }
    allSelectedGroupSub(event) {
        try {
            var CHECK = event.detail.checked;
            var groupId = event.currentTarget.dataset.id;
            console.log(groupId);
            var groups = [];
            if (CHECK) {
                for (let key in this.BeatGroup) {
                    let gp = {};
                    gp.Id = this.BeatGroup[key].Id;
                    gp.Name = this.BeatGroup[key].Name;
                    gp.beatGroupMem = [];
                    if (this.BeatGroup[key].Id == groupId) {
                        console.log('if for');
                        console.log('this.BeatGroup[key].beatGroupMem++' + this.BeatGroup[key].beatGroupMem);
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');


                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.checked = true;
                            groupmem.subRouteGrpWrap = [];
                            // Sub group Starts here
                            for (let Subgro in this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap) {
                                alert('Inside 2nd For');
                                if (!this.selectedChecks.includes(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id)) {
                                    alert('Inside 2nd For  IF');
                                    this.selectedChecks.push(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id);
                                }
                                let subGroupc = {};
                                alert('after SubGroup');
                                subGroupc.checked = CHECK;
                                // record.Name = this.beatPlans[key].Name;
                                subGroupc.Id = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Id;
                                //   record.Pincode = this.beatPlans[key].Pincode;
                                subGroupc.Dealer = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Dealer;
                                subGroupc.DealerName = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].DealerName;
                                subGroupc.ActivityDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].ActivityDates;
                                subGroupc.Category = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Category;
                                subGroupc.lstDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].lstDates;
                                groupmem.subRouteGrpWrap.push(subGroupc);
                            }
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    } else {
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');

                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.checked = this.BeatGroup[key].beatGroupMem[gro].checked;
                            groupmem.subRouteGrpWrap = [];
                            // Sub group Starts here
                            for (let Subgro in this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap) {
                                if (!this.selectedChecks.includes(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id)) {
                                    this.selectedChecks.push(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id);
                                }
                                let subGroupc = {};
                                subGroupc.checked = CHECK;
                                // record.Name = this.beatPlans[key].Name;
                                subGroupc.Id = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Id;
                                //   record.Pincode = this.beatPlans[key].Pincode;
                                subGroupc.Dealer = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Dealer;
                                subGroupc.DealerName = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].DealerName;
                                subGroupc.ActivityDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].ActivityDates;
                                subGroupc.Category = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Category;
                                subGroupc.lstDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].lstDates;
                                groupmem.subRouteGrpWrap.push(subGroupc);
                            }
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    }
                    console.log('gp-->' + JSON.stringify(gp));
                    groups.push(gp);
                    console.log('groups-->' + groups);
                }
            } else {
                for (let key in this.BeatGroup) {
                    let gp = {};
                    gp.Id = this.BeatGroup[key].Id;
                    gp.Name = this.BeatGroup[key].Name;
                    gp.beatGroupMem = [];
                    if (this.BeatGroup[key].Id == groupId) {
                        console.log('if for');
                        console.log('this.BeatGroup[key].beatGroupMem++' + this.BeatGroup[key].beatGroupMem);
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');

                            var index = this.selectedChecks.indexOf(this.BeatGroup[key].beatGroupMem[gro].Id);
                            this.selectedChecks.splice(index, 1);

                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.checked = false;
                            groupmem.subRouteGrpWrap = [];
                            // Sub group Starts here
                            for (let Subgro in this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap) {
                                if (!this.selectedChecks.includes(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id)) {
                                    this.selectedChecks.push(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id);
                                }
                                let subGroupc = {};
                                subGroupc.checked = CHECK;
                                // record.Name = this.beatPlans[key].Name;
                                subGroupc.Id = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Id;
                                //   record.Pincode = this.beatPlans[key].Pincode;
                                subGroupc.Dealer = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Dealer;
                                subGroupc.DealerName = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].DealerName;
                                subGroupc.ActivityDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].ActivityDates;
                                subGroupc.Category = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Category;
                                subGroupc.lstDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].lstDates;
                                groupmem.subRouteGrpWrap.push(subGroupc);
                            }
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    } else {
                        console.log('else');
                        for (let gro in this.BeatGroup[key].beatGroupMem) {
                            console.log('groupId');

                            let groupmem = {};
                            groupmem.Name = this.BeatGroup[key].beatGroupMem[gro].Name;
                            groupmem.Id = this.BeatGroup[key].beatGroupMem[gro].Id;
                            groupmem.Dealer = this.BeatGroup[key].beatGroupMem[gro].Dealer;
                            groupmem.DealerName = this.BeatGroup[key].beatGroupMem[gro].DealerName;
                            groupmem.ActivityDates = this.BeatGroup[key].beatGroupMem[gro].ActivityDates;
                            groupmem.lstDates = this.BeatGroup[key].beatGroupMem[gro].lstDates;
                            groupmem.Category = this.BeatGroup[key].beatGroupMem[gro].Category;
                            groupmem.checked = this.BeatGroup[key].beatGroupMem[gro].checked;
                            groupmem.subRouteGrpWrap = [];
                            // Sub group Starts here
                            for (let Subgro in this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap) {
                                if (!this.selectedChecks.includes(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id)) {
                                    this.selectedChecks.push(this.BeatGroup[key].beatGroupMem[gro].subRouteGrpWrap[Subgro].Id);
                                }
                                let subGroupc = {};
                                subGroupc.checked = CHECK;
                                // record.Name = this.beatPlans[key].Name;
                                subGroupc.Id = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Id;
                                //   record.Pincode = this.beatPlans[key].Pincode;
                                subGroupc.Dealer = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Dealer;
                                subGroupc.DealerName = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].DealerName;
                                subGroupc.ActivityDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].ActivityDates;
                                subGroupc.Category = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].Category;
                                subGroupc.lstDates = this.beatPlans[key].subRouteWrap[keys].subRouteGrpWrap[Subgro].lstDates;
                                groupmem.subRouteGrpWrap.push(subGroupc);
                            }
                            gp.beatGroupMem.push(groupmem);
                            console.log('gp.beatGroupMem-->' + gp.beatGroupMem);
                        }
                    }
                    console.log('gp-->' + JSON.stringify(gp));
                    groups.push(gp);
                    console.log('groups-->' + groups);
                }
            }
            this.BeatGroup = groups;
            console.log('this.BeatGroup-->' + this.BeatGroup);
            console.log('this.selectedChecks-->' + this.selectedChecks);
        } catch (e) {
            console.log('skjfnvkjfnvfjv' + e);
        }

    }
    /////////////////////////////////////////////////////////////////Ends here ////////////////////////
}