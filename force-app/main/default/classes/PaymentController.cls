public without sharing class PaymentController extends BasePaymentController{

    public boolean processRun {get;set;}

    public String memberCompany {get;set;}
    public String memberCity {get;set;}
    public String memberState {get;set;}
    public String discountCode {get;set;}
    public List<SelectOption> typeOptions {get;set;}
    public String membershipType {get;set;}
    public Map<String, Cowork_Membership_Types__c> membershipTypeMap{get;set;}
    public Integer memberCount {get;set;}
    public String price {get;set;}
    public Boolean conferenceRoom {get; set;}
    public Boolean codeOfConductValue {get; set;}
     public Boolean covidPolicyValue {get; set;}
    public String confirmType {get; set;}
    public Boolean allowMembership {get;set;}
    public Boolean smsOptIn {get;set;}
    public Boolean emailOptIn {get;set;}
    public String market {get;set;}
    public Membership__c membership;

    public Space__c space;

    List<SelectOption> states = getStates();
    List<SelectOption> markets = getMarkets();

    public List<SelectOption> getStates() {
        List<SelectOption> states = new List<SelectOption>(); 
        states = AddressUtility.getUSStatesSelectOptions();
        return states;
    }

    public List<SelectOption> getMarkets() {
        List<SelectOption> markets = new List<SelectOption>(); 
        markets.add(new SelectOption('Fresno','Fresno'));
        markets.add(new SelectOption('Bakersfield','Bakersfield'));
        return markets;
    }
        
    public PaymentController() {
        DEPARTMENT = 'Cowork'; //This is required to find the correct gateway.
        conferenceRoom = false;
        codeOfConductValue = false;
        covidPolicyValue = false;
        
        confirmType = 'signup';
        System.debug('Entering PaymentController Constructor');
        smsOptIn = false;
        emailOptIn = false;
        //Create the dropdown for the type from the Custom Setting table.
        membershipTypeMap = Cowork_Membership_Types__c.getAll();
        List<Cowork_Membership_Types__c> typeListUnfiltered = membershipTypeMap.values();
        List<Cowork_Membership_Types__c> typeList = new List<Cowork_Membership_Types__c>();

       allowMembership = Cowork_Allow_Memberships__c.getInstance().Allow_Memberships__c;
       System.debug('allowMembership');
       System.debug(allowMembership);

        for (Cowork_Membership_Types__c type : typeListUnfiltered) {
            if (!type.Do_Not_Show_Online__c) {
                typeList.add(type);
            }
        }

        //It seems silly and pointless to create a wrapper class to get the sorting functionality.
        //Also, the data size is going to be tiny.
        //Just use bubble sort.
        Boolean sorted = false;

        while(!sorted) {
            sorted = true;
            for (Integer i = 1; i < typeList.size(); ++i) {
                if (typeList[i].Sort_Order__c < typeList[i-1].Sort_Order__c) {
                    Cowork_Membership_Types__c temp = typeList[i-1];
                    typeList[i-1] = typeList[i];
                    typeList[i] = temp;
                    sorted = false;
                }
            }
        }

        System.debug(typeList);
        typeOptions = new List<SelectOption>();


        //For each Type (specified in a custom setting), create a selectoption.
        for (Cowork_Membership_Types__c type : typeList) {
            SelectOption so = new SelectOption(type.Name, type.Label__c);
            typeOptions.add(so);
        }


        //Process Parameters.
        Map<String, String> params = ApexPages.currentPage().getParameters();

        //memType - Specifies a default membership type.
        if (params.containsKey('memType') && membershipTypeMap.containsKey(params.get('memType'))) {
            membershipType = membershipTypeMap.get(params.get('memType')).Name;
        } else {
            membershipType = 'Individual';
        }

        //If we're passed a paymentEmail, use it. 
        if (params.containsKey('memberEmail')) {
            paymentEmail = params.get('memberEmail');
            System.debug(paymentEmail);
        }

        //If conferenceRoom is true, then we're coming from a conference booking and that data already exists. 
        if (params.get('conferenceRoom') == 'true') {
            conferenceRoom = true;
            membershipType = 'DayPass';
            String spaceId = params.get('conferenceLocation');
            space = [SELECT Id, Name, Reservation_Room_Type__c FROM Space__c WHERE Id = :spaceId];
        }
        
        processRun = false;
        error='';
        processPriceChange();
    }
    


    public PageReference processToken() {
        System.debug('Entering processToken');
        error = '';

        if (!String.isBlank(memberCity) && String.isBlank(memberState)){
            error = 'Please select a state.';
            return null;
        }
        

        //Ensure the amount is greater than 0.
        if (price.contains('$-')) {
            error = 'The total price cannot be negative.<br/>Please try a new discount code or change membership type.';
            return null;
        }



        //Get the Custom Setting record for the chosen membership type (to get Stripe data)
        Cowork_Membership_Types__c chosenType = membershipTypeMap.get(membershipType);

        processRun = true;
        PageReference result = null; 

        //Clean the data of whitespace. 
        cleanWhitespace();

        if (!isValidForm()) {
            System.debug('Form is invalid');
            return result;
        }

        //If there's a discount code applied, make sure it's valid. If not, yell at the user.
        Discount__c discountRecord = null;

        if (discountCode != '' && discountCode != null) {
            List<Discount__c> codes = [SELECT Id, Code__c, Times_Redeemed__c FROM Discount__c WHERE Code__c = :discountCode AND Valid__c = true];

            if (codes.size() == 0) {
                System.debug('Invalid Discount Code');
                error = 'That is an invalid discount code.';
                return result;
            } else {
                discountRecord = codes[0];
            }
        }

        //Stripe passes a "Token," which represents a credit card. Grab that.
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String token = params.get('card_token');

        //Create the result record to track the transaction.
        resultRecord = new Payment_Result__c(
            Source__c = 'Membership Sign-Up'
        );

        
        //Search for the Account and Contact, trying to match based on what the user entered.
        pullAccountAndContact();

        //See if there's an active membership for the Contact. If there is, yell at the user.
        if ([SELECT Id FROM Membership__c WHERE Status__c = 'Active' AND Contact__c = :contact.Id].size() > 0) {
            System.debug('Active membership already exists');
            error = 'There is already an active membership under that email address.';
            return result;
        }

        if (memberCount == null || memberCount < 0) {
            memberCount = 1;
        }
        //Create a membership for the user.
        membership = new Membership__c(Contact__c = contact.Id,
                                       Membership_Start_Date__c = Date.today(),
                                       Market__c = market,
                                       Status__c = 'Inactive',
                                       Type__c = chosenType.Label__c,
                                       Number_Of_Members__c = memberCount);
        


        //Reach out to stripe with the card token and create a customer for them.
        String customerId = getCustomerId(token);

        //Handle errors if customerId fails
        if (customerId.startsWith('error:')) {
            //error:400:card_declined
            List<String> errorData = customerId.split('\\|');
            String errorText = errorData[1];
            System.debug(customerId);
            error = errorText + '<br/>Please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> if you think this is in error.';

            return null;
        }

        Boolean subscriptionNeeded = chosenType.Pricing_Plan_Id__c != null || membershipType == 'Group'; //Decide if a subscription is needed or not.

        String subscriptionId;
        if (subscriptionNeeded) {
            //If it's a group subscription, handle the extra products. 
            Integer extraProducts = 0;
            if (membershipType == 'Group' || membershipType == 'Business') {
                extraProducts = memberCount - Constants.includedGroupSize;
            }
            //If a subscription is needed (for anything other than Day Pass), create a subscription.
            subscriptionId = createSubscription(customerId, token, chosenType.Pricing_Plan_Id__c, extraProducts, discountCode, market);

            //Handle errors if customerId fails
            if (subscriptionId.startsWith('error:')) {
                //error:400:card_declined
                List<String> errorData = subscriptionId.split('\\|');
                String errorText = errorData[1];
                error = errorText + '<br/>Please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> if you think this is in error.';

                return null;
            }


            membership.Stripe_Subscription_Id__c = subscriptionId;            
        } else {
            //If it's a conference room, charge the customer the correct amount.
            Decimal amount = 15; //A fallback. 
            String description = 'Day-Pass Purchase (' + market  + ')';
            if (conferenceRoom) {
                //Look up the space. 
                
                string durationStr = params.get('conferenceDuration');
                Decimal durationDec = Decimal.valueOf(durationStr);

                if (space.Reservation_Room_Type__c == 'Conference Room') {
                    amount = (durationDec/60) * Constants.conferenceRoomNonMemberPrice;
                } else {
                    amount = Constants.podcastBoothNonMemberPrice;
                }

                confirmType = 'conferenceRoom';
                description = 'Day-Pass + Conference Room Purchase (' + space.Name+', ' + market + ')';

            }
            //If a subscription isn't needed, just charge the customer.            
            String chargeId = chargeCustomer(customerId, token, amount, description); 

            //Handle errors if customerId fails
            if (chargeId.startsWith('error:')) {
                //error:400:card_declined
                List<String> errorData = chargeId.split('\\|');
                String errorText = errorData[1];
                error = errorText + '<br/>Please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> if you think this is in error.';

                return null;
            }

            membership.Stripe_Charge_ID__c = chargeId;
        }

        //If none of the Stripe transactions have failed, the transaction is a success.
        if (resultRecord.Status__c == null) {
            resultRecord.Status__c = 'success';
            membership.Status__c = 'Active';
            if(confirmType == 'signup'){
                result = new PageReference('https://bitwiseindustries.com/Confirmation/');
            } else {
                result = new PageReference('https://hashtagcoworkplace.com/conference-room-reserved/');  
            }
        }

        try{
            //If it's a new account, insert the account.
            if (account.Id == null) {
                insert account;
            }

            contact.AccountId = account.Id;
            contact.Cowork_Stripe_Customer_Id__c = customerId;
            contact.Cowork_SMS_Opt_In__c = smsOptIn;
            contact.Cowork_Email_Opt_In__c = emailOptIn;
            upsert contact;

            membership.Contact__c = contact.Id;
           

            if (membership.Status__c == 'Active') {
                insert membership;
            }

            if (conferenceRoom) {
                //Create the reservation.
                DateTime start = parseTime(params.get('conferenceStartTime'));
                Reservation__c res = new Reservation__c(
                    Space__c = params.get('conferenceLocation'),
                    Contact__c = contact.Id,
                    Membership__c = membership.Id,
                    Status__c = 'Charged',
                    Start__c = start,
                    End__c = start.addMinutes(Integer.valueOf(params.get('conferenceDuration')))
                );
                insert res;
            }

            //Update the discount, if there is one.
            if (discountRecord != null) {
                discountRecord.Times_Redeemed__c += 1;
                update discountRecord;
            }

            //Set the Gateway
            Gateway__c gateway = CredentialService.getStripeGateway(DEPARTMENT);

            resultRecord.Gateway__c = gateway.Id;
            resultRecord.Membership__c = membership.Id;
            resultRecord.Contact__c = contact.Id;
            PaymentResultProcessingService.upsertPaymentResult(resultRecord);

            //Query for the existing PaymentResultRecord and update it. 
            List<Payment_Result__c> results = [SELECT Id 
                                            FROM Payment_Result__c 
                                            WHERE (Subscription_Id__c = :subscriptionId AND Membership__c = null) 
                                            OR    (Customer_Id__c = :customerId AND Contact__C = null)];
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
        System.debug('Entering cleanWhitespace');
        super.cleanWhitespace();
        memberCompany = memberCompany.trim();
        memberCity = memberCity.trim();
        if (discountCode != null) {
            discountCode = discountCode.trim().toUpperCase();
        }
    }

    public PageReference processPriceChange() {
        error = '';
        System.debug('Entering ProcessPriceChange');
        System.debug(membershipType);

        Decimal discountAmount = 0;

        if (discountCode != '' && discountCode != null) {
            List<Discount__c> codes = [SELECT Id, Code__c, Amount_Off__c FROM Discount__c WHERE Code__c = :discountCode AND Valid__c = true];

            if (codes.size() > 0) {
                discountAmount = codes[0].Amount_Off__c;
            }
        }

        if (conferenceRoom) {
            Map<String, String> params = ApexPages.currentPage().getParameters();
            string durationStr = params.get('conferenceDuration');
            Decimal durationDec = (Decimal.valueOf(durationStr) / 60);

            Decimal priceDec;
            //If they book a conference room, they get a free day pass.
            if (space.Reservation_Room_Type__c == 'Conference Room') {
                priceDec = durationDec * Constants.conferenceRoomNonMemberPrice;
            } else {
                priceDec = Constants.podcastBoothNonMemberPrice;
            }

            if (priceDec < 0) {
                error = 'The total price cannot be negative.<br/>Please try a new discount code or change membership type.';
            }

            String priceStr = String.valueOf(priceDec).replaceAll('\\.0*', '.00');


            price = '$' + priceStr + ' (One-Time)';
            return null;
        }

        if (membershipType == 'Group' || membershipType == 'Business') {
            Integer amt = memberCount;

            if (amt == 0) {
                amt = 1;
            }

            Integer p = Constants.groupBasePrice;

            if (amt > Constants.includedGroupSize) {
                p += (Integer)((Constants.groupAddOnPrice * (amt-Constants.includedGroupSize)) - discountAmount);
            }


            price = '$' + String.valueOf(p) + ' (Monthly)';

        } else if (membershipType == 'DayPass') { 
            Decimal p = Constants.dayPassBasePrice - discountAmount;
            price = '$' +String.valueOf(p) + ' (One-Time)';
        } else if (membershipType == 'Individual') {
            Decimal p = Constants.individualBasePrice - discountAmount;
            price = '$' +String.valueOf(p) + ' (Monthly)';
        } else if (membershipType == 'Student') {
            Decimal p = Constants.studentBasePrice - discountAmount;
            price = '$' +String.valueOf(p) + ' (Monthly)';
        } else if (membershipType == 'VirtualTenant') {
            Decimal p = Constants.virtualTenantBasePrice - discountAmount;
            price = '$' +String.valueOf(p) + ' (Monthly)';
        }

        if (price.contains('$-')) {
            error = 'The total price cannot be negative.<br/>Please try a new discount code or change membership type.';
        }


        return null;
    }

    public override List<String> getErrors() {
        List<String> errors = super.getErrors();

        if ((membershipType == 'Group' || membershipType == 'Business') && memberCount <= 0) {
            errors.add('Business/Group memberships require a member count.');
        }

        if (codeOfConductValue == false) {
            errors.add('You must agree to the Bitwise Cowork Code of Conduct.');
        }

        if(covidPolicyValue == false) {
             errors.add('You must agree to the Bitwise Cowork COVID Protocols.');
        }

        return errors;
    }

  

    public override Account getAccount(Contact cont) {
        List<Account> accts;

        if (cont.AccountId != null) {
            accts = [SELECT Id FROM Account WHERE Id = :cont.AccountId];
        } else if (memberCompany != '') {
            accts = [SELECT Id FROM Account WHERE Name LIKE :memberCompany AND BillingCity LIKE :memberCity AND BillingState LIKE :memberState];
        } else {
            accts = [SELECT Id FROM Account WHERE RecordType.Name = 'Individuals'];
        }

        Account acct;


        if (accts.size() > 0) {
            acct = accts[0];
        } else {
            acct = new Account(Name = memberCompany, BillingCity = memberCity, BillingState = memberState);
        }

        return acct;
    }



    // public String createSubscriptionId(String customerId, String token, String productId, Integer extraProducts) {
    //     String subscriptionId;
    //     String paymentMethodId = null;

    //     //Create Payment Method in Stripe, if the customer already exists.
    //     if (customerExists) {
    //         paymentMethodId = createAndAttachPaymentMethod(customerId, token);
    //     }

    //     subscriptionId = StripePaymentService.getInstance().createSubscription(DEPARTMENT, customerId, paymentMethodId, productId, discountCode, extraProducts);

    //     if (subscriptionId.startsWith('error:')) {
    //         resultRecord.Status__c = 'Subscription ' + subscriptionId;
    //     } else {
    //         resultRecord.Subscription_Id__c = subscriptionId;
    //     }
    

    //     return subscriptionId;
    // }

    public static DateTime parseTime(String dt) {
        List<String> dtList = dt.split(' ');
        String year = dtList[5];
        String day = dtList[2];
        String month = Constants.monthToNum.get(dtList[1]);
        String ts = dtList[3];
        return DateTime.valueOfGmt(year+'-'+month+'-'+day+' '+ts);
    }
}