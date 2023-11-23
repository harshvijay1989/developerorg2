import { LightningElement, wire, track, api } from 'lwc';
import getDocumentTemplates from '@salesforce/apex/AddressManageCtrl.getDocumentTemplates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrganizationInfoCopy extends LightningElement {
  organizationFields = [];
  @track isTrue = false;
  @track isShowModal = false;
  @track compnayShowTable = false;
  @api tableFromParent;
  @api chaildModel = false;
  @track showAddress ;

  connectedCallback() {
   // alert(this.tableFromParent);
    console.log("data from parent ",this.tableFromParent);
  }

  get showModal(){
    console.log(' ====> My Testing : ',this.tableFromParent);
    return this.tableFromParent == true ? true : false;
  }

  @wire(getDocumentTemplates)
  wiredOrganization({ error, data }) {
    if (data) {
      this.organizationFields = [
        { label: 'Name', fieldName: 'Name', value: data.Name },
        { label: 'Street', fieldName: 'Street', value: data.Street },
        { label: 'City', fieldName: 'City', value: data.City },
        { label: 'State', fieldName: 'State', value: data.State },
        { label: 'Postal Code', fieldName: 'PostalCode', value: data.PostalCode },
        { label: 'Country', fieldName: 'Country', value: data.Country },
      ];
    }
  }

  handleCopyClick() {
    this.isTrue = true;
    const tableElement = this.template.querySelector('table');

    this.isTrue = false;
    const range = document.createRange();
    range.selectNode(tableElement);
    window.getSelection().removeAllRanges();
    window.getSelection().addRange(range);
    document.execCommand('copy');
    window.getSelection().removeAllRanges();

    const toastEvent = new ShowToastEvent({
      title: 'Table Copied Successfully',
      message: 'Table content has been copied',
      variant: 'success',
    });
    this.dispatchEvent(toastEvent);
    this.hideModalBox();
    this.showModal=false;
  }

  hideModalBox(event){
    this.tableFromParent=undefined;
    this.dispatchEvent(new CustomEvent('modalhide',{
      detail:false
    }))
  }
}














// import { LightningElement, track, wire, api } from 'lwc';
// import getDocumentTemplates from '@salesforce/apex/AddressManageCtrl.getDocumentTemplates';
// import { ShowToastEvent } from "lightning/platformShowToastEvent";


// export default class AddressWithTable extends LightningElement {
//     @track isTableShow = false;
//     documentTemplates;
//     @track isModalOpen = false;
//     @track getMergeFields = false;

//     connectedCallback() {
//         this.handleButtonClick();
//     }
//     handleButtonClick() {
//         //alert('handleButtonClick')
//         this.isModalOpen = true;
//         getDocumentTemplates()
//             .then(result => {
//                 console.log('result ' + JSON.stringify(result));
//                 this.documentTemplates = result;
//                 this.isTableShow = true;
//             })
//             .catch(error => {
//                 // Handle error
//             });
//     }
//     closeModal() {
//         // to close modal set isModalOpen tarck value as false
//         this.isModalOpen = false;
//     }

//     copyText() {
//         console.log("hello@@@@");
//         var urlField = this.template.querySelector('.my-class');
//         var range = document.createRange();
//         console.log('@@ urlField ', urlField);
//         console.log('@@ range ', range);
//         range.selectNode(urlField);

//            const event = new ShowToastEvent({
//                 message: 'Copied Table Successfully..!',
//                 variant: 'success',
//                 mode: 'dismissable'
//             });
//             this.dispatchEvent(event); 

//         window.getSelection().removeAllRanges();
//         window.getSelection().addRange(range);
//         document.execCommand('copy');

//         window.getSelection().removeAllRanges();
//         window.getSelection().addRange(selectedRange);
//         window.alert("helloooo");


//         this.isModalOpen=false;



//     }


//     handleDismiss(event) {
//         //alert('closeModal')
//         this.isModalOpen = false;
//          this.dispatchEvent( new CustomEvent( 'falsevalue', {} ) );
//     }
// }