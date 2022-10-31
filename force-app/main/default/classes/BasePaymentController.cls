/**
 * @author  Dylan Bowman <dbowman@softwareanywhere.com>
 */

public virtual class BasePaymentController {
    public String DEPARTMENT;

    public String paymentEmail {get; set;}
    public String paymentFirstName {get; set;}
    public String paymentLastName {get; set;}
    public String paymentPhone {get; set;}

    public Payment_Result__c resultRecord{get; set;}

    public String error {get; set;}

    public Account account;
    public Contact contact;

    public Boolean customerExists{get;set;}

    /**
     * Gets Publishable API Key from the Credential Service for the current Department.
     *
     * @return  The Publishable API Key for Stripe needed to use Stripe Elements.
     */
    public String getApiKey() {
        return CredentialService.getPublicStripeKey(DEPARTMENT);
    }

    /**
     * Removes whitespace from both ends of the 4 required payment fields.
     */
    public virtual void cleanWhitespace() {
        //Clean the data of whitespace. 
        paymentFirstName = paymentFirstName.trim();
        paymentLastName = paymentLastName.trim();
        paymentEmail = paymentEmail.trim();
        paymentPhone = paymentPhone.trim();
    }

    /**
     * Returns a list of errors to validate the 4 required fields.
     * @return   Returns a list of strings, each explaining the failed validation.
     */
    public virtual List<String> getErrors() {
        List<String> errors = new List<String>();

        if (paymentFirstName == '') {
            errors.add('Please fill out the First Name field.');
        }
        if (paymentLastName == '') {
            errors.add('Please fill out the Last Name field.');
        }
        if (paymentEmail == '') {
            errors.add('Please fill out the Email field.');
        } else {
            if(!Pattern.matches('[a-zA-Z0-9._\\-\\+]+@[a-zA-Z0-9._-]+\\.[a-zA-Z]{2,4}', paymentEmail)){
                errors.add('Email must be a valid email.');
            }
        }
        if (paymentPhone == '') {
            errors.add('Please fill out the Phone field.');
        }

        return errors;
    }

    /**
     * Uses the strings from getErrors to determine if the form is valid or not.
     * @return   Returns boolean to determine if form state is valid.
     */
    public virtual Boolean isValidForm() {
        List<String> errors = getErrors();

        if (errors.size() > 0) {
            error = String.join(errors, '\n');
            return false;
        } else {
            error = '';
            return true;
        }
    }

    /**
     * Sets the contact and account variables with the most accurate data it can find based on the input from the user.
     */ 
    public virtual void pullAccountAndContact() {
        //Look for an existing Contact/Account.
        List<Contact> conts = [SELECT Id, AccountId, Cowork_Stripe_Customer_Id__c, WFT_Stripe_Customer_Id__c FROM Contact WHERE Email LIKE :paymentEmail];
        //Create a fallback contact. If no contact is found, assume we're creating a new one.
        contact = new Contact();

        if (conts.size() > 0) {
            contact = conts[0];
        }

        account = getAccount(contact);

        if (contact.Id == null) {
            System.debug('Creating contact');
            contact = createContact(account);
        }
    }

    /**
     * Queries the database to find the most fitting account.
     * @param  cont A Contact record that may have a related account.
     * @return      Returns an account most fitting to use.
     */
    public virtual Account getAccount(Contact cont) {
        List<Account> accts;

        //If contact has an AccountId, grab that contact's associated account. Otherwise, grab the Individuals account.
        if (cont.AccountId != null) {
            accts = [SELECT Id FROM Account WHERE Id = :cont.AccountId];
        } else {
            accts = [SELECT Id FROM Account WHERE RecordType.Name = 'Individuals'];
        }

        if (accts.size() > 0) {
            return accts[0];
        }

        return null;
    }

    /**
     * Creates a contact from the 4 required fields and the Account Id.
     * @param  acct The account to relate this contact to.
     * @return      A contact record, ready for insertion.
     */
    public virtual Contact createContact(Account acct) {
        Contact cont = new Contact();

        cont.FirstName = paymentFirstName;
        cont.LastName = paymentLastName;
        cont.Email = paymentEmail;
        cont.MobilePhone = paymentPhone;

        if (acct != null && acct.Id != null) {
            cont.AccountId = acct.Id;
        }

        return cont;
    }

    /**
     * Retrieves or Creates a valid customer Id for the Contact Variable.
     *
     * If a contact record exists, set the customerExists flag and return it's ID.
     * If not, reach out to Stripe and create a new customer, marking the Customer ID in the Payment Result Record and returning it.
     * If that fails, mark the failure in the Payment Result Record.
     *
     * @param  token A Stripe Token to create a customer, if needed.
     * @return       A Stripe Customer ID.
     */
    public virtual String getCustomerId(String token) {
        String customerId;


        //check the contact for an existing Stripe Customer.
        if (contact != null && contact.Id != null) {
            customerId = getContactCustomerId(contact);

            if (customerId != null) {
                resultRecord.Customer_Id__c = customerId;
                customerExists = true;
                return customerId;
            }
        }

        customerExists = false;

        //If one doesn't exist, create one.
        String name = paymentFirstName + ' ' +paymentLastName;

        customerId = StripePaymentService.getInstance().createCustomer(DEPARTMENT, token, paymentEmail, name, paymentPhone, contact.Id);

        if (customerId.startsWith('error:')) {
            resultRecord.Status__c = 'Customer ' + customerId;
        } else {
            resultRecord.Customer_Id__c = customerId;
        }

        return customerId;
    }

    /**
     * Gets the customer ID from the contact based on the department.
     * @param  cont A contact record.
     * @return      Returns the WFT or Cowork Customer Id from the contact, whichever is appropriate.
     */
    public String getContactCustomerId(Contact cont) {
        if (DEPARTMENT == 'WFT') {
            return cont.WFT_Stripe_Customer_Id__c;
        } else if (DEPARTMENT == 'Cowork') {
            return cont.Cowork_Stripe_Customer_Id__c;
        } else {
            return null;
        }
    }

    /**
     * Given a Customer ID, a Stripe Token, and an amount (usd), charge the customer appropriately.
     *
     * If the customerExists flag is set, create a new source and attach it to the customer so as to avoid affecting current subscriptions.
     * If the customerExists flag is not set, charge the customer using their default card.
     * If the charge is a success, mark the Charge ID in the PaymentResult.
     * If the charge is a failure, mark the Error code in the Payment Result record.
     *
     * @param  customerId  The Stripe Customer ID to charge.
     * @param  tokenId     The Stripe Token from the front-end.
     * @param  amount      The amount to charge, in USD.
     * @param  description A description of the charge.
     * @return             Returns a Charge Id.
     */
    public String chargeCustomer(String customerId, String tokenId, Decimal amount, String description) {
        String sourceId = null;

        //If the customer already exists, attach the selected card as a source.
        if (customerExists) {
            sourceId = StripePaymentService.getInstance().createSource(DEPARTMENT, tokenId);
            StripePaymentService.getInstance().attachSource(DEPARTMENT,customerId, sourceId);
        }

        String chargeId = StripePaymentService.getInstance().chargeCustomer(DEPARTMENT, customerId, sourceId, amount, description);

        if (chargeId.startsWith('error:')) {
            resultRecord.Status__c = 'Charge ' + chargeId;
        } else {
            resultRecord.Charge_Id__c = chargeId;
        }

        return chargeId;
    }


    public String createSubscription(String customerId, String token, String productId, Integer extraProducts, String discountCode, String description) {
        String subscriptionId;
        String sourceId = null;

        //Create Payment Method in Stripe, if the customer already exists.
        if (customerExists) {
            sourceId = StripePaymentService.getInstance().createSource(DEPARTMENT, token);
            StripePaymentService.getInstance().attachSource(DEPARTMENT,customerId, sourceId);
        }

        subscriptionId = StripePaymentService.getInstance().createSubscription(DEPARTMENT, customerId, sourceId, productId, discountCode, extraProducts, description);

        if (subscriptionId.startsWith('error:')) {
            resultRecord.Status__c = 'Subscription ' + subscriptionId;
        } else {
            resultRecord.Subscription_Id__c = subscriptionId;
        }
    

        return subscriptionId;
    }

    // public String createAndAttachPaymentMethod(String customerId, String token) {
    //     String paymentMethodId = StripePaymentService.getInstance().createPaymentMethod(DEPARTMENT, token);

    //     //Attach it to the customer.
    //     StripePaymentService.getInstance().attachPaymentMethod(DEPARTMENT, paymentMethodId, customerId);

    //     return paymentMethodId;
    // }

   

}