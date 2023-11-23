import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAccount from '@salesforce/apex/MainClassAccount.createAccount';
import cycle from '@salesforce/resourceUrl/cycle';
//import dealerCreationBG from '@salesforce/resourceUrl/dealerCreationBG';
import homeimage from '@salesforce/resourceUrl/homeimage';


//Document Screen Components
// import uploadDocumentScreen from './dms_uploadDocumentScreen';
import identityImage from '@salesforce/resourceUrl/Identity';
import identityPan from '@salesforce/resourceUrl/Pan';
import identityDocument from '@salesforce/resourceUrl/Document';

export default class Dms_BasicDetailsAccount extends LightningElement {
    @track screenType = 'account';

    @track accountFirstName = '';
    @track accountLastName = '';
    @track accountEmail = '';
    @track accountPhone = '';
    @track shopName = '';
    @track otp = '';
    @track billingStreet = '';
    @track billingCity = '';
    @track billingCountry = '';
    @track billingProvince = '';
    @track billingPostalCode = '';
    @track disableSendOTPButton = true;
    @track selectedRegion = '';
    @track shippingStreet = '';
    @track shippingCity = '';
    @track shippingCountry = '';
    @track shippingProvince = '';
    @track shippingPostalCode = '';
    @track regionOptions = [
        { label: 'India', value: 'India' },
        { label: 'US', value: 'US' },
        { label: 'Italy', value: 'Italy' },
        { label: 'Sri Lanka', value: 'Sri Lanka' },
        { label: 'China', value: 'China' }
    ];
    @track isSameAsBilling = false;
    @track showOTP = false;
    @track showSaveButton = true;

    @track isNameInvalid = false;
    @track isPhoneInvalid = false;
    @track isEmailInvalid = false;
    @track isShopNameInvalid = false;
    @track showSpinner = true;
    fieldData;
    @track showSpinner = false;
    @track dealerName;
    @track dealer;
    @track dealerId;
    // @track dealerId = '0015j00001CX5BzAAL';
    @track isform = true;
    @track otpButtonLabel = 'Send OTP';
   //@track backgroundStyle = `background-image: url(${dealerCreationBG});background-repeat:no-repeat;background-size:cover;width:100%`;


    //Document Screen Variables
    @track imgs = identityImage;
    @track imgsPan = identityPan;
    @track imgsDoc = identityDocument;

    @track docIdUploaded = false;
    @track docPanUploaded = false;
    @track docOtherUploaded = false;

    @track idDocMsg;
    @track panDocMsg;
    @track otherDocMsg;

