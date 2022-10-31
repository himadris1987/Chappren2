@RestResource(urlMapping='/stripe')
global class StripeWebhookEndpoint {
    
    //POST Request
    @HttpPost
    global static void processEvent() {
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        String event = (String)response.get('type');

        if (event.startsWith('charge')) {
            processCharge(response);
        } else if (event.startsWith('invoice')) {
            processInvoice(response);
        } else if (event.startsWith('coupon')) {
            processCoupon(response);
        }

        RestContext.response.statusCode = 200;
    }

    private static void processCharge(Map<String, Object> data) {
        system.debug('processing processCharge');

        Map<String, Object> dataObj = (Map<String,Object>)((Map<String, Object>)data.get('data')).get('object');

        String chargeId = (String)dataObj.get('id');
        Decimal amount = ((Decimal)dataObj.get('amount'))/100; //Stripe stores money in the smallest denomination (cents)
        String customerId = (String)dataObj.get('customer');
        String invoiceId = (String)dataObj.get('invoice');
        String receiptUrl = (String)dataObj.get('receipt_url');

        String status;
        if ((String)data.get('type') == 'charge.succeeded') {
            status = 'success';
        } else {
            status = 'failed';
        }

        Payment_Result__c result = new Payment_Result__c(
            Charge_ID__c = chargeId,
            Customer_ID__c = customerId,
            Invoice_ID__c = invoiceId,
            Status__c = status,
            Receipt_URL__c = receiptUrl,
            Amount__c = amount,
            Source__c = 'Stripe Charge/Invoice',
            Gateway__c = getGatewayId()
        );

        PaymentResultProcessingService.upsertPaymentResult(result);

    }

    private static void processInvoice(Map<String, Object> data) {
        system.debug('processing processInvoice');

        //Pull the Object Data out of the event.
        Map<String, Object> dataObj = (Map<String,Object>)((Map<String, Object>)data.get('data')).get('object');

        //Get the invoiceId from the dataObj.
        String invoiceId = (String)dataObj.get('id');
        String customerId = (String)dataObj.get('customer');
        String chargeId = (String)dataObj.get('charge');

        //Get the subscription.
        String subscriptionId;
        try {
            subscriptionId = (String)((Map<String,Object>)((List<Object>)((Map<String, Object>)dataObj.get('lines')).get('data'))[0]).get('id');
        } catch(Exception ex) {
            subscriptionId = null;
        }

        String status;

        if ((String)data.get('type') == 'invoice.payment_succeeded') {
            status = 'success';
        } else {
            status = 'failed';
        }

        Payment_Result__c result = new Payment_Result__c(
            Charge_ID__c = chargeId,
            Customer_ID__c = customerId,
            Invoice_ID__c = invoiceId,
            Subscription_ID__c = subscriptionId,
            Status__c = status,
            Source__c = 'Stripe Charge/Invoice',
            Gateway__c = getGatewayId()
        );

        PaymentResultProcessingService.upsertPaymentResult(result);
    }

    private static void processCoupon(Map<String, Object> data) {
        Map<String, Object> dataObj = (Map<String,Object>)((Map<String, Object>)data.get('data')).get('object');

        String name = (String)dataObj.get('name');
        String code = (String)dataObj.get('id');
        Boolean valid = (Boolean)dataObj.get('valid');
        Integer amount_off = (Integer)dataObj.get('amount_off');
        Integer duration_in_months = (Integer)dataObj.get('duration_in_months');
        String duration = (String)dataObj.get('duration');

        Datetime redeem_by;
        if (dataObj.containsKey('redeem_by') && dataObj.get('redeem_by') != null) {
            redeem_by = Datetime.newInstance((Long)dataObj.get('redeem_by')*1000);
        }

        Integer times_redeemed = (Integer)dataObj.get('times_redeemed');
        Integer max_redemptions = (Integer)dataObj.get('max_redemptions');

        Discount__c record = new Discount__c();

        List<Discount__c> existing = [SELECT Id, Name, Code__c, Valid__c, Amount_Off__c  FROM Discount__c WHERE Code__c = :code];

        if (existing.size() > 0) {
            record = existing[0];
        } else {
            record = new Discount__c();
        }

        String type = (String)data.get('type');
        if (type == 'coupon.created') {
            
        } else if (type == 'coupon.updated' || type == 'coupon.deleted') {
           
            if (type=='coupon.deleted') {
                delete record;
                return;
            }
        }

        record.Name = name;
        record.Code__c = code;
        record.Valid__c = valid;
        if(amount_off != null) {
            record.Amount_Off__c = amount_off/100;
        }

        if (dataObj.containsKey('redeem_by')) {
            record.Redeem_By__c = redeem_by;
        }

        record.Gateway__c = getGatewayId();
        record.Times_Redeemed__c = times_redeemed;
        record.Duration__c = duration;
        record.Max_Redemptions__c = max_redemptions;
        record.Duration_In_Months__c = duration_in_months;

        upsert record;
    }

    public static Id getGatewayId() {
        Map<String, String> params = RestContext.request.params;
        if (params.containsKey('gateway')) {
            String department = params.get('gateway');
            Gateway__c gateway = CredentialService.getStripeGateway(department);
            return gateway.Id;
        } else {
            return null;
        }
    }

}