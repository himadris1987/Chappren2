public class WFTClassRegistrationController extends BasePaymentController {
    public class__c currentClass{get; set;}
    public boolean processRun {get;set;}
    public String classId {get;set;}
    public String className {get;set;}
    public String status {get;set;}
    public String studentSource {get;set;}
    public String adFillIn {get;set;}
    public String employeeFillIn {get;set;}
    public String otherFillIn {get;set;}
    public String socialMediaValue {get;set;}
    public String postalStreet {get;set;}
    public String postalCity {get;set;}
    public String postalState {get;set;}
	public String postalCode {get;set;}
    public Boolean smsOptIn {get;set;}
    public Boolean emailOptIn {get;set;}
    public List<SelectOption> states {get;set;}
    public Integer copyrightYear {get;set;}

    @TestVisible private Integer pixelStatusCode;

    public WFTClassRegistrationController() {
        DEPARTMENT = 'WFT';
        processRun = false;
        error='';
        status = 'enroll';
        smsOptIn = false;
        emailOptIn = false;
        copyrightYear = System.today().year();
        states = AddressUtility.getUSStatesSelectOptions();
        states[0] = new SelectOption('', 'Please Select');

        classId = apexpages.currentPage().getparameters().get('Id');

        if(String.isBlank(classId)) {
            getClassInfo(apexpages.currentPage().getParameters());
        }
        else {
            getClassInfoById(classId);
        }
    }

    public void getClassInfo(Map<String,String> params) {
        if(params.isEmpty()) {
            return;
        }

        String classNameParameter, attendanceTypeParameter, marketParameter, timeZoneParameter;

        classNameParameter = params.get('Name');
        attendanceTypeParameter = params.get('Type');
        marketParameter = params.get('Market');
        timeZoneParameter = params.get('TimeZone');
        

        if(String.isBlank(classNameParameter) || String.isBlank(attendanceTypeParameter) || String.isBlank(marketParameter) || String.isBlank(timeZoneParameter)) {
            System.debug('Missing Required Parameter');
            return;
        }

        classNameParameter = String.escapeSingleQuotes(classNameParameter);
        attendanceTypeParameter = String.escapeSingleQuotes(attendanceTypeParameter);
        marketParameter = String.escapeSingleQuotes(marketParameter);
        timeZoneParameter = String.escapeSingleQuotes(timeZoneParameter);

        try {
            currentClass = 	    [SELECT Id, Name, Display_Name__c, Market__c, Class__c, Other__c, 
                                Class_Cost__c, Class_Length__c, Class_Nights__c, Class_Description__c, 
                                Start_Date__c, End_Date__c, Name_Graphic__c, Attendance_Type__c, Attendance_Type_Graphic_URL__c,
                                Class_Skill_Level__c, Instruction_Time__c, Scheduled_Time__c, Time_Zone__c, 
                                Dont_Allow_Registrations__c
                                FROM Class__c
                                WHERE Dont_Display_On_Website__c = false AND Dont_Allow_Registrations__c = false
                                AND Display_Name__c =: classNameParameter AND Time_Zone__c =: timeZoneParameter
                                AND Attendance_Type__c =: attendanceTypeParameter AND Market__c =: marketParameter 
                                AND Posted_To_Website__c <= TODAY AND Removed_from_Website__c > TODAY LIMIT 1];
            
                className = currentClass.Display_Name__c;
                classId = currentClass.Id;

        } catch (QueryException e) {
            System.debug('Failed to Get Class Info');
            System.debug(e.getMessage());
        }
    }

    public void onPageLoad() {
        String cost = currentClass == null ? null : String.valueOf(currentClass.Class_Cost__c);
        pixelStatusCode = MarComFacebookPixel.WFTRegistrationVisit(ApexPages.currentPage(), cost).getStatusCode();     
    }


    public override void pullAccountAndContact() {
        //Look for an existing Contact/Account.
        List<Contact> conts = [SELECT Id, AccountId, 
							   WFT_Stripe_Customer_Id__c,
                               WFT_Email_Opt_In__c,
                               WFT_SMS_Opt_In__c, 
							   Student_Source__c, Market__c,
							   MailingStreet,
							   MailingCity,  
							   MailingState,
							   MailingPostalCode, 
							   Student_Source_Fill_In__c FROM Contact 
							   WHERE Email LIKE :paymentEmail];
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
        System.debug('Completed Pull Contact');
        System.debug(contact);
    }


    public void getClassInfoById(Id currentId) {
        try {
            currentClass = [ SELECT Id, Name, Display_Name__c, Market__c, Class__c, Other__c, Class_Cost__c, Class_Length__c,
                             Class_Nights__c, Class_Description__c, Start_Date__c, End_Date__c, Name_Graphic__c,Attendance_Type__c, Attendance_Type_Graphic_URL__c,
                             Class_Skill_Level__c, Instruction_Time__c, Scheduled_Time__c, Time_Zone__c, Dont_Allow_Registrations__c
                            FROM Class__c 
                            WHERE id = :currentId ];
          
            className = currentClass.Display_Name__c;
        } catch (QueryException e) {
            System.debug('Failed to Get Class Info');
            System.debug(e.getMessage());
        }
    }


    public PageReference processToken() {
        processRun = true;
        PageReference result = null; 

        cleanWhitespace();

        if (!isValidForm()) {
            return result;
        }
        if (currentClass != null && !allowedToRegister(currentClass.Market__c, postalCode)) {
            error = 'Currently, classes are only being offered in Bitwise cities.<br/> Follow us on our social channels for future expansion announcements as we continue to grow.<br/> If you have any questions please contact <a href="mailto:workforce@bitwiseindustries.com">workforce@bitwiseindustries.com</a>.';
            return null;
        }

        String token = ApexPages.currentPage().getParameters().get('card_token');
        resultRecord = new Payment_Result__c(
            Source__c = 'WFT Sign-Up'
        );

        pullAccountAndContact();

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

        if (currentClass != null) {
            Decimal classCost = (Decimal) currentClass.Class_Cost__c;
            // SEND IT IN CHARGE CUSTOMER IN 10 ARG
            String description = currentClass.Display_Name__c + ' Registration';
            String chargeId = chargeCustomer(customerId, token, classCost, description);

            //Handle errors if customerId fails
            if (chargeId.startsWith('error:')) {
                //error:400:card_declined
                List<String> errorData = chargeId.split('\\|');
                String errorText = errorData[1];
                error = errorText + '<br/>Please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> if you think this is in error.';

                return null;
            }

        } else {
            error = 'No Class specified';
            return result;
        }

        System.debug(resultRecord.Status__c);

        if (resultRecord.Status__c == null) {
            resultRecord.Status__c = 'success';
            result = new PageReference('https://bitwiseindustries.com/Confirmation'); //uncomment when switching to new page
            result.setRedirect(true);
            status = 'confirmation';
        }

        if (account != null) {
            contact.AccountId = account.Id;
        }

        contact.WFT_Stripe_Customer_Id__c = customerId;
        System.debug(socialMediaValue);

        
        switch on studentSource {
            when 'Bitwise Employee' {
                contact.Student_Source__c = studentSource;
                contact.Student_Source_Fill_In__c = employeeFillIn;
            }
            when 'Geekwise Outreach/Conference','WFT Outreach/Conference','Friends/Family','Bus Wrap' {
                contact.Student_Source__c = studentSource;
            }

            when 'Social Media' {
                contact.Student_Source__c = socialMediaValue;
            }
          
            when 'Advertisement' {
                contact.Student_Source__c = studentSource;
                contact.Student_Source_Fill_In__c = adFillIn;
            }
            when 'Other' {
                contact.Student_Source__c = studentSource;
                contact.Student_Source_Fill_In__c = otherFillIn;
            }
      
        }
		
		contact.Market__c = AddressUtility.getMarket(postalCode);
		
		
		//Always update Contacts Address fields
        contact.MailingStreet = postalStreet;
        contact.MailingCity = postalCity;
        contact.MailingState = postalState;
        contact.MailingPostalCode = postalCode;
		

        contact.WFT_Email_Opt_In__c = emailOptIn;
        contact.WFT_SMS_Opt_In__c = smsOptIn;
		System.debug('Up to Registration');
        
        try {
			System.debug(contact);
            upsert contact;
            
            // CREATE A REGISTRATION RECORD WITH INFO
            Registration__c reg = new Registration__c(
                Class__c = classId,
                Registrant__c = contact.Id,
				Street__c = postalStreet,
                City__c = postalCity,
                State__c = postalState,
				PostalCode__c = postalCode,
				Student_Source__c = contact.Student_Source__c,
				Student_Source_Fill_In__c = contact.Student_Source_Fill_In__c
            );

            System.debug(reg);

            insert reg;

            resultRecord.Contact__c = contact.Id;
            resultRecord.Registration__c = reg.Id;
            resultRecord.Amount__c = currentClass.Class_Cost__c;
            resultRecord.Contact__c = contact.Id;
            resultRecord.Gateway__c = CredentialService.getStripeGateway(DEPARTMENT).Id;
            
            PaymentResultProcessingService.upsertPaymentResult(resultRecord);
            
        } catch (Exception ex) {
            System.debug(ex);
            System.debug(ex.getMessage());
            error = 'Something went wrong. Your payment has been made, please <a href="mailto:salesforcesupport@bitwiseindustries.com">contact us</a> to complete this transaction.';
            status = 'enroll';  
            return null;
        }
        return result;
    }
    @testVisible
    private Boolean allowedToRegister(String classMarket, String postalCode) {
       String determinedMarket = AddressUtility.getMarket(postalCode);
       
       System.debug(postalCode);
       System.debug(classMarket);
       System.debug(determinedMarket);

        if (currentClass.Attendance_Type__c == 'Virtual' && determinedMarket != 'Other') {
            return true;
        }
        if (currentClass.Attendance_Type__c != 'Virtual' && classMarket == determinedMarket) {
            return true;
        }
        return false;
    }


    public override Contact createContact(Account acct) {
        Contact output = super.createContact(acct);
        return output;
    }

}