public class GiveGiftMembershipController extends BasePaymentController{

    public boolean processRun {get;set;}

    public String memberFirstName {get;set;}
    public String memberLastName {get;set;}

    public String price{get;set;}
    public Boolean checkboxValue{get; set;}
    public String confirmType{get; set;}

    public String discountCode {get; set;}

    public Contact recipientContact;
    public Account recipientAccount;

    public Integer amountToCharge {get;set;}



    public GiveGiftMembershipController() {
        DEPARTMENT = 'Cowork';
        //As of development in Nov 2019, membership types are hard-coded, and so is the price. 
        price = '$399 (One Time)';
        amountToCharge = 399;
    }

    public PageReference processToken() {
        //Trim the whitespace.
        cleanWhitespace();

        PageReference result = null; 

        if (!isValidForm()) {
            System.debug('Form is invalid');
            return result;
        }

        //Stripe passes a "Token," which represents a credit card. Grab that.
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String token = params.get('card_token');

        //Create the result record to track the transaction.
        resultRecord = new Payment_Result__c(
            Source__c = 'Membership Gift Purchase'
        );


        //Get the account and contact info from Salesforce (if it exists).
        pullAccountAndContact();

        String customerId = getCustomerId(token);

        if (customerId.startsWith('error:')) {
            //error:400|That card has been declined.
            List<String> errorData = customerId.split('\\|');
            String errorText = errorData[1];
            System.debug(customerId);
            error = errorText + '<br/>Please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> if you think this is in error.';

            return null;
        }

        String chargeId = chargeCustomer(customerId, token, amountToCharge, 'Gift Membership Purchase');

        //Handle errors if customerId fails
        if (chargeId.startsWith('error:')) {
            //error:400:card_declined
            List<String> errorData = chargeId.split('\\|');
            String errorText = errorData[1];
            error = errorText + '<br/>Please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> if you think this is in error.';

            return null;
        }

        try {
            if (resultRecord.Status__c == null) {
                resultRecord.Status__c = 'success';
                //Create a discount code and create the discount.
                String hourSecond = System.now().format('mmss');
                String discountCode = (memberFirstName+memberLastName+hourSecond).replace(' ', '');

                Discount__c newDiscount = new Discount__c(
                    Amount_Off__c = amountToCharge,
                    Code__c = discountCode,
                    Name = 'Gift Membership: '+discountCode,
                    Duration__c = 'Once',
                    Max_Redemptions__c = 1,
                    Purchaser_Email__c = paymentEmail,
                    Purchaser_First_Name__c = paymentFirstName,
                    Purchaser_Last_Name__c = paymentLastName,
                    Recipient_First_Name__c = memberFirstName,
                    Recipient_Last_Name__c = memberLastName,
                    Gift_Membership__c = true,
                    Valid__c = true
                );

                insert newDiscount;
                result = new PageReference('https://hashtagcoworkplace.com/gift-purchased/');
            }

            contact.Cowork_Stripe_Customer_Id__c = customerId;
            upsert contact;

            resultRecord.Contact__c = contact.Id;
            resultRecord.Gateway__c = CredentialService.getStripeGateway(DEPARTMENT).Id;
            PaymentResultProcessingService.upsertPaymentResult(resultRecord);

                    //Query for the existing PaymentResultRecord and update it. 
            List<Payment_Result__c> results = [SELECT Id 
                                            FROM Payment_Result__c 
                                            WHERE Charge_Id__c = :chargeId];
            if (results.size() > 0) {
                update results;
            }
        } catch (Exception ex) {
            error = 'Something went wrong. Your payment has been made, please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> to complete this transaction.';
            return null;
        }
        
        System.debug('ProcessToken finished');

        return result;
    }

    public override void cleanWhitespace() {
        super.cleanWhitespace();
        memberFirstName = memberFirstName.trim();
        memberLastName = memberLastName.trim();
    }

    public PageReference updateDiscountCode() {
        //Clear the errors.
        error = '';

        
        if (discountCode.toLowerCase() == 'freemonth') {
            price = '$360 (One Time)';
            amountToCharge = 360;
        } else {
            price = '$399 (One Time)';
            amountToCharge = 399;

            if (discountCode.length() > 0) {
                error = 'That is not a valid discount code.';
            }
        }

        return null;
    }

    public override Boolean isValidForm() {
        List<String> errors = new List<String>();

        if (paymentFirstName == '') {
            errors.add('The Giver\'s First Name must be filled in.');
        }
        if (paymentLastName == '') {
            errors.add('The Giver\'s Last Name must be filled in.');
        }
        if (paymentEmail == '') {
            errors.add('The Giver\'s Email must be filled in.');
        } else {
            if (!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.[a-zA-Z]{2,4}', paymentEmail)) {
                errors.add('The Giver\'s Email is not a valid email.');
            }
        }

        if (paymentPhone == '') {
            errors.add('The Giver\'s Phone must be filled in.');
        }

        if (memberFirstName == '') {
            errors.add('The Recipient\'s First Name must be filled in.');
        }
        if (memberLastName == '') {
            errors.add('The Recipient\'s Last Name must be filled in.');
        }
       
        if (errors.size() > 0) {
            error = String.join(errors, '\n');
            return false;
        }

        return true;
    }
}