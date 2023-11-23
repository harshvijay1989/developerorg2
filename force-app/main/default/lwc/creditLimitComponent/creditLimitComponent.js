import { LightningElement, track, wire } from 'lwc';
import slider_columns from '@salesforce/resourceUrl/slider_columns';
import apollo_Banner from '@salesforce/resourceUrl/apollo_Banner';
//import { NavigationMixin } from 'lightning/navigation';
import getAccounts from '@salesforce/apex/CreditLimitController.getAccounts';
export default class CreditLimitComponent extends LightningElement {
    currentURL;
    customLabel;
    sliderImage = slider_columns;
        bannerImage = apollo_Banner;
        leftSliderBtn() {
            this.template.querySelector('.scrollmenu').scrollLeft -= 300;
        }
    
        rightSliderBtn() {
            this.template.querySelector('.scrollmenu').scrollLeft += 300;
        }
    
        
    
  
    
        result;
        error;
    
        connectedCallback() {
            
            this.handleClick();
            // this.currentURL =  window.location.href.slice(0, -22);
            // console.log('URL ='  , this.currentURL);
            
        }
    
        handleClick(){
            getAccounts()
             .then((result) => {
              this.result = result;
              console.log('this.result-->',  JSON.stringify( this.result));
              this.error = undefined;
             })
             .catch((error) => {
             this.error = error;
             this.result = undefined;
             });
        }
    
}