    activeSections = ['A', 'B'];



    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg'];
    }

    get showDocumentScreen() {
        return this.screenType != 'account' ? true : false;
    }

    handleNameChange(event) {
        this.accountFirstName = event.target.value;
        this.isNameInvalid = !this.isValidName(this.accountFirstName);
    }
    handleRegionChange(event) {
        this.selectedRegion = event.target.value;
    }
    handleEmailChange(event) {
        this.accountEmail = event.target.value;
        this.isEmailInvalid = !this.isValidEmail(this.accountEmail);
    }

    handlePhoneChange(event) {
        this.accountPhone = event.target.value;
        this.isPhoneInvalid = !this.isValidPhone(this.accountPhone);

        if (this.accountPhone.length === 10) {
            this.disableSendOTPButton = false;
        } else {
            this.disableSendOTPButton = true;
        }
    }

    handleShopNameChange(event) {
        this.shopName = event.target.value;
        this.isShopNameInvalid = !this.isValidShopName(this.shopName);
    }
    handleLastNameChange(event) {
        this.accountLastName = event.target.value;
        this.isLastNameInvalid = !this.isValidName(this.accountLastName); // Add validation logic if needed
    }

    handleOTPChange(event) {
        this.otp = event.target.value;
    }

    handleSendOTP() {
        const isFormValid = (
            this.isValidName(this.accountFirstName) &&
            this.isValidEmail(this.accountEmail) &&
            this.isValidPhone(this.accountPhone) &&
            this.isValidShopName(this.shopName) &&
            this.isValidName(this.accountLastName)
        );
        if (!isFormValid) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please fill in all required fields correctly.',
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
        } else {
            this.otpButtonLabel = 'Resend OTP';

            this.showSpinner = true; // Show the spinner when Send OTP is clicked

            // Simulate a 4-second delay and then hide the spinner
            setTimeout(() => {
                this.showSpinner = false;
                this.showSaveButton = false;
                this.showOTP = true;
            }, 2000);
        }
    }

    handleBillingAddressChange(event) {
        this.billingStreet = event.detail.street;
        this.billingCity = event.detail.city;
        this.billingCountry = event.detail.country;
        this.billingProvince = event.detail.province;
        this.billingPostalCode = event.detail.postalCode;

        if (this.isSameAsBilling) {
            this.copyBillingToShipping();
        }
    }

    handleShippingAddressChange(event) {
        this.shippingStreet = event.detail.street;
        this.shippingCity = event.detail.city;
        this.shippingCountry = event.detail.country;
        this.shippingProvince = event.detail.province;
        this.shippingPostalCode = event.detail.postalCode;
    }

    handleSameAsBillingChange(event) {
        this.isSameAsBilling = event.target.checked;

        if (!this.isSameAsBilling) {
            // Clear the shipping address fields when the checkbox is unchecked
            this.shippingStreet = '';
            this.shippingCity = '';
            this.shippingCountry = '';
            this.shippingProvince = '';
            this.shippingPostalCode = '';
        } else {
            // Copy the billing address to the shipping address when the checkbox is checked
            this.copyBillingToShipping();
        }
    }

    copyBillingToShipping() {
        this.shippingStreet = this.billingStreet;
        this.shippingCity = this.billingCity;
        this.shippingCountry = this.billingCountry;
        this.shippingProvince = this.billingProvince;
        this.shippingPostalCode = this.billingPostalCode;
    }

    isValidName(name) {
        return name.length > 0;
    }

    isValidEmail(email) {
        return /\S+@\S+\.\S+/.test(email);
    }

    isValidPhone(phone) {
        return /^\d{10}$/.test(phone);
    }

    isValidShopName(shopName) {
        return shopName.length > 0;
    }

    handleSave() {
        if (this.otp.length === 6) { // Check if OTP matches
            this.convertJOSN();
            this.getData();

        } else {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'OTP is incorrect. Please try again.',
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
        }
    }
    getData() {
        createAccount({ data1: JSON.stringify(this.fieldData) })
            .then(result => {
                console.log('result: ' + result);
                var data = JSON.parse(result);
                this.dealer = data;
                this.dealerId = data.Id;
                this.isform = false;
                this.handleUploadDocumentScreen();
                // const toastEvent = new ShowToastEvent({
                //     title: 'Success',
                //     message: 'Account successfully saved!',
                //     variant: 'success',
                // });
                // this.dispatchEvent(toastEvent);
            })
            .catch(error => {
                console.log('error' + JSON.stringify(error));
                const { message, statusCode } = error.body.pageErrors[0];
                const toastEvent = new ShowToastEvent({
                    title: statusCode,
                    message: message,
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);


            });

    }

    //Handling Document Screen
    handleUploadDocumentScreen() {
        this.screenType = 'documentUpload';
    }

    // Add this method to your JavaScript
    validateOTP(event) {
        const keyCode = event.keyCode;
        // Allow numeric keys (0-9) and backspace (8)
        if (!((keyCode >= 48 && keyCode <= 57) || keyCode === 8)) {
            event.preventDefault();
        }
    }


    convertJOSN() {
        this.fieldData = {
            "First Name": this.accountFirstName,
            "Last Name": this.accountLastName,
            "Email": this.accountEmail,
            "Phone": this.accountPhone,
            "Shop Name": this.shopName,
            "Billing Street": this.billingStreet,
            "Billing City": this.billingCity,
            "Billing Country": this.billingCountry,
            "Billing Province": this.billingProvince,
            "Billing Postal Code": this.billingPostalCode,
            "Shipping Street": this.shippingStreet,
            "Shipping City": this.shippingCity,
            "Shipping Country": this.shippingCountry,
            "Shipping Province": this.shippingProvince,
            "Shipping Postal Code": this.shippingPostalCode,
            "Region": this.selectedRegion

        };
        console.log(JSON.stringify(this.fieldData));
    }

    isValidOTP(otp) {
        return otp.length === 6;
    }

    //Dealer Screen Functions
    handleFileChange(event) {
        var index = parseInt(event.currentTarget.dataset.index);

    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        var fileName = '';
        if (uploadedFiles.length > 0) {
            // Get the first file's name as an example
            fileName = uploadedFiles[0].name;
        } else {
            fileName = 'No file uploaded';
        }

        var index = parseInt(event.currentTarget.dataset.index);
        if (index == 1) {
            this.showToast('Success: ', 'Identity Document Uploaded Successfully.', 'success');
            this.idDocMsg = fileName;
            // this.docIdUploaded = true;
        } else if (index == 2) {
            this.showToast('Success: ', 'Pan Document Uploaded Successfully.', 'success');
            this.panDocMsg = fileName;
            // this.docPanUploaded = true;
        } else if (index == 3) {
            this.showToast('Success: ', 'Other Documents Uploaded Successfully.', 'success');
            this.otherDocMsg = fileName;
            // this.docOtherUploaded = true;
        }
    }

    handleUploadClicked(event) {
        // var index = event.currentTarget.dataset.index;
        // console.log('index: ' + index);
    }

    handleSubmit() {
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Account successfully saved!',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);
        this.dealerName = this.dealer.Name;
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
}