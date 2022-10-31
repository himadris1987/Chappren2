public class StripePaymentServiceCalloutMock implements HttpCalloutMock{
    string returnString;
    Integer statusCode;
    string mode;

    public StripePaymentServiceCalloutMock(String mode, Integer statusCode) {
        if (mode == 'customer') {
            returnString = customerData;
        } else if (mode == 'subscription') {
            returnString = subscriptionData;
        } else if (mode == 'charge') {
            returnString = chargeData;
        } else if (mode == 'discount') {
            returnString = couponData;
        } else if (mode == 'source') {
            returnString = sourceData;
        }

        this.statusCode = statusCode;
        this.mode = mode;

    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        if (mode == 'customer') {
            System.assert(req.getEndpoint().contains('customers'));
        } else if (mode == 'subscription') {
            System.assert(req.getEndpoint().contains('subscriptions'));
        } else if (mode == 'charge') {
            System.assert(req.getEndpoint().contains('charges'));
        }

        res.setBody(returnString);
        res.setStatusCode(statusCode);

        return res;
    }

    private string customerData = '{"id": "CUSTOMER_ID", "object": "customer", "account_balance": 0, "address": null, "balance": 0, "created": 1568138418, "currency": "usd", "default_source": null, "delinquent": false, "description": null, "discount": null, "email": null, "invoice_prefix": "EB30B26", "invoice_settings": {"custom_fields": null, "default_payment_method": null, "footer": null}, "livemode": false, "metadata": {}, "name": null, "phone": null, "preferred_locales": [], "shipping": null, "sources": {"object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/CUSTOMER_ID/sources"}, "subscriptions": {"object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/CUSTOMER_ID/subscriptions"}, "tax_exempt": "none", "tax_ids": {"object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/customers/CUSTOMER_ID/tax_ids"}, "tax_info": null, "tax_info_verification": null}';

    private string subscriptionData = '{"id": "SUBSCRIPTION_ID", "object": "subscription", "application_fee_percent": null, "billing": "charge_automatically", "billing_cycle_anchor": 1452892078, "billing_thresholds": null, "cancel_at": null, "cancel_at_period_end": false, "canceled_at": 1485814119, "collection_method": "charge_automatically", "created": 1452892078, "current_period_end": 1487192878, "current_period_start": 1484514478, "customer": "CUSTOMER_ID", "days_until_due": null, "default_payment_method": null, "default_source": null, "default_tax_rates": [], "discount": null, "ended_at": 1485814119, "items": {"object": "list", "data": [{"id": "si_08RR5825GAigWUtf5yFdy08i", "object": "subscription_item", "billing_thresholds": null, "created": 1452892078, "metadata": {}, "plan": {"id": "regular-monthly", "object": "plan", "active": true, "aggregate_usage": null, "amount": 3900, "amount_decimal": "3900", "billing_scheme": "per_unit", "created": 1445128942, "currency": "usd", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {"coupons": "MONTHLY10|HTX|GWX|#gkw#|#GKW#", "type": "cowork"}, "nickname": null, "product": "prod_BUg1xwt5HkBuOT", "tiers": null, "tiers_mode": null, "transform_usage": null, "trial_period_days": null, "usage_type": "licensed"}, "quantity": 1, "subscription": "SUBSCRIPTION_ID", "tax_rates": []}], "has_more": false, "total_count": 1, "url": "/v1/subscription_items?subscription=SUBSCRIPTION_ID"}, "latest_invoice": null, "livemode": false, "metadata": {}, "pending_setup_intent": null, "plan": {"id": "regular-monthly", "object": "plan", "active": true, "aggregate_usage": null, "amount": 3900, "amount_decimal": "3900", "billing_scheme": "per_unit", "created": 1445128942, "currency": "usd", "interval": "month", "interval_count": 1, "livemode": false, "metadata": {"coupons": "MONTHLY10|HTX|GWX|#gkw#|#GKW#", "type": "cowork"}, "nickname": null, "product": "prod_BUg1xwt5HkBuOT", "tiers": null, "tiers_mode": null, "transform_usage": null, "trial_period_days": null, "usage_type": "licensed"}, "quantity": 1, "schedule": null, "start": 1452892078, "start_date": 1452892078, "status": "canceled", "tax_percent": null, "trial_end": null, "trial_start": null}';

    private string chargeData = '{"id": "CHARGE_ID", "object": "charge", "amount": 5000, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_FlODWope99Nu0E", "billing_details": {"address": {"city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null}, "email": null, "name": "Tube Sock", "phone": null}, "captured": true, "created": 1373449369, "currency": "usd", "customer": "CUSTOMER_ID", "description": "Test Description", "destination": null, "dispute": null, "failure_code": null, "failure_message": null, "fraud_details": {}, "invoice": null, "livemode": false, "metadata": {}, "on_behalf_of": null, "order": null, "outcome": {"network_status": null, "reason": null, "risk_level": "not_assessed", "seller_message": "Payment complete.", "type": "authorized"}, "paid": true, "payment_intent": null, "payment_method": "cc_2AfS3uvL2ZoCA0", "payment_method_details": {"card": {"brand": "visa", "checks": {"address_line1_check": null, "address_postal_code_check": null, "cvc_check": "pass"}, "country": "US", "exp_month": 9, "exp_year": 2019, "fingerprint": "q2KzoaQ6PV4SDjZj", "funding": "credit", "last4": "4242", "three_d_secure": null, "wallet": null}, "type": "card"}, "receipt_email": null, "receipt_number": "1155-2816-4018", "receipt_url": "https://pay.stripe.com/receipts/acct_285t25GAigWUtfiZGDej/CHARGE_ID/rcpt_EI6Rzq4neTRvO3qqxY0nD8KEsfqTset", "refunded": false, "refunds": {"object": "list", "data": [], "has_more": false, "total_count": 0, "url": "/v1/charges/CHARGE_ID/refunds"}, "review": null, "shipping": null, "source": {"id": "cc_2AfS3uvL2ZoCA0", "object": "card", "address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "brand": "Visa", "country": "US", "customer": "CUSTOMER_ID", "cvc_check": "pass", "dynamic_last4": null, "exp_month": 9, "exp_year": 2019, "fingerprint": "q2KzoaQ6PV4SDjZj", "funding": "credit", "last4": "4242", "metadata": {}, "name": "Tube Sock", "tokenization_method": null}, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null}';

    private string couponData = '{"id": "DISCOUNT_ID", "object": "coupon", "amount_off": 1000, "created": 1568931033, "currency": "usd", "duration": "repeating", "duration_in_months": 6, "livemode": false, "max_redemptions": 10, "name": "Test Discount", "percent_off": null, "redeem_by": null, "times_redeemed": 0, "valid": true}';

    private string sourceData = '{"id": "SOURCE_ID","object": "source","ach_credit_transfer": {"account_number": "test_52796e3294dc","routing_number": "110000000","fingerprint": "ecpwEzmBOSMOqQTL","bank_name": "TEST BANK","swift_code": "TSTEZ122"},"amount": null,"client_secret": "src_client_secret_GafD4Etz7cBYPIR1wmFTSK6B","created": 1579640620,"currency": "usd","flow": "receiver","livemode": false,"metadata": {},"owner": {"address": null,"email": "jenny.rosen@example.com","name": null,"phone": null,"verified_address": null,"verified_email": null,"verified_name": null,"verified_phone": null},"receiver": {"address": "121042882-38381234567890123","amount_charged": 0,"amount_received": 0,"amount_returned": 0,"refund_attributes_method": "email","refund_attributes_status": "missing"},"statement_descriptor": null,"status": "pending","type": "ach_credit_transfer","usage": "reusable"}';
}