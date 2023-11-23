import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveImageApex from '@salesforce/apex/TesingSignatureController.saveImage';

export default class ImageUploader extends LightningElement {
    @track showImageSection = false;
    @track selectedImage = null;
    spinner = false;
    acceptedFormats = '.png, .jpg, .jpeg';
    @track showButtons=false;

    showImageSectionHandler() {
        this.showImageSection = true;
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.selectedImage = reader.result;
                console.log("this selcted imge ",this.selectedImage);
                this.showButtons=true;
            };
            reader.readAsDataURL(file);
        }
    }
    isSignatureProvided = false;
    saveImage() {
        console.log("save image ");
        this.spinner = true;
        if (!this.selectedImage) {
            return;
        }
        
        // Remove the data type from the base64 string, so only the data remains.
        const base64Data = this.selectedImage.split(',')[1];
        console.log("base64Data ",base64Data);
        //alert(base64Data);
        saveImageApex({ base64Image: base64Data })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Image saved successfully',
                        variant: 'success'
                    })
                );
                this.isSignatureProvided = true;
                this.dispatchSignatureProvidedEvent();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    dispatchSignatureProvidedEvent() {
        //alert('child');
        this.spinner = false;
        this.dispatchEvent(new CustomEvent('increasecount', {
            detail: {
                message:  this.isSignatureProvided
            }
        }));
    }
}