import { LightningElement,track,api } from 'lwc';
import GetTallyData from '@salesforce/apex/TallyDataProcess.GetTallyData';
import { CloseActionScreenEvent } from 'lightning/actions';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';


export default class TallyData extends LightningElement {
    @api recordId;
    @track Spinner = true;
   async connectedCallback(){
        this.tallyData();
        
    }
    

    tallyData(){

        
        GetTallyData({ recordId : this.recordId})
        .then(result => {
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Your Data Imported Successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            console.log('result'+JSON.stringify(result));
            this.Spinner = false;
            this.closeQuickAction();
                        this.finishFlowWithOutcome('SUCCESS'); 

           
        })
        
        .catch(error => {
            
            this.error = error;
            this.closeQuickAction();
            this.dispatchEvent(new CloseActionScreenEvent());
                        this.finishFlowWithOutcome('SUCCESS'); 

        });
        
    } 

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
       const closeQA = new CustomEvent('close');
         this.dispatchEvent(closeQA);
    }


      finishFlowWithOutcome(outcome) {
        const finishEvent = new FlowNavigationFinishEvent(outcome);
        this.dispatchEvent(finishEvent);
    }
    
}