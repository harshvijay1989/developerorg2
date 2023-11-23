import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, MessageContext } from "lightning/messageService";
import Record_Selected from "@salesforce/messageChannel/Record_Selected__c";
import fetchData from '@salesforce/apex/HistoryTrackerController.fetchData';
import { refreshApex } from '@salesforce/apex';

const FIELDS = ['Name'];
const MAX_STEPS = 5;
const status = '';
const stepDescriptions = [
    'Document Template Created.',
    'Document Generated.',
    'Sent Document to Customer.',
    'Customer has viewed the document.',
    'Document Agreement Accepted/Rejected',
];


export default class ProgressTracker extends LightningElement {

    @api recordId;
    @track mapFromApex = [];
    @track mapValueOfStep;
    @track dataNull = false;
    @track recordIdHistory;
    @track changeValue = '';
    @track wiredData1;


    @wire(MessageContext)
    messageContext;
    subscription = null;
    callbackBool = true;

    connectedCallback() {
        if (this.callbackBool == true) {
            this.subscriptionToMessageChannel();
            this.handleFetchData();
            this.callbackBool=false;
        }

    }

    //  @wire(fetchData, { recordId: '$recordId' })
    // wiredData({ data, error }) {
    //     if (data) {
    //         console.log("data is eeee",data);
    //         this.wiredData1=data;

    //         //alert(JSON.stringify(Data));
    //         console.log("wire method ", this.recordId);
    //         const dataArray = Object.values(data);
    //         console.log("length is abc:  ", dataArray);
    //         if (dataArray.length > 0) {
    //             this.mapFromApex = dataArray.map((entry, index) => ({
    //                 Counter: index + 1,
    //                 mapValueOfObjRecName: entry.Name__c,
    //                 steps: this.generateSteps(entry),
    //                 progressValue: this.calculateProgressValue(entry),
    //                 progressStyle: this.calculateProgressStyle(entry),
    //                 tooltipText: this.calculateTooltipText(entry),
    //                 key: entry.Id
    //             }));
    //             this.dataNull = false;
    //             console.log("fddf");
    //             this.subscriptionToMessageChannel();
    //         } else {
    //             this.dataNull = true;
    //         }
    //     } else if (error) {
    //         console.error('Err  or fetching data: ', error);
    //     }
    // }

    // fetchAllRecords(recordIdHistory){
    //     console.log('called fetchAllRecords');
    //     let recordId = recordIdHistory;
    //     console.log('recordId', recordId)
    //      fetchData({ recordId: recordId }).then(result => {
    //          console.log('result---------->', result);
    //      })
    // }


    subscriptionToMessageChannel() {
        console.log("In handle subscribe new org");
        this.subscription = subscribe(
            this.messageContext,
            Record_Selected,
            (message) => {
                console.log(' Message123545 is : ', message);
                this.recordIdHistory = message.recordIdHistory;
                console.log("record id history ", this.recordIdHistory);

                refreshApex(this.wiredData1);
                console.log("recordIdHistory", this.recordIdHistory);
                //alert('first');
                this.handleFetchData();
                // fetchData({ recordId: this.recordId })
                //     .then(data => {
                //         if (data) {
                //             alert(JSON.stringify(data));
                //             const dataArray = Object.values(data);
                //             console.log("length is abc4444:  ", dataArray);
                //             if (dataArray.length > 0) {
                //                 console.log("3333");
                //                 this.mapFromApex = dataArray.map((entry, index) => ({
                //                     Counter: index + 1,
                //                     mapValueOfObjRecName: entry.Name__c,
                //                     steps: this.generateSteps(entry),
                //                     progressValue: this.calculateProgressValue(entry),
                //                     progressStyle: this.calculateProgressStyle(entry),
                //                     tooltipText: this.calculateTooltipText(entry),
                //                     key: entry.Id
                //                 }));
                //                 this.dataNull = false;
                //                 console.log("data null false");
                //             } else {
                //                 this.dataNull = true;
                //             }
                //         }
                //     })
                //     .catch(error => {
                //         console.error('Error fetching data: ', error);
                //     });

            }
        )
    }

