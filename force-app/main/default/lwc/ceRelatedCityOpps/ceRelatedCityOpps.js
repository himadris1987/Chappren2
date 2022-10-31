import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getRelatedCityOpps from '@salesforce/apex/CERelatedOpps.getRelatedCityOpps';
import getRelatedCityOppsCount from '@salesforce/apex/CERelatedOpps.getRelatedCityOppsCount';
import updateOppAsCommericallyReady from '@salesforce/apex/CERelatedOpps.updateOppAsCommericallyReady';
//import necessary fields from SF
import OPPNAME_FIELD from '@salesforce/schema/Opportunity.Name';
import ACCOUNT_FIELD from '@salesforce/schema/Opportunity.AccountId';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import STAGE_FIELD from '@salesforce/schema/Opportunity.Stage__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Opportunity.RecordTypeId';
import OWNER_FIELD from '@salesforce/schema/Opportunity.OwnerId';

// row actions
const actions = [
    { label: 'Mark as Commercially Ready', name: 'mark_as_commercially_ready'}
];

//column definitions
const columnsDefs = [
    { label: 'Opportunity', fieldName: 'OpportunityUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: OPPNAME_FIELD.fieldApiName }, target: '_blank' }
    },
    { label: 'Account', fieldName: 'AccountNameUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: ACCOUNT_FIELD.fieldApiName }, target: '_blank' }
    },
    { label: 'Amount', fieldName: AMOUNT_FIELD.fieldApiName, type: 'currency', sortable: true, initialWidth: 150 },
    { label: 'Stage', fieldName: STAGE_FIELD.fieldApiName, type: 'text', sortable: true},
    { label: 'Record Type', fieldName: RECORDTYPE_FIELD.fieldApiName, type: 'text', sortable: true},
    { label: 'Opportunity Owner', fieldName: OWNER_FIELD.fieldApiName, type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

//used when sorting using dynamic soql query
const fieldNamesForApexSort = {
    OpportunityUrl: OPPNAME_FIELD.fieldApiName,
    AccountNameUrl: 'Account.Name',
    Amount: AMOUNT_FIELD.fieldApiName,
    Stage__c: STAGE_FIELD.fieldApiName,
    RecordTypeId: 'RecordType.Name',
    OwnerId: 'Owner.Name'
};
//used when sorting using javaScript
const fieldNamesForJSSort = {
    OpportunityUrl: OPPNAME_FIELD.fieldApiName,
    AccountNameUrl: ACCOUNT_FIELD.fieldApiName,
    Amount: AMOUNT_FIELD.fieldApiName,
    Stage__c: STAGE_FIELD.fieldApiName,
    RecordTypeId: RECORDTYPE_FIELD.fieldApiName,
    OwnerId: OWNER_FIELD.fieldApiName
};

export default class CeRelatedCityOpps extends LightningElement {
    @api recordId;
    @api rowLimit = 25;
    columns = columnsDefs;
    showLoadingSpinner = false;
    sortDirection;
    sortBy;
    apexSortBy;
    apexSortDirection;
    error;
    data = [];
    rowOffSet = 0;
    totalNumberOfRows=0;
    tableElement;

    connectedCallback() {
        this.apexSortBy = 'Amount';
        this.apexSortDirection = 'DESC';
        this.getTotalNumberOfRows();
        this.fetchData();
    }

    setLoadingSpinner(status) {
        (this.tableElement) ? this.tableElement.isLoading = status : this.showLoadingSpinner = status;
    }
    
    getTotalNumberOfRows() {
        return getRelatedCityOppsCount({ expanCityRecId: this.recordId })
            .then(result => {
                this.totalNumberOfRows = result;
            });
    }
    
    async fetchData(){
        this.setLoadingSpinner(true);
        try {
            const result = await getRelatedCityOpps({ expanCityRecId: this.recordId, limitSize: this.rowLimit, offset: this.rowOffSet, sortField: this.apexSortBy, sortDir: this.apexSortDirection });
            let tempResult = [];
            result.forEach(oppRec => {
                let tempRec = Object.assign({}, oppRec);
                // Hard coding for now. Will look into navigation
                tempRec.OpportunityUrl = '/lightning/r/Opportunity/' + tempRec.Id + '/view';
                tempRec.AccountNameUrl = '/lightning/r/Account/' + tempRec.AccountId + '/view';
                if (tempRec.AccountId) tempRec.AccountId = tempRec.Account.Name;
                if (tempRec.RecordTypeId) tempRec.RecordTypeId = tempRec.RecordType.Name;
                if (tempRec.OwnerId) tempRec.OwnerId = tempRec.Owner.Name;
                tempResult.push(tempRec);
            });
            //Append current data to existing data.
            this.data = [...this.data, ...tempResult];
            this.error = undefined;
            this.setLoadingSpinner(false);
        } catch (error) {
            this.error = error;
            this.data = undefined;
            this.setLoadingSpinner(false);
        }
    }

    loadMoreData(event) {
        if (this.data.length >= this.totalNumberOfRows) {
            event.target.enableInfiniteLoading = false;
        } else {
            this.tableElement = event.target;
            if (this.tableElement) event.target.isLoading = true;
            this.rowOffSet += this.rowLimit;
            this.fetchData();
        }
    }

    doSorting(event) {
        let sortbyField = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        //If full data is not retrived use apex method to build a dynamic soql query
        if (this.data.length < this.totalNumberOfRows) {
            this.apexSortDirection = this.sortDirection
            this.apexSortBy = fieldNamesForApexSort[sortbyField];
            this.data = []; //reset data before retrieving data from SF
            this.rowOffSet = 0;
            this.fetchData();
        } else { //if all the data is retrived, use JS to do sorting
            this.sortBy = fieldNamesForJSSort[sortbyField];
            this.sortDirection = event.detail.sortDirection;
            this.sortData(this.sortBy, this.sortDirection);
        }
        this.sortBy = sortbyField;
    }

    sortData(fieldname, direction) {
        let cloneData = [...this.data];
        // Return the value stored in the field
        let keyValue = (fieldValue) => fieldValue[fieldname];
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data 
        cloneData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            if (fieldname === AMOUNT_FIELD.fieldApiName) {
                return isReverse * ((x > y) - (y > x));
            } else {
                return isReverse * x.toLowerCase().localeCompare(y.toLowerCase());
            }
        });
        this.data = cloneData;
    };

    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let currentOpp = event.detail.row;
        switch (actionName) {
            case 'mark_as_commercially_ready':
                this.markOppAsCommerciallyReady(currentOpp);
                break;
        }
    }

    markOppAsCommerciallyReady(currentOpp) {
        this.showLoadingSpinner = true;
        updateOppAsCommericallyReady({ expanCityRecId: this.recordId, oppRecId: currentOpp.Id })
            .then(result => {
                this.showLoadingSpinner = false;
                this.showSuccessMessage(currentOpp.Name);
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                this.showErrorMessage(currentOpp.Name, error);
            })
    }

    showSuccessMessage(oppName) {
        const eventSuccess = new ShowToastEvent({
            title: `SUCCESS: Opportunity (${oppName}) has been marked as Commercially Ready.`,
            message: 'Once this page is refreshed this Opportunity will be dropped from All Geo Opps Tab.',
            variant: 'success',
            mode: 'sticky'
        });
        this.dispatchEvent(eventSuccess);
    }

    showErrorMessage(oppName, error) {
        const eventError = new ShowToastEvent({
            title: `Error while updating Opportunity (${oppName}).`,
            message: error.body.message,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(eventError);
    }
 }