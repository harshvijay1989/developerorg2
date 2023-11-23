import { LightningElement,track } from 'lwc';
//import identityImage from '@salesforce/resourceUrl/Identity';
//import identityPan from '@salesforce/resourceUrl/Pan';
//import identityDocument from '@salesforce/resourceUrl/Document';
import insertLead from '@salesforce/apex/CustomerOnBoardingController.createAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CreateGuestDealer extends LightningElement {
    loaded = false;
    @track currentPage = "1";
    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;

    @track phone = '';
    @track email = '';
    @track lastName = '';
    @track firstName = '';
    @track showResult = false;
    @track leadDetail = [];

    //@track imgs = identityImage;
    //@track imgsPan = identityPan;
    //@track imgsDoc = identityDocument;
    @track selectedIdentity = [];
    @track selectedPan = [];
    @track selectedDocument = [];

    activeSections = ['A'];

    nextPage(event){
        
        var value = event.target.value;
        var label = event.target.label;
        
        console.log(' Value : ',value);
        console.log(' Label : ',label);

        if(label == 'Next'){
            if(value < 3){
                value = parseInt(value) + 1;
            }
        }

        if(label == 'Previous'){
            if(value > 1){
                value = parseInt(value) - 1;
            }
        }
        
        if(value == 1){
            this.stepOne = true;
            this.stepTwo = false;
            this.stepThree = false;
            this.currentPage = "1";
            this.showResult = false;
            this.leadDetail = [];

        }else if(value == 2){
            if(this.validationMethod()){
                this.stepOne = false;
                this.stepTwo = true;
                this.stepThree = false;
                this.currentPage = "2";
            }
        }else if(value == 3){
            if(this.validationMethod()){
                this.stepOne = false;
                this.stepTwo = false;
                this.stepThree = true;
                this.currentPage = "3";
            }
        }
    }

    // Document set in array
    handleChangeDoc(event){
        var doc = event.target.dataset.type;
        var f = event.target.files;
        if(doc == 'identity'){
            if (f) {
                for (let i = 0; i < f.length; i++) {
                    const file = f[i];
                    this.selectedIdentity.push({
                        id: Date.now() + i,
                        name: file.name,
                        file: file
                    });
                }
            } else {
                alert("Failed to load file name");
            }

        }else if(doc == 'pan'){
            if (f) {
                for (let i = 0; i < f.length; i++) {
                    const file = f[i];
                    this.selectedPan.push({
                        id: Date.now() + i,
                        name: file.name,
                        file: file
                    });
                }
            } else {
                this.showToast('Error','Failed to load file name','error','dismissable');
            }
        }else if(doc == 'document'){
            if (f) {
                for (let i = 0; i < f.length; i++) {
                    const file = f[i];
                    this.selectedDocument.push({
                        id: Date.now() + i,
                        name: file.name,
                        file: file
                    });
                }
            } else {
                this.showToast('Error','Failed to load file name','error','dismissable');
            }
        }
    }
    // Remove Delete
    handleDeleteFile(event) {
        const fileId = event.currentTarget.dataset.id;
        if(fileId){
            for (let i = 0; i < this.selectedIdentity.length; i++) {
                var idx = this.selectedIdentity.indexOf(fileId);
                if(this.selectedIdentity[i].id == fileId){
                    this.selectedIdentity.splice(idx);
                }
            }
        }

        if(fileId){
            for (let i = 0; i < this.selectedPan.length; i++) {
                var idx = this.selectedPan.indexOf(fileId);
                if(this.selectedPan[i].id == fileId){
                    this.selectedPan.splice(idx);
                }
            }
        }

        if(fileId){
            for (let i = 0; i < this.selectedDocument.length; i++) {
                var idx = this.selectedDocument.indexOf(fileId);
                if(this.selectedDocument[i].id == fileId){
                    this.selectedDocument.splice(idx);
                }
            }
        }
    }

    

    handleChangeFirstName(){
        this.firstName = event.target.value;
    }
    handleChangeLastName(event){
        this.lastName = event.target.value;
    } 

    handleChangePhone(event){
        this.phone = event.target.value;
    } 
    
    handleChangeEmail(event){
        this.email = event.target.value;
    } 

    validationMethod(){
        var result = false;
        let lname = this.template.querySelector('.lastName');
        if(this.lastName.length == 0){
            lname.setCustomValidity('Last Name is required');
            result = false;
        }else{
            lname.setCustomValidity('');
           result =  true;
        }
        lname.reportValidity();
        return result;
    }

    //  click on save button
    handleSave(){
        this.loaded = true;
        insertLead({ 'firstName': this.firstName,'lastName' : this.lastName, 'phone' : this.phone, 'email' : this.email})
        .then(result =>{
            this.firstName='';
            this.lastName='';
            this.email='';
            this.showResult = true;

            // code for show result
            this.stepOne = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.currentPage = "3";
            this.leadDetail = result;  
            this.loaded = false;
            this.showToast('Registration Success','Registration number : '+this.leadDetail.Registration_Number__c,'success','dismissable');
        })
        .catch(error =>{
            console.log(' Error : ',error);
        })
    
    }

    showToast(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}