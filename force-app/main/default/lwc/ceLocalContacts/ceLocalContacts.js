import { LightningElement, api, wire } from 'lwc';
import getLocalContacts from '@salesforce/apex/CERelatedOpps.getLocalContacts';
import getLocalContactsCount from '@salesforce/apex/CERelatedOpps.getLocalContactsCount';
//import columns
import CON_NAME_FIELD from '@salesforce/schema/Contact.Name';
import CON_PRONOUNS_FIELD from '@salesforce/schema/Contact.Pronouns__c';
import CON_TITLE_FIELD from '@salesforce/schema/Contact.Title';
import CON_ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
import CON_ACTIVE_FIELD from '@salesforce/schema/Contact.Active_Contact__c';

const columnsDefs = [
    { label: 'Contact Name', fieldName: 'ContactNameUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: CON_NAME_FIELD.fieldApiName }, target: '_blank' }
    },
    { label: 'Pronouns', fieldName: CON_PRONOUNS_FIELD.fieldApiName, sortable: true },
    { label: 'Title', fieldName: CON_TITLE_FIELD.fieldApiName, sortable: true },
    { label: 'Account', fieldName: 'AccountNameUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: CON_ACCOUNT_FIELD.fieldApiName }, target: '_blank' }
    },
    { label: 'Active ?', fieldName: CON_ACTIVE_FIELD.fieldApiName, type: 'boolean', sortable: false },
];

//used in dynamic soql query
const fieldNamesForApexSort = {
    AccountNameUrl: 'Name',
    OwnerId: 'Owner.Name',
    Type: 'Type',
    PrimaryContactUrl: 'Primary_Contact__c'
};

//used when sorting using javascript
const fieldNamesForJSSort = {
    ContactNameUrl: CON_NAME_FIELD.fieldApiName,
    Pronouns__c: CON_PRONOUNS_FIELD.fieldApiName,
    Title: CON_TITLE_FIELD.fieldApiName,
    AccountNameUrl: CON_ACCOUNT_FIELD.fieldApiName,
    Active_Contact__c: CON_ACTIVE_FIELD.fieldApiName
};

export default class CeLocalContacts extends LightningElement {
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
    totalNumberOfRows = 0;
    tableElement;
    datatableHeight = 'height:400px;';

    connectedCallback() {
        this.apexSortBy = 'Name'; //default sord field
        this.apexSortDirection = 'ASC'; //default sort direction
        this.getTotalNumberOfRows();
        this.fetchData();
    }

    setLoadingSpinner(status) {
        (this.tableElement) ? this.tableElement.isLoading = status : this.showLoadingSpinner = status;
    }
    
    getTotalNumberOfRows() {
        return getLocalContactsCount({ expanCityRecId: this.recordId })
            .then(result => {
                this.totalNumberOfRows = result;
                this.datatableHeight = (result >= 12) ? 'height:400px;' : `height:${50+(result*25)}px;`
            });
    }
    
    async fetchData(){
        this.setLoadingSpinner(true);
        try {
            const result = await getLocalContacts({ expanCityRecId: this.recordId, limitSize: this.rowLimit, offset: this.rowOffSet, sortField: this.apexSortBy, sortDir: this.apexSortDirection });
            let tempResult = [];
            result.forEach(accRec => {
                let tempRec = Object.assign({}, accRec);
                // Hard coding for now. Will look into navigation
                tempRec.ContactNameUrl = '/lightning/r/Contact/' + tempRec.Id + '/view';
                if (tempRec.AccountId) {
                    tempRec.AccountNameUrl = '/lightning/r/Account/' + tempRec.AccountId + '/view';
                    tempRec.AccountId = tempRec.Account.Name;
                }
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
        return isReverse * x.toLowerCase().localeCompare(y.toLowerCase());            
        });
        this.data = cloneData;
    };    
}