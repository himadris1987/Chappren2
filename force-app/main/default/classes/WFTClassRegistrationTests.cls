@isTest
public class WFTClassRegistrationTests {
    private static Class__c clss;


    private static void setup() {
        StripePaymentServiceMock m = new StripePaymentServiceMock();
        StripePaymentService.Instance = m;

      	Market__c market = new Market__c(Name = 'Fresno',
								Public_Knowledge__c = true,
                                Time_Zone__c = 'Pacific',
								Status__c = 'Active', 
								PostalCodes__c = '93721,93725');
		insert market;
        
        clss = new Class__c(
			Name = 'Websites For Beginners',
            Class__c = 'Websites For Beginners',
            Start_Date__c = System.today() + 7,
            Posted_To_Website__c = System.today(),
            Removed_from_Website__c = System.today() + 1,
            Dont_Display_On_Website__c = false, 
            Dont_Allow_Registrations__c = false,
            Class_Cost__c = 10,
            Market__c = 'Fresno',
            Time_Zone__c = 'Pacific',
			Attendance_Type__c = 'Virtual'
        );

        insert clss;
         
    }


    @isTest
    private static void testSetup() {
        Test.startTest();
        setup();
        Test.stopTest();  
    }


    @isTest
    private static void testGPCWithoutContact() {
        setup();

        Id RecordTypeIdContact = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individuals').getRecordTypeId();
        Account acct = new Account(
            Name = 'Spinach Corp',
            RecordTypeId = RecordTypeIdContact
        );
        insert acct;

        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.paymentFirstName = 'Bill';
        controller.paymentLastName = 'Nye';
        controller.paymentEmail = 'the@science.guy';
        controller.paymentPhone = '3141592653';
        controller.postalStreet = '700 Van Ness Ave';
        controller.postalCity = 'Fresno';
        controller.postalState = 'California';
        controller.postalCode = '93721';

        Test.startTest();
        controller.processToken();
        Test.stopTest();   

        Contact cont = [SELECT Id, Name, AccountId FROM Contact WHERE Email LIKE :controller.paymentEmail LIMIT 1];
        System.assertEquals(cont.Name,'Bill Nye');
    }


    @isTest
    private static void testGPCWithContact() {
        setup();

        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

        Account acct = new Account(
            Name = 'Spinach Corp'
        );
        insert acct;

        Contact cont = new Contact(
            FirstName = 'Popeye',
            LastName = 'The Sailor',
            Email = 'popeye@spinachcorp.com',
            AccountId = acct.Id
        );
        insert cont;

        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.paymentFirstName = 'Popeye';
        controller.paymentLastName = 'The Sailor';
        controller.paymentEmail = 'popeye@spinachcorp.com';
        controller.paymentPhone = '3141592653';
         controller.postalStreet = '700 Van Ness Ave';
        controller.postalCity = 'Fresno';
        controller.postalState = 'California';
        controller.postalCode = '93721';

        Test.startTest();
        controller.processToken();
        Test.stopTest();   

        Contact testCont = [SELECT Id, Name, AccountId FROM Contact WHERE Email LIKE :controller.paymentEmail LIMIT 1];
        System.assertEquals(testCont.Name, cont.FirstName + ' ' + cont.LastName);

    }


