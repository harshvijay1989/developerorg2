import { LightningElement, track,wire,api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSelectedObjectFields from '@salesforce/apex/ChildTableDataShowLWC_Handler.getSelectedObjectFields';
export default class ChildTableDataShowLWC extends LightningElement {
    @track selectValue = '';
    @track showDuelBox=false;    
    _selected = [];
    listOptions=[];
    @track showContentBox=false;
    @track htmlTableBody='';

    get optionslist() {
        return [
            { label: 'Opportunity Line Item', value: 'OpportunityLineItem'}
        ];
    }

    handleComboChange(event) {
        this.selectValue = event.detail.value;
        if(this.selectValue!==''){
            this.showDuelBox=true;
            this.getObjectField();
        }
    }
   
    getObjectField(){
        getSelectedObjectFields({ selectedObject: this.selectValue })
        .then(result => {           
            var tempdata=[];           
            for(var i=0;i<result.length;i++){
                tempdata.push({label:result[i].label,value:result[i].apiValue});
            }
            this.listOptions=tempdata;
        })
        .catch(error => {
            
        })
    }

    get options() {
        return this.listOptions;
    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChange(e) {
        this._selected = e.detail.value;
        console.log(this._selected);
        let selectlabels = [];
        var htmlBody='{{{TableStarted'+'___'+this.selectValue+'}}}';
        htmlBody+='<table border="1" cellpadding="1" cellspacing="1" style="width:700px"><thead><tr>';
        this._selected.forEach(option => {
            let currentOption = this.listOptions.find( o => o.value === option);
            selectlabels.push(currentOption.label);
        });
        var lengthOfSpan=selectlabels.length;
        console.log('lengthOfSpan'+lengthOfSpan);
        console.log('selected labels => ' + selectlabels);       
        for(var i=0;i<selectlabels.length;i++){
            htmlBody+='<td><span style="font-size:12.0pt"><span style="font-family:&quot;Times New Roman&quot;,&quot;serif&quot;">'+selectlabels[i]+'</span></span></td>';
        }
        htmlBody+='</tr></thead><tbody><tr>';
        selectlabels=[];
        this._selected.forEach(option => {
            let currentOption = this.listOptions.find( o => o.value === option);
            selectlabels.push(currentOption.value);
        });
        for(var i=0;i<selectlabels.length;i++){
            htmlBody+='<td><span style="font-size:12.0pt"><span style="font-family:&quot;Times New Roman&quot;,&quot;serif&quot;">{{{'+selectlabels[i]+'}}}</span></span></td>';
        }
        htmlBody+='</tr></tbody></table>{{{TableEnd'+'___'+this.selectValue+'}}}<br/>';
        htmlBody+='Total:-<br/>';
        htmlBody+='In Words:-';

        // htmlBody+='<td colspan="'+lengthOfSpan+'"><span style="font-size:12.0pt"><span style="font-family:&quot;Times New Roman&quot;,&quot;serif&quot;">'+"Total:-"+'</span></span></td>';
        // htmlBody+='</tr><br/><tr>';
        // htmlBody+='<td colspan="'+lengthOfSpan+'"><span style="font-size:12.0pt"><span style="font-family:&quot;Times New Roman&quot;,&quot;serif&quot;">'+"In Words:-"+'</span></span></td>';
        // htmlBody+='</tr>';
        console.log(htmlBody);      
        this.htmlTableBody=htmlBody;
        
    }
    handlePreview(event){
        this.showContentBox=true;
    }
    hideModalBox(event){
         this.showContentBox=false;
    }

    async copyTable() {
        const bodyHtml = this.htmlTableBody;
        await getClipboard().then((clipboard) => {
            clipboard.writeText(bodyHtml);
        });
        const event = new ShowToastEvent({
            message: 'Copied Successfully!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }  

      copyHtmlBodyContent() {
        const bodyHtml = document.body.innerHTML;
        var urlField = this.template.querySelector('.my-class');
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