import { LightningElement } from 'lwc';
import Community_Url from '@salesforce/label/c.Community_Url';
import slider_columns from '@salesforce/resourceUrl/slider_columns';
import apollo_Banner from '@salesforce/resourceUrl/apollo_Banner';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountCommunityTab extends NavigationMixin(LightningElement) {
     sliderImage = slider_columns;
    bannerImage = apollo_Banner;
    leftSliderBtn() {
        this.template.querySelector('.scrollmenu').scrollLeft -= 300;
    }

    rightSliderBtn() {
        this.template.querySelector('.scrollmenu').scrollLeft += 300;
    }

customLabelUrl = Community_Url;

    handleNavigation(event) {
        var clickedTab = event.currentTarget.dataset.tab;
        if (clickedTab === 'Invoices') {
            // Generate a URL to a User record page
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Invoice__c',
                    actionName: 'list'
                },
            },
                true // Replaces the current page in your browser history with the URL
            );
        } else if (clickedTab === 'overdueInvoices') {
             // Generate a URL to a User record page
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Invoice__c',
                    actionName: 'list'
                },
                state: {       
                    filterName: '00B1e000001yNteEAE' 
                }
            },
                true // Replaces the current page in your browser history with the URL
            );
            

        } else if (clickedTab === 'creditNote') {
            // Generate a URL to a User record page
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Credit_Note__c',
                    actionName: 'list'
                },
            },
                true // Replaces the current page in your browser history with the URL
            );

        } else if (clickedTab === 'creditLimit') {
            console.log('url@62',this.customLabelUrl);
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    // url: 'https://aplapollotubeslimited--dev.sandbox.my.site.com/apollofour/s/credit-limit-component'
                    url: this.customLabelUrl + 'credit-limit' 
                },
                
            })
        } else if (clickedTab === 'Debit') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Debit_Note__c',
                    actionName: 'list'
                },
            },
            // Generate a URL to a User record page
            
                true // Replaces the current page in your browser history with the URL
            );


        } else if (clickedTab === 'Ledger') {
           
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    //url: 'https://aplapollotubeslimited--dev.sandbox.my.site.com/apollofour/s/ledgercomponent'
                    url: this.customLabelUrl + 'ledger' 
                },
                
            },
            // Generate a URL to a User record page
            
                true // Replaces the current page in your browser history with the URL
            );
        }
    }
}