public class XeroInvoiceSyncController {
    @AuraEnabled
    public static String syncInvoiceWithXero(Id invoiceId) {
        try {
            System.debug('invoiceId: ' + invoiceId);
            
            if (invoiceId == null) {

                System.debug('Could not find invoice ID');
                return 'Could not find invoice ID';
            }else {

                Custom_Invoice__c inv = [SELECT Id, TotalAmount__c, XeroInvoiceId__c,Status__c,BillToContact__c,Balance__c,
                                        (SELECT Id, LineAmount__c, Quantity__c, UnitPrice__c,Description__c
                                         FROM Custom_Invoice_Lines__r)
                                        FROM Custom_Invoice__c 
                                        WHERE Id = :invoiceId];
                System.debug('inv: ' + inv);

                if (String.isBlank(inv.XeroInvoiceId__c)) {
                  // Create new invoice in Xero
                  String xeroInvoiceId = XeroAPIWrapper.createInvoiceInXero(inv);
                  System.debug('xeroInvoiceID:'+xeroInvoiceId);

                  // Update Salesforce invoice with Xero Invoice ID
                  inv.XeroInvoiceId__c = xeroInvoiceId;
                  update inv;
                
                  return 'New invoice created in Xero with ID: ' + xeroInvoiceId;

                } else {

                  // Update existing invoice in Xero
                  XeroAPIWrapper.updateInvoiceInXero(inv);
                  return 'Existing Xero invoice updated with ID: ' + inv.XeroInvoiceId__c;

                }
            }
        } catch (Exception e) {

            return 'Error: ' + e.getMessage();
        }
    }
}