    @isTest
    private static void testGetApiKey() {
        insert new Gateway__c(
            Publishable_Key__c = 'FOLLOW YOUR DREAMS',
            Department__c = 'WFT',
            Active__c = true
        );

        WFTClassRegistrationController controller = new WFTClassRegistrationController();

        Test.startTest();
        String apiKey = controller.getApiKey();
        Test.stopTest();   

        System.assertEquals(apiKey, 'FOLLOW YOUR DREAMS');
    }

   
    @isTest
    private static void testgetClassInfoById() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.getClassInfoById(clss.Id);
        System.assertEquals('Fresno', controller.currentClass.Market__c);
    }
	@isTest
    private static void testgetClassInfoByIdBadId() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
		delete clss;
        controller.getClassInfoById(clss.Id);
        System.assertEquals(null, controller.currentClass);
    }
	@isTest
	private static void testGetClassInfo() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
	
        Map<String,String> params = new Map<String,String>{'Name' => clss.Name, 'Type' => clss.Attendance_Type__c, 'Market' => clss.Market__c, 'TimeZone' => clss.Time_Zone__c};
		
		controller.getClassInfo(params);
        
        System.assertEquals(clss.Id, controller.classId);
    }
	@isTest
	private static void testGetClassInfoMissingParam() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
	
        Map<String,String> params = new Map<String,String>{'Name' => clss.Name,  'Market' => clss.Market__c};
	
		controller.getClassInfo(params);
        
        System.assertEquals(null, controller.currentClass);
    }

	@isTest
	private static void testGetClassInfoBadParams() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
	
        Map<String,String> params = new Map<String,String>{'Name' => 'WFB', 'Type' => 'V', 'Market' => 'San Francisco'};
	
		controller.getClassInfo(params);
        
        System.assertEquals(null, controller.currentClass);
    }

	@isTest 
	private static void testProcessTokenNoClass() {
		setup();
		PageReference pageRef = Page.WFTClassRegistration;
		delete clss;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);
		WFTClassRegistrationController controller = new WFTClassRegistrationController();
		controller.paymentFirstName = 'Bill';
        controller.paymentLastName = 'Nye';
        controller.paymentEmail = 'the@science.guy';
        controller.paymentPhone = '3141592653';
		PageReference result = controller.processToken();
		System.assertEquals(null,result);
	}

    @isTest
    private static void testStudentSource1() {
        setup();

        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

        Account acct = new Account(
            Name = 'Spinach Corp'
        );
        insert acct;

        Contact cont = new Contact(
            FirstName = 'Popeye',
            LastName = 'The Sailor',
            Email = 'popeye@spinachcorp.com',
            AccountId = acct.Id
        );
        insert cont;

        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.paymentFirstName = 'Popeye';
        controller.paymentLastName = 'The Sailor';
        controller.paymentEmail = 'popeye@spinachcorp.com';
        controller.paymentPhone = '3141592653';
         controller.postalStreet = '700 Van Ness Ave';
        controller.postalCity = 'Fresno';
        controller.postalState = 'California';
        controller.postalCode = '93721';

        controller.studentSource = 'Bus Wrap';

        Test.startTest();
        controller.processToken();
        Test.stopTest();   

        Contact testCont = [SELECT Id, Name, Student_Source__c, Student_Source_Fill_In__c FROM Contact WHERE Email LIKE :controller.paymentEmail LIMIT 1];
        System.assertEquals(testCont.Student_Source__c, controller.studentSource);
    }
     @isTest
     private static void testStudentSource2() {
        setup();

        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

        Account acct = new Account(
            Name = 'Spinach Corp'
        );
        insert acct;

        Contact cont = new Contact(
            FirstName = 'Popeye',
            LastName = 'The Sailor',
            Email = 'popeye@spinachcorp.com',
            AccountId = acct.Id
        );
        insert cont;

        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.paymentFirstName = 'Popeye';
        controller.paymentLastName = 'The Sailor';
        controller.paymentEmail = 'popeye@spinachcorp.com';
        controller.paymentPhone = '3141592653';
         controller.postalStreet = '700 Van Ness Ave';
        controller.postalCity = 'Fresno';
        controller.postalState = 'California';
        controller.postalCode = '93721';

        controller.studentSource = 'Bitwise Employee';
        controller.employeeFillIn = 'Test Dude';
        Test.startTest();
        controller.processToken();
        Test.stopTest();   

        Contact testCont = [SELECT Id, Name, Student_Source__c, Student_Source_Fill_In__c FROM Contact WHERE Email LIKE :controller.paymentEmail LIMIT 1];
        System.assertEquals(testCont.Student_Source__c, controller.studentSource);
        System.assertEquals(testCont.Student_Source_Fill_In__c, controller.employeeFillIn);
     }
    
    @isTest
    private static void testStudentSource3() {
        setup();

        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

        Account acct = new Account(
            Name = 'Spinach Corp'
        );
        insert acct;

        Contact cont = new Contact(
            FirstName = 'Popeye',
            LastName = 'The Sailor',
            Email = 'popeye@spinachcorp.com',
            AccountId = acct.Id
        );
        insert cont;

        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.paymentFirstName = 'Popeye';
        controller.paymentLastName = 'The Sailor';
        controller.paymentEmail = 'popeye@spinachcorp.com';
        controller.paymentPhone = '3141592653';
         controller.postalStreet = '700 Van Ness Ave';
        controller.postalCity = 'Fresno';
        controller.postalState = 'California';
        controller.postalCode = '93721';

        controller.studentSource = 'Advertisement';
        controller.adFillIn = 'Test Ad';
        Test.startTest();
        controller.processToken();
        Test.stopTest();   

        Contact testCont = [SELECT Id, Name, Student_Source__c, Student_Source_Fill_In__c FROM Contact WHERE Email LIKE :controller.paymentEmail LIMIT 1];
        System.assertEquals(testCont.Student_Source__c, controller.studentSource);
        System.assertEquals(testCont.Student_Source_Fill_In__c, controller.adFillIn);
     }
    
    @isTest    
    private static void testStudentSource4() {
        setup();

        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

        Account acct = new Account(
            Name = 'Spinach Corp'
        );
        insert acct;

        Contact cont = new Contact(
            FirstName = 'Popeye',
            LastName = 'The Sailor',
            Email = 'popeye@spinachcorp.com',
            AccountId = acct.Id
        );
        insert cont;

        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.paymentFirstName = 'Popeye';
        controller.paymentLastName = 'The Sailor';
        controller.paymentEmail = 'popeye@spinachcorp.com';
        controller.paymentPhone = '3141592653';
         controller.postalStreet = '700 Van Ness Ave';
        controller.postalCity = 'Fresno';
        controller.postalState = 'California';
        controller.postalCode = '93721';

        controller.studentSource = 'Other';
        controller.otherFillIn = 'Test Other';
        Test.startTest();
        controller.processToken();
        Test.stopTest();   

        Contact testCont = [SELECT Id, Name, Student_Source__c, Student_Source_Fill_In__c FROM Contact WHERE Email LIKE :controller.paymentEmail LIMIT 1];
        System.assertEquals(testCont.Student_Source__c, controller.studentSource);
        System.assertEquals(testCont.Student_Source_Fill_In__c, controller.otherFillIn);

     }
    
    @isTest
    private static void testStudentSource5() {
        setup();

        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

        Account acct = new Account(
            Name = 'Spinach Corp'
        );
        insert acct;

        Contact cont = new Contact(
            FirstName = 'Popeye',
            LastName = 'The Sailor',
            Email = 'popeye@spinachcorp.com',
            AccountId = acct.Id
        );
        insert cont;

        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.paymentFirstName = 'Popeye';
        controller.paymentLastName = 'The Sailor';
        controller.paymentEmail = 'popeye@spinachcorp.com';
        controller.paymentPhone = '3141592653';
         controller.postalStreet = '700 Van Ness Ave';
        controller.postalCity = 'Fresno';
        controller.postalState = 'California';
        controller.postalCode = '93721';

        controller.studentSource = 'Social Media';
        controller.socialMediaValue = 'Facebook';
        Test.startTest();
        controller.processToken();
        Test.stopTest();   

        Contact testCont = [SELECT Id, Name, Student_Source__c, Student_Source_Fill_In__c FROM Contact WHERE Email LIKE :controller.paymentEmail LIMIT 1];
        System.assertEquals(testCont.Student_Source__c, controller.socialMediaValue);

     }

     @isTest
      private static void onPageLoadTest() {
		setup();
        PageReference pageRef = Page.WFTClassRegistration;
        pageRef.getParameters().put('id', clss.Id);
        Test.setCurrentPage(pageRef);

     	
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MarComFacebookPixelMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

		WFTClassRegistrationController controller = new WFTClassRegistrationController();

        Test.startTest();
		controller.onPageLoad();
        Test.stopTest();
		System.assertEquals(200, controller.pixelStatusCode);

     }
     @isTest
     private static void testAllowedToRegister() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.currentClass = clss;
        System.assertEquals(true, controller.allowedToRegister('Fresno','93721'));   
     }

     @isTest
     private static void testAllowedToRegisterNotInMarket() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.currentClass = clss;
        System.assertEquals(false, controller.allowedToRegister('Bakersfield','00050'));   
     }
     @isTest
      private static void testAllowedToRegisterVirtualMarket() {
        setup();
        WFTClassRegistrationController controller = new WFTClassRegistrationController();
        controller.currentClass = clss;
        System.assertEquals(true, controller.allowedToRegister('Virtual','93721'));   
     }



}