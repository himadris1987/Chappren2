/**
 *
 * StripePaymentService acts as a conduit between Stripe and Salesforce. All communication between Apex and Stripe comes through the PaymentService.
 * This allows callout-based testing to be confined to this specific class, with a mock class extending it for testing it's calling classes. 
 * This class should remain as agnostic as possible to the data architecture within Salesforce so it can be used anywhere else.
 *
 * @author  Dylan Bowman <dbowman@softwareanywhere.com>
 */
public virtual class StripePaymentService {

    public List<String> errors = new List<String>();

    @Testvisible private static StripePaymentService instance;

    public static StripePaymentService getInstance() {
        if (instance == null) {
            instance = new StripePaymentService();
        }

        return instance;
    }


    /**
     * Creates a customer in Stripe.
     * @param  department Which Department's Stripe Account the customer will be in.
     * @param  cardToken  The Token from the front-end. Will become the customer's defalt card.
     * @param  email      The Customer's email.
     * @param  name       The Customer's name.
     * @param  phone      The Customer's Phone Number.
     * @param  contactId  The Customer's ContactID. TODO: Deprecate.
     * @return            Returns the Customer's ID in Stripe. If it fails, returns the error code.
     */
    public virtual String createCustomer(String department, String cardToken, String email, String name, String phone, Id contactId) {
        System.debug('Creating Customer: '+name);
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('source', cardToken);
        bodyMap.put('email', EncodingUtil.urlEncode(email,'UTF-8'));
        bodyMap.put('name', name);
        bodyMap.put('phone', phone);
        // bodyMap.put('metadata[contactId]',contactId);

        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/customers','POST',bodyMap);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            System.debug('Failed: '+response.getStatusCode());
            errors.add('CreateCustomer failed: '+response.getStatusCode());
            String errorCode = getErrorCode(response.getBody());
            return 'error:' + String.valueOf(response.getStatusCode()) + '|' + errorCode; //error:402:card_declined

        } else {
            Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            String customerId = (String)responseMap.get('id');
            return customerId;
        }
    }

    /**
     * Creates a subscription for a customer in stripe.
     * @param  department      Which Department's Stripe Account the Subscription should be created under.
     * @param  customerId      The ID of the Stripe Customer to be subscribed
     * @param  paymentMethodId The ID of the payment method to be used. TODO: Change to Source if possible
     * @param  planId          The ID of the plan to subscribe the customer to
     * @param  couponCode      A coupon code to use, if there is one
     * @return                 Returns the Subscription ID. If it fails, returns the error code.
     */
    public virtual String createSubscription(String department, String customerId, String paymentMethodId, String planId,  String couponCode) {
        return createSubscription(department, customerId, paymentMethodId, planId, couponCode, 0, null);
    }

    /**
     * Creates a subscription for a customer in stripe.
     * @param  department      Which Department's Stripe Account the Subscription should be created under.
     * @param  customerId      The ID of the Stripe Customer to be subscribed
     * @param  paymentMethodId The ID of the payment method to be used. TODO: Change to Source if possible
     * @param  planId          The ID of the plan to subscribe the customer to
     * @param  couponCode      A coupon code to use, if there is one
     * @return                 Returns the Subscription ID. If it fails, returns the error code.
     */
    public virtual String createSubscription(String department, String customerId, String paymentMethodId, String planId,  String couponCode, String market) {
        return createSubscription(department, customerId, paymentMethodId, planId, couponCode, 0, market);
    }

    /**
     * Creates a subscription for a group membership
     * @param  department      Which Department's Stripe Account the subscription should be under
     * @param  customerId      The ID of the Stripe Customer to be subscribed
     * @param  sourceId        The ID of the payment method to be used. TODO: Change to Source if possible
     * @param  productId       The ID of the plan to subscribe the customer to
     * @param  discountCode    A coupon code to use, if there is one
     * @param  customerCount   The number of customers who need extra items on the plan
     * @return                 Returns the Subscription ID. If it fails, returns the error code.
     */
    public virtual String createSubscription(String department, String customerId, String sourceId, String productId, String discountCode, Integer customerCount, String market) {
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('customer', customerId);
        bodyMap.put('items[0][plan]', productId);

        if (sourceId != null) {
            bodyMap.put('default_source', sourceId);
        }

        if (market != null) {
            bodyMap.put('metadata[market]',market);
        }
        
        //For each element in customerCount, add a "Company Member" item to their plan. 
        if (customerCount > 0) {
            bodyMap.put('items[1][plan]', Constants.groupPlanId);
            bodyMap.put('items[1][quantity]',String.valueOf(customerCount));
        }


        bodyMap.put('billing_cycle_anchor', 'now');

        if (discountCode != null) {
            bodyMap.put('coupon', discountCode);
        }

        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/subscriptions','POST',bodyMap);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            System.debug('Failed: '+response.getStatusCode());
            errors.add('CreateSubscription failed: '+response.getStatusCode());
            String errorCode = getErrorCode(response.getBody());
            return 'error:' + String.valueOf(response.getStatusCode()) + '|' + errorCode; //error:402:card_declined
        } else {
            Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            String subscriptionId = (String)responseMap.get('id');
            return subscriptionId;
        }
    } 



    // public virtual void updateSubscription(String department, String subscriptionId, Map<String, String> bodyMap) {
    //     Http h = new Http();
    //     HttpRequest req = getRequest(department, 'v1/subscriptions', 'POST', bodyMap);
    //     HttpResponse response = h.send(req);

    //     if (response.getStatusCode() != 200) {
    //         System.debug('Failed with status '+String.valueOf(response.getStatusCode()));
    //     }
    // }


    public virtual void cancelSubscription(String department, String subscriptionId) {
        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/subscriptions/'+subscriptionId, 'DELETE', null);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            System.debug('Failed with status '+String.valueOf(response.getStatusCode()));
        }
    }

    /**
     * Calls the original chargeCustomer with a null CardID. TODO: Rename Variables to make more easily understandable.
     * @param  department Which Department's Stripe Account the customer is under
     * @param  customerId The Customer to Charge
     * @param  amount     The Amount to charge, in USD
     * @return            Returns the Charge ID.
     */
    public virtual String chargeCustomer(String department, String customerId, String sourceId, Decimal amount, String description) {
        Map<String, String> bodyMap = new Map<String, String>();
        String amt =  String.valueOf((Integer)amount*100);

        if (amt.contains('.')) {
            amt = amt.split('\\.')[0];
        }

        bodyMap.put('amount', amt); //Stripe requires the amount to be in cents. 
        bodyMap.put('currency','usd');
        bodyMap.put('customer',customerId);

        if (description != null) {
            bodyMap.put('description',description);
        }

        if (sourceId != null) {
            bodyMap.put('source', sourceId);
        }

        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/charges', 'POST', bodyMap);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            System.debug('Failed: '+response.getStatusCode());
            errors.add('ChargeCustomer failed: '+response.getStatusCode());
            String errorCode = getErrorCode(response.getBody());
            return 'error:' + String.valueOf(response.getStatusCode()) + '|' + errorCode; //error:402:card_declined
        } else {
            Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            String chargeId = (String)responseMap.get('id');
            return chargeId;
        }
    }

    /**
     * Given a token, creates a Source for that card
     * @param  department Which Department's Stripe Account to create the source under
     * @param  token      The token representing the card
     * @return            Returns the Source ID. If it fails, returns the error code.
     */
    public virtual String createSource(String department, String token) {
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('type','card');
        bodyMap.put('token',token);

        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/sources', 'POST', bodyMap);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            System.debug('Failed: '+response.getStatusCode());
            errors.add('CreateSource failed: '+response.getStatusCode());
            String errorCode = getErrorCode(response.getBody());
            return 'error:' + String.valueOf(response.getStatusCode()) + '|' + errorCode; //error:402:card_declined
        } else {
            Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            String sourceId = (String)responseMap.get('id');
            return sourceId;
        }
    }

    /**
     * Given a source Id and a Customer Id, attaches the source to the customer in Stripe.
     * @param  department Which Department's Stripe Account the customer and source are under
     * @param  customerId The Customer to attach to
     * @param  sourceId   The Source to attach
     */
    public virtual void attachSource(String department, String customerId, String sourceId) {
        Map<String, String> bodyMap = new Map<String, String>();
        bodyMap.put('source',sourceId);

        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/customers/'+customerId+'/sources', 'POST', bodyMap);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            errors.add('AttachSource failed: '+response.getStatusCode());
            System.debug('Failed: '+response.getStatusCode());
        }
    }

    /**
     * Create a discount code in Stripe to match a discount record in Salesforce
     *
     * The Discount Record contains all validation required to ensure Stripe allows the discount,
     * so this only accepts a Discount Record.
     *
     * @param  department Which Department's Stripe Account the discount will be created in
     * @param  discount   The discount record that will be reflected in Stripe.
     */
    public virtual void createDiscount(String department, Discount__c discount) {
        Map<String, String> bodyMap = new Map<String, String>();
        //Make the callout to Stripe.
        bodyMap.put('id',discount.Code__c.toUppercase());
        bodyMap.put('amount_off',String.valueOf((Integer)discount.Amount_Off__c * 100));
        bodyMap.put('name', discount.Name);

        if (discount.Duration_In_Months__c != null) {
            bodyMap.put('duration_in_months', String.valueOf((Integer)discount.Duration_In_Months__c));
        }
        
        bodyMap.put('duration', discount.Duration__c.toLowerCase());

        if (discount.Redeem_By__c != null) {
            bodyMap.put('redeem_by', String.valueOf(discount.Redeem_By__c.getTime()/1000));
        }

        if (discount.Max_Redemptions__c != null) {
            bodyMap.put('max_redemptions', String.valueOf((Integer)discount.Max_Redemptions__c));
        }

        bodyMap.put('currency', 'usd');
        bodyMap.put('metadata[discountId]', discount.Id);

        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/coupons', 'POST', bodyMap);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            errors.add('CreateDiscount failed: '+response.getStatusCode());
            System.debug('Failed: '+response.getStatusCode());
        } else {
            //In the case that they didn't add an ID, take the response and get update the discount.
            Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            String discountCode = (String)responseMap.get('id');
            Boolean valid = (Boolean)responseMap.get('valid');
            if (discountCode != discount.Code__c) {
                discount.Code__c = discountCode;
            }

            discount.Valid__c = valid;

            update discount;
        }
    }

    /**
     * Deletes a discount in Stripe.
     * @param  department Which Department's Stripe Account the discount is in. TODO: We'll need to determine, when a discount is created, which account it's in. Maybe.
     * @param  discount   The discount record to be deleted.
     */
    public virtual void deleteDiscount(String department, Discount__c discount) {
        Http h = new Http();
        HttpRequest req = getRequest(department, 'v1/coupons/'+discount.Id, 'DELETE', null);
        HttpResponse response = h.send(req);

        if (response.getStatusCode() != 200) {
            errors.add('DeleteDiscount failed: '+response.getStatusCode());
            System.debug('Failed: '+response.getStatusCode());
        }
    }


    /**
     * Create an HTTPRequest ready to send off to the proper Stripe API endpoint
     * @param  department The Department to send the request off for. Used to query for the correct Secret API Key
     * @param  route      The route needed. ex: /v1/charges
     * @param  method     The method used in the Request (GET, POST, DELETE, etc.)
     * @param  params     The map of parameters to pass into the body. Processed by paramMapToString
     * @return            Returns an HTTPRequest ready to send through an HTTP connection.
     */
    public HttpRequest getRequest(String department, String route, String method, Map<String, String> params) {
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://api.stripe.com/' + route);
        req.setMethod(method);
        String authorizationHeader = 'Bearer ' + CredentialService.getPrivateStripeKey(department);
        req.setHeader('Authorization',authorizationHeader);

        if (params != null) {
            String body = paramMapToString(params);
            System.debug(body);
            req.setBody(body);
        }


        return req;
    }

    /**
     * Takes an Apex Map and returns a string in the format accepted by the Stripe API
     *
     * Stripe uses a key-value pair method almost similar to Python's dictionary object.
     * The key is on the left, value on the right. If the value is an object, brackets are used for indexing.
     * For example:
     * If the key-value pair is: customer -> 'customer_id'
     * Stripe would want it formatted as: customer=customer_id
     * In the case of a object/hash: metadata -> (contactId -> 003000000001234)
     * Stripe would want it formatted as: metadata[contactId]=003000000001234
     * Object hashing and indexing should be handled by the calling function, and types should all be cast to string.
     *
     * @param  input an Apex map, mapping key to value for the Stripe request body
     * @return       returns a string formatted for Stripe API access.
     */
    public String paramMapToString(Map<String, String> input) {
        List<String> outputList = new List<String>();

        for (String k : input.keySet()) {
            outputList.add(k+'='+input.get(k));
        }

        return String.join(outputList,'&');
    }



    public String getErrorCode(String body) {
        try {
            ErrorWrapper ew = (ErrorWrapper)JSON.deserialize(body, ErrorWrapper.class);
            ErrorClass err = ew.error;
            return err.message;
        } catch (Exception ex) {
            return 'An Unknown Error has occured.';
        }
    }


    //Inner classes for error handling.
    public class ErrorWrapper {
        public ErrorClass error;
    }
    
    public class ErrorClass {
        public String code;
        public String doc_url;
        public String message;
        public String param;
        public String type;
        public String decline_code;
    }


}