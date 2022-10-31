import { LightningElement, api } from 'lwc';
import getRelatedAccounts from '@salesforce/apex/CERelatedOpps.getRelatedAccounts';
import getRelatedAccountsCount from '@salesforce/apex/CERelatedOpps.getRelatedAccountsCount';
//import columns
import ACC_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACC_OWNER_FIELD from '@salesforce/schema/Account.OwnerId';
import ACC_TYPE_FIELD from '@salesforce/schema/Account.Type';
import PRIMARY_CONTACT_FIELD from '@salesforce/schema/Account.Primary_Contact__c';

const columnsDefs = [
    { label: 'Account Name', fieldName: 'AccountNameUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: ACC_NAME_FIELD.fieldApiName }, target: '_blank' }
    },
    { label: 'Account Owner', fieldName: ACC_OWNER_FIELD.fieldApiName, type: 'text', sortable: true },
    { label: 'Type', fieldName: ACC_TYPE_FIELD.fieldApiName, type: 'text', sortable: true },
    { label: 'Primary Contact', fieldName: 'PrimaryContactUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: PRIMARY_CONTACT_FIELD.fieldApiName }, target: '_blank' }
    }
];

//these are used in dynamic soql query
const fieldNamesForApexSort = {
    AccountNameUrl: 'Name',
    OwnerId: 'Owner.Name',
    Type: 'Type',
    PrimaryContactUrl: 'Primary_Contact__c'
};

//these are used when sorting using javascript
const fieldNamesForJSSort = {
    AccountNameUrl: ACC_NAME_FIELD.fieldApiName,
    OwnerId: ACC_OWNER_FIELD.fieldApiName,
    Type: ACC_TYPE_FIELD.fieldApiName,
    PrimaryContactUrl: PRIMARY_CONTACT_FIELD.fieldApiName
};

export default class CeRelatedAccounts extends LightningElement {
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
    datatableHeight; 

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
        return getRelatedAccountsCount({ expanCityRecId: this.recordId })
            .then(result => {
                this.totalNumberOfRows = result;
                this.datatableHeight = (result >= 12) ? 'height:400px;' : `height:${50+(result*25)}px;`
            });
    }

    async fetchData(){
        this.setLoadingSpinner(true);
        try {
            const result = await getRelatedAccounts({ expanCityRecId: this.recordId, limitSize: this.rowLimit, offset: this.rowOffSet, sortField: this.apexSortBy, sortDir: this.apexSortDirection });
            let tempResult = [];
            result.forEach(accRec => {
                let tempRec = Object.assign({}, accRec);
                // Hard coding for now. Will look into navigation
                tempRec.AccountNameUrl = '/lightning/r/Account/' + tempRec.Id + '/view';
                if (tempRec.OwnerId) tempRec.OwnerId = tempRec.Owner.Name;
                if (tempRec.Primary_Contact__c != undefined) {
                    tempRec.PrimaryContactUrl = '/lightning/r/Contact/' + tempRec.Primary_Contact__c + '/view';
                    tempRec.Primary_Contact__c = tempRec.Primary_Contact__r.Name;
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