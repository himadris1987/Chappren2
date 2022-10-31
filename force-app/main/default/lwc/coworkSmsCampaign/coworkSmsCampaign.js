import { LightningElement, wire, track } from 'lwc';
import sendMessages from '@salesforce/apex/CoworkSmsCampaignController.sendMessages';
import getTotalContact from '@salesforce/apex/CoworkSmsCampaignController.getTotalContact';

export default class CoworkSmsCampaign extends LightningElement {
    smsContent = '';
    message = '';
    @wire(getTotalContact, {}) totalContacts;
    @track isModalOpen = false;
    @track messageOnly = false;
    
    onSmsContentInputChange(event) {
        this.smsContent = event.detail.value;
    }

    confirmMessage() {
        console.log('SMS: ', this.smsContent);
        console.log('SMS: ', this.totalContacts.data);

        if (this.totalContacts.data <= 0) {
            this.message = 'There are no contacts to send message to. Please contact support.';
            this.messageOnly = true;
        } else if (this.smsContent.trim().length <= 0) {
            this.message = 'Cannot send empty message.';
            this.messageOnly = true;
        }        

        this.isModalOpen = true;
    }
    
    sendMessage() {
        sendMessages({'smsContent': this.smsContent});
        this.smsContent = '';
        this.messageOnly = true;
        this.message = 'Messages are being sent!';
    }

    closeModal() {
        this.isModalOpen = false;
        this.messageOnly = false;
        this.message = '';
    }
}