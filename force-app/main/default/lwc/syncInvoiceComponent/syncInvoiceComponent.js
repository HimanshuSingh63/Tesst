import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import syncInvoiceWithXero from '@salesforce/apex/XeroInvoiceSyncController.syncInvoiceWithXero';
import USER_ID from '@salesforce/user/Id';

export default class SyncInvoiceComponent extends LightningElement {
    @api recordId;
    isSyncing = false;
    syncStatus = 'Ready to sync';
    @track userId = USER_ID;
    

    handleSync() {
        console.log('recordId', this.recordId);
        this.isSyncing = true;
        this.syncStatus = 'Sync in progress';

        syncInvoiceWithXero({ invoiceId: this.recordId })
            .then(result => {
                this.syncStatus = 'Sync completed';
                this.showToast('Success', result, 'success');
            })
            .catch(error => {
                this.syncStatus = 'Sync failed';
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.isSyncing = false;
            });
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}