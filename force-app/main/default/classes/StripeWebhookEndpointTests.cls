@isTest
public class StripeWebhookEndpointTests {
    public static void setup() {
        StripePaymentServiceMock mock = new StripePaymentServiceMock();
        StripePaymentService.instance = mock;
        
        GoogleCalendarServiceMock gCalMock = new GoogleCalendarServiceMock();
        GoogleCalendarService.instance = gCalMock;
    }


    @isTest
    public static void testProcessEventChargeSucceeded() {
        setup();
        String req = '{' +
                     '    "data":{' +
                     '        "object": {' +
                     '            "id": "CHARGE_ID",' +
                     '            "amount": 3000,' +
                     '            "customer": "CUSTOMER_ID",' +
                     '            "invoice": null,' +
                     '            "receipt_url": "http://reciepts.com/test.pdf"' +
                     '        }' +
                     '    },' +
                     '    "type": "charge.succeeded"' +
                     '}';

        RestRequest request = new RestRequest();
        RestResponse resp = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/stripe';
        request.httpMethod = 'POST';

        request.requestBody = Blob.valueOf(req);

        RestContext.request = request;
        RestContext.response = resp;
        
        Test.startTest();
        StripeWebhookEndpoint.processEvent();
        Test.stopTest();

        List<Payment_Result__c> results = [SELECT Id, Status__c, Charge_ID__c FROM Payment_Result__c];
        
        System.assertEquals(1, results.size());

        Payment_Result__c res = results[0];

        System.assertEquals('success', res.Status__c);
        System.assertEquals('CHARGE_ID', res.Charge_ID__c);
    }

    @isTest
    public static void testProcessEventChargeFailed() {
        setup();
        String req = '{' +
                     '    "data":{' +
                     '        "object": {' +
                     '            "id": "CHARGE_ID",' +
                     '            "amount": 3000,' +
                     '            "customer": "CUSTOMER_ID",' +
                     '            "invoice": null,' +
                     '            "receipt_url": "http://reciepts.com/test.pdf"' +
                     '        }' +
                     '    },' +
                     '    "type": "charge.failed"' +
                     '}';

        RestRequest request = new RestRequest();
        RestResponse resp = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/stripe';
        request.httpMethod = 'POST';

        request.requestBody = Blob.valueOf(req);

        RestContext.request = request;
        RestContext.response = resp;
        
        Test.startTest();
        StripeWebhookEndpoint.processEvent();
        Test.stopTest();

        List<Payment_Result__c> results = [SELECT Id, Status__c, Charge_ID__c FROM Payment_Result__c];
        
        System.assertEquals(1, results.size());

        Payment_Result__c res = results[0];

        System.assertEquals('failed', res.Status__c);
        System.assertEquals('CHARGE_ID', res.Charge_ID__c);
    }

    @isTest
    public static void testProcessEventInvoiceSucceeded() {
        setup();
        String req = '{' +
                     '    "data" : {' +

                     '        "object": {' +
                     '            "id": "INVOICE_ID",' +
                     '            "charge": "CHARGE_ID",' +
                     '            "customer": "CUSTOMER_ID",' +
                     '            "lines": {' +
                     '                "data": [' +
                     '                    {' +
                     '                        "id": "SUBSCRIPTION_ID"' +
                     '                    }' +
                     '                ]' +
                     '                ' +
                     '            }' +
                     '        }' +
                     '    },' +
                     '    "type" : "invoice.payment_succeeded"' +
                     '}' ;

        RestRequest request = new RestRequest();
        RestResponse resp = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/stripe';
        request.httpMethod = 'POST';

        request.requestBody = Blob.valueOf(req);

        RestContext.request = request;
        RestContext.response = resp;
        
        Test.startTest();
        StripeWebhookEndpoint.processEvent();
        Test.stopTest();

        List<Payment_Result__c> results = [SELECT Id, Status__c, Invoice_ID__c FROM Payment_Result__c];
        
        System.assertEquals(1, results.size());

        Payment_Result__c res = results[0];

        System.assertEquals('success', res.Status__c);
        System.assertEquals('INVOICE_ID', res.Invoice_ID__c);
    }

    @isTest
    public static void testProcessEventInvoiceFailed() {
        setup();
        String req = '{' +
                     '    "data" : {' +

                     '        "object": {' +
                     '            "id": "INVOICE_ID",' +
                     '            "charge": "CHARGE_ID",' +
                     '            "customer": "CUSTOMER_ID",' +
                     '            "lines": {' +
                     '                "data": [' +
                     '                    {' +
                     '                        "id": "SUBSCRIPTION_ID"' +
                     '                    }' +
                     '                ]' +
                     '                ' +
                     '            }' +
                     '        }' +
                     '    },' +
                     '    "type" : "invoice.payment_failed"' +
                     '}' ;

        RestRequest request = new RestRequest();
        RestResponse resp = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/stripe';
        request.httpMethod = 'POST';

        request.requestBody = Blob.valueOf(req);

        RestContext.request = request;
        RestContext.response = resp;
        
        Test.startTest();
        StripeWebhookEndpoint.processEvent();
        Test.stopTest();

        List<Payment_Result__c> results = [SELECT Id, Status__c, Invoice_ID__c FROM Payment_Result__c];
        
        System.assertEquals(1, results.size());

        Payment_Result__c res = results[0];

        System.assertEquals('failed', res.Status__c);
        System.assertEquals('INVOICE_ID', res.Invoice_ID__c);
    }



    @isTest
    public static void testProcessEventCouponCreated() {
        setup();
        String req = '{' +
                     '    "data" : {' +
                     '        "object": {' +
                     '            "id" : "TESTCOUPON",' +
                     '            "amount_off": 1000,' +
                     '            "currency":"usd",' +
                     '            "name":"Test Coupon",' +
                     '            "valid":true,' +
                     '            "duration_in_months":6,' +
                     '            "duration":"repeating",' +
                     '            "redeem_by":1569447532,' +
                     '            "max_redemptions":10,' +
                     '            "times_redeemed":0' +
                     '        }' +
                     '    },' +
                     '    "type" : "coupon.created"' +
                     '}';

        RestRequest request = new RestRequest();
        RestResponse resp = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/stripe';
        request.httpMethod = 'POST';

        request.requestBody = Blob.valueOf(req);

        RestContext.request = request;
        RestContext.response = resp;
        
        Test.startTest();
        StripeWebhookEndpoint.processEvent();
        Test.stopTest();

        List<Discount__c> discounts = [SELECT Id FROM Discount__c];

        System.assertNotEquals(0, discounts.size());
    }
}