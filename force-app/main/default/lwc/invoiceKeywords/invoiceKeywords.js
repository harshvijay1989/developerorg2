import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchCompanyData from '@salesforce/apex/ObjectNameController.getCompanyInfo';
import getDocumentTemplates from '@salesforce/apex/AddressManageCtrl.getDocumentTemplates';


export default class invoiceKeywords extends LightningElement {

  @track companydata = '';
  @track notShow = false;
  organizationFields = [];
  @track isTrue = false;
  @track isShowModal = false;
  @track compnayShowTable = false;
  @track parentData = undefined;
  @track notShowToast;



  @track tableData = [
    {
      SNo: 1,
      Description: 'Company Address',
      Pattern: '',
    },
    {
      SNo: 2,
      Description: 'TrueCaller Signature',
      Pattern: 'TrueCaller\n{{{TrueCaller_Signature}}}',
    },
    {
      SNo: 3,
      Description: 'Today Date',
      Pattern: '{{{Today_Date}}}',
    },
    { 
      SNo: 4,
      Description: 'Amount In words',
      Pattern: 'Total:\nAmount In Words:'
    },
    {
      SNo: 5,
      Description: 'Customer Signture',
      Pattern: '{{{Customer_Name}}}\n{{{Customer_Sign}}}',
    },
    {
      SNo: 6,
      Description: 'Current Date',
      Pattern: '{{{Current_Date}}}',
    },
    {
      SNo: 7,
      Description: 'Text Box',
      Pattern: '{{{Text_Box}}}',
    },
  ];

  connectedCallback() {
    this.handleCompanyAddress();
  }

  handleCompanyAddress() {
    console.log("table data ", this.tableData[0].Pattern);
    console.log("helo enter");

   // this.compnayShowTable = true;

    // fetchCompanyData()
    //   .then(result => {
    //     this.companydata = result;
    //     this.tableData[0].Pattern = 'Name: ' + this.companydata[0].Name + '\n' + 'Street: ' + this.companydata[0].Street + '\n' + 'City: ' + this.companydata[0].City + '\n' + 'State: ' + this.companydata[0].State + '\n' + 'PostalCode: ' + this.companydata[0].PostalCode + '\n' + 'Country: ' + this.companydata[0].Country + '\n';
    //   })
    //   .catch(error => {
    //   });
  }

  @track copyComopanyInfo = '';
  handleCopyClick(event) {
    const rowIndex = event.currentTarget.dataset.index;
    console.log(rowIndex);
    var strtemp = '<table border="1" cellpadding="1" cellspacing="1" style="width:100%"> <tbody> <tr> <td style="width:50%">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<strong> Company Information&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</strong></td> <td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>&nbsp; Customer Information&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</strong></td> </tr> <tr> <td>Name: CRM Landing Software Private Limited</td> <td>&nbsp;</td> </tr> <tr> <td>Street: Ram bhawan, Shastri Nagar</td> <td>&nbsp;</td> </tr> <tr> <td>City: Ajmer</td> <td>&nbsp;</td> </tr> <tr> <td>State: Rajasthan</td> <td>&nbsp;</td> </tr> <tr> <td>PostalCode: 305001</td> <td>&nbsp;</td> </tr> <tr> <td>Country: IN</td> <td>&nbsp;</td> </tr> </tbody> </table> <p>&nbsp;</p>';
    const signValue = this.tableData[rowIndex].Pattern;
    console.log("this.tableData[rowIndex].Pattern $$$ ", this.tableData[rowIndex].Pattern);
    this.notShowToast = rowIndex;
    this.parentData = false;

    if (rowIndex == 0) {
      this.parentData = true;
      this.copyToClipboard(signValue);
    }
    else {
      this.parentData = false;
      this.copyToClipboard(signValue);

    }
  }

  modalHide(event) {
    this.parentData = undefined;
  }

  copyToClipboard(text) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    console.log("not show toast ", this.notShowToast);
    if (this.notShowToast != 0) {
      const toastEvent = new ShowToastEvent({
        title: 'Copied Succesfully',
        message: 'Text has been copied',
        variant: 'success',
      });
      this.dispatchEvent(toastEvent);
    }
    else {
      console.log("not matched ");
    }

  }
  copyHtmlBodyContent() {
    alert('Enter');
    const bodyHtml = document.body.innerHTML;
    alert(bodyHtml);
    var strtemp = '<table border="1" cellpadding="1" cellspacing="1" style="width:100%"> <tbody> <tr> <td style="width:50%">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<strong> Company Information&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</strong></td> <td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>&nbsp; Customer Information&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</strong></td> </tr> <tr> <td>Name: CRM Landing Software Private Limited</td> <td>&nbsp;</td> </tr> <tr> <td>Street: Ram bhawan, Shastri Nagar</td> <td>&nbsp;</td> </tr> <tr> <td>City: Ajmer</td> <td>&nbsp;</td> </tr> <tr> <td>State: Rajasthan</td> <td>&nbsp;</td> </tr> <tr> <td>PostalCode: 305001</td> <td>&nbsp;</td> </tr> <tr> <td>Country: IN</td> <td>&nbsp;</td> </tr> </tbody> </table> <p>&nbsp;</p>';

    var urlField = this.template.querySelector('.my-class');
    alert(urlField);
    var range = document.createRange();
    range.selectNode(urlField);

    const event = new ShowToastEvent({
      message: 'Copied Table Successfully..!',
      variant: 'success',
      mode: 'dismissable'
    });
    this.dispatchEvent(event);

    window.getSelection().removeAllRanges();
    window.getSelection().addRange(range);
    document.execCommand('copy');

    window.getSelection().removeAllRanges();
    window.getSelection().addRange(selectedRange);
    window.alert("helloooo");

  }
}