    handleFetchData() {
        //alert('second');
        fetchData({ recordId: this.recordId })
            .then(data => {
                if (data) {
                    // alert(JSON.stringify(data));
                    const dataArray = Object.values(data);
                    console.log("length is abc4444:  ", JSON.stringify(dataArray));
                    if (dataArray.length > 0) {
                        console.log("3333");
                        this.mapFromApex = dataArray.map((entry, index) => ({
                            Counter: index + 1,
                            mapValueOfObjRecName: entry.Name__c,
                            steps: this.generateSteps(entry),
                            progressValue: this.calculateProgressValue(entry),
                            progressStyle: this.calculateProgressStyle(entry),
                            tooltipText: this.calculateTooltipText(entry),
                            key: entry.Id
                        }));
                        this.dataNull = false;
                        console.log("data null false" , JSON.stringify(this.mapFromApex));
                    } else {
                        this.dataNull = true;
                    }
                }
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });

    }
    generateSteps(entry) {
        stepDescriptions[4] = entry.Status__c;
        //alert('Call');
        const steps = [];
        let lastCompletedStep = 0;
        const stepCount = entry.Step__c || 0;
        for (let i = 1; i <= MAX_STEPS; i++) {
            const completed = i <= stepCount;
            const customTop = '0.5rem';
            const customLeft = `calc(${(i / MAX_STEPS) * 100}% - 50px)`;
            const customTransform = 'translateX(-50%)';

            const tooltipStyle = `position: absolute; top: ${customTop}; left: ${customLeft}; transform: ${customTransform};`;

            steps.push({
                key: `step${i}`,
                title: `Step ${i} - ${completed ? 'Completed' : 'Not Completed'}`,
                classes: `slds-progress__item ${completed ? 'slds-is-completed' : ''}`,
                completed,
                showInfo: true,
                info: `Step ${i}. ${stepDescriptions[i - 1]}`,
                tooltipStyle,
            });

            if (completed) {
                lastCompletedStep = i;
            }
        }

        return steps;
    }

    calculateProgressValue(entry) {
        const stepCount = entry.Step__c || 0;
        if (stepCount == 1) {
            return 0;
        }
        if (stepCount == 2) {
            return 25;
        }
        if (stepCount == 3) {
            return 50;
        }
        if (stepCount == 4) {
            return 75;
        }
        if (stepCount == 5) {
            return 100;
        }
    }

    calculateProgressStyle(entry) {
        return `width: ${this.calculateProgressValue(entry)}%`;
    }

    calculateTooltipText(entry) {

        return 'You are here!';
    }

    calculateTooltipStyle(stepNumber, lastCompletedStep) {
        if (stepNumber === lastCompletedStep) {
            const customTop = '0.5rem';
            const customLeft = `calc(${(stepNumber / MAX_STEPS) * 100}% - 50px)`;
            const customTransform = 'translateX(-50%)';

            return `position: absolute; top: ${customTop}; left: ${customLeft}; transform: ${customTransform};`;
        }
        return '';
    }


    // @track progressValue = 11;
    //  get tooltipStyle() {
    //         if(this.mapValueOfStep === '1'){
    //             this.isTrue1 = true;
    //             //alert(this.isTrue1);
    //             const customTop = '2.5rem'; // Adjust the top position as needed
    //             const customLeft = `calc(${this.progressValue}% - 5px)`; // Adjust the left position as needed
    //             const customTransform = 'translateX(-50%)';

    //             return `position: absolute; top: ${customTop}; left: ${customLeft}; transform: ${customTransform};`;
    //         }else if(this.mapValueOfStep == '2'){
    //             this.isTrue2 = true;
    //             this.progressValue = 29;
    //             const customTop = '2.5rem'; // Adjust the top position as needed
    //             const customLeft = `calc(${this.progressValue}% - 5px)`; // Adjust the left position as needed
    //             const customTransform = 'translateX(-50%)';

    //             return `position: absolute; top: ${customTop}; left: ${customLeft}; transform: ${customTransform};`;
    //         }else if(this.mapValueOfStep == '3'){
    //             this.isTrue3 = true;
    //             this.progressValue = 48;
    //             const customTop = '2.5rem'; // Adjust the top position as needed
    //             const customLeft = `calc(${this.progressValue}% - 5px)`; // Adjust the left position as needed
    //             const customTransform = 'translateX(-50%)';

    //             return `position: absolute; top: ${customTop}; left: ${customLeft}; transform: ${customTransform};`;
    //         }else if(this.mapValueOfStep == '4'){
    //             this.isTrue4 = true;
    //             this.progressValue = 67;
    //             const customTop = '2.5rem'; // Adjust the top position as needed
    //             const customLeft = `calc(${this.progressValue}% - 5px)`; // Adjust the left position as needed
    //             const customTransform = 'translateX(-50%)';

    //             return `position: absolute; top: ${customTop}; left: ${customLeft}; transform: ${customTransform};`;
    //         }else if(this.mapValueOfStep == '5'){
    //             this.isTrue5 = true;
    //             this.progressValue = 86;
    //             const customTop = '2.5rem'; // Adjust the top position as needed
    //             const customLeft = `calc(${this.progressValue}% - 5px)`; // Adjust the left position as needed
    //             const customTransform = 'translateX(-50%)';

    //             return `position: absolute; top: ${customTop}; left: ${customLeft}; transform: ${customTransform};`;
    //         }
    //     //}
    // }
}