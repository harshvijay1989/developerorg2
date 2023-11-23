import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation"; 
export default class InvoiveEditable extends NavigationMixin(LightningElement) {

    @api recordId;
     
    @api invoke() {
     this.handleNavigate(this.recordId);
    } 

    handleNavigate(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Edit',
            },
            state: {
                c__recordId: recordId
            }
        });
        //this.handleSelectedData();
   }

}