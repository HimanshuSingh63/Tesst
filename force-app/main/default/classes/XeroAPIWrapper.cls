public class XeroAPIWrapper {
    private static final String XERO_API_ENDPOINT = 'https://api.xero.com/api.xro/2.0/';
    
    public static String createInvoiceInXero(Custom_Invoice__c sfInvoice) {
        try {
             // Prepare the invoice data
        Map<String, Object> invoiceData = prepareInvoiceData(sfInvoice);
        String invoiceId;
        // Make the HTTP request
        HttpResponse response = makeHttpRequest('POST', 'Invoices', JSON.serialize(invoiceData));
        
        // Process the response
        if (response.getStatusCode() == 200) {
            // Parse the response and extract the Xero Invoice ID
            invoiceId =  parseInvoiceIdFromResponse(response.getBody());
        }
        return invoiceId;
        } catch (Exception e) {
            return e.getMessage();
        }
       
    }
    
    public static void updateInvoiceInXero(Custom_Invoice__c sfInvoice) {
        try {
            // Prepare the invoice data
        Map<String, Object> invoiceData = prepareInvoiceData(sfInvoice);
        
        // Make the HTTP request
        HttpResponse response = makeHttpRequest('POST', 'Invoices/' + sfInvoice.XeroInvoiceId__c, JSON.serialize(invoiceData));
        
        // Process the response
        if (response.getStatusCode() != 200) {
            throw new XeroAPIException('Failed to update invoice: ' + response.getBody());
        }
        } catch (Exception e) {
            
        }
        
    }
    
    private static HttpResponse makeHttpRequest(String method, String endpoint, String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(XERO_API_ENDPOINT + endpoint);
        request.setMethod(method);
        request.setHeader('Authorization', 'Bearer ' + getXeroAccessToken());
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        return http.send(request);
    }
    
    private static String getXeroAccessToken() {
        return 'your_access_token_here';
    }
    
    private static Map<String, Object> prepareInvoiceData(Custom_Invoice__c sfInvoice) {

        // Convert Salesforce invoice data to Xero format
       
        return new Map<String, Object>{
            'Type' => 'ACCREC',
            'Contact' => new Map<String, Object>{'ContactID' => sfInvoice.BillToContact__c},
            'LineItems' => prepareLineItems(sfInvoice.Custom_Invoice_Lines__r)
            // Add other necessary fields
        };
    }
    
    private static List<Object> prepareLineItems(List<Custom_Invoice_Line__c> lineItems) {
        // Convert Salesforce line items to Xero format
       
        List<Object> xeroLineItems = new List<Object>();
        for (Custom_Invoice_Line__c item : lineItems) {
            xeroLineItems.add(new Map<String, Object>{
                'Description' => item.Description__c,
                'Quantity' => item.Quantity__c,
                'UnitAmount' => item.UnitPrice__c
                // Add other necessary fields
            });
        }
        return xeroLineItems;
    }
    
    private static String parseInvoiceIdFromResponse(String responseBody) {
        // Parse the response JSON and extract the InvoiceID
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        List<Object> invoices = (List<Object>)responseMap.get('Invoices');
        Map<String, Object> invoice = (Map<String, Object>)invoices[0];
        return (String)invoice.get('InvoiceID');
    }
    
    public class XeroAPIException extends Exception {}
}