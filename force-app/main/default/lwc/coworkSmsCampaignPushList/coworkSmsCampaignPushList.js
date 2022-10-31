import { LightningElement, wire } from 'lwc';
import getCoworkSmsCampaignPush from '@salesforce/apex/CoworkSmsCampaignController.getCoworkSmsCampaignPush';

export default class CoworkSmsCampaignList extends LightningElement {
    @wire(getCoworkSmsCampaignPush, {}) campaignPushes;
}