import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import homeimage from '@salesforce/resourceUrl/homeimage';
import truecallerlogo from '@salesforce/resourceUrl/TruecallerLOGO';
//import userimg from '@salesforce/resourceUrl/userimg';
import userimg from '@salesforce/resourceUrl/SupremeMiddleHome';
import nogeo from '@salesforce/resourceUrl/nogeo';	
import cyclehome from '@salesforce/resourceUrl/cyclehome';

export default class Dms_HomePage extends NavigationMixin(LightningElement)  {
    @track  year = new Date().getFullYear() ;
   @track homeimage=homeimage;
   @track logo = truecallerlogo;
   @track userimg=userimg;
   @track showhome=true;
   @track nogeo=nogeo;
  @track backgroundStyle = `background-image: url(${cyclehome});background-repeat:no-repeat;background-size:cover;height:1000px`;
   

      handleButtonClick() {
          
       
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'dealer_registration__c'
            }
            
        });
    }
}